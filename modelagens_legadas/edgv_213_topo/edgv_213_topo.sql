CREATE SCHEMA edgv;
CREATE SCHEMA dominios;

CREATE EXTENSION postgis;
SET search_path TO pg_catalog,public,edgv,dominios;

CREATE TABLE public.db_metadata(
	 edgvversion varchar(50) NOT NULL DEFAULT 'EDGV 2.1.3 Topo',
	 dbimplversion varchar(50) NOT NULL DEFAULT '5.4.1',
	 CONSTRAINT edgvversioncheck CHECK (edgvversion = 'EDGV 2.1.3 Topo')
);
INSERT INTO public.db_metadata (edgvversion, dbimplversion) VALUES ('EDGV 2.1.3 Topo','5.4.1');

CREATE TABLE dominios.tipo_comprovacao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_comprovacao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_comprovacao (code,code_name) VALUES (1,'Confirmado em campo (1)');
INSERT INTO dominios.tipo_comprovacao (code,code_name) VALUES (2,'Não possível de confirmar em campo (2)');
INSERT INTO dominios.tipo_comprovacao (code,code_name) VALUES (3,'Feição não necessita de confirmação (3)');
INSERT INTO dominios.tipo_comprovacao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_comprovacao OWNER TO postgres;

CREATE TABLE dominios.tipo_insumo (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_insumo_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (1,'Fotointerpretado (1)');
INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (2,'Insumo externo (2)');
INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (3,'Processo automático (3)');
INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (4,'Aquisição em campo (4)');
INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (5,'Mapeamento anterior (5)');
INSERT INTO dominios.tipo_insumo (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_insumo OWNER TO postgres;

CREATE TABLE dominios.administracao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT administracao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.administracao (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.administracao (code,code_name) VALUES (1,'Federal (1)');
INSERT INTO dominios.administracao (code,code_name) VALUES (2,'Estadual (2)');
INSERT INTO dominios.administracao (code,code_name) VALUES (3,'Municipal (3)');
INSERT INTO dominios.administracao (code,code_name) VALUES (6,'Particular (6)');
INSERT INTO dominios.administracao (code,code_name) VALUES (7,'Concessionada (7)');
INSERT INTO dominios.administracao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.administracao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.administracao OWNER TO postgres;

CREATE TABLE dominios.booleano (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT booleano_pk PRIMARY KEY (code)
);

INSERT INTO dominios.booleano (code,code_name) VALUES (1,'Sim (1)');
INSERT INTO dominios.booleano (code,code_name) VALUES (2,'Não (2)');
INSERT INTO dominios.booleano (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.booleano OWNER TO postgres;

CREATE TABLE dominios.booleano_estendido (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT booleano_estendido_pk PRIMARY KEY (code)
);

INSERT INTO dominios.booleano_estendido (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.booleano_estendido (code,code_name) VALUES (1,'Sim (1)');
INSERT INTO dominios.booleano_estendido (code,code_name) VALUES (2,'Não (2)');
INSERT INTO dominios.booleano_estendido (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.booleano_estendido OWNER TO postgres;

CREATE TABLE dominios.canteiro_divisorio (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT canteiro_divisorio_pk PRIMARY KEY (code)
);

INSERT INTO dominios.canteiro_divisorio (code,code_name) VALUES (1,'Sim (1)');
INSERT INTO dominios.canteiro_divisorio (code,code_name) VALUES (2,'Não (2)');
INSERT INTO dominios.canteiro_divisorio (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.canteiro_divisorio OWNER TO postgres;

CREATE TABLE dominios.finalidade (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT finalidade_pk PRIMARY KEY (code)
);

INSERT INTO dominios.finalidade (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.finalidade (code,code_name) VALUES (2,'Tratamento (2)');
INSERT INTO dominios.finalidade (code,code_name) VALUES (3,'Recalque (3)');
INSERT INTO dominios.finalidade (code,code_name) VALUES (4,'Distribuição (4)');
INSERT INTO dominios.finalidade (code,code_name) VALUES (8,'Armazenamento (8)');
INSERT INTO dominios.finalidade (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.finalidade OWNER TO postgres;

CREATE TABLE dominios.forma_extracao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT forma_extracao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.forma_extracao (code,code_name) VALUES (5,'A céu aberto (5)');
INSERT INTO dominios.forma_extracao (code,code_name) VALUES (6,'Subterrânea (6)');
INSERT INTO dominios.forma_extracao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.forma_extracao OWNER TO postgres;

CREATE TABLE dominios.indice (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT indice_pk PRIMARY KEY (code)
);

INSERT INTO dominios.indice (code,code_name) VALUES (1,'Mestra (1)');
INSERT INTO dominios.indice (code,code_name) VALUES (2,'Normal (2)');
INSERT INTO dominios.indice (code,code_name) VALUES (3,'Auxiliar (3)');
INSERT INTO dominios.indice (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.indice OWNER TO postgres;

CREATE TABLE dominios.jurisdicao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT jurisdicao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.jurisdicao (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (1,'Federal (1)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (2,'Estadual (2)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (3,'Municipal (3)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (6,'Particular (6)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.jurisdicao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.jurisdicao OWNER TO postgres;

CREATE TABLE dominios.material_construcao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT material_construcao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.material_construcao (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (1,'Alvenaria (1)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (2,'Concreto (2)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (3,'Metal (3)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (4,'Rocha (4)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (5,'Madeira (5)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (6,'Arame (6)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (7,'Tela ou alambrado (7)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (8,'Cerca viva (8)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (23,'Terra (23)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (98,'Outros (98)');
INSERT INTO dominios.material_construcao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.material_construcao OWNER TO postgres;

CREATE TABLE dominios.modal_uso (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT modal_uso_pk PRIMARY KEY (code)
);

INSERT INTO dominios.modal_uso (code,code_name) VALUES (4,'Rodoviário (4)');
INSERT INTO dominios.modal_uso (code,code_name) VALUES (5,'Ferroviário (5)');
INSERT INTO dominios.modal_uso (code,code_name) VALUES (6,'Metroviário (6)');
INSERT INTO dominios.modal_uso (code,code_name) VALUES (8,'Rodoferroviário (8)');
INSERT INTO dominios.modal_uso (code,code_name) VALUES (9,'Aeroportuário (9)');
INSERT INTO dominios.modal_uso (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.modal_uso OWNER TO postgres;

CREATE TABLE dominios.nr_linhas (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT nr_linhas_pk PRIMARY KEY (code)
);

INSERT INTO dominios.nr_linhas (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.nr_linhas (code,code_name) VALUES (1,'Simples (1)');
INSERT INTO dominios.nr_linhas (code,code_name) VALUES (2,'Dupla (2)');
INSERT INTO dominios.nr_linhas (code,code_name) VALUES (3,'Múltipla (3)');
INSERT INTO dominios.nr_linhas (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.nr_linhas OWNER TO postgres;

CREATE TABLE dominios.posicao_pista (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT posicao_pista_pk PRIMARY KEY (code)
);

INSERT INTO dominios.posicao_pista (code,code_name) VALUES (12,'Adjacentes (12)');
INSERT INTO dominios.posicao_pista (code,code_name) VALUES (13,'Superpostas (13)');
INSERT INTO dominios.posicao_pista (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.posicao_pista (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.posicao_pista OWNER TO postgres;

CREATE TABLE dominios.posicao_relativa (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT posicao_relativa_pk PRIMARY KEY (code)
);

INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (2,'Superfície (2)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (3,'Elevado (3)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (4,'Emerso (4)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (5,'Submerso (5)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (6,'Subterrâneo (6)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (14,'Isolada (14)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (17,'Adjacente a edificação (17)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (18,'Sobre edificação (18)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.posicao_relativa (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.posicao_relativa OWNER TO postgres;

CREATE TABLE dominios.referencial_altim (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT referencial_altim_pk PRIMARY KEY (code)
);

INSERT INTO dominios.referencial_altim (code,code_name) VALUES (1,'Torres (1)');
INSERT INTO dominios.referencial_altim (code,code_name) VALUES (2,'Imbituba (2)');
INSERT INTO dominios.referencial_altim (code,code_name) VALUES (3,'Santana (3)');
INSERT INTO dominios.referencial_altim (code,code_name) VALUES (4,'Local (4)');
INSERT INTO dominios.referencial_altim (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.referencial_altim OWNER TO postgres;

CREATE TABLE dominios.referencial_grav (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT referencial_grav_pk PRIMARY KEY (code)
);

INSERT INTO dominios.referencial_grav (code,code_name) VALUES (1,'Postdam 1930 (1)');
INSERT INTO dominios.referencial_grav (code,code_name) VALUES (2,'IGSN71 (2)');
INSERT INTO dominios.referencial_grav (code,code_name) VALUES (3,'Absoluto (3)');
INSERT INTO dominios.referencial_grav (code,code_name) VALUES (4,'Local (4)');
INSERT INTO dominios.referencial_grav (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.referencial_grav (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.referencial_grav OWNER TO postgres;

CREATE TABLE dominios.regime (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT regime_pk PRIMARY KEY (code)
);

INSERT INTO dominios.regime (code,code_name) VALUES (1,'Permanente (1)');
INSERT INTO dominios.regime (code,code_name) VALUES (3,'Temporário (3)');
INSERT INTO dominios.regime (code,code_name) VALUES (5,'Seco (5)');
INSERT INTO dominios.regime (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.regime OWNER TO postgres;

CREATE TABLE dominios.revestimento (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT revestimento_pk PRIMARY KEY (code)
);

INSERT INTO dominios.revestimento (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (1,'Leito natural (1)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (2,'Revestimento primário (solto) (2)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (3,'Pavimentado (3)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (4,'Calçado (4)');
INSERT INTO dominios.revestimento (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.revestimento OWNER TO postgres;

CREATE TABLE dominios.sistema_geodesico (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT sistema_geodesico_pk PRIMARY KEY (code)
);

INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (1,'SAD 69 (1)');
INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (2,'SIRGAS 2000 (2)');
INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (3,'WGS-84 (3)');
INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (4,'Córrego Alegre (4)');
INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (5,'Astro Chuá (5)');
INSERT INTO dominios.sistema_geodesico (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.sistema_geodesico OWNER TO postgres;

CREATE TABLE dominios.situacao_fisica (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT situacao_fisica_pk PRIMARY KEY (code)
);

INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (0,'Desconhecida (0)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (1,'Abandonada (1)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (2,'Destruída (2)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (3,'Construída (3)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (4,'Em construção (4)');
INSERT INTO dominios.situacao_fisica (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.situacao_fisica OWNER TO postgres;

CREATE TABLE dominios.situacao_marco (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT situacao_marco_pk PRIMARY KEY (code)
);

INSERT INTO dominios.situacao_marco (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (1,'Bom (1)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (2,'Destruído (2)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (3,'Destruído sem chapa (3)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (4,'Destruído com chapa danificada (4)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (5,'Não encontrado (5)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (6,'Não visitado (6)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.situacao_marco (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.situacao_marco OWNER TO postgres;

CREATE TABLE dominios.tipo_corpo_dagua (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_corpo_dagua_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (1,'Rio (1)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (2,'Canal (2)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (3,'Oceano (3)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (4,'Baía (4)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (5,'Enseada (5)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (6,'Meandro abandonado (6)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (7,'Lago ou Lagoa (7)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (9,'Laguna (9)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (10,'Represa (10)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (11,'Açude (11)');
INSERT INTO dominios.tipo_corpo_dagua (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_corpo_dagua OWNER TO postgres;

CREATE TABLE dominios.tipo_delimitacao_fisica (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_delimitacao_fisica_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_delimitacao_fisica (code,code_name) VALUES (1,'Cerca (1)');
INSERT INTO dominios.tipo_delimitacao_fisica (code,code_name) VALUES (2,'Muro (2)');
INSERT INTO dominios.tipo_delimitacao_fisica (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_delimitacao_fisica OWNER TO postgres;

CREATE TABLE dominios.tipo_deposito (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_deposito_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (108,'Geral - Galpão (108)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (109,'Geral - Silo (109)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (110,'Geral - Composteira (110)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (111,'Geral - Depósito frigorífico (111)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (132,'Geral - Armazém (132)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (198,'Geral - Outros (198)','Depósito geral');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (201,'Abast água - Tanque de água (201)','Depósito de abastecimento de água');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (202,'Abast água - Caixa de água (202)','Depósito de abastecimento de água');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (203,'Abast água - Cisterna (203)','Depósito de abastecimento de água');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (298,'Abast água - Outros (298)','Depósito de abastecimento de água');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (301,'San - Tanque de saneamento (301)','Depósito de saneamento');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (304,'San - Depósito de lixo (304)','Depósito de saneamento');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (305,'San - Aterro sanitário (305)','Depósito de saneamento');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (306,'San - Aterro controlado (306)','Depósito de saneamento');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (398,'San - Outros (398)','Depósito de saneamento');
INSERT INTO dominios.tipo_deposito (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_deposito OWNER TO postgres;

CREATE TABLE dominios.tipo_edificacao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_edificacao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (0,'Edificação genérica (0)','Edificação genérica');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1,'Edificação destruída (1)','Edificação genérica');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2,'Edificação abandonada (2)','Edificação genérica');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (101,'Com - Centro de operações de comunicação (101)','Edificação de comunicação');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (102,'Com - Central de comutação e transmissão (102)','Edificação de comunicação');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (103,'Com - Estação rádio-base (103)','Edificação de comunicação');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (104,'Com - Estação repetidora (104)','Edificação de comunicação');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (201,'Edificação de energia (201)','Edificação de energia');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (301,'Abast - Edificação de captação de água (301)','Edificação de abastecimento de água');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (302,'Abast - Edificação de tratamento de água (302)','Edificação de abastecimento de água');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (303,'Abast - Edificação de recalque de água (303)','Edificação de abastecimento de água');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (395,'Abast - Mista (395)','Edificação de abastecimento de água');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (398,'Abast - Outros (398)','Edificação de abastecimento de água');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (403,'Saneam - Edificação de recalque de resíduos (403)','Edificação de saneamento');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (405,'Saneam - Edificação de tratamento de esgoto (405)','Edificação de saneamento');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (406,'Saneam - Usina de reciclagem (406)','Edificação de saneamento');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (407,'Saneam - Incinerador de resíduos (407)','Edificação de saneamento');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (498,'Saneam - Outros (498)','Edificação de saneamento');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (516,'Ens - Edificação de educação infantil – creche (516)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (517,'Ens - Edificação de educação infantil - pré-escola (517)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (518,'Ens - Edificação de ensino fundamental (518)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (519,'Ens - Edificação de ensino médio (519)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (520,'Ens - Edificação de educação superior – Graduação (520)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (521,'Ens - Edificação de educação superior – graduação e pós-graduação (521)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (522,'Ens - Edificação de educação superior – pós-graduação e extensão (522)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (523,'Ens - Edificação de educação professional de nível técnico (523)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (524,'Ens - Edificação de educação profissional de nível tecnológico (524)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (525,'Ens - Outras atividades de ensino (525)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (595,'Ens - Misto (595)','Edificação de ensino');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (601,'Rel - Igreja (601)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (602,'Rel - Templo (602)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (603,'Rel - Centro religioso (603)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (604,'Rel - Mosteiro (604)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (605,'Rel - Convento (605)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (606,'Rel - Mesquita (606)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (607,'Rel - Sinagoga (607)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (698,'Rel - Outros (698)','Edificação religiosa');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (709,'Tur - Cruzeiro (709)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (710,'Tur - Estátua (710)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (711,'Tur - Mirante (711)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (712,'Tur - Monumento (712)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (713,'Tur - Panteão (713)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (798,'Tur - Outros (798)','Edificação ou construção turística');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (801,'Laz - Estádio (801)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (802,'Laz - Ginásio (802)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (803,'Laz - Museu (803)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (804,'Laz - Teatro (804)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (805,'Laz - Anfiteatro (805)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (806,'Laz - Cinema (806)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (807,'Laz - Centro cultural (807)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (808,'Laz - Plataforma de pesca (808)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (898,'Laz - Outros (898)','Edificação de lazer');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (903,'Comerc - Centro comercial (903)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (904,'Comerc - Mercado (904)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (905,'Comerc - Centro de convenções (905)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (906,'Comerc - Feira (906)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (907,'Comerc - Hotel / motel / pousada (907)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (998,'Comerc - Outros (998)','Edificação de comércio e serviço');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1015,'Ind - Fabricação alimentícia e bebidas (1015)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1016,'Ind - Fabricação de produtos do fumo (1016)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1017,'Ind - Fabricação de produtos têxteis (1017)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1018,'Ind - Confecção de artigos de vestuário e acessórios (1018)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1019,'Ind - Preparação de couros, artefatos de couro, artigos de viagem e calçados (1019)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1020,'Ind - Fabricação de produtos de madeira e celulose (1020)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1021,'Ind - Fabricação de celulose, papel e produtos de papel (1021)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1022,'Ind - Industria de edição, impressão e reprodução de gravações (1022)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1023,'Ind - Fabricação de coque, refino de petróleo, elaboração de combustíveis nucleares e produção de álcool (1023)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1024,'Ind - Fabricação de produtos químicos (1024)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1025,'Ind - Fabricação de artigos de borracha e material plástico (1025)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1026,'Ind - Fabricação de produtos de minerais não-metálicos (1026)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1027,'Ind - Indústria de metalurgia básica (1027)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1028,'Ind - Fabricação de produtos de metal (1028)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1029,'Ind - Fabricação de máquinas e equipamentos (1029)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1030,'Ind - Fabriação de máquinas de escritório e equipamentos de informática (1030)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1031,'Ind - Fabricação de máquinas, aparelhos e materiais elétricos (1031)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1032,'Ind - Fabricação de material eletrônico, de aparelhos e equipamentos de comunicações (1032)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1033,'Ind - Fabricação de equipamentos de instrumentação médico-hospitalares, instrumentos de precisão e ópticos, automação industrial, cronômetros e relógios (1033)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1034,'Ind - Fabricação e montagem de veículos automotores, reboques e carrocerias (1034)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1035,'Ind - Fabricação de outros equipamentos de transporte (1035)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1036,'Ind - Fabricação de móveis e indústrias diversas (1036)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1037,'Ind - Indústria reciclagem (1037)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1045,'Ind - Indústria de construção (1045)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1098,'Ind - Outros (1098)','Edificação industrial');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1110,'Ext Min - Extração de carvão mineral (1110)','Edificação de extração mineral');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1111,'Ext Min - Extração de petróleo e serviços relacionados (1111)','Edificação de extração mineral');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1113,'Ext Min - Extração de minerais metálicos (1113)','Edificação de extração mineral');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1114,'Ext Min - Extração de minerais não-metálicos (1114)','Edificação de extração mineral');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1198,'Ext Min - Outros (1198)','Edificação de extração mineral');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1212,'Agro - Sede operacional de fazenda (1212)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1213,'Agro - Aviário (1213)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1214,'Agro - Apiário (1214)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1215,'Agro - Viveiro de plantas (1215)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1216,'Agro - Viveiro para aquicultura (1216)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1217,'Agro - Pocilga (1217)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1218,'Agro - Curral (1218)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1298,'Agro - Outros (1298)','Edificação agropecuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1301,'Pub Civ - Policial (1301)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1302,'Pub Civ - Prisional (1302)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1303,'Pub Civ - Cartorial (1303)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1304,'Pub Civ - Gestão pública (1304)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1305,'Pub Civ - Eleitoral (1305)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1306,'Pub Civ - Produção ou pequisa pública (1306)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1307,'Pub Civ - Seguridade social (1307)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1308,'Pub Civ - Câmara municipal (1308)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1309,'Pub Civ - Assembléia legislativa (1309)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1322,'Pub Civ - Prefeitura (1322)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1398,'Pub Civ - Outros (1398)','Edificação pública civil');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1401,'Habitacão indigena (1401)','Habitacão indigena');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1501,'Edificação de medição de fenômenos (1501)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1601,'Estação Climatológica Principal (1601)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1602,'Estação Climatológica Auxiliar (1602)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1603,'Estação Agroclimatológica (1603)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1604,'Estação Pluviométrica (1604)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1605,'Estação Eólica (1605)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1606,'Estação Evaporimétrica (1606)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1607,'Estação Solarimétrica (1607)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1608,'Estação de Radar Metereológico (1608)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1609,'Estação de Radiossonda (1609)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1610,'Estação Fluviométrica (1610)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1611,'Estação Maregráfica (1611)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1612,'Estação de Marés Terrestre - Crosta (1612)','Medição de fenômenos');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1712,'Pub Mil - Aquartelamento (1712)','Edificação militar');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1717,'Pub Mil - Hotel de trânsito (1717)','Edificação militar');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1718,'Pub Mil - Delegacia de serviço militar (1718)','Edificação militar');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1719,'Pub Mil - Posto policial militar (1719)','Edificação militar');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1798,'Pub Mil - Outros (1798)','Edificação militar');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1820,'Pol Rod - Posto polícia rodoviária militar (1820)','Posto de polícia rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1821,'Pol Rod - Posto polícia rodoviária federal (1821)','Posto de polícia rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1910,'Posto Fisc - Tributação (1910)','Posto fiscal');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1911,'Posto Fisc - Fiscalização (1911)','Posto fiscal');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (1995,'Posto Fisc - Misto (1995)','Posto fiscal');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2025,'Sau - Atendimento hospitalar (2025)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2026,'Sau - Atendimento hospitalar especializado (2026)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2027,'Sau - Atendimento a urgência e emergências (pronto socorro) (2027)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2028,'Sau - Atenção ambulatorial (posto e centro de saúde) (2028)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2029,'Sau - Serviços de complementação diagnóstica ou terapêutica (2029)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2030,'Sau - Outras atividades relacionadas com a atenção à saúde (instituto de pesquisa) (2030)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2031,'Sau - Serviços veterinários (2031)','Edificação de saúde');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2132,'SSoc - Alojamento (2132)','Edificação de serviço social');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2133,'SSoc - Serviços sociais (2133)','Edificação de serviço social');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2195,'SSoc - Misto (2195)','Edificação de serviço social');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2208,'Rod - Terminal interestadual (2208)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2209,'Rod - Terminal urbano (2209)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2210,'Rod - Parada interestadual (2210)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2212,'Rod - Posto de pesagem (2212)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2213,'Rod - Posto de pedágio (2213)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2214,'Rod - Posto de fiscalização rodoviária (2214)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2298,'Rod - Outros (2298)','Edificação rodoviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2316,'Ferrov - Estação ferroviária de passageiros (2316)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2317,'Ferrov - Estação metroviária (2317)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2318,'Ferrov - Terminal ferroviário de cargas (2318)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2319,'Ferrov - Terminal ferroviário de passageiros e cargas (2319)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2320,'Ferrov - Oficina de manutenção (2320)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2398,'Ferrov - Outros (2398)','Edificação ferroviária ou metroviária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2426,'Aero - Terminal de passageiros (2426)','Edificação aeroportuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2427,'Aero - Terminal de cargas (2427)','Edificação aeroportuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2428,'Aero - Torre de controle (2428)','Edificação aeroportuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2429,'Aero - Hangar (2429)','Edificação aeroportuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2498,'Aero - Outros (2498)','Edificação aeroportuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2526,'Port - Terminal de passageiros (2526)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2527,'Port - Terminal de cargas (2527)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2533,'Port - Estaleiro (2533)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2534,'Port - Dique de estaleiro (2534)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2535,'Port - Rampa portuária (2535)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2536,'Port - Carreira portuária (2536)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2598,'Port - Outros (2598)','Edificação portuária');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2601,'Posto de combustivel (2601)','Posto de combustivel');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (2701,'Edificação habitacional (2701)','Edificação habitacional');
INSERT INTO dominios.tipo_edificacao (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_edificacao OWNER TO postgres;

CREATE TABLE dominios.tipo_elemento_fisiografico (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_elemento_fisiografico_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (1,'Serra (1)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (2,'Morro (2)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (3,'Montanha (3)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (4,'Chapada (4)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (5,'Maciço (5)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (6,'Planalto (6)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (7,'Planície (7)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (8,'Escarpa (8)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (9,'Península (9)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (10,'Ponta (10)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (11,'Cabo (11)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (12,'Praia (12)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (13,'Falésia (13)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (14,'Talude (14)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (15,'Dolina (15)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (16,'Duna (16)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (17,'Pico (17)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (19,'Gruta (19)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (20,'Caverna (20)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (21,'Rocha - Matacão/pedra (21)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (22,'Rocha - Penedo isolado (22)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (23,'Rocha - Area rochosa/lajedo (23)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (24,'Caixa de empréstimo (24)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (25,'Área aterrada (25)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (26,'Corte (26)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (27,'Aterro (27)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (28,'Resíduo de bota-fora (28)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (29,'Resíduo sólido em geral (29)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (30,'Ilha Fluvial (30)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (31,'Ilha Marítima (31)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (32,'Ilha Lacustre (32)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (33,'Ilha Mista (33)');
INSERT INTO dominios.tipo_elemento_fisiografico (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_elemento_fisiografico OWNER TO postgres;

CREATE TABLE dominios.tipo_elemento_hidrografico (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_elemento_hidrografico_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (1,'Poço dágua (1)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (2,'Poço artesiano (2)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (3,'Olho dágua (3)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (4,'Sumidouro (4)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (5,'Vertedouro (5)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (6,'Foz marítima (6)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (7,'Nascente (7)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (8,'Rocha em água (8)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (9,'Cachoeira (9)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (10,'Salto (10)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (11,'Catarata (11)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (12,'Corredeira (12)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (13,'Terreno sujeito a inundação (13)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (14,'Banco de areia fluvial (14)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (15,'Banco de areia marítimo (15)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (16,'Banco de areia lacustre (16)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (17,'Banco de areia cordão arenoso (17)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (18,'Recife contiguo (18)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (19,'Recife afastado (19)');
INSERT INTO dominios.tipo_elemento_hidrografico (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_elemento_hidrografico OWNER TO postgres;

CREATE TABLE dominios.tipo_elemento_infraestrutura (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_elemento_infraestrutura_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (201,'Condutor hídrico – calha (201)','Condutor Hídrico');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (202,'Condutor hídrico – tubulação (202)','Condutor Hídrico');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (302,'Linha de distribuição de energia (302)','Linha de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (303,'Linha de transmissão de energia (303)','Linha de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (405,'Estação geradora - Eólica (405)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (406,'Estação geradora - Solar (406)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (407,'Estação geradora - Maré-motriz (407)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (408,'Estação geradora - Hidrelétrica (408)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (409,'Estação geradora - Termelétrica nuclear (409)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (410,'Estação geradora - Termelétrica a carvão (410)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (411,'Estação geradora - Termelétrica a diesel (411)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (412,'Estação geradora - Termelétrica a gás (412)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (495,'Estação geradora - Mista (495)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (498,'Estação geradora - Outras (498)','Estação geradora de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (601,'Grupo de transformadores (601)','Grupo de transformadores');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (701,'Quebramar (701)','Quebramar');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (801,'Molhe (801)','Molhe');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (901,'Comporta (901)','Comporta');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1001,'Eclusa (1001)','Eclusa');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1101,'Barragem (1101)','Barragem');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1201,'Torre de comunicação (1201)','Torre de comunicação');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1301,'Antena de comunicação (1301)','Antena de comunicação');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1401,'Torre de energia (1401)','Torre de energia');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1501,'Galeria ou bueiro (1501)','Galeria ou bueiro');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1601,'Equip agro - Pivô central (1601)','Equipamento agropecuário');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1698,'Equip agro - Outros (1698)','Equipamento agropecuário');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1700,'Duto - Desconhecido (1700)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1701,'Duto - Água (1701)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1702,'Duto - Óleo (1702)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1703,'Duto - Gasolina (1703)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1704,'Duto - Álcool (1704)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1705,'Duto - Querosene (1705)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1706,'Duto - Petróleo (1706)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1707,'Duto - Nafta (1707)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1708,'Duto - Gás (1708)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1709,'Duto - Efluentes (1709)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1710,'Duto - Esgoto (1710)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1798,'Duto - Outros (1798)','Duto');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1801,'Calha - Água pluvial (1801)','Calha');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1901,'Correia transp - Minério (1901)','Correia transportadora');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1902,'Correia transp - Grãos (1902)','Correia transportadora');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (1998,'Correia transp - Outros (1998)','Correia transportadora');
INSERT INTO dominios.tipo_elemento_infraestrutura (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_elemento_infraestrutura OWNER TO postgres;

CREATE TABLE dominios.tipo_elemento_transportes (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_elemento_transportes_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (101,'Passagem de nível (101)','Passagem de nível');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (238,'Atrac - Cais (238)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (239,'Atrac - Cais flutuante (239)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (240,'Atrac - Trapiche (240)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (241,'Atrac - Molhe de atracação (241)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (242,'Atrac - Pier (242)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (243,'Atrac - Dolfim (243)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (244,'Atrac - Desembarcadouro (244)','Atracadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (302,'Entroncamento - Círculo rodoviário (302)','Entroncamento');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (303,'Entroncamento - Trevo rodoviário (303)','Entroncamento');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (304,'Entroncamento - Rótula (304)','Entroncamento');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (404,'Sinalização - Farol ou farolete (404)','Sinalização');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (501,'Ciclovia (501)','Ciclovia');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (607,'Pedestre - Passagem subterrânea (607)','Travessia de pedestre');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (608,'Pedestre - Passarela (608)','Travessia de pedestre');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (609,'Pedestre - Pinguela (609)','Travessia de pedestre');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (701,'Girador ferroviário (701)','Girador ferroviário');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (801,'Caminho aéreo - Teleférico (801)','Caminho aéreo');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (898,'Caminho aéreo - Outros (898)','Caminho aéreo');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (901,'Funicular (901)','Funicular');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1001,'Cremalheira (1001)','Cremalheira');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1101,'Fundeadouro (1101)','Fundeadouro');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1201,'Obstáculo de navegação (1201)','Obstáculo de navegação');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1300,'Plataforma desconhecida (1300)','Plataforma');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1301,'Plataforma Petróleo (1301)','Plataforma');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1302,'Plataforma gás (1302)','Plataforma');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1395,'Plataforma mista (1395)','Plataforma');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (1401,'Trecho hidroviário (1401)','Trecho hidroviário');
INSERT INTO dominios.tipo_elemento_transportes (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_elemento_transportes OWNER TO postgres;

CREATE TABLE dominios.tipo_elemento_viario (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_elemento_viario_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (101,'Túnel (101)','Túnel');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (102,'Túnel - Passagem subterrânea sob via (102)','Túnel');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (201,'Ponte móvel (201)','Ponte');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (202,'Ponte pênsil (202)','Ponte');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (203,'Ponte fixa (203)','Ponte');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (301,'Passagem elevada (301)','Passagem elevada / Viaduto');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (302,'Viaduto (302)','Passagem elevada / Viaduto');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (401,'Travessia - Vau natural (401)','Travessia');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (402,'Travessia - Vau construído (402)','Travessia');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (403,'Travessia - Bote transportador (403)','Travessia');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (404,'Travessia - Balsa (404)','Travessia');
INSERT INTO dominios.tipo_elemento_viario (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_elemento_viario OWNER TO postgres;

CREATE TABLE dominios.tipo_exposicao (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_exposicao_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_exposicao (code,code_name) VALUES (3,'Fechado (3)');
INSERT INTO dominios.tipo_exposicao (code,code_name) VALUES (4,'Coberto (4)');
INSERT INTO dominios.tipo_exposicao (code,code_name) VALUES (5,'Céu aberto (5)');
INSERT INTO dominios.tipo_exposicao (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.tipo_exposicao (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_exposicao OWNER TO postgres;

CREATE TABLE dominios.tipo_extracao_mineral (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_extracao_mineral_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (1,'Poço (1)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (4,'Mina (4)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (5,'Garimpo (5)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (6,'Salina (6)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (7,'Pedreira (7)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (8,'Ponto de prospecção (8)');
INSERT INTO dominios.tipo_extracao_mineral (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_extracao_mineral OWNER TO postgres;

CREATE TABLE dominios.tipo_ferrovia (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_ferrovia_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_ferrovia (code,code_name) VALUES (5,'Bonde (5)');
INSERT INTO dominios.tipo_ferrovia (code,code_name) VALUES (6,'Aeromóvel (6)');
INSERT INTO dominios.tipo_ferrovia (code,code_name) VALUES (7,'Trem (7)');
INSERT INTO dominios.tipo_ferrovia (code,code_name) VALUES (8,'Metrô (8)');
INSERT INTO dominios.tipo_ferrovia (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_ferrovia OWNER TO postgres;

CREATE TABLE dominios.tipo_limite_especial (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_limite_especial_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (1,'Terra pública (1)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (2,'Terra indígena (2)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (3,'Quilombo (3)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (4,'Assentamento rural (4)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (8,'Área de preservação permanente (8)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (9,'Reserva legal (9)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (10,'Mosaico (10)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (11,'Distrito florestal (11)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (12,'Corredor ecológico (12)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (13,'Floresta pública (13)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (14,'Sítios RAMSAR (14)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (15,'Sítios do patrimônio (15)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (16,'Reserva da biosfera (16)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (24,'Área de Proteção Ambiental – APA (24)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (25,'Área de Relevante Interesse Ecológico – ARIE (25)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (26,'Floresta – FLO (26)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (27,'Reserva de Desenvolvimento Sustentável – RDS (27)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (28,'Reserva Extrativista – RESEX (28)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (29,'Reserva de Fauna – REFAU (29)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (30,'Reserva Particular do Patrimônio Natural – RPPN (30)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (31,'Estação Ecológica – ESEC (31)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (32,'Parque – PAR (32)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (33,'Monumento Natural – MONA (33)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (34,'Reserva Biológica – REBIO (34)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (35,'Refúgio de Vida Silvestre – RVS (35)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (36,'Área militar (36)');
INSERT INTO dominios.tipo_limite_especial (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_limite_especial OWNER TO postgres;

CREATE TABLE dominios.tipo_limite_legal (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_limite_legal_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (1,'Limite Internacional (1)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (2,'Limite Estadual (2)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (3,'Limite Municipal (3)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (4,'País (4)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (5,'Unidade federacao (5)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (6,'Municipio (6)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (7,'Distrito (7)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (8,'Sub distrito (8)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (9,'Região administrativa (9)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (10,'Bairro (10)');
INSERT INTO dominios.tipo_limite_legal (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_limite_legal OWNER TO postgres;

CREATE TABLE dominios.tipo_linha_limites (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_linha_limites_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (2,'Contorno massa dágua (2)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (3,'Cumeada (3)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (4,'Linha seca (4)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (5,'Costa visível da carta (5)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (6,'Rodovia (6)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (7,'Ferrovia (7)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (8,'Trecho de drenagem (8)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (9,'Massa dágua (9)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (96,'Não identificado (96)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (97,'Não aplicável (97)');
INSERT INTO dominios.tipo_linha_limites (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_linha_limites OWNER TO postgres;

CREATE TABLE dominios.tipo_localidade (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_localidade_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (1,'Cidade (1)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (2,'Capital estadual (2)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (3,'Capital federal (3)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (4,'Vila (4)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (5,'Aglomerado rural isolado – Núcleo (5)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (6,'Aglomerado rural isolado – Povoado (6)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (7,'Outros aglomerados rurais – Lugarejo (7)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (8,'Nome local (8)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (9,'Bairro (9)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (10,'Praça (10)');
INSERT INTO dominios.tipo_localidade (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_localidade OWNER TO postgres;

CREATE TABLE dominios.tipo_ocupacao_solo (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_ocupacao_solo_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (101,'Cemitério - Crematório (101)','Cemitério');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (102,'Cemitério Parque (102)','Cemitério');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (103,'Cemitério Vertical (103)','Cemitério');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (104,'Cemitério Comum (104)','Cemitério');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (105,'Cemitério - Túmulo isolado (105)','Cemitério');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (201,'Campo/Quadra de futebol (201)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (202,'Campo/Quadra de basquete (202)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (203,'Campo/Quadra de vôlei (203)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (204,'Campo/Quadra de pólo (204)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (205,'Campo/Quadra de hipismo (205)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (206,'Campo/Quadra poliesportiva (206)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (207,'Campo/Quadra de tênis (207)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (298,'Campo/Quadra - Outras quadras esportivas (298)','Campo ou quadra');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (301,'Pista de atletismo (301)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (302,'Pista de ciclismo (302)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (303,'Pista de motociclismo (303)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (304,'Pista de automobilismo (304)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (305,'Pista de corrida de cavalos (305)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (398,'Pista - Outras pistas de competição (398)','Pista competição');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (404,'Pátio rodoviário (404)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (405,'Pátio ferroviário (405)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (406,'Pátio metroviário (406)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (409,'Pátio aeroportuário (409)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (414,'Pátio portuário (414)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (495,'Pátio misto (495)','Pátio');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (501,'Piscina (501)','Piscina');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (601,'Área de ruinas (601)','Área de ruinas');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (701,'Ruina (701)','Ruina');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (801,'Área de energia (801)','Área de energia');
INSERT INTO dominios.tipo_ocupacao_solo (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_ocupacao_solo OWNER TO postgres;

CREATE TABLE dominios.tipo_pista_pouso (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_pista_pouso_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_pista_pouso (code,code_name) VALUES (9,'Pista de pouso (9)');
INSERT INTO dominios.tipo_pista_pouso (code,code_name) VALUES (10,'Pista de táxi (10)');
INSERT INTO dominios.tipo_pista_pouso (code,code_name) VALUES (11,'Heliponto (11)');
INSERT INTO dominios.tipo_pista_pouso (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_pista_pouso OWNER TO postgres;

CREATE TABLE dominios.tipo_produto_residuo (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_produto_residuo_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (1,'Água (1)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (3,'Petróleo (3)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (5,'Gás (5)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (6,'Grãos (6)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (9,'Esgoto (9)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (12,'Lixo domiciliar e comercial (12)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (13,'Lixo tóxico (13)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (14,'Lixo séptico (14)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (15,'Chorume (15)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (16,'Vinhoto (16)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (17,'Estrume (17)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (18,'Cascalho (18)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (19,'Semente (19)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (20,'Inseticida (20)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (21,'Folhagens (21)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (22,'Pedra (brita) (22)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (23,'Granito (23)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (24,'Mármore (24)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (25,'Bauxita (25)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (26,'Manganês (26)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (27,'Talco (27)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (28,'Óleo diesel (28)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (29,'Gasolina (29)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (30,'Álcool (30)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (31,'Querosene (31)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (32,'Cobre (32)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (33,'Carvão mineral (33)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (34,'Sal (34)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (35,'Ferro (35)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (36,'Escória (36)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (37,'Ouro (37)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (38,'Diamante (38)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (39,'Prata (39)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (40,'Pedras preciosas (40)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (41,'Forragem (41)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (42,'Areia (42)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (43,'Saibro ou piçarra (43)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (95,'Misto (95)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (98,'Outros (98)');
INSERT INTO dominios.tipo_produto_residuo (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_produto_residuo OWNER TO postgres;

CREATE TABLE dominios.tipo_pto (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_pto_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_pto (code,code_name) VALUES (1,'Vértice de Triangulação – VT (1)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (2,'Referëncia de Nível – RN (2)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (3,'Estação Gravimétrica – EG (3)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (4,'Estação de Poligonal – EP (4)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (5,'Ponto Astronômico – PA (5)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (6,'Ponto Barométrico – B (6)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (7,'Ponto Trigonométrico – RV (7)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (8,'Ponto de Satélite – SAT (8)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (9,'Ponto de controle (9)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (12,'Centro perspectivo (12)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (13,'Ponto fotogramétrico (13)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (14,'Marco internacional (14)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (15,'Marco estadual (15)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (16,'Marco municipal (16)');
INSERT INTO dominios.tipo_pto (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_pto OWNER TO postgres;

CREATE TABLE dominios.tipo_ref (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_ref_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_ref (code,code_name) VALUES (1,'Altimétrico (1)');
INSERT INTO dominios.tipo_ref (code,code_name) VALUES (2,'Planimétrico (2)');
INSERT INTO dominios.tipo_ref (code,code_name) VALUES (3,'Planialtimétrico (3)');
INSERT INTO dominios.tipo_ref (code,code_name) VALUES (4,'Gravimétrico (4)');
INSERT INTO dominios.tipo_ref (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_ref OWNER TO postgres;

CREATE TABLE dominios.tipo_trecho_drenagem (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_trecho_drenagem_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_trecho_drenagem (code,code_name) VALUES (1,'Rio (1)');
INSERT INTO dominios.tipo_trecho_drenagem (code,code_name) VALUES (2,'Canal (2)');
INSERT INTO dominios.tipo_trecho_drenagem (code,code_name) VALUES (3,'Fundo de vale (3)');
INSERT INTO dominios.tipo_trecho_drenagem (code,code_name) VALUES (11,'Vala (11)');
INSERT INTO dominios.tipo_trecho_drenagem (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_trecho_drenagem OWNER TO postgres;

CREATE TABLE dominios.tipo_hid (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_hid_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_hid (code,code_name) VALUES (1,'Rio (1)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (2,'Canal (2)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (3,'Oceano (3)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (4,'Baía (4)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (5,'Enseada (5)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (6,'Meando Abandonado (6)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (7,'Lago ou Lagoa (7)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (9,'Laguna (9)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (10,'Represa (10)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (11,'Açude (11)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (12,'Terreno Sujeito a Inundação (12)');
INSERT INTO dominios.tipo_hid (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_hid OWNER TO postgres;

CREATE TABLE dominios.tipo_veg (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 filter text NOT NULL,
	 CONSTRAINT tipo_veg_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (102,'Cult - Banana (102)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (103,'Cult - Laranja (103)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (107,'Cult - Cana de açúcar (107)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (114,'Cult - Café (114)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (115,'Cult - Cacau (115)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (116,'Cult - Erva-mate (116)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (117,'Cult - Palmeira (117)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (118,'Cult - Açaí cultivado (118)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (119,'Cult - Seringueira (119)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (124,'Cult - Pastagem cultivada (124)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (142,'Cult - Videira (142)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (150,'Cult - Arroz de inundação (150)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (151,'Cult - Maçã (151)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (152,'Cult - Pêssego (152)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (153,'Cult - Pera (153)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (194,'Cult - Perene não identificado (194)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (195,'Cult - Perene misto (195)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (196,'Cult - Anual não identificado (196)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (198,'Cult - Perene outros (198)','Vegetação Cultivada');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (201,'Mangue arbóreo (201)','Mangue');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (202,'Mangue arbustivo (202)','Mangue');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (301,'Brejo/pântano arbóreo (301)','Brejo ou pântano');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (302,'Brejo/pântano arbustivo (302)','Brejo ou pântano');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (401,'Restinga (401)','Restinga');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (501,'Campinarana (501)','Campinarana');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (601,'Floresta (601)','Floresta');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (701,'Cerrado/Cerradão arbóreo (701)','Cerrado/Cerradão');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (702,'Cerrado/Cerradão arbustivo (702)','Cerrado/Cerradão');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (801,'Caatinga (801)','Caatinga');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (901,'Campo (901)','Campo');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (1000,'Terreno exposto desconhecido (1000)','Terreno Exposto');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (1001,'Terreno exposto areia (1001)','Terreno Exposto');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (1101,'Vegetação de área de contato (1101)','Vegetação de área de contato');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (1296,'Ref - Não identificado (1296)','Reflorestamento');
INSERT INTO dominios.tipo_veg (code,code_name, filter) VALUES (999,'A SER PREENCHIDO (999)','A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_veg OWNER TO postgres;

CREATE TABLE dominios.tipo_via_deslocamento (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT tipo_via_deslocamento_pk PRIMARY KEY (code)
);

INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (2,'Estrada/Rodovia (2)');
INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (3,'Caminho carroçável (3)');
INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (4,'Auto-estrada (4)');
INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (5,'Arruamento (5)');
INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (6,'Trilha ou Picada (6)');
INSERT INTO dominios.tipo_via_deslocamento (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.tipo_via_deslocamento OWNER TO postgres;

CREATE TABLE dominios.trafego (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT trafego_pk PRIMARY KEY (code)
);

INSERT INTO dominios.trafego (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.trafego (code,code_name) VALUES (1,'Permanente (1)');
INSERT INTO dominios.trafego (code,code_name) VALUES (2,'Periódico (2)');
INSERT INTO dominios.trafego (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.trafego OWNER TO postgres;

CREATE TABLE dominios.uso_pista (
	 code smallint NOT NULL,
	 code_name text NOT NULL,
	 CONSTRAINT uso_pista_pk PRIMARY KEY (code)
);

INSERT INTO dominios.uso_pista (code,code_name) VALUES (0,'Desconhecido (0)');
INSERT INTO dominios.uso_pista (code,code_name) VALUES (6,'Particular (6)');
INSERT INTO dominios.uso_pista (code,code_name) VALUES (11,'Público (11)');
INSERT INTO dominios.uso_pista (code,code_name) VALUES (12,'Militar (12)');
INSERT INTO dominios.uso_pista (code,code_name) VALUES (13,'Público/Militar (13)');
INSERT INTO dominios.uso_pista (code,code_name) VALUES (999,'A SER PREENCHIDO (999)');

ALTER TABLE dominios.uso_pista OWNER TO postgres;

CREATE TABLE edgv.cobter_area_edificada_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT cobter_area_edificada_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX cobter_area_edificada_a_geom ON edgv.cobter_area_edificada_a USING gist (geom);

ALTER TABLE edgv.cobter_area_edificada_a OWNER TO postgres;

ALTER TABLE edgv.cobter_area_edificada_a
	 ADD CONSTRAINT cobter_area_edificada_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_area_edificada_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.cobter_area_edificada_a
	 ADD CONSTRAINT cobter_area_edificada_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_area_edificada_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.cobter_corpo_dagua_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 regime smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT cobter_corpo_dagua_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX cobter_corpo_dagua_a_geom ON edgv.cobter_corpo_dagua_a USING gist (geom);

ALTER TABLE edgv.cobter_corpo_dagua_a OWNER TO postgres;

ALTER TABLE edgv.cobter_corpo_dagua_a
	 ADD CONSTRAINT cobter_corpo_dagua_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_corpo_dagua (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_corpo_dagua_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.cobter_corpo_dagua_a
	 ADD CONSTRAINT cobter_corpo_dagua_a_regime_fk FOREIGN KEY (regime)
	 REFERENCES dominios.regime (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_corpo_dagua_a ALTER COLUMN regime SET DEFAULT 999;

ALTER TABLE edgv.cobter_corpo_dagua_a
	 ADD CONSTRAINT cobter_corpo_dagua_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_corpo_dagua_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.cobter_corpo_dagua_a
	 ADD CONSTRAINT cobter_corpo_dagua_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_corpo_dagua_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.cobter_vegetacao_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT cobter_vegetacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX cobter_vegetacao_a_geom ON edgv.cobter_vegetacao_a USING gist (geom);

ALTER TABLE edgv.cobter_vegetacao_a OWNER TO postgres;

ALTER TABLE edgv.cobter_vegetacao_a
	 ADD CONSTRAINT cobter_vegetacao_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_veg (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_vegetacao_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.cobter_vegetacao_a
	 ADD CONSTRAINT cobter_vegetacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_vegetacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.cobter_vegetacao_a
	 ADD CONSTRAINT cobter_vegetacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.cobter_vegetacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_deposito_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_exposicao smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 finalidade smallint NOT NULL,
	 tipo_produto_residuo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT constr_deposito_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_deposito_a_geom ON edgv.constr_deposito_a USING gist (geom);

ALTER TABLE edgv.constr_deposito_a OWNER TO postgres;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_deposito (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_exposicao_fk FOREIGN KEY (tipo_exposicao)
	 REFERENCES dominios.tipo_exposicao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a ALTER COLUMN tipo_exposicao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 5 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_a ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_finalidade_fk FOREIGN KEY (finalidade)
	 REFERENCES dominios.finalidade (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_finalidade_check 
	 CHECK (finalidade = ANY(ARRAY[2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 8 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_a ALTER COLUMN finalidade SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_produto_residuo_fk FOREIGN KEY (tipo_produto_residuo)
	 REFERENCES dominios.tipo_produto_residuo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_produto_residuo_check 
	 CHECK (tipo_produto_residuo = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 9 :: SMALLINT, 12 :: SMALLINT, 13 :: SMALLINT, 14 :: SMALLINT, 15 :: SMALLINT, 16 :: SMALLINT, 17 :: SMALLINT, 18 :: SMALLINT, 19 :: SMALLINT, 20 :: SMALLINT, 21 :: SMALLINT, 22 :: SMALLINT, 23 :: SMALLINT, 24 :: SMALLINT, 25 :: SMALLINT, 26 :: SMALLINT, 27 :: SMALLINT, 28 :: SMALLINT, 29 :: SMALLINT, 30 :: SMALLINT, 31 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 34 :: SMALLINT, 35 :: SMALLINT, 36 :: SMALLINT, 41 :: SMALLINT, 95 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_a ALTER COLUMN tipo_produto_residuo SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_a
	 ADD CONSTRAINT constr_deposito_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_deposito_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_exposicao smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 finalidade smallint NOT NULL,
	 tipo_produto_residuo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT constr_deposito_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_deposito_p_geom ON edgv.constr_deposito_p USING gist (geom);

ALTER TABLE edgv.constr_deposito_p OWNER TO postgres;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_deposito (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_exposicao_fk FOREIGN KEY (tipo_exposicao)
	 REFERENCES dominios.tipo_exposicao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p ALTER COLUMN tipo_exposicao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 5 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_p ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_finalidade_fk FOREIGN KEY (finalidade)
	 REFERENCES dominios.finalidade (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_finalidade_check 
	 CHECK (finalidade = ANY(ARRAY[2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 8 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_p ALTER COLUMN finalidade SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_produto_residuo_fk FOREIGN KEY (tipo_produto_residuo)
	 REFERENCES dominios.tipo_produto_residuo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_produto_residuo_check 
	 CHECK (tipo_produto_residuo = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 9 :: SMALLINT, 12 :: SMALLINT, 13 :: SMALLINT, 14 :: SMALLINT, 15 :: SMALLINT, 16 :: SMALLINT, 17 :: SMALLINT, 18 :: SMALLINT, 19 :: SMALLINT, 20 :: SMALLINT, 21 :: SMALLINT, 22 :: SMALLINT, 23 :: SMALLINT, 24 :: SMALLINT, 25 :: SMALLINT, 26 :: SMALLINT, 27 :: SMALLINT, 28 :: SMALLINT, 29 :: SMALLINT, 30 :: SMALLINT, 31 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 34 :: SMALLINT, 35 :: SMALLINT, 36 :: SMALLINT, 41 :: SMALLINT, 95 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_deposito_p ALTER COLUMN tipo_produto_residuo SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_deposito_p
	 ADD CONSTRAINT constr_deposito_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_deposito_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_edificacao_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT constr_edificacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_edificacao_a_geom ON edgv.constr_edificacao_a USING gist (geom);

ALTER TABLE edgv.constr_edificacao_a OWNER TO postgres;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_edificacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 101 :: SMALLINT, 102 :: SMALLINT, 103 :: SMALLINT, 104 :: SMALLINT, 201 :: SMALLINT, 301 :: SMALLINT, 302 :: SMALLINT, 303 :: SMALLINT, 395 :: SMALLINT, 398 :: SMALLINT, 403 :: SMALLINT, 405 :: SMALLINT, 406 :: SMALLINT, 407 :: SMALLINT, 498 :: SMALLINT, 516 :: SMALLINT, 517 :: SMALLINT, 518 :: SMALLINT, 519 :: SMALLINT, 520 :: SMALLINT, 521 :: SMALLINT, 522 :: SMALLINT, 523 :: SMALLINT, 524 :: SMALLINT, 525 :: SMALLINT, 595 :: SMALLINT, 601 :: SMALLINT, 602 :: SMALLINT, 603 :: SMALLINT, 604 :: SMALLINT, 605 :: SMALLINT, 606 :: SMALLINT, 607 :: SMALLINT, 698 :: SMALLINT, 709 :: SMALLINT, 710 :: SMALLINT, 711 :: SMALLINT, 712 :: SMALLINT, 713 :: SMALLINT, 798 :: SMALLINT, 801 :: SMALLINT, 802 :: SMALLINT, 803 :: SMALLINT, 804 :: SMALLINT, 805 :: SMALLINT, 806 :: SMALLINT, 807 :: SMALLINT, 808 :: SMALLINT, 898 :: SMALLINT, 903 :: SMALLINT, 904 :: SMALLINT, 905 :: SMALLINT, 906 :: SMALLINT, 907 :: SMALLINT, 998 :: SMALLINT, 1015 :: SMALLINT, 1016 :: SMALLINT, 1017 :: SMALLINT, 1018 :: SMALLINT, 1019 :: SMALLINT, 1020 :: SMALLINT, 1021 :: SMALLINT, 1022 :: SMALLINT, 1023 :: SMALLINT, 1024 :: SMALLINT, 1025 :: SMALLINT, 1026 :: SMALLINT, 1027 :: SMALLINT, 1028 :: SMALLINT, 1029 :: SMALLINT, 1030 :: SMALLINT, 1031 :: SMALLINT, 1032 :: SMALLINT, 1033 :: SMALLINT, 1034 :: SMALLINT, 1035 :: SMALLINT, 1036 :: SMALLINT, 1037 :: SMALLINT, 1045 :: SMALLINT, 1098 :: SMALLINT, 1110 :: SMALLINT, 1111 :: SMALLINT, 1113 :: SMALLINT, 1114 :: SMALLINT, 1198 :: SMALLINT, 1212 :: SMALLINT, 1213 :: SMALLINT, 1214 :: SMALLINT, 1215 :: SMALLINT, 1216 :: SMALLINT, 1217 :: SMALLINT, 1218 :: SMALLINT, 1298 :: SMALLINT, 1301 :: SMALLINT, 1302 :: SMALLINT, 1303 :: SMALLINT, 1304 :: SMALLINT, 1305 :: SMALLINT, 1306 :: SMALLINT, 1307 :: SMALLINT, 1308 :: SMALLINT, 1309 :: SMALLINT, 1322 :: SMALLINT, 1398 :: SMALLINT, 1401 :: SMALLINT, 1501 :: SMALLINT, 1712 :: SMALLINT, 1717 :: SMALLINT, 1718 :: SMALLINT, 1719 :: SMALLINT, 1798 :: SMALLINT, 1820 :: SMALLINT, 1821 :: SMALLINT, 1910 :: SMALLINT, 1911 :: SMALLINT, 1995 :: SMALLINT, 2025 :: SMALLINT, 2026 :: SMALLINT, 2027 :: SMALLINT, 2028 :: SMALLINT, 2029 :: SMALLINT, 2030 :: SMALLINT, 2031 :: SMALLINT, 2132 :: SMALLINT, 2133 :: SMALLINT, 2195 :: SMALLINT, 2208 :: SMALLINT, 2209 :: SMALLINT, 2210 :: SMALLINT, 2212 :: SMALLINT, 2213 :: SMALLINT, 2214 :: SMALLINT, 2298 :: SMALLINT, 2316 :: SMALLINT, 2317 :: SMALLINT, 2318 :: SMALLINT, 2319 :: SMALLINT, 2320 :: SMALLINT, 2398 :: SMALLINT, 2426 :: SMALLINT, 2427 :: SMALLINT, 2428 :: SMALLINT, 2429 :: SMALLINT, 2498 :: SMALLINT, 2526 :: SMALLINT, 2527 :: SMALLINT, 2533 :: SMALLINT, 2534 :: SMALLINT, 2535 :: SMALLINT, 2536 :: SMALLINT, 2598 :: SMALLINT, 2601 :: SMALLINT, 2701 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_edificacao_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_edificacao_a ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_a
	 ADD CONSTRAINT constr_edificacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_edificacao_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT constr_edificacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_edificacao_p_geom ON edgv.constr_edificacao_p USING gist (geom);

ALTER TABLE edgv.constr_edificacao_p OWNER TO postgres;

ALTER TABLE edgv.constr_edificacao_p
	 ADD CONSTRAINT constr_edificacao_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_edificacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_p
	 ADD CONSTRAINT constr_edificacao_p_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_p
	 ADD CONSTRAINT constr_edificacao_p_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_edificacao_p ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_p
	 ADD CONSTRAINT constr_edificacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_edificacao_p
	 ADD CONSTRAINT constr_edificacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_edificacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_extracao_mineral_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 forma_extracao smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_produto_residuo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT constr_extracao_mineral_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_extracao_mineral_a_geom ON edgv.constr_extracao_mineral_a USING gist (geom);

ALTER TABLE edgv.constr_extracao_mineral_a OWNER TO postgres;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_extracao_mineral (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[1 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_forma_extracao_fk FOREIGN KEY (forma_extracao)
	 REFERENCES dominios.forma_extracao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN forma_extracao SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_produto_residuo_fk FOREIGN KEY (tipo_produto_residuo)
	 REFERENCES dominios.tipo_produto_residuo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_produto_residuo_check 
	 CHECK (tipo_produto_residuo = ANY(ARRAY[0 :: SMALLINT, 3 :: SMALLINT, 5 :: SMALLINT, 18 :: SMALLINT, 22 :: SMALLINT, 23 :: SMALLINT, 24 :: SMALLINT, 25 :: SMALLINT, 26 :: SMALLINT, 27 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 34 :: SMALLINT, 35 :: SMALLINT, 37 :: SMALLINT, 38 :: SMALLINT, 39 :: SMALLINT, 40 :: SMALLINT, 42 :: SMALLINT, 43 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN tipo_produto_residuo SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_a
	 ADD CONSTRAINT constr_extracao_mineral_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_extracao_mineral_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 forma_extracao smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_produto_residuo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT constr_extracao_mineral_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_extracao_mineral_p_geom ON edgv.constr_extracao_mineral_p USING gist (geom);

ALTER TABLE edgv.constr_extracao_mineral_p OWNER TO postgres;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_extracao_mineral (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[1 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 8 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_forma_extracao_fk FOREIGN KEY (forma_extracao)
	 REFERENCES dominios.forma_extracao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN forma_extracao SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_produto_residuo_fk FOREIGN KEY (tipo_produto_residuo)
	 REFERENCES dominios.tipo_produto_residuo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_produto_residuo_check 
	 CHECK (tipo_produto_residuo = ANY(ARRAY[0 :: SMALLINT, 3 :: SMALLINT, 5 :: SMALLINT, 18 :: SMALLINT, 22 :: SMALLINT, 23 :: SMALLINT, 24 :: SMALLINT, 25 :: SMALLINT, 26 :: SMALLINT, 27 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 34 :: SMALLINT, 35 :: SMALLINT, 37 :: SMALLINT, 38 :: SMALLINT, 39 :: SMALLINT, 40 :: SMALLINT, 42 :: SMALLINT, 43 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN tipo_produto_residuo SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_extracao_mineral_p
	 ADD CONSTRAINT constr_extracao_mineral_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_extracao_mineral_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_ocupacao_solo_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT constr_ocupacao_solo_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_ocupacao_solo_a_geom ON edgv.constr_ocupacao_solo_a USING gist (geom);

ALTER TABLE edgv.constr_ocupacao_solo_a OWNER TO postgres;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_ocupacao_solo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[101 :: SMALLINT, 102 :: SMALLINT, 103 :: SMALLINT, 104 :: SMALLINT, 105 :: SMALLINT, 201 :: SMALLINT, 202 :: SMALLINT, 203 :: SMALLINT, 204 :: SMALLINT, 205 :: SMALLINT, 206 :: SMALLINT, 207 :: SMALLINT, 298 :: SMALLINT, 404 :: SMALLINT, 405 :: SMALLINT, 406 :: SMALLINT, 409 :: SMALLINT, 414 :: SMALLINT, 495 :: SMALLINT, 501 :: SMALLINT, 601 :: SMALLINT, 701 :: SMALLINT, 801 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_a
	 ADD CONSTRAINT constr_ocupacao_solo_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_ocupacao_solo_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT constr_ocupacao_solo_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_ocupacao_solo_l_geom ON edgv.constr_ocupacao_solo_l USING gist (geom);

ALTER TABLE edgv.constr_ocupacao_solo_l OWNER TO postgres;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_ocupacao_solo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[301 :: SMALLINT, 302 :: SMALLINT, 303 :: SMALLINT, 304 :: SMALLINT, 305 :: SMALLINT, 398 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_l
	 ADD CONSTRAINT constr_ocupacao_solo_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.constr_ocupacao_solo_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT constr_ocupacao_solo_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX constr_ocupacao_solo_p_geom ON edgv.constr_ocupacao_solo_p USING gist (geom);

ALTER TABLE edgv.constr_ocupacao_solo_p OWNER TO postgres;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_ocupacao_solo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[101 :: SMALLINT, 102 :: SMALLINT, 103 :: SMALLINT, 104 :: SMALLINT, 105 :: SMALLINT, 201 :: SMALLINT, 202 :: SMALLINT, 203 :: SMALLINT, 204 :: SMALLINT, 205 :: SMALLINT, 206 :: SMALLINT, 207 :: SMALLINT, 298 :: SMALLINT, 701 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.constr_ocupacao_solo_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.constr_ocupacao_solo_p
	 ADD CONSTRAINT constr_ocupacao_solo_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.constr_ocupacao_solo_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_curva_nivel_l(
	 id serial NOT NULL,
	 cota integer NOT NULL,
	 indice smallint NOT NULL,
	 depressao smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT elemnat_curva_nivel_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_curva_nivel_l_geom ON edgv.elemnat_curva_nivel_l USING gist (geom);

ALTER TABLE edgv.elemnat_curva_nivel_l OWNER TO postgres;

ALTER TABLE edgv.elemnat_curva_nivel_l
	 ADD CONSTRAINT elemnat_curva_nivel_l_indice_fk FOREIGN KEY (indice)
	 REFERENCES dominios.indice (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_curva_nivel_l ALTER COLUMN indice SET DEFAULT 999;

ALTER TABLE edgv.elemnat_curva_nivel_l
	 ADD CONSTRAINT elemnat_curva_nivel_l_depressao_fk FOREIGN KEY (depressao)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_curva_nivel_l ALTER COLUMN depressao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_curva_nivel_l
	 ADD CONSTRAINT elemnat_curva_nivel_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_curva_nivel_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_curva_nivel_l
	 ADD CONSTRAINT elemnat_curva_nivel_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_curva_nivel_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_fisiografico_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT elemnat_elemento_fisiografico_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_fisiografico_a_geom ON edgv.elemnat_elemento_fisiografico_a USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_fisiografico_a OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a
	 ADD CONSTRAINT elemnat_elemento_fisiografico_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_fisiografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a
	 ADD CONSTRAINT elemnat_elemento_fisiografico_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[12 :: SMALLINT, 15 :: SMALLINT, 16 :: SMALLINT, 21 :: SMALLINT, 22 :: SMALLINT, 23 :: SMALLINT, 24 :: SMALLINT, 25 :: SMALLINT, 28 :: SMALLINT, 29 :: SMALLINT, 30 :: SMALLINT, 31 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_fisiografico_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a
	 ADD CONSTRAINT elemnat_elemento_fisiografico_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a
	 ADD CONSTRAINT elemnat_elemento_fisiografico_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_fisiografico_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT elemnat_elemento_fisiografico_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_fisiografico_l_geom ON edgv.elemnat_elemento_fisiografico_l USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_fisiografico_l OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l
	 ADD CONSTRAINT elemnat_elemento_fisiografico_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_fisiografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l
	 ADD CONSTRAINT elemnat_elemento_fisiografico_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[1 :: SMALLINT, 8 :: SMALLINT, 12 :: SMALLINT, 13 :: SMALLINT, 14 :: SMALLINT, 26 :: SMALLINT, 27 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_fisiografico_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l
	 ADD CONSTRAINT elemnat_elemento_fisiografico_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l
	 ADD CONSTRAINT elemnat_elemento_fisiografico_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_fisiografico_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT elemnat_elemento_fisiografico_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_fisiografico_p_geom ON edgv.elemnat_elemento_fisiografico_p USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_fisiografico_p OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p
	 ADD CONSTRAINT elemnat_elemento_fisiografico_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_fisiografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p
	 ADD CONSTRAINT elemnat_elemento_fisiografico_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 9 :: SMALLINT, 10 :: SMALLINT, 11 :: SMALLINT, 12 :: SMALLINT, 17 :: SMALLINT, 19 :: SMALLINT, 20 :: SMALLINT, 21 :: SMALLINT, 22 :: SMALLINT, 30 :: SMALLINT, 31 :: SMALLINT, 32 :: SMALLINT, 33 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_fisiografico_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p
	 ADD CONSTRAINT elemnat_elemento_fisiografico_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p
	 ADD CONSTRAINT elemnat_elemento_fisiografico_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_fisiografico_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_hidrografico_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT elemnat_elemento_hidrografico_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_hidrografico_a_geom ON edgv.elemnat_elemento_hidrografico_a USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_hidrografico_a OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a
	 ADD CONSTRAINT elemnat_elemento_hidrografico_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_hidrografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a
	 ADD CONSTRAINT elemnat_elemento_hidrografico_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[6 :: SMALLINT, 8 :: SMALLINT, 12 :: SMALLINT, 13 :: SMALLINT, 14 :: SMALLINT, 15 :: SMALLINT, 16 :: SMALLINT, 17 :: SMALLINT, 18 :: SMALLINT, 19 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_hidrografico_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a
	 ADD CONSTRAINT elemnat_elemento_hidrografico_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a
	 ADD CONSTRAINT elemnat_elemento_hidrografico_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_hidrografico_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT elemnat_elemento_hidrografico_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_hidrografico_l_geom ON edgv.elemnat_elemento_hidrografico_l USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_hidrografico_l OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l
	 ADD CONSTRAINT elemnat_elemento_hidrografico_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_hidrografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l
	 ADD CONSTRAINT elemnat_elemento_hidrografico_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[8 :: SMALLINT, 9 :: SMALLINT, 10 :: SMALLINT, 11 :: SMALLINT, 12 :: SMALLINT, 18 :: SMALLINT, 19 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_hidrografico_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l
	 ADD CONSTRAINT elemnat_elemento_hidrografico_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l
	 ADD CONSTRAINT elemnat_elemento_hidrografico_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_elemento_hidrografico_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT elemnat_elemento_hidrografico_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_elemento_hidrografico_p_geom ON edgv.elemnat_elemento_hidrografico_p USING gist (geom);

ALTER TABLE edgv.elemnat_elemento_hidrografico_p OWNER TO postgres;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p
	 ADD CONSTRAINT elemnat_elemento_hidrografico_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_hidrografico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p
	 ADD CONSTRAINT elemnat_elemento_hidrografico_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 8 :: SMALLINT, 9 :: SMALLINT, 10 :: SMALLINT, 11 :: SMALLINT, 12 :: SMALLINT, 18 :: SMALLINT, 19 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.elemnat_elemento_hidrografico_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p
	 ADD CONSTRAINT elemnat_elemento_hidrografico_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p
	 ADD CONSTRAINT elemnat_elemento_hidrografico_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_elemento_hidrografico_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_ponto_cotado_p(
	 id serial NOT NULL,
	 cota real NOT NULL,
	 cota_comprovada smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT elemnat_ponto_cotado_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_ponto_cotado_p_geom ON edgv.elemnat_ponto_cotado_p USING gist (geom);

ALTER TABLE edgv.elemnat_ponto_cotado_p OWNER TO postgres;

ALTER TABLE edgv.elemnat_ponto_cotado_p
	 ADD CONSTRAINT elemnat_ponto_cotado_p_cota_comprovada_fk FOREIGN KEY (cota_comprovada)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_ponto_cotado_p ALTER COLUMN cota_comprovada SET DEFAULT 999;

ALTER TABLE edgv.elemnat_ponto_cotado_p
	 ADD CONSTRAINT elemnat_ponto_cotado_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_ponto_cotado_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_ponto_cotado_p
	 ADD CONSTRAINT elemnat_ponto_cotado_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_ponto_cotado_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.elemnat_trecho_drenagem_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 regime smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT elemnat_trecho_drenagem_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX elemnat_trecho_drenagem_l_geom ON edgv.elemnat_trecho_drenagem_l USING gist (geom);

ALTER TABLE edgv.elemnat_trecho_drenagem_l OWNER TO postgres;

ALTER TABLE edgv.elemnat_trecho_drenagem_l
	 ADD CONSTRAINT elemnat_trecho_drenagem_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_trecho_drenagem (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_trecho_drenagem_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.elemnat_trecho_drenagem_l
	 ADD CONSTRAINT elemnat_trecho_drenagem_l_regime_fk FOREIGN KEY (regime)
	 REFERENCES dominios.regime (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_trecho_drenagem_l ALTER COLUMN regime SET DEFAULT 999;

ALTER TABLE edgv.elemnat_trecho_drenagem_l
	 ADD CONSTRAINT elemnat_trecho_drenagem_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_trecho_drenagem_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.elemnat_trecho_drenagem_l
	 ADD CONSTRAINT elemnat_trecho_drenagem_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.elemnat_trecho_drenagem_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_infraestrutura_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 posicao_relativa smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT infra_elemento_infraestrutura_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_infraestrutura_a_geom ON edgv.infra_elemento_infraestrutura_a USING gist (geom);

ALTER TABLE edgv.infra_elemento_infraestrutura_a OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_infraestrutura (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[405 :: SMALLINT, 406 :: SMALLINT, 407 :: SMALLINT, 408 :: SMALLINT, 409 :: SMALLINT, 410 :: SMALLINT, 411 :: SMALLINT, 412 :: SMALLINT, 495 :: SMALLINT, 498 :: SMALLINT, 601 :: SMALLINT, 701 :: SMALLINT, 801 :: SMALLINT, 1001 :: SMALLINT, 1101 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 23 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_posicao_relativa_fk FOREIGN KEY (posicao_relativa)
	 REFERENCES dominios.posicao_relativa (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN posicao_relativa SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_a
	 ADD CONSTRAINT infra_elemento_infraestrutura_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_infraestrutura_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 posicao_relativa smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_elemento_infraestrutura_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_infraestrutura_l_geom ON edgv.infra_elemento_infraestrutura_l USING gist (geom);

ALTER TABLE edgv.infra_elemento_infraestrutura_l OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_infraestrutura (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[201 :: SMALLINT, 202 :: SMALLINT, 302 :: SMALLINT, 303 :: SMALLINT, 405 :: SMALLINT, 406 :: SMALLINT, 407 :: SMALLINT, 408 :: SMALLINT, 409 :: SMALLINT, 410 :: SMALLINT, 411 :: SMALLINT, 412 :: SMALLINT, 495 :: SMALLINT, 498 :: SMALLINT, 701 :: SMALLINT, 801 :: SMALLINT, 901 :: SMALLINT, 1001 :: SMALLINT, 1101 :: SMALLINT, 1501 :: SMALLINT, 1700 :: SMALLINT, 1701 :: SMALLINT, 1702 :: SMALLINT, 1703 :: SMALLINT, 1704 :: SMALLINT, 1705 :: SMALLINT, 1706 :: SMALLINT, 1707 :: SMALLINT, 1708 :: SMALLINT, 1709 :: SMALLINT, 1710 :: SMALLINT, 1798 :: SMALLINT, 1801 :: SMALLINT, 1901 :: SMALLINT, 1902 :: SMALLINT, 1998 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 23 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_posicao_relativa_fk FOREIGN KEY (posicao_relativa)
	 REFERENCES dominios.posicao_relativa (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN posicao_relativa SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_l
	 ADD CONSTRAINT infra_elemento_infraestrutura_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_infraestrutura_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 posicao_relativa smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT infra_elemento_infraestrutura_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_infraestrutura_p_geom ON edgv.infra_elemento_infraestrutura_p USING gist (geom);

ALTER TABLE edgv.infra_elemento_infraestrutura_p OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_infraestrutura (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[405 :: SMALLINT, 406 :: SMALLINT, 407 :: SMALLINT, 408 :: SMALLINT, 409 :: SMALLINT, 410 :: SMALLINT, 411 :: SMALLINT, 412 :: SMALLINT, 495 :: SMALLINT, 498 :: SMALLINT, 601 :: SMALLINT, 901 :: SMALLINT, 1001 :: SMALLINT, 1201 :: SMALLINT, 1301 :: SMALLINT, 1401 :: SMALLINT, 1501 :: SMALLINT, 1601 :: SMALLINT, 1698 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 23 :: SMALLINT, 97 :: SMALLINT, 98 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_posicao_relativa_fk FOREIGN KEY (posicao_relativa)
	 REFERENCES dominios.posicao_relativa (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN posicao_relativa SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_infraestrutura_p
	 ADD CONSTRAINT infra_elemento_infraestrutura_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_infraestrutura_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_transportes_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT infra_elemento_transportes_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_transportes_a_geom ON edgv.infra_elemento_transportes_a USING gist (geom);

ALTER TABLE edgv.infra_elemento_transportes_a OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_transportes_a
	 ADD CONSTRAINT infra_elemento_transportes_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_transportes (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_a
	 ADD CONSTRAINT infra_elemento_transportes_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[238 :: SMALLINT, 239 :: SMALLINT, 240 :: SMALLINT, 241 :: SMALLINT, 242 :: SMALLINT, 243 :: SMALLINT, 244 :: SMALLINT, 1101 :: SMALLINT, 1201 :: SMALLINT, 1300 :: SMALLINT, 1301 :: SMALLINT, 1302 :: SMALLINT, 1395 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_transportes_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_a
	 ADD CONSTRAINT infra_elemento_transportes_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_a
	 ADD CONSTRAINT infra_elemento_transportes_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_a
	 ADD CONSTRAINT infra_elemento_transportes_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_transportes_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_elemento_transportes_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_transportes_l_geom ON edgv.infra_elemento_transportes_l USING gist (geom);

ALTER TABLE edgv.infra_elemento_transportes_l OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_transportes_l
	 ADD CONSTRAINT infra_elemento_transportes_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_transportes (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_l
	 ADD CONSTRAINT infra_elemento_transportes_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[238 :: SMALLINT, 239 :: SMALLINT, 240 :: SMALLINT, 241 :: SMALLINT, 242 :: SMALLINT, 243 :: SMALLINT, 244 :: SMALLINT, 302 :: SMALLINT, 303 :: SMALLINT, 304 :: SMALLINT, 501 :: SMALLINT, 607 :: SMALLINT, 608 :: SMALLINT, 609 :: SMALLINT, 801 :: SMALLINT, 898 :: SMALLINT, 901 :: SMALLINT, 1001 :: SMALLINT, 1101 :: SMALLINT, 1201 :: SMALLINT, 1401 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_transportes_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_l
	 ADD CONSTRAINT infra_elemento_transportes_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_l
	 ADD CONSTRAINT infra_elemento_transportes_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_l
	 ADD CONSTRAINT infra_elemento_transportes_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_transportes_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT infra_elemento_transportes_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_transportes_p_geom ON edgv.infra_elemento_transportes_p USING gist (geom);

ALTER TABLE edgv.infra_elemento_transportes_p OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_transportes_p
	 ADD CONSTRAINT infra_elemento_transportes_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_transportes (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_p
	 ADD CONSTRAINT infra_elemento_transportes_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[101 :: SMALLINT, 238 :: SMALLINT, 239 :: SMALLINT, 240 :: SMALLINT, 241 :: SMALLINT, 242 :: SMALLINT, 243 :: SMALLINT, 244 :: SMALLINT, 404 :: SMALLINT, 607 :: SMALLINT, 608 :: SMALLINT, 609 :: SMALLINT, 701 :: SMALLINT, 901 :: SMALLINT, 1001 :: SMALLINT, 1101 :: SMALLINT, 1201 :: SMALLINT, 1300 :: SMALLINT, 1301 :: SMALLINT, 1302 :: SMALLINT, 1395 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_elemento_transportes_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_p
	 ADD CONSTRAINT infra_elemento_transportes_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_p
	 ADD CONSTRAINT infra_elemento_transportes_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_transportes_p
	 ADD CONSTRAINT infra_elemento_transportes_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_transportes_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_viario_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 modal_uso smallint NOT NULL,
	 nr_faixas varchar(255),
	 nr_pistas varchar(255),
	 posicao_pista smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_elemento_viario_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_viario_l_geom ON edgv.infra_elemento_viario_l USING gist (geom);

ALTER TABLE edgv.infra_elemento_viario_l OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_viario (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_modal_uso_fk FOREIGN KEY (modal_uso)
	 REFERENCES dominios.modal_uso (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN modal_uso SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_posicao_pista_fk FOREIGN KEY (posicao_pista)
	 REFERENCES dominios.posicao_pista (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN posicao_pista SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_l
	 ADD CONSTRAINT infra_elemento_viario_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_elemento_viario_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 modal_uso smallint NOT NULL,
	 nr_faixas varchar(255),
	 nr_pistas varchar(255),
	 posicao_pista smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT infra_elemento_viario_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_elemento_viario_p_geom ON edgv.infra_elemento_viario_p USING gist (geom);

ALTER TABLE edgv.infra_elemento_viario_p OWNER TO postgres;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_elemento_viario (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_modal_uso_fk FOREIGN KEY (modal_uso)
	 REFERENCES dominios.modal_uso (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN modal_uso SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_posicao_pista_fk FOREIGN KEY (posicao_pista)
	 REFERENCES dominios.posicao_pista (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN posicao_pista SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_elemento_viario_p
	 ADD CONSTRAINT infra_elemento_viario_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_elemento_viario_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_ferrovia_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 posicao_relativa smallint NOT NULL,
	 nr_linhas smallint NOT NULL,
	 em_arruamento smallint NOT NULL,
	 jurisdicao smallint NOT NULL,
	 administracao smallint NOT NULL,
	 concessionaria varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_ferrovia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_ferrovia_l_geom ON edgv.infra_ferrovia_l USING gist (geom);

ALTER TABLE edgv.infra_ferrovia_l OWNER TO postgres;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_ferrovia (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_posicao_relativa_fk FOREIGN KEY (posicao_relativa)
	 REFERENCES dominios.posicao_relativa (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_posicao_relativa_check 
	 CHECK (posicao_relativa = ANY(ARRAY[2 :: SMALLINT, 3 :: SMALLINT, 6 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN posicao_relativa SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_nr_linhas_fk FOREIGN KEY (nr_linhas)
	 REFERENCES dominios.nr_linhas (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN nr_linhas SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_em_arruamento_fk FOREIGN KEY (em_arruamento)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN em_arruamento SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_jurisdicao_fk FOREIGN KEY (jurisdicao)
	 REFERENCES dominios.jurisdicao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_jurisdicao_check 
	 CHECK (jurisdicao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 6 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN jurisdicao SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_administracao_fk FOREIGN KEY (administracao)
	 REFERENCES dominios.administracao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_administracao_check 
	 CHECK (administracao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN administracao SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_ferrovia_l
	 ADD CONSTRAINT infra_ferrovia_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_ferrovia_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_pista_pouso_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 revestimento smallint NOT NULL,
	 uso_pista smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 homologacao smallint NOT NULL,
	 largura varchar(255),
	 extensao varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT infra_pista_pouso_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_pista_pouso_a_geom ON edgv.infra_pista_pouso_a USING gist (geom);

ALTER TABLE edgv.infra_pista_pouso_a OWNER TO postgres;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_pista_pouso (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_revestimento_fk FOREIGN KEY (revestimento)
	 REFERENCES dominios.revestimento (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_revestimento_check 
	 CHECK (revestimento = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN revestimento SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_uso_pista_fk FOREIGN KEY (uso_pista)
	 REFERENCES dominios.uso_pista (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN uso_pista SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_homologacao_fk FOREIGN KEY (homologacao)
	 REFERENCES dominios.booleano_estendido (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN homologacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_a
	 ADD CONSTRAINT infra_pista_pouso_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_pista_pouso_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 revestimento smallint NOT NULL,
	 uso_pista smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 homologacao smallint NOT NULL,
	 largura varchar(255),
	 extensao varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_pista_pouso_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_pista_pouso_l_geom ON edgv.infra_pista_pouso_l USING gist (geom);

ALTER TABLE edgv.infra_pista_pouso_l OWNER TO postgres;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_pista_pouso (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_revestimento_fk FOREIGN KEY (revestimento)
	 REFERENCES dominios.revestimento (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_revestimento_check 
	 CHECK (revestimento = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN revestimento SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_uso_pista_fk FOREIGN KEY (uso_pista)
	 REFERENCES dominios.uso_pista (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN uso_pista SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_homologacao_fk FOREIGN KEY (homologacao)
	 REFERENCES dominios.booleano_estendido (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN homologacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_l
	 ADD CONSTRAINT infra_pista_pouso_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_pista_pouso_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 revestimento smallint NOT NULL,
	 uso_pista smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 homologacao smallint NOT NULL,
	 largura varchar(255),
	 extensao varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT infra_pista_pouso_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_pista_pouso_p_geom ON edgv.infra_pista_pouso_p USING gist (geom);

ALTER TABLE edgv.infra_pista_pouso_p OWNER TO postgres;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_pista_pouso (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_revestimento_fk FOREIGN KEY (revestimento)
	 REFERENCES dominios.revestimento (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_revestimento_check 
	 CHECK (revestimento = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN revestimento SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_uso_pista_fk FOREIGN KEY (uso_pista)
	 REFERENCES dominios.uso_pista (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN uso_pista SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_homologacao_fk FOREIGN KEY (homologacao)
	 REFERENCES dominios.booleano_estendido (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN homologacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_pista_pouso_p
	 ADD CONSTRAINT infra_pista_pouso_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_pista_pouso_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.infra_via_deslocamento_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 revestimento smallint NOT NULL,
	 trafego smallint NOT NULL,
	 nr_faixas varchar(255),
	 nr_pistas varchar(255),
	 canteiro_divisorio smallint NOT NULL,
	 situacao_fisica smallint NOT NULL,
	 jurisdicao smallint NOT NULL,
	 sigla varchar(255),
	 administracao smallint NOT NULL,
	 concessionaria varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT infra_via_deslocamento_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX infra_via_deslocamento_l_geom ON edgv.infra_via_deslocamento_l USING gist (geom);

ALTER TABLE edgv.infra_via_deslocamento_l OWNER TO postgres;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_via_deslocamento (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_revestimento_fk FOREIGN KEY (revestimento)
	 REFERENCES dominios.revestimento (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_revestimento_check 
	 CHECK (revestimento = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN revestimento SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_trafego_fk FOREIGN KEY (trafego)
	 REFERENCES dominios.trafego (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_trafego_check 
	 CHECK (trafego = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN trafego SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_canteiro_divisorio_fk FOREIGN KEY (canteiro_divisorio)
	 REFERENCES dominios.canteiro_divisorio (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN canteiro_divisorio SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_situacao_fisica_fk FOREIGN KEY (situacao_fisica)
	 REFERENCES dominios.situacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_situacao_fisica_check 
	 CHECK (situacao_fisica = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 4 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN situacao_fisica SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_jurisdicao_fk FOREIGN KEY (jurisdicao)
	 REFERENCES dominios.jurisdicao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_jurisdicao_check 
	 CHECK (jurisdicao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN jurisdicao SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_administracao_fk FOREIGN KEY (administracao)
	 REFERENCES dominios.administracao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_administracao_check 
	 CHECK (administracao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 2 :: SMALLINT, 7 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN administracao SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.infra_via_deslocamento_l
	 ADD CONSTRAINT infra_via_deslocamento_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.infra_via_deslocamento_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_delimitacao_fisica_l(
	 id serial NOT NULL,
	 tipo smallint NOT NULL,
	 material_construcao smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT llp_delimitacao_fisica_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_delimitacao_fisica_l_geom ON edgv.llp_delimitacao_fisica_l USING gist (geom);

ALTER TABLE edgv.llp_delimitacao_fisica_l OWNER TO postgres;

ALTER TABLE edgv.llp_delimitacao_fisica_l
	 ADD CONSTRAINT llp_delimitacao_fisica_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_delimitacao_fisica (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_delimitacao_fisica_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_delimitacao_fisica_l
	 ADD CONSTRAINT llp_delimitacao_fisica_l_material_construcao_fk FOREIGN KEY (material_construcao)
	 REFERENCES dominios.material_construcao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_delimitacao_fisica_l
	 ADD CONSTRAINT llp_delimitacao_fisica_l_material_construcao_check 
	 CHECK (material_construcao = ANY(ARRAY[0 :: SMALLINT, 1 :: SMALLINT, 4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 8 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.llp_delimitacao_fisica_l ALTER COLUMN material_construcao SET DEFAULT 999;

ALTER TABLE edgv.llp_delimitacao_fisica_l
	 ADD CONSTRAINT llp_delimitacao_fisica_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_delimitacao_fisica_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_delimitacao_fisica_l
	 ADD CONSTRAINT llp_delimitacao_fisica_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_delimitacao_fisica_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_limite_especial_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_delimitacao smallint NOT NULL,
	 geometria_aproximada smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT llp_limite_especial_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_limite_especial_a_geom ON edgv.llp_limite_especial_a USING gist (geom);

ALTER TABLE edgv.llp_limite_especial_a OWNER TO postgres;

ALTER TABLE edgv.llp_limite_especial_a
	 ADD CONSTRAINT llp_limite_especial_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_limite_especial (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_a
	 ADD CONSTRAINT llp_limite_especial_a_tipo_delimitacao_fk FOREIGN KEY (tipo_delimitacao)
	 REFERENCES dominios.tipo_linha_limites (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_a ALTER COLUMN tipo_delimitacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_a
	 ADD CONSTRAINT llp_limite_especial_a_geometria_aproximada_fk FOREIGN KEY (geometria_aproximada)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_a ALTER COLUMN geometria_aproximada SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_a
	 ADD CONSTRAINT llp_limite_especial_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_a
	 ADD CONSTRAINT llp_limite_especial_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_limite_especial_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_delimitacao smallint NOT NULL,
	 geometria_aproximada smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT llp_limite_especial_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_limite_especial_l_geom ON edgv.llp_limite_especial_l USING gist (geom);

ALTER TABLE edgv.llp_limite_especial_l OWNER TO postgres;

ALTER TABLE edgv.llp_limite_especial_l
	 ADD CONSTRAINT llp_limite_especial_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_limite_especial (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_l
	 ADD CONSTRAINT llp_limite_especial_l_tipo_delimitacao_fk FOREIGN KEY (tipo_delimitacao)
	 REFERENCES dominios.tipo_linha_limites (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_l ALTER COLUMN tipo_delimitacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_l
	 ADD CONSTRAINT llp_limite_especial_l_geometria_aproximada_fk FOREIGN KEY (geometria_aproximada)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_l ALTER COLUMN geometria_aproximada SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_l
	 ADD CONSTRAINT llp_limite_especial_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_especial_l
	 ADD CONSTRAINT llp_limite_especial_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_especial_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_limite_legal_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_delimitacao smallint NOT NULL,
	 geometria_aproximada smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT llp_limite_legal_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_limite_legal_a_geom ON edgv.llp_limite_legal_a USING gist (geom);

ALTER TABLE edgv.llp_limite_legal_a OWNER TO postgres;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_limite_legal (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_tipo_check 
	 CHECK (tipo = ANY(ARRAY[4 :: SMALLINT, 5 :: SMALLINT, 6 :: SMALLINT, 7 :: SMALLINT, 8 :: SMALLINT, 9 :: SMALLINT, 10 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.llp_limite_legal_a ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_tipo_delimitacao_fk FOREIGN KEY (tipo_delimitacao)
	 REFERENCES dominios.tipo_linha_limites (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_a ALTER COLUMN tipo_delimitacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_geometria_aproximada_fk FOREIGN KEY (geometria_aproximada)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_a ALTER COLUMN geometria_aproximada SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_a
	 ADD CONSTRAINT llp_limite_legal_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_limite_legal_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 tipo_delimitacao smallint NOT NULL,
	 geometria_aproximada smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT llp_limite_legal_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_limite_legal_l_geom ON edgv.llp_limite_legal_l USING gist (geom);

ALTER TABLE edgv.llp_limite_legal_l OWNER TO postgres;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_limite_legal (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_tipo_check 
	 CHECK (tipo = ANY(ARRAY[1 :: SMALLINT, 2 :: SMALLINT, 3 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.llp_limite_legal_l ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_tipo_delimitacao_fk FOREIGN KEY (tipo_delimitacao)
	 REFERENCES dominios.tipo_linha_limites (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_l ALTER COLUMN tipo_delimitacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_geometria_aproximada_fk FOREIGN KEY (geometria_aproximada)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_l ALTER COLUMN geometria_aproximada SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_limite_legal_l
	 ADD CONSTRAINT llp_limite_legal_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_limite_legal_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_localidade_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 latitude varchar(255),
	 longitude varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT llp_localidade_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_localidade_p_geom ON edgv.llp_localidade_p USING gist (geom);

ALTER TABLE edgv.llp_localidade_p OWNER TO postgres;

ALTER TABLE edgv.llp_localidade_p
	 ADD CONSTRAINT llp_localidade_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_localidade (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_localidade_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_localidade_p
	 ADD CONSTRAINT llp_localidade_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_localidade_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_localidade_p
	 ADD CONSTRAINT llp_localidade_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_localidade_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.llp_ponto_controle_p(
	 id serial NOT NULL,
	 cod_ponto varchar(255),
	 tipo smallint NOT NULL,
	 tipo_ref smallint NOT NULL,
	 altitude_ortometrica varchar(255) NOT NULL,
	 sistema_geodesico smallint NOT NULL,
	 referencial_altim smallint NOT NULL,
	 referencial_grav smallint NOT NULL,
	 situacao_marco smallint NOT NULL,
	 orgao_responsavel varchar(255) NOT NULL,
	 latitude varchar(255) NOT NULL,
	 longitude varchar(255) NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT llp_ponto_controle_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX llp_ponto_controle_p_geom ON edgv.llp_ponto_controle_p USING gist (geom);

ALTER TABLE edgv.llp_ponto_controle_p OWNER TO postgres;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_pto (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_tipo_ref_fk FOREIGN KEY (tipo_ref)
	 REFERENCES dominios.tipo_ref (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN tipo_ref SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_sistema_geodesico_fk FOREIGN KEY (sistema_geodesico)
	 REFERENCES dominios.sistema_geodesico (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN sistema_geodesico SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_referencial_altim_fk FOREIGN KEY (referencial_altim)
	 REFERENCES dominios.referencial_altim (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN referencial_altim SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_referencial_grav_fk FOREIGN KEY (referencial_grav)
	 REFERENCES dominios.referencial_grav (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN referencial_grav SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_situacao_marco_fk FOREIGN KEY (situacao_marco)
	 REFERENCES dominios.situacao_marco (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN situacao_marco SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.llp_ponto_controle_p
	 ADD CONSTRAINT llp_ponto_controle_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.llp_ponto_controle_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_objeto_desconhecido_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT aux_objeto_desconhecido_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_objeto_desconhecido_a_geom ON edgv.aux_objeto_desconhecido_a USING gist (geom);

ALTER TABLE edgv.aux_objeto_desconhecido_a OWNER TO postgres;

ALTER TABLE edgv.aux_objeto_desconhecido_a
	 ADD CONSTRAINT aux_objeto_desconhecido_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_objeto_desconhecido_a
	 ADD CONSTRAINT aux_objeto_desconhecido_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_objeto_desconhecido_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aux_objeto_desconhecido_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_objeto_desconhecido_l_geom ON edgv.aux_objeto_desconhecido_l USING gist (geom);

ALTER TABLE edgv.aux_objeto_desconhecido_l OWNER TO postgres;

ALTER TABLE edgv.aux_objeto_desconhecido_l
	 ADD CONSTRAINT aux_objeto_desconhecido_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_objeto_desconhecido_l
	 ADD CONSTRAINT aux_objeto_desconhecido_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_objeto_desconhecido_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT aux_objeto_desconhecido_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_objeto_desconhecido_p_geom ON edgv.aux_objeto_desconhecido_p USING gist (geom);

ALTER TABLE edgv.aux_objeto_desconhecido_p OWNER TO postgres;

ALTER TABLE edgv.aux_objeto_desconhecido_p
	 ADD CONSTRAINT aux_objeto_desconhecido_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_objeto_desconhecido_p
	 ADD CONSTRAINT aux_objeto_desconhecido_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_objeto_desconhecido_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_transportes_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT val_transportes_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_transportes_a_geom ON edgv.val_transportes_a USING gist (geom);

ALTER TABLE edgv.val_transportes_a OWNER TO postgres;

ALTER TABLE edgv.val_transportes_a
	 ADD CONSTRAINT val_transportes_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_transportes_a
	 ADD CONSTRAINT val_transportes_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_transportes_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT val_transportes_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_transportes_l_geom ON edgv.val_transportes_l USING gist (geom);

ALTER TABLE edgv.val_transportes_l OWNER TO postgres;

ALTER TABLE edgv.val_transportes_l
	 ADD CONSTRAINT val_transportes_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_transportes_l
	 ADD CONSTRAINT val_transportes_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_transportes_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT val_transportes_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_transportes_p_geom ON edgv.val_transportes_p USING gist (geom);

ALTER TABLE edgv.val_transportes_p OWNER TO postgres;

ALTER TABLE edgv.val_transportes_p
	 ADD CONSTRAINT val_transportes_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_transportes_p
	 ADD CONSTRAINT val_transportes_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_transportes_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_edificacao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT val_edificacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_edificacao_a_geom ON edgv.val_edificacao_a USING gist (geom);

ALTER TABLE edgv.val_edificacao_a OWNER TO postgres;

ALTER TABLE edgv.val_edificacao_a
	 ADD CONSTRAINT val_edificacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_edificacao_a
	 ADD CONSTRAINT val_edificacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_edificacao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT val_edificacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_edificacao_l_geom ON edgv.val_edificacao_l USING gist (geom);

ALTER TABLE edgv.val_edificacao_l OWNER TO postgres;

ALTER TABLE edgv.val_edificacao_l
	 ADD CONSTRAINT val_edificacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_edificacao_l
	 ADD CONSTRAINT val_edificacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_edificacao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT val_edificacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_edificacao_p_geom ON edgv.val_edificacao_p USING gist (geom);

ALTER TABLE edgv.val_edificacao_p OWNER TO postgres;

ALTER TABLE edgv.val_edificacao_p
	 ADD CONSTRAINT val_edificacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_edificacao_p
	 ADD CONSTRAINT val_edificacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_edificacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_vegetacao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT val_vegetacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_vegetacao_a_geom ON edgv.val_vegetacao_a USING gist (geom);

ALTER TABLE edgv.val_vegetacao_a OWNER TO postgres;

ALTER TABLE edgv.val_vegetacao_a
	 ADD CONSTRAINT val_vegetacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_vegetacao_a
	 ADD CONSTRAINT val_vegetacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_vegetacao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT val_vegetacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_vegetacao_l_geom ON edgv.val_vegetacao_l USING gist (geom);

ALTER TABLE edgv.val_vegetacao_l OWNER TO postgres;

ALTER TABLE edgv.val_vegetacao_l
	 ADD CONSTRAINT val_vegetacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_vegetacao_l
	 ADD CONSTRAINT val_vegetacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_vegetacao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT val_vegetacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_vegetacao_p_geom ON edgv.val_vegetacao_p USING gist (geom);

ALTER TABLE edgv.val_vegetacao_p OWNER TO postgres;

ALTER TABLE edgv.val_vegetacao_p
	 ADD CONSTRAINT val_vegetacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_vegetacao_p
	 ADD CONSTRAINT val_vegetacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_vegetacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_hidrografia_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT val_hidrografia_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_hidrografia_a_geom ON edgv.val_hidrografia_a USING gist (geom);

ALTER TABLE edgv.val_hidrografia_a OWNER TO postgres;

ALTER TABLE edgv.val_hidrografia_a
	 ADD CONSTRAINT val_hidrografia_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_hidrografia_a
	 ADD CONSTRAINT val_hidrografia_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_hidrografia_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT val_hidrografia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_hidrografia_l_geom ON edgv.val_hidrografia_l USING gist (geom);

ALTER TABLE edgv.val_hidrografia_l OWNER TO postgres;

ALTER TABLE edgv.val_hidrografia_l
	 ADD CONSTRAINT val_hidrografia_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_hidrografia_l
	 ADD CONSTRAINT val_hidrografia_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.val_hidrografia_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT val_hidrografia_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX val_hidrografia_p_geom ON edgv.val_hidrografia_p USING gist (geom);

ALTER TABLE edgv.val_hidrografia_p OWNER TO postgres;

ALTER TABLE edgv.val_hidrografia_p
	 ADD CONSTRAINT val_hidrografia_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.val_hidrografia_p
	 ADD CONSTRAINT val_hidrografia_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.val_hidrografia_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_vegetacao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_vegetacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_vegetacao_a_geom ON edgv.rev_vegetacao_a USING gist (geom);

ALTER TABLE edgv.rev_vegetacao_a OWNER TO postgres;

ALTER TABLE edgv.rev_vegetacao_a
	 ADD CONSTRAINT rev_vegetacao_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_a
	 ADD CONSTRAINT rev_vegetacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_a
	 ADD CONSTRAINT rev_vegetacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_vegetacao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_vegetacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_vegetacao_l_geom ON edgv.rev_vegetacao_l USING gist (geom);

ALTER TABLE edgv.rev_vegetacao_l OWNER TO postgres;

ALTER TABLE edgv.rev_vegetacao_l
	 ADD CONSTRAINT rev_vegetacao_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_l
	 ADD CONSTRAINT rev_vegetacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_l
	 ADD CONSTRAINT rev_vegetacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_vegetacao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_vegetacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_vegetacao_p_geom ON edgv.rev_vegetacao_p USING gist (geom);

ALTER TABLE edgv.rev_vegetacao_p OWNER TO postgres;

ALTER TABLE edgv.rev_vegetacao_p
	 ADD CONSTRAINT rev_vegetacao_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_p
	 ADD CONSTRAINT rev_vegetacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_vegetacao_p
	 ADD CONSTRAINT rev_vegetacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_vegetacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_edificacao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_edificacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_edificacao_a_geom ON edgv.rev_edificacao_a USING gist (geom);

ALTER TABLE edgv.rev_edificacao_a OWNER TO postgres;

ALTER TABLE edgv.rev_edificacao_a
	 ADD CONSTRAINT rev_edificacao_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_a
	 ADD CONSTRAINT rev_edificacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_a
	 ADD CONSTRAINT rev_edificacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_edificacao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_edificacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_edificacao_l_geom ON edgv.rev_edificacao_l USING gist (geom);

ALTER TABLE edgv.rev_edificacao_l OWNER TO postgres;

ALTER TABLE edgv.rev_edificacao_l
	 ADD CONSTRAINT rev_edificacao_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_l
	 ADD CONSTRAINT rev_edificacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_l
	 ADD CONSTRAINT rev_edificacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_edificacao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_edificacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_edificacao_p_geom ON edgv.rev_edificacao_p USING gist (geom);

ALTER TABLE edgv.rev_edificacao_p OWNER TO postgres;

ALTER TABLE edgv.rev_edificacao_p
	 ADD CONSTRAINT rev_edificacao_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_p
	 ADD CONSTRAINT rev_edificacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_edificacao_p
	 ADD CONSTRAINT rev_edificacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_edificacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_transportes_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_transportes_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_transportes_a_geom ON edgv.rev_transportes_a USING gist (geom);

ALTER TABLE edgv.rev_transportes_a OWNER TO postgres;

ALTER TABLE edgv.rev_transportes_a
	 ADD CONSTRAINT rev_transportes_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_a
	 ADD CONSTRAINT rev_transportes_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_a
	 ADD CONSTRAINT rev_transportes_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_transportes_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_transportes_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_transportes_l_geom ON edgv.rev_transportes_l USING gist (geom);

ALTER TABLE edgv.rev_transportes_l OWNER TO postgres;

ALTER TABLE edgv.rev_transportes_l
	 ADD CONSTRAINT rev_transportes_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_l
	 ADD CONSTRAINT rev_transportes_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_l
	 ADD CONSTRAINT rev_transportes_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_transportes_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_transportes_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_transportes_p_geom ON edgv.rev_transportes_p USING gist (geom);

ALTER TABLE edgv.rev_transportes_p OWNER TO postgres;

ALTER TABLE edgv.rev_transportes_p
	 ADD CONSTRAINT rev_transportes_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_p
	 ADD CONSTRAINT rev_transportes_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_transportes_p
	 ADD CONSTRAINT rev_transportes_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_transportes_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_hidrografia_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_hidrografia_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_hidrografia_a_geom ON edgv.rev_hidrografia_a USING gist (geom);

ALTER TABLE edgv.rev_hidrografia_a OWNER TO postgres;

ALTER TABLE edgv.rev_hidrografia_a
	 ADD CONSTRAINT rev_hidrografia_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_a
	 ADD CONSTRAINT rev_hidrografia_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_a
	 ADD CONSTRAINT rev_hidrografia_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_hidrografia_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_hidrografia_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_hidrografia_l_geom ON edgv.rev_hidrografia_l USING gist (geom);

ALTER TABLE edgv.rev_hidrografia_l OWNER TO postgres;

ALTER TABLE edgv.rev_hidrografia_l
	 ADD CONSTRAINT rev_hidrografia_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_l
	 ADD CONSTRAINT rev_hidrografia_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_l
	 ADD CONSTRAINT rev_hidrografia_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_hidrografia_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_hidrografia_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_hidrografia_p_geom ON edgv.rev_hidrografia_p USING gist (geom);

ALTER TABLE edgv.rev_hidrografia_p OWNER TO postgres;

ALTER TABLE edgv.rev_hidrografia_p
	 ADD CONSTRAINT rev_hidrografia_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_p
	 ADD CONSTRAINT rev_hidrografia_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_hidrografia_p
	 ADD CONSTRAINT rev_hidrografia_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_hidrografia_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_reambulacao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_reambulacao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_reambulacao_a_geom ON edgv.rev_reambulacao_a USING gist (geom);

ALTER TABLE edgv.rev_reambulacao_a OWNER TO postgres;

ALTER TABLE edgv.rev_reambulacao_a
	 ADD CONSTRAINT rev_reambulacao_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_a
	 ADD CONSTRAINT rev_reambulacao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_a
	 ADD CONSTRAINT rev_reambulacao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_reambulacao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_reambulacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_reambulacao_l_geom ON edgv.rev_reambulacao_l USING gist (geom);

ALTER TABLE edgv.rev_reambulacao_l OWNER TO postgres;

ALTER TABLE edgv.rev_reambulacao_l
	 ADD CONSTRAINT rev_reambulacao_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_l
	 ADD CONSTRAINT rev_reambulacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_l
	 ADD CONSTRAINT rev_reambulacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_reambulacao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_reambulacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_reambulacao_p_geom ON edgv.rev_reambulacao_p USING gist (geom);

ALTER TABLE edgv.rev_reambulacao_p OWNER TO postgres;

ALTER TABLE edgv.rev_reambulacao_p
	 ADD CONSTRAINT rev_reambulacao_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_p
	 ADD CONSTRAINT rev_reambulacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_reambulacao_p
	 ADD CONSTRAINT rev_reambulacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_reambulacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_insumo_externo_a(
	 id serial NOT NULL,
	 nome varchar(255),
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT aux_insumo_externo_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_insumo_externo_a_geom ON edgv.aux_insumo_externo_a USING gist (geom);

ALTER TABLE edgv.aux_insumo_externo_a OWNER TO postgres;

ALTER TABLE edgv.aux_insumo_externo_a
	 ADD CONSTRAINT aux_insumo_externo_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_insumo_externo_a
	 ADD CONSTRAINT aux_insumo_externo_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_insumo_externo_l(
	 id serial NOT NULL,
	 nome varchar(255),
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aux_insumo_externo_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_insumo_externo_l_geom ON edgv.aux_insumo_externo_l USING gist (geom);

ALTER TABLE edgv.aux_insumo_externo_l OWNER TO postgres;

ALTER TABLE edgv.aux_insumo_externo_l
	 ADD CONSTRAINT aux_insumo_externo_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_insumo_externo_l
	 ADD CONSTRAINT aux_insumo_externo_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_insumo_externo_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 obs varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT aux_insumo_externo_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_insumo_externo_p_geom ON edgv.aux_insumo_externo_p USING gist (geom);

ALTER TABLE edgv.aux_insumo_externo_p OWNER TO postgres;

ALTER TABLE edgv.aux_insumo_externo_p
	 ADD CONSTRAINT aux_insumo_externo_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_insumo_externo_p
	 ADD CONSTRAINT aux_insumo_externo_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_insumo_externo_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_revisao_a(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT rev_revisao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_revisao_a_geom ON edgv.rev_revisao_a USING gist (geom);

ALTER TABLE edgv.rev_revisao_a OWNER TO postgres;

ALTER TABLE edgv.rev_revisao_a
	 ADD CONSTRAINT rev_revisao_a_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_a ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_a
	 ADD CONSTRAINT rev_revisao_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_a
	 ADD CONSTRAINT rev_revisao_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_revisao_l(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT rev_revisao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_revisao_l_geom ON edgv.rev_revisao_l USING gist (geom);

ALTER TABLE edgv.rev_revisao_l OWNER TO postgres;

ALTER TABLE edgv.rev_revisao_l
	 ADD CONSTRAINT rev_revisao_l_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_l ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_l
	 ADD CONSTRAINT rev_revisao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_l
	 ADD CONSTRAINT rev_revisao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.rev_revisao_p(
	 id serial NOT NULL,
	 obs varchar(255),
	 categoria varchar(255),
	 corrigido smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT rev_revisao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX rev_revisao_p_geom ON edgv.rev_revisao_p USING gist (geom);

ALTER TABLE edgv.rev_revisao_p OWNER TO postgres;

ALTER TABLE edgv.rev_revisao_p
	 ADD CONSTRAINT rev_revisao_p_corrigido_fk FOREIGN KEY (corrigido)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_p ALTER COLUMN corrigido SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_p
	 ADD CONSTRAINT rev_revisao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.rev_revisao_p
	 ADD CONSTRAINT rev_revisao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.rev_revisao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_moldura_a(
	 id serial NOT NULL,
	 nome varchar(255) NOT NULL,
	 mi varchar(255) NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT aux_moldura_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_moldura_a_geom ON edgv.aux_moldura_a USING gist (geom);

ALTER TABLE edgv.aux_moldura_a OWNER TO postgres;

ALTER TABLE edgv.aux_moldura_a
	 ADD CONSTRAINT aux_moldura_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_moldura_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_moldura_a
	 ADD CONSTRAINT aux_moldura_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_moldura_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_moldura_area_continua_a(
	 id serial NOT NULL,
	 nome varchar(255) NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT aux_moldura_area_continua_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_moldura_area_continua_a_geom ON edgv.aux_moldura_area_continua_a USING gist (geom);

ALTER TABLE edgv.aux_moldura_area_continua_a OWNER TO postgres;

ALTER TABLE edgv.aux_moldura_area_continua_a
	 ADD CONSTRAINT aux_moldura_area_continua_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_moldura_area_continua_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_moldura_area_continua_a
	 ADD CONSTRAINT aux_moldura_area_continua_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_moldura_area_continua_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_rascunho_l(
	 id serial NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aux_rascunho_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_rascunho_l_geom ON edgv.aux_rascunho_l USING gist (geom);

ALTER TABLE edgv.aux_rascunho_l OWNER TO postgres;

ALTER TABLE edgv.aux_rascunho_l
	 ADD CONSTRAINT aux_rascunho_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_rascunho_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_rascunho_l
	 ADD CONSTRAINT aux_rascunho_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_rascunho_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aux_rascunho_a(
	 id serial NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT aux_rascunho_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aux_rascunho_a_geom ON edgv.aux_rascunho_a USING gist (geom);

ALTER TABLE edgv.aux_rascunho_a OWNER TO postgres;

ALTER TABLE edgv.aux_rascunho_a
	 ADD CONSTRAINT aux_rascunho_a_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_rascunho_a ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aux_rascunho_a
	 ADD CONSTRAINT aux_rascunho_a_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aux_rascunho_a ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_limite_vegetacao_l(
	 id serial NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aquisicao_limite_vegetacao_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_limite_vegetacao_l_geom ON edgv.aquisicao_limite_vegetacao_l USING gist (geom);

ALTER TABLE edgv.aquisicao_limite_vegetacao_l OWNER TO postgres;

ALTER TABLE edgv.aquisicao_limite_vegetacao_l
	 ADD CONSTRAINT aquisicao_limite_vegetacao_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_vegetacao_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_limite_vegetacao_l
	 ADD CONSTRAINT aquisicao_limite_vegetacao_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_vegetacao_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_limite_massa_dagua_l(
	 id serial NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aquisicao_limite_massa_dagua_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_limite_massa_dagua_l_geom ON edgv.aquisicao_limite_massa_dagua_l USING gist (geom);

ALTER TABLE edgv.aquisicao_limite_massa_dagua_l OWNER TO postgres;

ALTER TABLE edgv.aquisicao_limite_massa_dagua_l
	 ADD CONSTRAINT aquisicao_limite_massa_dagua_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_massa_dagua_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_limite_massa_dagua_l
	 ADD CONSTRAINT aquisicao_limite_massa_dagua_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_massa_dagua_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_limite_area_edificada_l(
	 id serial NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiLinestring, 31982),
	 CONSTRAINT aquisicao_limite_area_edificada_l_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_limite_area_edificada_l_geom ON edgv.aquisicao_limite_area_edificada_l USING gist (geom);

ALTER TABLE edgv.aquisicao_limite_area_edificada_l OWNER TO postgres;

ALTER TABLE edgv.aquisicao_limite_area_edificada_l
	 ADD CONSTRAINT aquisicao_limite_area_edificada_l_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_area_edificada_l ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_limite_area_edificada_l
	 ADD CONSTRAINT aquisicao_limite_area_edificada_l_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_limite_area_edificada_l ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_centroide_vegetacao_p(
	 id serial NOT NULL,
	 tipo smallint NOT NULL,
	 sujeito_inundacao smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT aquisicao_centroide_vegetacao_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_centroide_vegetacao_p_geom ON edgv.aquisicao_centroide_vegetacao_p USING gist (geom);

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p OWNER TO postgres;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p
	 ADD CONSTRAINT aquisicao_centroide_vegetacao_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_veg (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p
	 ADD CONSTRAINT aquisicao_centroide_vegetacao_p_tipo_check 
	 CHECK (tipo = ANY(ARRAY[301 :: SMALLINT, 302 :: SMALLINT, 201 :: SMALLINT, 202 :: SMALLINT, 801 :: SMALLINT, 501 :: SMALLINT, 701 :: SMALLINT, 702 :: SMALLINT, 401 :: SMALLINT, 1101 :: SMALLINT, 901 :: SMALLINT, 601 :: SMALLINT, 194 :: SMALLINT, 196 :: SMALLINT, 150 :: SMALLINT, 118 :: SMALLINT, 102 :: SMALLINT, 115 :: SMALLINT, 114 :: SMALLINT, 116 :: SMALLINT, 103 :: SMALLINT, 151 :: SMALLINT, 117 :: SMALLINT, 153 :: SMALLINT, 152 :: SMALLINT, 119 :: SMALLINT, 142 :: SMALLINT, 107 :: SMALLINT, 124 :: SMALLINT, 198 :: SMALLINT, 195 :: SMALLINT, 1296 :: SMALLINT, 1000 :: SMALLINT, 999 :: SMALLINT])); 
ALTER TABLE edgv.aquisicao_centroide_vegetacao_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p
	 ADD CONSTRAINT aquisicao_centroide_vegetacao_p_sujeito_inundacao_fk FOREIGN KEY (sujeito_inundacao)
	 REFERENCES dominios.booleano (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p ALTER COLUMN sujeito_inundacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p
	 ADD CONSTRAINT aquisicao_centroide_vegetacao_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p
	 ADD CONSTRAINT aquisicao_centroide_vegetacao_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_vegetacao_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_centroide_corpo_dagua_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo smallint NOT NULL,
	 regime smallint NOT NULL,
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT aquisicao_centroide_corpo_dagua_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_centroide_corpo_dagua_p_geom ON edgv.aquisicao_centroide_corpo_dagua_p USING gist (geom);

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p OWNER TO postgres;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p
	 ADD CONSTRAINT aquisicao_centroide_corpo_dagua_p_tipo_fk FOREIGN KEY (tipo)
	 REFERENCES dominios.tipo_corpo_dagua (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p ALTER COLUMN tipo SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p
	 ADD CONSTRAINT aquisicao_centroide_corpo_dagua_p_regime_fk FOREIGN KEY (regime)
	 REFERENCES dominios.regime (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p ALTER COLUMN regime SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p
	 ADD CONSTRAINT aquisicao_centroide_corpo_dagua_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p
	 ADD CONSTRAINT aquisicao_centroide_corpo_dagua_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_corpo_dagua_p ALTER COLUMN tipo_insumo SET DEFAULT 999;

CREATE TABLE edgv.aquisicao_centroide_area_edificada_p(
	 id serial NOT NULL,
	 nome varchar(255),
	 tipo_comprovacao smallint NOT NULL,
	 tipo_insumo smallint NOT NULL,
	 observacao VARCHAR(255),
	 data_modificacao timestamp with time zone,
	 controle_id uuid,
	 ultimo_usuario VARCHAR(255),
	 geom geometry(MultiPoint, 31982),
	 CONSTRAINT aquisicao_centroide_area_edificada_p_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX aquisicao_centroide_area_edificada_p_geom ON edgv.aquisicao_centroide_area_edificada_p USING gist (geom);

ALTER TABLE edgv.aquisicao_centroide_area_edificada_p OWNER TO postgres;

ALTER TABLE edgv.aquisicao_centroide_area_edificada_p
	 ADD CONSTRAINT aquisicao_centroide_area_edificada_p_tipo_comprovacao_fk FOREIGN KEY (tipo_comprovacao)
	 REFERENCES dominios.tipo_comprovacao (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_area_edificada_p ALTER COLUMN tipo_comprovacao SET DEFAULT 999;

ALTER TABLE edgv.aquisicao_centroide_area_edificada_p
	 ADD CONSTRAINT aquisicao_centroide_area_edificada_p_tipo_insumo_fk FOREIGN KEY (tipo_insumo)
	 REFERENCES dominios.tipo_insumo (code) MATCH FULL
	 ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE edgv.aquisicao_centroide_area_edificada_p ALTER COLUMN tipo_insumo SET DEFAULT 999;
