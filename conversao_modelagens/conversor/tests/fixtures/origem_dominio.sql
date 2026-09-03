-- Insumo degenerado para a checagem de dominio. Nao e um modelo EDGV: existe
-- para exercitar CADA eixo que `checar_dominios` afirma medir, e so isso.
--
--   tipo             mesmo nome nos dois lados, dominio ENCOLHE (3 e 4 somem)
--   tipo_renomeado   idem, mas o destino chama de `tipo_novo_nome`
--   tipo_filtrado    idem, mas o filtro da classe ja tira 3 e 4
--   tipo_traduzido   idem, mas o mapeamento traduz 3 e 4
--   tipo_default     idem, mas o mapeamento grava um default no destino
--   tipo_igual       dominio identico nos dois lados, nao pode acusar nada
--   tipo_com_filtro  dominio identico, mas o destino tem CHECK que estreita

CREATE TABLE dominios.tipo_teste (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_teste_pk PRIMARY KEY (code)
);
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (1,'um (1)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (2,'dois (2)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (3,'tres (3)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (4,'quatro (4)');
INSERT INTO dominios.tipo_teste (code,code_name) VALUES (9999,'A SER PREENCHIDO (9999)');

CREATE TABLE dominios.igual_dom (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT igual_dom_pk PRIMARY KEY (code)
);
INSERT INTO dominios.igual_dom (code,code_name) VALUES (1,'um (1)');
INSERT INTO dominios.igual_dom (code,code_name) VALUES (2,'dois (2)');

-- dominio com uma terceira coluna na lista do INSERT, como o `filter` de
-- tipo_edificacao na Topo 1.4. Exigir `(code, code_name)` cegava a checagem
-- em oito dominios reais, entre eles o maior do modelo.
CREATE TABLE dominios.dom_com_filtro (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text,
	 CONSTRAINT dom_com_filtro_pk PRIMARY KEY (code)
);
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (1,'um (1)','grupo A');
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (5,'cinco (5)','grupo B');
INSERT INTO dominios.dom_com_filtro (code,code_name, filter) VALUES (9999,'A SER PREENCHIDO (9999)','grupo A');

CREATE TABLE edgv.classe_velha_l(
	 id uuid NOT NULL,
	 tipo smallint NOT NULL,
	 tipo_renomeado smallint NOT NULL,
	 tipo_filtrado smallint NOT NULL,
	 tipo_traduzido smallint NOT NULL,
	 tipo_default smallint NOT NULL,
	 tipo_igual smallint NOT NULL,
	 tipo_com_filtro smallint NOT NULL,
	 geom geometry(MultiLinestring, 4674)
);
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a1 FOREIGN KEY (tipo) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a2 FOREIGN KEY (tipo_renomeado) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a3 FOREIGN KEY (tipo_filtrado) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a4 FOREIGN KEY (tipo_traduzido) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a5 FOREIGN KEY (tipo_default) REFERENCES dominios.tipo_teste (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a6 FOREIGN KEY (tipo_igual) REFERENCES dominios.igual_dom (code) MATCH FULL;
ALTER TABLE edgv.classe_velha_l ADD CONSTRAINT a7 FOREIGN KEY (tipo_com_filtro) REFERENCES dominios.dom_com_filtro (code) MATCH FULL;
