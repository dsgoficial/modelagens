CREATE SCHEMA edgv;
CREATE SCHEMA dominios;
CREATE EXTENSION postgis;
SET search_path TO pg_catalog,public,edgv,dominios;

CREATE TABLE dominios.auxiliar (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT auxiliar_pk PRIMARY KEY (code)
);

INSERT INTO dominios.auxiliar (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.auxiliar (code,code_name) VALUES (1,'Sim (1)');
INSERT INTO dominios.auxiliar (code,code_name) VALUES (2,'Não (2)');
INSERT INTO dominios.auxiliar (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.auxiliar OWNER TO postgres;

CREATE TABLE dominios.administracao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT administracao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.administracao (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.administracao (code,code_name) VALUES (2,'Federal (2)');
INSERT INTO dominios.administracao (code,code_name) VALUES (3,'Estadual/Distrital (3)');
INSERT INTO dominios.administracao (code,code_name) VALUES (4,'Municipal (4)');
INSERT INTO dominios.administracao (code,code_name) VALUES (5,'Concessionada (5)');
INSERT INTO dominios.administracao (code,code_name) VALUES (6,'Privada (6)');
INSERT INTO dominios.administracao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.administracao (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.administracao OWNER TO postgres;

CREATE TABLE dominios.jurisdicao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT jurisdicao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.jurisdicao (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (1,'Federal (1)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (2,'Estadual/Distrital (2)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (3,'Municipal (3)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (4,'Internacional (4)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (8,'Propriedade particular (8)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.jurisdicao OWNER TO postgres;

CREATE TABLE dominios.revestimento (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT revestimento_pk PRIMARY KEY (code)
);

INSERT INTO dominios.revestimento (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (1,'Sem revestimento (leito natural) (1)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (2,'Revestimento primário (solto) (2)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (3,'Pavimentado (3)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (4,'Madeira (4)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (99,'Outros (99)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.revestimento OWNER TO postgres;

CREATE TABLE dominios.situacao_fisica (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT situacao_fisica_pk PRIMARY KEY (code)
);

INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (1,'Abandonada (1)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (2,'Destruída (2)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (3,'Em construção (3)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (4,'Planejada (4)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (5,'Construída (5)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (6,'Construída, mas em obras (6)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.situacao_fisica OWNER TO postgres;


CREATE TABLE dominios.trafego (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT trafego_pk PRIMARY KEY (code)
);

INSERT INTO dominios.trafego (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.trafego (code,code_name) VALUES (1,'Permanente (1)');
INSERT INTO dominios.trafego (code,code_name) VALUES (2,'Periódico (2)');
INSERT INTO dominios.trafego (code,code_name) VALUES (4,'Temporário (4)');
INSERT INTO dominios.trafego (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.trafego OWNER TO postgres;

CREATE TABLE dominios.tipo_pavimentacao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_pavimentacao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (2,'Asfalto (2)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (3,'Placa de concreto (3)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (4,'Pedra regular (4)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (5,'Ladrilho de concreto (5)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (6,'Paralelepípedo (6)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (7,'Pedra irregular (7)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (99,'Outros (99)');
INSERT INTO dominios.tipo_pavimentacao (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.tipo_pavimentacao OWNER TO postgres;

CREATE TABLE dominios.tipo_via (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_via_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_via (code,code_name) VALUES (1,'Logradouro (1)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (2,'Rodovia (2)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (3,'Beco (3)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (4,'Autoestrada (4)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (5,'Ligação entre pistas (5)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (6,'Trecho de entroncamento (6)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (7,'Servidão (7)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (99,'Outros (99)');
INSERT INTO dominios.tipo_via (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

ALTER TABLE dominios.tipo_via OWNER TO postgres;


CREATE TABLE edgv.rot_trecho_rede_rodoviaria_l
(
    id SERIAL NOT NULL,
    nome character varying(80),
    geometriaaproximada boolean NOT NULL,
    jurisdicao smallint NOT NULL DEFAULT 9999,
    administracao smallint NOT NULL DEFAULT 9999,
    concessionaria character varying(100),
    revestimento smallint NOT NULL DEFAULT 9999,
    operacional smallint NOT NULL DEFAULT 9999,
    situacaofisica smallint NOT NULL DEFAULT 9999,
    canteirodivisorio smallint NOT NULL DEFAULT 9999,
    nrpistas integer,
    nrfaixas integer,
    trafego smallint NOT NULL DEFAULT 9999,
    tipopavimentacao smallint NOT NULL DEFAULT 9999,
    tipovia smallint NOT NULL DEFAULT 9999,
    sigla character varying(255),
    codtrechorod varchar(25),
    trechoemperimetrourbano smallint NOT NULL DEFAULT 9999,
	acostamento smallint NOT NULL DEFAULT 9999,
    limitevelocidade real,
    limitevelocidadeveiculospesados real,
    bidirecional boolean NOT NULL,
    larguramaxima real,
    alturamaxima real,
    tonelagemmaxima real,
    proibidocaminhoes boolean DEFAULT false,
    observacao character varying(255),
    geom geometry(MultiLineString,4674),
    CONSTRAINT rot_trecho_rede_rodoviaria_l_pk PRIMARY KEY (id)
        WITH (FILLFACTOR=80),
    CONSTRAINT rot_trecho_rede_rodoviaria_l_administracao_fk FOREIGN KEY (administracao)
        REFERENCES dominios.administracao (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_canteirodivisorio_fk FOREIGN KEY (canteirodivisorio)
        REFERENCES dominios.auxiliar (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_jurisdicao_fk FOREIGN KEY (jurisdicao)
        REFERENCES dominios.jurisdicao (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_operacional_fk FOREIGN KEY (operacional)
        REFERENCES dominios.auxiliar (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_revestimento_fk FOREIGN KEY (revestimento)
        REFERENCES dominios.revestimento (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_situacaofisica_fk FOREIGN KEY (situacaofisica)
        REFERENCES dominios.situacao_fisica (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_tipopavimentacao_fk FOREIGN KEY (tipopavimentacao)
        REFERENCES dominios.tipo_pavimentacao (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_tipovia_fk FOREIGN KEY (tipovia)
        REFERENCES dominios.tipo_via (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_trafego_fk FOREIGN KEY (trafego)
        REFERENCES dominios.trafego (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_trechoemperimetrourbano_fk FOREIGN KEY (trechoemperimetrourbano)
        REFERENCES dominios.auxiliar (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT rot_trecho_rede_rodoviaria_l_acostamento_fk FOREIGN KEY (acostamento)
        REFERENCES dominios.auxiliar (code) MATCH FULL
        ON UPDATE NO ACTION
        ON DELETE NO ACTION   
)
TABLESPACE pg_default;

ALTER TABLE edgv.rot_trecho_rede_rodoviaria_l
    OWNER to postgres;

CREATE INDEX rot_trecho_rede_rodoviaria_l_geom
    ON edgv.rot_trecho_rede_rodoviaria_l USING gist
    (geom)
    TABLESPACE pg_default;



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


CREATE TRIGGER a_explode_geom
    BEFORE INSERT OR UPDATE 
    ON edgv.rot_trecho_rede_rodoviaria_l
    FOR EACH ROW
    EXECUTE PROCEDURE public.explode_geom();


CREATE TABLE edgv.rot_restricao
(
    id serial NOT NULL,
    id_1 integer,
    id_2 integer,
    CONSTRAINT rot_restricao_pk PRIMARY KEY (id)
        WITH (FILLFACTOR=80)
)
TABLESPACE pg_default;

ALTER TABLE edgv.rot_restricao
    OWNER to postgres;

GRANT ALL ON TABLE edgv.rot_restricao TO postgres;