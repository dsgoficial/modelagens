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

Uso:
  python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py --config .../config_masacode_exemplo.json
  python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py --host localhost --port 5432 \
        --db ia2026_sul_cobter_50k_4674_edgvtopo14 --user postgres --password postgres --out SAIDA

Requisitos: geopandas, shapely>=2, sqlalchemy, psycopg2 (os mesmos do conversor/requirements.txt).
"""
import argparse
import json
import os

import geopandas as gpd
import pandas as pd
from shapely import force_2d
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


def convert(conn, schema, out_folder, keep_attributes=False):
    url = "postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}".format(**conn)
    engine = create_engine(url)
    os.makedirs(out_folder, exist_ok=True)

    outputs = {}  # arquivo -> lista de GeoDataFrames
    for table in TABLES:
        try:
            gdf = gpd.read_postgis(text(f'SELECT * FROM {schema}.{table}'), engine, geom_col='geom')
        except Exception as e:
            print(f'[skip] {table}: {e}')
            continue
        if gdf is None or len(gdf) == 0:
            print(f'[vazio] {table}')
            continue
        # geometria ativa passa a se chamar 'geometry'; descarta Z/M
        gdf = gdf.rename_geometry('geometry')
        gdf['geometry'] = gpd.GeoSeries(force_2d(gdf.geometry.values), index=gdf.index, crs=gdf.crs)
        gdf = gdf.set_geometry('geometry')
        res = _classify(table, gdf)
        if res is None or len(res) == 0:
            continue
        res = res.explode(index_parts=False, ignore_index=True)  # multipartes -> simples
        for out_name, sub in res.groupby('__out'):
            outputs.setdefault(out_name, []).append(sub.drop(columns='__out'))

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
    a = ap.parse_args()

    if a.config:
        with open(a.config, encoding='utf-8') as f:
            cfg = json.load(f)
        conn = cfg['connection']
        schema = conn.get('schema', cfg.get('schema', 'edgv'))
        out_folder = cfg['output_folder']
        keep = cfg.get('keep_attributes', False)
    else:
        if not (a.db and a.user and a.host and a.out):
            ap.error('sem --config, informe --host --db --user --password --out')
        conn = {'host': a.host, 'port': a.port, 'database': a.db, 'user': a.user, 'password': a.password}
        schema = a.schema
        out_folder = a.out
        keep = a.keep_attributes

    convert(conn, schema, out_folder, keep)


if __name__ == '__main__':
    main()
