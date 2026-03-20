"""
Utilitários de geometria usando shapely.
"""
import logging

import geopandas as gpd
from shapely.geometry import (
    MultiLineString,
    MultiPoint,
    MultiPolygon,
)
from shapely.ops import unary_union

logger = logging.getLogger(__name__)

_GEOM_TYPE_MAP = {
    "Point": "POINT",
    "MultiPoint": "POINT",
    "LineString": "LINESTRING",
    "MultiLineString": "LINESTRING",
    "Polygon": "POLYGON",
    "MultiPolygon": "POLYGON",
}

_MULTI_TYPES = {
    "POINT": MultiPoint,
    "LINESTRING": MultiLineString,
    "POLYGON": MultiPolygon,
}


def detect_geom_type(geom) -> str | None:
    if geom is None or geom.is_empty:
        return None
    return _GEOM_TYPE_MAP.get(geom.geom_type)


def split_multi(geom) -> list:
    if geom is None or geom.is_empty:
        return []
    if hasattr(geom, "geoms"):
        return list(geom.geoms)
    return [geom]


def aggregate(geometries: list, geom_type: str = None):
    if not geometries:
        return None
    if len(geometries) == 1 and geom_type is None:
        return geometries[0]

    if geom_type is None:
        geom_type = detect_geom_type(geometries[0])

    multi_cls = _MULTI_TYPES.get(geom_type)
    if multi_cls is not None:
        return multi_cls(geometries)
    return unary_union(geometries)


def clip(geom, clip_geom):
    if geom is None or clip_geom is None:
        return geom
    result = geom.intersection(clip_geom)
    if result.is_empty:
        return None
    # Intersection pode gerar GeometryCollection com tipos mistos.
    # Filtra para manter apenas geometrias compatíveis com o tipo original.
    expected = detect_geom_type(geom)
    result_type = detect_geom_type(result)
    if result_type == expected:
        return result
    # Extrai partes compatíveis de GeometryCollection
    if hasattr(result, "geoms"):
        compatible = [g for g in result.geoms if detect_geom_type(g) == expected]
        if not compatible:
            return None
        if len(compatible) == 1:
            return compatible[0]
        multi_cls = _MULTI_TYPES.get(expected)
        if multi_cls is not None:
            return multi_cls(compatible)
        return unary_union(compatible)
    return None


def ensure_crs(gdf: gpd.GeoDataFrame, srid: int) -> gpd.GeoDataFrame:
    if gdf.crs is None and srid:
        return gdf.set_crs(f"EPSG:{srid}")
    return gdf


def reproject(gdf: gpd.GeoDataFrame, target_srid: int) -> gpd.GeoDataFrame:
    if gdf.crs is None:
        logger.warning("GeoDataFrame sem CRS definido, pulando reprojeção")
        return gdf
    target_crs = f"EPSG:{target_srid}"
    if gdf.crs.to_epsg() == target_srid:
        return gdf
    return gdf.to_crs(target_crs)
