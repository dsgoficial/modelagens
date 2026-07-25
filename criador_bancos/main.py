"""
Criador de bancos EDGV em PostgreSQL/PostGIS.

Uso:
    python -m criador_bancos.main config.json
    python -m criador_bancos.main config.json --dry-run
    python -m criador_bancos.main --schema

Esta ferramenta CRIA banco, e só. Ela não derruba banco nenhum, em nenhuma
circunstância: não existe flag, chave de config nem combinação das duas que a
faça dar DROP DATABASE. Banco que já existe é sempre ignorado, e a execução
segue para os demais.

A capacidade de derrubar existia e foi removida de propósito. Config se copia,
se versiona e se reusa, e os configs versionados aqui nomeiam bancos de
produção com trabalho de campo dentro; um DROP disparado por engano é perda
irrecuperável. Recriar um banco passou a exigir um ato humano deliberado FORA
desta ferramenta (dropdb ou DROP DATABASE), com a conferência de quem depende
dele feita por gente.
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


def remover_chaves_obsoletas(config: dict) -> list:
    """Tira do config, em memória, as chaves que a ferramenta deixou de aceitar
    e devolve a lista de avisos a imprimir.

    Config antigo não pode virar erro fatal. Quem tem um `"options"` de uma
    rodada anterior (com o extinto `"overwrite"` dentro) precisa continuar
    criando banco normalmente, só que sem a parte destrutiva, que saiu. Sem
    isto, o `additionalProperties: false` do schema recusaria o arquivo inteiro
    por causa de uma chave que hoje não faz nada.
    """
    avisos = []
    options = config.pop("options", None)
    if options is None:
        return avisos

    if isinstance(options, dict) and "overwrite" in options:
        avisos.append(
            'AVISO: a chave "options.overwrite" não existe mais e está sendo '
            "ignorada. O criador de bancos perdeu a capacidade de derrubar "
            "banco: banco que já existe é ignorado, e recriar virou ato manual "
            "(dropdb ou DROP DATABASE), fora desta ferramenta."
        )
    else:
        avisos.append(
            'AVISO: a chave "options" não existe mais e está sendo ignorada.'
        )
    return avisos


def load_config(config_path: str) -> dict:
    config_path = os.path.abspath(config_path)
    if not os.path.isfile(config_path):
        raise FileNotFoundError(f"Arquivo de configuração não encontrado: {config_path}")

    with open(config_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    for aviso in remover_chaves_obsoletas(config):
        print(aviso, file=sys.stderr)

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


# --- Execução ----------------------------------------------------------------

def _quote_arg(value: str) -> str:
    """Cita o argumento só quando precisa, para o comando sugerido poder ser
    copiado e colado direto no terminal."""
    return value if re.fullmatch(r"[A-Za-z0-9_.:/\\-]+", value) else f'"{value}"'


def mensagem_banco_existente(dbname: str) -> str:
    """A mensagem do `ignorado`. Como a ferramenta não recria mais banco, ela
    tem que ENSINAR o caminho manual, senão vira só uma recusa sem saída."""
    return (
        "Banco já existe e não foi tocado. Esta ferramenta não derruba banco: "
        "para recriá-lo, confirme antes que ninguém depende dele (produção, "
        "edição em curso, backup feito) e derrube você mesmo, com "
        f"dropdb {_quote_arg(dbname)} ou DROP DATABASE \"{dbname}\"; "
        "depois rode este comando outra vez."
    )


def create_database(connection: dict, db_config: dict) -> dict:
    """Cria um banco de dados e executa o SQL do modelo.

    Banco que já existe é ignorado, nunca recriado. Retorna dict com status da
    operação.
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
            # Aqui existiam um pg_terminate_backend e um DROP DATABASE,
            # removidos de propósito em 2026-07-25. Não os reintroduza: os
            # configs versionados nomeiam bancos de produção com trabalho de
            # campo dentro, e nenhuma confirmação por flag impede que o config
            # errado seja rodado por engano. Destruir banco é ato humano, fora
            # desta ferramenta.
            result["status"] = "ignorado"
            result["message"] = mensagem_banco_existente(dbname)
            return result

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

def montar_plano(config: dict, config_arg: str) -> dict:
    """Monta o plano de execução sem tocar em nada: o que seria criado e o que
    já existe (e seria ignorado).

    Consulta o servidor só para saber quais bancos existem. Se não der para
    conectar, o plano sai mesmo assim, com a existência marcada como
    desconhecida, porque a metade offline da checagem (modelo, SRID, SQL do
    modelo) ainda vale.
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
        "indeterminado": acoes.count("indeterminado"),
    }
    return plano


_ROTULO_ACAO = {
    "criar": "criar    ",
    "ignorar": "ignorar  ",
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
        if d["acao"] == "ignorar":
            print("      já existe, não será tocado (esta ferramenta não derruba banco)")

    r = plano["resumo"]
    resumo = f"Resumo: {r['criar']} a criar, {r['ignorar']} a ignorar"
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
            "Esta ferramenta só cria banco. Banco que já existe é ignorado e "
            "segue intacto: não há como derrubá-lo daqui, nem por flag nem por "
            "config. Para recriar um banco, derrube-o à mão (dropdb ou DROP "
            "DATABASE) depois de conferir quem depende dele, e rode de novo."
        ),
    )
    parser.add_argument(
        "config", nargs="?", help="Caminho para o arquivo de configuração JSON",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Valida o config e mostra o que SERIA feito, sem criar nada",
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

    if args.dry_run:
        plano = montar_plano(config, args.config)
        if args.json_out:
            print(json.dumps(plano, ensure_ascii=False, indent=2))
        else:
            imprimir_plano(plano)
        sys.exit(EXIT_OK)

    connection = config["connection"]

    print(f"Criando {len(config['databases'])} banco(s)...\n")

    results = []
    for db_config in config["databases"]:
        print(f"  [{db_config['name']}] modelo={db_config['model']}, srid={db_config.get('srid', MODELS[db_config['model']]['default_srid'])}...")
        result = create_database(connection, db_config)
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
