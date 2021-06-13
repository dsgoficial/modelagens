CREATE TABLE edgv.edicao_borda_elemento_hidrografico_l(
	 id serial NOT NULL,
	 tipo smallint NOT NULL,
	 geom geometry(MultiLineString, 31982),
	 CONSTRAINT edicao_borda_elemento_hidrografico_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_borda_elemento_hidrografico_l_geom ON edgv.edicao_borda_elemento_hidrografico_l USING gist (geom);

ALTER TABLE edgv.edicao_borda_elemento_hidrografico_l OWNER TO postgres;

ALTER TABLE edgv.edicao_borda_elemento_hidrografico_l
	 ADD CONSTRAINT edicao_borda_elemento_hidrografico_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_hidrografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE TABLE edgv.edicao_simb_hidrografia_l(
	 id serial NOT NULL,
	 texto varchar(255) not null,
	 classe varchar(255) not null,
	 tamanho real not null,
	 escala integer not null,
	 carta_mini boolean not null DEFAULT FALSE,
	 geom geometry(MultiLineString, 31974),
	 CONSTRAINT edicao_simb_hidrografia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_hidrografia_l_geom ON edgv.edicao_simb_hidrografia_l USING gist (geom);

ALTER TABLE edgv.edicao_simb_hidrografia_l OWNER TO postgres;

CREATE TABLE edgv.edicao_simb_hidrografia_p(
	 id serial NOT NULL,
	 texto varchar(255) not null,
	 espacamento real not null default 0,
	 classe varchar(255) not null,
	 tamanho real not null,
	 escala integer not null,
	 carta_mini boolean not null DEFAULT FALSE,
	 geom geometry(MultiPoint, 31974),
	 CONSTRAINT edicao_simb_hidrografia_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_hidrografia_p_geom ON edgv.edicao_simb_hidrografia_p USING gist (geom);

ALTER TABLE edgv.edicao_simb_hidrografia_p OWNER TO postgres;


CREATE TABLE edgv.edicao_texto_generico_p(
	 id serial NOT NULL,
	 texto varchar(255) not null,
	 estilo_fonte varchar(255),
     tamanho_txt real not null default 6,
	 espacamento real not null default 0,
	 cor varchar(255) not null DEFAULT '0,0,0',
	 justificativa_txt VARCHAR(255),
	 carta_mini boolean not null DEFAULT FALSE,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_texto_generico_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_texto_generico_p_geom ON edgv.edicao_texto_generico_p USING gist (geom);

ALTER TABLE edgv.edicao_texto_generico_p OWNER TO postgres;

CREATE TABLE edgv.edicao_texto_generico_l(
	 id serial NOT NULL,
	 texto varchar(255) not null,
	 estilo_fonte varchar(255),
     tamanho_txt real not null default 6,
	 espacamento real not null default 0,
	 cor varchar(255) not null DEFAULT '0,0,0',
	 carta_mini boolean not null DEFAULT FALSE,
	 geom geometry(MultiLineString, 31982),
	 CONSTRAINT edicao_texto_generico_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_texto_generico_l_geom ON edgv.edicao_texto_generico_l USING gist (geom);

ALTER TABLE edgv.edicao_texto_generico_l OWNER TO postgres;


CREATE TABLE edgv.edicao_identificador_trecho_rod_p(
	 id serial NOT NULL,
	 sigla varchar(255) not null,
	 jurisdicao smallint NOT NULL,
	 geom geometry(MultiPoint, 31982),
	 carta_mini boolean not null DEFAULT FALSE,
	 CONSTRAINT edicao_identificador_trecho_rod_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_identificador_trecho_rod_p_geom ON edgv.edicao_identificador_trecho_rod_p USING gist (geom);

ALTER TABLE edgv.edicao_identificador_trecho_rod_p
	 ADD CONSTRAINT edicao_identificador_trecho_rod_p_jurisdicao_fk FOREIGN KEY (jurisdicao)
	 REFERENCES dominios.jurisdicao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.edicao_identificador_trecho_rod_p
	 ADD CONSTRAINT edicao_identificador_trecho_rod_p_jurisdicao_check 
	 CHECK (jurisdicao = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 9999 :: SMALLINT])); 
ALTER TABLE edgv.edicao_identificador_trecho_rod_p ALTER COLUMN jurisdicao SET DEFAULT 9999;

ALTER TABLE edgv.edicao_identificador_trecho_rod_p OWNER TO postgres;

CREATE TABLE edgv.edicao_simb_vegetacao_p(
	 id serial NOT NULL,
	 texto varchar(255) not null,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_simb_vegetacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_vegetacao_p_geom ON edgv.edicao_simb_vegetacao_p USING gist (geom);

ALTER TABLE edgv.edicao_simb_vegetacao_p OWNER TO postgres;

CREATE TABLE edgv.edicao_direcao_corrente_p(
	 id serial NOT NULL,
	 simb_rot REAL,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_direcao_corrente_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_direcao_corrente_p_geom ON edgv.edicao_direcao_corrente_p USING gist (geom);

ALTER TABLE edgv.edicao_direcao_corrente_p OWNER TO postgres;

CREATE TABLE edgv.edicao_cota_mestra_p(
	 id serial NOT NULL,
	 cota integer,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_cota_mestra_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_cota_mestra_p_geom ON edgv.edicao_cota_mestra_p USING gist (geom);

ALTER TABLE edgv.edicao_cota_mestra_p OWNER TO postgres;


CREATE TABLE dominios.simbolo_area (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT simbolo_area_pk PRIMARY KEY (code)
);

INSERT INTO dominios.simbolo_area (code,code_name) VALUES (1,'Subestação de energia (1)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (2,'Extração mineral (2)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (3,'Extração mineral não operacional (3)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (4,'Extração mineral - salina (4)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (5,'Plataforma (5)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (6,'Cemitério - Cristã (6)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (7,'Cemitério - Israelita (7)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (8,'Cemitério - Muçulmana (8)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (9,'Cemitério - Outros (9)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (10,'Estacionamento (10)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (11,'Edificação de ensino (11)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (12,'Edificação religiosa (12)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (13,'Edificação religiosa - mesquita (13)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (14,'Edificação religiosa - sinagoga (14)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (15,'Edificação saúde (15)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (16,'Posto de combustível (16)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (17,'Representação diplomática (17)');
INSERT INTO dominios.simbolo_area (code,code_name) VALUES (18,'Campo/quadra (18)');

INSERT INTO dominios.simbolo_area (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.administracao OWNER TO postgres;

CREATE TABLE edgv.edicao_simbolo_area_p(
	 id serial NOT NULL,
	 tipo smallint NOT NULL,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_simbolo_area_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simbolo_area_p_geom ON edgv.edicao_simbolo_area_p USING gist (geom);

ALTER TABLE edgv.edicao_simbolo_area_p OWNER TO postgres;

ALTER TABLE edgv.edicao_simbolo_area_p
	 ADD CONSTRAINT edicao_simbolo_area_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.simbolo_area (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.edicao_simbolo_area_p ALTER COLUMN tipo SET DEFAULT 9999;


CREATE TABLE edgv.edicao_simb_torre_energia_p(
	 id serial NOT NULL,
	 simb_rot REAL,
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT edicao_simb_torre_energia_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_simb_torre_energia_p_geom ON edgv.edicao_simb_torre_energia_p USING gist (geom);

ALTER TABLE edgv.edicao_simb_torre_energia_p OWNER TO postgres;



ALTER TABLE edgv.infra_elemento_viario_p ADD COLUMN largura_simbologia REAL NOT NULL DEFAULT 1;
ALTER TABLE edgv.infra_elemento_viario_l ADD COLUMN largura_simbologia REAL NOT NULL DEFAULT 1;
ALTER TABLE edgv.infra_barragem_l ADD COLUMN largura_simbologia REAL NOT NULL DEFAULT 1;

ALTER TABLE edgv.elemnat_toponimo_fisiografico_natural_p ADD COLUMN tamanho_txt REAL NOT NULL DEFAULT 6;
ALTER TABLE edgv.elemnat_toponimo_fisiografico_natural_l ADD COLUMN tamanho_txt REAL NOT NULL DEFAULT 6;
ALTER TABLE edgv.elemnat_toponimo_fisiografico_natural_l ADD COLUMN espacamento REAL NOT NULL DEFAULT 0;

ALTER TABLE edgv.llp_limite_especial_a ADD COLUMN tamanho_txt REAL NOT NULL DEFAULT 6;


ALTER TABLE edgv.elemnat_ilha_a ADD COLUMN tamanho_txt REAL NOT NULL DEFAULT 6;
ALTER TABLE edgv.llp_localidade_p ADD COLUMN tamanho_txt REAL NOT NULL DEFAULT 6;


ALTER TABLE edgv.elemnat_ponto_cotado_p ADD COLUMN cota_mais_alta BOOLEAN NOT NULL DEFAULT FALSE;


DO $$DECLARE r record;
BEGIN
	FOR r in select f_table_schema, f_table_name, type from public.geometry_columns
    LOOP 
	IF r.f_table_schema = 'edgv' AND r.f_table_name not like 'edicao_%' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN visivel BOOLEAN NOT NULL DEFAULT TRUE, ADD COLUMN texto_edicao VARCHAR(255), ADD COLUMN label_x REAL, ADD COLUMN label_y REAL, ADD COLUMN justificativa_txt VARCHAR(255)';
	END IF;

	IF r.f_table_schema = 'edgv' AND r.f_table_name not like 'edicao_%' AND r.type = 'MULTIPOINT' THEN
		EXECUTE 'ALTER TABLE edgv.' || quote_ident(r.f_table_name) || ' ADD COLUMN simb_rot REAL';
	END IF;
    END LOOP;
END$$;