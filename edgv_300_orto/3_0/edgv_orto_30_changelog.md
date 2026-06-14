# EDGV Orto 3.0 — Changelog (2.5 → 3.0)

> **EDGV Orto 3.0** é o perfil **ortoimagem** evoluído do **Orto 2.5**.
> Estratégia: **espelhar o conjunto de classes do Orto 2.5** (mesma estrutura,
> classes separadas), porém com todas as definições **rebaseadas no EDGV
> Topo 2.0** (tipos, domínios, primitivas, CHECKs e a extensão de qualidade/
> linhagem). O conjunto de classes do Orto 3.0 é **idêntico** ao do Orto 2.5.

## 1. Visão geral

| | Orto 2.5 | **Orto 3.0** |
|---|---|---|
| Modelo base | EDGV 3.0 | **EDGV Topo 2.0** |
| Versão | 2.5.4 | **3.0.0** |
| Classes temáticas | 27 | **27** (mesmas) |
| Classes auxiliares (`extension_classes`) | 24 | **24** (mesmas) |
| Domínios | 42 | **42** (rebaseados no Topo 2.0) |
| SQL DDL | ❌ não existia | ✅ **gerado** — 70 tabelas `edgv` + 42 `dominios` |
| Extensão de qualidade | básica (179 linhas) | ✅ **completa** (geocódigo, `fontes` JSON, ciclo de vida, acurácias, triggers, SAP) |
| CRS | 4674 (SIRGAS 2000) | 4674 (SIRGAS 2000) |

## 2. Princípio de derivação

Para **cada classe do Orto 2.5**:

- **Existe no Topo 2.0** → usa a definição **integral** do Topo 2.0 (temática ou
  auxiliar), com **todos os atributos** — sem redução.
- **Não existe no Topo 2.0** (classe própria do produto ortoimagem) → copiada
  **verbatim do Orto 2.5**. São elas:
  - temáticas: `aglomerado_rural`, `area_pub_militar`, `nome_local`,
    `terra_indigena`, `unidade_conservacao`;
  - auxiliares: `edicao_articulacao_imagem`, `edicao_area_pub_militar`,
    `edicao_terra_indigena`, `edicao_unidade_conservacao`.

Os domínios referenciados vêm do Topo 2.0 (todos presentes; **códigos idênticos**
aos do Orto 2.5 — o Topo apenas acrescenta códigos novos, logo nenhuma tradução
de valores é necessária).

## 3. Diferenças em relação ao desenho anterior (rascunho "subconjunto estrito")

Esta versão **separa** as áreas especiais e localidades em classes próprias
(padrão do Orto 2.5), em vez de unificá-las em `limite_especial`/`localidade`:

- ➕ Reintroduzidas como classes: `aglomerado_rural`, `area_pub_militar`,
  `nome_local`, `terra_indigena`, `unidade_conservacao`.
- ➕ Auxiliar de carta-imagem `edicao_articulacao_imagem` (articulação/recorte da
  imagem — própria do produto orto).
- ➖ Removidas as auxiliares `edicao_borda_elemento_hidrografico` e
  `edicao_simb_direcao_corrente` (não existiam no Orto 2.5).
- ➖ `llp_limite_especial` deixa de ser classe temática (suas feições viram as
  classes separadas acima). As auxiliares `centroide_/delimitador_limite_especial`
  permanecem (como no Orto 2.5).

## 4. Atributos — herdados integralmente do Topo 2.0 (sem redução)

As classes do Orto 3.0 que **existem no Topo 2.0 mantêm o conjunto de atributos
integral do Topo 2.0** — não há poda. O Orto 3.0 é *baseado no* Topo 2.0; a
distinção "orto" está na **seleção de classes** (perfil ortoimagem), não na
redução de atributos. Assim, por exemplo, `via_deslocamento`/`ferrovia` mantêm
`largura`/`gabarito_vertical`/`vao_livre`/`carga_suport_maxima`, e `limite_legal`
mantém `sigla`/`geocodigo_ibge`/`populacao`/`em_litigio`/`maritimo`. As 22 classes
comuns são **idênticas, atributo a atributo, ao Topo 2.0** — conversão sem perda.

As 5 classes separadas e a `edicao_articulacao_imagem` (sem contraparte no Topo
2.0) vêm do Orto 2.5. Dois flags cartográficos exclusivos do Orto 2.5
(`massa_dagua.apresentar_simbologia`, `limite_legal.visivel`) não têm equivalente
no Topo 2.0 e não foram introduzidos.

## 5. Estrutura de arquivos

```
edgv_300_orto/3_0/
├── build_orto30_from_topo20.py    # gerador (fonte da verdade do recorte)
├── master_file_orto_30.json       # GERADO — 27 temáticas + 24 auxiliares
├── edgv_orto_30.sql               # GERADO (mastergen) — 70 tabelas edgv + 42 dominios
├── edgv_orto_30_extension.sql     # qualidade/linhagem + triggers (do Topo 2.0)
├── conversao/
│   ├── conversao_pg-edgv-orto25_pg-edgv-orto30.json   # Orto 2.5 → 3.0 (1:1)
│   └── conversao_pg-edgv-topo20_pg-edgv-orto30.json   # Topo 2.0 ⇄ 3.0 (split por tipo)
├── orto30_topo20_sem_correspondencia.md               # complemento da conversão Topo
└── edgv_orto_30_changelog.md      # este arquivo
```

## 6. Conversões

### 6.1 Orto 2.5 → Orto 3.0 (`conversao_pg-edgv-orto25_pg-edgv-orto30.json`)
Conjuntos de classes espelhados: **51 mapeamentos 1:1** (27 temáticas + 24
auxiliares). Atributos alinham por nome; únicos descartes são os 2 flags do §4.
Migração praticamente sem perdas.

### 6.2 Topo 2.0 ⇄ Orto 3.0 (`conversao_pg-edgv-topo20_pg-edgv-orto30.json`)
47 mapeamentos. Classes comuns 1:1; as classes separadas são mapeadas por
**filtro sobre `tipo`** a partir das classes unificadas do Topo 2.0:

| Topo 2.0 | `tipo` | → Orto 3.0 |
|---|---|---|
| `llp_localidade` | 1,2,3,4,9,10 | `llp_localidade` |
| `llp_localidade` | 5,6,7 | `llp_aglomerado_rural` |
| `llp_localidade` | 8 | `llp_nome_local` |
| `llp_limite_especial` | 36 | `llp_area_pub_militar` |
| `llp_limite_especial` | 2 | `llp_terra_indigena` |
| `llp_limite_especial` | 5,24–35 | `llp_unidade_conservacao` |

`tipo_limite_especial` código 3 (Território quilombola) não tem destino no Orto.
As 4 auxiliares próprias do orto (§2) não têm fonte no Topo 2.0 (ver gap doc §3).

## 7. Como (re)gerar

```bash
# 1) master + 2 conversões + gap doc (a partir do Topo 2.0 e do Orto 2.5)
python edgv_300_orto/3_0/build_orto30_from_topo20.py

# 2) SQL DDL (puro JSON → SQL)
python rotinas/mastergen.py \
       edgv_300_orto/3_0/master_file_orto_30.json \
       edgv_300_orto/3_0/edgv_orto_30.sql --owner postgres
#    (mastergen emite CR; normalizar para CRLF como o edgv_topo_20.sql)

# 3) aplicar no PostGIS: DDL e depois a extensão
psql -d edgv_orto_30 -f edgv_300_orto/3_0/edgv_orto_30.sql
psql -d edgv_orto_30 -f edgv_300_orto/3_0/edgv_orto_30_extension.sql
```
