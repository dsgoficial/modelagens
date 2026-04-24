# EDGV Topo 2.0 — Changelog de modelagem (1.4 → 2.0)

Mudanças no schema de dados entre EDGV Topo 1.4 e EDGV Topo 2.0. Apenas modelagem (tabelas, colunas, domínios, constraints).

---

## 1. Novos atributos em tabelas existentes

### 1.1 Atributos com domínio (NOT NULL, DEFAULT 9999, FK)

#### `llp_limite_legal_l` (+2 colunas)

| Coluna | Tipo | FK | Descrição |
|--------|------|----|-----------|
| `em_litigio` | smallint | `dominios.booleano` | Fronteira disputada |
| `maritimo` | smallint | `dominios.booleano` | Limite marítimo |

### 1.2 Atributos numéricos (nullable, sem FK)

#### `infra_elemento_energia_l`, `_p`, `_a` (+1 coluna cada)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `tensao_kv` | integer | Tensão da linha de transmissão em kV |

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

### 1.3 Atributos removidos

#### `elemnat_toponimo_fisiografico_natural_l` (−2 colunas)

| Coluna | Tipo | Motivo |
|--------|------|--------|
| `label_x` | real | Removidas — posicionamento de label tratado por edição cartográfica, não pelo modelo |
| `label_y` | real | Removidas — posicionamento de label tratado por edição cartográfica, não pelo modelo|

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

### `infra_obstaculo_terrestre_p`, `_l`, `_a`

Obstáculos terrestres de interesse militar. Três geometrias (ponto, linha, polígono).

| Coluna | Tipo | Constraints |
|--------|------|-------------|
| `id` | uuid | PK, DEFAULT uuid_generate_v4() |
| `nome` | varchar(255) | nullable |
| `tipo` | smallint | NOT NULL, FK → `dominios.tipo_obstaculo_terrestre`, DEFAULT 9999 |
| `observacao` | varchar(255) | nullable |
| `visivel` | smallint | NOT NULL, FK → `dominios.booleano`, DEFAULT 9999 |
| `texto_edicao` | varchar(255) | nullable |
| `geom` | Multi*, 4674 | índice GiST |

---

## 3. Novos domínios

### `dominios.tipo_delimitacao_fisica`

| Código | Valor |
|--------|-------|
| 1 | Cerca |
| 2 | Muro |
| 9999 | A SER PREENCHIDO |

### `dominios.tipo_obstaculo_terrestre`

| Código | Valor |
|--------|-------|
| 1 | Antitanque |
| 2 | Arame / Concertina |
| 3 | Barreira veicular |
| 4 | Campo minado |
| 9999 | A SER PREENCHIDO |

---

## 4. Novos valores em domínios existentes

### `dominios.tipo_limite_legal` (+2)

| Código | Valor |
|--------|-------|
| 3 | Limite Municipal |
| 4 | Limite Distrital |

### `dominios.tipo_via_deslocamento` (+1)

| Código | Valor |
|--------|-------|
| 7 | Alça de acesso / Rotatória |

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

### `dominios.tipo_localidade` (+2)

| Código | Valor |
|--------|-------|
| 9 | Aldeia indígena |
| 10 | Comunidade quilombola |

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

## 5. CHECK constraints alterados

### 5.1 Expandidos

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

### 5.2 Removidos

| Tabela | Coluna | Motivo |
|--------|--------|--------|
| `constr_deposito_a` / `_p` | `material_construcao` | CHECK removido — FK para domínio já garante integridade |
| `infra_via_deslocamento_l` | `jurisdicao` | CHECK removido — FK para domínio já garante integridade |

### 5.3 Correções de CHECKs com valores duplicados

Bug originado em `mastergen.py` (já corrigido): o gerador anexava `9999` aos valores do CHECK sem verificar se já estava presente, produzindo duplicatas. Impacto funcional zero (ANY em array), mas inconsistência na DDL.

| Tabela | Coluna | Antes | Depois |
|--------|--------|-------|--------|
| `constr_edificacao_p` | `material_construcao` | `{0,1,2,3,4,5,97,98,9999,9999}` | `{0,1,2,3,4,5,97,98,9999}` |
| `infra_barragem_a` | `material_construcao` | `{0,1,2,3,4,5,23,9999,9999}` | `{0,1,2,3,4,5,23,9999}` |
| `infra_pista_pouso_l` | `revestimento` | `9999` duplicado | dedup |
| `infra_pista_pouso_p` | `revestimento` | `9999` triplicado | dedup |

### 5.4 FKs alteradas

| Tabela | Coluna | FK antes | FK depois | Motivo |
|--------|--------|----------|-----------|--------|
| `infra_via_deslocamento_l` | `canteiro_divisorio` | `dominios.booleano` {1,2,9999} | `dominios.auxiliar` {0,1,2,9999} | Permite valor 0 (Desconhecido) quando fonte externa não informa presença de canteiro |

---

## 6. Metadados

| Campo | 1.4 | 2.0 |
|-------|-----|-----|
| `edgvversion` | EDGV 3.0 Topo | EDGV Topo 2.0 |
| `dbimplversion` | 1.4.4 | 0.9.1 |

---

## 7. DDL de migração (1.4 → 2.0)

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

-- infra_elemento_energia_l/_p/_a: tensao_kv
ALTER TABLE edgv.infra_elemento_energia_l ADD COLUMN tensao_kv integer;
ALTER TABLE edgv.infra_elemento_energia_p ADD COLUMN tensao_kv integer;
ALTER TABLE edgv.infra_elemento_energia_a ADD COLUMN tensao_kv integer;

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

CREATE TABLE dominios.tipo_obstaculo_terrestre (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT tipo_obstaculo_terrestre_pk PRIMARY KEY (code)
);
INSERT INTO dominios.tipo_obstaculo_terrestre (code, code_name) VALUES
    (1, 'Antitanque (1)'),
    (2, 'Arame / Concertina (2)'),
    (3, 'Barreira veicular (3)'),
    (4, 'Campo minado (4)'),
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
    (10, 'Comunidade quilombola (10)');

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

CREATE TABLE edgv.infra_obstaculo_terrestre_p (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    nome varchar(255),
    tipo smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    visivel smallint NOT NULL DEFAULT 9999,
    texto_edicao varchar(255),
    geom geometry(MultiPoint, 4674),
    CONSTRAINT infra_obstaculo_terrestre_p_pk PRIMARY KEY (id)
);
CREATE INDEX infra_obstaculo_terrestre_p_geom ON edgv.infra_obstaculo_terrestre_p USING gist (geom);
ALTER TABLE edgv.infra_obstaculo_terrestre_p ADD CONSTRAINT infra_obstaculo_terrestre_p_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_obstaculo_terrestre (code);
ALTER TABLE edgv.infra_obstaculo_terrestre_p ADD CONSTRAINT infra_obstaculo_terrestre_p_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);

CREATE TABLE edgv.infra_obstaculo_terrestre_l (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    nome varchar(255),
    tipo smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    visivel smallint NOT NULL DEFAULT 9999,
    texto_edicao varchar(255),
    geom geometry(MultiLineString, 4674),
    CONSTRAINT infra_obstaculo_terrestre_l_pk PRIMARY KEY (id)
);
CREATE INDEX infra_obstaculo_terrestre_l_geom ON edgv.infra_obstaculo_terrestre_l USING gist (geom);
ALTER TABLE edgv.infra_obstaculo_terrestre_l ADD CONSTRAINT infra_obstaculo_terrestre_l_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_obstaculo_terrestre (code);
ALTER TABLE edgv.infra_obstaculo_terrestre_l ADD CONSTRAINT infra_obstaculo_terrestre_l_visivel_fk
    FOREIGN KEY (visivel) REFERENCES dominios.booleano (code);

CREATE TABLE edgv.infra_obstaculo_terrestre_a (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    nome varchar(255),
    tipo smallint NOT NULL DEFAULT 9999,
    observacao varchar(255),
    visivel smallint NOT NULL DEFAULT 9999,
    texto_edicao varchar(255),
    geom geometry(MultiPolygon, 4674),
    CONSTRAINT infra_obstaculo_terrestre_a_pk PRIMARY KEY (id)
);
CREATE INDEX infra_obstaculo_terrestre_a_geom ON edgv.infra_obstaculo_terrestre_a USING gist (geom);
ALTER TABLE edgv.infra_obstaculo_terrestre_a ADD CONSTRAINT infra_obstaculo_terrestre_a_tipo_fk
    FOREIGN KEY (tipo) REFERENCES dominios.tipo_obstaculo_terrestre (code);
ALTER TABLE edgv.infra_obstaculo_terrestre_a ADD CONSTRAINT infra_obstaculo_terrestre_a_visivel_fk
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
-- Versão
-- ===========================================
ALTER TABLE public.db_metadata DROP CONSTRAINT edgvversioncheck;
UPDATE public.db_metadata SET edgvversion = 'EDGV Topo 2.0', dbimplversion = '0.9.1';
ALTER TABLE public.db_metadata ALTER COLUMN edgvversion SET DEFAULT 'EDGV Topo 2.0';
ALTER TABLE public.db_metadata ALTER COLUMN dbimplversion SET DEFAULT '0.9.1';
ALTER TABLE public.db_metadata
    ADD CONSTRAINT edgvversioncheck CHECK (edgvversion = 'EDGV Topo 2.0');
```
