"""
Escritor PostGIS — escreve GeoDataFrames em tabelas PostGIS.
"""
import logging

import geopandas as gpd
from sqlalchemy import create_engine

from ..geometry import ensure_crs
from ..readers.postgis import _build_postgis_url

logger = logging.getLogger(__name__)


def _strip_schema(name: str) -> str:
    return name.split(".", 1)[1] if "." in name else name


def write_postgis(data: dict[str, gpd.GeoDataFrame], dest_config: dict):
    schema = dest_config.get("schema", "public")
    srid = dest_config.get("srid", 4326)

    engine = create_engine(_build_postgis_url(dest_config))

    for feature_type, gdf in data.items():
        if gdf.empty:
            logger.info("Pulando %s (vazio)", feature_type)
            continue

        table_name = _strip_schema(feature_type)
        gdf = ensure_crs(gdf, srid)

        try:
            gdf.to_postgis(
                name=table_name,
                con=engine,
                schema=schema,
                if_exists="append",
                index=False,
            )
            logger.info("Escrita tabela %s.%s: %d feições", schema, table_name, len(gdf))
        except Exception as e:
            logger.error("Erro ao escrever tabela %s.%s: %s", schema, table_name, e)
            raise

    engine.dispose()
