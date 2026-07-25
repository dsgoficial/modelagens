"""
Testes dos guardrails do conversor: contrato perguntável (config_schema.json),
dry-run e guarda de reexecução do destino PostGIS.

Nenhum teste aqui toca banco: as funções que falariam com o PostGIS são
substituídas por dublês que registram o que SERIA executado. É de propósito,
porque o que se está testando é a DECISÃO (abortar, esvaziar, acrescentar), não
o driver.

Rodar:
    cd conversao_modelagens
    pytest conversor/tests/test_guardrails.py
"""
import glob
import json
import os
import tempfile

import geopandas as gpd
import pytest
from shapely.geometry import Point

from conversor.config import VALID_DIRECTIONS, VALID_SE_EXISTIR, VALID_SOURCE_TYPES, load_config
from conversor.dryrun import montar_plano
from conversor.errors import DestinoNaoVazioError
from conversor.main import build_parser
from conversor.schema import load_schema, validate_against_schema
from conversor.writers import postgis as w

EXAMPLES_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "config_examples")
)


# --- Contrato perguntável ----------------------------------------------------

def test_todos_os_exemplos_validam_contra_o_schema():
    """O schema tem que descrever o que o repo de fato usa. Se um exemplo
    versionado não valida, o errado é o schema, não o exemplo."""
    exemplos = sorted(glob.glob(os.path.join(EXAMPLES_DIR, "*.json")))
    assert exemplos, "nenhum config de exemplo encontrado"
    for path in exemplos:
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)
        erros = validate_against_schema(raw)
        assert not erros, f"{os.path.basename(path)}: {erros}"


def test_schema_nao_diverge_das_constantes_do_codigo():
    """O schema é uma segunda descrição da mesma coisa, então precisa de uma
    amarra: enum que sair do lugar em config.py quebra aqui."""
    schema = load_schema()
    fonte = schema["definitions"]["fonte_dados"]["properties"]
    assert set(fonte["type"]["enum"]) == VALID_SOURCE_TYPES

    estagio = schema["definitions"]["estagio"]["properties"]
    assert set(estagio["direction"]["enum"]) == VALID_DIRECTIONS | {None}

    opcoes = schema["definitions"]["opcoes"]["properties"]
    assert set(opcoes["error_action"]["enum"]) == {"skip", "fail"}


def test_schema_pega_campo_desconhecido_que_o_imperativo_deixaria_passar(tmp_path):
    """'sorce' seria simplesmente ignorado na execução; o schema recusa."""
    cfg = tmp_path / "typo.json"
    cfg.write_text(json.dumps({
        "source": {"type": "shapefile", "path": str(tmp_path)},
        "destination": {"type": "shapefile", "path": str(tmp_path)},
        "sorce": {"type": "shapefile", "path": str(tmp_path)},
        "segment_clip": {"type": "shapefile", "path": str(tmp_path)},
    }), encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        load_config(str(cfg))
    assert "config_schema.json" in str(exc.value)
    assert "sorce" in str(exc.value)


def test_schema_pega_valor_fora_do_enum(tmp_path):
    cfg = tmp_path / "enum.json"
    cfg.write_text(json.dumps({
        "source": {"type": "shapefile", "path": str(tmp_path)},
        "destination": {"type": "shapefile", "path": str(tmp_path)},
        "segment_clip": {"type": "shapefile", "path": str(tmp_path)},
        "options": {"error_action": "explodir"},
    }), encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        load_config(str(cfg))
    assert "error_action" in str(exc.value)


def test_validacao_imperativa_continua_dando_a_mensagem_boa(tmp_path):
    """O schema entrou como camada ADICIONAL: as mensagens que já existiam
    continuam sendo as primeiras a aparecer."""
    cfg = tmp_path / "sem_source.json"
    cfg.write_text(json.dumps({"destination": {"type": "shapefile", "path": "x"}}), encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        load_config(str(cfg))
    assert "Campo obrigatório ausente no config: 'source'" in str(exc.value)


# --- Guarda de reexecução ----------------------------------------------------

def _dest_pg():
    return {
        "type": "postgis", "host": "h", "port": 5432, "database": "d",
        "user": "u", "password": "p", "schema": "edgv", "srid": 4674,
    }


def _gdf():
    return gpd.GeoDataFrame({"id": [1]}, geometry=[Point(0, 0)], crs="EPSG:4674")


@pytest.fixture
def pg_dublado(monkeypatch):
    """Substitui tudo que falaria com o PostGIS, registrando as chamadas."""
    registro = {"escritas": [], "esvaziadas": [], "contagens": {}}

    class _Engine:
        def dispose(self):
            pass

    monkeypatch.setattr(w, "create_engine", lambda url: _Engine())
    monkeypatch.setattr(w, "_get_dest_columns", lambda engine, schema, tabela: None)
    monkeypatch.setattr(
        w, "_contar_linhas_existentes",
        lambda engine, schema, tabelas: dict(registro["contagens"]),
    )
    monkeypatch.setattr(
        w, "_esvaziar_tabelas",
        lambda engine, schema, tabelas: registro["esvaziadas"].extend(tabelas),
    )
    monkeypatch.setattr(
        w, "_write_gdf",
        lambda gdf, tabela, engine, schema: registro["escritas"].append(tabela) or len(gdf),
    )
    return registro


def test_destino_vazio_grava_normalmente(pg_dublado):
    w.write_postgis({"edgv.casa": _gdf()}, _dest_pg())
    assert pg_dublado["escritas"] == ["casa"]


def test_destino_com_linhas_aborta_por_padrao(pg_dublado):
    """O modo de falha real: rodar a mesma conversão duas vezes duplicava as
    feições sem erro nenhum."""
    pg_dublado["contagens"] = {"casa": 42}

    with pytest.raises(DestinoNaoVazioError) as exc:
        w.write_postgis({"edgv.casa": _gdf()}, _dest_pg())

    assert pg_dublado["escritas"] == [], "abortou mas escreveu mesmo assim"
    assert pg_dublado["esvaziadas"] == []
    msg = str(exc.value)
    assert "casa" in msg and "42" in msg
    # A mensagem tem que ensinar a saída, não só barrar.
    for saida in ("--se-existir abortar", "--se-existir replace", "--se-existir append"):
        assert saida in msg


def test_append_explicito_acrescenta(pg_dublado):
    pg_dublado["contagens"] = {"casa": 42}
    w.write_postgis({"edgv.casa": _gdf()}, _dest_pg(), se_existir="append")
    assert pg_dublado["escritas"] == ["casa"]
    assert pg_dublado["esvaziadas"] == []


def test_replace_esvazia_antes_de_gravar(pg_dublado):
    pg_dublado["contagens"] = {"casa": 42}
    w.write_postgis({"edgv.casa": _gdf()}, _dest_pg(), se_existir="replace")
    assert pg_dublado["esvaziadas"] == ["casa"]
    assert pg_dublado["escritas"] == ["casa"]


def test_classe_vazia_nao_entra_na_checagem(pg_dublado):
    """GeoDataFrame vazio não é gravado, então não pode fazer a guarda disparar."""
    vazio = gpd.GeoDataFrame({"id": []}, geometry=[], crs="EPSG:4674")
    w.write_postgis({"edgv.casa": vazio}, _dest_pg())
    assert pg_dublado["escritas"] == []


# --- CLI ---------------------------------------------------------------------

def test_se_existir_tem_abortar_como_padrao():
    args = build_parser().parse_args(["config.json"])
    assert args.se_existir == "abortar"
    assert args.dry_run is False


def test_cli_aceita_as_tres_politicas():
    for politica in VALID_SE_EXISTIR:
        args = build_parser().parse_args(["config.json", "--se-existir", politica])
        assert args.se_existir == politica


def test_cli_recusa_politica_invalida():
    with pytest.raises(SystemExit):
        build_parser().parse_args(["config.json", "--se-existir", "sobrescrever"])


# --- Dry-run -----------------------------------------------------------------

def _shapefile_de_teste(pasta):
    os.makedirs(pasta, exist_ok=True)
    gpd.GeoDataFrame(
        {"tipo": [1, 1, 2]},
        geometry=[Point(0, 0), Point(1, 1), Point(2, 2)],
        crs="EPSG:4674",
    ).to_file(os.path.join(pasta, "casa.shp"), driver="ESRI Shapefile", encoding="UTF-8")


def test_dry_run_descreve_o_plano_e_nao_escreve_nada():
    with tempfile.TemporaryDirectory() as tmp:
        entrada = os.path.join(tmp, "in")
        saida = os.path.join(tmp, "out")
        _shapefile_de_teste(entrada)

        mapa = os.path.join(tmp, "map.json")
        with open(mapa, "w", encoding="utf-8") as f:
            json.dump({
                "schema_A": "", "schema_B": "",
                "mapeamento_classes": [{"classe_A": "casa", "classe_B": "predio"}],
            }, f)

        cfg_path = os.path.join(tmp, "cfg.json")
        with open(cfg_path, "w", encoding="utf-8") as f:
            json.dump({
                "source": {"type": "shapefile", "path": entrada, "srid": 4674},
                "destination": {"type": "shapefile", "path": saida, "srid": 4674},
                "mapping_file": mapa,
                "direction": "A=>B",
            }, f)

        plano = montar_plano(load_config(cfg_path), cfg_path, "abortar")

        assert plano["modo"] == "simples"
        assert plano["se_existir"] == "abortar"
        assert len(plano["estagios"]) == 1
        assert plano["estagios"][0]["direction"] == "A=>B"
        assert [t["nome"] for t in plano["origem"]["tabelas"]] == ["casa"]
        assert plano["origem"]["total_estimado"] == 3
        assert plano["classes_destino"]["exemplos"] == ["predio"]

        assert not os.path.exists(saida), "dry-run criou a pasta de destino"


def test_dry_run_nao_quebra_quando_o_banco_nao_responde():
    """A metade offline do plano (modo, estágios, mapeamento) vale mesmo sem
    servidor: recusar-se a planejar por falta de conexão seria pior."""
    exemplo = os.path.join(EXAMPLES_DIR, "postgis300_shp300_batch.json")
    plano = montar_plano(load_config(exemplo), exemplo, "abortar")

    assert plano["modo"] == "batch_clip"
    assert plano["estagios"][0]["direction"] == "A=>B"
    assert plano["classes_destino"]["total"] > 0
    # A origem aponta para um banco que não existe nesta máquina; o plano sai
    # mesmo assim, com a falha registrada em vez de propagada.
    assert "erro" in plano["origem"] or plano["origem"].get("tabelas") is not None


def test_dry_run_avisa_batch_clip_com_destino_postgis(tmp_path):
    """batch_clip só escreve shapefile. O config passa nas duas validações e só
    estoura no meio da execução, então o dry-run precisa antecipar."""
    mapa = tmp_path / "map.json"
    mapa.write_text(json.dumps({
        "schema_A": "", "schema_B": "",
        "mapeamento_classes": [{"classe_A": "casa", "classe_B": "predio"}],
    }), encoding="utf-8")

    cfg = tmp_path / "cfg.json"
    cfg.write_text(json.dumps({
        "source": {"type": "shapefile", "path": str(tmp_path), "srid": 4674},
        "destination": _dest_pg(),
        "mapping_file": str(mapa),
        "direction": "A=>B",
        "batch_clip": {"type": "shapefile", "path": str(tmp_path), "folder_attribute": "inom"},
    }), encoding="utf-8")

    plano = montar_plano(load_config(str(cfg)), str(cfg), "abortar")
    assert any("batch_clip" in a for a in plano["avisos"])


def test_dry_run_nao_vaza_senha():
    exemplo = os.path.join(EXAMPLES_DIR, "banco_edicao_topo14.json")
    plano = montar_plano(load_config(exemplo), exemplo, "abortar")
    serializado = json.dumps(plano, ensure_ascii=False)
    assert "password" not in serializado
    assert "postgres:postgres" not in serializado
