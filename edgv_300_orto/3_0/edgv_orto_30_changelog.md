# EDGV Orto 3.0 — Changelog (2.5 → 3.0)

> **EDGV Orto 3.0** é o perfil **ortoimagem** evoluído do **Orto 2.5**.
> Estratégia: **espelhar o conjunto de classes do Orto 2.5** (mesma estrutura,
> classes separadas), porém com todas as definições **rebaseadas no EDGV
> Topo 2.0** (tipos, domínios, primitivas, CHECKs e a extensão de qualidade/
> linhagem). O conjunto de classes espelha o do Orto 2.5, com UMA exceção:
> `pais`/`unidade_federacao` foram **consolidados** em `llp_limite_legal` (tipo
> 1/2), seguindo a Topo 2.0 (0.10.0).

## 1. Visão geral

| | Orto 2.5 | **Orto 3.0** |
|---|---|---|
| Modelo base | EDGV 3.0 | **EDGV Topo 2.0 v0.20.0** (regerado 2026-09-30; antes 0.19.0, 0.18.0, 0.17.0, 0.14.0, 0.11.0 e 0.9.0) |
| Versão | 2.5.4 | **3.0.4** |
| Classes temáticas | 27 | **25** (`pais`/`unidade_federacao` consolidados em `llp_limite_legal`) |
| Classes auxiliares (`extension_classes`) | 24 | **26** (as 24 do 2.5 mais `delimitador_limite_legal` e `centroide_limite_legal`, rev 3.0.1) |
| Domínios | 42 | **41** (rebaseados no Topo 2.0; `sigla_uf` sai com a UF) |
| SQL DDL | ❌ não existia | ✅ **gerado** — 70 tabelas `edgv` + 41 `dominios` |
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
aos do Orto 2.5 — o Topo apenas acrescenta códigos novos). Única tradução de valor
na conversão 2.5 → 3.0: a `sigla` da UF, que no Orto 2.5 é o domínio smallint
`sigla_uf` (1..27) e no `llp_limite_legal` do Topo 2.0 é string (`AC`..`TO`).

**Exceção ao espelho do Orto 2.5:** `pais` e `unidade_federacao` (classes
separadas no Orto 2.5) NÃO entram no Orto 3.0; suas feições vão para
`llp_limite_legal` com `tipo`=1 (Internacional/País) e 2 (Estadual/UF), seguindo a
consolidação que a Topo 2.0 fez na 0.10.0. Com isso o domínio `sigla_uf` também
sai do Orto 3.0 (só a UF o usava).

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
mantém `sigla`/`geocodigo_ibge`/`populacao`/`em_litigio`/`cod_iso` (rev Topo 0.13.0:
o `maritimo` foi substituído por tipos marítimos em `tipo_limite_legal`, 5/6/7). As 22 classes
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

## 7.1 Rev 3.0.1 (2026-09-19): limites por delimitador e centroide

Regerado sobre a Topo 2.0 v0.17.0. A versão anterior tinha sido gerada da 0.14.0, e por isso a regeneração traz três mudanças da Topo que o Orto ainda não tinha, mais uma própria:

| Mudança | Origem na Topo 2.0 | Efeito no Orto 3.0 |
|---|---|---|
| `tipo_limite_especial` 4 (Assentamento rural) | 0.15.0 | domínio +1 |
| `simb_ponto` em `infra_pista_pouso_l` e `_a` | 0.16.0 | os estilos filtram a pista por essa coluna; sem ela a pista não desenha |
| `tipo` em `delimitador_limite_especial_l` | 0.17.0 | a construção de `llp_terra_indigena`, `llp_unidade_conservacao` e `llp_area_pub_militar` pode rodar por classe, filtrando o delimitador pelos mesmos códigos do split (§6.2) |
| `delimitador_limite_legal_l` e `centroide_limite_legal_p` | 0.17.0 | auxiliares NOVAS, fora do conjunto do Orto 2.5: o Orto 3.0 tem `llp_limite_legal`, e o par é o que o constrói |

As duas auxiliares novas entram pela constante `EXT_NOVAS_DO_TOPO` do `build_orto30_from_topo20.py`, com mapeamento 1:1 na conversão Topo 2.0 ⇄ Orto 3.0 e fora da conversão Orto 2.5 → 3.0, que não tem de onde tirá-las. A justificativa do `tipo` no delimitador está na seção 1.5 do changelog da Topo 2.0.

Banco existente na 3.0.0: da seção 8 do changelog da Topo 2.0 servem só os comandos das tabelas que o Orto tem, ou seja, o `INSERT` do código 4 em `dominios.tipo_limite_especial` (0.15.0), o bloco do `simb_ponto` (0.16.0) e o incremento 0.17.0 inteiro. As linhas de `db_metadata` daqueles incrementos gravam versão da Topo e não se aplicam: no Orto, o fecho é `UPDATE public.db_metadata SET dbimplversion = '3.0.1'`, seguido da reaplicação de `edgv_orto_30_extension.sql`.

## 7.2 Rev 3.0.2 (2026-09-29): a linha que já existe marca o limite

Regerado sobre a Topo 2.0 v0.18.0. Justificativa na seção 1.6 do changelog da Topo 2.0.

| Mudança | Efeito no Orto 3.0 |
|---|---|
| `limite_legal`, `limite_especial` e `em_litigio` (`booleano`) em `elemnat_trecho_drenagem_l`, `delimitador_massa_dagua_l`, `infra_via_deslocamento_l` e `infra_ferrovia_l` | a divisa sobre rio, margem, via ou ferrovia deixa de ser linha sobreposta: a linha que já existe recebe a marca. O Orto não tem `llp_delimitacao_fisica_l`, a quinta classe marcada na Topo |
| `tipo` sai de `delimitador_limite_especial_l` e de `delimitador_limite_legal_l`; o segundo ganha `em_litigio` | a construção de `llp_terra_indigena`, `llp_unidade_conservacao` e `llp_area_pub_militar` deixa de filtrar o delimitador por código, como fazia a 3.0.1: cada classe usa todo limite especial e todo limite legal como linha, e o regime vem do centroide |
| `codigo_uf` em `centroide_limite_legal_p` e `llp_limite_legal_a` | a UF é a junção dos municípios por essa chave |

Banco existente na 3.0.1: da seção 8 do changelog da Topo 2.0 serve o incremento 0.18.0 sem as três linhas de `llp_delimitacao_fisica_l` e sem as de `db_metadata`. O fecho é `UPDATE public.db_metadata SET dbimplversion = '3.0.2'`, seguido da reaplicação de `edgv_orto_30_extension.sql`.

## 7.3 Rev 3.0.3 (2026-09-30): o histórico passa ao DSG Versioning

Regerado sobre a Topo 2.0 v0.19.0. Justificativa na seção 1.7 do changelog da Topo 2.0: a base versionada pelo DSG Versioning não pode ter trigger que grave usuário e relógio na linha.

| Mudança | Efeito no Orto 3.0 |
|---|---|
| Saem `operador_criacao`, `data_criacao`, `operador_atualizacao`, `data_atualizacao` e o trigger `preenche_metadado()` | quem editou e quando passam a ser eventos do histórico do DSG Versioning |
| Sai o valor 4 (Depreciado) de `dominios.status_ciclo_vida` | a depreciação é evento do histórico, com a linhagem |
| `preserva_geocodigo()` continua nas tabelas não-edição | a identidade segue protegida contra troca acidental |

O Orto não tem as colunas `confiabilidade` e `escala_maxima_autoritativa` nem a tabela `linhagem_feicao`, então a parte de qualidade calculada da 0.19.0 não se aplica.

Banco existente na 3.0.2: serve o incremento 0.19.0 da seção 8 do changelog da Topo 2.0, que usa `IF EXISTS` e passa pelos objetos que o Orto não tem, trocando as duas linhas de `db_metadata` por `UPDATE public.db_metadata SET dbimplversion = '3.0.3'` e `ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '3.0.3'`. Em seguida, reaplique `edgv_orto_30_extension.sql`.

## 7.4 Rev 3.0.4 (2026-09-30): o nível volta à linha, e hidrovia, barragem, corte e aterro viram atributo

Regerado sobre a Topo 2.0 v0.20.0. Justificativa na seção 1.8 do changelog da Topo 2.0.

| Mudança | Efeito no Orto 3.0 |
|---|---|
| `delimitador_limite_legal_l` volta a ter `tipo` (1 a 4) | a UF e o município voltam a se construir pelo nível da linha |
| `limite_legal` com o domínio `tipo_limite_legal` (1 a 4, 97) na drenagem, na margem, na via e na ferrovia | a marca passa a dizer o nível da divisa |
| `hidrovia`, `nome_hidrovia` e `calado_max_seca` em `elemnat_trecho_drenagem_l` | a hidrovia sobre o rio passa a ser atributo da drenagem; o Orto não tem a classe de hidrovia pura |
| `tipo_elemento_viario` 601, 602, 701 e 702, e o 23 (Terra) no material do elemento viário | barragem, dique, corte e aterro sob a via ou a ferrovia viram atributo do trecho |

Banco existente na 3.0.3: aplique o incremento 0.20.0 da seção 8 do changelog da Topo 2.0, sem as linhas de `llp_delimitacao_fisica_l` e de `infra_trecho_hidroviario_l` (classes que o Orto não tem) e sem as de `db_metadata`; o fecho é `UPDATE public.db_metadata SET dbimplversion = '3.0.4'`.
