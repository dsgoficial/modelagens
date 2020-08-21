CREATE TABLE public.gambiarra_edicao_a
(
    id serial NOT NULL,
    nome varchar(255) NOT NULL,
    mi varchar(255),
    inom varchar(255),
    denominador_escala varchar(255) NOT NULL,
    geom geometry(MultiPolygon,31982),
    CONSTRAINT gambiarra_edicao_a_pk PRIMARY KEY (id)
        WITH (FILLFACTOR=80)
);
CREATE INDEX gambiarra_edicao_a_geom ON public.gambiarra_edicao_a USING gist (geom);

ALTER TABLE public.gambiarra_edicao_a  OWNER to postgres;

CREATE TABLE public.gambiarra_edicao2_a
(
    id serial NOT NULL,
    nome varchar(255) NOT NULL,
    mi varchar(255),
    inom varchar(255),
    denominador_escala varchar(255) NOT NULL,
    geom geometry(MultiPolygon,31982),
    CONSTRAINT gambiarra_edicao2_a_pk PRIMARY KEY (id)
        WITH (FILLFACTOR=80)
);
CREATE INDEX gambiarra_edicao2_a_geom ON public.gambiarra_edicao2_a USING gist (geom);

ALTER TABLE public.gambiarra_edicao2_a  OWNER to postgres;

CREATE TABLE edgv.edicao_moldura_edicao_a(
	 id serial NOT NULL,
	 nome varchar(255),
     mi varchar(255),
     inom varchar(255),
	 denominador_escala varchar(255) NOT NULL,
	 geom geometry(MultiPolygon, 31982),
	 CONSTRAINT edicao_moldura_edicao_a_pk PRIMARY KEY (id)
	 WITH (FILLFACTOR = 80)
);
CREATE INDEX edicao_moldura_edicao_a_geom ON edgv.edicao_moldura_edicao_a USING gist (geom);

ALTER TABLE edgv.edicao_moldura_edicao_a OWNER TO postgres;