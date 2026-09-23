"""
converte_edgv_topo14_masacode.py

Rotina STANDALONE (sem QGIS) que converte camadas EDGV 3.0 Topo 1.4 para o formato MASACODE
(terreno do simulador COMBATER / MASA SWORD), replicando o algoritmo `convertEDGV3Topo14ToMASACODE`
do plugin EBGeo Desktop (provider EBGeo, grupo MASACODE). Le de um banco PostGIS e escreve um
Shapefile por feicao MASACODE (Forest, Water, Road, River, ...), cada um com os atributos
`MASACODE` (int) e `name` (str, do campo `nome` da feicao EDGV). Preserva o SRC de origem.

Esta rotina e SEPARADA do conversor padrao (conversao_modelagens/conversor), que converte ENTRE
modelagens EDGV. Aqui so se gera o produto MASACODE a partir de uma Topo 1.4 ja pronta.

Mapeamento (fiel ao EBGeo Desktop, com as decisoes correntes da DGEO):
  - Terreno exposto (cobter_vegetacao tipo 1000-1004) -> Sand (todas as variantes, nao so areia 1002).
  - Drenagem regime 0 (Desconhecido) -> River permanente (21002), junto com regime 1; regime 3 -> 21003.
  - Rodovia (infra_via_deslocamento tipo 2 Estrada/Rodovia e 4 Auto-estrada) -> name vem da sigla
    (ex.: BR-101), nao do campo nome. Demais vias mantem o nome.

Extensao alem do EBGeo (2026-09-23): ponte gravada como PONTO (infra_elemento_viario_p tipo 201-204,
classe da EDGV 3.0 Pro que a Topo 1.4 nao tem) vira Bridge em LINHA. A linha e o trecho da via
(modal_uso 4) ou da ferrovia (modal_uso 5) que a ponte carrega, centrado no cruzamento dela com a
drenagem ou com a massa d'agua mais proximo do ponto, ate RAIO_PONTE_PONTO_M. Ver pontes_de_ponto().

Uso:
  python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py --config .../config_masacode_exemplo.json
  python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py --host localhost --port 5432 \
        --db ia2026_sul_cobter_50k_4674_edgvtopo14 --user postgres --password postgres --out SAIDA

Requisitos: geopandas, shapely>=2, sqlalchemy, psycopg2 (os mesmos do conversor/requirements.txt).
"""
import argparse
import json
import os

import math

import geopandas as gpd
import pandas as pd
import shapely
from pyproj import Geod
from shapely import force_2d
from shapely.geometry import Point
from shapely.ops import substring
from sqlalchemy import create_engine, text

# --- Mapeamento classe EDGV Topo 1.4 -> (MASACODE, arquivo de saida) ---
# Classes/valores fora do mapa sao IGNORADOS (nao geram saida), igual ao EBGeo.

VEGETACAO_MAP = {
    601: (10000, 'Forest'), 602: (10000, 'Forest'),
    107: (10001, 'Plantation'), 142: (10001, 'Plantation'), 150: (10001, 'Plantation'),
    194: (10001, 'Plantation'), 196: (10001, 'Plantation'), 197: (10001, 'Plantation'),
    1296: (10001, 'Plantation'),
    301: (10002, 'Swamp'),
    1000: (10005, 'Sand'), 1001: (10005, 'Sand'), 1002: (10005, 'Sand'),
    1003: (10005, 'Sand'), 1004: (10005, 'Sand'),
}
ELEMENTO_VIARIO_MAP = {
    201: (20005, 'Bridge'), 202: (20005, 'Bridge'), 203: (20005, 'Bridge'), 204: (20005, 'Bridge'),
    101: (20007, 'Tunnel'), 102: (20007, 'Tunnel'),
}
DRENAGEM_MAP = {0: 21002, 1: 21002, 3: 21003}  # regime; demais -> default
DRENAGEM_DEFAULT = 21002

# Classes de codigo fixo: tabela -> (MASACODE, arquivo)
FIXED = {
    'cobter_massa_dagua_a': (10004, 'Water'),
    'cobter_area_edificada_a': (10003, 'Urban_Area'),
    'cobter_area_construida_a': (10003, 'Urban_Area'),
    'llp_localidade_p': (10003, 'Urban_Point'),
    'infra_ferrovia_l': (20006, 'Railroad'),
}

# Todas as classes de entrada que o conversor entende.
TABLES = [
    'cobter_vegetacao_a', 'cobter_massa_dagua_a', 'cobter_area_edificada_a',
    'cobter_area_construida_a', 'llp_localidade_p', 'elemnat_trecho_drenagem_l',
    'elemnat_elemento_fisiografico_l', 'infra_via_deslocamento_l', 'infra_elemento_viario_l',
    'elemnat_toponimo_fisiografico_natural_p', 'infra_ferrovia_l',
]


def _via_masacode(tipo, jurisdicao):
    if tipo == 5:
        return 20004
    if tipo in (3, 6):
        return 20001
    if tipo in (2, 4):
        if jurisdicao == 0:
            return 20002
        if jurisdicao in (1, 2):
            return 20003
        return 20001
    return None


def _classify(table, gdf):
    """Adiciona colunas MASACODE e __out; remove feicoes sem mapeamento. Geometria ativa: 'geometry'."""
    g = gdf.copy()
    g['name'] = g['nome'] if 'nome' in g.columns else None

    if table in FIXED:
        g['MASACODE'], g['__out'] = FIXED[table]
    elif table == 'cobter_vegetacao_a':
        m = g['tipo'].map(VEGETACAO_MAP)
        g['MASACODE'] = m.map(lambda t: t[0] if isinstance(t, tuple) else None)
        g['__out'] = m.map(lambda t: t[1] if isinstance(t, tuple) else None)
    elif table == 'infra_elemento_viario_l':
        m = g['tipo'].map(ELEMENTO_VIARIO_MAP)
        g['MASACODE'] = m.map(lambda t: t[0] if isinstance(t, tuple) else None)
        g['__out'] = m.map(lambda t: t[1] if isinstance(t, tuple) else None)
    elif table == 'elemnat_trecho_drenagem_l':
        g['MASACODE'] = g['regime'].map(lambda r: DRENAGEM_MAP.get(int(r), DRENAGEM_DEFAULT))
        g['__out'] = 'River'
    elif table == 'elemnat_elemento_fisiografico_l':
        g['MASACODE'] = g['tipo'].map(lambda t: 21000 if int(t) in (8, 13) else None)
        g['__out'] = 'Cliff'
    elif table == 'elemnat_toponimo_fisiografico_natural_p':
        g['MASACODE'] = g['tipo'].map(lambda t: 10007 if int(t) == 3 else None)
        g['__out'] = 'Mountain'
    elif table == 'infra_via_deslocamento_l':
        jur = list(g['jurisdicao']) if 'jurisdicao' in g.columns else [None] * len(g)
        g['MASACODE'] = [
            _via_masacode(int(t), int(j) if j is not None else None)
            for t, j in zip(g['tipo'], jur)
        ]
        g['__out'] = 'Road'
        # Para rodovia (Estrada/Rodovia=2, Auto-estrada=4) o name MASACODE vem da
        # sigla (ex.: BR-101), nao do campo nome. Demais vias mantem o nome.
        eh_rodovia = g['tipo'].map(lambda t: int(t) in (2, 4))
        g.loc[eh_rodovia, 'name'] = g['sigla'] if 'sigla' in g.columns else None
    else:
        return None

    g = g[g['MASACODE'].notna() & g['__out'].notna()]
    return g[['MASACODE', 'name', 'geometry', '__out']]


# --- Ponte em PONTO -> Bridge em LINHA (extensao alem do EBGeo) ---
PONTOS_PONTE = 'infra_elemento_viario_p'
PONTE_TIPOS = (201, 202, 203, 204)  # os mesmos codigos que viram Bridge na classe linha
MODAL_RODOVIARIO = 4
MODAL_FERROVIARIO = 5
RAIO_PONTE_PONTO_M = 50.0          # ponto a ate isso do cruzamento (1 mm a 1:50.000)
COMPRIMENTO_PONTE_PONTO_M = 30.0   # a base nao traz a extensao da ponte em ponto; convencao
_GEOD = Geod(ellps='GRS80')


def _medidor(crs):
    """(distancia entre dois pontos, comprimento de linha) em metros, conforme o SRC."""
    if crs is not None and crs.is_geographic:
        return (lambda a, b: _GEOD.inv(a.x, a.y, b.x, b.y)[2],
                lambda g: _GEOD.geometry_length(g))
    return (lambda a, b: a.distance(b), lambda g: g.length)


def _janela(p, raio_m, geografico):
    """Raio de busca na unidade do SRC, folgado para nao perder candidato."""
    if not geografico:
        return raio_m * 1.01
    return 1.5 * raio_m / (111320.0 * max(math.cos(math.radians(p.y)), 0.2))


def _linhas_simples(gdf):
    if gdf is None or len(gdf) == 0:
        return []
    return [g for g in shapely.get_parts(gdf.geometry.values) if g.geom_type == 'LineString' and not g.is_empty]


def _trecho(linha, s_ini, s_fim, meio_m, comprimento):
    """Trecho de `linha` de s_ini a s_fim (unidade do SRC) estendido meio_m em metros de cada lado."""
    total = linha.length
    if total == 0:
        return None
    # escala local (metros por unidade do SRC) medida no proprio trecho, alargado se for curto
    d = max(s_fim - s_ini, total * 1e-3, 1e-12)
    a, b = max(0.0, s_ini - d), min(total, s_fim + d)
    k = comprimento(substring(linha, a, b)) / (b - a) if b > a else 1.0
    delta = meio_m / k if k > 0 else 0.0
    return substring(linha, max(0.0, s_ini - delta), min(total, s_fim + delta))


def pontes_de_ponto(pontos, vias, ferrovias, drenagem, massa, pontes_linha,
                    raio_m=RAIO_PONTE_PONTO_M, comprimento_m=COMPRIMENTO_PONTE_PONTO_M):
    """Converte ponte em ponto (tipo 201-204) em Bridge (20005) em linha.

    A linha que a ponte carrega sai do modal_uso: 4 via, 5 ferrovia, outro as duas. O centro e o
    cruzamento dessa linha com a drenagem ou com a borda da massa d'agua mais proximo do ponto, ate
    raio_m. Sobre massa d'agua a ponte cobre o trecho dentro do poligono. Sem cruzamento no raio, a
    ponte centra na projecao do ponto na linha mais proxima (status 'sem_cruzamento'). Ponto a ate
    raio_m de ponte ja gravada em linha e pulado ('ja_em_linha'). Devolve (GeoDataFrame, relatorio).
    """
    vazio = gpd.GeoDataFrame({'MASACODE': [], 'name': []}, geometry=[], crs=None if pontos is None else pontos.crs)
    if pontos is None or len(pontos) == 0:
        return vazio, []
    crs = pontos.crs
    geografico = crs is not None and crs.is_geographic
    dist, comprimento = _medidor(crs)
    meio = comprimento_m / 2.0
    lin = {'via': _linhas_simples(vias), 'ferrovia': _linhas_simples(ferrovias)}
    arv = {k: shapely.STRtree(v) if v else None for k, v in lin.items()}
    obst_l = _linhas_simples(drenagem)
    polis = [] if massa is None or len(massa) == 0 else [
        g for g in shapely.get_parts(massa.geometry.values) if g.geom_type == 'Polygon']
    obst_l += [p.exterior for p in polis] + [r for p in polis for r in p.interiors]
    arv_obst = shapely.STRtree(obst_l) if obst_l else None
    arv_poli = shapely.STRtree(polis) if polis else None
    ja = _linhas_simples(None if pontes_linha is None or len(pontes_linha) == 0 else
                         pontes_linha[pontes_linha['tipo'].isin(PONTE_TIPOS)])
    arv_ja = shapely.STRtree(ja) if ja else None

    saida, rel = [], []
    for _, f in pontos.iterrows():
        if int(f['tipo']) not in PONTE_TIPOS:
            continue
        for p in shapely.get_parts(f.geometry):
            reg = {'id': str(f.get('id')), 'tipo': int(f['tipo']), 'modal_uso': f.get('modal_uso'),
                   'lon_x': p.x, 'lat_y': p.y}
            modal = f.get('modal_uso')
            modal = int(modal) if modal is not None and not pd.isna(modal) else None
            camadas = ['via'] if modal == MODAL_RODOVIARIO else ['ferrovia'] if modal == MODAL_FERROVIARIO else ['via', 'ferrovia']
            w = p.buffer(_janela(p, raio_m, geografico))
            cand = [(k, lin[k][i]) for k in camadas if arv[k] is not None for i in arv[k].query(w)]
            if not cand:
                rel.append({**reg, 'status': 'sem_linha_no_raio'})
                continue
            # cruzamento mais proximo do ponto
            melhor = None
            obst = [obst_l[i] for i in arv_obst.query(w)] if arv_obst is not None else []
            for k, c in cand:
                for o in obst:
                    for x in shapely.get_parts(c.intersection(o)):
                        if x.geom_type != 'Point':
                            continue
                        d = dist(p, x)
                        if d <= raio_m and (melhor is None or d < melhor[0]):
                            melhor = (d, c, x)
            status = 'cruzamento'
            if melhor is None:
                d, c = min(((dist(p, c.interpolate(c.project(p))), c) for _, c in cand), key=lambda t: t[0])
                if d > raio_m:
                    rel.append({**reg, 'status': 'sem_linha_no_raio', 'dist_m': round(d, 2)})
                    continue
                melhor = (d, c, c.interpolate(c.project(p)))
                status = 'sem_cruzamento'
            d, c, x = melhor
            if arv_ja is not None and any(dist(x, j.interpolate(j.project(x))) <= raio_m for j in (ja[i] for i in arv_ja.query(w))):
                rel.append({**reg, 'status': 'ja_em_linha', 'dist_m': round(d, 2)})
                continue
            s = c.project(x)
            s_ini = s_fim = s
            if arv_poli is not None and status == 'cruzamento':
                for i in arv_poli.query(x.buffer(_janela(x, 1.0, geografico))):
                    dentro = c.intersection(polis[i])
                    tol = 1e-7 if geografico else 0.01  # ~1 cm
                    partes = [g for g in shapely.get_parts(dentro) if g.geom_type == 'LineString' and g.distance(x) <= tol]
                    for g in partes:
                        a, b = c.project(Point(g.coords[0])), c.project(Point(g.coords[-1]))
                        s_ini, s_fim = min(s_ini, a, b), max(s_fim, a, b)
            ponte = _trecho(c, s_ini, s_fim, meio, comprimento)
            if ponte is None or ponte.is_empty or ponte.geom_type != 'LineString':
                rel.append({**reg, 'status': 'trecho_vazio', 'dist_m': round(d, 2)})
                continue
            saida.append({'MASACODE': 20005, 'name': f.get('nome'), 'geometry': ponte})
            rel.append({**reg, 'status': status, 'dist_m': round(d, 2), 'comprimento_m': round(comprimento(ponte), 2)})
    if not saida:
        return vazio, rel
    return gpd.GeoDataFrame(saida, geometry='geometry', crs=crs), rel


def _ler(engine, schema, table):
    try:
        gdf = gpd.read_postgis(text(f'SELECT * FROM {schema}.{table}'), engine, geom_col='geom')
    except Exception as e:
        print(f'[skip] {table}: {e}')
        return None
    if gdf is None or len(gdf) == 0:
        print(f'[vazio] {table}')
        return None
    # geometria ativa passa a se chamar 'geometry'; descarta Z/M
    gdf = gdf.rename_geometry('geometry')
    gdf['geometry'] = gpd.GeoSeries(force_2d(gdf.geometry.values), index=gdf.index, crs=gdf.crs)
    return gdf.set_geometry('geometry')


def convert(conn, schema, out_folder, keep_attributes=False, ponte_ponto=True,
            raio_ponte_m=RAIO_PONTE_PONTO_M, comprimento_ponte_m=COMPRIMENTO_PONTE_PONTO_M):
    url = "postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}".format(**conn)
    engine = create_engine(url)
    os.makedirs(out_folder, exist_ok=True)

    outputs = {}  # arquivo -> lista de GeoDataFrames
    lidas = {}
    for table in TABLES:
        gdf = _ler(engine, schema, table)
        if gdf is None:
            continue
        lidas[table] = gdf
        res = _classify(table, gdf)
        if res is None or len(res) == 0:
            continue
        res = res.explode(index_parts=False, ignore_index=True)  # multipartes -> simples
        for out_name, sub in res.groupby('__out'):
            outputs.setdefault(out_name, []).append(sub.drop(columns='__out'))

    if ponte_ponto:
        pontos = _ler(engine, schema, PONTOS_PONTE)
        pontes, rel = pontes_de_ponto(
            pontos, lidas.get('infra_via_deslocamento_l'), lidas.get('infra_ferrovia_l'),
            lidas.get('elemnat_trecho_drenagem_l'), lidas.get('cobter_massa_dagua_a'),
            lidas.get('infra_elemento_viario_l'), raio_ponte_m, comprimento_ponte_m)
        if len(pontes):
            outputs.setdefault('Bridge', []).append(pontes)
        if rel:
            cont = pd.Series([r['status'] for r in rel]).value_counts().to_dict()
            print(f'Pontes em ponto -> Bridge: {len(pontes)} de {len(rel)} ({cont})')

    summary = {}
    for out_name, parts in outputs.items():
        merged = pd.concat(parts, ignore_index=True)
        merged = gpd.GeoDataFrame(merged, geometry='geometry', crs=parts[0].crs)
        merged['MASACODE'] = merged['MASACODE'].astype(int)
        path = os.path.join(out_folder, out_name + '.shp')
        merged.to_file(path, driver='ESRI Shapefile', encoding='utf-8')
        codes = sorted(merged['MASACODE'].unique().tolist())
        summary[out_name] = (len(merged), codes)
        print(f'{out_name}.shp: {len(merged)} feicoes, MASACODE {codes}')
    if not outputs:
        print('Nenhuma feicao convertida.')
    return summary


def main():
    ap = argparse.ArgumentParser(description='Converte EDGV Topo 1.4 (PostGIS) para Shapefiles MASACODE.')
    ap.add_argument('--config', help='JSON com connection/output_folder/keep_attributes')
    ap.add_argument('--host'); ap.add_argument('--port', type=int, default=5432)
    ap.add_argument('--db'); ap.add_argument('--user'); ap.add_argument('--password')
    ap.add_argument('--schema', default='edgv'); ap.add_argument('--out')
    ap.add_argument('--keep-attributes', action='store_true')
    ap.add_argument('--sem-ponte-ponto', action='store_true',
                    help='nao converte ponte em ponto (infra_elemento_viario_p) em Bridge')
    ap.add_argument('--raio-ponte-ponto', type=float, default=RAIO_PONTE_PONTO_M,
                    help='distancia maxima, em metros, do ponto ao cruzamento (padrao %(default)s)')
    ap.add_argument('--comprimento-ponte-ponto', type=float, default=COMPRIMENTO_PONTE_PONTO_M,
                    help='comprimento, em metros, da Bridge gerada de ponto (padrao %(default)s)')
    a = ap.parse_args()
    ponte = {'ponte_ponto': not a.sem_ponte_ponto, 'raio_ponte_m': a.raio_ponte_ponto,
             'comprimento_ponte_m': a.comprimento_ponte_ponto}

    if a.config:
        with open(a.config, encoding='utf-8') as f:
            cfg = json.load(f)
        conn = cfg['connection']
        schema = conn.get('schema', cfg.get('schema', 'edgv'))
        out_folder = cfg['output_folder']
        keep = cfg.get('keep_attributes', False)
        ponte = {'ponte_ponto': cfg.get('ponte_ponto', ponte['ponte_ponto']),
                 'raio_ponte_m': cfg.get('raio_ponte_ponto_m', ponte['raio_ponte_m']),
                 'comprimento_ponte_m': cfg.get('comprimento_ponte_ponto_m', ponte['comprimento_ponte_m'])}
    else:
        if not (a.db and a.user and a.host and a.out):
            ap.error('sem --config, informe --host --db --user --password --out')
        conn = {'host': a.host, 'port': a.port, 'database': a.db, 'user': a.user, 'password': a.password}
        schema = a.schema
        out_folder = a.out
        keep = a.keep_attributes

    convert(conn, schema, out_folder, keep, **ponte)


if __name__ == '__main__':
    main()
