"""
Leitor Shapefile — lê arquivos .shp de um diretório via geopandas.
"""
import logging
import os

import geopandas as gpd

from ..geometry import ensure_crs

logger = logging.getLogger(__name__)


def read_shapefiles(source_config: dict) -> dict[str, gpd.GeoDataFrame]:
    path = source_config["path"]
    srid = source_config.get("srid", 4326)
    encoding = source_config.get("encoding", "UTF-8")
    tables = source_config.get("tables", [])

    if not os.path.isdir(path):
        raise FileNotFoundError(f"Diretório de shapefiles não encontrado: {path}")

    if tables:
        shp_files = []
        for t in tables:
            fname = t if t.endswith(".shp") else t + ".shp"
            full_path = os.path.join(path, fname)
            if os.path.isfile(full_path):
                shp_files.append(full_path)
            else:
                logger.warning("Shapefile não encontrado: %s", full_path)
    else:
        shp_files = [
            os.path.join(path, f)
            for f in os.listdir(path)
            if f.lower().endswith(".shp")
        ]

    result = {}
    for shp_path in sorted(shp_files):
        feature_type = os.path.splitext(os.path.basename(shp_path))[0]
        try:
            gdf = gpd.read_file(shp_path, encoding=encoding)
            gdf = ensure_crs(gdf, srid)
            result[feature_type] = gdf
            logger.info("Lido shapefile %s: %d feições", feature_type, len(gdf))
        except Exception as e:
            logger.error("Erro ao ler shapefile %s: %s", shp_path, e)
            raise

    return result
