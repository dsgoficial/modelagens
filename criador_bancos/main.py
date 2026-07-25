"""
Criador de bancos EDGV em PostgreSQL/PostGIS.

Uso:
    python -m criador_bancos.main config.json
    python -m criador_bancos.main config.json --dry-run
    python -m criador_bancos.main config.json --overwrite NOME_DO_BANCO
    python -m criador_bancos.main --schema

O DROP de banco NÃO é autorizado pelo arquivo de configuração sozinho: config
se copia, se versiona e se reusa, então um "overwrite": true esquecido de uma
rodada anterior apagaria um banco de produção em silêncio. A autorização mora
na linha de comando, nomeando cada banco a destruir (--overwrite).
"""
import argparse
import json
import os
import re
import sys

from .models import MODELS
from .schema import schema_text, validate_against_schema

# Códigos de saída: 0 sucesso, 1 erro de execução, 2 config/uso recusado.
EXIT_OK = 0
EXIT_ERRO_EXECUCAO = 1
EXIT_RECUSADO = 2


def load_config(config_path: str) -> dict:
    config_path = os.path.abspath(config_path)
    if not os.path.isfile(config_path):
        raise FileNotFoundError(f"Arquivo de configuração não encontrado: {config_path}")

    with open(config_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    if "connection" not in config:
        raise ValueError("Campo obrigatório ausente: 'connection'")
    if "databases" not in config or not config["databases"]:
        raise ValueError("Campo obrigatório ausente ou vazio: 'databases'")

    for i, db in enumerate(config["databases"]):
        if "name" not in db:
            raise ValueError(f"databases[{i}]: campo 'name' ausente")
        if "model" not in db:
            raise ValueError(f"databases[{i}]: campo 'model' ausente")
        if db["model"] not in MODELS:
            raise ValueError(
                f"databases[{i}]: modelo '{db['model']}' não reconhecido. "
                f"Modelos disponíveis: {', '.join(MODELS.keys())}"
            )

    # Camada adicional: pega o que a validação acima não vê (campo com nome
    # errado, tipo trocado, entrada repetida na lista de bancos).
    erros = validate_against_schema(config)
    if erros:
        raise ValueError(
            "Config não bate com config_schema.json:\n  "
            + "\n  ".join(erros)
        )

    return config


def _connect_admin(connection: dict):
    """Conecta no PostgreSQL sem especificar banco (usa 'postgres')."""
    import psycopg2
    from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

    conn = psycopg2.connect(
        host=connection.get("host", "localhost"),
        port=connection.get("port", 5432),
        user=connection.get("user", "postgres"),
        password=connection.get("password", "postgres"),
        dbname="postgres",
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    return conn


def _connect_db(connection: dict, dbname: str):
    """Conecta num banco específico."""
    import psycopg2

    return psycopg2.connect(
        host=connection.get("host", "localhost"),
        port=connection.get("port", 5432),
        user=connection.get("user", "postgres"),
        password=connection.get("password", "postgres"),
        dbname=dbname,
    )


def _database_exists(conn, dbname: str) -> bool:
    with conn.cursor() as cur:
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (dbname,))
        return cur.fetchone() is not None


def _read_sql(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def _replace_srid(sql: str, original_srid: int, target_srid: int) -> str:
    """Substitui o SRID nas definições de geometria."""
    if original_srid == target_srid:
        return sql
    return re.sub(
        rf"(geometry\([^,]+,\s*){original_srid}(\s*\))",
        rf"\g<1>{target_srid}\2",
        sql,
    )


# --- Autorização do DROP -----------------------------------------------------

def _quote_arg(value: str) -> str:
    """Cita o argumento só quando precisa, para o comando sugerido poder ser
    copiado e colado direto no terminal."""
    return value if re.fullmatch(r"[A-Za-z0-9_.:/\\-]+", value) else f'"{value}"'


def comando_de_confirmacao(config_arg: str, nomes: list) -> str:
    """Monta o comando exato que autorizaria a destruição dos bancos dados."""
    partes = ["python", "-m", "criador_bancos.main", _quote_arg(config_arg)]
    for nome in nomes:
        partes += ["--overwrite", _quote_arg(nome)]
    return " ".join(partes)


def resolver_overwrites(config: dict, confirmados_cli: list, config_arg: str) -> set:
    """Decide QUAIS bancos podem ser derrubados, cruzando a intenção declarada
    no config com a confirmação nomeada na linha de comando.

    Devolve o conjunto de nomes autorizados a derrubar. Levanta ValueError
    (recusa) quando o config pede overwrite sem a confirmação correspondente,
    que é o modo de falha real: config copiado de outra rodada com
    "overwrite": true apagando um banco que ninguém quis apagar.
    """
    nomes_config = [db["name"] for db in config["databases"]]
    confirmados = set(confirmados_cli)

    desconhecidos = sorted(confirmados - set(nomes_config))
    if desconhecidos:
        raise ValueError(
            "--overwrite nomeia banco que não está no config: "
            + ", ".join(desconhecidos)
            + "\nBancos no config: "
            + ", ".join(nomes_config)
        )

    pede_overwrite = bool(config.get("options", {}).get("overwrite", False))
    if pede_overwrite:
        nao_confirmados = [n for n in nomes_config if n not in confirmados]
        if nao_confirmados:
            raise ValueError(
                'RECUSADO: o config pede "overwrite": true, mas derrubar banco '
                "exige confirmação nomeada na linha de comando.\n\n"
                f"Sem confirmação ({len(nao_confirmados)}):\n  "
                + "\n  ".join(nao_confirmados)
                + "\n\nDROP DATABASE é irreversível e MATA AS SESSÕES ATIVAS do banco "
                "(pg_terminate_backend): quem estiver editando cai na hora e perde o "
                "trabalho não salvo.\n\n"
                "Para confirmar, repita o comando nomeando cada banco a destruir:\n\n  "
                + comando_de_confirmacao(config_arg, nomes_config)
                + '\n\nPara só criar o que falta e deixar o que já existe intacto, '
                'troque "overwrite" para false no config.'
            )

    return confirmados


# --- Execução ----------------------------------------------------------------

def create_database(connection: dict, db_config: dict, allow_drop: bool = False) -> dict:
    """Cria um banco de dados e executa o SQL do modelo.

    `allow_drop` vem da confirmação na linha de comando, nunca do config: sem
    ele, um banco existente é ignorado em vez de destruído.

    Retorna dict com status da operação.
    """
    dbname = db_config["name"]
    model_key = db_config["model"]
    model = MODELS[model_key]
    srid = db_config.get("srid", model["default_srid"])

    result = {"database": dbname, "model": model_key, "srid": srid}

    # Criar o banco
    admin_conn = _connect_admin(connection)
    try:
        if _database_exists(admin_conn, dbname):
            if not allow_drop:
                result["status"] = "ignorado"
                result["message"] = (
                    "Banco já existe (para recriar: \"overwrite\": true no config "
                    f"MAIS --overwrite {_quote_arg(dbname)} na linha de comando)"
                )
                return result
            with admin_conn.cursor() as cur:
                # Desconecta sessões ativas
                cur.execute("""
                    SELECT pg_terminate_backend(pid)
                    FROM pg_stat_activity
                    WHERE datname = %s AND pid <> pg_backend_pid()
                """, (dbname,))
                cur.execute(f'DROP DATABASE "{dbname}"')

        with admin_conn.cursor() as cur:
            cur.execute(f'CREATE DATABASE "{dbname}"')
    finally:
        admin_conn.close()

    # Executar SQL do modelo
    db_conn = _connect_db(connection, dbname)
    try:
        sql = _read_sql(model["sql"])
        sql = _replace_srid(sql, model["default_srid"], srid)

        with db_conn.cursor() as cur:
            cur.execute(sql)
        db_conn.commit()

        # Executar extension se existir
        ext_path = model.get("extension")
        if ext_path and os.path.isfile(ext_path):
            ext_sql = _read_sql(ext_path)
            with db_conn.cursor() as cur:
                cur.execute(ext_sql)
            db_conn.commit()

        result["status"] = "criado"
        result["message"] = "Banco criado com sucesso"
    except Exception as e:
        db_conn.rollback()
        result["status"] = "erro"
        result["message"] = str(e)
    finally:
        db_conn.close()

    return result


# --- Dry-run -----------------------------------------------------------------

def montar_plano(config: dict, autorizados: set, config_arg: str) -> dict:
    """Monta o plano de execução sem tocar em nada: o que seria criado, o que
    já existe e o que seria DERRUBADO.

    Consulta o servidor só para saber quais bancos existem. Se não der para
    conectar, o plano sai mesmo assim, com a existência marcada como
    desconhecida, porque a metade offline da checagem (modelo, SRID, SQL do
    modelo, autorização de drop) ainda vale.
    """
    connection = config["connection"]
    plano = {
        "dry_run": True,
        "config": config_arg,
        "conexao": {
            "host": connection.get("host", "localhost"),
            "port": connection.get("port", 5432),
            "user": connection.get("user", "postgres"),
        },
        "servidor_consultado": False,
        "erro_conexao": None,
        "databases": [],
    }

    existentes = None
    try:
        admin_conn = _connect_admin(connection)
        try:
            existentes = {
                db["name"]
                for db in config["databases"]
                if _database_exists(admin_conn, db["name"])
            }
            plano["servidor_consultado"] = True
        finally:
            admin_conn.close()
    except Exception as e:
        plano["erro_conexao"] = str(e).strip()

    for db in config["databases"]:
        nome = db["name"]
        model = MODELS[db["model"]]
        existe = None if existentes is None else (nome in existentes)

        if existe is None:
            acao = "indeterminado"
        elif not existe:
            acao = "criar"
        elif nome in autorizados:
            acao = "derrubar_e_recriar"
        else:
            acao = "ignorar"

        plano["databases"].append({
            "name": nome,
            "model": db["model"],
            "srid": db.get("srid", model["default_srid"]),
            "sql": os.path.basename(model["sql"]),
            "sql_encontrado": os.path.isfile(model["sql"]),
            "existe": existe,
            "acao": acao,
        })

    acoes = [d["acao"] for d in plano["databases"]]
    plano["resumo"] = {
        "criar": acoes.count("criar"),
        "ignorar": acoes.count("ignorar"),
        "derrubar_e_recriar": acoes.count("derrubar_e_recriar"),
        "indeterminado": acoes.count("indeterminado"),
    }
    return plano


_ROTULO_ACAO = {
    "criar": "criar    ",
    "ignorar": "ignorar  ",
    "derrubar_e_recriar": "DERRUBAR ",
    "indeterminado": "?        ",
}


def imprimir_plano(plano: dict):
    print(f"DRY-RUN criador_bancos: {plano['config']}")
    c = plano["conexao"]
    print(f"Servidor: {c['user']}@{c['host']}:{c['port']}")
    if not plano["servidor_consultado"]:
        print(
            "  Sem conexão, existência dos bancos NÃO verificada: "
            f"{plano['erro_conexao']}"
        )
    print(f"Bancos: {len(plano['databases'])}")
    for d in plano["databases"]:
        linha = (
            f"  {_ROTULO_ACAO[d['acao']]} {d['name']}  "
            f"modelo={d['model']} srid={d['srid']} sql={d['sql']}"
        )
        if not d["sql_encontrado"]:
            linha += "  [SQL DO MODELO NÃO ENCONTRADO]"
        print(linha)
        if d["acao"] == "derrubar_e_recriar":
            print("      DROP DATABASE irreversível, mata as sessões ativas do banco")

    r = plano["resumo"]
    resumo = f"Resumo: {r['criar']} a criar, {r['ignorar']} a ignorar, {r['derrubar_e_recriar']} a DERRUBAR"
    if r["indeterminado"]:
        resumo += f", {r['indeterminado']} indeterminado(s)"
    print(resumo)
    print("Nada foi executado (--dry-run).")


# --- CLI ---------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Criador de bancos EDGV",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Derrubar um banco exige DUAS coisas: \"overwrite\": true no config "
            "(intenção) e --overwrite NOME na linha de comando (autorização, um "
            "por banco). O config sozinho não basta, porque config se copia."
        ),
    )
    parser.add_argument(
        "config", nargs="?", help="Caminho para o arquivo de configuração JSON",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Valida o config e mostra o que SERIA feito, sem criar nem derrubar nada",
    )
    parser.add_argument(
        "--overwrite", action="append", default=[], metavar="BANCO",
        help=(
            "Autoriza DERRUBAR o banco nomeado antes de recriá-lo. Repita a flag "
            "por banco. O DROP mata as sessões ativas e é irreversível."
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
    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    if args.schema:
        print(schema_text())
        sys.exit(EXIT_OK)

    if not args.config:
        parser.error("informe o arquivo de configuração (ou use --schema)")

    try:
        config = load_config(args.config)
    except (ValueError, FileNotFoundError, json.JSONDecodeError) as e:
        print(f"ERRO: {e}", file=sys.stderr)
        sys.exit(EXIT_RECUSADO)

    try:
        autorizados = resolver_overwrites(config, args.overwrite, args.config)
    except ValueError as e:
        print(str(e), file=sys.stderr)
        sys.exit(EXIT_RECUSADO)

    if args.dry_run:
        plano = montar_plano(config, autorizados, args.config)
        if args.json_out:
            print(json.dumps(plano, ensure_ascii=False, indent=2))
        else:
            imprimir_plano(plano)
        sys.exit(EXIT_OK)

    connection = config["connection"]

    print(f"Criando {len(config['databases'])} banco(s)...\n")
    if autorizados:
        print(f"Autorizados a DERRUBAR: {', '.join(sorted(autorizados))}\n")

    results = []
    for db_config in config["databases"]:
        print(f"  [{db_config['name']}] modelo={db_config['model']}, srid={db_config.get('srid', MODELS[db_config['model']]['default_srid'])}...")
        result = create_database(
            connection, db_config, allow_drop=db_config["name"] in autorizados,
        )
        results.append(result)
        print(f"  [{result['database']}] {result['status']}: {result['message']}\n")

    # Resumo
    criados = sum(1 for r in results if r["status"] == "criado")
    ignorados = sum(1 for r in results if r["status"] == "ignorado")
    erros = sum(1 for r in results if r["status"] == "erro")

    print("=== Resumo ===")
    print(f"Criados: {criados}")
    if ignorados:
        print(f"Ignorados: {ignorados}")
    if erros:
        print(f"Erros: {erros}")

    sys.exit(EXIT_ERRO_EXECUCAO if erros else EXIT_OK)


if __name__ == "__main__":
    main()
