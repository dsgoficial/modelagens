--########################################################
-- Função explodir multi geometrias
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
			IF r.key <> 'geom' AND r.key <> 'id' THEN
				querytext1 := querytext1 || quote_ident(r.key) || ',';
				IF r.value <> '' THEN
					querytext2 := querytext2 || quote_literal(r.value) || ',';
				ELSE
					querytext2 := querytext2 || 'NULL' || ',';					
				END IF;
			END IF;
		END LOOP;

		IF TG_OP = 'UPDATE' THEN
			EXECUTE 'DELETE FROM ' || quote_ident(TG_TABLE_SCHEMA) || '.' || quote_ident(TG_TABLE_NAME) || ' WHERE id = ' || OLD.id;
		END IF;


		querytext1 := querytext1  || querytext2;
		EXECUTE querytext1 || 'ST_Multi((ST_Dump(ST_AsEWKT(' || quote_literal(NEW.geom::text) || '))).geom);';
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

--########################################################
-- Cria trigger de explodir multi geometrias

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'CREATE TRIGGER a_explode_geom BEFORE INSERT OR UPDATE ON edgv.' || quote_ident(r.f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE public.explode_geom()';
	END IF;
    END LOOP;
END$$;

--########################################################
--Metadados de feição para produção

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN operador_criacao VARCHAR(255);';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN data_criacao timestamp with time zone;';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN operador_atualizacao VARCHAR(255);';
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN data_atualizacao timestamp with time zone;';
	END IF;
    END LOOP;
END$$;

CREATE OR REPLACE FUNCTION public.preenche_metadado()
  RETURNS trigger AS
$BODY$
    BEGIN

		IF TG_OP = 'UPDATE' THEN
			NEW.operador_atualizacao = CURRENT_USER;
			NEW.data_atualizacao = CURRENT_TIMESTAMP;
      NEW.operador_criacao = OLD.operador_criacao;
			NEW.data_criacao = OLD.data_criacao;
    elsif  TG_OP = 'INSERT' THEN
			NEW.operador_criacao = CURRENT_USER;
			NEW.data_criacao = CURRENT_TIMESTAMP;
	END IF;

		RETURN NEW;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.preenche_metadado()
  OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.preenche_metadado() TO PUBLIC;


DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' THEN
		EXECUTE 'CREATE TRIGGER b_preenche_metadado BEFORE INSERT OR UPDATE ON edgv.' || quote_ident(r.f_table_name) || ' FOR EACH ROW EXECUTE PROCEDURE public.preenche_metadado()';
	END IF;
    END LOOP;
END$$;

--########################################################
--Cria tabela de estilos

CREATE TABLE public.layer_styles
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

--########################################################
--Cria função que atualiza o nome do banco na tabela de estilos

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
--Cria tabela menu profile

CREATE TABLE public.qgis_menus
(
    id SERIAL NOT NULL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    definicao_menu TEXT NOT NULL,
    owner varchar(255) NOT NULL,
	  update_time timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT unique_menus UNIQUE (nome)
);

ALTER TABLE public.qgis_menus
    OWNER to postgres;

GRANT ALL ON TABLE public.qgis_menus TO PUBLIC;

--########################################################
--Cria tabela de regras

CREATE TABLE public.layer_rules(
	id SERIAL NOT NULL PRIMARY KEY,
  nome varchar(255) NOT NULL,
  cor_rgb varchar(255) NOT NULL,
  ordem INTEGER NOT NULL,
  regra TEXT NOT NULL,
  owner varchar(255) NOT NULL,
	update_time timestamp without time zone NOT NULL DEFAULT now(),
  UNIQUE(nome)
);

ALTER TABLE public.layer_rules
    OWNER to postgres;

GRANT ALL ON TABLE public.layer_rules TO PUBLIC;

--########################################################
--Cria tabela de modelos

CREATE TABLE public.qgis_models(
	id SERIAL NOT NULL PRIMARY KEY,
  nome varchar(255) NOT NULL UNIQUE,
  descricao TEXT NOT NULL,
  model_xml TEXT NOT NULL,
  owner varchar(255) NOT NULL,
	update_time timestamp without time zone NOT NULL DEFAULT now()
);

ALTER TABLE public.qgis_models
    OWNER to postgres;

GRANT ALL ON TABLE public.qgis_models TO PUBLIC;

--########################################################
--Cria tabela de atalhos

CREATE TABLE public.qgis_shortcuts(
	code SMALLINT NOT NULL PRIMARY KEY,
  ferramenta VARCHAR(255) NOT NULL,
  idioma VARCHAR(255) NOT NULL,
  atalho VARCHAR(255),
  owner varchar(255) NOT NULL,
	update_time timestamp without time zone NOT NULL DEFAULT now()
);

ALTER TABLE public.qgis_shortcuts
    OWNER to postgres;

GRANT ALL ON TABLE public.qgis_shortcuts TO PUBLIC;

--########################################################
--Cria tabela sap local

CREATE TABLE public.work_areas(
	id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
  nome VARCHAR(255) NOT NULL,
	epsg VARCHAR(5) NOT NULL,
 	subfase VARCHAR(255) NOT NULL,
	lote VARCHAR(255) NOT NULL,
	bloco VARCHAR(255) NOT NULL,
	etapa VARCHAR(255) NOT NULL,
	data_inicio timestamp with time zone,
	data_fim timestamp with time zone,
  nome_usuario VARCHAR(255),
  usuario_uuid UUID,
	observacao_ut text,
  observacao_ativ text,
  geom geometry(POLYGON, 4326) NOT NULL,
  CONSTRAINT chk_single_row CHECK (id = 1)
);

ALTER TABLE public.work_areas
    OWNER to postgres;

GRANT ALL ON TABLE public.work_areas TO PUBLIC;

--########################################################
--Cria tabela de temas
CREATE TABLE public.qgis_themes(
	  id SERIAL NOT NULL PRIMARY KEY,
    nome text NOT NULL,
    definicao_tema text NOT NULL,
    owner varchar(255) NOT NULL,
	  update_time timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT unique_themes UNIQUE (nome)
);

ALTER TABLE public.qgis_themes
    OWNER to postgres;

GRANT ALL ON TABLE public.qgis_themes TO PUBLIC;


--########################################################

CREATE TABLE public.aux_grid_revisao_a(
	 id uuid NOT NULL DEFAULT uuid_generate_v4(),
	 rank integer,
	 visited boolean,
	 atividade_id integer,
   data_atualizacao timestamp without time zone,
	 geom geometry(MultiPolygon, 4674),
	 CONSTRAINT aux_grid_revisao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_grid_revisao_a_geom ON public.aux_grid_revisao_a USING gist (geom);

ALTER TABLE public.aux_grid_revisao_a OWNER TO postgres;

GRANT ALL ON TABLE public.aux_grid_revisao_a TO public;

--########################################################

CREATE TABLE public.aux_track_p(
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

CREATE INDEX aux_track_p_geom ON public.aux_track_p USING gist (geom);

ALTER TABLE public.aux_track_p OWNER to postgres;

GRANT SELECT ON TABLE public.aux_track_p TO public;

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
WITH DATA;

ALTER TABLE public.aux_track_l OWNER TO postgres;

GRANT SELECT ON TABLE public.aux_track_l TO public;
