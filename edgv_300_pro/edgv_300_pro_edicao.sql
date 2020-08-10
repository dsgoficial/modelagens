CREATE TABLE edgv.edicao_moldura_edicao_a(
	 id serial NOT NULL,
	 nome varchar(255),
     mi varchar(255),
     inom varchar(255),
	 denominador_escala varchar(255) NOT NULL,
	 geom geometry(MultiPolygon, 4674),
	 CONSTRAINT aux_moldura_edicao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_moldura_edicao_a_geom ON edgv.aux_moldura_edicao_a USING gist (geom);

ALTER TABLE edgv.aux_moldura_edicao_a OWNER TO postgres;

CREATE TABLE edgv.edicao_simb_hidrografia_l(
	 id serial NOT NULL,
	 texto varchar(255) not null,
     tamanho_txt real not null default 1.5,
     parte integer,
	 espacamento_letra real not null default 0,
	 espacamento_palavra real not null default 0,
	 geom geometry(MultiLineString, 31982),
	 CONSTRAINT edicao_simb_hidrografia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_hidrografia_l_geom ON edgv.edicao_simb_hidrografia_l USING gist (geom);

ALTER TABLE edgv.edicao_simb_hidrografia_l OWNER TO postgres;

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' AND r.f_table_name !~ 'edicao_%' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN visivel BOOLEAN NOT NULL DEFAULT TRUE, ADD COLUMN texto VARCHAR(255), ADD COLUMN label_x REAL, ADD COLUMN label_y REAL, ADD COLUMN justificativa_txt VARCHAR(255), ADD COLUMN symb_x REAL, ADD COLUMN symb_y REAL, ADD COLUMN symb_rot REAL';
	END IF;
    END LOOP;
END$$;