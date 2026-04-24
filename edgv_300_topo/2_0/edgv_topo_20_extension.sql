--================================================================
-- EDGV Topo 2.0 — Extension Script
-- Aplicar APÓS edgv_topo_20.sql
--
-- Seções:
--   1. Função explode_geom() + triggers
--   2. Domínios de qualidade e linhagem
--   3. Colunas de qualidade e linhagem (todas as tabelas edgv)
--   4. Metadados de produção (operador/data)
--   5. Trigger preenche_metadado() (produção + geocodigo)
--   6. Tabela de estilos (layer_styles)
--   7. Tabelas auxiliares SAP / revisão / track
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
    (1, 'Ativo'),
    (2, 'Em validação'),
    (3, 'Sob verificação'),
    (4, 'Depreciado'),
    (9999, 'A SER PREENCHIDO')
ON CONFLICT DO NOTHING;

-- 2.2 dominios.tipo_validacao
CREATE TABLE IF NOT EXISTS dominios.tipo_validacao (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT tipo_validacao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_validacao (code, code_name) VALUES
    (1, 'Não validada'),
    (2, 'Validação geométrica'),
    (3, 'Validação de atributos'),
    (4, 'Validação completa'),
    (9999, 'A SER PREENCHIDO')
ON CONFLICT DO NOTHING;

-- 2.3 dominios.confirmacao_geometria
CREATE TABLE IF NOT EXISTS dominios.confirmacao_geometria (
    code smallint NOT NULL,
    code_name text NOT NULL,
    nivel text,
    CONSTRAINT confirmacao_geometria_pk PRIMARY KEY (code)
);

INSERT INTO dominios.confirmacao_geometria (code, code_name, nivel) VALUES
    (1, 'Não confirmada', NULL),
    (2, 'Cruzamento com fonte autoritativa', 'baixo'),
    (3, 'Fotointerpretação', 'medio'),
    (4, 'Imagem 360°', 'medio'),
    (5, 'Campo visual', 'alto'),
    (9999, 'A SER PREENCHIDO', NULL)
ON CONFLICT DO NOTHING;

-- 2.4 dominios.confirmacao_atributos
CREATE TABLE IF NOT EXISTS dominios.confirmacao_atributos (
    code smallint NOT NULL,
    code_name text NOT NULL,
    nivel text,
    CONSTRAINT confirmacao_atributos_pk PRIMARY KEY (code)
);

INSERT INTO dominios.confirmacao_atributos (code, code_name, nivel) VALUES
    (1, 'Não confirmada', NULL),
    (2, 'Origem autoritativa - nome', 'baixo'),
    (3, 'Origem autoritativa - parcial', 'baixo'),
    (4, 'Parcial - fotointerpretação', 'baixo'),
    (5, 'Parcial - cruzamento nome', 'baixo'),
    (6, 'Parcial - cruzamento temático', 'medio'),
    (7, 'Parcial - cruzamento múltiplo', 'medio'),
    (8, 'Parcial - campo', 'medio'),
    (9, 'Completa - cruzamento', 'alto'),
    (10, 'Completa - campo', 'alto'),
    (9999, 'A SER PREENCHIDO', NULL)
ON CONFLICT DO NOTHING;

-- 2.5 dominios.metodo_aquisicao (tabela de referência — usada dentro do JSON fontes)
CREATE TABLE IF NOT EXISTS dominios.metodo_aquisicao (
    code smallint NOT NULL,
    code_name text NOT NULL,
    CONSTRAINT metodo_aquisicao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.metodo_aquisicao (code, code_name) VALUES
    (1, 'Extração por fotointerpretação'),
    (2, 'Levantamento de campo'),
    (3, 'Digitalização de carta'),
    (4, 'Insumo colaborativo'),
    (5, 'Insumo autoritativo'),
    (6, 'Insumo cooperativo'),
    (7, 'Insumo concessionária'),
    (8, 'Extração automática'),
    (9, 'Geocodificação'),
    (9999, 'A SER PREENCHIDO')
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
-- 4. Metadados de produção (operador/data)
--########################################################

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN IF NOT EXISTS operador_criacao VARCHAR(255);';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN IF NOT EXISTS data_criacao timestamp with time zone;';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN IF NOT EXISTS operador_atualizacao VARCHAR(255);';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN IF NOT EXISTS data_atualizacao timestamp with time zone;';
	END IF;
    END LOOP;
END$$;

--########################################################
-- 5. Trigger preenche_metadado()
--    Preenche operador/data de criação e atualização
--    Preserva geocodigo em UPDATE (impede alteração acidental)
--    Garante geocodigo em INSERT (fallback para DEFAULT)
--########################################################

CREATE OR REPLACE FUNCTION public.preenche_metadado()
  RETURNS trigger AS
$BODY$
    BEGIN

		IF TG_OP = 'UPDATE' THEN
			NEW.operador_atualizacao = CURRENT_USER;
			NEW.data_atualizacao = CURRENT_TIMESTAMP;
			NEW.operador_criacao = OLD.operador_criacao;
			NEW.data_criacao = OLD.data_criacao;
			-- Preserva geocodigo: impede alteração acidental
			NEW.geocodigo = OLD.geocodigo;
		ELSIF TG_OP = 'INSERT' THEN
			-- Só preenche se não vier valor (permite preservar dados de migração)
			IF NEW.operador_criacao IS NULL THEN
				NEW.operador_criacao = CURRENT_USER;
			END IF;
			IF NEW.data_criacao IS NULL THEN
				NEW.data_criacao = CURRENT_TIMESTAMP;
			END IF;
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
ALTER FUNCTION public.preenche_metadado()
  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.preenche_metadado() TO PUBLIC;

-- Cria trigger de metadados em todas as tabelas edgv

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'DROP TRIGGER IF EXISTS b_preenche_metadado ON edgv.' || quote_ident(r.f_table_name);
		EXECUTE 'CREATE TRIGGER b_preenche_metadado BEFORE INSERT OR UPDATE ON edgv.' || quote_ident(r.f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE public.preenche_metadado()';
	END IF;
    END LOOP;
END$$;

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
