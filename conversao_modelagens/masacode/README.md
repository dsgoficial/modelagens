# Conversao EDGV 3.0 Topo 1.4 -> MASACODE (rotina standalone)

Rotina STANDALONE (sem QGIS) que converte camadas EDGV 3.0 Topo 1.4 de um banco PostGIS para o
formato **MASACODE** (terreno do simulador COMBATER / MASA SWORD). Escreve um Shapefile por feicao
MASACODE (Forest, Water, Road, River, ...), cada um com os atributos `MASACODE` (int) e `name` (str,
do campo `nome` da feicao EDGV). Preserva o SRC de origem.

Espelha o algoritmo `convertEDGV3Topo14ToMASACODE` do plugin **EBGeo Desktop**
(`dsgoficial/EBGeo_Desktop`, provider EBGeo, grupo MASACODE), porem em geopandas/shapely, para rodar
headless e em lote. **E SEPARADA do conversor padrao** deste repo (`conversor/`), que converte ENTRE
modelagens EDGV; aqui so se gera o produto MASACODE a partir de uma Topo 1.4 ja pronta.

## Uso

Por config JSON (ver `config_masacode_exemplo.json`):

    python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py --config conversao_modelagens/masacode/config_masacode_exemplo.json

Por linha de comando:

    python conversao_modelagens/masacode/converte_edgv_topo14_masacode.py \
        --host localhost --port 5432 --db NOME_DO_BANCO --user postgres --password SENHA \
        --schema edgv --out PASTA_DE_SAIDA

Requisitos: geopandas, shapely>=2, sqlalchemy, psycopg2 (os mesmos de `conversor/requirements.txt`).

## Mapeamento (classe EDGV Topo 1.4 -> MASACODE)

| MASACODE | Arquivo | Classe EDGV e filtro |
|---|---|---|
| 10000 | Forest | `cobter_vegetacao_a` tipo 601, 602 |
| 10001 | Plantation | `cobter_vegetacao_a` tipo 107, 142, 150, 194, 196, 197, 1296 |
| 10002 | Swamp | `cobter_vegetacao_a` tipo 301 |
| 10005 | Sand | `cobter_vegetacao_a` tipo 1000 a 1004 (todo terreno exposto) |
| 10003 | Urban_Area | `cobter_area_edificada_a`, `cobter_area_construida_a` |
| 10003 | Urban_Point | `llp_localidade_p` |
| 10004 | Water | `cobter_massa_dagua_a` |
| 10007 | Mountain | `elemnat_toponimo_fisiografico_natural_p` tipo 3 |
| 20001 | Road | `infra_via_deslocamento_l` tipo 3, 6 (e tipo 2/4 sem jurisdicao conhecida) |
| 20002 | Road | `infra_via_deslocamento_l` tipo 2, 4, jurisdicao 0 |
| 20003 | Road | `infra_via_deslocamento_l` tipo 2, 4, jurisdicao 1, 2 |
| 20004 | Road | `infra_via_deslocamento_l` tipo 5 (arruamento) |
| 20005 | Bridge | `infra_elemento_viario_l` tipo 201 a 204 |
| 20006 | Railroad | `infra_ferrovia_l` |
| 20007 | Tunnel | `infra_elemento_viario_l` tipo 101, 102 |
| 21000 | Cliff | `elemnat_elemento_fisiografico_l` tipo 8, 13 |
| 21002 | River | `elemnat_trecho_drenagem_l` regime 0, 1 (e default) |
| 21003 | River | `elemnat_trecho_drenagem_l` regime 3 |

Classes ou valores fora do mapa sao ignorados (campo, tipo 901, vira terreno aberto default).

## Decisoes correntes da DGEO embutidas (2026-06-24)

- Todo terreno exposto (tipo 1000 a 1004) -> Sand (nao so areia 1002). A cobertura por IA nao distingue subtipo.
- Regime 0 (desconhecido) -> River permanente (21002). A hidrografia da BHO/IAT nao classifica perene/intermitente.

(As mesmas decisoes estao no `convertEDGV3Topo14ToMASACODE.py` do EBGeo Desktop.)

## Funcionamento

Para cada classe: le do PostGIS; descarta Z e M; explode multipartes em feicoes simples; mapeia
classe e atributo para o codigo MASACODE; acumula por arquivo de saida; escreve um Shapefile por
feicao com `MASACODE` e `name`, no SRC de origem (tipicamente 4674).
