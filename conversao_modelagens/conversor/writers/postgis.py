"""
Escritor PostGIS — escreve GeoDataFrames em tabelas PostGIS.

Introspects destination table columns and drops any source columns
that don't exist in the target, avoiding "column does not exist" errors.
Also casts numeric types to match target column types.
"""
import logging
import uuid

import geopandas as gpd
import pandas as pd
from sqlalchemy import create_engine, inspect, text

from ..errors import ConversionError, DestinoNaoVazioError
from ..geometry import ensure_crs
from ..readers.postgis import _build_postgis_url

logger = logging.getLogger(__name__)

RETRY_CHUNK_SIZE = 100

# EDGV sentinel para atributo de dominio "desconhecido"
_EDGV_UNKNOWN = 9999


def _get_notnull_cols(engine, schema, table_name):
    """Return list of (column_name, data_type) for NOT NULL columns of the table."""
    try:
        q = text("""SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema=:s AND table_name=:t AND is_nullable='NO'""")
        with engine.connect() as con:
            return [(r[0], r[1]) for r in con.execute(q, {"s": schema, "t": table_name}).fetchall()]
    except Exception as e:
        logger.warning("Falha ao ler NOT NULL de %s.%s: %s", schema, table_name, e)
        return []


def _fill_required_nulls(gdf, notnull_cols, table_name):
    """Fill nulls in NOT NULL destination columns with the EDGV domain default
    (boolean -> False, numeric -> 9999). Prevents silent row drops on write
    when the mapping emits an explicit NULL for a required domain attribute."""
    geom_col = gdf.geometry.name
    filled = []
    for cn, dt in notnull_cols:
        if cn == geom_col or cn not in gdf.columns:
            continue
        # uuid antes do atalho de "não há nulo": a origem legada traz `id`
        # inteiro e cheio, que não é nulo e não é uuid. Mantê-lo faz o COPY
        # inteiro falhar. Descartar deixa o default do banco agir.
        if dt == "uuid" and not _parece_uuid(gdf[cn]):
            gdf = gdf.drop(columns=[cn])
            logger.info(
                "  %s: coluna %s descartada (destino é uuid e a origem não traz "
                "uuid); o default do banco vai gerar o valor.", table_name, cn,
            )
            continue
        if not gdf[cn].isna().any():
            continue
        if dt == "boolean":
            gdf[cn] = gdf[cn].fillna(False)
            filled.append(cn)
        elif dt in ("smallint", "integer", "bigint", "numeric", "double precision", "real"):
            gdf[cn] = gdf[cn].fillna(_EDGV_UNKNOWN)
            filled.append(cn)
    if filled:
        logger.info("  %s: null-fill em coluna(s) NOT NULL: %s", table_name, ", ".join(sorted(filled)))
    return gdf


def _parece_uuid(serie) -> bool:
    """Diz se a coluna traz uuid de verdade.

    Coluna toda nula conta como uuid (o writer a descarta e o default do banco
    gera o valor). Um só valor que não parseia como uuid reprova a coluna
    inteira: basta ele para o COPY do lote falhar.
    """
    validos = serie.dropna()
    if validos.empty:
        return False
    for valor in validos:
        try:
            uuid.UUID(str(valor))
        except (ValueError, AttributeError, TypeError):
            return False
    return True


def _strip_schema(name: str) -> str:
    return name.split(".", 1)[1] if "." in name else name


def _contar_linhas_existentes(engine, schema: str, table_names) -> dict:
    """Conta as feições já presentes em cada tabela de destino, para as tabelas
    que já existem. Devolve só as não vazias.

    Contagem exata, não estimativa de `reltuples`: uma tabela recém-carregada e
    nunca analisada reporta 0 em `reltuples`, e um falso "está vazia" aqui
    liberaria justamente a duplicação que esta checagem existe para impedir.
    """
    try:
        existentes = set(inspect(engine).get_table_names(schema=schema))
    except Exception as e:
        # Sem introspecção não dá para afirmar que o destino está vazio.
        # Avisar e seguir é melhor do que travar a conversão por isso.
        logger.warning("Falha ao listar tabelas de %s: %s", schema, e)
        return {}

    contagens = {}
    with engine.connect() as conn:
        for tabela in table_names:
            if tabela not in existentes:
                continue
            n = conn.execute(
                text(f'SELECT count(*) FROM "{schema}"."{tabela}"')
            ).scalar()
            if n:
                contagens[tabela] = int(n)
    return contagens


def _esvaziar_tabelas(engine, schema: str, tabelas):
    """Esvazia as tabelas com DELETE, numa transação só.

    DELETE e não `to_postgis(if_exists='replace')`: o replace do geopandas
    DERRUBA a tabela e a recria a partir do GeoDataFrame, perdendo chave
    primária, domínios, constraints e triggers do DDL EDGV. O banco continuaria
    de pé, mas deixaria de ser EDGV.
    """
    with engine.begin() as conn:
        for tabela in tabelas:
            conn.execute(text(f'DELETE FROM "{schema}"."{tabela}"'))
    logger.info(
        "Esvaziadas %d tabela(s) de %s antes de gravar (--se-existir replace)",
        len(tabelas), schema,
    )


def _get_dest_columns(engine, schema, table_name):
    """Return dict of {column_name: column_type} for the destination table."""
    try:
        insp = inspect(engine)
        cols = insp.get_columns(table_name, schema=schema)
        return {c["name"]: c["type"] for c in cols}
    except Exception as e:
        logger.warning("Falha ao introspect %s.%s: %s", schema, table_name, e)
        return None


def _align_gdf_to_dest(gdf, dest_cols, table_name):
    """Drop columns not in destination, cast types where needed."""
    geom_col = gdf.geometry.name
    to_drop = [c for c in gdf.columns if c != geom_col and c not in dest_cols]
    if to_drop:
        logger.info("  %s: descartando %d colunas ausentes no destino: %s",
                     table_name, len(to_drop), ", ".join(sorted(to_drop)))
        gdf = gdf.drop(columns=to_drop)

    # Cast float→int for integer columns (e.g., populacao 334620.0 → 334620)
    for col in gdf.columns:
        if col == geom_col or col not in dest_cols:
            continue
        dest_type = str(dest_cols[col]).upper()
        if "INT" in dest_type and gdf[col].dtype in ("float64", "float32"):
            gdf[col] = gdf[col].astype("Int64")

    return gdf


def _write_gdf(gdf, table_name, engine, schema):
    """Write a GeoDataFrame to PostGIS. Returns number of rows written."""
    gdf.to_postgis(
        name=table_name,
        con=engine,
        schema=schema,
        if_exists="append",
        index=False,
    )
    return len(gdf)


def _write_with_chunked_retry(gdf, table_name, engine, schema):
    """Retry failed bulk insert in chunks, then row-by-row for failed chunks.

    Devolve `(ok, falhas)`, em que `falhas` é a lista de `(indice, mensagem)`
    das linhas que o destino recusou. Quem chama PRECISA registrar essas
    falhas no relatório: linha recusada pelo destino é perda de dado, e
    reportá-la só no log deixa o resumo dizer "Erros: 0" sobre uma escrita
    incompleta.
    """
    ok = 0
    falhas = []
    for start in range(0, len(gdf), RETRY_CHUNK_SIZE):
        chunk = gdf.iloc[start:start + RETRY_CHUNK_SIZE]
        try:
            _write_gdf(chunk, table_name, engine, schema)
            ok += len(chunk)
        except Exception:
            # Chunk failed — retry row by row within this chunk
            for i in range(len(chunk)):
                try:
                    _write_gdf(chunk.iloc[[i]], table_name, engine, schema)
                    ok += 1
                except Exception as row_err:
                    falhas.append((start + i, str(row_err)))
    logger.info("Retry %s.%s: %d ok, %d falhas", schema, table_name, ok, len(falhas))
    return ok, falhas


def write_postgis(
    data: dict[str, gpd.GeoDataFrame],
    dest_config: dict,
    se_existir: str = "abortar",
    report=None,
):
    """Escreve as classes convertidas no destino PostGIS.

    `se_existir` decide o que fazer quando a tabela de destino já tem feições:
    'abortar' (padrão, não escreve nada), 'replace' (esvazia antes) ou
    'append' (acrescenta, duplicando). A checagem roda ANTES de qualquer
    escrita, para o abort não deixar o destino meio gravado.
    """
    schema = dest_config.get("schema", "public")
    srid = dest_config.get("srid", 4326)

    engine = create_engine(_build_postgis_url(dest_config))

    alvos = [_strip_schema(ft) for ft, gdf in data.items() if not gdf.empty]
    ocupadas = _contar_linhas_existentes(engine, schema, alvos)
    if ocupadas:
        if se_existir == "abortar":
            engine.dispose()
            raise DestinoNaoVazioError(schema, ocupadas)
        if se_existir == "replace":
            _esvaziar_tabelas(engine, schema, sorted(ocupadas))
        else:
            logger.warning(
                "--se-existir append: %d tabela(s) de destino já tinham feições "
                "(%d no total). As novas serão ACRESCENTADAS, não substituídas.",
                len(ocupadas), sum(ocupadas.values()),
            )

    for feature_type, gdf in data.items():
        if gdf.empty:
            logger.info("Pulando %s (vazio)", feature_type)
            continue

        table_name = _strip_schema(feature_type)
        gdf = ensure_crs(gdf, srid)

        # Rename geometry column to match destination table (typically "geom")
        if gdf.geometry.name != "geom":
            gdf = gdf.rename_geometry("geom")

        # Introspect destination and align columns
        dest_cols = _get_dest_columns(engine, schema, table_name)
        if dest_cols:
            gdf = _align_gdf_to_dest(gdf, dest_cols, table_name)

        # Preenche colunas NOT NULL que o mapa deixou nulas (evita descarte silencioso)
        notnull_cols = _get_notnull_cols(engine, schema, table_name)
        if notnull_cols:
            gdf = _fill_required_nulls(gdf, notnull_cols, table_name)

        try:
            _write_gdf(gdf, table_name, engine, schema)
            logger.info("Escrita tabela %s.%s: %d feições", schema, table_name, len(gdf))
            if report is not None:
                report.written_features += len(gdf)
        except Exception as e:
            logger.warning("Bulk insert falhou para %s.%s (%s). Retry em chunks...",
                           schema, table_name, e)
            ok, falhas = _write_with_chunked_retry(gdf, table_name, engine, schema)
            if report is not None:
                report.written_features += ok
                for idx, msg in falhas:
                    report.add_error(ConversionError(
                        source_table=f"{schema}.{table_name}",
                        feature_index=idx,
                        error_type="WRITE_ERROR",
                        message=msg,
                    ))
            elif falhas:
                logger.error(
                    "%s.%s: %d feição(ões) RECUSADAS pelo destino e não "
                    "registradas no relatório (writer chamado sem report).",
                    schema, table_name, len(falhas),
                )

    engine.dispose()
