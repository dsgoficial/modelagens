# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Repository for EDGV (Especificação Técnica para Estruturação de Dados Geoespaciais) database specifications and conversion tools, maintained by DSG (Diretoria de Serviço Geográfico). Manages SQL schemas, master specification files, and data conversion between EDGV model variants (3.0, Topo 1.4, Orto 2.5, Topo Multiescala 1.4) and formats (PostGIS, Shapefile, GeoPackage).

## Key Commands

### Python Converter (run from `conversao_modelagens/`)
```bash
pip install -r conversor/requirements.txt
python -m conversor.main <config.json>
```
Config examples are in `conversao_modelagens/conversor/config_examples/`.

### Utility Scripts (run from `rotinas/`)
```bash
python mastergen.py          # Generate master files from database
python generate_gpkg.py      # Generate GeoPackage from specification
```

## Architecture

### EDGV Model Definitions (`edgv_300*/ directories`)
Each variant has:
- `*.sql` — PostgreSQL schema creation scripts
- `*_extension.sql` — PostGIS extension setup
- `master_file_*.json` — Machine-readable specification (tables, columns, domains, constraints)

Master files follow the schema in `masterfile_schema.json`.

### Conversion System (`conversao_modelagens/`)
Two approaches exist — FME workspaces (legacy, in `fme/`) and a pure Python converter (active, in `conversor/`).

**Python converter modules** (`conversor/`):
- `main.py` — Orchestrator: loads config, reads source, runs conversion pipeline (mapping → geometry ops → write)
- `config.py` — Config loader with validation
- `converter.py` — Feature-level conversion logic using mapping files
- `geometry.py` — Geometry operations: clip, reproject, aggregate, split multi-geometries
- `readers/` — PostGIS and Shapefile readers (return GeoDataFrames)
- `writers/` — PostGIS and Shapefile writers (consume GeoDataFrames)
- `errors.py` — Error handling and conversion report generation

**Mapping files** (`arquivos_mapeamento/`):
JSON files defining attribute-level mappings between model variants. Schema: `arquivo_mapeamento_schema.json`. The `direction` field (`A=>B` or `B=>A`) controls which way the mapping applies.

**Conversion pipeline flow**: config → reader → FeatureConverter (attribute mapping) → geometry ops (clip/reproject/split) → writer → report

### Batch and Segmentation Modes
- `batch_clip`: Clips output by map frames (`aux_moldura_a`) and optionally zips each into separate folders (for BDGEx upload)
- `segment_clip`: Segments features by map frame boundaries and reprojects to UTM (creates editing databases)

## CI

GitHub Actions (`main.yml`) validates JSON mapping files on push via `jq`.

## Language Notes

- Primary language in code, comments, and docs is **Brazilian Portuguese**
- Python 3.10+ required for the converter
- Key Python dependencies: geopandas, shapely, sqlalchemy, psycopg2, fiona, pyproj
- SRID 4674 (SIRGAS 2000) is the standard CRS; UTM projections (e.g., 31982) used for editing databases
