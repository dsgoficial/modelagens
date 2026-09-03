-- O par do `origem_dominio.sql`. O dominio `tipo_teste` perde 3 e 4, e a classe
-- ganha um CHECK que estreita `tipo_com_filtro` para menos do que a FK permite.

CREATE TABLE dominios.tipo_teste (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_teste_pk PRIMARY KEY (code)
);
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (1,'um (1)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (2,'dois (2)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (7,'tres (7)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

CREATE TABLE dominios.igual_dom (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT igual_dom_pk PRIMARY KEY (code)
);
INSERT INTO dominios.igual_dom (code,code_name) VALUES (1,'um (1)');
INSERT INTO dominios.igual_dom (code,code_name) VALUES (2,'dois (2)');

CREATE TABLE dominios.dom_com_filtro (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text,
	 CONSTRAINT dom_com_filtro_pk PRIMARY KEY (code)
);
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (1,'um (1)','grupo A');
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (5,'cinco (5)','grupo B');
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (9999,'A SER PREENCHIDO (9999)','grupo A');

CREATE TABLE edgv.classe_nova_l(
	 id uuid NOT NULL,
	 tipo smallint NOT NULL,
	 tipo_novo_nome smallint NOT NULL,
	 tipo_filtrado smallint NOT NULL,
	 tipo_traduzido smallint NOT NULL,
	 tipo_default smallint NOT NULL,
	 tipo_igual smallint NOT NULL,
	 tipo_com_filtro smallint NOT NULL,
	 geom geometry(MultiLinestring, 4674)
);
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b1 FOREIGN KEY (tipo) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b2 FOREIGN KEY (tipo_novo_nome) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b3 FOREIGN KEY (tipo_filtrado) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b4 FOREIGN KEY (tipo_traduzido) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b5 FOREIGN KEY (tipo_default) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b6 FOREIGN KEY (tipo_igual) REFERENCES dominios.igual_dom (code) MATCH FULL;
ALTER TABLE edgv.classe_nova_l ADD CONSTRAINT b7 FOREIGN KEY (tipo_com_filtro) REFERENCES dominios.dom_com_filtro (code) MATCH FULL;

ALTER TABLE edgv.classe_nova_l
	 ADD CONSTRAINT classe_nova_l_tipo_com_filtro_check
	 CHECK (tipo_com_filtro = ANY(ARRAY[1 :: SMALLINT, 9999 :: SMALLINT]));
