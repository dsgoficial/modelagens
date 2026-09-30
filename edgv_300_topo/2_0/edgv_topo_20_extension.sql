--================================================================
-- EDGV Topo 2.0 — Extension Script
-- Aplicar APÓS edgv_topo_20.sql
--
-- Seções:
--   1. Função explode_geom() + triggers
--   2. Domínios de qualidade e linhagem
--   3. Colunas de qualidade e linhagem (todas as tabelas edgv)
--   4. Autoria e datas de edição: histórico do DSG Versioning (rev 0.19.0)
--   5. Trigger preserva_geocodigo()
--   6. Tabela de estilos (layer_styles)
--   7. Tabelas auxiliares SAP / revisão / track
--   8. Metadados de qualidade da base contínua
--      (confiabilidade e escala máxima autoritativa calculadas na leitura,
--       completude por subfase; linhagem e depreciação no DSG Versioning)
--
-- Rev 0.19.0: esta extensão não mantém mais autoria, datas de edição,
-- linhagem nem depreciação. Numa base versionada pelo DSG Versioning
-- (1cgeo/dsg_versioning, decisão D019), esses fatos são eventos do histórico.
-- Trigger que altera a linha com usuário ou relógio divergiria entre clones e
-- gravaria o integrador como autor; por isso os triggers restantes só usam a
-- própria linha.
--================================================================

-- Coluna 'fontes' é TEXT contendo um array JSON serializado (compatibilidade QGIS).
-- Para consultas com operadores JSON, usar cast: fontes::jsonb -> 0 ->> 'fonte'.
-- Estrutura de cada entrada no array JSON 'fontes':
-- {
--   "fonte": "DSG/1º CGEO",              -- Organização de origem (obrigatório)
--   "metodo_aquisicao": 1,                -- Código do dominios.metodo_aquisicao
--   "data_aquisicao": "2026-03-15",       -- Data da captura/incorporação
--   "data_confirmacao": "2026-04-01",     -- Data da confirmação (se houver)
--   "escala_fonte": 25000,                -- Denominador da escala fonte
--   "acuracia_planimetrica": 12.5,        -- Acurácia plan. da fonte em metros
--   "acuracia_altimetrica": 5.0,          -- Acurácia altim. da fonte em metros
--   "id_externo": "IBGE:4205407",         -- ID na base de origem
--   "fonte_url": "https://...",           -- URL da fonte
--   "observacao": null,                   -- Nota sobre esta fonte específica
--   "atributos_originais": {}             -- Tags/atributos originais da fonte
-- }
--
-- Exemplo OSM:
--   atributos_originais: {"highway":"secondary","surface":"asphalt","lanes":"2","ref":"BR-101"}
--
-- Exemplo Overture:
--   atributos_originais: {"class":"hospital","confidence":0.85,"height":12.5}

--########################################################
-- 1. Função explodir multi geometrias
--    Adaptada para EDGV Topo 2.0
--########################################################

CREATE EXTENSION IF NOT EXISTS hstore;

CREATE OR REPLACE FUNCTION public.explode_geom()
  RETURNS trigger AS
$BODY$
    DECLARE querytext1 text;
    DECLARE querytext2 text;
    DECLARE r record;
    BEGIN

	IF ST_NumGeometries(NEW.geom) > 1 THEN

		querytext1 := 'INSERT INTO ' || quote_ident(TG_TABLE_SCHEMA) || '.' || quote_ident(TG_TABLE_NAME) || '(';
		querytext2 := 'geom) SELECT ';

		FOR r IN SELECT (each(hstore(NEW))).*
		LOOP
			IF r.key <> 'geom' AND r.key <> 'id' AND r.key <> 'geocodigo' THEN
				querytext1 := querytext1 || quote_ident(r.key) || ',';
				IF r.value IS NOT NULL AND r.value <> '' THEN
					querytext2 := querytext2 || quote_literal(r.value) || ',';
				ELSE
					querytext2 := querytext2 || 'NULL' || ',';
				END IF;
			END IF;
		END LOOP;

		IF TG_OP = 'UPDATE' THEN
			EXECUTE 'DELETE FROM ' || quote_ident(TG_TABLE_SCHEMA) || '.' || quote_ident(TG_TABLE_NAME) || ' WHERE id = ' || quote_literal(OLD.id);
		END IF;

		querytext1 := querytext1  || querytext2;
		EXECUTE querytext1 || 'ST_Multi((ST_Dump(' || quote_literal(NEW.geom::text) || '::geometry)).geom);';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.explode_geom()
  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.explode_geom() TO PUBLIC;

-- Cria trigger de explodir multi geometrias

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'DROP TRIGGER IF EXISTS a_explode_geom ON edgv.' || quote_ident(r.f_table_name);
		EXECUTE 'CREATE TRIGGER a_explode_geom BEFORE INSERT OR UPDATE ON edgv.' || quote_ident(r.f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE public.explode_geom()';
	END IF;
    END LOOP;
END$$;

--########################################################
-- 2. Domínios de qualidade e linhagem
--########################################################

-- 2.1 dominios.status_ciclo_vida
CREATE TABLE IF NOT EXISTS dominios.status_ciclo_vida (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT status_ciclo_vida_pk PRIMARY KEY (code)
);

INSERT INTO dominios.status_ciclo_vida (code, code_name) VALUES
    (1, 'Ativo (1)'),
    (2, 'Em validação (2)'),
    (3, 'Sob verificação (3)'),
    (9999, 'A SER PREENCHIDO (9999)')
ON CONFLICT DO NOTHING;

-- 2.2 dominios.tipo_validacao
CREATE TABLE IF NOT EXISTS dominios.tipo_validacao (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT tipo_validacao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_validacao (code, code_name) VALUES
    (1, 'Não validada (1)'),
    (2, 'Validação geométrica (2)'),
    (3, 'Validação de atributos (3)'),
    (4, 'Validação completa (4)'),
    (9999, 'A SER PREENCHIDO (9999)')
ON CONFLICT DO NOTHING;

-- 2.3 dominios.confirmacao_geometria
CREATE TABLE IF NOT EXISTS dominios.confirmacao_geometria (
    code smallint NOT NULL,
    code_name text NOT NULL,
    nivel text,
    CONSTRAINT confirmacao_geometria_pk PRIMARY KEY (code)
);

INSERT INTO dominios.confirmacao_geometria (code, code_name, nivel) VALUES
    (1, 'Não confirmada (1)', NULL),
    (2, 'Cruzamento com fonte autoritativa (2)', 'baixo'),
    (3, 'Fotointerpretação (3)', 'medio'),
    (4, 'Imagem 360° (4)', 'medio'),
    (5, 'Campo visual (5)', 'alto'),
    (9999, 'A SER PREENCHIDO (9999)', NULL)
ON CONFLICT DO NOTHING;

-- 2.4 dominios.confirmacao_atributos
CREATE TABLE IF NOT EXISTS dominios.confirmacao_atributos (
    code smallint NOT NULL,
    code_name text NOT NULL,
    nivel text,
    CONSTRAINT confirmacao_atributos_pk PRIMARY KEY (code)
);

INSERT INTO dominios.confirmacao_atributos (code, code_name, nivel) VALUES
    (1, 'Não confirmada (1)', NULL),
    (2, 'Origem autoritativa - nome (2)', 'baixo'),
    (3, 'Origem autoritativa - parcial (3)', 'baixo'),
    (4, 'Parcial - fotointerpretação (4)', 'baixo'),
    (5, 'Parcial - cruzamento nome (5)', 'baixo'),
    (6, 'Parcial - cruzamento temático (6)', 'medio'),
    (7, 'Parcial - cruzamento múltiplo (7)', 'medio'),
    (8, 'Parcial - campo (8)', 'medio'),
    (9, 'Completa - cruzamento (9)', 'alto'),
    (10, 'Completa - campo (10)', 'alto'),
    (9999, 'A SER PREENCHIDO (9999)', NULL)
ON CONFLICT DO NOTHING;

-- 2.5 dominios.metodo_aquisicao (tabela de referência — usada dentro do JSON fontes)
CREATE TABLE IF NOT EXISTS dominios.metodo_aquisicao (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT metodo_aquisicao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.metodo_aquisicao (code, code_name) VALUES
    (1, 'Extração por fotointerpretação (1)'),
    (2, 'Levantamento de campo (2)'),
    (3, 'Digitalização de carta (3)'),
    (4, 'Insumo colaborativo (4)'),
    (5, 'Insumo autoritativo (5)'),
    (6, 'Insumo cooperativo (6)'),
    (7, 'Insumo concessionária (7)'),
    (8, 'Extração automática (8)'),
    (9, 'Geocodificação (9)'),
    (9999, 'A SER PREENCHIDO (9999)')
ON CONFLICT DO NOTHING;

--########################################################
-- 3. Colunas de qualidade e linhagem
--    Adicionadas a todas as tabelas edgv com geometria
--########################################################

DO $$DECLARE r record; t text;
BEGIN
    FOR r in select f_table_name from public.geometry_columns
              WHERE f_table_schema = 'edgv'
    LOOP
        t := r.f_table_name;
        -- Colunas (IF NOT EXISTS para idempotência)
        EXECUTE 'ALTER TABLE edgv.' || quote_ident(t)
            || ' ADD COLUMN IF NOT EXISTS geocodigo UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE'
            || ', ADD COLUMN IF NOT EXISTS fontes TEXT NOT NULL DEFAULT ''[]'''
            || ', ADD COLUMN IF NOT EXISTS status_ciclo_vida SMALLINT NOT NULL DEFAULT 1'
            || ', ADD COLUMN IF NOT EXISTS validacao SMALLINT NOT NULL DEFAULT 1'
            || ', ADD COLUMN IF NOT EXISTS confirmacao_geometria SMALLINT NOT NULL DEFAULT 1'
            || ', ADD COLUMN IF NOT EXISTS confirmacao_atributos SMALLINT NOT NULL DEFAULT 1'
            || ', ADD COLUMN IF NOT EXISTS acuracia_planimetrica REAL'
            || ', ADD COLUMN IF NOT EXISTS acuracia_altimetrica REAL;';
        -- FKs (nomes curtos para evitar truncamento em tabelas com nomes longos)
        BEGIN EXECUTE 'ALTER TABLE edgv.' || quote_ident(t) || ' ADD CONSTRAINT ' || t || '_scv_fk FOREIGN KEY (status_ciclo_vida) REFERENCES dominios.status_ciclo_vida(code);';
        EXCEPTION WHEN duplicate_object THEN NULL; END;
        BEGIN EXECUTE 'ALTER TABLE edgv.' || quote_ident(t) || ' ADD CONSTRAINT ' || t || '_val_fk FOREIGN KEY (validacao) REFERENCES dominios.tipo_validacao(code);';
        EXCEPTION WHEN duplicate_object THEN NULL; END;
        BEGIN EXECUTE 'ALTER TABLE edgv.' || quote_ident(t) || ' ADD CONSTRAINT ' || t || '_cg_fk FOREIGN KEY (confirmacao_geometria) REFERENCES dominios.confirmacao_geometria(code);';
        EXCEPTION WHEN duplicate_object THEN NULL; END;
        BEGIN EXECUTE 'ALTER TABLE edgv.' || quote_ident(t) || ' ADD CONSTRAINT ' || t || '_ca_fk FOREIGN KEY (confirmacao_atributos) REFERENCES dominios.confirmacao_atributos(code);';
        EXCEPTION WHEN duplicate_object THEN NULL; END;
    END LOOP;
END$$;

--########################################################
-- 4. Autoria e datas de edição (rev 0.19.0)
--    As colunas operador_criacao, data_criacao, operador_atualizacao e
--    data_atualizacao saíram do modelo: quem editou e quando são eventos do
--    histórico do DSG Versioning, que separa autor, responsável pela
--    resolução e integrador. O produto que precisar delas as projeta do
--    histórico.
--########################################################

--########################################################
-- 5. Trigger preserva_geocodigo()
--    Preserva geocodigo em UPDATE (impede alteração acidental)
--    Garante geocodigo em INSERT (fallback para DEFAULT)
--    Usa só a própria linha, sem usuário nem relógio.
--########################################################

CREATE OR REPLACE FUNCTION public.preserva_geocodigo()
  RETURNS trigger AS
$BODY$
    BEGIN

		IF TG_OP = 'UPDATE' THEN
			-- Preserva geocodigo: impede alteração acidental
			NEW.geocodigo = OLD.geocodigo;
		ELSIF TG_OP = 'INSERT' THEN
			-- Garante geocodigo se NULL (fallback para o DEFAULT)
			IF NEW.geocodigo IS NULL THEN
				NEW.geocodigo = uuid_generate_v4();
			END IF;
		END IF;

		RETURN NEW;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.preserva_geocodigo()
  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.preserva_geocodigo() TO PUBLIC;

-- Cria o trigger em todas as tabelas edgv e remove os da 0.18.0
-- (b_preenche_metadado, c_computa_qualidade), para que reaplicar esta
-- extensão atualize um banco existente.

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'DROP TRIGGER IF EXISTS b_preenche_metadado ON edgv.' || quote_ident(r.f_table_name);
		EXECUTE 'DROP TRIGGER IF EXISTS c_computa_qualidade ON edgv.' || quote_ident(r.f_table_name);
		EXECUTE 'DROP TRIGGER IF EXISTS b_preserva_geocodigo ON edgv.' || quote_ident(r.f_table_name);
		EXECUTE 'CREATE TRIGGER b_preserva_geocodigo BEFORE INSERT OR UPDATE ON edgv.' || quote_ident(r.f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE public.preserva_geocodigo()';
	END IF;
    END LOOP;
END$$;

DROP FUNCTION IF EXISTS public.preenche_metadado();

--########################################################
-- 6. Tabela de estilos (layer_styles)
--########################################################

CREATE TABLE IF NOT EXISTS public.layer_styles
(
  id serial NOT NULL PRIMARY KEY,
  f_table_catalog character varying,
  f_table_schema character varying,
  f_table_name character varying,
  f_geometry_column character varying,
  grupo_estilo_id INTEGER,
  stylename character varying(255),
  styleqml text,
  stylesld text,
  useasdefault boolean,
  description text,
  owner character varying(30),
  ui text,
  update_time timestamp without time zone DEFAULT now(),
  type character varying,
  CONSTRAINT unique_styles UNIQUE (f_table_schema,f_table_name,stylename)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.layer_styles OWNER TO postgres;

GRANT ALL ON TABLE public.layer_styles TO public;

-- Função que atualiza o nome do banco na tabela de estilos

CREATE OR REPLACE FUNCTION public.estilo()
  RETURNS integer AS
$BODY$
    UPDATE public.layer_styles
        SET f_table_catalog = (select current_catalog);
    SELECT 1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.estilo()
  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.estilo() TO PUBLIC;

--########################################################
-- 7. Tabelas auxiliares SAP / revisão / track
--########################################################

-- 7.1 sap_local

CREATE TABLE IF NOT EXISTS public.sap_local(
	id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
  atividade_id INTEGER NOT NULL,
  json_atividade TEXT NOT NULL,
	data_inicio timestamp with time zone,
	data_fim timestamp with time zone,
  nome_usuario VARCHAR(255),
  usuario_uuid UUID,
  geom geometry(POLYGON, 4326) NOT NULL,
  CONSTRAINT chk_single_row CHECK (id = 1)
);

ALTER TABLE public.sap_local
    OWNER to postgres;

GRANT ALL ON TABLE public.sap_local TO PUBLIC;

-- 7.2 aux_grid_revisao_a

CREATE TABLE IF NOT EXISTS public.aux_grid_revisao_a(
	 id uuid NOT NULL DEFAULT uuid_generate_v4(),
	 rank integer,
	 visited boolean,
	 atividade_id integer,
   unidade_trabalho_id integer,
	 etapa_id integer,
   data_atualizacao timestamp without time zone,
	 geom geometry(MultiPolygon, 4674),
	 CONSTRAINT aux_grid_revisao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX IF NOT EXISTS aux_grid_revisao_a_geom ON public.aux_grid_revisao_a USING gist (geom);

ALTER TABLE public.aux_grid_revisao_a OWNER TO postgres;

GRANT ALL ON TABLE public.aux_grid_revisao_a TO public;

-- 7.3 aux_track_p + aux_track_l (materialized view)

CREATE TABLE IF NOT EXISTS public.aux_track_p(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    operador text,
    data_track date,
    x_ll real,
    y_ll real,
    track_id text,
    track_segment integer,
    track_segment_point_index integer,
    elevation real,
    creation_time timestamp with time zone,
    geom geometry(Point,4674),
    data_importacao timestamp(6) without time zone,
    vtr text,
    CONSTRAINT aux_track_p_pk PRIMARY KEY (id)
    WITH (FILLFACTOR = 80)
);

CREATE INDEX IF NOT EXISTS aux_track_p_geom ON public.aux_track_p USING gist (geom);

ALTER TABLE public.aux_track_p OWNER to postgres;

GRANT SELECT ON TABLE public.aux_track_p TO public;

DO $$ BEGIN
IF NOT EXISTS (SELECT 1 FROM pg_matviews WHERE schemaname = 'public' AND matviewname = 'aux_track_l') THEN
    EXECUTE $mat$
    CREATE MATERIALIZED VIEW public.aux_track_l
    AS
     SELECT row_number() OVER () AS id,
        a.data_track,
        a.track_id,
        a.operador,
        a.vtr,
        min(a.creation_time) AS min_t,
        max(a.creation_time) AS max_t,
        st_makeline(st_setsrid(st_makepointm(st_x(a.geom), st_y(a.geom), date_part('epoch'::text, a.creation_time)), 4674) ORDER BY a.creation_time)::geometry(LineStringM,4674) AS geom
       FROM public.aux_track_p AS a
      GROUP BY a.data_track, a.track_id, a.operador, a.vtr
    WITH DATA
    $mat$;
END IF;
END $$;

ALTER TABLE public.aux_track_l OWNER TO postgres;

GRANT SELECT ON TABLE public.aux_track_l TO public;

--########################################################
-- 8. Metadados de qualidade da base contínua
--    Materializa o Apêndice C (confiabilidade, escala máxima autoritativa,
--    escala mínima de derivação, data de confirmação) e o Apêndice F.2.3
--    (completude por subfase) do RT 08/2026. A linhagem (Apêndices C.7 e G.4)
--    e a depreciação passaram ao DSG Versioning na rev 0.19.0.
--########################################################

-- 8.1 dominios.confiabilidade (Apêndice C.4)
CREATE TABLE IF NOT EXISTS dominios.confiabilidade (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT confiabilidade_pk PRIMARY KEY (code)
);

-- Revisao 2026-07-12: 5 niveis (era 4). Os DOIS mais altos (Muito Alta, Alta)
-- sao os que qualificam para INDE (ver public.linha_derivacao). O nivel novo,
-- Muito Alta, separa o confirmado em campo de alta acuracia do meramente confirmado.
INSERT INTO dominios.confiabilidade (code, code_name) VALUES
    (1, 'Muito Alta (1)'),
    (2, 'Alta (2)'),
    (3, 'Média (3)'),
    (4, 'Baixa (4)'),
    (5, 'Indeterminada (5)')
ON CONFLICT DO NOTHING;

-- 8.2 dominios.nivel_completude (Apêndice F.2.3). Hierarquia cumulativa;
--     ausencia_confirmada equivale a completa para todas as escalas.
CREATE TABLE IF NOT EXISTS dominios.nivel_completude (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT nivel_completude_pk PRIMARY KEY (code)
);

INSERT INTO dominios.nivel_completude (code, code_name) VALUES
    (1, 'Não verificada (1)'),
    (2, 'Ausência confirmada (2)'),
    (3, 'Verificada 1:250.000 (3)'),
    (4, 'Verificada 1:100.000 (4)'),
    (5, 'Verificada 1:50.000 (5)'),
    (6, 'Verificada 1:25.000 (6)')
ON CONFLICT DO NOTHING;

-- 8.3 Colunas data_confirmacao e escala_minima_derivacao, em todas as tabelas
--     edgv com geometria. confiabilidade e escala_maxima_autoritativa não são
--     mais colunas (rev 0.19.0): são calculadas na leitura pelas funções de 8.4,
--     porque valor derivado gravado na linha geraria conflito falso no merge
--     e a escala expira com a idade, sem edição.
--     data_confirmacao é informada por quem confirma (a data da verificação
--     pode ser anterior à edição); nenhum trigger a preenche.
DO $$DECLARE r record; t text;
BEGIN
    FOR r in select f_table_name from public.geometry_columns
              WHERE f_table_schema = 'edgv'
    LOOP
        t := r.f_table_name;
        EXECUTE 'ALTER TABLE edgv.' || quote_ident(t)
            || ' ADD COLUMN IF NOT EXISTS data_confirmacao DATE'
            || ', ADD COLUMN IF NOT EXISTS escala_minima_derivacao INTEGER;';
    END LOOP;
END$$;

-- 8.4 Funções de qualidade calculadas na leitura (Apêndices C.4 e C.5).
--     Substituem o trigger computa_qualidade() e a rotina
--     recomputa_escala_idade() da 0.18.0. Uso, por feição:
--       public.confiabilidade_feicao(status_ciclo_vida, confirmacao_geometria,
--           confirmacao_atributos, acuracia_planimetrica)
--       public.escala_maxima_autoritativa(status_ciclo_vida, validacao,
--           confirmacao_geometria, confirmacao_atributos, acuracia_planimetrica,
--           data_confirmacao)
--     A idade da escala máxima conta da data_confirmacao: todo limiar de C.5
--     exige confirmação, e a última edição não mede a atualidade da
--     informação. Sem data_confirmacao não há escala máxima.

CREATE OR REPLACE FUNCTION public.nivel_confirmacao(p_nivel text)
  RETURNS smallint AS
$BODY$
    SELECT CASE p_nivel WHEN 'alto' THEN 3 WHEN 'medio' THEN 2 WHEN 'baixo' THEN 1 ELSE 0 END::smallint;
$BODY$
  LANGUAGE sql IMMUTABLE;
ALTER FUNCTION public.nivel_confirmacao(text) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.nivel_confirmacao(text) TO PUBLIC;

-- Confiabilidade (C.4, revisao 2026-07-12: 5 niveis; os dois mais altos = INDE).
-- So confirmacao + acuracia (a temporalidade e criterio ORTOGONAL, aplicado
-- na derivacao do produto por public.linha_derivacao, nao aqui).
CREATE OR REPLACE FUNCTION public.confiabilidade_feicao(
    p_status_ciclo_vida smallint,
    p_confirmacao_geometria smallint,
    p_confirmacao_atributos smallint,
    p_acuracia_planimetrica real)
  RETURNS smallint AS
$BODY$
    WITH n AS (
        SELECT coalesce((SELECT public.nivel_confirmacao(nivel) FROM dominios.confirmacao_geometria WHERE code = p_confirmacao_geometria), 0) AS g,
               coalesce((SELECT public.nivel_confirmacao(nivel) FROM dominios.confirmacao_atributos WHERE code = p_confirmacao_atributos), 0) AS a
    )
    SELECT CASE
        WHEN p_status_ciclo_vida = 3 THEN 5   -- Indeterminada (sob verificação)
        WHEN g >= 3 AND a >= 3 AND p_acuracia_planimetrica <= 12.5 THEN 1   -- Muito Alta
        WHEN g >= 2 AND a >= 2 AND p_acuracia_planimetrica <= 25 THEN 2     -- Alta
        WHEN g >= 1 OR a >= 1 THEN 3                                        -- Média
        ELSE 4                                                              -- Baixa
    END::smallint FROM n;
$BODY$
  LANGUAGE sql STABLE;
ALTER FUNCTION public.confiabilidade_feicao(smallint, smallint, smallint, real) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.confiabilidade_feicao(smallint, smallint, smallint, real) TO PUBLIC;

-- Escala máxima autoritativa (C.5). Só feição ativa, validação completa.
CREATE OR REPLACE FUNCTION public.escala_maxima_autoritativa(
    p_status_ciclo_vida smallint,
    p_validacao smallint,
    p_confirmacao_geometria smallint,
    p_confirmacao_atributos smallint,
    p_acuracia_planimetrica real,
    p_data_confirmacao date,
    p_data_referencia date DEFAULT CURRENT_DATE)
  RETURNS integer AS
$BODY$
    WITH n AS (
        SELECT coalesce((SELECT public.nivel_confirmacao(nivel) FROM dominios.confirmacao_geometria WHERE code = p_confirmacao_geometria), 0) AS g,
               coalesce((SELECT public.nivel_confirmacao(nivel) FROM dominios.confirmacao_atributos WHERE code = p_confirmacao_atributos), 0) AS a,
               (p_data_referencia - p_data_confirmacao) / 365.25 AS idade_anos
    )
    SELECT CASE
        WHEN p_status_ciclo_vida IS DISTINCT FROM 1 OR p_validacao IS DISTINCT FROM 4
             OR p_acuracia_planimetrica IS NULL OR p_data_confirmacao IS NULL THEN NULL
        WHEN g >= 2 AND a >= 2 AND p_acuracia_planimetrica <= 12.5 AND idade_anos <= 5  THEN 25000
        WHEN g >= 2 AND a >= 2 AND p_acuracia_planimetrica <= 25   AND idade_anos <= 7  THEN 50000
        WHEN g >= 1 AND a >= 1 AND p_acuracia_planimetrica <= 50   AND idade_anos <= 8  THEN 100000
        WHEN g >= 1 AND a >= 1 AND p_acuracia_planimetrica <= 125  AND idade_anos <= 10 THEN 250000
    END FROM n;
$BODY$
  LANGUAGE sql STABLE;
ALTER FUNCTION public.escala_maxima_autoritativa(smallint, smallint, smallint, smallint, real, date, date) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.escala_maxima_autoritativa(smallint, smallint, smallint, smallint, real, date, date) TO PUBLIC;

-- 8.5 Remoção dos objetos da 0.18.0 que gravavam valores derivados
--     (os triggers c_computa_qualidade já foram removidos na seção 5).
DROP FUNCTION IF EXISTS public.computa_qualidade();
DROP FUNCTION IF EXISTS public.recomputa_escala_idade();

-- linha_derivacao(): linha de derivacao do produto POR FEICAO (revisao 2026-07-12,
--     ajustada na mesma data apos reflexao). A aptidao por feicao COLAPSA na
--     escala_maxima_autoritativa (C.5), que ja e confianca + temporalidade + validacao
--     resolvidas POR ESCALA. Nao ha mais gate flat de confiabilidade+idade: ele so
--     duplicava a escala_maxima e a CONTRADIZIA nas escalas grosseiras (100k/250k, que o
--     C.5 admite em confiabilidade Media). INDE quando a feicao e ativa e tem
--     escala_maxima_autoritativa (apta a alguma escala do SCN); senao Militar/expedito,
--     desde que o status nao seja sob verificacao (3). A confiabilidade
--     fica como rotulo legivel (top-2 Muito Alta/Alta = INDE de detalhe 25k/50k; Media =
--     INDE grosseiro 100k/250k). O TERRITORIO e criterio de AREA (nao aqui): fora do
--     Brasil e sempre llp_area_sem_dados_a para o INDE (obrigatorio; INDE nao tem dado
--     internacional). Retorna 'INDE', 'MILITAR' ou NULL (feicao sem produto).
DROP FUNCTION IF EXISTS public.linha_derivacao(smallint, smallint, smallint, timestamptz, timestamptz);
CREATE OR REPLACE FUNCTION public.linha_derivacao(
    p_status_ciclo_vida smallint,
    p_escala_maxima_autoritativa integer)
  RETURNS text AS
$BODY$
    SELECT CASE
        WHEN p_status_ciclo_vida = 3 THEN NULL   -- sob verificacao: sem produto
        WHEN p_status_ciclo_vida = 1 AND p_escala_maxima_autoritativa IS NOT NULL THEN 'INDE'
        ELSE 'MILITAR'
    END;
$BODY$
  LANGUAGE sql STABLE;
ALTER FUNCTION public.linha_derivacao(smallint, integer) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.linha_derivacao(smallint, integer) TO PUBLIC;

-- celula_publicavel_inde(): a TERCEIRA perna do INDE, de AREA (nao por feicao).
--     O produto INDE oficial de escala S so sai onde a celula MI 1:25.000 esta
--     verificada-completa em S (edgv.completude_subfase.nivel_completude, F.2.3),
--     alem da qualidade por feicao (linha_derivacao) e da aptidao de escala. Como
--     e espacial (por celula), nao entra em linha_derivacao: e filtro na derivacao,
--     cruzando a feicao com a celula pela grade MI. nivel_completude e cumulativo:
--     2 Ausencia confirmada = completa em qualquer escala; 3..6 = verificada ate
--     250k..25k. p_escala em denominador (250000, 100000, 50000, 25000).
CREATE OR REPLACE FUNCTION public.celula_publicavel_inde(
    p_nivel_completude smallint, p_escala integer)
  RETURNS boolean AS
$BODY$
    SELECT CASE
        WHEN p_nivel_completude = 2 THEN true          -- ausencia confirmada = completa
        WHEN p_escala = 250000 THEN p_nivel_completude >= 3
        WHEN p_escala = 100000 THEN p_nivel_completude >= 4
        WHEN p_escala = 50000  THEN p_nivel_completude >= 5
        WHEN p_escala = 25000  THEN p_nivel_completude >= 6
        ELSE false
    END;
$BODY$
  LANGUAGE sql IMMUTABLE;
ALTER FUNCTION public.celula_publicavel_inde(smallint, integer) OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.celula_publicavel_inde(smallint, integer) TO PUBLIC;

-- 8.6 Linhagem (Apêndices C.7 e G.4): desde a rev 0.19.0 a relação entre
--     predecessores e sucessores na divisão, na fusão e na migração é
--     registrada pelo DSG Versioning no mesmo evento da operação, com a
--     depreciação do original. A tabela edgv.linhagem_feicao saiu do modelo;
--     o incremento 0.19.0 do changelog a remove só se estiver vazia.

-- 8.7 edgv.completude_subfase (Apêndice F.2.3): verificação de completude
--     por subfase da linha de produção, na granularidade da MI 1:25.000.
CREATE TABLE IF NOT EXISTS edgv.completude_subfase (
    id BIGSERIAL PRIMARY KEY,
    mi_25k VARCHAR(20) NOT NULL,
    subfase VARCHAR(60) NOT NULL,
    nivel_completude SMALLINT NOT NULL DEFAULT 1,
    data_verificacao DATE,
    operador VARCHAR(255),
    observacao TEXT,
    CONSTRAINT completude_subfase_uk UNIQUE (mi_25k, subfase),
    CONSTRAINT completude_subfase_nc_fk FOREIGN KEY (nivel_completude) REFERENCES dominios.nivel_completude(code)
);
CREATE INDEX IF NOT EXISTS completude_subfase_mi_idx ON edgv.completude_subfase (mi_25k);
ALTER TABLE edgv.completude_subfase OWNER TO postgres;
GRANT ALL ON TABLE edgv.completude_subfase TO public;
GRANT USAGE, SELECT ON SEQUENCE edgv.completude_subfase_id_seq TO public;

-- 8.8 escala_minima_derivacao (Apêndice C): menor escala do SCN em que a feição
--     deve aparecer na carta derivada (250000, 100000, 50000, 25000 ou NULL).
--     É o análogo cartográfico do min_zoom dos vector tiles: o par de qualidade
--     escala_maxima_autoritativa diz até que detalhe a feição é BOA o bastante;
--     escala_minima_derivacao diz a partir de que generalização ela é RELEVANTE
--     o bastante. Uma feição compõe a carta de escala S quando, em denominador,
--     escala_maxima_autoritativa <= S <= escala_minima_derivacao.
--
--     A coluna (adicionada em 8.3) NÃO é preenchida por trigger: o valor depende de atributos temáticos POR CLASSE (hierarquia
--     viária, população, dimensões, presença de nome), vários deles derivados
--     no build, exatamente como o min_zoom. Por isso é computada pelo mesmo
--     motor de regras por classe (zoom_model / pipeline de tiles), e não por
--     SQL genérico. O operador pode ajustar o valor calculado diretamente.
