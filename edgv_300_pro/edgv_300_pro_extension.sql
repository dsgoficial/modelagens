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
--Cria tabela de estilos

CREATE TABLE public.layer_styles
(
  id serial NOT NULL PRIMARY KEY,
  f_table_catalog character varying,
  f_table_schema character varying,
  f_table_name character varying,
  f_geometry_column character varying,
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
CREATE TABLE public.group_rules(
  	id SERIAL NOT NULL PRIMARY KEY,
    grupo_regra varchar(255) NOT NULL,
    cor_rgb varchar(255) NOT NULL,
    ordem integer NOT NULL,
    UNIQUE(grupo_regra)
);

ALTER TABLE public.group_rules
    OWNER to postgres;

GRANT ALL ON TABLE public.group_rules TO PUBLIC;

CREATE TABLE public.layer_rules(
	id SERIAL NOT NULL PRIMARY KEY,
  grupo_regra_id INTEGER NOT NULL REFERENCES public.group_rules (id),
  schema varchar(255) NOT NULL,
  camada varchar(255) NOT NULL,
  atributo varchar(255) NOT NULL,
  regra TEXT NOT NULL,
  descricao TEXT NOT NULL,
  owner varchar(255) NOT NULL,
	update_time timestamp without time zone NOT NULL DEFAULT now()
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
	id SERIAL NOT NULL PRIMARY KEY,
  ferramenta VARCHAR(255) NOT NULL,
  atalho VARCHAR(255) NOT NULL,
  owner varchar(255) NOT NULL,
	update_time timestamp without time zone NOT NULL DEFAULT now()
);

ALTER TABLE public.qgis_shortcuts
    OWNER to postgres;

GRANT ALL ON TABLE public.qgis_shortcuts TO PUBLIC;

--########################################################
--Cria tabela de unidades de trabalho

CREATE TABLE public.work_areas(
	id SERIAL NOT NULL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  geom geometry(POLYGON, 4326)
);

ALTER TABLE public.work_areas
    OWNER to postgres;

GRANT ALL ON TABLE public.work_areas TO PUBLIC;

--########################################################
