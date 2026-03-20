"""
Criador de bancos EDGV em PostgreSQL/PostGIS.

Uso:
    python -m criador_bancos.main config.json
"""
import argparse
import json
import os
import re
import sys

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

from .models import MODELS


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

    return config


def _connect_admin(connection: dict):
    """Conecta no PostgreSQL sem especificar banco (usa 'postgres')."""
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


def create_database(connection: dict, db_config: dict, options: dict) -> dict:
    """Cria um banco de dados e executa o SQL do modelo.

    Retorna dict com status da operação.
    """
    dbname = db_config["name"]
    model_key = db_config["model"]
    model = MODELS[model_key]
    srid = db_config.get("srid", model["default_srid"])
    overwrite = options.get("overwrite", False)

    result = {"database": dbname, "model": model_key, "srid": srid}

    # Criar o banco
    admin_conn = _connect_admin(connection)
    try:
        if _database_exists(admin_conn, dbname):
            if not overwrite:
                result["status"] = "ignorado"
                result["message"] = "Banco já existe (use overwrite: true para recriar)"
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


def main():
    parser = argparse.ArgumentParser(description="Criador de bancos EDGV")
    parser.add_argument("config", help="Caminho para o arquivo de configuração JSON")
    args = parser.parse_args()

    config = load_config(args.config)
    connection = config["connection"]
    options = config.get("options", {})

    print(f"Criando {len(config['databases'])} banco(s)...\n")

    results = []
    for db_config in config["databases"]:
        print(f"  [{db_config['name']}] modelo={db_config['model']}, srid={db_config.get('srid', MODELS[db_config['model']]['default_srid'])}...")
        result = create_database(connection, db_config, options)
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

    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
