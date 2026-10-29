--
-- PostgreSQL database dump
--

\restrict EBVwbARp07LViniwE2oSIfkp931YreAAqlmE8duCDkOR1A624AL8GMkQ7Cg76aR

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: canales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.canales (
    id integer NOT NULL,
    tipo character varying(30) NOT NULL,
    grupo_id integer,
    materia_id integer,
    grado_id integer,
    usuario_id integer,
    CONSTRAINT canales_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['grupo_materia'::character varying, 'coordinacion'::character varying, 'general'::character varying, 'directo'::character varying])::text[]))),
    CONSTRAINT chk_canal_coherente CHECK (((((tipo)::text = 'grupo_materia'::text) AND (grupo_id IS NOT NULL) AND (materia_id IS NOT NULL) AND (grado_id IS NULL) AND (usuario_id IS NULL)) OR (((tipo)::text = 'coordinacion'::text) AND (grado_id IS NOT NULL) AND (grupo_id IS NULL) AND (usuario_id IS NULL)) OR (((tipo)::text = 'general'::text) AND (grupo_id IS NULL) AND (materia_id IS NULL) AND (grado_id IS NULL) AND (usuario_id IS NULL)) OR (((tipo)::text = 'directo'::text) AND (usuario_id IS NOT NULL) AND (grupo_id IS NULL) AND (materia_id IS NULL) AND (grado_id IS NULL))))
);


ALTER TABLE public.canales OWNER TO postgres;

--
-- Name: canales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.canales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.canales_id_seq OWNER TO postgres;

--
-- Name: canales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.canales_id_seq OWNED BY public.canales.id;


--
-- Name: coordinador_area; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coordinador_area (
    id integer NOT NULL,
    coordinador_id integer NOT NULL,
    materia_id integer NOT NULL,
    grado_id integer
);


ALTER TABLE public.coordinador_area OWNER TO postgres;

--
-- Name: coordinador_area_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.coordinador_area_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.coordinador_area_id_seq OWNER TO postgres;

--
-- Name: coordinador_area_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.coordinador_area_id_seq OWNED BY public.coordinador_area.id;


--
-- Name: estudiante_grupo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estudiante_grupo (
    id integer NOT NULL,
    estudiante_id integer NOT NULL,
    grupo_id integer NOT NULL
);


ALTER TABLE public.estudiante_grupo OWNER TO postgres;

--
-- Name: estudiante_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estudiante_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estudiante_grupo_id_seq OWNER TO postgres;

--
-- Name: estudiante_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estudiante_grupo_id_seq OWNED BY public.estudiante_grupo.id;


--
-- Name: grados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grados (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.grados OWNER TO postgres;

--
-- Name: grados_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grados_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grados_id_seq OWNER TO postgres;

--
-- Name: grados_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grados_id_seq OWNED BY public.grados.id;


--
-- Name: grupos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupos (
    id integer NOT NULL,
    grado_id integer NOT NULL,
    nombre character varying(20) NOT NULL
);


ALTER TABLE public.grupos OWNER TO postgres;

--
-- Name: grupos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.grupos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.grupos_id_seq OWNER TO postgres;

--
-- Name: grupos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.grupos_id_seq OWNED BY public.grupos.id;


--
-- Name: materias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.materias (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.materias OWNER TO postgres;

--
-- Name: materias_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.materias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.materias_id_seq OWNER TO postgres;

--
-- Name: materias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.materias_id_seq OWNED BY public.materias.id;


--
-- Name: mensajes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mensajes (
    id integer NOT NULL,
    canal_id integer NOT NULL,
    emisor_id integer NOT NULL,
    contenido text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mensajes OWNER TO postgres;

--
-- Name: mensajes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mensajes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mensajes_id_seq OWNER TO postgres;

--
-- Name: mensajes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mensajes_id_seq OWNED BY public.mensajes.id;


--
-- Name: profesor_materia_grupo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profesor_materia_grupo (
    id integer NOT NULL,
    profesor_id integer NOT NULL,
    materia_id integer NOT NULL,
    grupo_id integer NOT NULL
);


ALTER TABLE public.profesor_materia_grupo OWNER TO postgres;

--
-- Name: profesor_materia_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profesor_materia_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.profesor_materia_grupo_id_seq OWNER TO postgres;

--
-- Name: profesor_materia_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profesor_materia_grupo_id_seq OWNED BY public.profesor_materia_grupo.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    usuario character varying(50) NOT NULL,
    contrasena_hash character varying(255) NOT NULL,
    rol character varying(20) NOT NULL,
    CONSTRAINT usuarios_rol_check CHECK (((rol)::text = ANY ((ARRAY['estudiante'::character varying, 'profesor'::character varying, 'coordinador'::character varying, 'administracion'::character varying])::text[])))
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: canales id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales ALTER COLUMN id SET DEFAULT nextval('public.canales_id_seq'::regclass);


--
-- Name: coordinador_area id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coordinador_area ALTER COLUMN id SET DEFAULT nextval('public.coordinador_area_id_seq'::regclass);


--
-- Name: estudiante_grupo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiante_grupo ALTER COLUMN id SET DEFAULT nextval('public.estudiante_grupo_id_seq'::regclass);


--
-- Name: grados id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grados ALTER COLUMN id SET DEFAULT nextval('public.grados_id_seq'::regclass);


--
-- Name: grupos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos ALTER COLUMN id SET DEFAULT nextval('public.grupos_id_seq'::regclass);


--
-- Name: materias id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materias ALTER COLUMN id SET DEFAULT nextval('public.materias_id_seq'::regclass);


--
-- Name: mensajes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes ALTER COLUMN id SET DEFAULT nextval('public.mensajes_id_seq'::regclass);


--
-- Name: profesor_materia_grupo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo ALTER COLUMN id SET DEFAULT nextval('public.profesor_materia_grupo_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: canales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.canales (id, tipo, grupo_id, materia_id, grado_id, usuario_id) FROM stdin;
1	general	\N	\N	\N	\N
2	coordinacion	\N	\N	1	\N
3	coordinacion	\N	\N	2	\N
4	coordinacion	\N	\N	3	\N
5	coordinacion	\N	\N	4	\N
6	coordinacion	\N	\N	5	\N
7	coordinacion	\N	\N	6	\N
8	coordinacion	\N	\N	7	\N
9	coordinacion	\N	\N	8	\N
10	coordinacion	\N	\N	9	\N
11	coordinacion	\N	\N	10	\N
12	coordinacion	\N	\N	11	\N
20	grupo_materia	1	1	\N	\N
23	directo	\N	\N	\N	5
29	grupo_materia	1	2	\N	\N
30	grupo_materia	1	3	\N	\N
31	grupo_materia	1	4	\N	\N
32	grupo_materia	1	5	\N	\N
33	grupo_materia	1	6	\N	\N
34	grupo_materia	1	7	\N	\N
35	grupo_materia	1	8	\N	\N
36	grupo_materia	1	9	\N	\N
37	grupo_materia	1	10	\N	\N
38	grupo_materia	1	11	\N	\N
39	grupo_materia	1	12	\N	\N
40	grupo_materia	1	13	\N	\N
41	grupo_materia	1	66	\N	\N
46	grupo_materia	2	1	\N	\N
48	grupo_materia	2	3	\N	\N
51	directo	\N	\N	\N	8
54	grupo_materia	2	2	\N	\N
56	grupo_materia	2	4	\N	\N
57	grupo_materia	2	5	\N	\N
58	grupo_materia	2	6	\N	\N
59	grupo_materia	2	7	\N	\N
60	grupo_materia	2	8	\N	\N
61	grupo_materia	2	9	\N	\N
62	grupo_materia	2	10	\N	\N
63	grupo_materia	2	11	\N	\N
64	grupo_materia	2	12	\N	\N
65	grupo_materia	2	13	\N	\N
66	grupo_materia	2	66	\N	\N
84	directo	\N	\N	\N	7
102	directo	\N	\N	\N	6
\.


--
-- Data for Name: coordinador_area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coordinador_area (id, coordinador_id, materia_id, grado_id) FROM stdin;
\.


--
-- Data for Name: estudiante_grupo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estudiante_grupo (id, estudiante_id, grupo_id) FROM stdin;
1	4	1
3	1	2
\.


--
-- Data for Name: grados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grados (id, nombre) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
10	10
11	11
\.


--
-- Data for Name: grupos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grupos (id, grado_id, nombre) FROM stdin;
1	8	8-03
2	11	11-06
\.


--
-- Data for Name: materias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.materias (id, nombre) FROM stdin;
1	Matemáticas
2	Lengua Castellana
3	Inglés
4	Ciencias Naturales
5	Física
6	Química
7	Ciencias Sociales
8	Educación Física
9	Educación Artística
10	Ética y Valores
11	Religión
12	Tecnología e Informática
13	Filosofía
66	matematicas
\.


--
-- Data for Name: mensajes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mensajes (id, canal_id, emisor_id, contenido, "timestamp") FROM stdin;
1	20	5	mañana hay examen de números reales	2026-10-18 12:36:29.006643-05
2	48	8	hay tarea de ingles, traer las copias	2026-10-18 13:52:39.622537-05
3	30	8	traer la guia impresa	2026-10-18 13:52:48.902669-05
4	46	7	simulacro icfes	2026-10-18 13:54:39.301189-05
5	12	6	mañana no hay clases	2026-10-18 13:55:22.973604-05
6	102	3	mañana se tienen que postular los candidatos a personeria	2026-10-19 19:08:35.961715-05
\.


--
-- Data for Name: profesor_materia_grupo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profesor_materia_grupo (id, profesor_id, materia_id, grupo_id) FROM stdin;
1	5	1	1
2	7	1	2
3	8	3	1
4	8	3	2
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombre, usuario, contrasena_hash, rol) FROM stdin;
1	mateo	mateobustillo	d182409f37337cabe65449f97931b4bc:2dca9258d4c2ebd02b84ff348b8001c87aa726fa6ae9da27e21901781e358564	estudiante
2	Administración	admin	b8705f514f993287de1b1a1f355e6518:fc564e7a8489d02d07cfcfc4a7f09cd98941f0fe507570b755a44bba64bf2b24	administracion
3	Administrador	administrador	a1b2c3d4e5f60718293a4b5c6d7e8f90:88503bcd35c0570667bee57220b1a1d097c5de405d8855883141c5106ed2aede	administracion
4	michael andres bustillo mateo	michael-bustillo	33219b350b0d602ac14b349440a265e4:0cd7bc5bc5ab1ec1d56000f6240c1c9a09c4c56a2598ea5901155e10d97a9cdc	estudiante
5	bornachera	bornachera	fdfd12f28d109635fff650f6484be484:957040e0de9081b060fb43e55df8d46ebdff296c5e24ad636101fe6ff84e8b11	profesor
6	maria cristina	maria-cristina	53c1506fe12ad7f92b0383ed321fe599:c6c19f161e3480432ae2e5fde62bcaff1f59575aec9b7cee87e1907feb4ba61f	coordinador
7	alexander vega	alex-vega	f1456982c6ff26e181ff555941fe3cfd:635d31ceb6a70f4a03601dd1048e2b7067645bca00423f684e3ee9ac16bc7477	profesor
8	marceliano cuentas	marceliano	b06a667a3d6e5ec4c8bf0208cf574610:a1b854f1a05e8907b42c7e6cf89cfcfb091d48115185196a447331c03f3656ab	profesor
\.


--
-- Name: canales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.canales_id_seq', 157, true);


--
-- Name: coordinador_area_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coordinador_area_id_seq', 1, false);


--
-- Name: estudiante_grupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estudiante_grupo_id_seq', 3, true);


--
-- Name: grados_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grados_id_seq', 88, true);


--
-- Name: grupos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grupos_id_seq', 2, true);


--
-- Name: materias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.materias_id_seq', 105, true);


--
-- Name: mensajes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mensajes_id_seq', 6, true);


--
-- Name: profesor_materia_grupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profesor_materia_grupo_id_seq', 4, true);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 8, true);


--
-- Name: canales canales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales
    ADD CONSTRAINT canales_pkey PRIMARY KEY (id);


--
-- Name: coordinador_area coordinador_area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coordinador_area
    ADD CONSTRAINT coordinador_area_pkey PRIMARY KEY (id);


--
-- Name: estudiante_grupo estudiante_grupo_estudiante_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiante_grupo
    ADD CONSTRAINT estudiante_grupo_estudiante_id_key UNIQUE (estudiante_id);


--
-- Name: estudiante_grupo estudiante_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiante_grupo
    ADD CONSTRAINT estudiante_grupo_pkey PRIMARY KEY (id);


--
-- Name: grados grados_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grados
    ADD CONSTRAINT grados_nombre_key UNIQUE (nombre);


--
-- Name: grados grados_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grados
    ADD CONSTRAINT grados_pkey PRIMARY KEY (id);


--
-- Name: grupos grupos_grado_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_grado_id_nombre_key UNIQUE (grado_id, nombre);


--
-- Name: grupos grupos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_pkey PRIMARY KEY (id);


--
-- Name: materias materias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_nombre_key UNIQUE (nombre);


--
-- Name: materias materias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_pkey PRIMARY KEY (id);


--
-- Name: mensajes mensajes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes
    ADD CONSTRAINT mensajes_pkey PRIMARY KEY (id);


--
-- Name: profesor_materia_grupo profesor_materia_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo
    ADD CONSTRAINT profesor_materia_grupo_pkey PRIMARY KEY (id);


--
-- Name: profesor_materia_grupo profesor_materia_grupo_profesor_id_materia_id_grupo_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo
    ADD CONSTRAINT profesor_materia_grupo_profesor_id_materia_id_grupo_id_key UNIQUE (profesor_id, materia_id, grupo_id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_usuario_key UNIQUE (usuario);


--
-- Name: ix_mensajes_canal_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mensajes_canal_fecha ON public.mensajes USING btree (canal_id, "timestamp");


--
-- Name: ux_canal_coordinacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_canal_coordinacion ON public.canales USING btree (grado_id, COALESCE(materia_id, 0)) WHERE ((grado_id IS NOT NULL) AND (grupo_id IS NULL));


--
-- Name: ux_canal_directo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_canal_directo ON public.canales USING btree (usuario_id) WHERE ((tipo)::text = 'directo'::text);


--
-- Name: ux_canal_general; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_canal_general ON public.canales USING btree (tipo) WHERE ((tipo)::text = 'general'::text);


--
-- Name: ux_canal_grupo_materia; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_canal_grupo_materia ON public.canales USING btree (grupo_id, materia_id) WHERE (grupo_id IS NOT NULL);


--
-- Name: ux_coordinador_area_con_grado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_coordinador_area_con_grado ON public.coordinador_area USING btree (coordinador_id, materia_id, grado_id) WHERE (grado_id IS NOT NULL);


--
-- Name: ux_coordinador_area_sin_grado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_coordinador_area_sin_grado ON public.coordinador_area USING btree (coordinador_id, materia_id) WHERE (grado_id IS NULL);


--
-- Name: canales canales_grado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales
    ADD CONSTRAINT canales_grado_id_fkey FOREIGN KEY (grado_id) REFERENCES public.grados(id) ON DELETE RESTRICT;


--
-- Name: canales canales_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales
    ADD CONSTRAINT canales_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON DELETE RESTRICT;


--
-- Name: canales canales_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales
    ADD CONSTRAINT canales_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE RESTRICT;


--
-- Name: canales canales_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.canales
    ADD CONSTRAINT canales_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: coordinador_area coordinador_area_coordinador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coordinador_area
    ADD CONSTRAINT coordinador_area_coordinador_id_fkey FOREIGN KEY (coordinador_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: coordinador_area coordinador_area_grado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coordinador_area
    ADD CONSTRAINT coordinador_area_grado_id_fkey FOREIGN KEY (grado_id) REFERENCES public.grados(id) ON DELETE RESTRICT;


--
-- Name: coordinador_area coordinador_area_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coordinador_area
    ADD CONSTRAINT coordinador_area_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE RESTRICT;


--
-- Name: estudiante_grupo estudiante_grupo_estudiante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiante_grupo
    ADD CONSTRAINT estudiante_grupo_estudiante_id_fkey FOREIGN KEY (estudiante_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: estudiante_grupo estudiante_grupo_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estudiante_grupo
    ADD CONSTRAINT estudiante_grupo_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON DELETE RESTRICT;


--
-- Name: grupos grupos_grado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_grado_id_fkey FOREIGN KEY (grado_id) REFERENCES public.grados(id) ON DELETE RESTRICT;


--
-- Name: mensajes mensajes_canal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes
    ADD CONSTRAINT mensajes_canal_id_fkey FOREIGN KEY (canal_id) REFERENCES public.canales(id) ON DELETE CASCADE;


--
-- Name: mensajes mensajes_emisor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mensajes
    ADD CONSTRAINT mensajes_emisor_id_fkey FOREIGN KEY (emisor_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: profesor_materia_grupo profesor_materia_grupo_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo
    ADD CONSTRAINT profesor_materia_grupo_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON DELETE RESTRICT;


--
-- Name: profesor_materia_grupo profesor_materia_grupo_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo
    ADD CONSTRAINT profesor_materia_grupo_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id) ON DELETE RESTRICT;


--
-- Name: profesor_materia_grupo profesor_materia_grupo_profesor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profesor_materia_grupo
    ADD CONSTRAINT profesor_materia_grupo_profesor_id_fkey FOREIGN KEY (profesor_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict EBVwbARp07LViniwE2oSIfkp931YreAAqlmE8duCDkOR1A624AL8GMkQ7Cg76aR

