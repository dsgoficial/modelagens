# EDGV Topo 2.0 — Changelog de modelagem (1.4 → 2.0)

Mudanças no schema de dados entre EDGV Topo 1.4 e EDGV Topo 2.0. Apenas modelagem (tabelas, colunas, domínios, constraints).

---

## 1. Novos atributos em tabelas existentes

### 1.1 Atributos com domínio (NOT NULL, DEFAULT 9999, FK)

#### `llp_limite_legal_l` (+1 coluna)

| Coluna | Tipo | FK | Descrição |
|--------|------|----|-----------|
| `em_litigio` | smallint | `dominios.booleano` | Fronteira disputada |

> Rev 0.13.0 (2026-07-10): a coluna `maritimo` (booleano) foi **removida**; o limite marítimo passou a ser codificado no `tipo_limite_legal` (ver seção 5, códigos 5/6/7) e o filtro do layer `limite-maritimo` migrou de `maritimo_texto` para `caso`.

### 1.2 Atributos numéricos (nullable, sem FK)

#### `elemnat_ponto_cotado_p` (+1 coluna)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `rank_zoom` | smallint | Rank de proeminência por grade para filtrar por zoom (1 = mais proeminente); calculado offline, à la `ordem_strahler` da drenagem |

#### `infra_elemento_viario_l` (+4 colunas)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `carga_suport_maxima` | real | Tonelagem máxima suportada |
| `gabarito_vertical` | real | Altura livre em metros (túnel, passagem sob viaduto) |
| `largura` | real | Largura da plataforma/estrutura em metros |
| `vao_livre` | real | Comprimento do maior vão de ponte em metros |

#### `infra_via_deslocamento_l` (+4 colunas)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `carga_suport_maxima` | real | Tonelagem máxima suportada (ponte/viaduto) |
| `gabarito_vertical` | real | Altura livre em metros (túnel, passagem sob viaduto) |
| `largura` | real | Largura da plataforma em metros |
| `vao_livre` | real | Comprimento do maior vão de ponte em metros |

#### `infra_ferrovia_l` (+4 colunas)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `carga_suport_maxima` | real | Tonelagem máxima suportada (ponte/viaduto ferroviário) |
| `gabarito_vertical` | real | Altura livre em metros (túnel ferroviário) |
| `largura` | real | Largura da plataforma ferroviária em metros |
| `vao_livre` | real | Comprimento do maior vão de ponte em metros |

#### `elemnat_trecho_drenagem_l` (+2 colunas)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `ordem_strahler` | smallint | Ordem de Strahler (hierarquia da rede de drenagem) |
| `largura` | real | Largura do curso d'água em metros |

#### `constr_edificacao_a`, `constr_edificacao_p`, `constr_deposito_a`, `constr_deposito_p` (+3 colunas cada)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `altura` | real | Altura acima do solo em metros |
| `pavimentos` | smallint | Número de pavimentos |
| `endereco` | varchar(255) | Endereço textual livre |

#### `edicao_texto_generico_p`, `_l` (+2 colunas cada)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id_feicao_origem` | uuid | `id` da feição que originou o texto. Referência polimórfica (sem FK, nullable): a feição pode estar em qualquer tabela `edgv` e o texto livre pode não apontar para nenhuma |
| `classe_feicao_origem` | varchar(255) | Classe (tabela) da feição de origem; junto com `id_feicao_origem`, rastreia o texto genérico de volta à feição que o originou |

### 1.3 Atributos removidos

#### `elemnat_toponimo_fisiografico_natural_l` (−2 colunas)

| Coluna | Tipo | Motivo |
|--------|------|--------|
| `label_x` | real | Removidas — posicionamento de label tratado por edição cartográfica, não pelo modelo |
| `label_y` | real | Removidas — posicionamento de label tratado por edição cartográfica, não pelo modelo|

#### `cobter_area_edificada_a` (−1 coluna)

| Coluna | Tipo | Motivo |
|--------|------|--------|
| `nome` | varchar(255) | Removida — área edificada não é entidade nomeada |

### 1.3 Rev 0.13.0 (2026-07-10)

Aporte do cruzamento com a ET-EDGV SPU 4.0 (ver `analysis/comparativo_edgvspu40_topo20.md`). Traz o calado da hidrovia (parte do gap 3.0 A1), por valor de logística fluvial e mobilidade anfíbia. A navegabilidade não entra como atributo: um trecho hidroviário é, por definição, navegável (o `cod_iso` do limite legal está documentado na seção 2, na classe `llp_limite_legal_a`).

| Tabela | Coluna | Tipo | FK / domínio | Descrição |
|--------|--------|------|--------------|-----------|
| `infra_trecho_hidroviario_l` | `calado_max_seca` | real | — | Calado máximo na seca em metros (EDGV 3.0 `caladomaxseca`) |

---

## 2. Novas tabelas

### `llp_localidade_a`

Polígono de localidades (mesmo schema de `llp_localidade_p`, com geometria MultiPolygon).

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `nome` | varchar(255) | nullable |
| `tipo` | smallint | NOT NULL, FK → `dominios.tipo_localidade`, DEFAULT 9999 |
| `populacao` | integer | nullable |
| `texto_edicao` | varchar(255) | nullable |
| `label_x` | real | nullable |
| `label_y` | real | nullable |
| `justificativa_txt` | smallint | NOT NULL, FK → `dominios.justificativa`, DEFAULT 9999 |
| `visivel` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `observacao` | varchar(255) | nullable |
| `geom` | MultiPolygon, 4674 | índice GiST |

### `llp_delimitacao_fisica_l`

Delimitações físicas — cercas e muros.

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `tipo` | smallint | NOT NULL, FK → `dominios.tipo_delimitacao_fisica`, DEFAULT 9999 |
| `material_construcao` | smallint | NOT NULL, FK → `dominios.material_construcao`, DEFAULT 9999 |
| `visivel` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `observacao` | varchar(255) | nullable |
| `geom` | MultiLinestring, 4674 | índice GiST |

### `llp_limite_legal_a`

Polígonos de limites político-administrativos unificados: país, UF, município e distrito. Absorve dados de `lml_pais_a`, `lml_unidade_federacao_a`, `lml_municipio_a` e `lml_distrito_a` da EDGV 3.0.

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `nome` | varchar(255) | nullable |
| `tipo` | smallint | NOT NULL, FK → `dominios.tipo_limite_legal`, DEFAULT 9999 |
| `sigla` | varchar(10) | nullable (ex: "BR", "SP") |
| `geocodigo_ibge` | varchar(15) | nullable (código IBGE: UF 2 dígitos, município 7, distrito 9) |
| `cod_iso` | varchar(3) | nullable (ISO 3166-1 alpha-3 do país; cobertura América do Sul; adicionado na rev 0.13.0, antes sobrecarregado em `sigla`) |
| `geometria_aproximada` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `observacao` | varchar(255) | nullable |
| `geom` | MultiPolygon, 4674 | índice GiST |

### `elemnat_curva_batimetrica_l`

Curvas batimétricas (profundidade subaquática). Espelha `elemnat_curva_nivel_l`. Origem: EDGV 3.0.

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `profundidade` | integer | nullable |
| `indice` | smallint | NOT NULL, FK → `dominios.indice`, DEFAULT 9999 |
| `geometria_aproximada` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `visivel` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `texto_edicao` | varchar(255) | nullable |
| `observacao` | varchar(255) | nullable |
| `geom` | MultiLinestring, 4674 | índice GiST |

### `elemnat_ponto_cotado_batimetrico_p`

Pontos cotados batimétricos (profundidade). Espelha `elemnat_ponto_cotado_p`. Origem: EDGV 3.0.

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `profundidade` | real | nullable |
| `geometria_aproximada` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `visivel` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `texto_edicao` | varchar(255) | nullable |
| `observacao` | varchar(255) | nullable |
| `geom` | MultiPoint, 4674 | índice GiST |

---

## 3. Tabelas removidas

### `infra_travessia_hidroviaria_p`

A travessia hidroviária passa a ser **linha-only** no Topo 2.0: a travessia é o percurso entre as margens, não um ponto. O domínio `tipo_travessia` (Balsa=1, Bote transportador=2) permanece inalterado, em `infra_travessia_hidroviaria_l`.

| Tabela | Motivo | Migração |
|--------|--------|----------|
| `infra_travessia_hidroviaria_p` | Classe linha-only — percurso margem a margem | Redigitalizar os pontos como linhas em `infra_travessia_hidroviaria_l` (mesmos atributos) antes do DROP |

---

## 4. Novos domínios

### `dominios.tipo_delimitacao_fisica`

| Código | Valor |
|--------|-------|
| 1 | Cerca |
| 2 | Muro |
| 9999 | A SER PREENCHIDO |

---

## 5. Novos valores em domínios existentes

### `dominios.tipo_limite_legal` (+5)

| Código | Valor |
|--------|-------|
| 3 | Limite Municipal |
| 4 | Limite Distrital |
| 5 | Mar Territorial (12 MN) |
| 6 | Zona Contígua (24 MN) |
| 7 | Zona Econômica Exclusiva (200 MN) |

> Códigos 5/6/7 na rev 0.13.0 (2026-07-10): substituem o antigo booleano `maritimo` (removido). MN = milhas náuticas.

### `dominios.tipo_via_deslocamento` (+2)

| Código | Valor |
|--------|-------|
| 0 | Desconhecido |
| 7 | Alça de acesso / Rotatória |

### `dominios.tipo_veg` (+3)

| Código | Valor |
|--------|-------|
| 1101 | Neve/Gelo |
| 1005 | Terreno exposto - crosta salina |
| 1200 | Vegetação arbustiva |

### `dominios.tipo_elemento_fisiografico` (+2)

| Código | Valor |
|--------|-------|
| 24 | Vulcão |
| 25 | Cratera |

Cobertura continental (a Topo 2.0 mapeia toda a América do Sul, não só o Brasil; o `tipo_veg` 1101 Neve/Gelo é o precedente): vulcão/cratera para o arco andino; crosta salina para o salar/planície salina do Altiplano-Atacama (distinta de `tipo_extracao_mineral`=6 Salina, que é extração antrópica); vegetação arbustiva (shrub) recebe WorldCover 20 Shrubland e Dynamic World 5 shrub_and_scrub, e volta à EDGV 3.0 como `veg_campo` + `classificacaoporte`=Arbustiva ("campo arbustivo"), sem perda.

### `dominios.tipo_elemento_viario` (+1)

| Código | Valor |
|--------|-------|
| 205 | Ponte flutuante |

### `dominios.tipo_ocupacao_solo` (+4, filter = 'Área verde pública')

| Código | Valor |
|--------|-------|
| 1401 | Praça |
| 1402 | Largo |
| 1403 | Jardim público |
| 1404 | Parque urbano |

### `dominios.tipo_elemento_infraestrutura` (+6, filter = 'Trecho de comunicação')

| Código | Valor |
|--------|-------|
| 1101 | Trecho de comunicação - Sinal de TV |
| 1102 | Trecho de comunicação - Dados |
| 1103 | Trecho de comunicação - Telefônica |
| 1104 | Trecho de comunicação - Cabo submarino |
| 1105 | Trecho de comunicação - Fibra óptica terrestre |
| 1198 | Trecho de comunicação - Outros |

### `dominios.tipo_edificacao` (+7)

| Código | Valor | Filtro |
|--------|-------|--------|
| 106 | Com - Datacenter | Edificação de comunicação |
| 107 | Com - Estação de aterrissagem de cabos | Edificação de comunicação |
| 2214 | Rod - Rodoviária | Edificação rodoviária |
| 2503 | Port - Base naval | Edificação portuária |
| 2504 | Port - Terminal de contêineres | Edificação portuária |
| 2505 | Port - Terminal de granéis | Edificação portuária |
| 3009 | Seg - Polícia Federal | Edificação de segurança pública |

### `dominios.tipo_edificacao` (+8, incremento 0.12.0)

| Código | Valor | Filtro |
|--------|-------|--------|
| 2102 | Ssoc – Equipamento público de proteção social | Edificação de desenvolvimento social |
| 2602 | Comb - Estação de compressão de gás | Infraestrutura de combustíveis |
| 2603 | Comb - Polo de processamento de gás | Infraestrutura de combustíveis |
| 2604 | Comb - Terminal de GNL/regaseificação | Infraestrutura de combustíveis |
| 2605 | Comb - Base de distribuição de combustíveis | Infraestrutura de combustíveis |
| 3010 | Seg - Defesa Civil | Edificação de segurança pública |
| 3011 | Seg - Perícia forense | Edificação de segurança pública |
| 3012 | Seg - Unidade socioeducativa | Edificação de segurança pública |

Origem: stress test do acervo GeoSwarm (256k feições) contra a 0.11.0
(propostas B1–B5, `geoswarm docs/propostas_modelagem_topo20.md`). Racional:
(a) o grupo 3xxx cobria PM/PC/PF/bombeiros/prisional mas não Defesa Civil,
perícia forense (IML/IGP) nem o sistema socioeducativo — todos distinguíveis
por fonte autoritativa (origem B); (b) a 2.0 ganhou os DUTOS de gás
(311/312) mas os NÓS da rede (compressão, processamento, GNL, base) caíam em
1023 "coque/refino" — a rede tinha linha e não tinha nó; (c) a rede estatal
SUAS (CRAS/CREAS/Conselho Tutelar, capilar como a UBS da saúde) dividia um
único 2101 com asilos privados e associações de moradores. Filtro novo
"Infraestrutura de combustíveis" agrupa 2602–2605 (o 2601 posto de
combustível mantém o filtro próprio). Nas fontes colaborativas quase nada
distingue esses códigos (OSM parcialmente: ver conversao_osm v1.4) — o
alimentador primário é a coleta autoritativa (GeoSwarm/insumos oficiais).

### `dominios.tipo_elemento_energia` (+2)

| Código | Valor |
|--------|-------|
| 410 | Estação geradora – Nuclear |
| 411 | Estação geradora – Biomassa |

### `dominios.tipo_trecho_duto` (+2)

| Código | Valor |
|--------|-------|
| 311 | Duto – Gás de transporte |
| 312 | Duto – Gás de distribuição |

### `dominios.tipo_localidade` (+3)

| Código | Valor |
|--------|-------|
| 9 | Aldeia indígena |
| 10 | Comunidade quilombola |
| 11 | Bairro |

> Rev 0.14.0 (2026-07-11): adicionado o código 11 `Bairro` (subdivisão intraurbana), alvo do subtype `neighborhood` do Overture divisions no mapeamento Overture -> EDGV Topo 2.0 (ver analysis/overture_referencia_e_mapeamento_topo20.md).

### `dominios.tipo_limite_especial` (+1)

| Código | Valor |
|--------|-------|
| 3 | Território quilombola |

### `dominios.tipo_alteracao_fisiografica` (+1)

| Código | Valor |
|--------|-------|
| 24 | Caixa de empréstimo |

### `dominios.posicao_relativa` (+1)

| Código | Valor |
|--------|-------|
| 0 | Desconhecido |

Adicionado para permitir preenchimento neutro quando fonte externa (OSM, Overture) não traz a posição relativa da feição (trecho_duto, ferrovia etc.).

---

## 6. CHECK constraints alterados

### 6.1 Expandidos

| Tabela | Coluna | Valores adicionados |
|--------|--------|---------------------|
| `infra_elemento_infraestrutura_l` | `tipo` | 1101, 1102, 1103, 1104, 1105, 1198 |
| `infra_elemento_viario_l` | `tipo` | 205 |
| `infra_ferrovia_l` | `tipo_elemento_viario` | 205 |
| `infra_via_deslocamento_l` | `tipo_elemento_viario` | 205 |
| `constr_ocupacao_solo_a` | `tipo` | 1401, 1402, 1403, 1404 |
| `elemnat_elemento_hidrografico_l` | `tipo` | 18 (Recife contíguo) |
| `infra_via_deslocamento_l` | `revestimento` | 0 (Desconhecido) — permite fallback neutro para dados externos |
| `infra_ferrovia_l` | `posicao_relativa` | 0 (Desconhecido) |
| `infra_via_deslocamento_l` | `administracao` | 3 (Municipal), 6 (Particular) — exclusão acidental no CHECK original; rodovias municipais e vicinais particulares agora permitidas |
| `elemnat_elemento_fisiografico_a` | `tipo` | 24, 25 (Vulcão, Cratera) |
| `elemnat_elemento_fisiografico_p` | `tipo` | 24, 25 (Vulcão, Cratera) |

### 6.2 Removidos

| Tabela | Coluna | Motivo |
|--------|--------|--------|
| `constr_deposito_a` / `_p` | `material_construcao` | CHECK removido — FK para domínio já garante integridade |
| `infra_via_deslocamento_l` | `jurisdicao` | CHECK removido — FK para domínio já garante integridade |

### 6.3 Correções de CHECKs com valores duplicados

Bug originado em `mastergen.py`: o gerador anexa `9999` aos valores do CHECK sem verificar se já está presente, produzindo duplicatas. Impacto funcional zero (ANY em array), mas inconsistência na DDL. O SQL versionado foi deduplado à mão; o gerador, porém, ainda reintroduz as duplicatas ao regenerar (o SQL da 0.11.0 foi aplicado preservando essa dedup). Corrigir o `mastergen.py` é pendência à parte.

| Tabela | Coluna | Antes | Depois |
|--------|--------|-------|--------|
| `constr_edificacao_p` | `material_construcao` | `{0,1,2,3,4,5,97,98,9999,9999}` | `{0,1,2,3,4,5,97,98,9999}` |
| `infra_barragem_a` | `material_construcao` | `{0,1,2,3,4,5,23,9999,9999}` | `{0,1,2,3,4,5,23,9999}` |
| `infra_pista_pouso_l` | `revestimento` | `9999` duplicado | dedup |
| `infra_pista_pouso_p` | `revestimento` | `9999` triplicado | dedup |

### 6.4 FKs alteradas

| Tabela | Coluna | FK antes | FK depois | Motivo |
|--------|--------|----------|-----------|--------|
| `infra_via_deslocamento_l` | `canteiro_divisorio` | `dominios.booleano` {1,2,9999} | `dominios.auxiliar` {0,1,2,9999} | Permite valor 0 (Desconhecido) quando fonte externa não informa presença de canteiro |

---

## 7. Metadados

| Campo | 1.4 | 2.0 |
|-------|-----|-----|
| `edgvversion` | EDGV 3.0 Topo | EDGV Topo 2.0 |
| `dbimplversion` | 1.4.4 | 0.13.0 |

---

## 8. DDL de migração (1.4 → 2.0)

```sql
-- ===========================================
-- Novos atributos em tabelas existentes
-- ===========================================

-- llp_limite_legal_l: em_litigio, maritimo (NOT NULL, FK booleano)
ALTER TABLE edgv.llp_limite_legal_l ADD COLUMN em_litigio smallint NOT NULL DEFAULT 9999;
ALTER TABLE edgv.llp_limite_legal_l ADD COLUMN maritimo smallint NOT NULL DEFAULT 9999;
ALTER TABLE edgv.llp_limite_legal_l
    ADD CONSTRAINT llp_limite_legal_l_em_litigio_fk
    FOREIGN KEY (em_litigio) REFERENCES dominios.booleano (code);
ALTER TABLE edgv.llp_limite_legal_l
    ADD CONSTRAINT llp_limite_legal_l_maritimo_fk
    FOREIGN KEY (maritimo) REFERENCES dominios.booleano (code);

-- elemnat_ponto_cotado_p: rank_zoom (rank de proeminencia para filtrar por zoom; nullable, calculado offline)
ALTER TABLE edgv.elemnat_ponto_cotado_p ADD COLUMN rank_zoom smallint;

-- cobter_area_edificada_a: remocao de nome (area edificada nao e entidade nomeada)
ALTER TABLE edgv.cobter_area_edificada_a DROP COLUMN nome;

-- Novos valores de dominio (0.10.0)
INSERT INTO dominios.tipo_veg (code, code_name, filter) VALUES (1101, 'Neve/Gelo (1101)', 'Neve e Gelo');
INSERT INTO dominios.tipo_via_deslocamento (code, code_name) VALUES (0, 'Desconhecido (0)');

-- infra_elemento_viario_l: carga_suport_maxima, gabarito_vertical, largura, vao_livre
ALTER TABLE edgv.infra_elemento_viario_l ADD COLUMN carga_suport_maxima real;
ALTER TABLE edgv.infra_elemento_viario_l ADD COLUMN gabarito_vertical real;
ALTER TABLE edgv.infra_elemento_viario_l ADD COLUMN largura real;
ALTER TABLE edgv.infra_elemento_viario_l ADD COLUMN vao_livre real;

-- infra_via_deslocamento_l: carga_suport_maxima, gabarito_vertical, largura, vao_livre
ALTER TABLE edgv.infra_via_deslocamento_l ADD COLUMN carga_suport_maxima real;
ALTER TABLE edgv.infra_via_deslocamento_l ADD COLUMN gabarito_vertical real;
ALTER TABLE edgv.infra_via_deslocamento_l ADD COLUMN largura real;
ALTER TABLE edgv.infra_via_deslocamento_l ADD COLUMN vao_livre real;

-- infra_ferrovia_l: carga_suport_maxima, gabarito_vertical, largura, vao_livre
ALTER TABLE edgv.infra_ferrovia_l ADD COLUMN carga_suport_maxima real;
ALTER TABLE edgv.infra_ferrovia_l ADD COLUMN gabarito_vertical real;
ALTER TABLE edgv.infra_ferrovia_l ADD COLUMN largura real;
ALTER TABLE edgv.infra_ferrovia_l ADD COLUMN vao_livre real;

-- elemnat_trecho_drenagem_l: ordem_strahler, largura
ALTER TABLE edgv.elemnat_trecho_drenagem_l ADD COLUMN ordem_strahler smallint;
ALTER TABLE edgv.elemnat_trecho_drenagem_l ADD COLUMN largura real;

-- constr_edificacao_a/p, constr_deposito_a/p: altura, pavimentos, endereco
ALTER TABLE edgv.constr_edificacao_a ADD COLUMN altura real;
ALTER TABLE edgv.constr_edificacao_a ADD COLUMN pavimentos smallint;
ALTER TABLE edgv.constr_edificacao_a ADD COLUMN endereco varchar(255);
ALTER TABLE edgv.constr_edificacao_p ADD COLUMN altura real;
ALTER TABLE edgv.constr_edificacao_p ADD COLUMN pavimentos smallint;
ALTER TABLE edgv.constr_edificacao_p ADD COLUMN endereco varchar(255);
ALTER TABLE edgv.constr_deposito_a ADD COLUMN altura real;
ALTER TABLE edgv.constr_deposito_a ADD COLUMN pavimentos smallint;
ALTER TABLE edgv.constr_deposito_a ADD COLUMN endereco varchar(255);
ALTER TABLE edgv.constr_deposito_p ADD COLUMN altura real;
ALTER TABLE edgv.constr_deposito_p ADD COLUMN pavimentos smallint;
ALTER TABLE edgv.constr_deposito_p ADD COLUMN endereco varchar(255);

-- edicao_texto_generico_p/_l: id_feicao_origem, classe_feicao_origem (referência polimórfica à feição de origem)
ALTER TABLE edgv.edicao_texto_generico_p ADD COLUMN id_feicao_origem uuid;
ALTER TABLE edgv.edicao_texto_generico_p ADD COLUMN classe_feicao_origem varchar(255);
ALTER TABLE edgv.edicao_texto_generico_l ADD COLUMN id_feicao_origem uuid;
ALTER TABLE edgv.edicao_texto_generico_l ADD COLUMN classe_feicao_origem varchar(255);

-- elemnat_toponimo_fisiografico_natural_l: remover label_x, label_y
ALTER TABLE edgv.elemnat_toponimo_fisiografico_natural_l DROP COLUMN label_x;
ALTER TABLE edgv.elemnat_toponimo_fisiografico_natural_l DROP COLUMN label_y;

-- ===========================================
-- Novos domínios
-- ===========================================

CREATE TABLE dominios.tipo_delimitacao_fisica (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT tipo_delimitacao_fisica_pk PRIMARY KEY (code)
);
INSERT INTO dominios.tipo_delimitacao_fisica (code, code_name) VALUES
    (1, 'Cerca (1)'),
    (2, 'Muro (2)'),
    (9999, 'A SER PREENCHIDO (9999)');

-- ===========================================
-- Novos valores em domínios existentes
-- ===========================================

INSERT INTO dominios.tipo_limite_legal (code, code_name) VALUES
    (3, 'Limite Municipal (3)'),
    (4, 'Limite Distrital (4)');

INSERT INTO dominios.tipo_via_deslocamento (code, code_name) VALUES
    (7, 'Alça de acesso / Rotatória (7)');

INSERT INTO dominios.tipo_elemento_viario (code, code_name, filter) VALUES
    (205, 'Ponte flutuante (205)', 'Ponte');

INSERT INTO dominios.tipo_ocupacao_solo (code, code_name, filter) VALUES
    (1401, 'Praça (1401)', 'Área verde pública'),
    (1402, 'Largo (1402)', 'Área verde pública'),
    (1403, 'Jardim público (1403)', 'Área verde pública'),
    (1404, 'Parque urbano (1404)', 'Área verde pública');

INSERT INTO dominios.tipo_elemento_infraestrutura (code, code_name, filter) VALUES
    (1101, 'Trecho de comunicação - Sinal de TV (1101)', 'Trecho de comunicação'),
    (1102, 'Trecho de comunicação - Dados (1102)', 'Trecho de comunicação'),
    (1103, 'Trecho de comunicação - Telefônica (1103)', 'Trecho de comunicação'),
    (1104, 'Trecho de comunicação - Cabo submarino (1104)', 'Trecho de comunicação'),
    (1105, 'Trecho de comunicação - Fibra óptica terrestre (1105)', 'Trecho de comunicação'),
    (1198, 'Trecho de comunicação - Outros (1198)', 'Trecho de comunicação');

INSERT INTO dominios.tipo_edificacao (code, code_name, filter) VALUES
    (106, 'Com - Datacenter (106)', 'Edificação de comunicação'),
    (107, 'Com - Estação de aterrissagem de cabos (107)', 'Edificação de comunicação'),
    (2214, 'Rod - Rodoviária (2214)', 'Edificação rodoviária'),
    (2503, 'Port - Base naval (2503)', 'Edificação portuária'),
    (2504, 'Port - Terminal de contêineres (2504)', 'Edificação portuária'),
    (2505, 'Port - Terminal de granéis (2505)', 'Edificação portuária'),
    (3009, 'Seg - Polícia Federal (3009)', 'Edificação de segurança pública');

INSERT INTO dominios.tipo_elemento_energia (code, code_name, filter) VALUES
    (410, 'Estação geradora – Nuclear (410)', 'Estação geradora de energia'),
    (411, 'Estação geradora – Biomassa (411)', 'Estação geradora de energia');

INSERT INTO dominios.tipo_trecho_duto (code, code_name, filter) VALUES
    (311, 'Duto – Gás de transporte (311)', 'Duto'),
    (312, 'Duto – Gás de distribuição (312)', 'Duto');

INSERT INTO dominios.tipo_localidade (code, code_name) VALUES
    (9, 'Aldeia indígena (9)'),
    (10, 'Comunidade quilombola (10)'),
    (11, 'Bairro (11)');

INSERT INTO dominios.tipo_limite_especial (code, code_name) VALUES
    (3, 'Território quilombola (3)');

INSERT INTO dominios.tipo_alteracao_fisiografica (code, code_name) VALUES
    (24, 'Caixa de empréstimo (24)');

-- ===========================================
-- Novas tabelas
-- ===========================================

CREATE TABLE edgv.llp_localidade_a (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    nome varchar(255),
    tipo smallint NOT NULL DEFAULT 9999,
    populacao integer,
    texto_edicao varchar(255),
    label_x real,
    label_y real,
    justificativa_txt smallint NOT NULL DEFAULT 9999,
    visivel smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    geom geometry(MultiPolygon, 4674),
    CONSTRAINT llp_localidade_a_pk PRIMARY KEY (id) WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_localidade_a_geom ON edgv.llp_localidade_a USING gist (geom);
ALTER TABLE edgv.llp_localidade_a ADD CONSTRAINT llp_localidade_a_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_localidade (code);
ALTER TABLE edgv.llp_localidade_a ADD CONSTRAINT llp_localidade_a_justificativa_txt_fk
    FOREIGN KEY (justificativa_txt) REFERENCES dominios.justificativa (code);
ALTER TABLE edgv.llp_localidade_a ADD CONSTRAINT llp_localidade_a_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);

CREATE TABLE edgv.llp_delimitacao_fisica_l (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    tipo smallint NOT NULL DEFAULT 9999,
    material_construcao smallint NOT NULL DEFAULT 9999,
    visivel smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    geom geometry(MultiLinestring, 4674),
    CONSTRAINT llp_delimitacao_fisica_l_pk PRIMARY KEY (id) WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_delimitacao_fisica_l_geom ON edgv.llp_delimitacao_fisica_l USING gist (geom);
ALTER TABLE edgv.llp_delimitacao_fisica_l ADD CONSTRAINT llp_delimitacao_fisica_l_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_delimitacao_fisica (code);
ALTER TABLE edgv.llp_delimitacao_fisica_l ADD CONSTRAINT llp_delimitacao_fisica_l_material_construcao_fk
    FOREIGN KEY (material_construcao) REFERENCES dominios.material_construcao (code);
ALTER TABLE edgv.llp_delimitacao_fisica_l ADD CONSTRAINT llp_delimitacao_fisica_l_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);
ALTER TABLE edgv.llp_delimitacao_fisica_l
    ADD CONSTRAINT llp_delimitacao_fisica_l_material_construcao_check
    CHECK (material_construcao = ANY(ARRAY[0, 1, 2, 3, 4, 5, 9, 23, 98, 9999]::SMALLINT[]));

CREATE TABLE edgv.llp_limite_legal_a (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    nome varchar(255),
    tipo smallint NOT NULL DEFAULT 9999,
    sigla varchar(10),
    geocodigo_ibge varchar(15),
    populacao integer,
    geometria_aproximada smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    geom geometry(MultiPolygon, 4674),
    CONSTRAINT llp_limite_legal_a_pk PRIMARY KEY (id) WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_limite_legal_a_geom ON edgv.llp_limite_legal_a USING gist (geom);
ALTER TABLE edgv.llp_limite_legal_a ADD CONSTRAINT llp_limite_legal_a_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_limite_legal (code);
ALTER TABLE edgv.llp_limite_legal_a ADD CONSTRAINT llp_limite_legal_a_geometria_aproximada_fk
    FOREIGN KEY (geometria_aproximada) REFERENCES dominios.booleano (code);

CREATE TABLE edgv.elemnat_curva_batimetrica_l (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    profundidade integer,
    indice smallint NOT NULL DEFAULT 9999,
    geometria_aproximada smallint NOT NULL DEFAULT 9999,
    visivel smallint NOT NULL DEFAULT 9999,
    texto_edicao varchar(255),
    observacao varchar(255),
    geom geometry(MultiLinestring, 4674),
    CONSTRAINT elemnat_curva_batimetrica_l_pk PRIMARY KEY (id) WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_curva_batimetrica_l_geom ON edgv.elemnat_curva_batimetrica_l USING gist (geom);
ALTER TABLE edgv.elemnat_curva_batimetrica_l ADD CONSTRAINT elemnat_curva_batimetrica_l_indice_fk
    FOREIGN KEY (indice) REFERENCES dominios.indice (code);
ALTER TABLE edgv.elemnat_curva_batimetrica_l ADD CONSTRAINT elemnat_curva_batimetrica_l_geometria_aproximada_fk
    FOREIGN KEY (geometria_aproximada) REFERENCES dominios.booleano (code);
ALTER TABLE edgv.elemnat_curva_batimetrica_l ADD CONSTRAINT elemnat_curva_batimetrica_l_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);

CREATE TABLE edgv.elemnat_ponto_cotado_batimetrico_p (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    profundidade real,
    geometria_aproximada smallint NOT NULL DEFAULT 9999,
    visivel smallint NOT NULL DEFAULT 9999,
    texto_edicao varchar(255),
    observacao varchar(255),
    geom geometry(MultiPoint, 4674),
    CONSTRAINT elemnat_ponto_cotado_batimetrico_p_pk PRIMARY KEY (id) WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_ponto_cotado_batimetrico_p_geom ON edgv.elemnat_ponto_cotado_batimetrico_p USING gist (geom);
ALTER TABLE edgv.elemnat_ponto_cotado_batimetrico_p ADD CONSTRAINT elemnat_ponto_cotado_batimetrico_p_geometria_aproximada_fk
    FOREIGN KEY (geometria_aproximada) REFERENCES dominios.booleano (code);
ALTER TABLE edgv.elemnat_ponto_cotado_batimetrico_p ADD CONSTRAINT elemnat_ponto_cotado_batimetrico_p_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);

-- ===========================================
-- CHECK constraints expandidos
-- ===========================================

ALTER TABLE edgv.infra_elemento_infraestrutura_l
    DROP CONSTRAINT infra_elemento_infraestrutura_l_tipo_check;
ALTER TABLE edgv.infra_elemento_infraestrutura_l
    ADD CONSTRAINT infra_elemento_infraestrutura_l_tipo_check
    CHECK (tipo = ANY(ARRAY[607, 608, 609, 701, 801, 901, 1001,
        1101, 1102, 1103, 1104, 1105, 1198,
        1501, 1601, 1938, 1939, 1940, 1941, 1942, 1943, 1944,
        2001, 2098, 9999]::SMALLINT[]));

ALTER TABLE edgv.infra_elemento_viario_l
    DROP CONSTRAINT infra_elemento_viario_l_tipo_check;
ALTER TABLE edgv.infra_elemento_viario_l
    ADD CONSTRAINT infra_elemento_viario_l_tipo_check
    CHECK (tipo = ANY(ARRAY[101, 102, 201, 202, 203, 204, 205,
        301, 302, 401, 402, 501, 9999]::SMALLINT[]));

ALTER TABLE edgv.infra_ferrovia_l
    DROP CONSTRAINT infra_ferrovia_l_tipo_elemento_viario_check;
ALTER TABLE edgv.infra_ferrovia_l
    ADD CONSTRAINT infra_ferrovia_l_tipo_elemento_viario_check
    CHECK (tipo_elemento_viario = ANY(ARRAY[101, 102, 201, 202, 203, 204, 205,
        301, 302, 97, 9999]::SMALLINT[]));

ALTER TABLE edgv.infra_via_deslocamento_l
    DROP CONSTRAINT infra_via_deslocamento_l_tipo_elemento_viario_check;
ALTER TABLE edgv.infra_via_deslocamento_l
    ADD CONSTRAINT infra_via_deslocamento_l_tipo_elemento_viario_check
    CHECK (tipo_elemento_viario = ANY(ARRAY[101, 102, 201, 202, 203, 204, 205,
        301, 302, 401, 402, 97, 9999]::SMALLINT[]));

-- ===========================================
-- Correções de constraints
-- ===========================================

-- infra_pista_pouso_l: remover 9999 duplicado do CHECK de revestimento
ALTER TABLE edgv.infra_pista_pouso_l
    DROP CONSTRAINT infra_pista_pouso_l_revestimento_check;
ALTER TABLE edgv.infra_pista_pouso_l
    ADD CONSTRAINT infra_pista_pouso_l_revestimento_check
    CHECK (revestimento = ANY(ARRAY[0, 1, 2, 3, 9999]::SMALLINT[]));

-- infra_pista_pouso_p: remover 9999 triplicado do CHECK de revestimento
ALTER TABLE edgv.infra_pista_pouso_p
    DROP CONSTRAINT infra_pista_pouso_p_revestimento_check;
ALTER TABLE edgv.infra_pista_pouso_p
    ADD CONSTRAINT infra_pista_pouso_p_revestimento_check
    CHECK (revestimento = ANY(ARRAY[0, 1, 2, 3, 9999]::SMALLINT[]));

-- constr_ocupacao_solo_a: expandir CHECK para tipo (+1401-1404)
ALTER TABLE edgv.constr_ocupacao_solo_a
    DROP CONSTRAINT constr_ocupacao_solo_a_tipo_check;
ALTER TABLE edgv.constr_ocupacao_solo_a
    ADD CONSTRAINT constr_ocupacao_solo_a_tipo_check
    CHECK (tipo = ANY(ARRAY[101, 102, 103, 104, 105, 106, 107, 108,
        201, 202, 203, 204, 205, 206, 207, 298,
        404, 405, 406, 409, 414, 415, 416,
        501, 601, 701,
        801, 802, 804, 803, 805, 806,
        901, 1001, 1201, 1202,
        1401, 1402, 1403, 1404,
        9999]::SMALLINT[]));

-- elemnat_elemento_hidrografico_l: expandir CHECK para tipo (+18)
ALTER TABLE edgv.elemnat_elemento_hidrografico_l
    DROP CONSTRAINT elemnat_elemento_hidrografico_l_tipo_check;
ALTER TABLE edgv.elemnat_elemento_hidrografico_l
    ADD CONSTRAINT elemnat_elemento_hidrografico_l_tipo_check
    CHECK (tipo = ANY(ARRAY[6, 9, 10, 11, 12, 18, 9999]::SMALLINT[]));

-- constr_deposito_a/p: remover CHECK de material_construcao (FK já garante integridade)
ALTER TABLE edgv.constr_deposito_a
    DROP CONSTRAINT constr_deposito_a_material_construcao_check;
ALTER TABLE edgv.constr_deposito_p
    DROP CONSTRAINT constr_deposito_p_material_construcao_check;

-- infra_via_deslocamento_l: remover CHECK de jurisdicao (FK já garante integridade)
ALTER TABLE edgv.infra_via_deslocamento_l
    DROP CONSTRAINT infra_via_deslocamento_l_jurisdicao_check;

-- dominios.posicao_relativa: adicionar 0 (Desconhecido) para fallback de dados externos
INSERT INTO dominios.posicao_relativa (code, code_name) VALUES (0, 'Desconhecido (0)')
    ON CONFLICT DO NOTHING;

-- infra_ferrovia_l.posicao_relativa: incluir 0 no CHECK
ALTER TABLE edgv.infra_ferrovia_l
    DROP CONSTRAINT infra_ferrovia_l_posicao_relativa_check;
ALTER TABLE edgv.infra_ferrovia_l
    ADD CONSTRAINT infra_ferrovia_l_posicao_relativa_check
    CHECK (posicao_relativa = ANY(ARRAY[0, 2, 3, 6, 9999]::SMALLINT[]));

-- infra_via_deslocamento_l.revestimento: incluir 0 no CHECK
ALTER TABLE edgv.infra_via_deslocamento_l
    DROP CONSTRAINT infra_via_deslocamento_l_revestimento_check;
ALTER TABLE edgv.infra_via_deslocamento_l
    ADD CONSTRAINT infra_via_deslocamento_l_revestimento_check
    CHECK (revestimento = ANY(ARRAY[0, 1, 2, 3, 4, 9999]::SMALLINT[]));

-- infra_via_deslocamento_l.administracao: incluir 3 (Municipal) e 6 (Particular), antes excluídos por bug
ALTER TABLE edgv.infra_via_deslocamento_l
    DROP CONSTRAINT infra_via_deslocamento_l_administracao_check;
ALTER TABLE edgv.infra_via_deslocamento_l
    ADD CONSTRAINT infra_via_deslocamento_l_administracao_check
    CHECK (administracao = ANY(ARRAY[0, 1, 2, 3, 6, 7, 9999]::SMALLINT[]));

-- infra_via_deslocamento_l.canteiro_divisorio: trocar FK booleano -> auxiliar (permite 0 = Desconhecido)
ALTER TABLE edgv.infra_via_deslocamento_l
    DROP CONSTRAINT infra_via_deslocamento_l_canteiro_divisorio_fk;
ALTER TABLE edgv.infra_via_deslocamento_l
    ADD CONSTRAINT infra_via_deslocamento_l_canteiro_divisorio_fk
    FOREIGN KEY (canteiro_divisorio) REFERENCES dominios.auxiliar (code);

-- Dedup de CHECKs com 9999 duplicado (bug em mastergen.py, já corrigido)
ALTER TABLE edgv.constr_edificacao_p
    DROP CONSTRAINT constr_edificacao_p_material_construcao_check;
ALTER TABLE edgv.constr_edificacao_p
    ADD CONSTRAINT constr_edificacao_p_material_construcao_check
    CHECK (material_construcao = ANY(ARRAY[0, 1, 2, 3, 4, 5, 97, 98, 9999]::SMALLINT[]));

ALTER TABLE edgv.infra_barragem_a
    DROP CONSTRAINT infra_barragem_a_material_construcao_check;
ALTER TABLE edgv.infra_barragem_a
    ADD CONSTRAINT infra_barragem_a_material_construcao_check
    CHECK (material_construcao = ANY(ARRAY[0, 1, 2, 3, 4, 5, 23, 9999]::SMALLINT[]));

-- Typo em domínio
UPDATE dominios.tipo_area_uso_especifico
    SET code_name = 'Área relacionada a edificação de ensino (6)'
    WHERE code = 6;

-- ===========================================
-- Tabelas removidas
-- ===========================================

-- infra_travessia_hidroviaria_p: classe passa a ser linha-only no Topo 2.0.
-- Travessias ponto devem ser redigitalizadas como linha (margem a margem)
-- em infra_travessia_hidroviaria_l ANTES do DROP. Backup opcional:
-- CREATE TABLE backup.infra_travessia_hidroviaria_p AS
--     SELECT * FROM edgv.infra_travessia_hidroviaria_p;
DROP TABLE IF EXISTS edgv.infra_travessia_hidroviaria_p;

-- ===========================================
-- Versão
-- ===========================================
ALTER TABLE public.db_metadata DROP CONSTRAINT edgvversioncheck;
UPDATE public.db_metadata SET edgvversion = 'EDGV Topo 2.0', dbimplversion = '0.9.1';
ALTER TABLE public.db_metadata ALTER COLUMN edgvversion SET DEFAULT 'EDGV Topo 2.0';
ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '0.9.1';
ALTER TABLE public.db_metadata
    ADD CONSTRAINT edgvversioncheck CHECK (edgvversion = 'EDGV Topo 2.0');

-- ===========================================
-- Incremento 0.11.0: cobertura continental America do Sul
-- (vulcao/cratera, crosta salina/salar, vegetacao arbustiva)
-- ===========================================
INSERT INTO dominios.tipo_elemento_fisiografico (code, code_name) VALUES
    (24, 'Vulcão (24)'),
    (25, 'Cratera (25)');
INSERT INTO dominios.tipo_veg (code, code_name, filter) VALUES
    (1005, 'Terreno exposto - crosta salina (1005)', 'Terreno Exposto'),
    (1200, 'Vegetação arbustiva (1200)', 'Vegetação Arbustiva');

ALTER TABLE edgv.elemnat_elemento_fisiografico_a DROP CONSTRAINT elemnat_elemento_fisiografico_a_tipo_check;
ALTER TABLE edgv.elemnat_elemento_fisiografico_a ADD CONSTRAINT elemnat_elemento_fisiografico_a_tipo_check
    CHECK (tipo = ANY(ARRAY[15, 16, 21, 22, 23, 24, 25, 9999]::SMALLINT[]));
ALTER TABLE edgv.elemnat_elemento_fisiografico_p DROP CONSTRAINT elemnat_elemento_fisiografico_p_tipo_check;
ALTER TABLE edgv.elemnat_elemento_fisiografico_p ADD CONSTRAINT elemnat_elemento_fisiografico_p_tipo_check
    CHECK (tipo = ANY(ARRAY[15, 16, 19, 20, 21, 22, 24, 25, 9999]::SMALLINT[]));

UPDATE public.db_metadata SET dbimplversion = '0.11.0';
ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '0.11.0';

-- ===========================================
-- Incremento 0.12.0: codigos B1-B5 do stress test GeoSwarm
-- (defesa civil, pericia forense, socioeducativo, nos de gas, SUAS)
-- constr_edificacao nao tem CHECK de tipo (so FK) -- basta o INSERT no dominio
-- ===========================================
INSERT INTO dominios.tipo_edificacao (code, code_name, filter) VALUES
    (2102, 'Ssoc – Equipamento público de proteção social (2102)', 'Edificação de desenvolvimento social'),
    (2602, 'Comb - Estação de compressão de gás (2602)', 'Infraestrutura de combustíveis'),
    (2603, 'Comb - Polo de processamento de gás (2603)', 'Infraestrutura de combustíveis'),
    (2604, 'Comb - Terminal de GNL/regaseificação (2604)', 'Infraestrutura de combustíveis'),
    (2605, 'Comb - Base de distribuição de combustíveis (2605)', 'Infraestrutura de combustíveis'),
    (3010, 'Seg - Defesa Civil (3010)', 'Edificação de segurança pública'),
    (3011, 'Seg - Perícia forense (3011)', 'Edificação de segurança pública'),
    (3012, 'Seg - Unidade socioeducativa (3012)', 'Edificação de segurança pública');

UPDATE public.db_metadata SET dbimplversion = '0.12.0';
ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '0.12.0';

-- ===========================================
-- Incremento 0.13.0: cruzamento com a ET-EDGV SPU 4.0
-- (limites maritimos como tipo; calado da hidrovia; ISO do pais)
-- ===========================================

-- 1) Limite maritimo vira tipo; remove o booleano `maritimo`
INSERT INTO dominios.tipo_limite_legal (code, code_name) VALUES
    (5, 'Mar Territorial (12 MN) (5)'),
    (6, 'Zona Contígua (24 MN) (6)'),
    (7, 'Zona Econômica Exclusiva (200 MN) (7)');

ALTER TABLE edgv.llp_limite_legal_l DROP CONSTRAINT IF EXISTS llp_limite_legal_l_maritimo_fk;
ALTER TABLE edgv.llp_limite_legal_l DROP COLUMN IF EXISTS maritimo;

-- 2) Calado da hidrovia (parte do gap 3.0 A1; navegabilidade nao entra, e redundante)
ALTER TABLE edgv.infra_trecho_hidroviario_l ADD COLUMN calado_max_seca real;

-- 3) Codigo ISO 3166-1 alpha-3 do pais
ALTER TABLE edgv.llp_limite_legal_a ADD COLUMN cod_iso varchar(3);

UPDATE public.db_metadata SET dbimplversion = '0.13.0';
ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '0.13.0';
```
