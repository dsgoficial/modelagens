"""
Leitor PostGIS — lê tabelas de um banco PostgreSQL/PostGIS via geopandas.
"""
import logging
from urllib.parse import quote_plus

import geopandas as gpd
from sqlalchemy import create_engine, text

from ..geometry import ensure_crs

logger = logging.getLogger(__name__)


def _build_postgis_url(config: dict) -> str:
    user = quote_plus(config["user"])
    password = quote_plus(config["password"])
    return (
        f"postgresql://{user}:{password}"
        f"@{config['host']}:{config.get('port', 5432)}/{config['database']}"
    )


def read_postgis(source_config: dict) -> dict[str, gpd.GeoDataFrame]:
    schema = source_config.get("schema", "public")
    srid = source_config.get("srid", 4326)
    tables = source_config.get("tables", [])

    engine = create_engine(_build_postgis_url(source_config))

    # Discover tables + geometry columns in a single query
    table_geom_map = _discover_tables_with_geom(engine, schema)

    if tables:
        # Filter to requested tables only
        table_geom_map = {t: g for t, g in table_geom_map.items() if t in tables}
    else:
        logger.info("Descobertas %d tabelas no schema '%s'", len(table_geom_map), schema)

    result = {}
    for table, geom_col in table_geom_map.items():
        qualified = f"{schema}.{table}" if schema else table
        try:
            gdf = gpd.read_postgis(
                f'SELECT * FROM "{schema}"."{table}"',
                engine,
                geom_col=geom_col,
            )
            gdf = ensure_crs(gdf, srid)

            feature_type = f"{schema}.{table}" if schema else table
            result[feature_type] = gdf
            logger.info("Lida tabela %s: %d feições", qualified, len(gdf))
        except Exception as e:
            logger.error("Erro ao ler tabela %s: %s", qualified, e)
            raise

    engine.dispose()
    return result


def _discover_tables_with_geom(engine, schema: str) -> dict[str, str]:
    query = text(
        "SELECT f_table_name, f_geometry_column FROM geometry_columns "
        "WHERE f_table_schema = :schema"
    )
    with engine.connect() as conn:
        rows = conn.execute(query, {"schema": schema}).fetchall()
    # First geometry column per table wins
    result = {}
    for table_name, geom_col in rows:
        if table_name not in result:
            result[table_name] = geom_col
    return result
