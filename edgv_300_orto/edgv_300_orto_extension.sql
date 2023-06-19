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
