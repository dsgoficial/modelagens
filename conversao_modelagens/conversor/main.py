"""
Orquestrador principal do conversor de modelagens EDGV.

Uso:
    python -m conversor.main config.json
"""
import argparse
import json
import logging
import os
import sys

import geopandas as gpd
import pandas as pd
from shapely import wkt

from .config import load_config, load_mapping
from .converter import FeatureConverter
from .errors import ConversionError, ConversionReport
from .geometry import aggregate, clip, detect_geom_type, ensure_crs, reproject, split_multi
from .readers.postgis import read_postgis, _build_postgis_url
from .readers.shapefile import read_shapefiles
from .writers.postgis import write_postgis
from .writers.shapefile import write_shapefiles

logger = logging.getLogger("conversor")

_INTERNAL_KEYS = frozenset({
    "$GEOM_TYPE", "INVALID_GEOM", "CLASS_NOT_FOUND",
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


def _write_destination(data: dict[str, gpd.GeoDataFrame], dest_config: dict):
    if dest_config["type"] == "postgis":
        write_postgis(data, dest_config)
    elif dest_config["type"] == "shapefile":
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
            rows = [
                {**f["attrs"], "geometry": f["geometry"]}
                for f in features
            ]

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
    for _, row in gdf.iterrows():
        folder_name = str(row[folder_attr]).strip()
        if not folder_name:
            logger.warning("Moldura com '%s' vazio, ignorando", folder_attr)
            continue
        clips.append({
            "geometry": row.geometry,
            "folder_name": folder_name,
        })

    logger.info("Carregadas %d molduras para recorte em lote", len(clips))
    return clips


def _load_segment_clips(config: dict) -> list:
    """Carrega molduras para segmentação. Retorna lista de geometrias."""
    gdf = _load_clip_source(config["segment_clip"])
    geometries = [row.geometry for _, row in gdf.iterrows() if row.geometry and not row.geometry.is_empty]
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


def run(config_path: str):
    config = load_config(config_path)
    _setup_logging(config)

    logger.info("Carregando configuração de: %s", config_path)
    logger.info("Direção: %s", config["direction"])

    is_passthrough = not config.get("mapping_file")
    error_action = config["options"].get("error_action", "skip")
    target_srid = config["options"].get("reproject_to")
    source_srid = config["source"].get("srid", 4326)

    # Read source data (uma única vez)
    logger.info("Lendo dados de origem...")
    source_data = _read_source(config)
    logger.info("Lidas %d tabelas/layers", len(source_data))

    # Convert or passthrough
    report = ConversionReport()

    if is_passthrough:
        logger.info("Modo passthrough (sem mapeamento de classes/atributos)")
        converted = _passthrough_source_data(source_data, report)
    else:
        mapping_dict = load_mapping(config["mapping_file"])
        logger.info("Mapeamento carregado: %s", config["mapping_file"])
        converter = FeatureConverter(mapping_dict, config["direction"])

        # Build quality metadata from config (if present)
        qm_config = config.get("quality_metadata")
        quality_meta = None
        if qm_config:
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
            quality_meta = {
                "fontes": json.dumps([fonte_entry], ensure_ascii=False),
                "status_ciclo_vida": qm_config.get("status_ciclo_vida", 1),
                "validacao": qm_config.get("validacao", 1),
                "confirmacao_geometria": qm_config.get("confirmacao_geometria", 1),
                "confirmacao_atributos": qm_config.get("confirmacao_atributos", 1),
                "acuracia_planimetrica": qm_config.get("acuracia_planimetrica"),
            }

        converted = _convert_source_data(source_data, converter, report, error_action, quality_meta)

    logger.info("Processadas %d feições", len(converted))

    if "segment_clip" in config:
        _run_segment(config, converted, source_srid, target_srid, report)
    elif "batch_clip" in config:
        _run_batch(config, converted, source_srid, target_srid, report)
    else:
        _run_single(config, converted, source_srid, target_srid, report)


def _run_single(config, converted, source_srid, target_srid, report):
    """Modo normal: clip único opcional + escrita em um destino."""
    clip_geom = _load_clip_geometry(config)

    output_gdfs = _clip_and_build_gdfs(converted, clip_geom, source_srid, target_srid)

    logger.info("Escrevendo %d classes destino...", len(output_gdfs))
    _write_destination(output_gdfs, config["destination"])

    _export_report(report, config)


def _run_batch(config, converted, source_srid, target_srid, report):
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
        _write_destination(output_gdfs, clip_dest)
        total_written += feat_count

    logger.info(
        "Batch concluído: %d molduras processadas, %d feições escritas no total",
        len(clips), total_written,
    )
    _export_report(report, config)


def _run_segment(config, converted, source_srid, target_srid, report):
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

    _write_destination(output_gdfs, config["destination"])
    _export_report(report, config)


def main():
    parser = argparse.ArgumentParser(
        description="Conversor de modelagens EDGV — Python puro",
    )
    parser.add_argument(
        "config", help="Caminho para o arquivo de configuração JSON",
    )
    args = parser.parse_args()
    run(args.config)


if __name__ == "__main__":
    main()
