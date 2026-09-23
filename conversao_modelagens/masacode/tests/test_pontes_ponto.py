"""Ponte em ponto -> Bridge em linha (pontes_de_ponto). Um caso por eixo que a funcao afirma decidir."""
import os
import sys

import geopandas as gpd
import pytest
from pyproj import Geod
from shapely.geometry import LineString, Point, Polygon

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import converte_edgv_topo14_masacode as m  # noqa: E402

UTM = 'EPSG:31981'


def gdf(geoms, crs=UTM, **cols):
    return gpd.GeoDataFrame(cols, geometry=list(geoms), crs=crs)


def pontos(*regs, crs=UTM):
    return gdf([r[0] for r in regs], crs=crs, id=[str(i) for i in range(len(regs))],
               tipo=[r[1] for r in regs], modal_uso=[r[2] for r in regs], nome=['p%d' % i for i in range(len(regs))])


# cena base: via horizontal em y=0, ferrovia horizontal em y=-20, rio vertical em x=0
VIA = gdf([LineString([(-500, 0), (500, 0)])])
FERRO = gdf([LineString([(-500, -20), (500, -20)])])
RIO = gdf([LineString([(0, -300), (0, 300)])])


def rodar(pts, vias=VIA, ferro=FERRO, rio=RIO, massa=None, ja=None, **kw):
    return m.pontes_de_ponto(pts, vias, ferro, rio, massa, ja, **kw)


def test_ponte_no_cruzamento_centrada_e_sobre_a_via():
    out, rel = rodar(pontos((Point(0, 0), 203, 4)))
    assert rel[0]['status'] == 'cruzamento'
    ln = out.geometry.iloc[0]
    assert ln.length == pytest.approx(30.0)
    assert ln.interpolate(0.5, normalized=True).distance(Point(0, 0)) < 1e-9
    assert VIA.geometry.iloc[0].buffer(1e-9).covers(ln)
    assert out['MASACODE'].iloc[0] == 20005 and out['name'].iloc[0] == 'p0'


def test_ponto_deslocado_no_raio_centra_no_cruzamento():
    out, rel = rodar(pontos((Point(0, 45), 203, 4)))
    assert rel[0]['status'] == 'cruzamento' and rel[0]['dist_m'] == pytest.approx(45.0)
    assert out.geometry.iloc[0].interpolate(0.5, normalized=True).distance(Point(0, 0)) < 1e-9


def test_ponto_fora_do_raio_nao_vira_ponte():
    out, rel = rodar(pontos((Point(0, 80), 203, 4)))
    assert len(out) == 0 and rel[0]['status'] == 'sem_linha_no_raio'


def test_via_e_rio_no_raio_mas_cruzamento_fora_dele():
    # via a 40 m e rio a 40 m do ponto, cruzando-se a 56,6 m: nao vale como cruzamento
    out, rel = rodar(pontos((Point(40, 40), 203, 4)))
    assert rel[0]['status'] == 'sem_cruzamento'
    assert out.geometry.iloc[0].interpolate(0.5, normalized=True).distance(Point(40, 0)) < 1e-9


def test_modal_ferroviario_escolhe_a_ferrovia_mesmo_com_a_via_mais_perto():
    # o ponto esta sobre a VIA (y=0), mas a ponte e ferroviaria: tem de sair na ferrovia (y=-20)
    out, rel = rodar(pontos((Point(0, 0), 203, 5)))
    ln = out.geometry.iloc[0]
    assert FERRO.geometry.iloc[0].buffer(1e-9).covers(ln)
    assert ln.interpolate(0.5, normalized=True).distance(Point(0, -20)) < 1e-9


def test_modal_rodoviario_ignora_a_ferrovia():
    out, _ = rodar(pontos((Point(0, -20), 203, 4)))
    assert VIA.geometry.iloc[0].buffer(1e-9).covers(out.geometry.iloc[0])


def test_ponte_ja_gravada_em_linha_nao_duplica():
    ja = gdf([LineString([(-15, 0), (15, 0)])], tipo=[203])
    out, rel = rodar(pontos((Point(0, 0), 203, 4)), ja=ja)
    assert len(out) == 0 and rel[0]['status'] == 'ja_em_linha'


def test_sem_drenagem_no_raio_centra_na_projecao():
    out, rel = rodar(pontos((Point(200, 10), 203, 4)))
    assert rel[0]['status'] == 'sem_cruzamento'
    assert out.geometry.iloc[0].interpolate(0.5, normalized=True).distance(Point(200, 0)) < 1e-9


def test_massa_dagua_cobre_o_trecho_dentro_do_poligono():
    lago = gdf([Polygon([(300, -100), (400, -100), (400, 100), (300, 100)])])
    out, rel = rodar(pontos((Point(300, 5), 203, 4)), massa=lago)
    ln = out.geometry.iloc[0]
    assert rel[0]['status'] == 'cruzamento'
    assert ln.length == pytest.approx(100 + 30)
    assert ln.bounds[0] == pytest.approx(285) and ln.bounds[2] == pytest.approx(415)


def test_viaduto_e_outros_tipos_ficam_de_fora():
    out, rel = rodar(pontos((Point(0, 0), 302, 4), (Point(0, 0), 101, 4)))
    assert len(out) == 0 and rel == []


def test_ponte_perto_da_ponta_da_via_e_cortada_no_fim():
    via = gdf([LineString([(-5, 0), (500, 0)])])
    out, _ = rodar(pontos((Point(0, 0), 203, 4)), vias=via)
    assert out.geometry.iloc[0].length == pytest.approx(20.0)


def test_src_geografico_mede_em_metros():
    lat = -30.3
    via = gdf([LineString([(-55.01, lat), (-54.99, lat)])], crs='EPSG:4674')
    rio = gdf([LineString([(-55.0, lat - 0.01), (-55.0, lat + 0.01)])], crs='EPSG:4674')
    out, rel = m.pontes_de_ponto(pontos((Point(-55.0, lat + 0.0003), 203, 4), crs='EPSG:4674'),
                                 via, None, rio, None, None)
    assert rel[0]['status'] == 'cruzamento' and rel[0]['dist_m'] == pytest.approx(33.3, abs=0.5)
    assert Geod(ellps='GRS80').geometry_length(out.geometry.iloc[0]) == pytest.approx(30.0, abs=0.01)


def test_raio_e_comprimento_sao_parametros():
    out, rel = rodar(pontos((Point(0, 45), 203, 4)), raio_m=40)
    assert len(out) == 0
    out, _ = rodar(pontos((Point(0, 0), 203, 4)), comprimento_m=60)
    assert out.geometry.iloc[0].length == pytest.approx(60.0)
