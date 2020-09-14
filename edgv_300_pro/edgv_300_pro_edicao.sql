CREATE TABLE edgv.edicao_simb_hidrografia_l(
	 id serial NOT NULL,
	 texto varchar(255) not null,
     tamanho_txt real not null default 1.5,
     parte integer,
	 espacamento_letra real not null default 0,
	 espacamento_palavra real not null default 0,
	 carta_mini boolean not null DEFAULT FALSE,
	 geom geometry(MultiLineString, 31982),
	 CONSTRAINT edicao_simb_hidrografia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_hidrografia_l_geom ON edgv.edicao_simb_hidrografia_l USING gist (geom);

ALTER TABLE edgv.edicao_simb_hidrografia_l OWNER TO postgres;

CREATE TABLE edgv.edicao_identificador_trecho_rod_p(
	 id serial NOT NULL,
	 sigla varchar(255) not null,
	 geom geometry(MultiPoint, 31982),
	 carta_mini boolean not null DEFAULT FALSE,
	 CONSTRAINT edicao_identificador_trecho_rod_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_identificador_trecho_rod_p_geom ON edgv.edicao_identificador_trecho_rod_p USING gist (geom);

ALTER TABLE edgv.edicao_identificador_trecho_rod_p OWNER TO postgres;

ALTER TABLE edgv.llp_localidade_p ADD COLUMN populacao REAL;
ALTER TABLE edgv.cobter_massa_dagua_a ADD COLUMN largura_media REAL;

DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name from public.geometry_columns
    LOOP
	IF r.f_table_schema = 'edgv' AND r.f_table_name not like 'edicao_%' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN visivel BOOLEAN NOT NULL DEFAULT TRUE, ADD COLUMN texto VARCHAR(255), ADD COLUMN label_x REAL, ADD COLUMN label_y REAL, ADD COLUMN justificativa_txt VARCHAR(255), ADD COLUMN simb_x REAL, ADD COLUMN simb_y REAL, ADD COLUMN simb_rot REAL';
	END IF;
    END LOOP;
END$$;