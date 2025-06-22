--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: hospital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital (
    id_hospital integer NOT NULL,
    cnes text
);


ALTER TABLE public.hospital OWNER TO postgres;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospital_id_hospital_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospital_id_hospital_seq OWNER TO postgres;

--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospital_id_hospital_seq OWNED BY public.hospital.id_hospital;


--
-- Name: localidade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localidade (
    id_local integer NOT NULL,
    estado text,
    municipio text,
    estado_notificacao text,
    municipio_notificacao text
);


ALTER TABLE public.localidade OWNER TO postgres;

--
-- Name: localidade_id_local_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.localidade_id_local_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.localidade_id_local_seq OWNER TO postgres;

--
-- Name: localidade_id_local_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.localidade_id_local_seq OWNED BY public.localidade.id_local;


--
-- Name: registro_ocupacao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registro_ocupacao (
    _id text NOT NULL,
    data_notificacao timestamp with time zone NOT NULL,
    criado_em timestamp with time zone,
    atualizado_em timestamp with time zone,
    id_hospital integer,
    id_local integer,
    id_status integer,
    ocupacao_suspeito_cli numeric,
    ocupacao_suspeito_uti numeric,
    ocupacao_confirmado_cli numeric,
    ocupacao_confirmado_uti numeric,
    ocupacao_covid_cli numeric,
    ocupacao_covid_uti numeric,
    ocupacao_hospitalar_cli numeric,
    ocupacao_hospitalar_uti numeric,
    saida_suspeita_obitos numeric,
    saida_suspeita_altas numeric,
    saida_confirmada_obitos numeric,
    saida_confirmada_altas numeric
);


ALTER TABLE public.registro_ocupacao OWNER TO postgres;

--
-- Name: status_envio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_envio (
    id_status integer NOT NULL,
    origem text,
    usuario_sistema text,
    excluido boolean,
    validado boolean
);


ALTER TABLE public.status_envio OWNER TO postgres;

--
-- Name: status_envio_id_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_envio_id_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.status_envio_id_status_seq OWNER TO postgres;

--
-- Name: status_envio_id_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_envio_id_status_seq OWNED BY public.status_envio.id_status;


--
-- Name: hospital id_hospital; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital ALTER COLUMN id_hospital SET DEFAULT nextval('public.hospital_id_hospital_seq'::regclass);


--
-- Name: localidade id_local; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade ALTER COLUMN id_local SET DEFAULT nextval('public.localidade_id_local_seq'::regclass);


--
-- Name: status_envio id_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_envio ALTER COLUMN id_status SET DEFAULT nextval('public.status_envio_id_status_seq'::regclass);


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospital (id_hospital, cnes)
FROM 'C:/trabalho_final_sql/hospital.csv'
WITH (
    FORMAT csv,
    DELIMITER ';',
    NULL '\N',
    HEADER false
);


--
-- Data for Name: localidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.localidade (id_local, estado, municipio, estado_notificacao, municipio_notificacao) 
FROM 'C:/trabalho_final_sql/localidade.csv'
WITH (
    FORMAT csv,
    DELIMITER ';',
    NULL '\N',
    HEADER false
);


--
-- Data for Name: registro_ocupacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.registro_ocupacao (_id, data_notificacao, criado_em, atualizado_em, id_hospital, id_local, id_status, ocupacao_suspeito_cli, ocupacao_suspeito_uti, ocupacao_confirmado_cli, ocupacao_confirmado_uti, ocupacao_covid_cli, ocupacao_covid_uti, ocupacao_hospitalar_cli, ocupacao_hospitalar_uti, saida_suspeita_obitos, saida_suspeita_altas, saida_confirmada_obitos, saida_confirmada_altas) 
FROM 'C:/trabalho_final_sql/registro_ocupacao.csv'
WITH (
    FORMAT csv,
    DELIMITER ';',
    NULL '\N',
    HEADER false
);


--
-- Data for Name: status_envio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_envio (id_status, origem, usuario_sistema, excluido, validado)
FROM 'C:/trabalho_final_sql/status_envio.csv'
WITH (
    FORMAT csv,
    DELIMITER ';',
    NULL '\N',
    HEADER false
);



--
-- Name: hospital_id_hospital_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospital_id_hospital_seq', 4069, true);


--
-- Name: localidade_id_local_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.localidade_id_local_seq', 2514, true);


--
-- Name: status_envio_id_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_envio_id_status_seq', 4354, true);


--
-- Name: hospital hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id_hospital);


--
-- Name: localidade localidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localidade
    ADD CONSTRAINT localidade_pkey PRIMARY KEY (id_local);


--
-- Name: registro_ocupacao registro_ocupacao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registro_ocupacao
    ADD CONSTRAINT registro_ocupacao_pkey PRIMARY KEY (_id, data_notificacao);


--
-- Name: status_envio status_envio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_envio
    ADD CONSTRAINT status_envio_pkey PRIMARY KEY (id_status);


--
-- Name: idx_hospital_cnes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hospital_cnes ON public.hospital USING btree (cnes);


--
-- Name: idx_localidade_chave; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_localidade_chave ON public.localidade USING btree (estado, municipio, estado_notificacao, municipio_notificacao);


--
-- Name: idx_status_envio_chave; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_status_envio_chave ON public.status_envio USING btree (origem, usuario_sistema, excluido, validado);


--
-- Name: registro_ocupacao registro_ocupacao_id_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registro_ocupacao
    ADD CONSTRAINT registro_ocupacao_id_hospital_fkey FOREIGN KEY (id_hospital) REFERENCES public.hospital(id_hospital);


--
-- Name: registro_ocupacao registro_ocupacao_id_local_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registro_ocupacao
    ADD CONSTRAINT registro_ocupacao_id_local_fkey FOREIGN KEY (id_local) REFERENCES public.localidade(id_local);


--
-- Name: registro_ocupacao registro_ocupacao_id_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registro_ocupacao
    ADD CONSTRAINT registro_ocupacao_id_status_fkey FOREIGN KEY (id_status) REFERENCES public.status_envio(id_status);


--
-- PostgreSQL database dump complete
--