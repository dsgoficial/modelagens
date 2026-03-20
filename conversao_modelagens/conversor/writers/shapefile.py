"""
Escritor Shapefile — escreve GeoDataFrames como arquivos .shp, com opção de zipar.
"""
import logging
import os
import shutil
import zipfile

import geopandas as gpd

from ..geometry import ensure_crs

logger = logging.getLogger(__name__)

DBF_FIELD_NAME_LIMIT = 10

# Extensões que compõem um shapefile completo
_SHP_EXTENSIONS = (".shp", ".shx", ".dbf", ".prj", ".cpg")


def _strip_schema(name: str) -> str:
    return name.split(".", 1)[1] if "." in name else name


def write_shapefiles(data: dict[str, gpd.GeoDataFrame], dest_config: dict):
    path = dest_config["path"]
    encoding = dest_config.get("encoding", "UTF-8")
    srid = dest_config.get("srid", 4326)
    zip_output = dest_config.get("zip", False)

    os.makedirs(path, exist_ok=True)

    for feature_type, gdf in data.items():
        if gdf.empty:
            logger.info("Pulando %s (vazio)", feature_type)
            continue

        name = _strip_schema(feature_type)

        for col in gdf.columns:
            if col != "geometry" and len(col) > DBF_FIELD_NAME_LIMIT:
                logger.warning(
                    "Atributo '%s' na classe '%s' será truncado para %d caracteres no DBF",
                    col, name, DBF_FIELD_NAME_LIMIT,
                )

        gdf = ensure_crs(gdf, srid)

        output_path = os.path.join(path, f"{name}.shp")
        try:
            gdf.to_file(output_path, driver="ESRI Shapefile", encoding=encoding)
            logger.info("Escrito shapefile %s: %d feições", output_path, len(gdf))
        except Exception as e:
            logger.error("Erro ao escrever shapefile %s: %s", output_path, e)
            raise

    if zip_output:
        zip_shapefiles(path)


def zip_shapefiles(directory: str):
    """Cria um .zip com todos os arquivos shapefile do diretório e remove os originais."""
    zip_path = directory.rstrip("/\\") + ".zip"
    file_count = 0

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for fname in sorted(os.listdir(directory)):
            if os.path.splitext(fname)[1].lower() in _SHP_EXTENSIONS:
                full_path = os.path.join(directory, fname)
                zf.write(full_path, arcname=fname)
                file_count += 1

    if file_count > 0:
        shutil.rmtree(directory)
        logger.info("Zipado %s (%d arquivos)", zip_path, file_count)
    else:
        os.remove(zip_path)
        logger.warning("Nenhum arquivo shapefile encontrado em %s para zipar", directory)
