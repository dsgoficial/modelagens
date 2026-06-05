"""
Teste de fumaça do pipeline encadeado (stages) do conversor.

Não depende de PostGIS: usa shapefile -> shapefile com dois mapeamentos
sintéticos minimos (casa -> predio -> building). Valida que:

1. Rodar o pipeline encadeado (2 estagios num unico config) produz exatamente
   a mesma saida que rodar os dois estagios manualmente, um de cada vez.
2. O formato legado (mapping_file + direction no topo, sem 'stages') continua
   funcionando e equivale a um pipeline de um estagio.

Rodar:
    cd conversao_modelagens
    python -m conversor.tests.test_chained
ou, com pytest:
    pytest conversor/tests/test_chained.py
"""
import json
import logging
import math
import os
import tempfile

import geopandas as gpd
from shapely.geometry import Point

from conversor.config import load_config
from conversor.main import run

# Silencia o INFO verboso do conversor durante o teste.
logging.getLogger("conversor").setLevel(logging.WARNING)


# --- Mapeamentos sinteticos minimos -----------------------------------------

MAPPING_CASA_PREDIO = {
    "metadados": {"modelo_A": "casa", "modelo_B": "predio"},
    "schema_A": "",
    "schema_B": "",
    "mapeamento_classes": [
        {
            "classe_A": "casa",
            "classe_B": "predio",
            "mapeamento_atributos": [
                {
                    "attr_A": "tipo",
                    "attr_B": "categoria",
                    "traducao": [{"valor_A": "1", "valor_B": "residencial"}],
                }
            ],
        }
    ],
}

MAPPING_PREDIO_BUILDING = {
    "metadados": {"modelo_A": "predio", "modelo_B": "building"},
    "schema_A": "",
    "schema_B": "",
    "mapeamento_classes": [
        {
            "classe_A": "predio",
            "classe_B": "building",
            "mapeamento_atributos": [
                {
                    "attr_A": "categoria",
                    "attr_B": "uso",
                    "traducao": [{"valor_A": "residencial", "valor_B": "R"}],
                }
            ],
        }
    ],
}


# --- Helpers ----------------------------------------------------------------

def _write_json(path, obj):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)


def _make_input_shapefile(folder):
    """Cria casa.shp com 3 feicoes de ponto e atributo 'tipo'."""
    os.makedirs(folder, exist_ok=True)
    gdf = gpd.GeoDataFrame(
        {"tipo": [1, 1, 2]},
        geometry=[Point(0, 0), Point(1, 1), Point(2, 2)],
        crs="EPSG:4674",
    )
    gdf.to_file(os.path.join(folder, "casa.shp"), driver="ESRI Shapefile", encoding="UTF-8")


def _shp_source(path):
    return {"type": "shapefile", "path": path, "srid": 4674, "encoding": "UTF-8"}


def _shp_dest(path):
    return {"type": "shapefile", "path": path, "srid": 4674, "encoding": "UTF-8", "zip": False}


def _layer_records(folder, name):
    """Le uma camada e devolve uma representacao normalizada, ordenada e
    comparavel (atributos + WKT da geometria), ignorando colunas all-null."""
    gdf = gpd.read_file(os.path.join(folder, name + ".shp"))
    geom_col = gdf.geometry.name
    recs = []
    for _, row in gdf.iterrows():
        attrs = {}
        for col in gdf.columns:
            if col == geom_col:
                continue
            val = row[col]
            if isinstance(val, float) and math.isnan(val):
                val = None
            attrs[col] = val
        key = tuple(sorted((k, str(v)) for k, v in attrs.items()))
        recs.append((key, row.geometry.wkt))
    return sorted(recs)


# --- Testes -----------------------------------------------------------------

def test_chained_equals_two_step():
    with tempfile.TemporaryDirectory() as tmp:
        in_dir = os.path.join(tmp, "in")
        map1 = os.path.join(tmp, "map_casa_predio.json")
        map2 = os.path.join(tmp, "map_predio_building.json")
        _make_input_shapefile(in_dir)
        _write_json(map1, MAPPING_CASA_PREDIO)
        _write_json(map2, MAPPING_PREDIO_BUILDING)

        # (A) Pipeline encadeado: casa -> predio -> building, num unico config.
        chained_out = os.path.join(tmp, "out_chained")
        chained_cfg = os.path.join(tmp, "chained.json")
        _write_json(chained_cfg, {
            "source": _shp_source(in_dir),
            "stages": [
                {"mapping_file": map1, "direction": "A=>B"},
                {"mapping_file": map2, "direction": "A=>B"},
            ],
            "destination": _shp_dest(chained_out),
            "options": {},
        })
        run(chained_cfg)

        # (B) Dois passos manuais: casa -> predio, depois predio -> building.
        step1_out = os.path.join(tmp, "out_step1")
        step1_cfg = os.path.join(tmp, "step1.json")
        _write_json(step1_cfg, {
            "source": _shp_source(in_dir),
            "mapping_file": map1,
            "direction": "A=>B",
            "destination": _shp_dest(step1_out),
            "options": {},
        })
        run(step1_cfg)

        step2_out = os.path.join(tmp, "out_step2")
        step2_cfg = os.path.join(tmp, "step2.json")
        _write_json(step2_cfg, {
            "source": _shp_source(step1_out),
            "mapping_file": map2,
            "direction": "A=>B",
            "destination": _shp_dest(step2_out),
            "options": {},
        })
        run(step2_cfg)

        # A saida da classe final deve existir e ser identica nos dois caminhos.
        assert os.path.isfile(os.path.join(chained_out, "building.shp")), \
            "pipeline encadeado nao gerou building.shp"
        assert os.path.isfile(os.path.join(step2_out, "building.shp")), \
            "dois-passos manual nao gerou building.shp"

        chained_recs = _layer_records(chained_out, "building")
        twostep_recs = _layer_records(step2_out, "building")

        assert len(chained_recs) == 3, f"esperava 3 feicoes, veio {len(chained_recs)}"
        assert chained_recs == twostep_recs, (
            "encadeado != dois-passos\n"
            f"  encadeado: {chained_recs}\n"
            f"  dois-passos: {twostep_recs}"
        )

        # Verifica a traducao encadeada: tipo=1 -> categoria=residencial -> uso=R.
        gdf = gpd.read_file(os.path.join(chained_out, "building.shp"))
        usos = sorted(str(v) for v in gdf["uso"].tolist())
        assert usos == ["2", "R", "R"], f"traducao encadeada errada: {usos}"

        # O pipeline encadeado nao deve deixar a classe intermediaria na saida.
        assert not os.path.isfile(os.path.join(chained_out, "predio.shp")), \
            "classe intermediaria 'predio' vazou para a saida final"


def test_legacy_single_stage_still_works():
    """O formato legado (sem 'stages') equivale a um pipeline de um estagio."""
    with tempfile.TemporaryDirectory() as tmp:
        in_dir = os.path.join(tmp, "in")
        map1 = os.path.join(tmp, "map_casa_predio.json")
        _make_input_shapefile(in_dir)
        _write_json(map1, MAPPING_CASA_PREDIO)

        legacy_out = os.path.join(tmp, "out_legacy")
        legacy_cfg = os.path.join(tmp, "legacy.json")
        _write_json(legacy_cfg, {
            "source": _shp_source(in_dir),
            "mapping_file": map1,
            "direction": "A=>B",
            "destination": _shp_dest(legacy_out),
            "options": {},
        })
        run(legacy_cfg)

        stages_out = os.path.join(tmp, "out_stages")
        stages_cfg = os.path.join(tmp, "stages.json")
        _write_json(stages_cfg, {
            "source": _shp_source(in_dir),
            "stages": [{"mapping_file": map1, "direction": "A=>B"}],
            "destination": _shp_dest(stages_out),
            "options": {},
        })
        run(stages_cfg)

        assert os.path.isfile(os.path.join(legacy_out, "predio.shp")), \
            "config legado nao gerou predio.shp"
        assert _layer_records(legacy_out, "predio") == _layer_records(stages_out, "predio"), \
            "config legado != pipeline de um estagio"


def _expect_value_error(cfg, msg):
    with tempfile.TemporaryDirectory() as tmp:
        in_dir = os.path.join(tmp, "in")
        map1 = os.path.join(tmp, "map.json")
        _make_input_shapefile(in_dir)
        _write_json(map1, MAPPING_CASA_PREDIO)
        # injeta paths reais para o que precisar existir
        cfg = json.loads(json.dumps(cfg).replace("__IN__", in_dir.replace("\\", "/"))
                         .replace("__MAP__", map1.replace("\\", "/")))
        cfg_path = os.path.join(tmp, "bad.json")
        _write_json(cfg_path, cfg)
        try:
            load_config(cfg_path)
        except ValueError:
            return
        except Exception as e:
            raise AssertionError(f"{msg}: esperava ValueError, veio {type(e).__name__}: {e}")
        raise AssertionError(f"{msg}: nenhuma excecao levantada")


def test_config_validation_rejects_bad_chains():
    # 'stages' e 'mapping_file' ao mesmo tempo
    _expect_value_error({
        "source": {"type": "shapefile", "path": "__IN__"},
        "mapping_file": "__MAP__", "direction": "A=>B",
        "stages": [{"mapping_file": "__MAP__", "direction": "A=>B"}],
        "destination": {"type": "shapefile", "path": "__IN__"},
    }, "stages + mapping_file")

    # lista 'stages' vazia
    _expect_value_error({
        "source": {"type": "shapefile", "path": "__IN__"},
        "stages": [],
        "destination": {"type": "shapefile", "path": "__IN__"},
    }, "stages vazio")

    # estagio com mapeamento mas sem direction
    _expect_value_error({
        "source": {"type": "shapefile", "path": "__IN__"},
        "stages": [{"mapping_file": "__MAP__"}],
        "destination": {"type": "shapefile", "path": "__IN__"},
    }, "estagio sem direction")

    # passthrough no meio de uma cadeia (sem segment_clip)
    _expect_value_error({
        "source": {"type": "shapefile", "path": "__IN__"},
        "stages": [
            {"mapping_file": "__MAP__", "direction": "A=>B"},
            {"direction": "A=>B"},
        ],
        "destination": {"type": "shapefile", "path": "__IN__"},
    }, "passthrough encadeado")


def test_legacy_config_normalizes_to_stages():
    """load_config converte o formato legado em 'stages' e resolve os paths."""
    with tempfile.TemporaryDirectory() as tmp:
        in_dir = os.path.join(tmp, "in")
        map1 = os.path.join(tmp, "map.json")
        _make_input_shapefile(in_dir)
        _write_json(map1, MAPPING_CASA_PREDIO)

        legacy_path = os.path.join(tmp, "legacy.json")
        _write_json(legacy_path, {
            "source": _shp_source(in_dir),
            "mapping_file": map1, "direction": "A=>B",
            "destination": _shp_dest(os.path.join(tmp, "out")),
        })
        cfg = load_config(legacy_path)
        assert isinstance(cfg.get("stages"), list) and len(cfg["stages"]) == 1
        assert cfg["stages"][0]["direction"] == "A=>B"
        assert os.path.isabs(cfg["stages"][0]["mapping_file"])


def test_chained_example_config_loads():
    """O exemplo encadeado versionado carrega e resolve os dois mapeamentos
    reais do repo (guarda contra path relativo errado no exemplo)."""
    example = os.path.normpath(os.path.join(
        os.path.dirname(__file__), "..", "config_examples",
        "postgis300topo14_shp300_batch_chained.json",
    ))
    cfg = load_config(example)
    assert len(cfg["stages"]) == 2, "exemplo encadeado deveria ter 2 estagios"
    assert all(os.path.isfile(s["mapping_file"]) for s in cfg["stages"]), \
        "mapeamentos do exemplo encadeado nao foram encontrados no repo"
    assert cfg["stages"][0]["direction"] == "B=>A"
    assert cfg["stages"][1]["direction"] == "A=>B"


def _main():
    tests = [
        test_chained_equals_two_step,
        test_legacy_single_stage_still_works,
        test_config_validation_rejects_bad_chains,
        test_legacy_config_normalizes_to_stages,
        test_chained_example_config_loads,
    ]
    failures = 0
    for t in tests:
        try:
            t()
            print(f"PASS  {t.__name__}")
        except AssertionError as e:
            failures += 1
            print(f"FAIL  {t.__name__}: {e}")
        except Exception as e:
            failures += 1
            print(f"ERROR {t.__name__}: {type(e).__name__}: {e}")
    print()
    print(f"{len(tests) - failures}/{len(tests)} testes passaram")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(_main())
