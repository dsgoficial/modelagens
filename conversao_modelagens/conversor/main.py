"""
Orquestrador principal do conversor de modelagens EDGV.

Uso:
    python -m conversor.main config.json
    python -m conversor.main config.json --dry-run
    python -m conversor.main config.json --se-existir replace
    python -m conversor.main --schema
"""
import argparse
import json
import logging
import os
import sys
import uuid

import geopandas as gpd
import pandas as pd
from shapely import wkt

from .config import VALID_SE_EXISTIR, load_config, load_mapping
from .converter import FeatureConverter
from .dryrun import imprimir_plano, montar_plano
from .errors import (
    ConversionError,
    ConversionReport,
    DestinoNaoVazioError,
    ValorForaDeDominioError,
)
from .geometry import aggregate, clip, detect_geom_type, ensure_crs, reproject, split_multi
from .readers.postgis import read_postgis, _build_postgis_url
from .readers.shapefile import read_shapefiles
from .schema import schema_text
from .writers.postgis import write_postgis
from .writers.shapefile import write_shapefiles

logger = logging.getLogger("conversor")

_INTERNAL_KEYS = frozenset({
    "$GEOM_TYPE", "INVALID_GEOM", "CLASS_NOT_FOUND", "CLASS_FILTERED",
    "AGGREGATE_GEOM", "feature_type", "feature_type_original",
    "feature_type_sem_schema", "feature_type_sem_afixo",
})


def _setup_logging(config: dict):
    log_file = config["options"].get("log_file")
    handlers = [logging.StreamHandler(sys.stdout)]
    if log_file:
        log_dir = os.path.dirname(os.path.abspath(log_file))
        if log_dir:
            os.makedirs(log_dir, exist_ok=True)
        handlers.append(logging.FileHandler(log_file, encoding="utf-8"))
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        handlers=handlers,
    )


def _read_source(config: dict) -> dict[str, gpd.GeoDataFrame]:
    src = config["source"]
    if src["type"] == "postgis":
        return read_postgis(src)
    elif src["type"] == "shapefile":
        return read_shapefiles(src)
    else:
        raise ValueError(f"Tipo de fonte não suportado: {src['type']}")


def _write_destination(
    data: dict[str, gpd.GeoDataFrame], dest_config: dict, se_existir: str = "abortar",
    report: ConversionReport = None,
):
    if dest_config["type"] == "postgis":
        write_postgis(data, dest_config, se_existir=se_existir, report=report)
    elif dest_config["type"] == "shapefile":
        # Shapefile não acumula: `to_file` reescreve o arquivo inteiro, então a
        # política de reexecução não se aplica.
        write_shapefiles(data, dest_config)
    else:
        raise ValueError(f"Tipo de destino não suportado: {dest_config['type']}")


def _normalize_value(val):
    if val is None:
        return None
    try:
        if pd.isna(val):
            return None
    except (ValueError, TypeError):
        pass
    # MUVD/MGCP sentinel: -999999 means "No Information"
    if isinstance(val, (int, float)) and val == -999999:
        return None
    return val


def _convert_source_data(
    source_data: dict[str, gpd.GeoDataFrame],
    converter: FeatureConverter,
    report: ConversionReport,
    error_action: str,
    quality_meta: dict | None = None,
) -> list[dict]:
    """Converte todas as feições fonte, retornando lista de feições convertidas
    com geometria original preservada (sem clip)."""
    converted = []

    for table_name, gdf in source_data.items():
        logger.info("Processando %s (%d feições)...", table_name, len(gdf))
        geom_col = gdf.geometry.name  # "geom" or "geometry"
        attr_columns = [col for col in gdf.columns if col != geom_col]

        for idx, row in gdf.iterrows():
            report.total_features += 1
            geom = row[geom_col]
            simple_geoms = split_multi(geom)

            for simple_geom in simple_geoms:
                geom_type = detect_geom_type(simple_geom)
                attrs = {col: _normalize_value(row[col]) for col in attr_columns}
                attrs["feature_type"] = table_name

                feat_dict = converter.build_feature_dict(attrs, geom_type)

                if feat_dict.get("INVALID_GEOM"):
                    report.skipped_invalid_geom += 1
                    report.add_error(ConversionError(
                        table_name, idx, "INVALID_GEOM",
                        f"Tipo de geometria não suportado: {geom.geom_type if geom else 'None'}",
                    ))
                    if error_action == "fail":
                        logger.error(report.summary())
                        sys.exit(1)
                    continue

                try:
                    mapped = converter.convert_feature(feat_dict)
                except Exception as e:
                    report.add_error(ConversionError(
                        table_name, idx, "CONVERSION_ERROR", str(e),
                    ))
                    if error_action == "fail":
                        logger.error(report.summary())
                        sys.exit(1)
                    continue

                if mapped.get("CLASS_NOT_FOUND"):
                    report.skipped_class_not_found += 1
                    report.registrar_descarte(
                        table_name, bool(mapped.get("CLASS_FILTERED")),
                    )
                    continue

                dest_type = mapped.get("feature_type", table_name)
                output_attrs = {
                    k: v for k, v in mapped.items() if k not in _INTERNAL_KEYS
                }

                # Inject quality metadata for EDGV Topo 2.0
                if quality_meta:
                    output_attrs.update(quality_meta)

                converted.append({
                    "dest_type": dest_type,
                    "attrs": output_attrs,
                    "geometry": simple_geom,
                    "aggregate": mapped.get("AGGREGATE_GEOM", False),
                    "geom_type": geom_type,
                })
                report.converted_features += 1

    return converted


def _passthrough_source_data(
    source_data: dict[str, gpd.GeoDataFrame],
    report: ConversionReport,
) -> list[dict]:
    """Modo passthrough: sem mapeamento, apenas extrai feições preservando tabela/atributos."""
    converted = []

    for table_name, gdf in source_data.items():
        logger.info("Passthrough %s (%d feições)...", table_name, len(gdf))
        geom_col = gdf.geometry.name
        attr_columns = [col for col in gdf.columns if col != geom_col]

        for idx, row in gdf.iterrows():
            report.total_features += 1
            geom = row[geom_col]
            simple_geoms = split_multi(geom)

            for simple_geom in simple_geoms:
                geom_type = detect_geom_type(simple_geom)
                if geom_type is None:
                    report.skipped_invalid_geom += 1
                    continue

                attrs = {col: _normalize_value(row[col]) for col in attr_columns}

                converted.append({
                    "dest_type": table_name,
                    "attrs": attrs,
                    "geometry": simple_geom,
                    "aggregate": False,
                    "geom_type": geom_type,
                })
                report.converted_features += 1

    return converted


def _clip_and_build_gdfs(
    converted_features: list[dict],
    clip_geom,
    dest_srid: int,
    target_srid: int | None,
) -> dict[str, gpd.GeoDataFrame]:
    """Aplica clip opcional e constrói GeoDataFrames de saída agrupados por dest_type."""
    output_data: dict[str, list[dict]] = {}

    for feat in converted_features:
        geom = feat["geometry"]
        if clip_geom is not None:
            geom = clip(geom, clip_geom)
            if geom is None:
                continue

        dest_type = feat["dest_type"]
        output_data.setdefault(dest_type, []).append({
            "attrs": feat["attrs"],
            "geometry": geom,
            "aggregate": feat["aggregate"],
            "geom_type": feat["geom_type"],
        })

    return _build_output_gdfs(output_data, dest_srid, target_srid)


def _segment_and_build_gdfs(
    converted_features: list[dict],
    clip_geometries: list,
    source_srid: int,
    target_srid: int | None,
) -> dict[str, gpd.GeoDataFrame]:
    """Segmenta cada feição por cada moldura, produzindo um resultado unificado.

    Cada feição é recortada por cada moldura individualmente.
    Uma feição que cruza N molduras se torna N feições separadas.
    """
    output_data: dict[str, list[dict]] = {}

    for feat in converted_features:
        geom = feat["geometry"]
        dest_type = feat["dest_type"]

        for clip_geom in clip_geometries:
            clipped = clip(geom, clip_geom)
            if clipped is None:
                continue

            output_data.setdefault(dest_type, []).append({
                "attrs": feat["attrs"],
                "geometry": clipped,
                "aggregate": feat["aggregate"],
                "geom_type": feat["geom_type"],
            })

    return _build_output_gdfs(output_data, source_srid, target_srid)


def _build_output_gdfs(
    output_data: dict[str, list[dict]],
    dest_srid: int,
    target_srid: int | None,
) -> dict[str, gpd.GeoDataFrame]:
    """Constrói GeoDataFrames a partir dos dados de saída agrupados."""
    output_gdfs: dict[str, gpd.GeoDataFrame] = {}

    for dest_type, features in output_data.items():
        if not features:
            continue

        should_aggregate = features[0].get("aggregate", False)

        if should_aggregate:
            groups: dict[tuple, list] = {}
            for f in features:
                attr_key = tuple(sorted(f["attrs"].items()))
                groups.setdefault(attr_key, []).append(f)

            rows = []
            for group_feats in groups.values():
                geoms = [f["geometry"] for f in group_feats]
                agg_geom = aggregate(geoms, group_feats[0].get("geom_type"))
                row_attrs = dict(group_feats[0]["attrs"])
                row_attrs["geometry"] = agg_geom
                rows.append(row_attrs)
        else:
            # Cada pedaco de uma feicao segmentada por moldura (ou explodida de
            # multiparte por split_multi) carrega o mesmo attrs da origem, incl.
            # o id. Num destino com PK em id, os pedacos repetidos colidem e sao
            # descartados no COPY (perda de geometria nas linhas que cruzam folha).
            # Mantem o id original no primeiro pedaco (rastreabilidade) e gera um
            # uuid novo para os demais, pois cada pedaco e uma feicao distinta no
            # banco de edicao.
            seen_ids: set = set()
            rows = []
            for f in features:
                attrs = f["attrs"]
                fid = attrs.get("id")
                if fid is not None:
                    if fid in seen_ids:
                        attrs = {**attrs, "id": str(uuid.uuid4())}
                    else:
                        seen_ids.add(fid)
                rows.append({**attrs, "geometry": f["geometry"]})

        gdf = gpd.GeoDataFrame(rows, geometry="geometry")
        gdf = gdf.set_crs(f"EPSG:{dest_srid}", allow_override=True)

        if target_srid:
            gdf = reproject(gdf, target_srid)

        output_gdfs[dest_type] = gdf

    return output_gdfs


def _load_clip_geometry(config: dict):
    """Carrega geometria de clip simples (modo não-batch)."""
    options = config["options"]
    if options.get("clip_geometry"):
        return wkt.loads(options["clip_geometry"])
    if options.get("clip_file"):
        clip_gdf = gpd.read_file(options["clip_file"])
        if clip_gdf.empty:
            logger.warning("Arquivo de recorte vazio: %s", options["clip_file"])
            return None
        return clip_gdf.union_all()
    return None


def _load_clip_source(clip_cfg: dict) -> gpd.GeoDataFrame:
    """Carrega molduras de uma fonte PostGIS ou shapefile."""
    if clip_cfg["type"] == "postgis":
        from sqlalchemy import create_engine
        engine = create_engine(_build_postgis_url(clip_cfg))
        schema = clip_cfg.get("schema", "public")
        table = clip_cfg["table"]
        gdf = gpd.read_postgis(
            f'SELECT * FROM "{schema}"."{table}"',
            engine,
            geom_col=clip_cfg.get("geom_column", "geom"),
        )
        engine.dispose()
    elif clip_cfg["type"] == "shapefile":
        gdf = gpd.read_file(
            clip_cfg["path"],
            encoding=clip_cfg.get("encoding", "UTF-8"),
        )
    else:
        raise ValueError(f"Tipo de clip não suportado: {clip_cfg['type']}")

    if gdf.empty:
        raise ValueError("Tabela/arquivo de molduras está vazio")

    return gdf


def _load_batch_clips(config: dict) -> list[dict]:
    """Carrega molduras para o modo batch. Retorna lista de dicts com
    'geometry' e 'folder_name'."""
    batch_cfg = config["batch_clip"]
    folder_attr = batch_cfg["folder_attribute"]

    gdf = _load_clip_source(batch_cfg)

    if folder_attr not in gdf.columns:
        raise ValueError(
            f"Atributo '{folder_attr}' não encontrado na tabela de molduras. "
            f"Colunas disponíveis: {list(gdf.columns)}"
        )

    clips = []
    geom_col = gdf.geometry.name
    for _, row in gdf.iterrows():
        folder_name = str(row[folder_attr]).strip()
        if not folder_name:
            logger.warning("Moldura com '%s' vazio, ignorando", folder_attr)
            continue
        clips.append({
            "geometry": row[geom_col],
            "folder_name": folder_name,
        })

    logger.info("Carregadas %d molduras para recorte em lote", len(clips))
    return clips


def _load_segment_clips(config: dict) -> list:
    """Carrega molduras para segmentação. Retorna lista de geometrias."""
    gdf = _load_clip_source(config["segment_clip"])
    geom_col = gdf.geometry.name
    geometries = [row[geom_col] for _, row in gdf.iterrows() if row[geom_col] is not None and not row[geom_col].is_empty]
    logger.info("Carregadas %d molduras para segmentação", len(geometries))
    return geometries


def _export_report(report: ConversionReport, config: dict, suffix: str = ""):
    print()
    print(report.summary())

    log_file = config["options"].get("log_file")
    if log_file:
        base, ext = os.path.splitext(log_file)
        report_json_path = base + suffix + "_report.json"
        report.export_json(report_json_path)
        logger.info("Relatório exportado para: %s", report_json_path)


def _build_quality_meta(qm_config: dict | None) -> dict | None:
    """Monta o dicionário de metadados de qualidade injetado nas feições
    (EDGV Topo 2.0). Retorna None se o estágio não declara quality_metadata."""
    if not qm_config:
        return None
    fonte_entry = {
        "fonte": qm_config.get("fonte", "Desconhecida"),
        "metodo_aquisicao": qm_config.get("metodo_aquisicao", 9999),
        "data_aquisicao": qm_config.get("data_aquisicao"),
        "escala_fonte": qm_config.get("escala_fonte"),
        "acuracia_planimetrica": qm_config.get("acuracia_planimetrica"),
        "observacao": qm_config.get("observacao"),
    }
    # acuracia_planimetrica appears both inside fontes (per-source)
    # and as a top-level column (feature-level, used for confiabilidade)
    return {
        "fontes": json.dumps([fonte_entry], ensure_ascii=False),
        "status_ciclo_vida": qm_config.get("status_ciclo_vida", 1),
        "validacao": qm_config.get("validacao", 1),
        "confirmacao_geometria": qm_config.get("confirmacao_geometria", 1),
        "confirmacao_atributos": qm_config.get("confirmacao_atributos", 1),
        "acuracia_planimetrica": qm_config.get("acuracia_planimetrica"),
    }


def _stage_label(stage: dict) -> str:
    if stage.get("mapping_file"):
        return f"{os.path.basename(stage['mapping_file'])} ({stage.get('direction')})"
    return "passthrough"


def _run_stage_transform(
    stage: dict,
    data: dict[str, gpd.GeoDataFrame],
    report: ConversionReport,
    error_action: str,
) -> list[dict]:
    """Aplica um único estágio (mapeamento ou passthrough) sobre `data`,
    retornando a lista de feições convertidas (sem clip/reproject)."""
    if not stage.get("mapping_file"):
        logger.info("Modo passthrough (sem mapeamento de classes/atributos)")
        return _passthrough_source_data(data, report)

    mapping_dict = load_mapping(stage["mapping_file"])
    logger.info("Mapeamento carregado: %s", stage["mapping_file"])
    converter = FeatureConverter(mapping_dict, stage["direction"])
    quality_meta = _build_quality_meta(stage.get("quality_metadata"))
    return _convert_source_data(data, converter, report, error_action, quality_meta)


def _portao_dominio(config: dict, ignorar: bool):
    """Confere, ANTES de ler feição, se a origem guarda valor que o destino
    recusa. Só leitura, nos dois bancos.

    Existe porque a descoberta vinha tarde demais: a conversão rodava inteira,
    o retry linha a linha do escritor virava aviso no log, e uma classe podia
    terminar com zero feição no destino. Medido em 2026-09-03 numa conversão
    Topo 1.3 para 1.4, em `llp_limite_legal_l`.

    Falha de conexão aqui não aborta a conversão: avisa e segue, porque um
    portão que derruba trabalho bom por indisponibilidade de rede vira a
    primeira coisa que se desliga.
    """
    from .checar_dominios import checar_config, resumo_checagem

    try:
        achados, textos, motivo = checar_config(config)
    except Exception as e:
        logger.warning("Checagem de domínio não pôde rodar (%s). Seguindo.", e)
        return

    for linha in resumo_checagem(achados, textos, motivo):
        logger.info(linha)
    graves = [a for a in achados if a["default_no_destino"] is None]
    if not graves and not textos:
        return
    if ignorar:
        logger.warning(
            "--ignorar-dominio: seguindo mesmo com %d coluna(s) que o destino "
            "recusa. As feições correspondentes SERÃO perdidas.",
            len(graves) + len(textos),
        )
        return
    raise ValorForaDeDominioError(graves, textos)


def run(config_path: str, se_existir: str = "abortar", ignorar_dominio: bool = False):
    config = load_config(config_path)
    _setup_logging(config)

    stages = config["stages"]
    error_action = config["options"].get("error_action", "skip")
    target_srid = config["options"].get("reproject_to")
    source_srid = config["source"].get("srid", 4326)

    logger.info("Carregando configuração de: %s", config_path)
    logger.info("Pipeline com %d estágio(s)", len(stages))

    _portao_dominio(config, ignorar_dominio)

    # Read source data (uma única vez)
    logger.info("Lendo dados de origem...")
    source_data = _read_source(config)
    logger.info("Lidas %d tabelas/layers", len(source_data))

    # Estágios intermediários: transformam em memória (sem clip/reproject/escrita).
    # A saída de cada estágio é materializada como dict[classe -> GeoDataFrame],
    # exatamente a forma que o estágio seguinte consome como origem.
    data = source_data
    for i, stage in enumerate(stages[:-1]):
        logger.info(
            "=== Estágio %d/%d: %s ===", i + 1, len(stages), _stage_label(stage)
        )
        stage_report = ConversionReport()
        converted = _run_stage_transform(stage, data, stage_report, error_action)
        data = _clip_and_build_gdfs(converted, None, source_srid, None)
        logger.info(
            "Estágio %d: %d feições -> %d classes intermediárias",
            i + 1, stage_report.converted_features, len(data),
        )
        if stage_report.converted_features == 0:
            logger.warning(
                "Estágio %d converteu 0 feições — verifique a compatibilidade de "
                "schema/afixo entre os mapeamentos encadeados", i + 1,
            )

    # Estágio final: produz `converted` e despacha para segment/batch/single.
    final_stage = stages[-1]
    logger.info(
        "=== Estágio %d/%d (final): %s ===",
        len(stages), len(stages), _stage_label(final_stage),
    )
    report = ConversionReport()
    converted = _run_stage_transform(final_stage, data, report, error_action)

    logger.info("Processadas %d feições", len(converted))

    if "segment_clip" in config:
        _run_segment(config, converted, source_srid, target_srid, report, se_existir)
    elif "batch_clip" in config:
        _run_batch(config, converted, source_srid, target_srid, report, se_existir)
    else:
        _run_single(config, converted, source_srid, target_srid, report, se_existir)

    return report


def _run_single(config, converted, source_srid, target_srid, report, se_existir="abortar"):
    """Modo normal: clip único opcional + escrita em um destino."""
    clip_geom = _load_clip_geometry(config)

    output_gdfs = _clip_and_build_gdfs(converted, clip_geom, source_srid, target_srid)

    logger.info("Escrevendo %d classes destino...", len(output_gdfs))
    _write_destination(output_gdfs, config["destination"], se_existir, report)

    _export_report(report, config)


def _run_batch(config, converted, source_srid, target_srid, report, se_existir="abortar"):
    """Modo batch: para cada moldura, recorta e escreve em subpasta separada."""
    clips = _load_batch_clips(config)
    dest_config = config["destination"]
    base_path = dest_config.get("path", "")

    if dest_config["type"] != "shapefile":
        raise ValueError(
            "Modo batch_clip atualmente suporta apenas destino 'shapefile'. "
            f"Tipo configurado: '{dest_config['type']}'"
        )

    total_written = 0
    for i, clip_info in enumerate(clips, 1):
        folder_name = clip_info["folder_name"]
        clip_geom = clip_info["geometry"]

        logger.info(
            "[%d/%d] Recortando para: %s", i, len(clips), folder_name,
        )

        output_gdfs = _clip_and_build_gdfs(converted, clip_geom, source_srid, target_srid)

        if not output_gdfs:
            logger.info("  Nenhuma feição no recorte '%s', pulando", folder_name)
            continue

        clip_dest = dict(dest_config)
        clip_dest["path"] = os.path.join(base_path, folder_name)

        feat_count = sum(len(gdf) for gdf in output_gdfs.values())
        logger.info(
            "  Escrevendo %d classes (%d feições) em %s",
            len(output_gdfs), feat_count, clip_dest["path"],
        )
        _write_destination(output_gdfs, clip_dest, se_existir, report)
        total_written += feat_count

    logger.info(
        "Batch concluído: %d molduras processadas, %d feições escritas no total",
        len(clips), total_written,
    )
    _export_report(report, config)


def _run_segment(config, converted, source_srid, target_srid, report, se_existir="abortar"):
    """Modo segmentação: recorta cada feição por cada moldura, resultado unificado.

    Transforma um banco contínuo em contíguo — feições são segmentadas nas
    bordas das molduras. Ideal para preparação de banco de edição.
    """
    clip_geometries = _load_segment_clips(config)

    logger.info("Segmentando feições por %d molduras...", len(clip_geometries))

    output_gdfs = _segment_and_build_gdfs(
        converted, clip_geometries, source_srid, target_srid,
    )

    feat_count = sum(len(gdf) for gdf in output_gdfs.values())
    logger.info(
        "Segmentação concluída: %d classes, %d feições (de %d originais)",
        len(output_gdfs), feat_count, len(converted),
    )

    _write_destination(output_gdfs, config["destination"], se_existir, report)
    _export_report(report, config)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Conversor de modelagens EDGV, Python puro",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "A gravação em PostGIS é sempre em append, então rodar a mesma "
            "conversão duas vezes duplicaria as feições. Por isso --se-existir "
            "vem como 'abortar': tabela de destino não vazia exige decisão "
            "explícita. Use --dry-run para ver o estado antes de converter."
        ),
    )
    parser.add_argument(
        "config", nargs="?", help="Caminho para o arquivo de configuração JSON",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Valida o config e mostra o que SERIA feito, sem ler nem escrever feição",
    )
    parser.add_argument(
        "--se-existir", choices=VALID_SE_EXISTIR, default="abortar", dest="se_existir",
        help=(
            "O que fazer quando a tabela de destino (PostGIS) já tem feições: "
            "abortar (padrão), replace (esvazia antes de gravar) ou append "
            "(acrescenta, duplicando)"
        ),
    )
    parser.add_argument(
        "--schema", action="store_true",
        help="Imprime o JSON Schema do arquivo de configuração e sai",
    )
    parser.add_argument(
        "--json", action="store_true", dest="json_out",
        help="Saída em JSON (vale para --dry-run)",
    )
    parser.add_argument(
        "--ignorar-dominio", action="store_true", dest="ignorar_dominio",
        help=(
            "Converte mesmo que a origem tenha valor que o destino recusa. "
            "As feições correspondentes serão perdidas, uma a uma, e o "
            "relatório dirá quais"
        ),
    )
    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    if args.schema:
        print(schema_text())
        sys.exit(0)

    if not args.config:
        parser.error("informe o arquivo de configuração (ou use --schema)")

    if args.dry_run:
        try:
            config = load_config(args.config)
        except (ValueError, FileNotFoundError, json.JSONDecodeError) as e:
            print(f"ERRO: {e}", file=sys.stderr)
            sys.exit(2)
        plano = montar_plano(config, args.config, args.se_existir)
        if args.json_out:
            print(json.dumps(plano, ensure_ascii=False, indent=2))
        else:
            imprimir_plano(plano)
        sys.exit(0)

    try:
        report = run(
            args.config, se_existir=args.se_existir,
            ignorar_dominio=args.ignorar_dominio,
        )
    except ValorForaDeDominioError as e:
        # Não é falha de conversão, é decisão pendente, como o destino não vazio.
        print(f"\n{e}", file=sys.stderr)
        sys.exit(2)
    except DestinoNaoVazioError as e:
        # Guarda de reexecução: não é falha de conversão, é decisão pendente.
        print(f"\n{e}", file=sys.stderr)
        sys.exit(2)
    except (ValueError, FileNotFoundError, json.JSONDecodeError) as e:
        print(f"ERRO: {e}", file=sys.stderr)
        sys.exit(2)

    # Perda de feição não pode sair com 0: quem chama por script precisa saber
    # que o destino ficou incompleto sem ler o log inteiro.
    if report is not None and report.houve_perda():
        sys.exit(1)


if __name__ == "__main__":
    main()
