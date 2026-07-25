"""
Dry-run do conversor: mostra o que SERIA feito, sem ler feição nem escrever nada.

Serve para responder, antes de gastar uma conversão inteira, as perguntas que
só o config mais o estado dos bancos respondem: em que modo isso vai rodar,
quantas feições tem a origem, quantas molduras saem, e principalmente se o
destino já tem dados (o caso em que a execução real vai abortar).

Toda consulta aqui é SÓ LEITURA e opcional: se o banco não responder, o plano
sai mesmo assim com a parte offline, marcando o que não deu para verificar.
"""
import os

from .config import load_mapping
from .converter import _DIRECTION_KEYS


def _msg_erro(exc: Exception) -> str:
    """Resume uma falha de consulta numa linha legível.

    Mensagem de erro do PostgreSQL volta na codificação do SERVIDOR (cp1252 num
    Windows pt-BR), e o driver estoura ao decodificá-la como UTF-8. O que sobra
    nesse caso é um UnicodeDecodeError que não diz nada sobre a causa, então
    vale trocar por uma frase que diga o que de fato se sabe.
    """
    texto = " ".join(str(exc).split())
    if "codec can't decode" in texto:
        return (
            "conexão falhou e a mensagem do servidor veio em codificação não-UTF-8, "
            "ilegível aqui (típico de banco inexistente ou credencial errada)"
        )
    return f"{type(exc).__name__}: {texto[:300]}"


def _descreve_endpoint(cfg: dict) -> str:
    """Descrição de uma ponta do pipeline, SEM a senha."""
    if cfg["type"] == "postgis":
        return (
            f"postgis {cfg.get('database', '?')}@{cfg.get('host', '?')}:"
            f"{cfg.get('port', 5432)} schema={cfg.get('schema', 'public')}"
        )
    return f"shapefile {cfg.get('path', '?')}"


def _engine(cfg: dict):
    from sqlalchemy import create_engine

    from .readers.postgis import _build_postgis_url

    return create_engine(_build_postgis_url(cfg))


def _origem_postgis(cfg: dict) -> dict:
    """Tabelas com geometria na origem e a contagem ESTIMADA de feições.

    Usa `pg_class.reltuples` (estimativa do planner, custo zero) em vez de
    count(*): num dry-run vale mais responder rápido do que responder exato, e
    a estimativa já dá a ordem de grandeza. Tabela nunca analisada reporta -1,
    que vira 'desconhecido' em vez de zero.
    """
    from sqlalchemy import text

    from .readers.postgis import _discover_tables_with_geom

    schema = cfg.get("schema", "public")
    filtro = cfg.get("tables") or []

    engine = _engine(cfg)
    try:
        com_geom = _discover_tables_with_geom(engine, schema)
        if filtro:
            com_geom = {t: g for t, g in com_geom.items() if t in filtro}

        with engine.connect() as conn:
            linhas = conn.execute(text(
                "SELECT c.relname, c.reltuples "
                "FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace "
                "WHERE n.nspname = :schema AND c.relkind = 'r'"
            ), {"schema": schema}).fetchall()
    finally:
        engine.dispose()

    estimativas = {nome: valor for nome, valor in linhas}
    tabelas = []
    for tabela in sorted(com_geom):
        bruto = estimativas.get(tabela)
        estimado = None if bruto is None or bruto < 0 else int(bruto)
        tabelas.append({"nome": tabela, "feicoes_estimadas": estimado})
    return {"tabelas": tabelas}


def _origem_shapefile(cfg: dict) -> dict:
    """Shapefiles da pasta de origem e a contagem de feições lida do cabeçalho."""
    path = cfg["path"]
    if not os.path.isdir(path):
        raise FileNotFoundError(f"Diretório de shapefiles não encontrado: {path}")

    filtro = [t if t.endswith(".shp") else t + ".shp" for t in (cfg.get("tables") or [])]
    nomes = sorted(f for f in os.listdir(path) if f.lower().endswith(".shp"))
    if filtro:
        nomes = [f for f in nomes if f in filtro]

    tabelas = []
    for fname in nomes:
        try:
            import fiona

            with fiona.open(os.path.join(path, fname)) as src:
                n = len(src)
        except Exception:
            # Contar é um luxo do dry-run; não vale abortar o plano por isso.
            n = None
        tabelas.append({"nome": os.path.splitext(fname)[0], "feicoes_estimadas": n})
    return {"tabelas": tabelas}


def _destino_postgis_ocupado(cfg: dict) -> dict:
    """Tabelas do destino que JÁ têm feições, que é o que faria a execução real
    abortar (a gravação é sempre em append)."""
    from .writers.postgis import _contar_linhas_existentes

    schema = cfg.get("schema", "public")
    engine = _engine(cfg)
    try:
        from sqlalchemy import inspect

        tabelas = inspect(engine).get_table_names(schema=schema)
        return _contar_linhas_existentes(engine, schema, tabelas)
    finally:
        engine.dispose()


def _conta_molduras(clip_cfg: dict) -> int:
    from sqlalchemy import text

    if clip_cfg["type"] == "postgis":
        engine = _engine(clip_cfg)
        try:
            with engine.connect() as conn:
                return int(conn.execute(text(
                    f'SELECT count(*) FROM "{clip_cfg.get("schema", "public")}".'
                    f'"{clip_cfg["table"]}"'
                )).scalar())
        finally:
            engine.dispose()

    import fiona

    with fiona.open(clip_cfg["path"]) as src:
        return len(src)


def _classes_destino(stage: dict) -> dict:
    """Classes que o mapeamento do último estágio pode produzir.

    São os nomes crus do mapeamento (antes de schema e afixo de geometria, que
    dependem da geometria de cada feição), então servem para conferir se o
    mapeamento é o esperado, não como lista literal de tabelas.
    """
    if not stage.get("mapping_file"):
        return {"total": None, "exemplos": [], "nota": "passthrough, classes iguais às da origem"}

    mapping = load_mapping(stage["mapping_file"])
    chave = _DIRECTION_KEYS[stage["direction"]]["class_destiny"]
    nomes = sorted({
        cm[chave]
        for cm in mapping.get("mapeamento_classes", [])
        if cm.get("sentido") in (None, stage["direction"]) and chave in cm
    })
    return {"total": len(nomes), "exemplos": nomes[:5]}


def montar_plano(config: dict, config_path: str, se_existir: str) -> dict:
    if "segment_clip" in config:
        modo = "segment_clip"
    elif "batch_clip" in config:
        modo = "batch_clip"
    else:
        modo = "simples"

    dest = config["destination"]
    plano = {
        "dry_run": True,
        "config": config_path,
        "modo": modo,
        "se_existir": se_existir,
        "reproject_to": config["options"].get("reproject_to"),
        "error_action": config["options"].get("error_action"),
        "estagios": [
            {
                "mapping_file": (
                    os.path.basename(s["mapping_file"]) if s.get("mapping_file") else None
                ),
                "direction": s.get("direction"),
                "quality_metadata": bool(s.get("quality_metadata")),
            }
            for s in config["stages"]
        ],
        "origem": {"type": config["source"]["type"], "descricao": _descreve_endpoint(config["source"])},
        "destino": {"type": dest["type"], "descricao": _descreve_endpoint(dest)},
        "recorte": None,
        "avisos": [],
    }

    # --- origem ---
    try:
        if config["source"]["type"] == "postgis":
            plano["origem"].update(_origem_postgis(config["source"]))
        else:
            plano["origem"].update(_origem_shapefile(config["source"]))
        conhecidas = [
            t["feicoes_estimadas"] for t in plano["origem"]["tabelas"]
            if t["feicoes_estimadas"] is not None
        ]
        plano["origem"]["total_estimado"] = sum(conhecidas) if conhecidas else None
        if not plano["origem"]["tabelas"]:
            plano["avisos"].append("A origem não tem nenhuma tabela/camada com geometria a converter.")
    except Exception as e:
        plano["origem"]["erro"] = _msg_erro(e)

    # --- destino ---
    if dest["type"] == "postgis":
        try:
            ocupadas = _destino_postgis_ocupado(dest)
            plano["destino"]["tabelas_com_feicoes"] = ocupadas
            if ocupadas and se_existir == "abortar":
                plano["avisos"].append(
                    f"{len(ocupadas)} tabela(s) do destino já têm feições: com "
                    "--se-existir abortar (padrão), a execução real NÃO escreveria nada."
                )
            elif ocupadas and se_existir == "append":
                plano["avisos"].append(
                    f"{len(ocupadas)} tabela(s) do destino já têm feições e "
                    "--se-existir append vai DUPLICAR o que já está lá."
                )
            elif ocupadas and se_existir == "replace":
                plano["avisos"].append(
                    f"--se-existir replace vai APAGAR as feições de {len(ocupadas)} "
                    f"tabela(s) de {dest.get('schema', 'public')} antes de gravar."
                )
        except Exception as e:
            plano["destino"]["erro"] = _msg_erro(e)

    if modo == "batch_clip" and dest["type"] != "shapefile":
        plano["avisos"].append(
            f"batch_clip só escreve em shapefile, mas o destino é '{dest['type']}': "
            "a execução real falharia."
        )
    if "segment_clip" in config and "batch_clip" in config:
        plano["avisos"].append(
            "config tem segment_clip E batch_clip: segment_clip vence, batch_clip é ignorado."
        )

    # --- recorte ---
    clip_key = "segment_clip" if modo == "segment_clip" else ("batch_clip" if modo == "batch_clip" else None)
    if clip_key:
        clip_cfg = config[clip_key]
        plano["recorte"] = {
            "origem": clip_key,
            "descricao": _descreve_endpoint(clip_cfg),
            "table": clip_cfg.get("table"),
            "folder_attribute": clip_cfg.get("folder_attribute"),
        }
        try:
            plano["recorte"]["molduras"] = _conta_molduras(clip_cfg)
        except Exception as e:
            plano["recorte"]["erro"] = _msg_erro(e)
    elif config["options"].get("clip_geometry") or config["options"].get("clip_file"):
        plano["recorte"] = {
            "origem": "options",
            "descricao": (
                "clip_file: " + str(config["options"]["clip_file"])
                if config["options"].get("clip_file") else "clip_geometry (WKT)"
            ),
        }

    # --- classes de destino ---
    try:
        plano["classes_destino"] = _classes_destino(config["stages"][-1])
    except Exception as e:
        plano["classes_destino"] = {"erro": _msg_erro(e)}

    return plano


def imprimir_plano(plano: dict):
    print(f"DRY-RUN conversor: {plano['config']}")
    print(f"Modo: {plano['modo']}   se-existir: {plano['se_existir']}   "
          f"error_action: {plano['error_action']}   "
          f"reprojetar_para: {plano['reproject_to'] or 'nenhum'}")

    print(f"Estágios: {len(plano['estagios'])}")
    for i, e in enumerate(plano["estagios"], 1):
        rotulo = f"{e['mapping_file']} ({e['direction']})" if e["mapping_file"] else "passthrough"
        if e["quality_metadata"]:
            rotulo += " + quality_metadata"
        print(f"  {i}. {rotulo}")

    origem = plano["origem"]
    print(f"Origem: {origem['descricao']}")
    if origem.get("erro"):
        print(f"  não consultada: {origem['erro']}")
    else:
        total = origem.get("total_estimado")
        print(f"  {len(origem['tabelas'])} tabela(s)/camada(s), "
              f"~{total if total is not None else '?'} feições (estimativa)")
        maiores = sorted(
            (t for t in origem["tabelas"] if t["feicoes_estimadas"]),
            key=lambda t: -t["feicoes_estimadas"],
        )[:5]
        for t in maiores:
            print(f"    {t['nome']}: ~{t['feicoes_estimadas']}")

    destino = plano["destino"]
    print(f"Destino: {destino['descricao']}")
    if destino.get("erro"):
        print(f"  não consultado: {destino['erro']}")
    elif "tabelas_com_feicoes" in destino:
        ocupadas = destino["tabelas_com_feicoes"]
        if not ocupadas:
            print("  destino vazio")
        else:
            print(f"  {len(ocupadas)} tabela(s) JÁ com feições "
                  f"({sum(ocupadas.values())} no total)")
            for tabela, n in sorted(ocupadas.items(), key=lambda kv: -kv[1])[:5]:
                print(f"    {tabela}: {n}")

    recorte = plano.get("recorte")
    if recorte:
        linha = f"Recorte ({recorte['origem']}): {recorte['descricao']}"
        if recorte.get("table"):
            linha += f" tabela={recorte['table']}"
        if recorte.get("folder_attribute"):
            linha += f" pasta_por={recorte['folder_attribute']}"
        print(linha)
        if recorte.get("erro"):
            print(f"  molduras não contadas: {recorte['erro']}")
        elif "molduras" in recorte:
            print(f"  {recorte['molduras']} moldura(s)")

    classes = plano.get("classes_destino", {})
    if classes.get("erro"):
        print(f"Classes de destino: não determinadas ({classes['erro']})")
    elif classes.get("total") is None:
        print(f"Classes de destino: {classes.get('nota', '?')}")
    else:
        exemplos = ", ".join(classes["exemplos"])
        print(f"Classes de destino no mapeamento final: {classes['total']} "
              f"(ex.: {exemplos})")

    for aviso in plano["avisos"]:
        print(f"AVISO: {aviso}")

    print("Nada foi lido nem escrito (--dry-run).")
