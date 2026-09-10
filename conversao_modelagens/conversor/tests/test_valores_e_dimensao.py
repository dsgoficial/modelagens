"""
Testes de três consertos que vinham falhando em SILÊNCIO, cada um provado
contra o PIOR CASO que ele existe para pegar:

1. rótulo de domínio que difere só na CAIXA entre o modelo e o produto
   entregue (a tradução não casava e o valor cru atravessava a cadeia);
2. regra de classe SEM tradução, cujo atributo de destino tem o nome de uma
   coluna da origem (a regra virava no-op e o destino ficava com 9999);
3. geometria com Z indo para coluna 2D (o destino recusava a linha inteira).

Nenhum teste toca banco: o que se testa é a decisão, não o driver.

Rodar:
    cd conversao_modelagens
    pytest conversor/tests/test_valores_e_dimensao.py
"""
import geopandas as gpd
import pytest
from shapely.geometry import LineString, Point

from conversor.converter import FeatureConverter, mesmo_valor
from conversor.geometry import force_2d, tem_z
from conversor.writers import postgis as w


def _mapa(classes, globais=None, afixo_b_maiusculo=False):
    sufixo_b = (
        {"tipo": "sufixo", "POINT": "_P", "LINESTRING": "_L", "POLYGON": "_A"}
        if afixo_b_maiusculo
        else {"tipo": "sufixo", "POINT": "_p", "LINESTRING": "_l", "POLYGON": "_a"}
    )
    return {
        "schema_A": "cb",
        "schema_B": "edgv",
        "afixo_geom_A": {"tipo": "sufixo", "POINT": "_p", "LINESTRING": "_l", "POLYGON": "_a"},
        "afixo_geom_B": sufixo_b,
        "agregar_geom_A": False,
        "agregar_geom_B": False,
        "mapeamento_classes": classes,
        "mapeamento_atributos": globais or [],
    }


# --- 1. rótulo que difere só na caixa ---------------------------------------

def test_mesmo_valor_ignora_caixa_e_espaco_mas_nao_funde_codigos():
    assert mesmo_valor("Meandro Abandonado", "Meandro abandonado")
    assert mesmo_valor(" Represa/açude ", "Represa/Açude")
    assert mesmo_valor(7, "7")
    # o pior caso do outro lado: rótulos DIFERENTES continuam diferentes
    assert not mesmo_valor("Lago", "Lagoa")
    assert not mesmo_valor("Povoado", "Aglomerado Rural Isolado - Povoado")


def test_traducao_casa_o_rotulo_do_produto_com_o_rotulo_do_modelo():
    """O caso medido: a EDGV 2.1.3 grava 'Meandro Abandonado' e o Shapefile
    entregue escreve 'Meandro abandonado'. Antes, o rótulo cru seguia adiante e
    a massa d'água chegava à Topo 1.4 com tipo 9999."""
    mapa = _mapa(
        [{"classe_A": "hid_massa_dagua", "classe_B": "HID_Massa_Dagua"}],
        [{"attr_A": "tipomassadagua", "attr_B": "TIPOMASSAD",
          "traducao": [{"valor_A": 6, "valor_B": "Meandro Abandonado"},
                       {"valor_A": 7, "valor_B": "Lago"}]}],
        afixo_b_maiusculo=True,
    )
    fc = FeatureConverter(mapa, "B=>A")
    r = fc.convert_feature({
        "$GEOM_TYPE": "POLYGON", "feature_type": "HID_Massa_Dagua_A",
        "TIPOMASSAD": "Meandro abandonado",
    })
    assert r["tipomassadagua"] == 6


def test_rotulo_desconhecido_continua_sem_traducao():
    """A régua tem de REPROVAR: rótulo que não existe no domínio não pode
    virar código por acidente da normalização."""
    mapa = _mapa(
        [{"classe_A": "hid_massa_dagua", "classe_B": "HID_Massa_Dagua"}],
        [{"attr_A": "tipomassadagua", "attr_B": "TIPOMASSAD",
          "traducao": [{"valor_A": 7, "valor_B": "Lago"}]}],
        afixo_b_maiusculo=True,
    )
    fc = FeatureConverter(mapa, "B=>A")
    r = fc.convert_feature({
        "$GEOM_TYPE": "POLYGON", "feature_type": "HID_Massa_Dagua_A",
        "TIPOMASSAD": "Meandro abandonado",
    })
    assert r["tipomassadagua"] == "Meandro abandonado"


# --- 2. regra de classe bloqueada pelo nome que veio da origem --------------

def _mapa_trecho_massa():
    return _mapa([{
        "classe_A": "hid_trecho_massa_dagua",
        "classe_B": "hid_massa_dagua",
        "mapeamento_atributos": [{"attr_A": "tipotrechomassa", "attr_B": "tipomassadagua"}],
    }])


def test_regra_de_classe_sem_traducao_dispara_mesmo_com_nome_vindo_da_origem():
    """O caso medido: a 2.1.3 tem tipomassadagua E tipotrechomassa na mesma
    classe. Como `mapped` nasce cópia da origem, o destino aparecia como já
    preenchido e o renomeio nunca acontecia: 29 trechos de uma folha chegaram
    com 9999 (Desconhecida) em vez de 1 (Rio)."""
    fc = FeatureConverter(_mapa_trecho_massa(), "A=>B")
    r = fc.convert_feature({
        "$GEOM_TYPE": "POLYGON", "feature_type": "cb.hid_trecho_massa_dagua_a",
        "tipomassadagua": 0, "tipotrechomassa": 1,
    })
    assert r["tipomassadagua"] == 1


def test_regra_de_classe_COM_traducao_ainda_nao_desfaz_o_que_a_global_resolveu():
    """O guard tem de continuar valendo onde ele foi feito para valer, senão o
    conserto vira regressão: a tradução global decide, a de classe não
    sobrescreve com o valor cru."""
    mapa = _mapa(
        [{"classe_A": "x", "classe_B": "y",
          "mapeamento_atributos": [{"attr_A": "origem", "attr_B": "alvo",
                                    "traducao": [{"valor_A": 99, "valor_B": 77}]}]}],
        [{"attr_A": "outro", "attr_B": "alvo",
          "traducao": [{"valor_A": 1, "valor_B": 11}]}],
    )
    fc = FeatureConverter(mapa, "A=>B")
    r = fc.convert_feature({
        "$GEOM_TYPE": "POINT", "feature_type": "cb.x_p",
        "outro": 1, "origem": 5,
    })
    # a global resolveu alvo=11 e o 5 não tem tradução na regra de classe
    assert r["alvo"] == 11


# --- 3. Z indo para coluna 2D -----------------------------------------------

def _gdf_3d():
    return gpd.GeoDataFrame(
        {"nome": ["a", "b"]},
        geometry=[LineString([(0, 0, 5), (1, 1, 6)]), Point(2, 2, 7).buffer(0.1)],
        crs="EPSG:4674",
    )


def test_tem_z_e_force_2d():
    g = _gdf_3d()
    assert tem_z(g)
    achatado = force_2d(g)
    assert not tem_z(achatado)
    assert len(achatado) == len(g)
    # achatar não pode mexer em planimetria
    assert achatado.geometry.iloc[0].coords[0][:2] == (0.0, 0.0)


def test_writer_achata_quando_o_destino_e_2d(monkeypatch):
    monkeypatch.setattr(w, "_dimensao_destino", lambda *a, **k: 2)
    saida = w._achatar_se_destino_2d(_gdf_3d(), None, "edgv", "qualquer")
    assert not tem_z(saida)


def test_writer_preserva_z_quando_o_destino_e_3d(monkeypatch):
    """Sem este eixo, o achatamento passaria a valer para todo destino e o
    teste acima aprovaria por omissão."""
    monkeypatch.setattr(w, "_dimensao_destino", lambda *a, **k: 3)
    saida = w._achatar_se_destino_2d(_gdf_3d(), None, "edgv", "qualquer")
    assert tem_z(saida)


def test_writer_nao_mexe_em_geometria_ja_2d(monkeypatch):
    plano = gpd.GeoDataFrame({"n": [1]}, geometry=[Point(0, 0)], crs="EPSG:4674")
    chamou = []
    monkeypatch.setattr(w, "_dimensao_destino", lambda *a, **k: chamou.append(1) or 2)
    saida = w._achatar_se_destino_2d(plano, None, "edgv", "qualquer")
    assert not chamou, "não deve nem consultar o destino quando não há Z"
    assert saida is plano
