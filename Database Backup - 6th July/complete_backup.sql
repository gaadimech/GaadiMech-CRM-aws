--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.5 (Homebrew)

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
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO crmadmin;

--
-- Name: daily_followup_count; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.daily_followup_count (
    id integer NOT NULL,
    date date NOT NULL,
    user_id integer NOT NULL,
    initial_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.daily_followup_count OWNER TO crmadmin;

--
-- Name: daily_followup_count_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.daily_followup_count_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.daily_followup_count_id_seq OWNER TO crmadmin;

--
-- Name: daily_followup_count_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.daily_followup_count_id_seq OWNED BY public.daily_followup_count.id;


--
-- Name: lead; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.lead (
    id integer NOT NULL,
    customer_name character varying(100) NOT NULL,
    mobile character varying(15) NOT NULL,
    followup_date timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'Needs Followup'::character varying NOT NULL,
    remarks text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    creator_id integer NOT NULL,
    modified_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    car_registration character varying(20)
);


ALTER TABLE public.lead OWNER TO crmadmin;

--
-- Name: lead_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.lead_id_seq
    START WITH 7692
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lead_id_seq OWNER TO crmadmin;

--
-- Name: lead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.lead_id_seq OWNED BY public.lead.id;


--
-- Name: push_subscription; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.push_subscription (
    id integer NOT NULL,
    user_id integer NOT NULL,
    endpoint text NOT NULL,
    p256dh_key text NOT NULL,
    auth_key text NOT NULL,
    user_agent text,
    created_at timestamp without time zone,
    is_active boolean
);


ALTER TABLE public.push_subscription OWNER TO crmadmin;

--
-- Name: push_subscription_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.push_subscription_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.push_subscription_id_seq OWNER TO crmadmin;

--
-- Name: push_subscription_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.push_subscription_id_seq OWNED BY public.push_subscription.id;


--
-- Name: team_assignment; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.team_assignment (
    id integer NOT NULL,
    unassigned_lead_id integer NOT NULL,
    assigned_to_user_id integer NOT NULL,
    assigned_date date NOT NULL,
    assigned_at timestamp without time zone,
    assigned_by integer NOT NULL,
    status character varying(20) NOT NULL,
    processed_at timestamp without time zone,
    added_to_crm boolean,
    CONSTRAINT valid_assignment_status CHECK (((status)::text = ANY ((ARRAY['Assigned'::character varying, 'Contacted'::character varying, 'Added to CRM'::character varying, 'Ignored'::character varying])::text[])))
);


ALTER TABLE public.team_assignment OWNER TO crmadmin;

--
-- Name: team_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.team_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_assignment_id_seq OWNER TO crmadmin;

--
-- Name: team_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.team_assignment_id_seq OWNED BY public.team_assignment.id;


--
-- Name: unassigned_lead; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.unassigned_lead (
    id integer NOT NULL,
    mobile character varying(15) NOT NULL,
    customer_name character varying(100),
    car_manufacturer character varying(50),
    car_model character varying(50),
    pickup_type character varying(20),
    service_type character varying(50),
    scheduled_date timestamp without time zone,
    source character varying(30),
    remarks text,
    created_at timestamp without time zone,
    created_by integer NOT NULL,
    CONSTRAINT valid_pickup_type CHECK (((pickup_type)::text = ANY ((ARRAY['Pickup'::character varying, 'Self Walkin'::character varying])::text[]))),
    CONSTRAINT valid_service_type CHECK (((service_type)::text = ANY ((ARRAY['Express Car Service'::character varying, 'Dent Paint'::character varying, 'AC Service'::character varying, 'Car Wash'::character varying, 'Repairs'::character varying])::text[]))),
    CONSTRAINT valid_source CHECK (((source)::text = ANY ((ARRAY['WhatsApp'::character varying, 'Chatbot'::character varying, 'Website'::character varying, 'Social Media'::character varying])::text[])))
);


ALTER TABLE public.unassigned_lead OWNER TO crmadmin;

--
-- Name: unassigned_lead_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.unassigned_lead_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.unassigned_lead_id_seq OWNER TO crmadmin;

--
-- Name: unassigned_lead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.unassigned_lead_id_seq OWNED BY public.unassigned_lead.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(80) NOT NULL,
    password_hash character varying(120) NOT NULL,
    name character varying(100) NOT NULL,
    is_admin boolean DEFAULT false
);


ALTER TABLE public."user" OWNER TO crmadmin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(80) NOT NULL,
    name character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_admin boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO crmadmin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO crmadmin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: worked_lead; Type: TABLE; Schema: public; Owner: crmadmin
--

CREATE TABLE public.worked_lead (
    id integer NOT NULL,
    lead_id integer NOT NULL,
    user_id integer NOT NULL,
    work_date date NOT NULL,
    old_followup_date timestamp without time zone,
    new_followup_date timestamp without time zone NOT NULL,
    worked_at timestamp without time zone
);


ALTER TABLE public.worked_lead OWNER TO crmadmin;

--
-- Name: worked_lead_id_seq; Type: SEQUENCE; Schema: public; Owner: crmadmin
--

CREATE SEQUENCE public.worked_lead_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.worked_lead_id_seq OWNER TO crmadmin;

--
-- Name: worked_lead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crmadmin
--

ALTER SEQUENCE public.worked_lead_id_seq OWNED BY public.worked_lead.id;


--
-- Name: daily_followup_count id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.daily_followup_count ALTER COLUMN id SET DEFAULT nextval('public.daily_followup_count_id_seq'::regclass);


--
-- Name: lead id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.lead ALTER COLUMN id SET DEFAULT nextval('public.lead_id_seq'::regclass);


--
-- Name: push_subscription id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.push_subscription ALTER COLUMN id SET DEFAULT nextval('public.push_subscription_id_seq'::regclass);


--
-- Name: team_assignment id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.team_assignment ALTER COLUMN id SET DEFAULT nextval('public.team_assignment_id_seq'::regclass);


--
-- Name: unassigned_lead id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.unassigned_lead ALTER COLUMN id SET DEFAULT nextval('public.unassigned_lead_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: worked_lead id; Type: DEFAULT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.worked_lead ALTER COLUMN id SET DEFAULT nextval('public.worked_lead_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.alembic_version (version_num) FROM stdin;
395c66e828a3
\.


--
-- Data for Name: daily_followup_count; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.daily_followup_count (id, date, user_id, initial_count, created_at) FROM stdin;
2	2025-06-28	4	50	2025-06-27 19:41:39.416008+00
3	2025-06-28	1	0	2025-06-27 19:41:39.517325+00
4	2025-06-28	5	0	2025-06-27 19:41:39.620486+00
5	2025-06-28	6	117	2025-06-27 19:41:39.730017+00
6	2025-06-28	3	0	2025-06-27 19:41:39.832905+00
7	2025-06-28	2	0	2025-06-27 19:41:39.935995+00
8	2025-06-28	7	0	2025-06-27 19:41:40.039395+00
9	2025-06-28	8	1	2025-06-27 19:41:40.141971+00
10	2025-06-29	6	53	2025-06-29 07:07:26.872665+00
11	2025-06-30	4	83	2025-06-29 19:03:52.29315+00
12	2025-06-30	1	0	2025-06-29 19:03:52.293169+00
13	2025-06-30	5	0	2025-06-29 19:03:52.293174+00
14	2025-06-30	6	100	2025-06-29 19:03:52.293179+00
15	2025-06-30	3	0	2025-06-29 19:03:52.293185+00
16	2025-06-30	2	0	2025-06-29 19:03:52.293189+00
17	2025-06-30	7	0	2025-06-29 19:03:52.293193+00
18	2025-06-30	8	0	2025-06-29 19:03:52.293198+00
19	2025-06-29	4	24	2025-06-29 19:03:57.769956+00
20	2025-06-29	1	1	2025-06-29 19:03:57.769971+00
21	2025-06-29	5	0	2025-06-29 19:03:57.769976+00
22	2025-06-29	3	0	2025-06-29 19:03:57.76998+00
23	2025-06-29	2	0	2025-06-29 19:03:57.769984+00
24	2025-06-29	7	0	2025-06-29 19:03:57.769988+00
25	2025-06-29	8	0	2025-06-29 19:03:57.769992+00
27	2025-07-01	1	0	2025-06-30 18:37:26.454047+00
28	2025-07-01	5	0	2025-06-30 18:37:26.454055+00
30	2025-07-01	3	0	2025-06-30 18:37:26.454071+00
31	2025-07-01	2	0	2025-06-30 18:37:26.454078+00
32	2025-07-01	7	0	2025-06-30 18:37:26.454085+00
33	2025-07-01	8	0	2025-06-30 18:37:26.454102+00
35	2025-06-30	9	0	2025-07-01 07:36:22.024047+00
36	2025-07-30	4	0	2025-07-01 07:37:14.36196+00
37	2025-07-30	1	0	2025-07-01 07:37:14.361979+00
38	2025-07-30	5	0	2025-07-01 07:37:14.361986+00
39	2025-07-30	6	2	2025-07-01 07:37:14.361991+00
40	2025-07-30	3	0	2025-07-01 07:37:14.361995+00
41	2025-07-30	2	0	2025-07-01 07:37:14.361999+00
42	2025-07-30	7	0	2025-07-01 07:37:14.362004+00
43	2025-07-30	8	0	2025-07-01 07:37:14.362008+00
44	2025-07-30	9	116	2025-07-01 07:37:14.362012+00
45	2025-07-02	9	118	2025-07-01 08:23:09.018297+00
26	2025-07-01	4	34	2025-06-30 18:37:26.453993+00
29	2025-07-01	6	24	2025-06-30 18:37:26.454062+00
34	2025-07-01	9	68	2025-07-01 06:38:22.433542+00
46	2025-07-02	4	99	2025-07-02 05:13:00.123487+00
47	2025-07-03	9	128	2025-07-02 05:22:55.498341+00
48	2025-07-04	9	123	2025-07-02 06:51:54.221518+00
49	2025-07-02	1	0	2025-07-02 07:11:53.155977+00
50	2025-07-02	5	0	2025-07-02 07:11:53.155996+00
51	2025-07-02	6	96	2025-07-02 07:11:53.156001+00
52	2025-07-02	3	0	2025-07-02 07:11:53.156005+00
53	2025-07-02	2	0	2025-07-02 07:11:53.156011+00
54	2025-07-02	7	0	2025-07-02 07:11:53.156016+00
55	2025-07-02	8	0	2025-07-02 07:11:53.15602+00
57	2025-07-13	9	128	2025-07-02 09:35:37.427311+00
58	2025-07-05	9	128	2025-07-02 09:35:49.879027+00
59	2025-07-07	9	123	2025-07-02 10:37:21.027977+00
60	2025-07-08	9	122	2025-07-02 10:37:24.630794+00
61	2025-07-09	9	120	2025-07-02 10:37:28.230763+00
62	2025-07-10	9	123	2025-07-02 10:37:31.638765+00
63	2025-07-20	9	118	2025-07-02 10:37:36.738202+00
64	2025-06-05	9	0	2025-07-02 14:37:26.741081+00
65	2025-10-21	9	1	2025-07-02 14:37:35.759691+00
66	2025-08-08	9	2	2025-07-02 14:37:46.822252+00
67	2025-07-24	9	119	2025-07-02 14:37:51.377607+00
68	2025-07-31	9	3	2025-07-02 14:37:56.11248+00
69	2025-07-17	9	123	2025-07-03 09:54:53.221376+00
70	2025-07-29	9	133	2025-07-03 09:54:59.450143+00
71	2025-07-28	9	122	2025-07-03 09:55:16.51238+00
72	2025-07-03	4	83	2025-07-03 12:03:41.297254+00
73	2025-07-03	1	0	2025-07-03 12:03:41.297272+00
74	2025-07-03	5	0	2025-07-03 12:03:41.297277+00
75	2025-07-03	6	82	2025-07-03 12:03:41.297281+00
76	2025-07-03	3	0	2025-07-03 12:03:41.297288+00
77	2025-07-03	2	0	2025-07-03 12:03:41.297293+00
78	2025-07-03	7	0	2025-07-03 12:03:41.297297+00
79	2025-07-03	8	0	2025-07-03 12:03:41.297302+00
80	2025-07-04	4	100	2025-07-03 12:03:46.561225+00
81	2025-07-04	1	0	2025-07-03 12:03:46.561244+00
82	2025-07-04	5	0	2025-07-03 12:03:46.561248+00
83	2025-07-04	6	89	2025-07-03 12:03:46.561252+00
84	2025-07-04	3	0	2025-07-03 12:03:46.561256+00
85	2025-07-04	2	0	2025-07-03 12:03:46.56126+00
86	2025-07-04	7	0	2025-07-03 12:03:46.561264+00
87	2025-07-04	8	0	2025-07-03 12:03:46.561267+00
88	2025-11-22	9	0	2025-07-04 10:11:25.215276+00
89	2026-01-22	9	1	2025-07-04 10:11:31.673815+00
90	2026-01-20	9	0	2025-07-04 10:12:38.448469+00
91	2025-11-20	9	4	2025-07-04 10:12:42.020595+00
92	2025-12-31	9	2	2025-07-04 10:12:57.06987+00
93	2025-07-05	4	86	2025-07-04 10:59:36.261065+00
94	2025-07-05	1	0	2025-07-04 10:59:36.261079+00
95	2025-07-05	5	0	2025-07-04 10:59:36.261084+00
96	2025-07-05	6	70	2025-07-04 10:59:36.261088+00
97	2025-07-05	3	0	2025-07-04 10:59:36.261094+00
98	2025-07-05	2	0	2025-07-04 10:59:36.261099+00
99	2025-07-05	7	0	2025-07-04 10:59:36.261103+00
100	2025-07-05	8	0	2025-07-04 10:59:36.261108+00
103	2025-07-06	5	3	2025-07-05 22:01:45.760811+00
105	2025-07-06	3	0	2025-07-05 22:01:45.760827+00
106	2025-07-06	2	1	2025-07-05 22:01:45.760832+00
107	2025-07-06	7	0	2025-07-05 22:01:45.760836+00
108	2025-07-06	8	0	2025-07-05 22:01:45.760841+00
109	2025-08-10	9	0	2025-07-06 05:23:54.265159+00
110	2025-07-27	9	119	2025-07-06 07:20:36.435236+00
111	2025-07-26	9	118	2025-07-06 07:20:38.814593+00
112	2025-07-25	9	128	2025-07-06 07:20:41.05466+00
113	2025-07-23	9	123	2025-07-06 07:20:44.874659+00
114	2025-07-22	9	123	2025-07-06 07:20:47.829757+00
115	2025-07-21	9	124	2025-07-06 07:20:49.655257+00
116	2025-07-19	9	121	2025-07-06 07:20:54.054474+00
117	2025-08-01	9	1	2025-07-06 07:21:02.37713+00
118	2025-08-15	9	1	2025-07-06 09:07:36.550189+00
119	2025-08-21	9	1	2025-07-06 09:07:41.999414+00
120	2025-08-14	9	2	2025-07-06 09:07:45.908268+00
121	2025-08-23	9	0	2025-07-06 09:07:50.93565+00
122	2025-08-22	9	5	2025-07-06 09:07:55.15373+00
123	2025-08-13	9	6	2025-07-06 09:08:02.599383+00
101	2025-07-06	4	83	2025-07-05 22:01:45.760779+00
102	2025-07-06	1	1	2025-07-05 22:01:45.760805+00
104	2025-07-06	6	53	2025-07-05 22:01:45.760819+00
56	2025-07-06	9	95	2025-07-02 08:04:51.766573+00
\.


--
-- Data for Name: lead; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.lead (id, customer_name, mobile, followup_date, status, remarks, created_at, creator_id, modified_at, car_registration) FROM stdin;
7817	gaadimech 	8302779465	2025-07-08 18:30:00	Needs Followup	By mistake inquiry 	2025-07-02 05:19:31.234835	6	2025-07-02 05:19:31.234843	
6399	Cx1117	9784657775	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-21 05:00:52.722098	4	2025-05-31 08:43:19.077196	
515	Cx83	7503379315	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:21:51.113086	\N
6839	Cx1157	7737144248	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-02 07:07:45.478099	4	2025-05-31 08:43:19.077196	
7907	Cx4011	9887427059	2025-07-06 18:30:00	Did Not Pick Up	No answer 	2025-07-05 08:33:25.516385	4	2025-07-06 00:12:54.792041	
7897	Surakshit Soni	+919001436050	2025-07-06 08:03:59.937768	Needs Followup	Added from admin assignment. Service: Express Car Service. Source: Website. 	2025-07-05 08:03:59.941049	5	2025-07-05 08:03:59.94107	
7904	Cx4010	6375998976	2025-07-06 18:30:00	Needs Followup	Call cut 	2025-07-05 08:31:47.460509	4	2025-07-05 08:31:47.460517	
6840	Cx1159	7014840540	2025-07-20 10:00:00	Needs Followup	Alto Dent paint 	2025-05-02 07:08:25.879906	4	2025-05-31 08:43:19.077196	
7911	Cx4013	9983990422	2025-07-06 18:30:00	Needs Followup	Car service \r\nCall cut 	2025-07-05 08:36:19.09673	4	2025-07-05 08:36:19.096738	
7209	Amit meena	9001359003	2025-07-20 10:00:00	Needs Followup	Beat dent paint 	2025-05-15 11:12:48.600632	6	2025-05-31 08:43:19.077196	
3512	.	9828473938	2025-07-05 18:30:00	Needs Followup	Abhi kuch nahi 	2025-01-29 08:32:50.939274	4	2025-07-02 12:07:56.109234	
7914	Cx4014	9024600503	2025-07-06 18:30:00	Needs Followup	Call cut 	2025-07-05 08:37:53.010479	4	2025-07-05 08:37:53.010486	
7787	Alto 	9636777300	2025-07-05 18:30:00	Needs Followup	Alto service Jagatpura	2025-07-01 04:52:55.326365	4	2025-07-01 04:52:55.326372	
2733	Customer	6375552854	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-09 04:06:43.856234	4	2025-05-31 08:42:04.112745	
5315	Customer 	9828080500	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-30 11:08:36.274755	6	2025-05-31 08:42:22.030114	
3225	Customer 	9503841580	2025-07-02 10:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:04.112745	
2750	Bhupendra	7974346152	2025-07-03 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	6	2025-05-31 08:42:09.584832	\N
5316	Amit g	9828571315	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:09:07.72035	6	2025-05-31 08:42:09.584832	
5317	Customer 	9829065718	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:09:36.415576	6	2025-05-31 08:42:09.584832	
4763	Cx611	8209988694	2025-07-04 10:00:00	Needs Followup	Car service 	2025-03-16 09:20:08.731733	4	2025-05-31 08:42:14.037958	
7210	Sameer 	9166546922	2025-07-20 10:00:00	Needs Followup	Audi Q3\r\n14399	2025-05-15 11:13:35.488279	6	2025-05-31 08:43:19.077196	
3385	gaadimech 	8619272121	2025-07-04 10:00:00	Needs Followup	Wagnor 2199	2025-01-25 04:07:13.578442	6	2025-05-31 08:42:14.037958	
4762	Cx610	8504001096	2025-07-19 10:00:00	Needs Followup	Swift \r\nDrycleaning 	2025-03-16 09:17:50.929662	6	2025-05-31 08:43:14.897002	
3214	Arun	9829098450	2025-07-15 10:00:00	Needs Followup	Service done by other workshop \r\nCall cut	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:58.621937	
4761	Cx609	9928649906	2025-07-19 10:00:00	Needs Followup	Alto Dent paint 19000	2025-03-16 09:16:29.470578	6	2025-05-31 08:43:14.897002	
7211	Customer 	9414778844	2025-07-20 10:00:00	Needs Followup		2025-05-15 11:19:34.725243	6	2025-05-31 08:43:19.077196	
7220	Customer 	9772201687	2025-07-20 10:00:00	Needs Followup		2025-05-15 11:27:05.364028	6	2025-05-31 08:43:19.077196	
2739	Customer	9413941717	2025-07-24 18:30:00	Feedback	Busy call u letter\r\nSantro 1999 service done in sharp motors	2025-01-09 04:06:43.856234	6	2025-04-21 09:14:20.576891	
7861	Mohit 	8619772461	2025-09-03 18:30:00	Needs Followup	Scorpio 2014 model contact for service	2025-07-04 06:01:56.575821	9	2025-07-05 08:33:56.402984	RJ25UB1
4476	CX591	8000515155	2025-07-28 18:30:00	Did Not Pick Up	not incoming not valid	2025-03-02 11:51:05.976821	9	2025-07-05 09:39:55.959875	
7050	Ravi Chouhan	9887600400	2026-01-07 18:30:00	Needs Followup	I20 service follow up!!!!	2025-05-09 05:11:06.92192	9	2025-07-06 05:19:52.692033	RJ14NC3827
7906	Altoz 3199	9944274679	2025-07-06 18:30:00	Needs Followup	Car service \r\nNo answer 	2025-07-05 08:32:57.995213	4	2025-07-06 06:32:54.865207	
5321	Customer 	7014171747	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:12:24.421432	4	2025-05-31 08:42:14.037958	
6164	Honda City 	7014436161	2025-07-20 10:00:00	Needs Followup	Honda City 3399	2025-04-17 05:12:45.040842	4	2025-05-31 08:43:19.077196	
7864	Cx4006	8963059221	2025-07-05 18:30:00	Did Not Pick Up	No answer 	2025-07-04 06:20:02.381137	4	2025-07-04 06:20:02.381153	
7842	Cx4001	9057073504	2025-07-03 18:30:00	Needs Followup	Chittod se 	2025-07-03 08:50:05.608328	4	2025-07-04 07:29:55.355017	
7862	Cx4007	9166225439	2025-07-03 18:30:00	Needs Followup	Jodhpur se 	2025-07-04 06:08:33.126682	4	2025-07-05 12:54:41.164133	
7636	gaadimech 	7877338815	2025-07-04 18:30:00	Did Not Pick Up	Not have a car and dis connected	2025-05-31 07:12:36.443778	9	2025-07-06 09:41:15.047164	
3096	Cx191	9929312314	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-17 04:24:01.411996	9	2025-07-06 07:26:35.319419	\N
7905	Cx4011	9257409884	2025-07-04 18:30:00	Needs Followup	Iss no per call nahi 	2025-07-05 08:32:19.746179	4	2025-07-06 06:37:46.731807	
7863	gaadimech	9649907860	2025-07-30 18:30:00	Confirmed	Skoda Octavia tsi petrol 2 litr not picking twice 	2025-07-04 06:14:06.274715	9	2025-07-06 06:43:31.157029	
6173	Customer 	9828526888	2025-07-13 10:00:00	Needs Followup		2025-04-17 06:07:15.175938	6	2025-05-31 08:42:50.438237	
6165	Cx694	9314551747	2025-07-20 10:00:00	Needs Followup	Ac service 	2025-04-17 05:13:24.929908	4	2025-05-31 08:43:19.077196	
7834	gaadimech	6351170688	2025-07-02 18:30:00	Did Not Pick Up	Call cut	2025-07-02 12:06:34.437163	6	2025-07-02 12:06:34.437171	
6174	Customer 	7413999509	2025-07-13 10:00:00	Needs Followup		2025-04-17 06:07:41.964771	6	2025-05-31 08:42:50.438237	
5322	Customer 	9828081758	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:12:55.317038	4	2025-05-31 08:42:14.037958	
5323	Customer 	9828081758	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:12:57.516891	4	2025-05-31 08:42:14.037958	
6167	Cx996	9166378910	2025-07-20 10:00:00	Needs Followup	i10 car service 	2025-04-17 05:14:42.08399	4	2025-05-31 08:43:19.077196	
6168	Cx1000	9819886858	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-17 05:15:19.7529	4	2025-05-31 08:43:19.077196	
5324	Customer 	9828081758	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:12:58.444637	4	2025-05-31 08:42:14.037958	
7250	Ravi ji 	7903584441	2025-07-20 10:00:00	Needs Followup	Tigor 3699 service 	2025-05-16 05:21:10.280428	6	2025-05-31 08:43:19.077196	
5325	Avant g	9784446612	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:13:47.005495	4	2025-05-31 08:42:14.037958	
7224	Customer 	8058075330	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:29:43.111157	4	2025-05-31 08:43:27.624295	
7226	Customer 	9460893592	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:54:27.675632	4	2025-05-31 08:43:27.624295	
7227	Customer 	8118813388	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:56:46.644205	4	2025-05-31 08:43:27.624295	
7228	Customer 	9928900033	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:57:09.68494	4	2025-05-31 08:43:27.624295	
7230	Customer 	9694199995	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:58:01.851728	4	2025-05-31 08:43:27.624295	
7232	Customer 	9314027677	2025-07-22 10:00:00	Needs Followup	Hyundai I 10	2025-05-15 12:01:57.270179	4	2025-05-31 08:43:27.624295	
7234	Customer 	9314632176	2025-07-22 10:00:00	Needs Followup	Dent paint kia sonnet 	2025-05-15 12:03:24.535122	4	2025-05-31 08:43:27.624295	
7237	Customer 	9829056198	2025-07-22 10:00:00	Needs Followup	Honda jazz \r\nDent paint 	2025-05-15 12:14:02.278562	4	2025-05-31 08:43:27.624295	
5351	Manish g	9829063490	2025-07-23 10:00:00	Needs Followup	Not interested 	2025-03-30 11:30:45.480995	4	2025-05-31 08:43:31.574711	
7240	Customer 	9929474937	2025-07-22 10:00:00	Needs Followup	I10\r\nCreta 	2025-05-15 12:16:19.765426	4	2025-05-31 08:43:27.624295	
7241	Customer 	9351430756	2025-07-22 10:00:00	Needs Followup	Duster 3999	2025-05-15 12:16:50.587378	4	2025-05-31 08:43:27.624295	
7912	Caiz 	9636396961	2025-07-06 18:30:00	Needs Followup	Call cut	2025-07-05 08:36:59.035545	4	2025-07-05 08:36:59.035552	
7242	Customer 	9414051201	2025-07-22 10:00:00	Needs Followup	I 20	2025-05-15 12:17:35.690738	4	2025-05-31 08:43:27.624295	
7858	Innova 	9537395373	2025-07-05 18:30:00	Needs Followup	Innova car service 	2025-07-03 12:10:38.256284	4	2025-07-03 12:10:38.256292	
4764	Cx612	8209988694	2025-07-25 10:00:00	Needs Followup	Car service 	2025-03-16 10:05:21.135038	6	2025-05-31 08:43:39.880052	
5857	gaadimech 	8690933779	2025-07-27 10:00:00	Needs Followup	Not pick xuv 500	2025-04-12 08:35:46.243329	6	2025-05-31 08:43:47.842094	
5326	Customer 	7023446069	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:14:38.459024	4	2025-05-31 08:42:14.037958	
5327	Customer 	7023446069	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:14:39.637235	4	2025-05-31 08:42:14.037958	
5330	Customer 	9829019040	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:17:24.872488	4	2025-05-31 08:42:14.037958	
3673	.	9829100605	2025-07-05 10:00:00	Needs Followup	Calll cut	2025-02-04 08:21:25.650869	4	2025-05-31 08:42:17.990214	
6175	Customer 	9672322439	2025-07-13 10:00:00	Needs Followup		2025-04-17 06:08:12.319603	6	2025-05-31 08:42:50.438237	
6172	Cx1004	9828409040	2025-07-08 18:30:00	Needs Followup	i10 service 	2025-04-17 05:18:36.735683	4	2025-04-18 05:24:39.121062	
5856	gaadimech 	8078663720	2025-07-30 18:30:00	Did Not Pick Up	Gi10 dent paint 2200\r\nNot interested 	2025-04-12 08:28:40.595841	6	2025-04-29 10:33:05.1169	
4760	Cx608	7014152297	2025-07-05 10:00:00	Needs Followup	Dent paint \r\ni20	2025-03-16 09:15:12.718545	6	2025-05-31 08:42:17.990214	
5337	Customer 	9829517077	2025-07-06 10:00:00	Needs Followup		2025-03-30 11:22:16.807387	4	2025-05-31 08:42:22.030114	
5347	Customer 	7999534684	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-30 11:27:46.791185	4	2025-05-31 08:42:22.030114	
5336	Customer 	9351314667	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-30 11:21:48.506203	6	2025-05-31 08:42:22.030114	
5344	Customer 	9829011003	2025-07-06 10:00:00	Needs Followup	Not answered 	2025-03-30 11:26:13.828104	6	2025-05-31 08:42:22.030114	
5345	Customer 	9413342912	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-30 11:26:45.406526	6	2025-05-31 08:42:22.030114	
5352	Customer 	8769920560	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-03-30 11:31:12.558888	4	2025-05-31 08:42:26.111514	
5340	Customer 	7073519992	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-03-30 11:23:55.793441	6	2025-05-31 08:42:30.087566	
5354	Gaurav 	9314885666	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-03-30 11:32:48.961053	4	2025-05-31 08:42:34.144665	
6176	Customer 	8233925894	2025-07-13 10:00:00	Needs Followup		2025-04-17 06:08:41.083165	6	2025-05-31 08:42:50.438237	
6177	Customer 	7615967389	2025-07-13 10:00:00	Needs Followup		2025-04-17 06:09:04.199759	6	2025-05-31 08:42:50.438237	
5334	Dheraj g	8826646479	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-03-30 11:19:48.537664	4	2025-05-31 08:43:02.994951	
6169	Cx1001	9414228953	2025-07-18 10:00:00	Needs Followup	i20 service 2999\r\nCall cut	2025-04-17 05:16:13.622439	6	2025-05-31 08:43:10.854377	
6171	Shoda yati 	9929779698	2025-07-18 10:00:00	Needs Followup	5999 service 	2025-04-17 05:17:32.419381	6	2025-05-31 08:43:10.854377	
6923	Cx1170	9799995971	2025-07-20 10:00:00	Needs Followup	Swift 2999	2025-05-06 07:06:06.58495	6	2025-05-31 08:43:19.077196	
7243	Customer 	9829010198	2025-07-22 10:00:00	Needs Followup	Fortuner \r\nBaleno 	2025-05-15 12:18:37.171535	4	2025-05-31 08:43:27.624295	
7245	Customer 	9829079861	2025-07-22 10:00:00	Needs Followup	Xuv	2025-05-15 12:19:26.280305	4	2025-05-31 08:43:27.624295	
7246	Customer 	9829055354	2025-07-22 10:00:00	Needs Followup	Honda jazz 	2025-05-15 12:19:59.747979	4	2025-05-31 08:43:27.624295	
7265	gaadimech 	8619951961	2025-07-22 10:00:00	Needs Followup	Scorpio ac gas	2025-05-17 08:36:00.060562	4	2025-05-31 08:43:27.624295	
6983	gaadimech 	9351697797	2025-07-22 10:00:00	Needs Followup	Alto 2399	2025-05-08 05:00:31.901705	6	2025-05-31 08:43:27.624295	
7065	gaadimech 	9555170178	2025-07-22 10:00:00	Needs Followup	Eco sport 3699\r\nCall cut	2025-05-10 07:44:31.547244	6	2025-05-31 08:43:27.624295	
5365	gaadimech 	8112245016	2025-07-27 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-03-31 08:14:28.038658	6	2025-05-31 08:43:47.842094	
7193	gaadimech 	8619015198	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-05-15 04:42:07.637517	6	2025-05-31 08:43:27.624295	
7194	gaadimech 	9460838672	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-05-15 04:47:32.481208	6	2025-05-31 08:43:27.624295	
7820	gaadimech 	9414320530	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-07-02 06:46:57.522099	6	2025-07-02 06:46:57.522108	
5362	gaadimech 	9413200014	2025-07-24 10:00:00	Needs Followup	Pulse 3599 	2025-03-31 07:08:11.520681	4	2025-05-31 08:43:35.995616	
7202	gaadimech	9213772913	2025-07-22 10:00:00	Needs Followup	Swift 2799	2025-05-15 10:30:48.844194	6	2025-05-31 08:43:27.624295	
5859	Cx634	7014436161	2025-07-19 10:00:00	Needs Followup	Honda City 3399	2025-04-12 09:47:51.732966	6	2025-05-31 08:43:14.897002	
7205	gaadimech	9782993674	2025-07-22 10:00:00	Needs Followup	Nit pick	2025-05-15 10:34:29.975314	6	2025-05-31 08:43:27.624295	
7206	gaadimech	7014804714	2025-07-22 10:00:00	Needs Followup	Alto 2399	2025-05-15 10:39:27.961008	6	2025-05-31 08:43:27.624295	
5861	Cx635	9314551747	2025-07-25 10:00:00	Needs Followup	i20 \r\nAc service 	2025-04-12 09:49:00.461389	6	2025-05-31 08:43:39.880052	
2769	Customer	8386969313	2025-07-02 10:00:00	Needs Followup	Not interested 	2025-01-09 08:07:34.075518	4	2025-05-31 08:42:04.112745	
595	Gunjan Ramawat	9001094449	2025-07-04 10:00:00	Needs Followup	Pilot DL3CVW1198 inko mine 5499 ka pack diya tha ye banipark Aaye bhi the but inko ye pack me break oil mang rhe the alag se pise nhi dena chah rhe the\r\nNot pick	2024-11-30 09:37:30	6	2025-05-31 08:42:14.037958	
4775	Cx615	9557087462	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-16 10:57:08.13406	6	2025-05-31 08:42:22.030114	
4777	Cx622	7891486476	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-16 10:58:58.90206	6	2025-05-31 08:42:22.030114	
4779	Cx620	8824241389	2025-07-06 10:00:00	Needs Followup	Car service	2025-03-16 11:03:57.22599	6	2025-05-31 08:42:22.030114	
3518	.	7877939394	2025-07-03 18:30:00	Needs Followup	Call cut	2025-01-29 08:32:50.939274	4	2025-07-02 12:00:28.154653	
3680	.	8239518979	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-02-04 08:21:25.650869	6	2025-05-31 08:42:30.087566	
3678	.	9783152782	2025-07-09 10:00:00	Needs Followup	Honda city 2899 service done	2025-02-04 08:21:25.650869	4	2025-05-31 08:42:34.144665	
3559	.	8946862616	2025-07-11 18:30:00	Did Not Pick Up	Ritz 2499 service done other' workshop\r\nNot lick	2025-01-31 08:47:45.318294	6	2025-06-28 11:12:30.174192	
3679	.	9414782084	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	4	2025-05-31 08:42:58.621937	
5860	gaadimech 	9214577724	2025-07-30 18:30:00	Did Not Pick Up	Xuv 500\r\nNot interested 	2025-04-12 09:48:27.283913	6	2025-05-23 10:22:05.12894	
4791	Cx634	9930086206	2025-07-18 10:00:00	Needs Followup	Car service 	2025-03-16 11:29:40.22272	4	2025-05-31 08:43:10.854377	
4765	Cx612	8209988694	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-16 10:33:48.535384	6	2025-05-31 08:43:06.869056	
4766	Cx615	9929450006	2025-07-17 10:00:00	Needs Followup	Car service \r\nVerna 	2025-03-16 10:34:51.605632	6	2025-05-31 08:43:06.869056	
4767	Cx614	9929450006	2025-07-18 10:00:00	Needs Followup	Venu ac service 	2025-03-16 10:42:58.730138	4	2025-05-31 08:43:10.854377	
4769	Cx619	8114431804	2025-07-17 10:00:00	Needs Followup	Honda City \r\nAc service 	2025-03-16 10:46:33.590009	6	2025-05-31 08:43:06.869056	
4781	Cx928	9610710538	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-16 11:05:07.604472	6	2025-05-31 08:43:06.869056	
4788	Alto 2499	8949605526	2025-07-17 10:00:00	Needs Followup	Alto 2499\r\n	2025-03-16 11:12:07.749567	6	2025-05-31 08:43:06.869056	
4768	Cx619	9166899268	2025-07-18 10:00:00	Needs Followup	Car service ke liye	2025-03-16 10:45:54.2841	4	2025-05-31 08:43:10.854377	
4784	Cx630	7610010056	2025-07-18 10:00:00	Needs Followup	Verna full dent paint 24000	2025-03-16 11:07:02.157229	4	2025-05-31 08:43:10.854377	
4783	Cx629	7733807526	2025-07-19 10:00:00	Needs Followup	Car service 	2025-03-16 11:06:15.186896	6	2025-05-31 08:43:14.897002	
6987	Cx1172	9982451158	2025-07-20 10:00:00	Needs Followup	Honda City \r\nWrv service 	2025-05-08 05:30:56.036003	6	2025-05-31 08:43:19.077196	
7207	gaadimech 	9887888660	2025-07-22 10:00:00	Needs Followup	Swift 2799	2025-05-15 10:47:00.903536	6	2025-05-31 08:43:27.624295	
2830	Customer	9829430908	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-11 04:14:05.019885	4	2025-05-31 08:42:04.112745	
7233	Customer 	9351559444	2025-07-22 10:00:00	Needs Followup	Innova \r\nDent paint 	2025-05-15 12:02:46.071278	6	2025-05-31 08:43:27.624295	
4778	Cx629	9351148442	2025-07-06 18:30:00	Needs Followup	Call cut 	2025-03-16 11:01:14.581294	6	2025-07-06 09:19:11.916	
7869	Audi ac compressor 	9660864817	2025-07-06 18:30:00	Needs Followup	Audi ac compressor \r\nAjmer road 	2025-07-04 06:25:43.366846	4	2025-07-05 10:09:29.552333	
5368	gaadimech 	9660932756	2025-07-24 10:00:00	Needs Followup	Dzire ac check 999\r\nNot interested 	2025-03-31 12:22:59.582464	6	2025-05-31 08:43:35.995616	
3109	Customer	9511328186	2025-07-04 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-18 04:23:45.326649	6	2025-05-31 08:42:14.037958	
2831	Ravindra	9672653965	2025-07-07 10:00:00	Needs Followup	Service done swift Dzire 2899\r\nNot pick	2025-01-11 04:14:05.019885	6	2025-05-31 08:42:26.111514	
6986	Cx1171	8058449302	2025-07-25 10:00:00	Needs Followup	Caiz bumper paint 	2025-05-08 05:29:58.488791	6	2025-05-31 08:43:39.880052	
5367	gaadimech 	8949814747	2025-07-27 10:00:00	Needs Followup	Call cut \r\nNot interested 	2025-03-31 12:14:58.119222	6	2025-05-31 08:43:47.842094	
4665	gaadimech 	7240720846	2025-07-08 10:00:00	Needs Followup	Dzire 2699\r\nCall cut	2025-03-11 08:20:47.570418	4	2025-05-31 08:42:30.087566	
5864	gaadimech 	9929048050	2025-07-27 10:00:00	Needs Followup	Brezza 2200 panel charge \r\nNext month will plan	2025-04-12 09:50:44.378451	6	2025-05-31 08:43:47.842094	
5358	Cx584	9587173485	2025-07-17 10:00:00	Needs Followup	Bolero ac gas 2000	2025-03-31 06:33:18.940688	6	2025-05-31 08:43:06.869056	
7870	Cx4009	7737030433	2025-07-07 18:30:00	Needs Followup	Call cut 	2025-07-04 06:26:12.292487	4	2025-07-06 09:26:41.091226	
1306	Customer	9667781707	2025-08-09 18:30:00	Needs Followup	Dzire, jhotwara, washing not need right now	2024-12-07 05:46:09	9	2025-07-06 06:25:54.215813	\N
5868	somesh soni gaadimech 	9521890803	2025-07-09 18:30:00	Feedback	Not interested	2025-04-12 10:44:45.931071	9	2025-07-01 07:08:54.0207	RJ45CM6019
4805	gaadimech 	7733807526	2025-07-21 10:00:00	Needs Followup	Call back after 10 days	2025-03-17 09:38:14.192629	4	2025-05-31 08:43:23.449024	
7236	Customer 	9837081968	2025-07-22 10:00:00	Needs Followup	Maruti desire 	2025-05-15 12:05:16.302149	6	2025-05-31 08:43:27.624295	
7238	Customer 	9829157089	2025-07-22 10:00:00	Needs Followup	Verna \r\nCreta \r\nI10	2025-05-15 12:14:38.827021	6	2025-05-31 08:43:27.624295	
304	Ankit sir	9929095409	2025-07-04 10:00:00	Needs Followup	What's app details share \r\nOut of Jaipur \r\nNot required 	2024-11-26 09:29:28	4	2025-05-31 08:42:14.037958	
4802	gaadimech	8739929655	2025-07-05 10:00:00	Needs Followup	Tomorrow visit krenge normal check up ke liye honda city\r\nNot pick	2025-03-17 07:09:48.544817	6	2025-05-31 08:42:17.990214	
7244	Customer 	9314505735	2025-07-22 10:00:00	Needs Followup	Verna	2025-05-15 12:19:01.240127	6	2025-05-31 08:43:27.624295	
4797	Cx640	7665482229	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-17 04:34:04.276109	6	2025-05-31 08:42:22.030114	
7843	Paint 	8559932450	2025-07-04 18:30:00	Needs Followup	Car paint 	2025-07-03 09:48:47.135818	4	2025-07-03 09:48:47.135827	
7871	Cx4010	7737030433	2025-07-07 18:30:00	Needs Followup	Call cut	2025-07-04 06:26:53.656949	4	2025-07-06 09:25:23.350188	
4745	.	9829012828	2025-07-23 10:00:00	Needs Followup	Not requirement 	2025-03-13 11:55:21.030514	4	2025-05-31 08:43:31.574711	
7826	gaadimech 	9079623817	2025-07-02 18:30:00	Did Not Pick Up	Call cut	2025-07-02 07:10:55.250232	6	2025-07-02 07:10:55.250239	
4800	Cx644	8619017080	2025-07-06 10:00:00	Needs Followup	Alto service 	2025-03-17 04:35:57.614031	6	2025-05-31 08:42:22.030114	
6179	Customer 	9825332230	2025-07-07 10:00:00	Needs Followup		2025-04-17 07:56:10.50169	6	2025-05-31 08:42:26.111514	
434	.	9414054223	2025-07-07 10:00:00	Needs Followup	call cut\r\nNot pick 	2024-11-28 06:03:20	6	2025-05-31 08:42:26.111514	
4804	gaadimech	7568587837	2025-07-08 10:00:00	Needs Followup	Shadi me busy hai baad me bat krenge\r\nNot pick \r\n	2025-03-17 09:02:58.957893	4	2025-05-31 08:42:30.087566	
6178	Customer 	9829299956	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-17 07:55:41.489664	4	2025-05-31 08:42:54.38585	
387	Krishna Kumar	9810149016	2025-07-14 10:00:00	Needs Followup	What's app details share Zen estilo service package shared  \r\nNot requirement 	2024-11-27 07:21:40	6	2025-05-31 08:42:54.38585	
4801	Cx645	7221898170	2025-07-18 10:00:00	Needs Followup	General check up	2025-03-17 04:36:30.312821	4	2025-05-31 08:43:10.854377	
3688	.	9529599088	2025-07-25 18:30:00	Did Not Pick Up	Call cut	2025-02-04 08:21:25.650869	6	2025-07-02 12:28:57.053051	
7876	Verna 	7733960717	2025-07-06 18:30:00	Needs Followup	Verna 3399\r\nNo answer 	2025-07-04 06:33:04.260784	4	2025-07-06 08:44:26.695993	
7900	Baleno 	8003356223	2025-07-08 18:30:00	Open	Baleno washing \r\nFeedback call 	2025-07-05 08:28:56.236191	4	2025-07-06 10:34:37.258308	
4798	Cx642	9211679778	2025-07-19 10:00:00	Needs Followup	Triber dent paint 25000\r\n	2025-03-17 04:34:40.434108	6	2025-05-31 08:43:14.897002	
7827	gaadimech 	7976789694	2025-07-02 18:30:00	Did Not Pick Up	Switch off	2025-07-02 07:12:21.870506	6	2025-07-02 07:12:21.870513	
2523	.	9829485998	2025-07-24 18:30:00	Did Not Pick Up	Call not pick \r\nNot interested 	2024-12-24 12:00:21.095211	6	2025-07-01 07:41:58.85352	
4808	gaadimech	9887121411	2025-07-30 18:30:00	Did Not Pick Up	Not requirement by mistake click ho gaya\r\nNot required 	2025-03-17 11:37:28.795804	6	2025-04-25 08:56:07.776425	
884	...	9999999999	2025-07-17 18:30:00	Did Not Pick Up		2024-12-03 05:16:04	9	2025-07-06 09:04:27.206735	
7901	City	9660177167	2025-07-06 18:30:00	Needs Followup	Honda City 	2025-07-05 08:29:47.325387	4	2025-07-05 08:29:47.325394	
7821	gaadimech 	9783607544	2025-07-02 18:30:00	Needs Followup	Vento 999	2025-07-02 06:51:04.002293	6	2025-07-02 06:51:04.002301	
7247	Customer 	9829057778	2025-07-22 10:00:00	Needs Followup	Seltos \r\nSwift dizire 	2025-05-15 12:20:27.886319	6	2025-05-31 08:43:27.624295	
7251	gaadimech 	9414084729	2025-07-22 10:00:00	Needs Followup	Busy call u later \r\nScorpio 5199	2025-05-17 05:02:11.521562	6	2025-05-31 08:43:27.624295	
7260	gaadimech 	8209580787	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-05-17 05:52:36.885155	6	2025-05-31 08:43:27.624295	
7262	gaadimech 	6377039790	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-05-17 06:28:00.951052	6	2025-05-31 08:43:27.624295	
7264	gaadimech	7737552270	2025-07-22 10:00:00	Needs Followup	Not pick	2025-05-17 08:30:59.765053	6	2025-05-31 08:43:27.624295	
5384	Customer 	8432557870	2025-07-06 10:00:00	Needs Followup	Rapid 4199	2025-04-01 07:00:23.569544	6	2025-05-31 08:42:22.030114	
7267	gaadimech 	7525955501	2025-07-22 10:00:00	Needs Followup	Verna 3399	2025-05-17 10:53:29.66196	6	2025-05-31 08:43:27.624295	
7269	gaadimech 	9950755626	2025-07-22 10:00:00	Needs Followup	Switch off 	2025-05-17 10:54:21.831913	6	2025-05-31 08:43:27.624295	
7745	Paint 	9414781287	2025-07-05 18:30:00	Needs Followup	Baleno paint\r\nCall cut	2025-06-29 05:30:35.522196	4	2025-07-04 09:14:38.949681	
7806	gaadimech 	7715013382	2025-07-03 18:30:00	Did Not Pick Up	Call cut	2025-07-01 08:43:07.332515	6	2025-07-02 08:50:09.404764	
419	Cx77	7976332742	2025-07-25 18:30:00	Needs Followup	Not picking 	2024-11-27 11:01:48	9	2025-07-02 04:17:30.934089	\N
4799	Cx643	9425714325	2025-07-06 18:30:00	Needs Followup	Voice call \r\nCall cut 	2025-03-17 04:35:25.619725	6	2025-07-06 09:19:43.505279	
5380	Hitesh agarwal 	8302634012	2025-07-04 10:00:00	Needs Followup		2025-04-01 06:53:37.516006	4	2025-05-31 08:42:14.037958	
7270	gaadimech 	8209920153	2025-07-22 10:00:00	Needs Followup	Honda city 2000 panel charge	2025-05-17 11:27:58.234662	6	2025-05-31 08:43:27.624295	
7271	gaadimech 	8859955844	2025-07-22 10:00:00	Needs Followup	Switch off 	2025-05-17 11:28:37.201766	6	2025-05-31 08:43:27.624295	
5385	Customer 	8448052953	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:00:57.139346	4	2025-05-31 08:42:26.111514	
5386	Prashant Sharma 	7014561774	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:12:32.708658	4	2025-05-31 08:42:26.111514	
7272	gaadimech 	9314532655	2025-07-22 10:00:00	Needs Followup	Wagnor washing nd drycleaning 	2025-05-17 11:29:10.824127	6	2025-05-31 08:43:27.624295	
7353	gaadimech 	8273817932	2025-07-23 10:00:00	Needs Followup	3 bje tak Dzire 2999	2025-05-21 06:53:14.809641	4	2025-05-31 08:43:31.574711	
7359	gaadimech	9910090496	2025-07-23 10:00:00	Needs Followup	Wagnor 2599	2025-05-21 09:27:59.550462	4	2025-05-31 08:43:31.574711	
5387	Mm mathur 	9829030465	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:13:06.384933	4	2025-05-31 08:42:26.111514	
7362	gaadimech 	7742623305	2025-07-23 10:00:00	Needs Followup	Swift 2799 pickup	2025-05-21 09:53:20.660027	4	2025-05-31 08:43:31.574711	
5388	Customer 	8800188323	2025-07-07 10:00:00	Needs Followup		2025-04-01 07:14:02.396419	4	2025-05-31 08:42:26.111514	
7386	gaadimech 	9414168535	2025-07-23 10:00:00	Needs Followup	BREZZA sc 	2025-05-22 08:34:37.993976	6	2025-05-31 08:43:31.574711	
5375	Cx603	9571648226	2025-07-26 10:00:00	Needs Followup	Car service 	2025-04-01 06:06:41.65527	6	2025-05-31 08:43:43.903509	
5390	Customer 	8800188323	2025-07-07 10:00:00	Needs Followup		2025-04-01 07:15:07.629821	4	2025-05-31 08:42:26.111514	
5378	Customer 	9887144944	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 06:52:00.679015	6	2025-05-31 08:42:34.144665	
5379	Customer 	8619253487	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 06:52:55.655014	6	2025-05-31 08:42:34.144665	
7810	gaadimech	7742847605	2025-07-02 18:30:00	Needs Followup	Wagnor dent paint 	2025-07-02 04:36:03.094048	6	2025-07-02 04:36:03.094057	
5389	Customer 	7568625150	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 07:14:40.701668	6	2025-05-31 08:42:34.144665	
5393	Anurag 	7877889761	2025-07-09 10:00:00	Needs Followup		2025-04-01 07:17:08.878348	6	2025-05-31 08:42:34.144665	
5395	Customer 	8562007574	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 07:18:12.618261	6	2025-05-31 08:42:34.144665	
7898	Pavan Pratihast	919257011045	2025-07-05 18:30:00	Needs Followup	Service: Express Car Service. Source: None. Pavan Pratihast (+919257011045)\r\nCar ManufacturerMaruti\r\nCar Model: Ciaz\r\nCity: Jaipur\r\nFuel Type: Petrol/CNG\r\nPnD or Walkin: Self Walk-in\r\nService Type: Express Car Service\r\nServiceDate: Tomorrow\r\nTimeSlot: 12 PM - 3 PM\r\nWorkshop Chosen: Jagatpur	2025-07-05 08:27:17.742764	5	2025-07-05 08:28:53.325482	
7875	Verna 3399	7665533558	2025-07-05 18:30:00	Open	Verna 3399\r\nAjmer road 	2025-07-04 06:31:17.271142	4	2025-07-06 08:44:08.806305	
5396	Customer 	9982867065	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 07:18:50.638563	6	2025-05-31 08:42:34.144665	
5399	Customer 	9530375959	2025-07-09 10:00:00	Needs Followup		2025-04-01 07:20:35.733211	6	2025-05-31 08:42:34.144665	
5400	Customer 	9829494114	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 07:21:33.655784	6	2025-05-31 08:42:34.144665	
5401	Jai agarwal 	9351425647	2025-07-09 10:00:00	Needs Followup		2025-04-01 07:22:06.529828	6	2025-05-31 08:42:34.144665	
5402	Customer 	9829638933	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 07:25:09.930047	6	2025-05-31 08:42:34.144665	
5409	Cm Singh 	8949278016	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:03:39.77893	6	2025-05-31 08:42:34.144665	
5410	Customer 	9549877750	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:05:39.026841	6	2025-05-31 08:42:34.144665	
5411	Karishma 	7014883955	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:06:19.807461	6	2025-05-31 08:42:34.144665	
6975	Customer 	9828400003	2025-07-19 10:00:00	Needs Followup	Range rover \r\nDefender 	2025-05-07 12:11:28.654527	4	2025-05-31 08:43:14.897002	
4814	 gaadimech	9950836646	2025-07-21 10:00:00	Needs Followup	Swift Dzire 2699 sharp motors 	2025-03-18 04:33:16.276218	4	2025-05-31 08:43:23.449024	
4816	gaadimech	9351234872	2025-07-23 10:00:00	Needs Followup	Ac checkup 	2025-03-18 04:48:38.162385	4	2025-05-31 08:43:31.574711	
4819	gaadimech 	9950312959	2025-07-24 10:00:00	Needs Followup	Not interested by mistake ho gya boga	2025-03-18 07:17:04.55587	4	2025-05-31 08:43:35.995616	
5867	gaadimech 	6367827083	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-12 09:56:01.336884	6	2025-05-31 08:43:35.995616	
6227	Customer 	8058375578	2025-07-24 10:00:00	Needs Followup		2025-04-17 11:44:06.880682	6	2025-05-31 08:43:35.995616	
6279	gaadimech 	9785839457	2025-07-24 10:00:00	Needs Followup	Busy call u later 	2025-04-18 05:13:38.015554	6	2025-05-31 08:43:35.995616	
6400	gaadimech	7877064533	2025-07-24 10:00:00	Needs Followup	Creta 4199 	2025-04-21 05:17:12.864516	6	2025-05-31 08:43:35.995616	
3690	.	9549111554	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-02-04 08:21:25.650869	4	2025-05-31 08:42:58.621937	
7755	gaadimech	7568348159	2025-07-03 18:30:00	Did Not Pick Up	I10 ac checkup 	2025-06-29 10:41:15.836332	6	2025-07-02 10:16:32.777922	
6648	gaadimech 	9079238400	2025-07-24 10:00:00	Needs Followup	Eon 2299\r\nNot interested 	2025-04-25 09:45:09.951257	6	2025-05-31 08:43:35.995616	
5405	Customer 	7665652652	2025-07-06 18:30:00	Needs Followup		2025-04-01 08:41:00.736684	6	2025-07-06 10:15:44.194807	
7878	Cx4013	6375034998	2025-07-06 18:30:00	Needs Followup	Car service \r\nNo answer 	2025-07-04 07:05:00.616704	4	2025-07-06 07:14:02.377281	
2622	Ramanand	9461551152	2025-07-04 10:00:00	Needs Followup	Call cut\r\nCall cut\r\nNot pick\r\nNot interested 	2025-01-07 04:42:15.913695	6	2025-05-31 08:42:14.037958	
6772	gaadimech 	9414538126	2025-07-25 10:00:00	Needs Followup	Dzire dent paint 	2025-04-28 06:46:36.441628	4	2025-05-31 08:43:39.880052	
2632	Mahaveer	9929090757	2025-07-09 10:00:00	Needs Followup	Glanzza 2599 package share nd 40000 km par hogi service time due h\r\nNot pick	2025-01-07 04:42:15.913695	4	2025-05-31 08:42:34.144665	
5412	Customer 	8949278016	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:07:21.814324	6	2025-05-31 08:42:34.144665	
6777	gaadimech 	9784034139	2025-07-25 10:00:00	Needs Followup	Switch off \r\nNot pick	2025-04-28 09:27:20.190191	4	2025-05-31 08:43:39.880052	
7913	Alto vki 	9636396961	2025-07-04 18:30:00	Open	Alto vki 	2025-07-05 08:37:27.291641	4	2025-07-05 09:48:33.64256	
6782	gaadimech 	7849998507	2025-07-25 10:00:00	Needs Followup	Not pick \r\nDzire 2999	2025-04-29 05:15:51.767434	4	2025-05-31 08:43:39.880052	
7873	Cx4011	9929502597	2025-07-04 18:30:00	Did Not Pick Up	No answer 	2025-07-04 06:28:36.816511	4	2025-07-06 08:50:43.645771	
4811	gaadimech	9660212332	2025-07-27 10:00:00	Needs Followup	Ac cooling coil 3200 labour 2500 ac ges 1000\r\nBeawar se hai	2025-03-18 04:22:12.679653	4	2025-05-31 08:43:47.842094	
2634	Customer	9001892178	2025-07-19 10:00:00	Needs Followup	Not interested \r\nNot interested 	2025-01-07 04:42:15.913695	4	2025-05-31 08:43:14.897002	
4813	gaadimech	6350558151	2025-07-27 10:00:00	Needs Followup	Verna ac ges out of jaipur gaye h gaadi\r\nCall cut\r\n	2025-03-18 04:30:48.796715	4	2025-05-31 08:43:47.842094	
6982	gaadimech	9829453062	2025-09-29 18:30:00	Did Not Pick Up	Not interested 	2025-05-08 04:53:35.612225	6	2025-05-08 08:41:58.140833	
3393	.	9001993323	2025-07-01 18:30:00	Needs Followup	Chaksu se hu\r\nMotorcycle hai 	2025-01-25 04:07:13.578442	4	2025-07-02 13:34:13.161906	
7882	Raju Singh	7339987350	2025-08-08 18:30:00	Needs Followup		2025-07-04 08:31:24.465324	9	2025-07-04 08:31:24.465332	
7751	gaadimech	9785000616	2025-07-03 18:30:00	Did Not Pick Up	Wagnor 2599 	2025-06-29 10:26:33.191077	6	2025-07-02 10:18:35.237315	
7922	Test	9999988888	2025-07-06 18:30:00	Needs Followup		2025-07-06 07:43:21.014074	1	2025-07-06 10:14:30.242985	
7789	gaadimech	9414280868	2025-07-04 18:30:00	Did Not Pick Up	Nit pick\r\nAjmer	2025-07-01 04:56:04.336591	6	2025-07-02 09:16:03.796839	
6992	Customer 	8385876891	2025-07-20 10:00:00	Needs Followup		2025-05-08 11:10:45.327954	6	2025-05-31 08:43:19.077196	
6994	Customer 	8005887700	2025-07-20 10:00:00	Needs Followup	Grand I10 2699	2025-05-08 11:12:18.703547	6	2025-05-31 08:43:19.077196	
2585	Cx139	9251658942	2025-07-18 18:30:00	Did Not Pick Up	Linea \r\n2999\r\nService done \r\nCall cut	2025-01-06 11:15:01.167732	6	2025-06-28 11:14:06.017193	
562	Yogesh ji 	9828011000	2025-07-20 10:00:00	Needs Followup	Dzire ka pack send kiya h but abhi need nhi h\r\nCall cut	2024-11-29 07:12:53	6	2025-05-31 08:43:19.077196	
2796	Customer	7426941538	2025-07-02 10:00:00	Needs Followup	Ertiga drycleaning home service me karwa li hai 	2025-01-10 04:20:50.707156	4	2025-05-31 08:42:04.112745	
3241	customer 	9799942157	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:04.112745	
4821	.	7737757562	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-03-18 11:15:45.235281	4	2025-05-31 08:43:35.995616	
6783	gaadimech 	7042500000	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-29 05:20:51.327547	4	2025-05-31 08:43:39.880052	
4824	.	9829012464	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-03-18 11:20:09.800907	6	2025-05-31 08:42:17.990214	
4825	.	9829012464	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-03-18 11:22:37.975309	6	2025-05-31 08:42:17.990214	
6791	gaadimech	9887231226	2025-07-25 10:00:00	Needs Followup	I10  2299\r\nCar sale karenge \r\n	2025-04-29 08:52:35.643352	4	2025-05-31 08:43:39.880052	
4826	.	9829061116	2025-07-05 10:00:00	Needs Followup	Call cut	2025-03-18 11:23:05.581354	6	2025-05-31 08:42:17.990214	
4827	.	9829061116	2025-07-05 10:00:00	Needs Followup	Call cut	2025-03-18 11:25:15.847136	6	2025-05-31 08:42:17.990214	
4834	.	9983978899	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-18 11:49:46.841943	4	2025-05-31 08:42:22.030114	
582	.	7976046471	2025-07-07 10:00:00	Needs Followup	Baleno 2499\r\nCall cut	2024-11-30 07:06:42	6	2025-05-31 08:42:26.111514	
6794	gaadimech 	8955759881	2025-07-25 10:00:00	Needs Followup	Punch dent paint 2000	2025-04-29 10:08:16.997652	4	2025-05-31 08:43:39.880052	
4837	gaadimech 	9694444977	2025-07-08 10:00:00	Needs Followup	Quanto 4999 \r\nDent paint 2300\r\n\r\n\r\nNot pick \r\n	2025-03-18 11:54:11.410534	4	2025-05-31 08:42:30.087566	
6800	gaadimech 	7737711311	2025-07-25 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-30 05:09:37.379749	4	2025-05-31 08:43:39.880052	
2808	Cx164	8619640884	2025-07-04 18:30:00	Did Not Pick Up	i20 car service \r\nDone 	2025-01-10 04:20:50.707156	6	2025-06-01 10:35:54.936084	
4820	gaadimech 	9314007003	2025-07-25 18:30:00	Did Not Pick Up	Call cut \r\nMagnite 3399	2025-03-18 10:33:49.235526	6	2025-06-28 10:47:28.772352	
7872	Aura 	9256789773	2025-07-06 18:30:00	Needs Followup	Aura \r\nVoice call \r\nIncoming nahi hai 	2025-07-04 06:27:28.902265	4	2025-07-06 08:56:04.281974	
7880	gaadimech	9352563091	2025-07-07 18:30:00	Needs Followup	Innova	2025-07-04 08:29:02.724098	9	2025-07-04 08:29:02.724107	
6801	gaadimech 	9414497626	2025-07-25 10:00:00	Needs Followup	Spark 2599	2025-04-30 05:12:28.19392	4	2025-05-31 08:43:39.880052	
4833	.	9414111700	2025-07-27 10:00:00	Needs Followup	Switch off \r\nNot pick 	2025-03-18 11:35:31.148336	4	2025-05-31 08:43:47.842094	
3239	customer 	8947816090	2025-07-09 10:00:00	Needs Followup	Not pics\r\nNot pick \r\nNot interested service done bye other workshop 	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:34.144665	\N
3396	.	9660686868	2025-07-03 18:30:00	Needs Followup	Call cut 	2025-01-25 04:07:13.578442	4	2025-07-02 13:37:15.681675	
4840	.	9875019786	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-03-18 11:58:40.561215	4	2025-05-31 08:42:54.38585	
2527	Cx124	9229170427	2026-01-29 18:30:00	Needs Followup	From Bihar 	2024-12-30 11:05:48.996851	9	2025-07-04 06:30:47.029597	\N
2844	Customer	8619288514	2025-07-15 10:00:00	Needs Followup	I10 car accessories \r\nNot requirement 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:58.621937	
4822	.	9414251346	2025-07-16 10:00:00	Needs Followup	Not pick 	2025-03-18 11:16:38.011675	4	2025-05-31 08:43:02.994951	
3240	.	8949485623	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:58.621937	
4832	.	9829259909	2025-07-18 10:00:00	Needs Followup	Not pick 	2025-03-18 11:34:29.315297	4	2025-05-31 08:43:10.854377	
4829	.	8963003037	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-03-18 11:27:20.81945	4	2025-05-31 08:43:02.994951	
4835	.	9983978899	2025-07-16 10:00:00	Needs Followup	Not pick 	2025-03-18 11:50:19.812936	4	2025-05-31 08:43:02.994951	
4842	.	9829950500	2025-08-22 18:30:00	Did Not Pick Up	Honda city 3399	2025-03-18 12:04:51.309128	6	2025-05-09 09:59:07.524608	
4838	.	9828018899	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-03-18 11:55:28.712503	4	2025-05-31 08:43:02.994951	
4843	.	9664312727	2025-07-18 10:00:00	Needs Followup	Not requirement 	2025-03-18 12:14:04.718412	4	2025-05-31 08:43:10.854377	
7881	Disha Mathur	8209253413	2025-11-05 18:30:00	Needs Followup	breea petrol	2025-07-04 08:30:40.115108	9	2025-07-04 08:30:40.115115	
7883	Ankit Mishra	9928081533	2025-07-06 18:30:00	Needs Followup	Interested	2025-07-04 08:34:28.259545	9	2025-07-04 08:34:28.259559	
5428	Lalit g	8700875021	2025-07-05 18:30:00	Needs Followup	Call cut 	2025-04-01 09:20:08.634643	4	2025-07-04 13:27:35.204594	
5427	Magan singh g 	9784001166	2025-07-05 18:30:00	Needs Followup	Call cut 	2025-04-01 09:19:31.494288	4	2025-07-04 13:29:14.372663	
7000	Customer 	9664113360	2025-07-20 10:00:00	Needs Followup		2025-05-08 11:18:59.541961	6	2025-05-31 08:43:19.077196	
4844	.	8168536017	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-03-18 12:29:32.508477	4	2025-05-31 08:43:23.449024	
3243	customer 	9950116999	2025-07-24 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-20 04:31:19.397625	4	2025-05-31 08:43:35.995616	
5425	Customer 	9601438200	2025-07-03 10:00:00	Needs Followup	Interested asked to call back on 2nd April 	2025-04-01 09:15:56.284371	6	2025-05-31 08:42:09.584832	
6802	gaadimech 	9549192943	2025-07-25 10:00:00	Needs Followup	Call cut	2025-04-30 05:37:39.702691	4	2025-05-31 08:43:39.880052	
5423	Naveen g 	9314203978	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:12:35.524398	6	2025-05-31 08:42:34.144665	
6998	Customer 	9782090928	2025-07-19 10:00:00	Needs Followup		2025-05-08 11:18:03.204365	4	2025-05-31 08:43:14.897002	
5432	Customer 	9633817052	2025-07-06 10:00:00	Needs Followup		2025-04-01 09:22:16.155493	6	2025-05-31 08:42:22.030114	
7192	Customer 	8949334329	2025-07-25 10:00:00	Needs Followup		2025-05-14 12:16:44.279546	4	2025-05-31 08:43:39.880052	
6997	Customer 	9001111888	2025-07-28 10:00:00	Needs Followup		2025-05-08 11:17:28.636682	4	2025-05-31 08:43:51.744985	
5433	Customer 	8949601780	2025-07-06 10:00:00	Needs Followup		2025-04-01 09:22:43.145134	6	2025-05-31 08:42:22.030114	
5434	Customer 	7976630308	2025-07-06 10:00:00	Needs Followup		2025-04-01 09:23:05.418447	6	2025-05-31 08:42:22.030114	
5429	Nitin g	9166774114	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 09:20:44.583663	4	2025-05-31 08:42:26.111514	
3245	.	8006829000	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	6	2025-05-31 08:42:30.087566	
5424	Customer 	7073266606	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:13:04.509687	6	2025-05-31 08:42:34.144665	
5426	Sunil choudhary 	9829015239	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:16:35.329623	6	2025-05-31 08:42:34.144665	
4845	.	9352868731	2025-07-16 10:00:00	Needs Followup	Not pick \r\nDon't have car	2025-03-18 12:31:34.719553	4	2025-05-31 08:43:02.994951	
6999	Customer 	9667186218	2025-07-19 10:00:00	Needs Followup		2025-05-08 11:18:36.951634	4	2025-05-31 08:43:14.897002	
5431	Honda Jazz 	8800880088	2025-07-17 10:00:00	Needs Followup	Honda jazz 3199\r\nNo answer \r\nSwitch off 	2025-04-01 09:21:24.045179	6	2025-05-31 08:43:06.869056	
7925	Indica	9887925705	2025-07-06 18:30:00	Needs Followup	Indica ac vki 	2025-07-06 09:15:10.13309	4	2025-07-06 09:15:10.133098	
6995	Customer 	9166546922	2025-07-19 10:00:00	Needs Followup		2025-05-08 11:12:43.065343	6	2025-05-31 08:43:14.897002	
7841	Brio 2599	9983714200	2025-07-02 18:30:00	Open	Brio service \r\n2599	2025-07-03 08:33:05.607776	4	2025-07-03 08:33:05.607783	
2658	Customer	7014846664	2025-09-26 18:30:00	Did Not Pick Up	Busy call u letter\r\nNot interested 	2025-01-08 04:05:57.844174	6	2025-02-26 10:16:44.186844	
2671	Customer	6350585226	2025-07-25 18:30:00	Did Not Pick Up	Wagnor 2299 package share \r\nService done by company workshop 	2025-01-08 04:05:57.844174	6	2025-02-15 04:21:05.525427	
7926	Indica	9887925705	2025-07-06 18:30:00	Needs Followup	Indica ac vki 	2025-07-06 09:15:17.867106	4	2025-07-06 09:15:17.867114	
2618	Himanshu 	7737178478	2025-08-29 18:30:00	Did Not Pick Up	Not pick\r\nService done bye other workshop 	2025-01-07 04:42:15.913695	6	2025-05-16 11:34:26.099324	
6183	Customer 	7014162795	2025-07-20 10:00:00	Needs Followup		2025-04-17 08:00:07.071379	4	2025-05-31 08:43:19.077196	
7807	gaadimech	9414320530	2025-07-03 18:30:00	Did Not Pick Up	Call cut	2025-07-01 08:45:15.966571	6	2025-07-02 08:42:38.302205	
5443	Cx001	9928342011	2025-07-03 10:00:00	Needs Followup	Switch off	2025-04-01 09:33:08.834293	6	2025-05-31 08:42:09.584832	
4852	.	9136996224	2025-07-06 10:00:00	Needs Followup	Kwid 2199 self call krenge	2025-03-19 05:12:34.802543	4	2025-05-31 08:42:22.030114	
5435	Customer 	9509008975	2025-07-06 10:00:00	Needs Followup		2025-04-01 09:23:33.971121	6	2025-05-31 08:42:22.030114	
6182	Customer 	8739896969	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-17 07:59:13.965156	6	2025-05-31 08:42:26.111514	
6189	Customer 	9784342114	2025-07-07 10:00:00	Needs Followup		2025-04-17 08:10:31.997428	6	2025-05-31 08:42:26.111514	
2548	Rishi sharma	7014342954	2025-07-26 10:00:00	Needs Followup	Hyundai elantra, 3299 pack shared, followup after Aug-25	2024-12-31 06:23:43.015407	6	2025-05-31 08:43:43.903509	\N
5858	gaadimech	9782735070	2025-07-21 10:00:00	Needs Followup	Alto K10 2399	2025-04-12 08:40:17.892799	6	2025-05-31 08:43:23.449024	
5870	gaadimech 	9166378910	2025-07-21 10:00:00	Needs Followup	Call cut	2025-04-13 05:28:50.972569	6	2025-05-31 08:43:23.449024	
6199	gaadimech 	9929095709	2025-07-21 10:00:00	Needs Followup	Dent paint alto 1900	2025-04-17 08:39:14.053334	6	2025-05-31 08:43:23.449024	
6185	Customer 	9859541772	2025-07-08 10:00:00	Needs Followup		2025-04-17 08:01:24.641778	6	2025-05-31 08:42:30.087566	
6202	gaadimech 	9887144975	2025-07-22 10:00:00	Needs Followup	I10 2299	2025-04-17 08:40:53.02438	4	2025-05-31 08:43:27.624295	
7001	Customer 	9784072708	2025-07-22 10:00:00	Needs Followup		2025-05-08 11:19:34.195624	6	2025-05-31 08:43:27.624295	
6201	gaadimech 	7790827629	2025-07-24 10:00:00	Needs Followup	Santro dent paint 1900	2025-04-17 08:40:23.336314	6	2025-05-31 08:43:35.995616	
6206	gaadimech	7014479889	2025-07-24 10:00:00	Needs Followup	Baleno engine light 	2025-04-17 09:46:17.717694	6	2025-05-31 08:43:35.995616	
4847	gaadimech	9571129075	2025-07-27 10:00:00	Needs Followup	Polo ac check \r\nNot interested 	2025-03-19 04:32:10.748206	4	2025-05-31 08:43:47.842094	
5436	Krishna 	9950082772	2025-07-09 10:00:00	Needs Followup	Baleno	2025-04-01 09:24:12.600865	6	2025-05-31 08:42:34.144665	
6796	Cx1153	9694980205	2025-07-25 10:00:00	Needs Followup	Dent paint 	2025-04-29 10:17:39.664847	6	2025-05-31 08:43:39.880052	
6186	Customer 	9928373636	2025-07-08 10:00:00	Needs Followup		2025-04-17 08:07:43.455874	6	2025-05-31 08:42:30.087566	
6842	Cx1161	9829755468	2025-07-25 10:00:00	Needs Followup	Honda Amaze dent paint 	2025-05-02 07:44:49.416803	6	2025-05-31 08:43:39.880052	
6191	Customer 	9462338411	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-04-17 08:12:01.440843	6	2025-05-31 08:42:30.087566	
7466	Nexon 3199	7742441155	2025-07-25 10:00:00	Needs Followup	Nexon service 3199\r\nCall cut 	2025-05-24 09:49:46.105625	6	2025-05-31 08:43:39.880052	
7503	Drycleaning nexon 	9929012257	2025-07-25 10:00:00	Needs Followup	Drycleaning \r\n1500	2025-05-26 11:20:36.95139	6	2025-05-31 08:43:39.880052	
5437	Customer 	9829013587	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:24:36.581012	6	2025-05-31 08:42:34.144665	
4770	Cx615	8058119097	2025-07-25 10:00:00	Needs Followup	Ac service 	2025-03-16 10:47:08.223763	6	2025-05-31 08:43:39.880052	
5442	Tata nexon  3699	8619454007	2025-07-26 10:00:00	Needs Followup	Tata nexon 	2025-04-01 09:26:27.712299	6	2025-05-31 08:43:43.903509	
5438	Customer 	9829013587	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:24:37.750065	6	2025-05-31 08:42:34.144665	
4848	gaadimech	9782897707	2025-07-27 10:00:00	Needs Followup	Not interested 	2025-03-19 04:36:25.700809	4	2025-05-31 08:43:47.842094	
5440	Customer 	9829013587	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:25:02.745742	6	2025-05-31 08:42:34.144665	
6188	Customer 	9610000092	2025-07-13 10:00:00	Needs Followup		2025-04-17 08:09:16.338067	6	2025-05-31 08:42:50.438237	
7673	gaadimech	8905345539	2025-07-28 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 08:45:46.917354	9	2025-07-03 09:51:11.286024	
2208	Pawan Rana	8949527632	2025-08-06 18:30:00	Did Not Pick Up	cus ne abhi car nahi li hai\r\nCall cut	2024-12-20 04:42:01.100851	6	2025-06-01 11:02:00.934485	
2547	Nitin ji	9829350475	2025-09-18 00:00:00	Needs Followup	cus from udaipur	2024-12-31 06:23:43.015407	5	2024-12-31 06:23:43.015407	\N
6193	Customer 	9530171720	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-17 08:13:13.956203	6	2025-05-31 08:42:50.438237	
6192	Customer 	9928469066	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-17 08:12:37.82469	4	2025-05-31 08:42:54.38585	
6207	Customer 	9351332567	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-17 10:43:17.991269	6	2025-05-31 08:42:54.38585	
3695	.	9829097679	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	4	2025-05-31 08:42:58.621937	
5439	Safari 	9929949452	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-01 09:24:38.685069	6	2025-05-31 08:43:10.854377	
7831	gaadimech 	9829252812	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-07-02 07:25:27.348276	6	2025-07-02 07:25:27.348284	
6187	Customer 	9829066501	2025-07-19 10:00:00	Needs Followup	Audi 13999	2025-04-17 08:08:37.637089	6	2025-05-31 08:43:14.897002	
5441	Cx602	7790932044	2025-07-19 10:00:00	Needs Followup	Car service 	2025-04-01 09:25:42.646871	6	2025-05-31 08:43:14.897002	
4849	gaadimech	8302329935	2025-09-29 18:30:00	Did Not Pick Up	120 service done by other workshop 	2025-03-19 04:38:33.295945	6	2025-05-16 07:06:13.686015	
7917	Vinod Ji	8758707815	2025-07-07 18:30:00	Feedback	Swift dzire service done feedback call	2025-07-05 09:14:20.748532	9	2025-07-05 09:14:20.74854	RJ45CE5321
6184	Customer 	9511572341	2025-07-16 10:00:00	Needs Followup		2025-04-17 08:00:58.123934	4	2025-05-31 08:43:02.994951	
4493	Cx904	7014849541	2025-07-17 10:00:00	Needs Followup	Etios. Service 2999\r\n\r\n	2025-03-03 06:25:27.018611	4	2025-05-31 08:43:06.869056	
307	Sushil sir	9829687639	2025-07-30 18:30:00	Needs Followup	What's app details share \r\nCall cut	2024-11-26 10:43:20	6	2025-07-01 11:38:08.897121	
7004	Customer 	9166546922	2025-07-22 10:00:00	Needs Followup		2025-05-08 11:39:55.736636	4	2025-05-31 08:43:27.624295	
3401	Cx226	8559826303	2025-07-04 10:00:00	Needs Followup	Kwid 	2025-01-25 04:07:13.578442	6	2025-05-31 08:42:14.037958	
4856	gaadimech 	9314909897	2025-07-06 10:00:00	Needs Followup	Honda city 2899\r\nNot pick 	2025-03-19 05:48:15.345517	4	2025-05-31 08:42:22.030114	
6211	Customer 	8875020003	2025-07-07 10:00:00	Needs Followup		2025-04-17 10:46:12.819786	6	2025-05-31 08:42:26.111514	
6208	Customer 	8233440011	2025-07-09 10:00:00	Needs Followup		2025-04-17 10:43:48.589015	4	2025-05-31 08:42:34.144665	Not interested 
6213	Customer 	6376455067	2025-07-13 10:00:00	Needs Followup		2025-04-17 10:47:08.424905	6	2025-05-31 08:42:50.438237	
6218	Customer 	8209021240	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-17 10:51:02.891792	6	2025-05-31 08:42:54.38585	
2814	Customer	7733825177	2025-07-15 10:00:00	Needs Followup	Kia terrance dant paint\r\nCar gujrat hai jaipur aane par contact karenge	2025-01-11 04:14:05.019885	4	2025-05-31 08:42:58.621937	
2851	Customer	9928021807	2025-07-15 10:00:00	Needs Followup	Wagnor 2299\r\nPackage share\r\nNot requirement 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:58.621937	
6212	Customer 	9829056919	2025-07-19 10:00:00	Needs Followup		2025-04-17 10:46:42.337533	6	2025-05-31 08:43:14.897002	
6215	Customer 	9314071092	2025-07-23 10:00:00	Needs Followup		2025-04-17 10:49:30.247775	4	2025-05-31 08:43:31.574711	
7003	Customer 	9314301982	2025-07-23 10:00:00	Needs Followup		2025-05-08 11:39:26.903288	6	2025-05-31 08:43:31.574711	
6989	Cx1174	8852867787	2025-07-25 10:00:00	Needs Followup	Nishan magnet	2025-05-08 06:43:39.443603	6	2025-05-31 08:43:39.880052	
6991	Cx1179	6377301700	2025-07-25 10:00:00	Needs Followup	Dent paint 	2025-05-08 06:47:12.013652	6	2025-05-31 08:43:39.880052	
5444	Brezza 	9680147149	2025-07-17 10:00:00	Needs Followup	Brezza (3399)\r\nService 	2025-04-01 10:00:33.768506	6	2025-05-31 08:43:06.869056	
7141	Cx2006	8882125658	2025-07-26 10:00:00	Needs Followup	Wr service 2599	2025-05-13 06:58:11.955098	4	2025-05-31 08:43:43.903509	
6214	Customer 	7014979519	2025-07-26 10:00:00	Needs Followup		2025-04-17 10:49:02.117147	6	2025-05-31 08:43:43.903509	
6219	Customer 	7014321965	2025-07-26 10:00:00	Needs Followup		2025-04-17 10:51:29.755427	6	2025-05-31 08:43:43.903509	
5877	gaadimech 	9785238057	2025-07-27 10:00:00	Needs Followup	Venue 3199\r\nNot interested 	2025-04-13 06:47:21.840142	6	2025-05-31 08:43:47.842094	
2598	Cx148	8851879828	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-06 11:15:01.167732	9	2025-07-06 07:41:38.81091	\N
7761	Cx3091	7014678350	2025-07-05 18:30:00	Needs Followup	Dent paint \r\nCall cut 	2025-06-30 04:46:24.371507	4	2025-07-04 09:02:07.443699	
5875	gaadimech 	9414266319	2025-07-30 18:30:00	Did Not Pick Up	Wagnor 2399\r\nNot interested 	2025-04-13 06:41:30.732548	6	2025-04-16 06:03:23.33484	
2250	.	9829215250	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:25:31.626564	
7844	Cx4003	9444819370	2025-07-04 18:30:00	Needs Followup	Car paint 	2025-07-03 09:51:21.621232	4	2025-07-03 09:51:21.62124	
6203	gaadimech 	9887818739	2025-07-11 18:30:00	Did Not Pick Up	Call not pick \r\nNot interested 	2025-04-17 08:41:31.585592	6	2025-06-28 07:27:01.133362	
7845	Service 	7691004890	2025-07-04 18:30:00	Needs Followup	Call cut	2025-07-03 09:52:04.340417	4	2025-07-03 09:52:04.340424	
7811	gaadimech 	8385967777	2025-07-02 18:30:00	Needs Followup	Dzire 2999 voice mail	2025-07-02 04:59:26.999829	6	2025-07-02 04:59:26.999836	
7814	i10	8005696147	2025-07-04 18:30:00	Needs Followup	i10 car service 	2025-07-02 05:14:03.828949	4	2025-07-02 05:14:03.828957	
6221	Customer 	9494008541	2025-07-09 10:00:00	Needs Followup		2025-04-17 11:29:10.642752	4	2025-05-31 08:42:34.144665	
6224	Customer 	8239271231	2025-07-09 10:00:00	Needs Followup		2025-04-17 11:31:35.392131	4	2025-05-31 08:42:34.144665	
6225	Customer 	9351719028	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:41:34.406564	4	2025-05-31 08:42:54.38585	
6228	Customer 	8058375578	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:44:44.415458	4	2025-05-31 08:42:54.38585	
2714	Iqbal.  9660289087	9351206804	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-01-08 11:00:12.657946	4	2025-05-31 08:42:58.621937	
5453	gaadimech 	9024607839	2025-07-18 10:00:00	Needs Followup	Bussy call cut \r\nNot interested 	2025-04-02 05:55:10.884352	4	2025-05-31 08:43:10.854377	
6226	Customer 	9352383073	2025-07-19 10:00:00	Needs Followup	Not interested 	2025-04-17 11:43:20.951012	6	2025-05-31 08:43:14.897002	
6230	Customer 	9351789409	2025-07-20 10:00:00	Needs Followup	Not interested 	2025-04-17 11:45:37.71644	4	2025-05-31 08:43:19.077196	
7005	Customer 	9950158355	2025-07-22 10:00:00	Needs Followup		2025-05-08 11:40:15.614138	6	2025-05-31 08:43:27.624295	
7007	Customer 	9783023939	2025-07-22 10:00:00	Needs Followup		2025-05-08 11:40:58.683919	6	2025-05-31 08:43:27.624295	
7006	Customer 	9829061076	2025-07-23 10:00:00	Needs Followup		2025-05-08 11:40:34.9125	6	2025-05-31 08:43:31.574711	
5447	gaadimech 	9414392799	2025-07-24 10:00:00	Needs Followup	Honda city 3199	2025-04-02 05:05:15.460754	6	2025-05-31 08:43:35.995616	
5448	gaadimech 	9127397035	2025-07-24 10:00:00	Needs Followup	Dzire 2999 rk\r\n	2025-04-02 05:08:09.110779	6	2025-05-31 08:43:35.995616	
4859	gaadimech 	7851803524	2025-07-27 10:00:00	Needs Followup	Terreno compressor 17000\r\nPrice jyada hai \r\n	2025-03-19 06:56:58.289403	4	2025-05-31 08:43:47.842094	
5449	gaadimech 	6375034998	2025-07-24 10:00:00	Needs Followup	Alto 800 2299 rk	2025-04-02 05:14:36.639249	6	2025-05-31 08:43:35.995616	
5878	gaadimech 	9414810480	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-13 07:34:16.235759	6	2025-05-31 08:43:35.995616	
5445	gaadimech 	8824199335	2025-07-27 10:00:00	Needs Followup	Not pick	2025-04-02 04:40:32.829646	6	2025-05-31 08:43:47.842094	
5450	gaadiemch 	6377433565	2025-07-27 10:00:00	Needs Followup	Not pick\r\nCall cut 	2025-04-02 05:18:31.357732	6	2025-05-31 08:43:47.842094	
6222	Customer 	9799384508	2025-07-27 10:00:00	Needs Followup		2025-04-17 11:30:04.16407	6	2025-05-31 08:43:47.842094	
6223	Customer 	8949204191	2025-07-27 10:00:00	Needs Followup		2025-04-17 11:30:41.103522	6	2025-05-31 08:43:47.842094	
7808	gaadimech 	9887417979	2025-07-05 18:30:00	Needs Followup	Amaze 3199	2025-07-01 08:54:22.231938	6	2025-07-02 04:32:12.696647	
7828	gaadimech 	9660330949	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-07-02 07:14:49.654822	6	2025-07-02 07:14:49.654831	
5465	Kanta	9892326725	2025-07-07 18:30:00	Needs Followup	Car service 	2025-04-02 07:29:03.364039	4	2025-07-04 12:02:10.638689	
5457	Hemant 	9899046161	2025-07-10 18:30:00	Needs Followup	Abhi nahi karwani 	2025-04-02 07:24:06.833756	4	2025-07-04 12:05:56.361478	
7915	Unknown	919944274679	2025-07-06 08:46:06.806148	Needs Followup	Service: None. Source: None. 710\r\nFriday, July 4, 2025 at 9:19 PM\r\n9944274679\r\n-\t-\t\r\nTata\r\nAltroz\r\npetrol\r\n3,199	2025-07-05 08:46:06.809177	5	2025-07-05 08:46:06.809206	
7866	Ac gas	8561957702	2025-07-05 18:30:00	Needs Followup	Ac gas 	2025-07-04 06:23:38.249251	4	2025-07-05 12:40:17.678067	
3017	Customer	9782967521	2025-07-25 18:30:00	Needs Followup	Not interested 	2025-01-13 09:02:24.989067	6	2025-07-01 07:27:41.533071	
3865	.	8692973000	2025-07-21 10:00:00	Needs Followup	Don't have car verna sale kr di mene\r\nCall cut	2025-02-07 09:03:50.545995	4	2025-05-31 08:43:23.449024	
7008	Customer 	9829012634	2025-07-22 10:00:00	Needs Followup		2025-05-08 11:57:18.286054	4	2025-05-31 08:43:27.624295	
776	.	9214690051	2025-07-02 10:00:00	Needs Followup	Not interested & cut a call	2024-12-02 04:50:36	4	2025-05-31 08:42:04.112745	
5466	Mahendra Singh 	9892057431	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-02 07:29:46.165606	4	2025-05-31 08:43:02.994951	
7009	Customer 	9828307862	2025-07-23 10:00:00	Needs Followup		2025-05-08 11:58:28.225646	4	2025-05-31 08:43:31.574711	
7301	Cx2028	9694905620	2025-07-26 10:00:00	Needs Followup	No answer 	2025-05-19 05:34:28.153002	4	2025-05-31 08:43:43.903509	
2564	Cx136	7976073345	2025-07-18 18:30:00	Did Not Pick Up	Swift \r\nService \r\nService done \r\nNot pick 	2025-01-02 12:06:04.008231	6	2025-06-28 11:14:57.68597	
7304	Duster 	8209744796	2025-07-26 10:00:00	Needs Followup	Duster 4899	2025-05-19 06:32:28.831418	4	2025-05-31 08:43:43.903509	
7308	Cx2027	8619599021	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-19 09:05:09.649119	4	2025-05-31 08:43:43.903509	
5460	Artika jain 	9898111226	2025-07-06 10:00:00	Needs Followup		2025-04-02 07:26:08.89984	6	2025-05-31 08:42:22.030114	
7310	Cx2027	8955752298	2025-07-26 10:00:00	Needs Followup	Mai call kar loga	2025-05-19 09:07:02.99142	4	2025-05-31 08:43:43.903509	
3702	.	7062714420	2025-07-05 10:00:00	Needs Followup	K10 1899\r\nSunday call back\r\nTime nhi hai jab milega tab call kar lunga khud	2025-02-04 11:08:27.673516	4	2025-05-31 08:42:17.990214	
5454	Abhishek 	9899107607	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 07:20:26.252037	4	2025-05-31 08:42:26.111514	
7312	Cx2028	9996017865	2025-07-26 10:00:00	Needs Followup	Xuv service 	2025-05-19 09:09:02.217566	4	2025-05-31 08:43:43.903509	
2575	Test	9001436050	2025-10-24 18:30:00	Needs Followup		2025-01-03 06:33:58.732764	6	2025-06-01 10:58:07.984839	
5458	Seema	9898318739	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 07:24:51.577494	4	2025-05-31 08:42:26.111514	
2872	Customer	7737375735	2025-07-08 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot requirement 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:30.087566	
5455	Dev	9899060300	2025-07-09 10:00:00	Needs Followup		2025-04-02 07:21:03.844389	6	2025-05-31 08:42:34.144665	
5456	Ashok parnami	9899052994	2025-07-09 10:00:00	Needs Followup		2025-04-02 07:23:32.647583	6	2025-05-31 08:42:34.144665	
5459	Vijay Kumar Gupta 	9898268121	2025-07-09 10:00:00	Needs Followup		2025-04-02 07:25:29.295651	6	2025-05-31 08:42:34.144665	
5463	Rakesh 	9893142501	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 07:27:56.228493	6	2025-05-31 08:42:34.144665	
7833	gaadimech	9001156041	2025-07-03 18:30:00	Needs Followup	Ford Fiesta jagatpura 2099panel	2025-07-02 07:30:16.65706	6	2025-07-02 07:30:16.657068	
7832	gaadimech	9983972625	2025-07-02 18:30:00	Did Not Pick Up	Busy call u later 	2025-07-02 07:29:22.173197	6	2025-07-02 07:31:16.829436	
5464	Ali	9893127452	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 07:28:29.961023	6	2025-05-31 08:42:34.144665	
3700	.	9672359664	2025-07-15 10:00:00	Needs Followup	Cal cut\r\nDon't have car	2025-02-04 11:08:27.673516	4	2025-05-31 08:42:58.621937	
569	......  	9829013201	2025-07-25 18:30:00	Did Not Pick Up	Abhi need  nhi\r\nNot pick	2024-11-29 07:12:53	6	2025-06-29 11:45:04.216142	
7558	gaadimech 	9414072922	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-29 04:59:46.14997	9	2025-07-03 08:40:21.540698	
2871	Customer	9799922237	2025-07-18 10:00:00	Needs Followup	Not pick\r\nNot pivk\r\nK10 1999\r\nVerna 2999\r\nSkoda 4999	2025-01-12 04:36:11.819946	4	2025-05-31 08:43:10.854377	
5485	Abhisheel	9829681330	2025-07-05 18:30:00	Needs Followup	Call cut 	2025-04-02 12:07:48.553174	4	2025-07-04 10:54:04.707961	
5482	Mahendra 	9829687678	2025-07-04 18:30:00	Needs Followup	No answer 	2025-04-02 12:05:52.030562	4	2025-07-04 12:00:23.590309	
7916	Unknown	919944274679	2025-07-06 08:57:47.397012	Needs Followup	Service: None. Source: None. Friday, July 4, 2025 at 9:19 PM\r\n9944274679\r\n-\t-\t\r\nTata\r\nAltroz\r\npetrol\r\n3,199	2025-07-05 08:57:47.4008	2	2025-07-05 08:57:47.400827	
7920	Cx 4014	919983331646	2025-07-04 18:30:00	Needs Followup	 Jodhpur	2025-07-05 12:02:32.130828	4	2025-07-05 13:27:15.860557	
2374	.	9828885761	2025-07-04 18:30:00	Needs Followup	\tFrom Hanumangarh	2024-12-22 08:06:41.389566	9	2025-07-06 09:41:37.920114	
7792	gaadimech 	9352053606	2025-07-03 18:30:00	Open	Amaze  dent paint	2025-07-01 05:22:17.594017	6	2025-07-02 09:09:04.97092	
7014	Customer 	8740004537	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:00:48.865264	4	2025-05-31 08:43:27.624295	
5491	Gauri shankar 	9829676665	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-04-02 12:20:51.03837	6	2025-05-31 08:42:22.030114	
2877	Customer	9929777981	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:04.112745	
7015	Customer 	8740004537	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:01:12.206114	4	2025-05-31 08:43:27.624295	
7016	Customer 	9057229762	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:01:33.094403	4	2025-05-31 08:43:27.624295	
7018	Customer 	9414240343	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:02:29.001353	4	2025-05-31 08:43:27.624295	
7021	Customer 	9694430333	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:04:07.611174	4	2025-05-31 08:43:27.624295	
7013	Customer 	8559819924	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:00:28.191216	6	2025-05-31 08:43:27.624295	
7010	Customer 	9829220051	2025-07-23 10:00:00	Needs Followup		2025-05-08 11:58:51.491961	4	2025-05-31 08:43:31.574711	
5492	Ajay 	9829676585	2025-07-06 10:00:00	Needs Followup	I 20 :2999\r\nAlto:2399	2025-04-02 12:22:50.517139	6	2025-05-31 08:42:22.030114	
5494	Bhojraj	9829675670	2025-07-06 10:00:00	Needs Followup		2025-04-02 12:24:20.737658	6	2025-05-31 08:42:22.030114	
7011	Customer 	9828525731	2025-07-23 10:00:00	Needs Followup		2025-05-08 11:59:43.619436	4	2025-05-31 08:43:31.574711	
7017	Customer 	9587009005	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:02:05.302756	6	2025-05-31 08:43:31.574711	
7012	Customer 	9649901035	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:00:04.717489	6	2025-05-31 08:43:31.574711	
7020	Customer 	9929012768	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:03:29.19311	4	2025-05-31 08:43:39.880052	
7314	Cx2030	7568462241	2025-07-26 10:00:00	Needs Followup	i10 service 2299	2025-05-19 09:10:57.336682	6	2025-05-31 08:43:43.903509	
5472	Gajanand 	9892054617	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 11:59:12.024351	4	2025-05-31 08:42:26.111514	
7317	Cx2026	6376962231	2025-07-26 10:00:00	Needs Followup	Dent paint 	2025-05-19 12:32:43.842985	6	2025-05-31 08:43:43.903509	
7532	Cx2063	8360448084	2025-07-26 10:00:00	Needs Followup	Sikar se hu	2025-05-27 11:10:56.7093	6	2025-05-31 08:43:43.903509	
7607	Test	1234567890	2025-07-26 10:00:00	Needs Followup		2025-05-30 08:53:43.583373	6	2025-05-31 08:43:43.903509	
1465	Rajeev sir 	9414743390	2025-07-26 10:00:00	Needs Followup	WhatsApp package share\r\nNot pick \r\nNot pick	2024-12-08 08:15:33	6	2025-05-31 08:43:43.903509	
2743	Customer	9414333765	2025-07-26 10:00:00	Needs Followup	Gi10 2699\r\nNot pick \r\nCall cut	2025-01-09 04:06:43.856234	6	2025-05-31 08:43:43.903509	
5489	Munish	9829677987	2025-07-07 10:00:00	Needs Followup		2025-04-02 12:19:42.058808	4	2025-05-31 08:42:26.111514	
4719	.	9829414103	2025-07-27 10:00:00	Needs Followup	I10 2299 \r\nSelf call karenge 	2025-03-13 10:57:53.884798	4	2025-05-31 08:43:47.842094	
5490	Nizamuddin 	9829677218	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:20:22.415429	4	2025-05-31 08:42:26.111514	
5493	Ajay	9829675799	2025-07-07 10:00:00	Needs Followup		2025-04-02 12:23:40.029263	4	2025-05-31 08:42:26.111514	
2878	Customer	7727817341	2025-07-08 10:00:00	Needs Followup	Scorpio 4699\r\nSwift Dzire. 2899\r\nVenue 3299\r\nPackage 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:30.087566	
5474	Ankit 	9890230788	2025-07-08 10:00:00	Needs Followup		2025-04-02 12:00:25.777829	6	2025-05-31 08:42:30.087566	
5473	Arvind jain	9891497895	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 11:59:59.992829	6	2025-05-31 08:42:34.144665	
5475	Manoj	9890183577	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:01:05.734387	6	2025-05-31 08:42:34.144665	
5476	Nirmal Kumar 	9889380829	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:02:05.657238	6	2025-05-31 08:42:34.144665	
5477	Nahar 	9829705522	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:02:37.125025	6	2025-05-31 08:42:34.144665	
5478	Naveen 	9829702020	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:03:34.152594	6	2025-05-31 08:42:34.144665	
7019	Customer 	9828177153	2025-07-19 10:00:00	Needs Followup		2025-05-08 12:02:49.922585	4	2025-05-31 08:43:14.897002	
7793	gaadimech 	9414253484	2025-07-03 18:30:00	Did Not Pick Up	Swift engine light doorstep check	2025-07-01 05:35:26.068634	6	2025-07-02 09:07:46.135126	
7835	Paint 	8619288514	2025-07-12 18:30:00	Needs Followup	Paint sharp motor 	2025-07-03 08:22:35.607173	4	2025-07-04 07:44:14.974907	
2895	Customer	8559990937	2025-07-21 10:00:00	Needs Followup	Beat 2399 package share	2025-01-12 04:36:11.819946	4	2025-05-31 08:43:23.449024	
7865	Cx4007	9024789717	2025-07-04 18:30:00	Needs Followup	Only company 	2025-07-04 06:22:58.561305	4	2025-07-05 12:47:29.982106	
7859	Washing 400	7014516263	2025-07-16 18:30:00	Needs Followup	Car service \r\nAjmer road 	2025-07-03 12:20:14.291707	4	2025-07-05 13:28:02.211586	
4887	.	9799138596	2025-07-21 10:00:00	Needs Followup	Call cit	2025-03-20 11:54:34.750438	4	2025-05-31 08:43:23.449024	
2898	Customer	9779100337	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	6	2025-05-31 08:42:14.037958	
4869	gaadimech	7230011444	2025-07-06 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-03-20 04:40:26.459491	4	2025-05-31 08:42:22.030114	
7024	Customer 	8949639939	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:05:10.890017	4	2025-05-31 08:43:27.624295	
4872	gadimech	8005789959	2025-07-06 10:00:00	Needs Followup	Not pick many time call \r\nExpress service 800 	2025-03-20 04:50:43.379382	4	2025-05-31 08:42:22.030114	
5503	Shiv charan 	9829666671	2025-07-06 10:00:00	Needs Followup		2025-04-02 12:33:31.28531	6	2025-05-31 08:42:22.030114	
4874	gaadimech 	9119144577	2025-07-18 10:00:00	Needs Followup	Polo Dent paint Sunday call back	2025-03-20 04:53:09.712731	4	2025-05-31 08:43:10.854377	
5496	Inthikhab	9829675611	2025-07-07 10:00:00	Needs Followup	Creta3699	2025-04-02 12:28:42.285271	4	2025-05-31 08:42:26.111514	
7025	Customer 	8875391111	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:05:29.45265	4	2025-05-31 08:43:27.624295	
7026	Customer 	7355941449	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:05:48.932359	4	2025-05-31 08:43:27.624295	
5497	Lokesh 	9829672670	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:29:35.143828	4	2025-05-31 08:42:26.111514	
5500	Yadram 	9829669176	2025-07-07 10:00:00	Needs Followup	I 20 2999	2025-04-02 12:30:54.479529	4	2025-05-31 08:42:26.111514	
7022	Customer 	7814858262	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:04:33.611597	4	2025-05-31 08:43:31.574711	
7023	Customer 	9079114638	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:04:53.04034	6	2025-05-31 08:43:31.574711	
4876	gaadi ech	7696202495	2025-07-24 10:00:00	Needs Followup	Tata tigor nd spark  srvice done by company workshop normal charges check ka rhe the 	2025-03-20 05:21:51.095158	4	2025-05-31 08:43:35.995616	
5501	Sandeep jain	9829667430	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:32:03.722449	4	2025-05-31 08:42:26.111514	
4885	.	9829431988	2025-07-24 10:00:00	Needs Followup	Call cut	2025-03-20 11:51:49.826423	4	2025-05-31 08:43:35.995616	
7027	Customer 	9828522520	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:06:15.816282	4	2025-05-31 08:43:39.880052	
2841	Customer	7239821917	2025-07-11 18:30:00	Needs Followup	Altis 3299 call cut	2025-01-12 04:36:11.819946	6	2025-06-28 11:13:21.485589	
5504	Vinod deg	9829666661	2025-07-07 10:00:00	Needs Followup		2025-04-02 12:34:04.234148	4	2025-05-31 08:42:26.111514	
4806	gaadimech 	8955617015	2025-07-27 10:00:00	Needs Followup	I20 tomorrow morning visit \r\nOut of jaipur\r\nNot interested 	2025-03-17 10:54:10.359019	4	2025-05-31 08:43:47.842094	
4886	.	8107769902	2025-07-27 10:00:00	Needs Followup	Not required alredy done 	2025-03-20 11:53:15.765037	4	2025-05-31 08:43:47.842094	
5499	Pawan Kumar 	9829670329	2025-07-09 10:00:00	Needs Followup		2025-04-02 12:30:07.245778	6	2025-05-31 08:42:34.144665	
4897	.	9828957000	2025-07-27 10:00:00	Needs Followup	Call cut	2025-03-20 12:24:31.990248	4	2025-05-31 08:43:47.842094	
5502	Narendra 	9829666966	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:32:39.063282	6	2025-05-31 08:42:34.144665	
6204	gaadimech 	9782575858	2025-07-27 10:00:00	Needs Followup	I20 2999 next month 	2025-04-17 08:42:12.736638	6	2025-05-31 08:43:47.842094	
4892	.	9829743431	2025-07-18 10:00:00	Needs Followup	Call cut	2025-03-20 12:16:24.319661	4	2025-05-31 08:43:10.854377	
4898	.	8619775446	2025-07-18 10:00:00	Needs Followup	Not pick 	2025-03-20 12:25:53.86146	4	2025-05-31 08:43:10.854377	
6668	gaadimech 	9414077387	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-04-25 10:38:41.561439	4	2025-05-31 08:43:51.744985	
4884	aslam khan	9712555071	2025-07-16 10:00:00	Needs Followup	Venue petrol suspension work and service 	2025-03-20 11:39:36.003979	4	2025-05-31 08:43:02.994951	RJ34CB1778
7846	Cx4004	9166353198	2025-07-04 18:30:00	Needs Followup	Car service \r\n	2025-07-03 10:12:23.43313	4	2025-07-03 10:12:23.433137	
4888	.	9799138596	2025-07-10 18:30:00	Did Not Pick Up	Call cit\r\nDon't have car 	2025-03-20 11:56:36.959838	6	2025-06-28 10:36:12.140917	
4875	gaadimech 	9024263040	2025-10-10 18:30:00	Did Not Pick Up	Not pick dent paint 	2025-03-20 05:03:11.003284	6	2025-06-28 10:46:47.471458	
2264	.	9928044454	2025-07-07 18:30:00	Did Not Pick Up	Cut a call 	2024-12-20 08:28:57.743192	6	2025-06-28 11:21:51.447551	
269	Yogesh ji	9509075588	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-11-25 10:44:18	6	2025-06-29 11:50:14.329931	
7812	gaadimech	9001518397	2025-07-03 18:30:00	Did Not Pick Up	Alto accelater issue vki	2025-07-02 04:59:55.720267	6	2025-07-02 11:32:52.025205	
3707	.	8003368098	2025-07-25 18:30:00	Did Not Pick Up	Not pick	2025-02-04 11:08:27.673516	6	2025-07-02 12:27:11.44109	
7847	Cx4005	9131289385	2025-07-05 18:30:00	Needs Followup	Car ac Jagatpura	2025-07-03 10:13:53.553568	4	2025-07-04 07:16:41.507429	
5889	Customer 	9829266751	2025-07-21 10:00:00	Needs Followup	Hyundai Verna 3399\r\nEvening 3 pm	2025-04-13 12:07:32.374742	6	2025-05-31 08:43:23.449024	
5892	Customer 	9829481294	2025-07-23 10:00:00	Needs Followup		2025-04-13 12:09:48.368505	4	2025-05-31 08:43:31.574711	
7029	Customer 	9887864774	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:07:02.128529	6	2025-05-31 08:43:31.574711	
7028	Customer 	8800425097	2025-07-23 10:00:00	Needs Followup		2025-05-08 12:06:38.132207	6	2025-05-31 08:43:31.574711	
5890	Customer 	9636243797	2025-07-26 10:00:00	Needs Followup		2025-04-13 12:08:18.824762	6	2025-05-31 08:43:43.903509	
7815	Cx3089	7357229586	2025-07-04 18:30:00	Needs Followup	In coming nahi hai voice call 	2025-07-02 05:15:05.514383	4	2025-07-03 12:29:01.913511	
4903	gaadimechh	7742042141	2025-07-27 10:00:00	Needs Followup	Etios dent paint again inquiry self visit krenge 	2025-03-21 04:57:42.066835	4	2025-05-31 08:43:47.842094	
4902	gaadimech 	7452938645	2025-07-27 10:00:00	Needs Followup	Call cut\r\nBy mistake 	2025-03-21 04:52:37.114489	4	2025-05-31 08:43:47.842094	
4904	gaadiemch	6350106810	2025-07-27 10:00:00	Needs Followup	Busy call cut \r\nNot interested \r\nCall cut	2025-03-21 05:05:01.927367	4	2025-05-31 08:43:47.842094	
5883	gaadimech 	8234910001	2025-07-27 10:00:00	Needs Followup	Nexon 3699	2025-04-13 09:31:01.057504	6	2025-05-31 08:43:47.842094	
6673	gaadimech 	7610062692	2025-07-28 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-25 11:05:09.26636	4	2025-05-31 08:43:51.744985	
6679	gaadimech 	9829065430	2025-07-28 10:00:00	Needs Followup	Not pick \r\nNot requirment 	2025-04-25 11:32:35.697576	4	2025-05-31 08:43:51.744985	
5514	Rajeev Gupta 	9829650355	2025-07-06 10:00:00	Needs Followup		2025-04-02 12:44:30.961396	6	2025-05-31 08:42:22.030114	
3705	.	9509308169	2025-07-30 18:30:00	Did Not Pick Up	Call cut	2025-02-04 11:08:27.673516	6	2025-05-23 11:45:50.270337	
7887	Cx4007	9784183736	2025-07-03 18:30:00	Needs Followup	Indergarh se	2025-07-05 04:26:51.598118	4	2025-07-05 05:37:20.198273	
2508	.	9300920537	2025-07-25 18:30:00	Needs Followup	Call not pick \r\nCall cut	2024-12-24 09:44:45.910357	6	2025-07-01 09:48:07.343807	
7888	Aura 2799	9772790328	2025-07-07 18:30:00	Completed	Aura service 2799\r\nFeedback call 	2025-07-05 04:28:14.589109	4	2025-07-05 08:24:37.546177	
7885	Harrier 	8386831643	2025-07-06 18:30:00	Needs Followup	Harrier 4999\r\n	2025-07-05 04:23:42.727565	4	2025-07-06 08:08:28.205436	
5508	Rajesh 	9829664446	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-02 12:36:08.42229	4	2025-05-31 08:42:38.503765	
5880	gaadimech 	9571205742	2025-09-26 18:30:00	Did Not Pick Up	Swift Dzire 2999\r\nService done by company workshop 	2025-04-13 09:20:16.479154	6	2025-05-05 09:19:25.442637	
7886	Tata punch Ev	9660700897	2025-07-15 18:30:00	Needs Followup	Tata punch Ev	2025-07-05 04:24:49.518832	4	2025-07-05 08:39:19.416156	
5887	Customer 	9772222207	2025-07-07 10:00:00	Needs Followup	Polo 4999	2025-04-13 11:48:57.2844	4	2025-05-31 08:42:26.111514	
5893	Customer 	9414783003	2025-07-08 10:00:00	Needs Followup		2025-04-13 12:10:18.799405	6	2025-05-31 08:42:30.087566	
7884	Vki bumper 	8306775753	2025-07-06 18:30:00	Needs Followup	Vki bumper paint 	2025-07-05 04:22:50.352421	4	2025-07-05 08:40:16.695381	
7919	Sameer	917014493301	2025-07-06 10:43:11.057523	Needs Followup	Service: Express Car Service. Source: Website. Maruti\r\nBaleno\r\nPetrol\r\nSameer\r\n7014493301\r\nExpress Service\r\nSelf Walk-in (You bring the car to our center)\r\nToday\r\n1:00 PM - 3:00 PM\r\nSaturday, July 5, 2025 at 11:15 AM	2025-07-05 10:43:11.059513	9	2025-07-05 10:43:11.059531	
7889	Dzire 	9166117891	2025-07-12 18:30:00	Needs Followup	Dzire \r\n	2025-07-05 04:30:22.878194	4	2025-07-06 06:50:28.505635	
2925	Customer	9829450214	2025-07-09 10:00:00	Needs Followup	Service done 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:34.144665	\N
5509	Sushama 	9829657881	2025-07-10 10:00:00	Needs Followup		2025-04-02 12:36:36.77309	4	2025-05-31 08:42:38.503765	
7890	Cx4009	8118830977	2025-07-06 18:30:00	Did Not Pick Up	No answer 	2025-07-05 04:30:53.048134	4	2025-07-05 23:41:44.795133	
7874	Cx4012	9314048399	2025-07-07 18:30:00	Needs Followup	Call cut	2025-07-04 06:29:11.735971	4	2025-07-06 08:48:43.964733	
5510	Amita	9829657687	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-02 12:37:11.212912	4	2025-05-31 08:42:38.503765	
5515	Vijay 	9829648551	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-02 12:45:00.903903	4	2025-05-31 08:42:38.503765	
5516	Shelendra 	9829647083	2025-07-10 10:00:00	Needs Followup	Tigor 3299	2025-04-02 12:45:58.394475	4	2025-05-31 08:42:38.503765	
5894	Customer 	7742779199	2025-07-11 10:00:00	Needs Followup		2025-04-13 12:11:03.244384	6	2025-05-31 08:42:42.451086	
2917	Customer	7073346198	2025-07-13 10:00:00	Needs Followup	Service done by company workshop 	2025-01-12 04:36:11.819946	6	2025-05-31 08:42:50.438237	\N
4900	gaadimech	8306724890	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-03-21 04:33:03.34892	4	2025-05-31 08:42:54.38585	
5891	Customer 	9460188305	2025-07-16 10:00:00	Needs Followup		2025-04-13 12:08:54.137081	4	2025-05-31 08:43:02.994951	
4907	gaadimech	6377914668	2025-07-21 10:00:00	Needs Followup	Etios 1000 ac check	2025-03-21 05:46:39.0737	4	2025-05-31 08:43:23.449024	
6235	Customer 	9829055990	2025-07-21 10:00:00	Needs Followup	Sentra Fe	2025-04-17 11:48:39.42731	6	2025-05-31 08:43:23.449024	
6253	Customer 	9782516385	2025-07-21 10:00:00	Needs Followup		2025-04-17 12:07:54.995573	6	2025-05-31 08:43:23.449024	
6256	Customer 	9829790575	2025-07-23 10:00:00	Needs Followup		2025-04-17 12:09:52.405102	4	2025-05-31 08:43:31.574711	
6236	Customer 	9521315199	2025-07-23 10:00:00	Needs Followup		2025-04-17 11:49:07.715086	4	2025-05-31 08:43:31.574711	
7891	Honda City 	9785826048	2025-07-06 18:30:00	Needs Followup	Honda City \r\nCall cut 	2025-07-05 05:01:55.570231	4	2025-07-05 05:01:55.570239	
7892	Altoz 3199	9944274679	2025-07-06 18:30:00	Needs Followup	Altoz 3199 	2025-07-05 05:04:40.085325	4	2025-07-05 05:04:40.085333	
4920	gaadimech.	9950097009	2025-07-24 10:00:00	Needs Followup	Switch off \r\nWhtsap call not pick 	2025-03-21 06:54:26.177887	4	2025-05-31 08:43:35.995616	
7030	Customer 	9828269129	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:07:22.571691	4	2025-05-31 08:43:39.880052	
4910	gaadimech 	6378066067	2025-07-27 10:00:00	Needs Followup	Not pick\r\nBy mistake 	2025-03-21 05:56:49.496351	4	2025-05-31 08:43:47.842094	
4911	gaadimechh 	8955962383	2025-07-27 10:00:00	Needs Followup	Busy call u later \r\nMene koi inquiry nahi ki ho gaye hogi by mistake	2025-03-21 05:59:17.374077	4	2025-05-31 08:43:47.842094	
4618	abhishek gaadimech	8947942511	2025-07-03 18:30:00	Needs Followup	Clutch issue break pad nd rear shoker \r\nCall cut 	2025-03-09 07:00:34.500159	4	2025-07-02 07:45:50.926948	
4915	gaadimech 	9024566343	2025-07-27 10:00:00	Needs Followup	Koi inquiry nhi ki 	2025-03-21 06:25:04.715416	4	2025-05-31 08:43:47.842094	
4917	gaadimech	8890908690	2025-07-27 10:00:00	Needs Followup	Not interested \r\nMene koi inquiry nahi ki hai	2025-03-21 06:29:41.528988	4	2025-05-31 08:43:47.842094	
6680	gaadimech 	9588974090	2025-07-28 10:00:00	Needs Followup	Call cut	2025-04-25 11:33:40.478335	4	2025-05-31 08:43:51.744985	
4918	gaadimech 	9977884429	2025-07-06 10:00:00	Needs Followup	Duster dent paint 	2025-03-21 06:44:25.543211	4	2025-05-31 08:42:22.030114	
6684	gaadimech 	8094638785	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-04-25 11:41:48.427728	4	2025-05-31 08:43:51.744985	
4912	gaadimech	8107629348	2025-07-18 10:00:00	Needs Followup	Swift Dzire ac checkup\r\nBusy out of jaipur \r\nCall cut	2025-03-21 06:05:14.872543	4	2025-05-31 08:43:10.854377	
6834	Customer 	9314517171	2025-07-28 10:00:00	Needs Followup		2025-05-01 12:01:54.986202	4	2025-05-31 08:43:51.744985	
6843	Cx1161	9252222220	2025-07-28 10:00:00	Needs Followup	Alto Dent paint insurance se\r\n	2025-05-02 07:46:20.761159	4	2025-05-31 08:43:51.744985	
7153	Cx2007	8094222777	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-13 07:09:48.82194	6	2025-05-31 08:43:51.744985	
6242	Customer 	9829387729	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-17 11:52:21.680548	6	2025-05-31 08:42:50.438237	
7188	Customer 	9321282923	2025-07-28 10:00:00	Needs Followup		2025-05-14 12:15:07.498261	6	2025-05-31 08:43:51.744985	
2931	Customer	9667776463	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:30.087566	
5895	Customer 	9414250072	2025-07-08 10:00:00	Needs Followup		2025-04-13 12:11:48.440107	6	2025-05-31 08:42:30.087566	
7344	gaadimech 	8233172864	2025-07-28 10:00:00	Needs Followup	Venue 3399	2025-05-21 05:53:54.513278	6	2025-05-31 08:43:51.744985	
7355	gaadimech 	8799896501	2025-07-28 10:00:00	Needs Followup	I20 ac check	2025-05-21 06:54:00.887585	6	2025-05-31 08:43:51.744985	
3261	customer 	9991295720	2025-07-07 18:30:00	Did Not Pick Up	Not pick	2025-01-20 12:02:14.345371	6	2025-06-29 10:51:25.781938	
6233	Customer 	9929957373	2025-07-09 10:00:00	Needs Followup	 	2025-04-17 11:47:45.386077	4	2025-05-31 08:42:34.144665	
7366	Cx2034	8054130553	2025-07-28 10:00:00	Needs Followup	Xuv 5199	2025-05-21 11:06:38.93087	6	2025-05-31 08:43:51.744985	
7367	Cx2036	8875272566	2025-07-28 10:00:00	Needs Followup	Brezza\r\nGlass 	2025-05-21 11:08:08.016037	6	2025-05-31 08:43:51.744985	
7369	Cx2037	9414133555	2025-07-28 10:00:00	Needs Followup	Dent paint 	2025-05-21 11:10:33.962602	6	2025-05-31 08:43:51.744985	
7371	gaadimech 	9116465455	2025-07-28 10:00:00	Needs Followup	Scorpio 5199	2025-05-22 04:45:30.292678	6	2025-05-31 08:43:51.744985	
6234	Customer 	7073903382	2025-07-09 10:00:00	Needs Followup		2025-04-17 11:48:07.175066	4	2025-05-31 08:42:34.144665	
4919	gaadimech 	9042085940	2025-07-30 18:30:00	Did Not Pick Up	Swift 2699	2025-03-21 06:52:57.111098	6	2025-05-05 11:48:58.956813	
6257	Customer 	9828288209	2025-07-19 10:00:00	Needs Followup		2025-04-17 12:10:20.749048	6	2025-05-31 08:43:14.897002	
7895	Tuv 300	9351070026	2025-08-21 18:30:00	Needs Followup	Tuv service 	2025-07-05 05:07:37.335532	4	2025-07-05 05:07:37.335539	
7896	Dzire 2899	8758707815	2025-07-07 18:30:00	Completed	Swift \r\nFeedback call 	2025-07-05 05:08:20.355487	4	2025-07-05 09:46:15.834104	
6239	Customer 	9828021364	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-17 11:50:58.17692	4	2025-05-31 08:42:34.144665	
6231	Customer 	8439561622	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:46:04.03063	4	2025-05-31 08:42:54.38585	
6248	Customer 	9829757555	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:03:35.857009	4	2025-05-31 08:42:54.38585	
6249	Customer 	9829757555	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:03:37.122545	4	2025-05-31 08:42:54.38585	
7893	Honda City,3399	9414332015	2025-07-07 18:30:00	Completed	Honda City service \r\nFeedback call 	2025-07-05 05:05:36.41059	4	2025-07-05 12:56:59.828565	
6252	Customer 	9829082203	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:07:29.156555	4	2025-05-31 08:42:54.38585	
6232	Customer 	8107056702	2025-07-16 10:00:00	Needs Followup		2025-04-17 11:47:17.835213	4	2025-05-31 08:43:02.994951	
6240	Customer 	9928953967	2025-07-16 10:00:00	Needs Followup		2025-04-17 11:51:22.786737	4	2025-05-31 08:43:02.994951	
6241	Customer 	9829330608	2025-07-16 10:00:00	Needs Followup		2025-04-17 11:51:48.971585	4	2025-05-31 08:43:02.994951	
6243	Customer 	8209195311	2025-07-16 10:00:00	Needs Followup		2025-04-17 11:52:47.237138	4	2025-05-31 08:43:02.994951	
7829	gaadimech 	8875697162	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-07-02 07:16:55.424036	6	2025-07-02 07:16:55.424043	
5900	Cx629	7014993035	2025-07-20 10:00:00	Needs Followup	Dzire service 2999	2025-04-14 05:58:00.79196	4	2025-05-31 08:43:19.077196	
6391	gaadimech 	8529488621	2025-07-21 10:00:00	Needs Followup	Swift 2799	2025-04-21 04:38:01.126783	6	2025-05-31 08:43:23.449024	
5904	Caiz 3399	9799573841	2025-07-20 10:00:00	Needs Followup	Caiz package,3399	2025-04-14 06:01:36.550983	4	2025-05-31 08:43:19.077196	
6401	gaadimech 	9782458641	2025-07-19 10:00:00	Needs Followup	Not pick 	2025-04-21 05:17:44.531225	6	2025-05-31 08:43:14.897002	
2937	Customer	8056010399	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
7836	Verna ac 	8209973727	2025-07-04 18:30:00	Needs Followup	Verna ac Ajmer road 	2025-07-03 08:23:23.852547	4	2025-07-04 07:46:24.28663	
5902	gaadiemch 	8769255579	2025-08-15 18:30:00	Did Not Pick Up	Not pick 	2025-04-14 06:00:41.411549	6	2025-06-29 09:09:16.488092	
2943	Customer	9929669292	2025-07-09 10:00:00	Needs Followup	Service done bye other workshop\r\n	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:34.144665	\N
5528	gaadimech 	6377463152	2025-07-27 10:00:00	Needs Followup	TRIBER 3599 not pick 	2025-04-03 08:00:56.959377	6	2025-05-31 08:43:47.842094	
7794	gaadimech 	7073148249	2025-07-03 18:30:00	Did Not Pick Up	Not connect 	2025-07-01 05:38:15.172986	6	2025-07-02 09:07:00.210561	
7838	Creta dent paint 	9928809101	2025-07-07 18:30:00	Completed	Creta dent paint \r\nFeedback call 	2025-07-03 08:26:08.993415	4	2025-07-04 11:12:28.346777	
7839	i20 service 2999	9784385559	2025-07-05 18:30:00	Needs Followup	i20 service 	2025-07-03 08:27:37.603468	4	2025-07-04 07:40:57.747358	
6268	Customer 	9314056599	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:17:58.772314	4	2025-05-31 08:42:54.38585	
5522	gaadimech 	9001463344	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-03 07:08:50.75894	6	2025-05-31 08:43:35.995616	
5897	Cx620	9784296646	2025-07-18 10:00:00	Needs Followup	Ac service 	2025-04-14 05:55:54.839936	6	2025-05-31 08:43:10.854377	
5901	Cx641	7014993035	2025-07-25 10:00:00	Needs Followup	Swift package 2899	2025-04-14 05:59:15.634411	6	2025-05-31 08:43:39.880052	
7879	Deepak Ji	9610999009	2025-07-06 18:30:00	Open	Innova Crysta feedback call	2025-07-04 07:15:25.996815	9	2025-07-04 10:06:15.847149	RJ14UF4064
7851	Cx4007	6375649765	2025-07-09 18:30:00	Needs Followup	Ac service \r\nOut off jaipur ho 	2025-07-03 10:28:27.738298	4	2025-07-05 13:47:53.02321	
5521	gaadimech 	8949619416	2025-07-21 10:00:00	Needs Followup	Scorpio condenser issue	2025-04-03 05:58:39.14636	6	2025-05-31 08:43:23.449024	
5524	gaadimech 	9828161837	2025-07-24 10:00:00	Needs Followup	Duster 2350 panel 	2025-04-03 07:44:53.917641	6	2025-05-31 08:43:35.995616	
5896	gaadimech	8619464228	2025-07-21 10:00:00	Needs Followup	Altroz 2999 sharp	2025-04-14 05:55:22.641595	6	2025-05-31 08:43:23.449024	
6273	Customer 	9713597162	2025-07-23 10:00:00	Needs Followup		2025-04-17 12:23:18.31646	6	2025-05-31 08:43:31.574711	
5527	gaadimech 	9929679870	2025-07-24 10:00:00	Needs Followup	Call cut \r\nOut of jaipur akar bat krenge 	2025-04-03 08:00:04.268955	6	2025-05-31 08:43:35.995616	
6271	Customer 	9829063092	2025-07-24 10:00:00	Needs Followup		2025-04-17 12:22:19.496626	6	2025-05-31 08:43:35.995616	
5905	Ford figo 3199	8302236950	2025-07-25 10:00:00	Needs Followup	Figo package 3199	2025-04-14 06:02:52.279018	6	2025-05-31 08:43:39.880052	
7850	Cx4006	9314519478	2025-07-05 18:30:00	Needs Followup	No answer 	2025-07-03 10:27:38.758729	4	2025-07-05 13:56:14.0441	
6389	Cx1007	7297065595	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-21 04:36:17.422606	6	2025-05-31 08:43:39.880052	
7033	Customer 	9414084057	2025-07-26 10:00:00	Needs Followup		2025-05-08 12:09:41.114753	6	2025-05-31 08:43:43.903509	
4923	gaadimech	8769620481	2025-07-27 10:00:00	Needs Followup	Dzire ac checkup 	2025-03-21 08:34:36.622278	4	2025-05-31 08:43:47.842094	
7031	Customer 	9928633337	2025-07-28 10:00:00	Needs Followup		2025-05-08 12:07:45.573481	4	2025-05-31 08:43:51.744985	
7032	Customer 	9602300441	2025-07-28 10:00:00	Needs Followup		2025-05-08 12:09:20.894628	4	2025-05-31 08:43:51.744985	
7373	gaadimech 	9782103932	2025-07-28 10:00:00	Needs Followup	Swift. 2799 tonk road Evng tak call back	2025-05-22 04:53:12.428406	6	2025-05-31 08:43:51.744985	
7375	gaadimech 	9530310999	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-05-22 05:07:07.470887	6	2025-05-31 08:43:51.744985	
7389	gaadimech 	9782328113	2025-07-29 10:00:00	Needs Followup	Out of jaipur call back after 2 days 	2025-05-22 08:37:33.321714	4	2025-05-31 08:43:55.621424	
7408	gaadimech 	9828593903	2025-07-29 10:00:00	Needs Followup	Spark 2599\r\nCall cut	2025-05-23 05:36:06.649089	4	2025-05-31 08:43:55.621424	
7409	gaadimech 	7665000044	2025-07-29 10:00:00	Needs Followup	Amaze 3199	2025-05-23 05:50:43.038715	4	2025-05-31 08:43:55.621424	
7423	gaadimech 	9351879765	2025-07-29 10:00:00	Needs Followup	Not pick 	2025-05-23 07:19:06.765465	4	2025-05-31 08:43:55.621424	
7837	Xuv300	9929048427	2025-07-04 18:30:00	Needs Followup	Xuv300\r\nDent paint \r\n2200	2025-07-03 08:24:53.446091	4	2025-07-03 08:24:53.446098	
7848	Cx4006	8003409294	2025-07-04 18:30:00	Needs Followup	Call cut	2025-07-03 10:24:39.117808	4	2025-07-03 10:24:39.117815	
7849	Cx4006	7062459295	2025-07-05 18:30:00	Needs Followup	Ac Jagatpura	2025-07-03 10:26:13.227396	4	2025-07-03 10:26:13.227403	
3710	.	9694834401	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-04 11:08:27.673516	4	2025-05-31 08:42:58.621937	
6396	Cx1117	7300439397	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-21 04:56:44.320714	4	2025-05-31 08:43:19.077196	
5910	gaadimech 	9414520545	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-14 07:00:12.022025	6	2025-05-31 08:43:35.995616	
4858	gaadimech 	9509462448	2025-07-19 10:00:00	Needs Followup	Call cut	2025-03-19 06:42:00.001176	4	2025-05-31 08:43:14.897002	
6397	Cx1118	9351494052	2025-07-20 10:00:00	Needs Followup	i20\r\nDent paint 	2025-04-21 04:57:43.50531	4	2025-05-31 08:43:19.077196	
6286	gaadimech 	8824342886	2025-07-21 10:00:00	Needs Followup	Alto 2399 not pick 	2025-04-18 05:18:44.4368	6	2025-05-31 08:43:23.449024	
6376	gaadimech 	9311957497	2025-07-21 10:00:00	Needs Followup	Ac checkup\r\nCall back after 10 days	2025-04-20 06:29:30.288016	6	2025-05-31 08:43:23.449024	
6394	gaadimech 	7340592526	2025-07-21 10:00:00	Needs Followup	Call cut	2025-04-21 04:40:04.903989	6	2025-05-31 08:43:23.449024	
5913	gaadimech 	9782836964	2025-07-24 10:00:00	Needs Followup	Dzire ins claim	2025-04-14 07:15:53.416173	6	2025-05-31 08:43:35.995616	
6277	gaadimech 	9828113011	2025-07-24 10:00:00	Needs Followup	Figo 2799 self call\r\nNot requirment 	2025-04-18 05:12:23.650835	6	2025-05-31 08:43:35.995616	
6398	Cx1114	9599324143	2025-07-25 10:00:00	Needs Followup	Dent paint 	2025-04-21 04:59:25.095558	6	2025-05-31 08:43:39.880052	
5909	gaadimech 	7221831863	2025-07-27 10:00:00	Needs Followup	Call cut	2025-04-14 06:59:35.016658	6	2025-05-31 08:43:47.842094	
6283	gaadimech 	9828828804	2025-07-27 10:00:00	Needs Followup	Baleno 2799 ajmer se h	2025-04-18 05:16:43.204698	6	2025-05-31 08:43:47.842094	
6392	gaadimech 	7734950068	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-04-21 04:38:34.347868	6	2025-05-31 08:43:47.842094	
7429	Cx2040	9366931292	2025-07-29 10:00:00	Needs Followup	Ac service 	2025-05-23 09:33:51.675025	4	2025-05-31 08:43:55.621424	
7430	Accord dent paint 	9351321223	2025-07-29 10:00:00	Needs Followup	Accord Dent paint 	2025-05-23 09:35:20.560444	4	2025-05-31 08:43:55.621424	
3711	.	8890443398	2025-07-25 18:30:00	Did Not Pick Up	Call cut	2025-02-04 11:08:27.673516	6	2025-07-02 12:27:48.537946	
7855	Alto 	7014804714	2025-07-05 18:30:00	Needs Followup	Service 	2025-07-03 10:36:56.301146	4	2025-07-04 06:50:44.196526	
7852	Swift 	9829322256	2025-07-20 18:30:00	Needs Followup	Swift Dzire 	2025-07-03 10:33:30.197819	4	2025-07-03 10:33:30.197826	
7853	Ertiga 	9928363403	2025-07-05 18:30:00	Needs Followup	Drycleaning \r\nRubbing 	2025-07-03 10:35:42.202528	4	2025-07-03 10:35:42.202535	
7795	gaadimech	6376851792	2025-07-02 18:30:00	Did Not Pick Up	Call not pick 	2025-07-01 05:44:19.011811	6	2025-07-01 05:44:19.011818	
7809	gaadimech	9785573451	2025-07-03 18:30:00	Did Not Pick Up	Fiat avventura 3999 not pick 	2025-07-01 09:20:48.839625	6	2025-07-02 08:40:11.141097	
7854	Ertiga 	9928363403	2025-07-05 18:30:00	Needs Followup	Drycleaning \r\nRubbing 	2025-07-03 10:36:17.466526	4	2025-07-03 10:36:17.466533	
6280	gaadimech 	8769963252	2025-07-30 18:30:00	Did Not Pick Up	Herrier wash 400	2025-04-18 05:14:24.989283	6	2025-05-10 11:40:10.338572	
7819	3092	9950902824	2025-07-04 18:30:00	Needs Followup	Car service \r\nCall cut	2025-07-02 05:21:28.938953	4	2025-07-03 10:58:38.945973	
1961	Parth baheti	7300033066	2025-08-15 18:30:00	Feedback	Polo insurance claim\r\nPAYMENT COMPLETED BY CHECK ( 8897 ) \r\nFEEDBACK \r\nNot pick 27/03/2025\r\n	2024-12-16 05:29:02	6	2025-06-28 11:43:09.54666	RJ45CN0275
6393	gaadimech 	9587320720	2025-08-29 18:30:00	Did Not Pick Up	Honda city  3399 tonk road \r\n\r\nNot interested 	2025-04-21 04:39:15.572905	6	2025-05-07 06:39:41.146425	
7857	Cx4007	7014970146	2025-07-06 18:30:00	Needs Followup	Call cut	2025-07-03 10:40:32.453144	4	2025-07-05 13:34:05.678011	
7856	Cx4007	8003088412	2025-07-06 18:30:00	Needs Followup	Call cut	2025-07-03 10:37:25.950997	4	2025-07-05 13:37:25.386956	
3256	.	9871954447	2025-07-24 10:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	4	2025-05-31 08:43:35.995616	
5536	gaadimech 	9351796714	2025-07-24 10:00:00	Needs Followup	Santro 2399	2025-04-04 08:43:28.424789	6	2025-05-31 08:43:35.995616	
5917	gaadimech 	9828647888	2025-07-24 10:00:00	Needs Followup	Call cut	2025-04-14 10:55:31.147454	6	2025-05-31 08:43:35.995616	
7034	Customer 	8560892484	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:21:14.97964	4	2025-05-31 08:43:39.880052	
7036	Customer 	9509678103	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:22:08.123486	6	2025-05-31 08:43:39.880052	
5123	gaadimech 	9163490199	2025-07-27 10:00:00	Needs Followup	Busy call 2 pm\r\nNot interested 	2025-03-27 05:13:22.798734	4	2025-05-31 08:43:47.842094	
5531	gaadimech 	8559971717	2025-07-27 10:00:00	Needs Followup	Not pick	2025-04-04 04:38:00.318443	6	2025-05-31 08:43:47.842094	
5944	Customer 	9829024847	2025-07-07 10:00:00	Needs Followup	Seltos 3599	2025-04-14 11:29:42.213226	4	2025-05-31 08:42:26.111514	
4927	Cx501	9414045147	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-22 07:03:26.338571	6	2025-05-31 08:42:22.030114	
7035	Customer 	7073479149	2025-07-28 10:00:00	Needs Followup		2025-05-08 12:21:36.701589	4	2025-05-31 08:43:51.744985	
5918	Customer 	9413127393	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:11:26.079181	6	2025-05-31 08:42:42.451086	
5912	gaadimech 	9784296646	2025-07-24 18:30:00	Did Not Pick Up	Call cut\r\nNot interested \r\n	2025-04-14 07:14:55.575373	6	2025-06-28 07:29:58.997157	
7432	Cx2042	9587158061	2025-07-29 10:00:00	Needs Followup	Car service 	2025-05-23 09:47:01.045434	4	2025-05-31 08:43:55.621424	
7438	gaadimech 	9460741556	2025-07-29 10:00:00	Needs Followup	Magnite 3999	2025-05-24 05:28:57.746071	4	2025-05-31 08:43:55.621424	
7442	gaadimech 	9660070450	2025-07-29 10:00:00	Needs Followup	Not pick 	2025-05-24 05:51:12.675868	4	2025-05-31 08:43:55.621424	
5919	Customer 	9413127393	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:11:28.311529	6	2025-05-31 08:42:42.451086	
7450	gaadimech 	9414079829	2025-07-29 10:00:00	Needs Followup	Terreno suspension 	2025-05-24 06:47:09.685493	4	2025-05-31 08:43:55.621424	
5920	Customer 	9413127393	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:11:32.208067	6	2025-05-31 08:42:42.451086	
5928	Customer 	9829004114	2025-07-14 10:00:00	Needs Followup		2025-04-14 11:14:08.746876	4	2025-05-31 08:42:54.38585	
7456	gaadimech 	7790932189	2025-07-29 10:00:00	Needs Followup	Wagnor 1999	2025-05-24 07:07:26.063667	4	2025-05-31 08:43:55.621424	
7457	Gaadimech	9414255590	2025-07-29 10:00:00	Needs Followup	TRIBER 3599 self call back	2025-05-24 08:48:35.165623	4	2025-05-31 08:43:55.621424	
7818	Cx3091	9983204724	2025-07-04 18:30:00	Needs Followup	Service \r\nVoice call only 	2025-07-02 05:19:33.959132	4	2025-07-04 07:49:38.065926	
7463	Cx2043	8690007514	2025-07-29 10:00:00	Needs Followup	Service 	2025-05-24 09:35:04.12072	4	2025-05-31 08:43:55.621424	
7474	gaadimech 	8385815044	2025-07-29 10:00:00	Needs Followup	Honda City 3399\r\nCall cut	2025-05-24 10:58:17.439452	4	2025-05-31 08:43:55.621424	
5924	Customer 	9001198208	2025-07-16 10:00:00	Needs Followup		2025-04-14 11:12:07.141661	4	2025-05-31 08:43:02.994951	
7483	Cx2042	9636719738	2025-07-29 10:00:00	Needs Followup	Dent paint 	2025-05-25 05:01:11.924969	4	2025-05-31 08:43:55.621424	
7490	gaadimech 	8764243204	2025-07-29 10:00:00	Needs Followup	Marazzo 4999\r\nRubbing 2000	2025-05-25 05:17:08.069731	4	2025-05-31 08:43:55.621424	
7500	gaadimech 	9001283739	2025-07-29 10:00:00	Needs Followup	Not valid no 	2025-05-25 07:45:22.35734	4	2025-05-31 08:43:55.621424	
4930	Cx 506	9636331100	2025-07-17 10:00:00	Needs Followup	Caiz 22000\r\nCall cut 	2025-03-22 07:07:57.307216	6	2025-05-31 08:43:06.869056	
7516	Cx2057	7733840301	2025-07-29 10:00:00	Needs Followup	i20 dent paint 	2025-05-27 08:53:09.578403	4	2025-05-31 08:43:55.621424	
5533	Cx611	8829821171	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-04 05:58:53.598944	4	2025-05-31 08:43:10.854377	
7541	gaadimech	9829754779	2025-07-29 10:00:00	Needs Followup	Wagnor 2599	2025-05-28 10:09:35.483206	4	2025-05-31 08:43:55.621424	
7542	gaadimech	9309439944	2025-07-29 10:00:00	Needs Followup	Not pick 	2025-05-28 10:10:40.260005	4	2025-05-31 08:43:55.621424	
7544	gaadimech 	9309439944	2025-07-29 10:00:00	Needs Followup	Not pick\r\nCall u back later whenever I am free 	2025-05-28 10:16:09.460224	4	2025-05-31 08:43:55.621424	
4929	Cx504	9828152552	2025-07-19 10:00:00	Needs Followup	Car service 	2025-03-22 07:06:45.479769	6	2025-05-31 08:43:14.897002	
5908	gaadimech 	9450271820	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-04-14 06:35:31.6911	6	2025-05-31 08:43:23.449024	
6548	Customer 	9829057008	2025-07-21 10:00:00	Needs Followup		2025-04-22 09:53:50.498044	6	2025-05-31 08:43:23.449024	
7038	Customer 	9829064265	2025-07-22 10:00:00	Needs Followup		2025-05-08 12:22:56.4246	4	2025-05-31 08:43:27.624295	
6558	Customer 	9829068522	2025-07-19 10:00:00	Needs Followup		2025-04-22 09:59:06.945939	4	2025-05-31 08:43:14.897002	
6546	Customer 	9829056038	2025-07-22 10:00:00	Needs Followup		2025-04-22 09:52:59.412315	6	2025-05-31 08:43:27.624295	
6549	Customer 	9660122333	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:54:15.863795	4	2025-05-31 08:43:31.574711	
6551	Customer 	9828068493	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:56:32.429926	4	2025-05-31 08:43:31.574711	
6543	Customer 	9314502315	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:51:34.180915	6	2025-05-31 08:43:31.574711	
6545	Customer 	9314010740	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:52:34.512165	6	2025-05-31 08:43:31.574711	
6557	Customer 	9414050265	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:58:46.875117	6	2025-05-31 08:43:31.574711	
7804	gaadimech	8209347443	2025-07-03 18:30:00	Did Not Pick Up	Call cut	2025-07-01 08:26:08.325033	6	2025-07-02 08:55:45.119594	
4942	Cx513	6350332283	2025-07-18 10:00:00	Needs Followup	Car service 	2025-03-22 10:28:51.868913	4	2025-05-31 08:43:10.854377	
4940	gaadimech	9636331100	2025-07-27 10:00:00	Needs Followup	Ciaz dent paint 	2025-03-22 10:26:00.424403	4	2025-05-31 08:43:47.842094	
4877	gaadimech 	9414553939	2025-07-24 10:00:00	Needs Followup	I10 ac checkup 999 \r\nOut of jaipur hai next week tonk road workshop visist krenge 	2025-03-20 06:40:20.704414	4	2025-05-31 08:43:35.995616	
5541	Cx614	7014935218	2025-07-07 10:00:00	Needs Followup	Kwid \r\nJodhpur  retha hi ab 	2025-04-05 05:02:44.454606	6	2025-05-31 08:42:26.111514	
7037	Customer 	9649770044	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:22:37.67374	4	2025-05-31 08:43:39.880052	
4931	Cx506	9352990206	2025-07-26 10:00:00	Needs Followup	Abhi out of jaipur hu	2025-03-22 07:09:05.763149	6	2025-05-31 08:43:43.903509	
5542	Cx615	7737025315	2025-07-26 10:00:00	Needs Followup	Car service 	2025-04-05 05:03:16.791831	6	2025-05-31 08:43:43.903509	
7918	Unknown	917874379027	2025-07-06 09:35:23.417894	Needs Followup	Service: Express Car Service. Source: Website. Wednesday, July 2, 2025 at 1:49 PM\r\nपपु\r\nहोंडा\r\n7874379027\r\nWednesday, July 2, 2025\r\nGeneral Service	2025-07-05 09:35:23.419083	9	2025-07-05 09:35:23.419097	
6544	Customer 	9829007988	2025-07-26 10:00:00	Needs Followup		2025-04-22 09:52:00.32318	6	2025-05-31 08:43:43.903509	
6554	Customer 	9414068867	2025-07-26 10:00:00	Needs Followup		2025-04-22 09:57:25.959882	6	2025-05-31 08:43:43.903509	
1423	....	9928304051	2025-07-26 10:00:00	Needs Followup	Not pick \r\nCall cut	2024-12-08 05:58:11	6	2025-05-31 08:43:43.903509	
6405	Customer 	9314027677	2025-07-27 10:00:00	Needs Followup	Hyundai i10 	2025-04-21 06:27:02.950602	6	2025-05-31 08:43:47.842094	
5953	Customer 	9314765087	2025-07-08 10:00:00	Needs Followup		2025-04-14 11:32:03.857963	6	2025-05-31 08:42:30.087566	
3126	Customer	9214308884	2025-07-09 10:00:00	Needs Followup	Not requirement 	2025-01-19 05:26:31.430473	4	2025-05-31 08:42:34.144665	
3713	.	9314504161	2025-07-26 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-02-04 11:08:27.673516	6	2025-05-31 08:43:43.903509	
7545	gaadimech 	9929274009	2025-07-29 10:00:00	Needs Followup	Santro 2499 \r\nAc 999\r\nTomorrow morning Pick up 	2025-05-28 10:21:54.563382	4	2025-05-31 08:43:55.621424	
7623	gaadimech	7220880740	2025-07-29 10:00:00	Needs Followup	Alto 2399 sharp motors eveng 5 pm	2025-05-30 12:42:15.578814	4	2025-05-31 08:43:55.621424	
7624	gaadimech	7220880740	2025-07-29 10:00:00	Needs Followup	Alto 2399 sharp motors eveng 5pm 	2025-05-31 04:24:24.214554	4	2025-05-31 08:43:55.621424	
1313	Roshan sir 	9828473938	2025-07-04 10:00:00	Needs Followup	WhatsApp package shared \r\nCall back \r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
4938	gaadimech	7737191352	2025-07-06 10:00:00	Needs Followup	Wagnor 2000 dent paint 	2025-03-22 10:24:48.303952	4	2025-05-31 08:42:22.030114	
5947	Customer 	9829324893	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:31:22.375888	6	2025-05-31 08:42:42.451086	
4937	Cx513	8058227237	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-22 10:19:27.999499	6	2025-05-31 08:42:22.030114	
4944	Cx519	9530065044	2025-07-18 10:00:00	Needs Followup	Tuv 300 5199	2025-03-22 10:40:17.586554	4	2025-05-31 08:43:10.854377	
5538	Cx612	8239208075	2025-07-18 10:00:00	Needs Followup	Ecosport 3799	2025-04-05 05:00:36.670451	4	2025-05-31 08:43:10.854377	
7860	Prakash Jain	9414332015	2025-07-03 18:30:00	Open	honda city petrol service ongoing	2025-07-04 05:28:39.420268	9	2025-07-05 07:51:19.695521	RJ45CV0932
2310	Varanasi	9214400088	2025-07-04 18:30:00	Needs Followup	\tFrom Varanasi	2024-12-21 08:31:22.208151	9	2025-07-06 09:42:19.172529	
6406	Customer 	9414048256	2025-07-19 10:00:00	Needs Followup		2025-04-21 06:43:38.038575	6	2025-05-31 08:43:14.897002	
6553	Customer 	9829055435	2025-07-19 10:00:00	Needs Followup		2025-04-22 09:57:03.258419	6	2025-05-31 08:43:14.897002	
6556	Customer 	9352954488	2025-07-19 10:00:00	Needs Followup		2025-04-22 09:58:18.280063	6	2025-05-31 08:43:14.897002	
5539	Cx613	9509465064	2025-07-19 10:00:00	Needs Followup	Ac service 	2025-04-05 05:01:13.148068	6	2025-05-31 08:43:14.897002	
6404	Sanjay Verma 	9351559444	2025-07-16 18:30:00	Needs Followup	Innova \r\nDent paint 	2025-04-21 06:25:04.27047	8	2025-05-01 04:16:02.22641	
5540	Cx614	7737253989	2025-07-19 10:00:00	Needs Followup	Carens service 4099	2025-04-05 05:02:06.620504	6	2025-05-31 08:43:14.897002	
7824	gaadimech 	9929325960	2025-07-18 18:30:00	Needs Followup	Not interested 	2025-07-02 07:04:51.789523	6	2025-07-02 07:04:51.789531	
6244	Customer 	8005829514	2025-07-11 18:30:00	Needs Followup		2025-04-17 11:53:10.794855	8	2025-04-24 08:25:24.29527	
6419	gaadimech 	9982639393	2025-09-29 18:30:00	Did Not Pick Up	I20 2999\r\nDoor step service done 	2025-04-21 07:31:47.672087	6	2025-04-26 06:41:56.950681	
5544	Santro 	9784594039	2025-07-18 10:00:00	Needs Followup	Santro Dent paint 	2025-04-05 09:21:56.965331	4	2025-05-31 08:43:10.854377	
6296	Customer 	9829012634	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-04-18 10:59:51.079762	6	2025-05-31 08:43:23.449024	
7908	Cx4011	9887427059	2025-07-07 18:30:00	Did Not Pick Up	Call cut 	2025-07-05 08:34:20.011171	4	2025-07-06 06:29:45.129864	
6300	Customer 	9829213344	2025-07-23 10:00:00	Needs Followup		2025-04-18 11:04:16.444502	4	2025-05-31 08:43:31.574711	
6412	Customer 	9314504387	2025-07-23 10:00:00	Needs Followup		2025-04-21 06:46:20.764776	6	2025-05-31 08:43:31.574711	
6415	Customer 	9929177000	2025-07-23 10:00:00	Needs Followup		2025-04-21 07:09:16.346461	6	2025-05-31 08:43:31.574711	
2881	Customer	7014207123	2025-07-24 10:00:00	Needs Followup	Not pick\r\nCall cut	2025-01-12 04:36:11.819946	4	2025-05-31 08:43:35.995616	
6197	Customer 	7610080742	2025-07-24 10:00:00	Needs Followup		2025-04-17 08:16:01.54375	6	2025-05-31 08:43:35.995616	
7910	Cx4013	9413737700	2025-07-06 18:30:00	Needs Followup	Call cut 	2025-07-05 08:35:21.161102	4	2025-07-05 08:35:21.161109	
6297	Customer 	9314939013	2025-07-24 10:00:00	Needs Followup	Not interested 	2025-04-18 11:00:31.791165	6	2025-05-31 08:43:35.995616	
7039	Customer 	9314857160	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:23:21.708448	6	2025-05-31 08:43:39.880052	
4913	dashrath ji .	9602669390	2025-07-27 10:00:00	Needs Followup	Seltos next month call back\r\nNot interested 	2025-03-21 06:09:06.56846	4	2025-05-31 08:43:47.842094	
4948	gaadimech	8824616064	2025-07-27 10:00:00	Needs Followup	Not interested by mistake hua hai 	2025-03-23 04:32:29.716733	4	2025-05-31 08:43:47.842094	
7813	gaadimech  7014116854	9001522975	2025-07-01 18:30:00	Open	Wrv honda  clutch plate \r\n	2025-07-02 05:01:07.580064	6	2025-07-02 05:01:07.580072	
6290	i20	7082059343	2025-07-27 10:00:00	Needs Followup	Car service aur clutch work 	2025-04-18 10:40:33.79131	6	2025-05-31 08:43:47.842094	
6293	Customer 	9829089709	2025-07-27 10:00:00	Needs Followup	Not interested 	2025-04-18 10:56:28.567176	6	2025-05-31 08:43:47.842094	
7909	Baleno 	7014493301	2025-07-06 18:30:00	Needs Followup	Baleno 	2025-07-05 08:34:52.36209	4	2025-07-05 08:34:52.362098	
6288	Customer 	9460434589	2025-07-14 10:00:00	Needs Followup		2025-04-18 10:34:28.28365	6	2025-05-31 08:42:54.38585	
6421	Customer 	9829669444	2025-07-27 10:00:00	Needs Followup	Creta\r\nNexon 	2025-04-21 08:24:43.724964	6	2025-05-31 08:43:47.842094	
7903	Alto vki 	9314624012	2025-07-06 18:30:00	Needs Followup	Alto vki \r\nNo answer 	2025-07-05 08:31:15.450564	4	2025-07-06 06:39:00.042936	
6294	Customer 	9414262011	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-18 10:58:02.284215	6	2025-05-31 08:42:54.38585	
7902	Honda City 	9530028021	2025-07-18 18:30:00	Needs Followup	Honda City 	2025-07-05 08:30:24.334044	4	2025-07-05 08:30:24.334059	
5955	Cx682	9782750211	2025-07-18 10:00:00	Needs Followup	Alto 2399	2025-04-15 07:34:16.481782	6	2025-05-31 08:43:10.854377	
3269	customer 	9650767950	2025-07-15 10:00:00	Needs Followup	Not interested \r\nCall cut	2025-01-20 12:02:14.345371	4	2025-05-31 08:42:58.621937	
6411	Customer 	7742200111	2025-07-19 10:00:00	Needs Followup		2025-04-21 06:45:51.946908	4	2025-05-31 08:43:14.897002	
6295	Customer 	9414262011	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-18 10:58:17.745169	6	2025-05-31 08:42:54.38585	
7899	Caiz 	9257011045	2025-07-08 18:30:00	Completed	Jagatpura \r\nHonda City \r\nFeedback call \r\n	2025-07-05 08:28:16.406492	4	2025-07-06 10:35:12.758673	
6298	Customer 	9829213344	2025-07-19 10:00:00	Needs Followup		2025-04-18 11:01:59.073725	6	2025-05-31 08:43:14.897002	
6408	Customer 	9829068291	2025-07-19 10:00:00	Needs Followup		2025-04-21 06:44:59.049757	6	2025-05-31 08:43:14.897002	
7394	Durga Prashad Meena	9785826048	2025-07-06 18:30:00	Confirmed	Honda city petrol service 3599 + synthetic oil + seat cover washing	2025-05-22 12:37:59.819933	9	2025-07-06 09:43:36.522105	RJ27CD8899
4955	gaadimech 	6376666967	2025-07-06 10:00:00	Needs Followup	Call cut\r\nCall cut	2025-03-23 06:11:04.853326	4	2025-05-31 08:42:22.030114	
5547	Cx613	9929944244	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-06 05:16:32.452037	4	2025-05-31 08:43:10.854377	
4951	gaadimech 	9829666680	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-03-23 05:23:04.692402	4	2025-05-31 08:43:23.449024	
5546	Cx620	9166780475	2025-07-19 10:00:00	Needs Followup	Car service 	2025-04-06 05:15:51.250616	6	2025-05-31 08:43:14.897002	
6305	gaadimech 	9414001553	2025-07-21 10:00:00	Needs Followup	Baleno 2799\r\nI20 2999\r\nSelf call	2025-04-19 04:44:11.131209	6	2025-05-31 08:43:23.449024	
6307	gaadimech 	7412942560	2025-07-22 10:00:00	Needs Followup	Bolero ac checkup	2025-04-19 05:00:59.590313	4	2025-05-31 08:43:27.624295	
6304	gaadimech 	7297846660	2025-07-24 10:00:00	Needs Followup	Not pick \r\nBusy call u later 	2025-04-19 04:42:06.755193	6	2025-05-31 08:43:35.995616	
7041	Customer 	9929991111	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:23:58.57274	6	2025-05-31 08:43:39.880052	
7042	Customer 	8559886594	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:24:20.667715	6	2025-05-31 08:43:39.880052	
5545	Cx619	9854300029	2025-07-25 10:00:00	Needs Followup	i20 service \r\n3399\r\n\r\n	2025-04-05 09:22:47.909689	6	2025-05-31 08:43:39.880052	
7040	Customer 	8290143009	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:23:41.479409	6	2025-05-31 08:43:39.880052	
4952	gaadimech 	6377384945	2025-07-27 10:00:00	Needs Followup	Switch off 	2025-03-23 05:36:37.975152	4	2025-05-31 08:43:47.842094	
6306	gaadimech 	9636500238	2025-07-27 10:00:00	Needs Followup	Eon 2299 self visit 	2025-04-19 04:59:05.153748	6	2025-05-31 08:43:47.842094	
5553	Cx629	7976511270	2025-07-07 10:00:00	Needs Followup	Car service \r\nCar sell kar di \r\n	2025-04-06 05:21:33.671172	6	2025-05-31 08:42:26.111514	
1797	.	7877939394	2025-08-07 18:30:00	Did Not Pick Up	Cut a call 	2024-12-14 06:02:14	6	2025-06-28 11:45:00.625697	
6424	Customer 	9829056110	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:26:28.599121	6	2025-05-31 08:42:50.438237	
5549	Swift 2899	7014463594	2025-07-19 10:00:00	Needs Followup	Car service Swift 2899	2025-04-06 05:17:49.995033	6	2025-05-31 08:43:14.897002	
5550	Cx623	9636425612	2025-07-19 10:00:00	Needs Followup	Car service 	2025-04-06 05:19:15.542718	6	2025-05-31 08:43:14.897002	
3714	.	9005464589	2025-07-11 00:00:00	Needs Followup		2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	\N
7768	gaadimech 	9587854254	2025-07-08 18:30:00	Did Not Pick Up	Call cut	2025-06-30 05:02:04.811968	6	2025-07-02 10:05:48.219797	
4954	ivr	9314641908	2025-07-08 10:00:00	Needs Followup	I10 seltos sharp motors inquiry ki hai 	2025-03-23 06:10:11.462496	4	2025-05-31 08:42:30.087566	
472	Cx79	9772242927	2025-07-27 18:30:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-05 07:51:52.735839	
444	Satveer sir	9829175196	2025-07-04 10:00:00	Needs Followup	Audi Q7 11999 package call back Monday\r\nOut of jaipur hai  \r\nNot pick	2024-11-28 06:03:20	4	2025-05-31 08:42:14.037958	
6425	Customer 	9828226911	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:26:57.077919	6	2025-05-31 08:42:50.438237	
5551	Cx623	6263443629	2025-07-19 10:00:00	Needs Followup	Ac service \r\nAbhi nahi	2025-04-06 05:20:08.428189	6	2025-05-31 08:43:14.897002	
6428	Customer 	9829057250	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:31:44.395867	6	2025-05-31 08:42:50.438237	
5548	Cx622	9983990286	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-06 05:17:07.284892	4	2025-05-31 08:43:10.854377	
4950	gaadimech 	9930702554	2025-07-14 10:00:00	Needs Followup	Not pick	2025-03-23 05:06:21.516456	4	2025-05-31 08:42:54.38585	
7921	Anil Jeet Jhala	8108111475	2025-07-13 18:30:00	Needs Followup	Mercedes  c2 20 awthegarden service must follow	2025-07-06 05:13:58.683719	9	2025-07-06 05:15:12.338862	
6426	Customer 	9829018151	2025-07-14 10:00:00	Needs Followup		2025-04-21 08:28:20.330126	6	2025-05-31 08:42:54.38585	
6436	Customer 	9214014119	2025-07-14 10:00:00	Needs Followup		2025-04-21 09:24:38.574456	6	2025-05-31 08:42:54.38585	
6423	Customer 	9886066563	2025-07-16 10:00:00	Needs Followup		2025-04-21 08:26:02.192708	6	2025-05-31 08:43:02.994951	
6427	Customer 	9828075409	2025-07-16 10:00:00	Needs Followup		2025-04-21 08:29:40.298342	6	2025-05-31 08:43:02.994951	
5554	Cx626	9414141469	2025-07-18 10:00:00	Needs Followup	Call answer 	2025-04-06 05:22:20.303656	4	2025-05-31 08:43:10.854377	
5556	Cx626	9772789390	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-06 05:26:22.022809	4	2025-05-31 08:43:10.854377	
5555	Cx626	6375488235	2025-07-19 10:00:00	Needs Followup	Swift service \r\n\r\n	2025-04-06 05:23:48.147892	6	2025-05-31 08:43:14.897002	
7803	Vki 	9929502597	2025-07-04 18:30:00	Needs Followup	Swift vki	2025-07-01 07:38:49.416315	4	2025-07-04 08:07:48.021855	
7594	gaadimech 	9828012596	2025-08-09 18:30:00	Did Not Pick Up	\tDzire 2999 visit tomorrow Not pick	2025-05-30 04:42:36.86303	9	2025-07-06 05:47:29.447108	
1419	Raj Kumar sir celerio	9024775060	2025-07-06 10:00:00	Needs Followup	Call back \r\nService requirement \r\nBusy call u letter\r\nCall cut\r\nNot pic	2024-12-08 05:58:11	4	2025-05-31 08:42:22.030114	
7043	Customer 	9892962104	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:24:41.485107	6	2025-05-31 08:43:39.880052	
5961	Customer 	9414051690	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-15 10:39:32.065212	6	2025-05-31 08:42:42.451086	
7044	Customer 	9828065320	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:25:57.305761	6	2025-05-31 08:43:39.880052	
7045	Customer 	7858635586	2025-07-25 10:00:00	Needs Followup		2025-05-08 12:27:00.928642	6	2025-05-31 08:43:39.880052	
7822	gaadimech 	9521721104	2025-07-02 18:30:00	Did Not Pick Up	Call cut	2025-07-02 06:52:12.591968	6	2025-07-02 06:52:12.591975	
7823	gaadimech 	9509001547	2025-07-02 18:30:00	Did Not Pick Up	Busy call u later 	2025-07-02 06:54:00.297293	6	2025-07-02 06:54:00.297302	
4959	gaadimech 	7413066325	2025-07-27 10:00:00	Needs Followup	Eco van 2599\r\nNot interested 	2025-03-23 08:46:00.240401	4	2025-05-31 08:43:47.842094	
5960	Customer 	9828114115	2025-07-27 10:00:00	Needs Followup		2025-04-15 10:38:53.67219	6	2025-05-31 08:43:47.842094	
7791	gaadimech	9672111107	2025-07-03 18:30:00	Did Not Pick Up	Not pick 	2025-07-01 05:04:51.155655	6	2025-07-02 09:11:54.655129	
7825	gaadimech 	7219998875	2025-07-02 18:30:00	Did Not Pick Up		2025-07-02 07:06:08.381257	6	2025-07-02 07:06:08.381265	
3716	.	7023222266	2025-07-30 18:30:00	Did Not Pick Up	Call cut	2025-02-04 11:08:27.673516	6	2025-07-02 12:26:18.820288	
7805	gaadimech 	9887045813	2025-07-03 18:30:00	Needs Followup	Eon ac CHECK UP 999 tonk road 	2025-07-01 08:32:39.102009	6	2025-07-02 08:54:16.369475	
3026	Sharad Katta	9782122660	2025-07-04 18:30:00	Needs Followup	Totally not interested and disconnect the call in anger	2025-01-13 09:02:24.989067	9	2025-07-06 09:43:22.232057	\N
2992	Customer	9717821686	2025-07-04 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-13 09:02:24.989067	6	2025-05-31 08:42:14.037958	
5962	Customer 	9414051690	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 10:39:34.070554	4	2025-05-31 08:42:46.397595	
5963	Customer 	9929760760	2025-07-12 10:00:00	Needs Followup	Amaze 3199	2025-04-15 10:40:12.309021	4	2025-05-31 08:42:46.397595	
5557	Cx629	9772789390	2025-07-18 10:00:00	Needs Followup	Wrv 3199	2025-04-06 08:29:31.625303	4	2025-05-31 08:43:10.854377	
5558	Cx629	8503098480	2025-07-18 10:00:00	Needs Followup	Ac service	2025-04-06 08:35:24.559958	4	2025-05-31 08:43:10.854377	
5560	Cx630	8306882070	2025-07-18 10:00:00	Needs Followup	Ritza \r\nAc service 	2025-04-06 08:37:13.135585	6	2025-05-31 08:43:10.854377	
4961	gaadimech	9468866923	2025-07-24 10:00:00	Needs Followup	Call cut	2025-03-24 04:30:34.968604	4	2025-05-31 08:43:35.995616	
7783	gaadimech	7062060820	2025-07-03 18:30:00	Did Not Pick Up	I10 nios dent paint 1899 panel charge	2025-07-01 04:41:49.885774	6	2025-07-02 09:28:01.914288	
6402	Cx1118	9784539371	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-21 05:45:46.473726	6	2025-05-31 08:43:39.880052	
6552	Customer 	9829055435	2025-07-26 10:00:00	Needs Followup		2025-04-22 09:57:02.093186	6	2025-05-31 08:43:43.903509	
4015	.	9929394195	2025-07-26 10:00:00	Needs Followup	Service done already 	2025-02-12 11:47:51.98708	6	2025-05-31 08:43:43.903509	
5563	gaadimech 	9887461692	2025-08-29 18:30:00	Did Not Pick Up	Scorpio 5499\r\nNot interested 	2025-04-07 05:52:25.775757	6	2025-05-09 06:45:49.769489	
1625	Rakesh sharma	9461801187	2025-07-18 18:30:00	Did Not Pick Up	Alto-800,CUS location Raja Park.\r\nno need right now\r\n\r\nCall cut	2024-12-10 05:43:58	6	2025-06-28 11:46:32.420134	
5984	Customer 	9887976453	2025-07-08 10:00:00	Needs Followup		2025-04-15 11:33:45.590921	6	2025-05-31 08:42:30.087566	
5985	Customer 	9460778890	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:34:11.727843	4	2025-05-31 08:42:46.397595	
5986	Customer 	9828328392	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:34:47.217688	4	2025-05-31 08:42:46.397595	
6015	Customer 	9351537697	2025-07-14 10:00:00	Needs Followup		2025-04-15 12:16:35.821751	6	2025-05-31 08:42:54.38585	
464	.	9928358121	2025-07-14 10:00:00	Needs Followup	Call back 	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
6012	Customer 	8769562140	2025-07-16 10:00:00	Needs Followup		2025-04-15 12:13:38.155548	4	2025-05-31 08:43:02.994951	
4455	gaadimech	8278609014	2025-08-29 18:30:00	Did Not Pick Up	Call cut \r\nBikaner 	2025-03-01 10:37:21.904199	6	2025-06-01 10:11:17.749708	
7840	Service 	9828438101	2025-07-04 18:30:00	Needs Followup	Voice call 	2025-07-03 08:30:21.60513	4	2025-07-04 07:33:56.702786	
2809	Cx162	9680459538	2025-07-02 18:30:00	Did Not Pick Up	Audi A4\r\nCar service \r\n\r\nNot pick	2025-01-10 04:20:50.707156	6	2025-06-01 10:33:17.617836	
2726	Cx147	9828355915	2025-07-16 18:30:00	Did Not Pick Up	Honda jazz \r\n2999\r\nConfirm service \r\nNot pick	2025-01-08 11:00:12.657946	6	2025-06-01 10:37:39.709141	
7802	Vki 	9929502597	2025-07-04 18:30:00	Needs Followup	Vki ac Swift 	2025-07-01 07:13:27.765484	4	2025-07-04 08:09:40.047132	
2032	hasjbajscx	7023620070	2025-08-21 18:30:00	Needs Followup	This is a test, please don't call	2024-12-16 14:58:39	6	2025-06-01 11:07:17.679812	
1664	GST Swift vdi	9509918383	2025-07-18 18:30:00	Did Not Pick Up	car is out of town right, \r\nCall cut not interested 	2024-12-11 07:05:55	6	2025-06-01 11:10:03.256185	
6014	Customer 	9314401208	2025-07-16 10:00:00	Needs Followup	Ciaz 3199	2025-04-15 12:15:16.906393	4	2025-05-31 08:43:02.994951	
4968	Cx520	9829200766	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-24 04:59:31.785116	6	2025-05-31 08:43:06.869056	
4969	Cx522	9352719644	2025-07-18 10:00:00	Needs Followup	Car service 	2025-03-24 04:59:59.242315	6	2025-05-31 08:43:10.854377	
4963	gaadimech 	8097866459	2025-07-19 10:00:00	Needs Followup	Not pick 	2025-03-24 04:45:19.838903	4	2025-05-31 08:43:14.897002	
4972	Cx 526	9314518322	2025-07-19 10:00:00	Needs Followup	Car service \r\nExpress 	2025-03-24 05:03:28.066772	6	2025-05-31 08:43:14.897002	
7790	gaadimcech	7737770721	2025-07-03 18:30:00	Did Not Pick Up	Call cut	2025-07-01 05:02:10.168967	6	2025-07-02 09:12:48.859484	
7769	gaadimech 	9680510188	2025-07-02 18:30:00	Needs Followup	Creta full gadi paint 25000	2025-06-30 05:08:04.512854	6	2025-06-30 05:08:04.512862	
5015	Sumit Gupta 	8890629475	2025-07-04 10:00:00	Needs Followup	Belleno \r\nDenting and painting 22k 	2025-03-24 10:42:33.98964	4	2025-05-31 08:42:14.037958	
5958	Cx686	9352990206	2025-07-20 10:00:00	Needs Followup	Eon ac service \r\nSharp motor 	2025-04-15 08:29:41.371065	4	2025-05-31 08:43:19.077196	
4988	Customer 	7014883955	2025-07-27 10:00:00	Needs Followup	Has already done with the car service from some other outlet 	2025-03-24 08:11:24.34292	4	2025-05-31 08:43:47.842094	
5010	Ravi sharma 	9414174601	2025-07-27 10:00:00	Needs Followup	Scorpio 4999	2025-03-24 09:19:32.640381	4	2025-05-31 08:43:47.842094	
7801	gaadimech 	9549057489	2025-07-03 18:30:00	Did Not Pick Up	Dzire 1999 panel\r\nNot oick	2025-07-01 06:57:49.509782	6	2025-07-02 08:59:36.876082	
383	Abhishek ji	7218639606	2025-07-25 18:30:00	Needs Followup	Not re	2024-11-27 07:21:40	6	2025-07-01 11:20:04.235725	
63	CX16	8875700666	2025-07-18 18:30:00	Did Not Pick Up	Baleno  not pick	2024-11-23 11:05:15	6	2025-06-28 11:52:43.417842	
7867	Cx4008	9950370320	2025-07-06 18:30:00	Needs Followup	Car service 	2025-07-04 06:24:32.321811	4	2025-07-05 10:57:30.056821	
7770	gaadimech 	8697496765	2025-07-03 18:30:00	Did Not Pick Up	Byd atto 3 dent paint 	2025-06-30 05:18:42.590236	6	2025-07-02 10:04:01.611377	
7816	Cx3090	8290752163	2025-07-04 18:30:00	Needs Followup	Call end 	2025-07-02 05:16:16.566183	4	2025-07-03 11:57:55.139862	
3522	.	9664265183	2025-07-03 18:30:00	Needs Followup	Call cut 	2025-01-30 05:36:29.015053	4	2025-07-02 11:57:58.877912	
4999	CX	8097866459	2025-07-03 10:00:00	Needs Followup	Toyota INNOVA Diesel 2010 Model.\r\nPackage Given Express Service Rs.5499\r\n	2025-03-24 08:20:26.120837	4	2025-05-31 08:42:09.584832	
1638	.	9214308884	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot connect \r\nNot pick\r\nNot pick	2024-12-10 08:57:17	6	2025-05-31 08:42:14.037958	
5009	Pradeep 	9829019040	2025-07-08 10:00:00	Needs Followup	Not required for now 	2025-03-24 09:13:50.505136	6	2025-05-31 08:42:30.087566	
4975	Rahul	9828112085	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-03-24 07:14:14.32448	4	2025-05-31 08:43:02.994951	
7764	Cx3094	9166937811	2025-07-04 18:30:00	Needs Followup	Dent paint \r\nBolero 	2025-06-30 04:48:29.516695	4	2025-07-02 05:52:07.486257	
3955	nitesh guota	9358824538	2025-09-24 18:30:00	Feedback	Not interested first service is not good 	2025-02-12 04:53:25.901341	9	2025-07-02 04:53:49.86526	RJ19CE7558
5578	Gaadimech 	8118836882	2025-07-21 10:00:00	Needs Followup	Elentra 3699	2025-04-07 10:57:52.265402	6	2025-05-31 08:43:23.449024	
5597	Gaurav 	9829638911	2025-07-23 10:00:00	Needs Followup		2025-04-07 12:04:05.005328	4	2025-05-31 08:43:31.574711	
5583	Vinod 	9845718976	2025-07-07 10:00:00	Needs Followup		2025-04-07 11:54:36.937077	4	2025-05-31 08:42:26.111514	
5582	Shlil kumar 	9846400116	2025-07-23 10:00:00	Needs Followup	Not interested 	2025-04-07 11:53:58.133852	6	2025-05-31 08:43:31.574711	
3273	customer 	7877749401	2025-07-24 10:00:00	Needs Followup	Service done by other workshop 	2025-01-20 12:02:14.345371	4	2025-05-31 08:43:35.995616	
5569	gaadimech	9413396236	2025-07-24 10:00:00	Needs Followup	I10 service 2399 	2025-04-07 08:24:06.996478	6	2025-05-31 08:43:35.995616	
5957	Cx685	9351808743	2025-07-25 10:00:00	Needs Followup	Amaze 	2025-04-15 07:36:24.300978	6	2025-05-31 08:43:39.880052	
5566	Cx643	7340310227	2025-07-26 10:00:00	Needs Followup	Xuv 500\r\nService 5199	2025-04-07 06:15:49.710324	6	2025-05-31 08:43:43.903509	
5577	gaadimech 	9414780170	2025-07-27 10:00:00	Needs Followup	Brezza 3499 door step service	2025-04-07 09:06:32.071518	6	2025-05-31 08:43:47.842094	
5573	gaadimech 	8005717275	2025-07-30 18:30:00	Did Not Pick Up	Dent paint \r\nNot interested 	2025-04-07 08:57:24.916435	6	2025-05-05 09:20:45.0055	
5584	Ashvin 	9845281866	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-07 11:55:52.284309	4	2025-05-31 08:42:38.503765	
5586	Akshat 	9840244986	2025-07-10 10:00:00	Needs Followup		2025-04-07 11:57:01.430524	4	2025-05-31 08:42:38.503765	
7877	Cx4010	9257409884	2025-07-04 18:30:00	Needs Followup	Rong no call nahi iss no per 	2025-07-04 06:45:12.690513	4	2025-07-05 09:27:15.132353	
7894	Tiago 3199	7202850082	2025-08-06 18:30:00	Needs Followup	TATA Tiago 3199\r\n	2025-07-05 05:06:43.386516	4	2025-07-06 06:43:32.19569	
5588	Shyam sundar 	9839050091	2025-07-10 10:00:00	Needs Followup		2025-04-07 11:58:30.994169	4	2025-05-31 08:42:38.503765	
5590	Sanjay Sharma 	9829646773	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-07 12:00:04.47037	4	2025-05-31 08:42:38.503765	
3421	.	8875012056	2025-07-07 18:30:00	Needs Followup	Car service 	2025-01-26 09:16:05.01535	4	2025-07-02 13:26:25.200455	
3426	.	9414085259	2025-07-01 18:30:00	Needs Followup	Ganganagar rehta hu 	2025-01-26 09:16:05.01535	4	2025-07-02 13:30:11.627744	
1296	Customer	9982550667	2025-08-07 18:30:00	Needs Followup	Call Not interested \r\n	2024-12-07 05:46:09	6	2025-06-28 11:47:15.825858	
7689	Cx2096	9828888305	2025-08-09 18:30:00	Needs Followup	\tWr service 2599	2025-06-02 06:08:58.066789	9	2025-07-06 06:32:20.759575	
5591	Pradeep 	9829645630	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:00:35.01798	4	2025-05-31 08:42:38.503765	
5592	Pankaj 	9829644410	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:01:05.069571	4	2025-05-31 08:42:38.503765	
5593	Manish 	9829643100	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:01:47.239839	4	2025-05-31 08:42:38.503765	
5594	Kaushalya	9829641353	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:02:27.199732	4	2025-05-31 08:42:38.503765	
5595	Kaushalya	9829641353	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:02:34.950067	4	2025-05-31 08:42:38.503765	
5018	gaadimech 	7023739916	2025-07-14 10:00:00	Needs Followup	Sail 3499 service package\r\n1000 ac chackup	2025-03-24 12:30:19.752762	4	2025-05-31 08:42:54.38585	
5568	gaadimech 	7014597017	2025-07-14 10:00:00	Needs Followup	Not pick	2025-04-07 08:21:12.415154	4	2025-05-31 08:42:54.38585	
469	Omprkash ji	9950107371	2025-07-14 10:00:00	Needs Followup	Abhi need nhi h	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
4966	Cx520	9350114982	2025-07-18 10:00:00	Needs Followup	Car service 	2025-03-24 04:58:31.075677	4	2025-05-31 08:43:10.854377	
5564	Cx640	9549070144	2025-07-18 10:00:00	Needs Followup	Eon ac\r\nOut of service 	2025-04-07 06:13:20.895265	4	2025-05-31 08:43:10.854377	
5565	Cx641	7903286743	2025-07-18 10:00:00	Needs Followup	Honda City \r\n25000	2025-04-07 06:14:07.909481	4	2025-05-31 08:43:10.854377	
5575	gaadimech 	9799651073	2025-07-19 10:00:00	Needs Followup	Not pick	2025-04-07 08:59:23.04957	4	2025-05-31 08:43:14.897002	
5581	Rakesh jain	9847053472	2025-07-19 10:00:00	Needs Followup	Not interested 	2025-04-07 11:53:08.091081	4	2025-05-31 08:43:14.897002	
5606	Ashish 	9829620289	2025-07-19 10:00:00	Needs Followup	Not interested 	2025-04-07 12:09:17.606929	6	2025-05-31 08:43:14.897002	
3037	Customer	9660581180	2025-07-04 10:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-13 09:02:24.989067	6	2025-05-31 08:42:14.037958	
5621	Rakesh jain 	9829603838	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:17:00.342508	6	2025-05-31 08:42:26.111514	
5622	Rakesh jain 	9829603838	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:17:19.954012	6	2025-05-31 08:42:26.111514	
3035	Customer	9784532569	2025-07-08 10:00:00	Needs Followup	Vitara Brezza 3455	2025-01-13 09:02:24.989067	4	2025-05-31 08:42:30.087566	
3030	Customer	7062878785	2025-07-08 10:00:00	Needs Followup	Call cut\r\nNot interested 	2025-01-13 09:02:24.989067	4	2025-05-31 08:42:30.087566	\N
5620	Jaspal	9829607003	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:16:28.276122	4	2025-05-31 08:42:38.503765	
3229	Customer 	8386050492	2025-07-15 10:00:00	Needs Followup	Ignis 2699	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:58.621937	
3252	.	9810400181	2025-07-15 10:00:00	Needs Followup	Creta 3199	2025-01-20 04:31:19.397625	4	2025-05-31 08:42:58.621937	
5376	Cx614	9887044445	2025-07-18 10:00:00	Needs Followup	Beleno service \r\n2899	2025-04-01 06:07:22.347555	6	2025-05-31 08:43:10.854377	
7830	gaadimech 	9352221902	2025-07-06 18:30:00	Needs Followup	Alto dent paint 	2025-07-02 07:22:41.248753	6	2025-07-02 07:22:41.248761	
7759	Cx3089	8905919219	2025-07-04 18:30:00	Needs Followup	Call end 	2025-06-30 04:45:09.090991	4	2025-07-03 13:22:17.66552	
3548	Cx242	9321558033	2025-07-03 18:30:00	Did Not Pick Up	Invalid No.	2025-01-31 04:20:51.980955	9	2025-07-05 08:01:46.330178	
7868	Cx4008	7339987350	2025-07-05 18:30:00	Did Not Pick Up	No answer 	2025-07-04 06:25:04.067293	4	2025-07-05 10:55:12.60396	
3164	Customer	9828860607	2025-07-21 10:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	4	2025-05-31 08:43:23.449024	
3154	Customer	9887650027	2025-07-09 10:00:00	Needs Followup	Baleno service done 	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:34.144665	\N
3432	.	9811299902	2025-07-21 10:00:00	Needs Followup	Not pick	2025-01-26 09:16:05.01535	4	2025-05-31 08:43:23.449024	
5024	gaadimech 	9694306021	2025-07-24 10:00:00	Needs Followup	Tata Tiago \r\nCall cut	2025-03-25 04:58:14.741974	4	2025-05-31 08:43:35.995616	
3152	Customer	9425166661	2025-07-02 10:00:00	Needs Followup	Not connect 	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:04.112745	
3189	Customer	8387951150	2025-07-02 10:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:04.112745	
3175	Customer	7014298042	2025-07-08 10:00:00	Needs Followup	Call cut 	2025-01-19 10:35:57.536291	6	2025-05-31 08:42:30.087566	
3180	Customer	8239656601	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	6	2025-05-31 08:42:30.087566	
3187	Customer	8005683020	2025-07-08 10:00:00	Needs Followup	Not interested \r\nNot pick 	2025-01-19 10:35:57.536291	6	2025-05-31 08:42:30.087566	
3159	Customer	9950876161	2025-07-15 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:58.621937	
3196	Customer	9205903850	2025-07-15 10:00:00	Needs Followup	Service is due 2 months ago \r\nI20 2699 service packege 5000 km due hai abhi 	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:58.621937	
3147	Customer	9351807577	2025-07-10 00:00:00	Did Not Pick Up	Free service due swift 	2025-01-19 09:01:07.792367	6	2025-01-29 07:19:53.505743	\N
225	Ritesh	7296838414	2025-07-30 18:30:00	Needs Followup	Swift 2799 ka sarvice pack 	2024-11-25 07:11:52	6	2025-07-01 11:45:10.314531	
7796	gaadimech 	9829339663	2025-07-03 18:30:00	Did Not Pick Up	Ciaz service not pick 	2025-07-01 05:45:53.630184	6	2025-07-02 09:05:26.857845	
7923	Cx4016	9772595353	2025-07-06 18:30:00	Needs Followup	Car paint 	2025-07-06 08:06:01.100281	4	2025-07-06 08:06:01.10029	
7924	Cx4017	9829541319	2025-07-06 18:30:00	Needs Followup	Etios paint	2025-07-06 08:06:28.09508	4	2025-07-06 08:06:28.095087	
1248	Avneet kour	9999905315	2025-07-14 18:30:00	Confirmed	Not picking 	2024-12-07 04:43:50	9	2025-07-01 10:18:42.432195	\N
3460	.	9799654996	2025-07-06 18:30:00	Needs Followup	Car service 	2025-01-26 09:16:05.01535	4	2025-07-02 12:55:36.167664	
3450	.	7665371760	2025-07-03 18:30:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	4	2025-07-02 13:24:49.052414	
3449	.	7742152759	2025-07-03 18:30:00	Needs Followup	call cut 	2025-01-26 09:16:05.01535	4	2025-07-02 13:28:29.647549	
3441	.	9555177765	2025-07-04 18:30:00	Needs Followup	Car service 	2025-01-26 09:16:05.01535	4	2025-07-02 13:32:02.331157	
3221	Customer 	9001900380	2025-07-24 10:00:00	Needs Followup	Not pick \r\nWagnor 2299\r\nHonda city 2999\r\nCall cut	2025-01-20 04:31:19.397625	4	2025-05-31 08:43:35.995616	
5025	gaadimech 	9829336866	2025-07-06 10:00:00	Needs Followup	Tata tiago 3199 	2025-03-25 05:11:39.419467	4	2025-05-31 08:42:22.030114	
5026	gaadimech 	7877333470	2025-07-27 10:00:00	Needs Followup	Eon ac checkup tonk road \r\nSelf call\r\nNit interested 	2025-03-25 05:19:37.22407	4	2025-05-31 08:43:47.842094	
3443	.	9251691172	2025-07-09 10:00:00	Needs Followup	Service done by company workshop	2025-01-26 09:16:05.01535	4	2025-05-31 08:42:34.144665	\N
3202	Customer	6350058093	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	4	2025-05-31 08:42:34.144665	
3440	.	9782892042	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	4	2025-05-31 08:42:58.621937	
3452	.	9971098314	2025-07-15 10:00:00	Needs Followup	Not requirement 	2025-01-26 09:16:05.01535	4	2025-05-31 08:42:58.621937	
3455	.	9664274561	2026-02-26 18:30:00	Did Not Pick Up	Ertiga new car	2025-01-26 09:16:05.01535	6	2025-02-27 09:42:36.194393	
3434	.	7221911446	2025-07-03 18:30:00	Did Not Pick Up	Not pick 	2025-01-26 09:16:05.01535	6	2025-06-29 09:40:41.263351	
7797	gaadimech	9649907860	2025-07-04 18:30:00	Did Not Pick Up	Octavia 5199	2025-07-01 05:51:30.064111	6	2025-07-02 09:03:36.595191	
7772	gaadimech	9784077014	2025-07-04 18:30:00	Did Not Pick Up	Xuv dent paint	2025-06-30 05:32:44.285772	6	2025-07-02 09:58:55.599921	
3474	.	9950066264	2025-07-09 18:30:00	Needs Followup	Abhi nahi 	2025-01-27 04:07:45.870122	4	2025-07-02 12:11:41.980531	
3471	.	9636776197	2025-07-21 10:00:00	Needs Followup	Mahindra berito	2025-01-27 04:07:45.870122	4	2025-05-31 08:43:23.449024	
3067	Customer	8209326863	2025-07-18 10:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-16 04:14:34.232859	4	2025-05-31 08:43:10.854377	
1186	Ravinder sir	9783321529	2025-07-14 10:00:00	Needs Followup	Hundai 2999  call back \r\nBusy call u letter\r\nNot pick	2024-12-06 08:38:44	6	2025-05-31 08:42:54.38585	
4980	gaadimech	9166711978	2025-07-18 10:00:00	Needs Followup	Not interested 	2025-03-24 07:34:28.580186	4	2025-05-31 08:43:10.854377	
3475	.	7340058444	2025-07-02 18:30:00	Did Not Pick Up	Baleno 2999	2025-01-27 04:07:45.870122	6	2025-06-29 09:38:31.846808	
3477	.	9166406526	2025-07-08 10:00:00	Needs Followup	Switch off 	2025-01-27 04:07:45.870122	6	2025-05-31 08:42:30.087566	
3560	.	7737991063	2025-07-08 10:00:00	Needs Followup	Call cut	2025-01-31 08:47:45.318294	6	2025-05-31 08:42:30.087566	
3060	Customer	7619701770	2025-07-31 00:00:00	Did Not Pick Up	Amaze 2899\r\nNot pick 	2025-01-16 04:14:34.232859	6	2025-02-07 07:50:10.012019	\N
3058	Customer	9887625921	2025-07-18 18:30:00	Did Not Pick Up	Not interested \r\nNot pick 	2025-01-16 04:14:34.232859	6	2025-06-29 10:54:00.660284	
2892	Customer	9116157101	2025-08-15 18:30:00	Needs Followup	Not pick \r\nNot pick\r\nDon't have car 	2025-01-12 04:36:11.819946	6	2025-06-29 10:55:36.404326	
7736	Cx3087	9571421835	2025-07-24 18:30:00	Needs Followup	Service 	2025-06-29 05:12:03.336736	4	2025-06-30 05:40:33.211292	
7798	gaadimech	9415417010	2025-11-13 18:30:00	Did Not Pick Up	Up 	2025-07-01 05:54:34.300602	6	2025-07-02 09:02:09.43554	
3562	.	9829065663	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-01-31 11:39:32.99819	4	2025-05-31 08:42:58.621937	
3564	.	9928642000	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-01-31 11:39:32.99819	4	2025-05-31 08:42:58.621937	
3280	manish	8000718073	2025-07-04 10:00:00	Needs Followup	Not pick\r\nCall cut	2025-01-21 08:47:29.498491	6	2025-05-31 08:42:14.037958	
3076	Customer	9001649122	2025-07-21 10:00:00	Needs Followup	Not connect 	2025-01-16 05:05:21.020106	4	2025-05-31 08:43:23.449024	
3563	.	9828079141	2025-07-21 10:00:00	Needs Followup	Not requirement 	2025-01-31 11:39:32.99819	4	2025-05-31 08:43:23.449024	
3567	.	9829012019	2025-07-08 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-01-31 11:39:32.99819	4	2025-05-31 08:42:30.087566	
5037	gaadimech 	9256600106	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-03-25 06:42:30.241943	4	2025-05-31 08:43:23.449024	
3001	Customer	9314654211	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-13 09:02:24.989067	4	2025-05-31 08:42:04.112745	
3283	.	6376450905	2025-07-02 10:00:00	Needs Followup	Call cut	2025-01-21 08:47:29.498491	4	2025-05-31 08:42:04.112745	
3284	.	8700194679	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot pick \r\nSwitch off	2025-01-21 08:47:29.498491	4	2025-05-31 08:42:04.112745	
3571	.	9314513967	2025-07-04 10:00:00	Needs Followup	Call cut	2025-01-31 11:39:32.99819	6	2025-05-31 08:42:14.037958	
3579	.	9828028065	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-01-31 11:39:32.99819	4	2025-05-31 08:42:30.087566	
3569	.	9849051300	2025-07-08 10:00:00	Needs Followup	Call cut	2025-01-31 11:39:32.99819	6	2025-05-31 08:42:30.087566	
3277	.	8295588859	2025-11-20 18:30:00	Needs Followup	Not requirement 	2025-01-21 08:47:29.498491	6	2025-02-13 11:10:04.13567	
3294	.	9829184863	2025-07-24 10:00:00	Needs Followup	Call cut	2025-01-21 10:55:25.845211	4	2025-05-31 08:43:35.995616	
3755	.	8769861554	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-05 08:55:58.705632	4	2025-05-31 08:43:35.995616	
3298	.	9829238594	2025-07-25 10:00:00	Needs Followup	Service done by other workshop 	2025-01-21 10:55:25.845211	4	2025-05-31 08:43:39.880052	\N
3761	.	9468592718	2025-07-05 10:00:00	Needs Followup	Not interested 	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:17.990214	
2372	.	9799641966	2025-07-10 18:30:00	Needs Followup	Car service 	2024-12-22 08:06:41.389566	4	2025-06-30 12:55:18.94524	
3747	.	9166102772	2025-07-02 18:30:00	Needs Followup	No answer 	2025-02-05 08:55:58.705632	4	2025-07-02 09:01:22.368912	
3586	.	9829924028	2025-07-05 10:00:00	Needs Followup	I10 ac checkup 	2025-02-01 04:09:42.798808	4	2025-05-31 08:42:17.990214	
7763	Cx3093	9829160678	2025-07-05 18:30:00	Needs Followup	Service \r\nCall cut	2025-06-30 04:47:49.185547	4	2025-07-04 08:42:19.933993	
3750	.	9694655912	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:17.990214	
3594	.	9784012326	2025-07-15 10:00:00	Needs Followup	Dzire dent paint 2200 \r\nSelf cal krenge	2025-02-01 04:09:42.798808	4	2025-05-31 08:42:58.621937	
3590	.	9001353060	2025-07-02 18:30:00	Needs Followup	No answers 	2025-02-01 04:09:42.798808	4	2025-07-02 11:23:21.72711	
3745	.	9887740392	2025-07-17 18:30:00	Did Not Pick Up	Call cut	2025-02-05 08:55:58.705632	6	2025-07-02 12:21:54.368408	
3748	.	9694400712	2025-07-07 10:00:00	Needs Followup	Call cut	2025-02-05 08:55:58.705632	6	2025-05-31 08:42:26.111514	
3759	.	6376337287	2025-08-06 18:30:00	Did Not Pick Up	Not pick 	2025-02-05 08:55:58.705632	6	2025-07-02 12:24:01.851508	
460	Lavi chudhray	9001041160	2025-07-02 10:00:00	Needs Followup	Abhi 1 mhine pahle sarvice hui h ab next sarvice pr c.back\r\nNot pick	2024-11-28 06:03:20	4	2025-05-31 08:42:04.112745	
7799	gaadimech 	9829113380	2025-07-04 18:30:00	Needs Followup	Santro 1999 	2025-07-01 06:02:33.352237	6	2025-07-01 06:02:33.352244	
3584	.	9782222514	2025-07-08 10:00:00	Needs Followup	Baleno dent paint 2200 per penal \r\nNew car hai requirement nahi h	2025-02-01 04:09:42.798808	4	2025-05-31 08:42:30.087566	
3736	.	7073864414	2025-07-08 10:00:00	Needs Followup	I20 2699\r\nVenue 2899\r\nService not Requirement 	2025-02-05 08:55:58.705632	6	2025-05-31 08:42:30.087566	
3738	.	9509197259	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-02-05 08:55:58.705632	6	2025-05-31 08:42:30.087566	
3742	.	9887567811	2025-07-15 10:00:00	Needs Followup	Not pick	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:58.621937	
3731	customer .	9166867668	2025-08-28 18:30:00	Did Not Pick Up	Audi A7 12000 service done	2025-02-05 08:03:10.877726	6	2025-03-22 09:32:44.110925	
3746	.	7877034088	2025-07-08 10:00:00	Needs Followup	Not requirement 	2025-02-05 08:55:58.705632	6	2025-05-31 08:42:30.087566	
3739	.	9899140066	2025-07-24 18:30:00	Did Not Pick Up	Cal cut	2025-02-05 08:55:58.705632	6	2025-07-02 12:24:27.695194	
3735	.	9602731852	2025-07-25 18:30:00	Did Not Pick Up	Call cut	2025-02-05 08:55:58.705632	6	2025-07-02 12:25:00.905511	
3082	Customer	9828293384	2025-07-21 10:00:00	Needs Followup	Wagnor 2299\r\nNot pick\r\n250 me wash kr do tab to aa jata hu	2025-01-16 08:25:50.621567	4	2025-05-31 08:43:23.449024	
3962	.	9829015975	2025-07-09 10:00:00	Needs Followup	Call cut not requirment 	2025-02-12 07:09:02.096886	4	2025-05-31 08:42:34.144665	
3305	Customer 	8875013365	2025-07-08 18:30:00	Did Not Pick Up	Not pick \r\n	2025-01-22 05:25:41.038653	6	2025-06-29 10:50:46.351283	
533	.	9351543169	2025-07-02 10:00:00	Needs Followup	Not pick	2024-11-28 12:42:48	4	2025-05-31 08:42:04.112745	
3730	.	9460389980	2025-07-24 10:00:00	Needs Followup	Not pick	2025-02-05 08:03:10.877726	4	2025-05-31 08:43:35.995616	
5017	gaadimech	9653938016	2025-07-24 10:00:00	Needs Followup	Not pick	2025-03-24 12:28:45.819171	4	2025-05-31 08:43:35.995616	
3081	Customer	9983636052	2025-07-01 18:30:00	Needs Followup	Audi suspension work\r\n	2025-01-16 08:25:50.621567	4	2025-06-30 10:29:49.608483	
3766	.	9950923740	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:17.990214	
3976	.	7588322085	2025-07-08 10:00:00	Needs Followup	Not required 	2025-02-12 09:25:29.735066	4	2025-05-31 08:42:30.087566	
3990	.	9116570017	2025-07-08 10:00:00	Needs Followup	Not pick	2025-02-12 10:19:59.572493	4	2025-05-31 08:42:30.087566	
4016	.	9469211921	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-02-12 11:48:59.240432	4	2025-05-31 08:42:30.087566	
3772	.	9460617918	2025-07-16 18:30:00	Needs Followup	Abhi koi car service nahi karwani 	2025-02-05 11:59:45.332338	4	2025-07-02 08:55:51.470017	
3775	.	9911997202	2025-07-08 18:30:00	Did Not Pick Up	Not pick	2025-02-05 11:59:45.332338	6	2025-07-02 12:20:18.020272	
3763	.	9257138010	2025-07-15 10:00:00	Needs Followup	Not connect	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:58.621937	
3768	.	8484084096	2025-07-15 10:00:00	Needs Followup	I10 1999\r\nSwitch off	2025-02-05 08:55:58.705632	4	2025-05-31 08:42:58.621937	
3757	.	8619513874	2025-07-24 18:30:00	Did Not Pick Up	Don't have car	2025-02-05 08:55:58.705632	6	2025-04-20 11:04:30.400736	
3773	.	9460617918	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-05 11:59:45.332338	6	2025-07-02 12:21:11.508407	
3303	Customer 	9352584776	2025-07-30 18:30:00	Did Not Pick Up	Duster service \r\nNot pick \r\nNot pick\r\nService done 	2025-01-22 05:25:41.038653	6	2025-05-16 11:26:04.075634	
3599	.	8104128261	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-01 08:10:35.762903	6	2025-07-02 12:42:09.969954	
7760	Cx3090	9950959813	2025-07-05 18:30:00	Needs Followup	Dent paint out off network \r\n	2025-06-30 04:45:44.931621	4	2025-07-04 09:04:43.281557	
4442	gaadimech	8114424289	2025-07-23 10:00:00	Needs Followup	Octavia 4599 package \r\nBhahr ye package mjhe 3000 me mil rha h\r\nCompany me service krwa li 	2025-02-28 12:17:17.918192	4	2025-05-31 08:43:31.574711	
1287	.	9811413919	2025-07-25 18:30:00	Did Not Pick Up	Cut a call \r\nNot pick\r\nNot pick\r\nNt required 	2024-12-07 05:46:09	6	2025-06-28 11:48:00.467299	
4247	.	9928557490	2025-07-05 10:00:00	Needs Followup	Baleno steering issue\r\nBusy call back after holi\r\nNot required 	2025-02-20 07:34:11.294231	4	2025-05-31 08:42:17.990214	
3770	.	9833220233	2025-08-15 18:30:00	Did Not Pick Up	Service done baleno	2025-02-05 08:55:58.705632	6	2025-06-29 09:26:47.719305	
3493	Cx240	7850904965	2025-07-10 00:00:00	Needs Followup	Call cut	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3583	.	8209626458	2025-07-03 18:30:00	Needs Followup	Grand i10 dent paint per penal 2000	2025-02-01 04:09:42.798808	4	2025-07-02 11:20:32.113837	
4354	gaadimech 	9672601401	2025-07-09 10:00:00	Needs Followup	Alto 800 not interested 	2025-02-25 05:04:52.654546	4	2025-05-31 08:42:34.144665	
4353	gaadimech	9311709986	2025-07-15 10:00:00	Needs Followup	Scross ac issue\r\nOut of jaipur	2025-02-25 05:00:45.233353	6	2025-05-31 08:42:58.621937	
4355	gaadimech 	8619670146	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-25 05:09:17.353313	6	2025-05-31 08:42:58.621937	
4578	gaadimech 7015592374	8003569537	2025-07-16 10:00:00	Needs Followup	Eon rubbing polishing nd drycleaning 1200 me hoti h bhahr 	2025-03-08 04:22:28.368101	4	2025-05-31 08:43:02.994951	
4580	gaadimech 	9680305337	2025-07-16 10:00:00	Needs Followup	Call cut\r\nAc compressor secnd hand 5500 or new 10500 price me mil rha h apke yaha 17000 jyada hai	2025-03-08 04:31:20.251739	4	2025-05-31 08:43:02.994951	
3473	.	8878642688	2025-07-03 18:30:00	Needs Followup	Car service 	2025-01-27 04:07:45.870122	4	2025-07-02 12:09:39.235702	
3003	Customer	7023634064	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-01-13 09:02:24.989067	4	2025-05-31 08:42:58.621937	
295	Raju sir	9929341002	2025-08-15 18:30:00	Needs Followup	Not requirement \r\nDon't have car\r\nScorpio 5199	2024-11-26 08:15:30	6	2025-06-28 11:48:45.394142	
3503	.	9876979597	2025-07-10 00:00:00	Did Not Pick Up	Dutson go coolenet nd parts change\r\nOther workshop done 👍	2025-01-28 08:30:23.304672	6	2025-02-04 05:11:30.568094	\N
4402	Cx590	9462164536	2025-07-05 10:00:00	Needs Followup	Creta 3199	2025-02-26 08:20:09.330337	4	2025-05-31 08:42:17.990214	
4456	Cx581	9571740504	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-02 06:07:19.288557	4	2025-05-31 08:42:17.990214	
4459	Cx586	9828987171	2025-07-06 10:00:00	Needs Followup	Ac service \r\nMagnet 1000	2025-03-02 06:11:24.012961	4	2025-05-31 08:42:22.030114	
4497	Cx909	9001030303	2025-07-06 10:00:00	Needs Followup	Dent paint 	2025-03-03 11:27:55.483175	4	2025-05-31 08:42:22.030114	
3729	.	8005505242	2025-07-08 10:00:00	Needs Followup	Wagnor 2199	2025-02-05 08:03:10.877726	4	2025-05-31 08:42:30.087566	
4463	Cx587	7021103383	2025-07-14 10:00:00	Needs Followup	Call cut 	2025-03-02 06:18:44.659959	4	2025-05-31 08:42:54.38585	
3545	.	9929889589	2025-07-15 10:00:00	Needs Followup	800 services \r\nOut of rajastha 	2025-01-31 04:20:51.980955	4	2025-05-31 08:42:58.621937	
4465	CX588	8058276375	2025-07-17 10:00:00	Needs Followup	Ac service \r\ni10\r\n	2025-03-02 06:20:41.545635	6	2025-05-31 08:43:06.869056	
3415	.	9983342628	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2025-01-26 09:16:05.01535	6	2025-06-29 09:42:38.934373	
3776	.	9416497049	2025-07-11 00:00:00	Needs Followup		2025-02-05 11:59:45.332338	9	2025-07-01 06:50:29.884428	\N
4457	Cx584	6367568944	2025-07-17 10:00:00	Needs Followup	Dzire \r\nAc service 	2025-03-02 06:08:22.279357	4	2025-05-31 08:43:06.869056	
4460	Cx586	7665532513	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-02 06:11:55.948556	4	2025-05-31 08:43:06.869056	
4462	Cx587	9672124286	2025-07-17 10:00:00	Needs Followup	Wr ac service 	2025-03-02 06:13:35.43256	6	2025-05-31 08:43:06.869056	
395	 C.R godha	9828246404	2025-10-16 18:30:00	Needs Followup	Amaze done service 	2024-11-27 07:21:40	6	2025-07-01 11:19:00.921547	
7774	gaadimech	9610689925	2025-07-25 18:30:00	Needs Followup	Maruti van 2899\r\nCall cut	2025-06-30 06:04:12.9822	6	2025-07-02 09:55:47.936224	
4018	.	8005573173	2025-07-30 18:30:00	Needs Followup	Punto 2899 not interested 	2025-02-12 11:53:19.967324	6	2025-07-02 11:35:45.333046	
3798	deep ji	8619363811	2025-07-16 18:30:00	Feedback	Swift package 2799\r\nService 5000 pay amount \r\n\r\nDay 1 11/02/2025  service achi hai 	2025-02-07 04:30:18.562584	6	2025-05-30 11:54:09.419398	RJ45CY0968
289	.	9462575853	2025-07-18 18:30:00	Did Not Pick Up	What's app details share \r\nService alredy done \r\nVento \r\nNot interested 	2024-11-26 06:10:47	6	2025-06-28 11:51:57.355808	
2924	Customer	9799296363	2026-01-30 00:00:00	Did Not Pick Up	Not pick \r\nNot pick\r\nNew car tata nexon	2025-01-12 04:36:11.819946	6	2025-01-23 06:49:13.153958	\N
3543	.	8239052891	2025-07-15 10:00:00	Needs Followup	Nexon dent paint 2500 per penal \r\nCompany se ktwa liya	2025-01-31 04:20:51.980955	4	2025-05-31 08:42:58.621937	
3600	.	8209124617	2025-07-05 10:00:00	Needs Followup	Vitara brezza 3299	2025-02-01 11:28:10.789574	4	2025-05-31 08:42:17.990214	
4831	customer 	9829031100	2025-07-21 10:00:00	Needs Followup	Brio 2399	2025-03-18 11:34:10.741397	4	2025-05-31 08:43:23.449024	
4890	.	7014853824	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-03-20 12:11:55.390841	4	2025-05-31 08:43:47.842094	
4526	ayush mathur ivr	6350041766	2025-07-17 18:30:00	Feedback	I10 1999 \r\nCOMPLETED \r\nTOTAL PAYMENT - 2825\r\nFEEDBACK \r\n27/03/2025 not pick\r\nCall cut 31/03/2025	2025-03-04 12:06:21.351893	6	2025-05-31 09:15:47.406958	RJ14CG4199
4524	Cx 922	8619265887	2025-07-06 10:00:00	Needs Followup	Washing aur ac service 	2025-03-04 11:49:48.016992	4	2025-05-31 08:42:22.030114	
4405	Cx562	9571665617	2025-07-05 10:00:00	Needs Followup	Car service 	2025-02-26 08:59:35.843594	4	2025-05-31 08:42:17.990214	
4407	Cx564	9799787387	2025-07-05 10:00:00	Needs Followup	Car service 	2025-02-26 09:01:35.695009	4	2025-05-31 08:42:17.990214	
4399	gaadimech 	9672646514	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-26 05:21:04.18618	4	2025-05-31 08:42:34.144665	
3575	.	9414041718	2025-07-14 10:00:00	Needs Followup	Not requirement 	2025-01-31 11:39:32.99819	4	2025-05-31 08:42:54.38585	
3986	gaadimech 	6376076489	2025-07-14 10:00:00	Needs Followup	Nexon 2899\r\nBolero	2025-02-12 10:11:18.795081	4	2025-05-31 08:42:54.38585	
5051	Keshav ji 	7792076131	2025-07-16 10:00:00	Needs Followup	Not interested for now 	2025-03-25 09:20:20.303489	4	2025-05-31 08:43:02.994951	
3969	.	9660431822	2025-07-30 00:00:00	Needs Followup	Not pick	2025-02-12 08:53:03.241788	9	2025-07-01 06:50:29.884428	
4030	.	9833300226	2025-07-03 18:30:00	Needs Followup	Call cut 	2025-02-15 07:43:56.812325	4	2025-07-02 08:45:07.377757	
4022	.	9314566491	2025-07-18 18:30:00	Did Not Pick Up	Call cit	2025-02-15 07:40:22.334042	6	2025-07-02 11:34:11.693412	
3812	.	8769238599	2025-07-05 18:30:00	Did Not Pick Up	Innova 4299	2025-02-07 04:30:18.562584	6	2025-07-02 12:18:52.183369	
3805	.	8209414432	2025-07-17 18:30:00	Needs Followup	Call cut\r\nNot requirement 	2025-02-07 04:30:18.562584	6	2025-07-02 12:19:42.89798	
3806	.	9351484904	2025-07-24 10:00:00	Needs Followup	Innova 2000 done by other workshop 	2025-02-07 04:30:18.562584	4	2025-05-31 08:43:35.995616	
3816	.	8947904052	2025-07-19 10:00:00	Needs Followup	Not pick 	2025-02-07 04:30:18.562584	4	2025-05-31 08:43:14.897002	
4026	.	9571035426	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-15 07:42:06.881086	4	2025-05-31 08:43:35.995616	
7171	Cx2006	7374942723	2025-07-26 10:00:00	Needs Followup	Dzire fender dent paint 	2025-05-14 07:11:00.794182	4	2025-05-31 08:43:43.903509	
7172	Cx2010	9829227511	2025-07-26 10:00:00	Needs Followup	Baleno digi dent paint 	2025-05-14 07:11:56.496377	4	2025-05-31 08:43:43.903509	
7758	Kwid ac service vki 	9829237786	2025-07-08 18:30:00	Needs Followup	Car service ke liye 	2025-06-30 04:44:33.041424	4	2025-07-01 06:49:22.245962	
3803	gaadimech 	8949624790	2025-07-26 10:00:00	Needs Followup	Amaze 3199	2025-02-07 04:30:18.562584	6	2025-05-31 08:43:43.903509	
4029	.	9799509447	2025-07-26 10:00:00	Needs Followup	Not interested 	2025-02-15 07:43:32.611212	6	2025-05-31 08:43:43.903509	
3808	.	7300072707	2025-07-09 10:00:00	Needs Followup	Vento drycleaning 	2025-02-07 04:30:18.562584	4	2025-05-31 08:42:34.144665	
4027	.	8769731912	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-15 07:42:48.394101	4	2025-05-31 08:42:17.990214	
3807	.	9415462719	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-02-07 04:30:18.562584	4	2025-05-31 08:42:58.621937	
3810	gaadimech	9928887684	2025-07-15 10:00:00	Needs Followup	Call cut\r\nK10	2025-02-07 04:30:18.562584	4	2025-05-31 08:42:58.621937	
3801	.	9413112697	2025-07-25 18:30:00	Did Not Pick Up	Service done 	2025-02-07 04:30:18.562584	6	2025-02-11 04:58:04.260464	
1800	.	9672359664	2025-07-25 18:30:00	Did Not Pick Up	Not interested 	2024-12-14 07:02:01	6	2025-06-28 11:44:22.189471	
7800	gaadimech 	9799476920	2025-07-03 18:30:00	Did Not Pick Up	Dzire 2999 busy call u later 	2025-07-01 06:50:12.48929	6	2025-07-02 08:59:16.740396	
3842	.	9828722088	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2025-02-07 09:03:50.545995	6	2025-07-02 12:18:25.117416	
3613	.	9829067111	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 08:44:54.392846	6	2025-07-02 12:39:17.376437	
3617	.	9829067809	2025-07-19 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 08:44:54.392846	6	2025-07-02 12:40:49.431887	
7055	gaadimech 	8440048113	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-05-10 05:07:27.526598	6	2025-05-31 08:43:27.624295	
3965	.	9928548523	2025-07-08 10:00:00	Needs Followup	Not pick \r\nMjhe service ki requirment nahi hai plz don't again call me	2025-02-12 07:13:09.04846	6	2025-05-31 08:42:30.087566	
3838	.	9019869480	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-07 09:03:50.545995	4	2025-05-31 08:42:17.990214	
7053	gaadimech 	9799938897	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-05-10 05:06:33.36115	4	2025-05-31 08:43:39.880052	
4359	gaadimech	9509543233	2025-07-27 10:00:00	Needs Followup	Not requirement need hui to self call kar lunga	2025-02-25 06:12:33.840995	4	2025-05-31 08:43:47.842094	
3840	.	7014893130	2025-07-09 10:00:00	Needs Followup	not pick	2025-02-07 09:03:50.545995	4	2025-05-31 08:42:34.144665	
5623	Hemant 	9838988638	2025-07-10 10:00:00	Needs Followup	Indica 3199	2025-04-07 12:17:57.172766	4	2025-05-31 08:42:38.503765	
4498	Cx909	8095785085	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-03 12:45:36.227977	6	2025-05-31 08:43:06.869056	
4470	Cx590	7689076905	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-02 08:14:13.988331	4	2025-05-31 08:42:17.990214	
4033	.	9314566491	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-15 07:45:12.780087	4	2025-05-31 08:42:34.144665	
5624	Karni	9838860915	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:18:28.284265	4	2025-05-31 08:42:38.503765	
5625	Prashant 	9835321810	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:19:06.328604	4	2025-05-31 08:42:38.503765	
5626	Prashant 	9835321810	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:27:32.863276	4	2025-05-31 08:42:38.503765	
5627	Customer 	9833180689	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:28:00.757882	4	2025-05-31 08:42:38.503765	
5628	Naresh 	9831451689	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:28:40.471668	4	2025-05-31 08:42:38.503765	
4031	.	9414059953	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-02-15 07:44:14.808497	6	2025-05-31 08:42:58.621937	
4409	gaadimech 	9828806509	2025-07-15 10:00:00	Needs Followup	Baleno 2599 Banipark visit krenge\r\nCall cut\r\nBoard exam me busy hai time milne ke bad contact krenge	2025-02-26 10:44:24.812987	6	2025-05-31 08:42:58.621937	
4530	ivr	7568877001	2025-07-15 10:00:00	Needs Followup	Honda city 2999 call back	2025-03-04 12:10:38.288767	6	2025-05-31 08:42:58.621937	
3631	.	9799394501	2025-07-03 18:30:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	4	2025-07-02 09:20:33.996774	
1618	Dharmver ji	9782746360	2025-07-29 18:30:00	Confirmed	Nhi krwani 	2024-12-10 05:43:58	9	2025-07-02 04:13:33.707311	\N
3621	.	9414079778	2025-07-18 18:30:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	6	2025-07-02 12:35:03.303066	
5055	Manish g	9414207604	2025-07-03 10:00:00	Needs Followup	Asked me to call back later on Monday 	2025-03-25 11:26:32.998392	4	2025-05-31 08:42:09.584832	
3624	.	9829092723	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 10:46:12.681522	6	2025-07-02 12:36:31.085819	
3626	.	9829050003	2025-07-11 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 10:46:12.681522	6	2025-07-02 12:37:28.307062	
3639	.	9314965287	2025-07-21 10:00:00	Needs Followup	Service done \r\nCall cut	2025-02-02 10:46:12.681522	4	2025-05-31 08:43:23.449024	
3643	.	9828090509	2025-07-26 10:00:00	Needs Followup	Not pick	2025-02-02 10:46:12.681522	6	2025-05-31 08:43:43.903509	
3644	.	9352850005	2025-07-08 10:00:00	Needs Followup	call cut	2025-02-02 10:46:12.681522	6	2025-05-31 08:42:30.087566	
3358	customer 	9828114161	2025-07-02 10:00:00	Needs Followup	Nexon dant paint 2200 per penal 	2025-01-24 04:17:20.62172	4	2025-05-31 08:42:04.112745	
3850	.	8708562932	2025-07-08 10:00:00	Needs Followup	Scooty h	2025-02-07 09:03:50.545995	6	2025-05-31 08:42:30.087566	
3629	.	9829063632	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	4	2025-05-31 08:42:17.990214	
3630	.	9314525121	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	4	2025-05-31 08:42:17.990214	
3853	.	9570513029	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-07 09:03:50.545995	4	2025-05-31 08:42:17.990214	
5631	Saurabh 	9829999910	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:32:08.686344	4	2025-05-31 08:42:38.503765	
3345	Customer 	9660794438	2025-07-15 10:00:00	Needs Followup	Dzire ambika automobile \r\nNot pick\r\n	2025-01-24 04:17:20.62172	4	2025-05-31 08:42:58.621937	
3845	.	9602030706	2026-01-31 00:00:00	Did Not Pick Up	Free service 	2025-02-07 09:03:50.545995	6	2025-02-07 09:03:50.546021	\N
3641	.	9414279553	2025-07-15 10:00:00	Needs Followup	Not pick	2025-02-02 10:46:12.681522	4	2025-05-31 08:42:58.621937	
3851	.	9414252548	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-07 09:03:50.545995	6	2025-05-31 08:42:58.621937	
2716	Radhashyan	8949446297	2025-07-25 18:30:00	Did Not Pick Up	Brezza 3299 package share\r\nNot pick 	2025-01-08 11:00:12.657946	6	2025-05-23 12:26:14.83071	
7058	gaadimech 	9549050708	2025-07-22 10:00:00	Needs Followup	Etios 999 ac	2025-05-10 05:09:23.40673	6	2025-05-31 08:43:27.624295	
3650	.	9414689665	2025-07-26 10:00:00	Needs Followup	Switch off\r\nCall cut	2025-02-02 10:46:12.681522	6	2025-05-31 08:43:43.903509	
3656	.	9887066633	2025-07-26 10:00:00	Needs Followup	Don't have car 	2025-02-02 10:46:12.681522	6	2025-05-31 08:43:43.903509	
3872	.	9828023228	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-07 10:20:37.99656	6	2025-06-30 10:00:39.695257	
4582	gaadimech 	9758795679	2025-07-27 10:00:00	Needs Followup	Mene koi inquiry nahi ki by mistake ho gyae hogi	2025-03-08 04:39:53.24964	4	2025-05-31 08:43:47.842094	
4035	.	9116094580	2025-07-25 18:30:00	Did Not Pick Up	Not pick 	2025-02-15 08:18:12.212632	6	2025-07-02 11:17:22.637425	
3856	.	9024261312	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-07 09:03:50.545995	6	2025-07-02 11:50:46.859474	
3648	.	9828122302	2025-07-25 18:30:00	Did Not Pick Up	Call cut	2025-02-02 10:46:12.681522	6	2025-07-02 12:33:04.491065	
3647	.	9829011470	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 10:46:12.681522	6	2025-07-02 12:34:17.58177	
3360	Punch 	9001159595	2025-12-18 18:30:00	Confirmed	Free services ho chuki	2025-01-24 08:53:51.25089	9	2025-07-01 07:30:51.519428	\N
4532	Cx921	6375745669	2025-07-05 10:00:00	Needs Followup	in coming nahi \r\nVoice call 	2025-03-05 08:50:01.302336	4	2025-05-31 08:42:17.990214	
4583	gaadimech 	9950605585	2025-08-13 18:30:00	Did Not Pick Up	Scorpio service 4699\r\nCall cut\r\nNot interested 	2025-03-08 04:45:36.464066	6	2025-05-05 07:38:22.54226	
4038	.	9351003820	2025-07-08 10:00:00	Needs Followup	Not pick 	2025-02-15 08:33:31.18708	6	2025-05-31 08:42:30.087566	
3645	.	9829005050	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	4	2025-05-31 08:42:34.144665	
3857	.	8696733082	2025-07-09 10:00:00	Needs Followup	Call cut	2025-02-07 09:03:50.545995	4	2025-05-31 08:42:34.144665	
4446	Cx584	9717416621	2025-07-13 10:00:00	Needs Followup	Car service 	2025-03-01 05:27:08.461137	6	2025-05-31 08:42:50.438237	
3646	.	9784742197	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	4	2025-05-31 08:42:54.38585	
4535	Cx930	7068749846	2025-07-17 10:00:00	Needs Followup	in coming nahi nahi\r\nOnly voice call	2025-03-05 08:52:19.856982	6	2025-05-31 08:43:06.869056	
4537	Cx933	9829727152	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-05 08:53:43.001118	6	2025-05-31 08:43:06.869056	
4037	.	7877308283	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-15 08:33:15.410155	6	2025-05-31 08:42:58.621937	
4528	ivr	7240070440	2025-07-15 10:00:00	Needs Followup	Mobilo 2999\r\nSharp motors ki service achi nhi lagi islye me khud nhi aaunga na kisi ko preference karunga	2025-03-04 12:07:53.092229	6	2025-05-31 08:42:58.621937	
5063	gaadimech 	7877665245	2025-07-30 18:30:00	Did Not Pick Up	Inquiry ki h self call karenge\r\nNot pick \r\nNot interested 	2025-03-26 05:09:40.590183	6	2025-05-05 11:50:56.298571	
4040	.	9782211383	2025-07-24 18:30:00	Did Not Pick Up	Eco sport 3199\r\nService done by company workshop 	2025-02-15 08:38:23.870744	6	2025-03-09 08:43:14.589389	
5066	gaadimech 	9509403529	2025-07-27 10:00:00	Needs Followup	I10 2299\r\nNot pick	2025-03-26 05:16:59.235381	4	2025-05-31 08:43:47.842094	
3615	.	9829013159	2025-07-06 18:30:00	Needs Followup	Abhi nahi karwani	2025-02-02 08:44:54.392846	4	2025-06-30 08:04:20.130569	
3870	.	8979995959	2025-07-05 10:00:00	Needs Followup	Switch off 	2025-02-07 10:20:37.99656	4	2025-05-31 08:42:17.990214	
3862	vinod kumar meena	9351808743	2025-07-10 18:30:00	Did Not Pick Up	Amaze 2899\r\nCall cut	2025-02-07 09:03:50.545995	6	2025-07-02 11:49:56.653953	
3889	.	8442070916	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-07 10:20:37.99656	4	2025-05-31 08:42:17.990214	
5064	gaadimech 	7976905505	2025-07-06 10:00:00	Needs Followup	Celerio 2699\r\nErtiga 3399 \r\nApril mid week	2025-03-26 05:10:36.976454	4	2025-05-31 08:42:22.030114	
3888	.	9252279720	2025-07-08 10:00:00	Needs Followup	Call cut	2025-02-07 10:20:37.99656	4	2025-05-31 08:42:30.087566	
3380	.	9335983789	2025-07-03 18:30:00	Needs Followup	Call cut	2025-01-25 04:07:13.578442	4	2025-07-02 13:41:07.506581	
3864	.	9370529265	2025-07-08 10:00:00	Needs Followup	Don't have car	2025-02-07 09:03:50.545995	6	2025-05-31 08:42:30.087566	
3874	.	8209236122	2025-07-15 10:00:00	Needs Followup	Call cut\r\nNot interested 	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:58.621937	
3891	.	9928322080	2025-07-08 10:00:00	Needs Followup	Not pick \r\nCall vut	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:30.087566	
7061	Cx1176	8239465494	2025-07-28 10:00:00	Needs Followup	Baleno service 	2025-05-10 07:18:00.279162	4	2025-05-31 08:43:51.744985	
3383	.	6376413674	2025-07-01 18:30:00	Needs Followup	Amanya hai 	2025-01-25 04:07:13.578442	4	2025-07-02 13:43:36.4174	
3879	.	8094665362	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:58.621937	
3880	.	9829288231	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:58.621937	
64	KAPIL JI 	7665992344	2025-12-19 18:30:00	Feedback	kwid servicing	2024-11-23 11:06:13	9	2025-07-01 07:32:56.066787	RJ19CF5841
3886	.	9460789138	2025-07-15 10:00:00	Needs Followup	Not requirement 	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:58.621937	
3877	.	7742299971	2025-07-30 18:30:00	Did Not Pick Up	Don't have car	2025-02-07 10:20:37.99656	6	2025-05-09 07:31:29.351039	
3893	.	8003730630	2025-07-18 00:00:00	Did Not Pick Up	Service done last month	2025-02-07 10:20:37.99656	6	2025-02-07 10:20:37.996587	
3882	.	9166873855	2026-02-20 18:30:00	Did Not Pick Up	New car hai 	2025-02-07 10:20:37.99656	6	2025-02-28 10:08:30.677225	
4262	CX 513	8104159995	2025-07-17 10:00:00	Needs Followup	Car service 	2025-02-21 12:26:59.941183	4	2025-05-31 08:43:06.869056	
5071	gaadimech 	9425092584	2025-07-14 10:00:00	Needs Followup	Out of station	2025-03-26 05:55:54.200754	4	2025-05-31 08:42:54.38585	
4051	.	9378010378	2025-08-28 18:30:00	Did Not Pick Up	Not required alredy service done	2025-02-15 10:09:21.315005	6	2025-05-16 07:47:40.955598	
4067	.	7414804880	2025-07-21 10:00:00	Needs Followup	Call cut	2025-02-15 11:02:13.339909	4	2025-05-31 08:43:23.449024	
4075	.	7777007981	2025-07-03 10:00:00	Needs Followup	Whatsap call cut	2025-02-15 11:22:42.076246	4	2025-05-31 08:42:09.584832	
4078	.	7976497828	2025-07-21 10:00:00	Needs Followup	Switch off 	2025-02-15 11:51:40.529579	4	2025-05-31 08:43:23.449024	
4080	.	8955961007	2025-07-03 10:00:00	Needs Followup	Honda city next month call back	2025-02-15 11:58:05.234086	4	2025-05-31 08:42:09.584832	
4042	.	9785077717	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-15 09:48:40.242974	4	2025-05-31 08:42:17.990214	
5068	gaadimech 	7340555374	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-03-26 05:23:55.348828	4	2025-05-31 08:43:35.995616	
4052	.	9660727360	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-15 10:11:05.85786	4	2025-05-31 08:42:17.990214	
4050	.	9829095170	2025-07-07 10:00:00	Needs Followup	Call cut	2025-02-15 10:07:57.274923	6	2025-05-31 08:42:26.111514	
4054	.	9001153247	2025-07-08 10:00:00	Needs Followup	Call cut	2025-02-15 10:13:32.462128	6	2025-05-31 08:42:30.087566	
4060	.	9887200677	2025-07-08 10:00:00	Needs Followup	Tiyago 2899\r\nBete se bat karke btayenge	2025-02-15 10:43:25.451633	6	2025-05-31 08:42:30.087566	
4059	.	8279053002	2025-07-09 10:00:00	Needs Followup	Wagnor visit karenge pahle 	2025-02-15 10:36:06.739533	4	2025-05-31 08:42:34.144665	
3887	.	8100006669	2025-07-25 18:30:00	Did Not Pick Up		2025-02-07 10:20:37.99656	6	2025-06-28 11:08:03.795533	
3890	.	9660937575	2025-07-11 18:30:00	Did Not Pick Up	Call cut\r\nNot interested 	2025-02-07 10:20:37.99656	6	2025-06-30 10:03:13.56543	
5070	gaadimech 	7300138046	2025-07-14 10:00:00	Needs Followup	I20 3399\r\nAlto 2399	2025-03-26 05:41:24.744285	4	2025-05-31 08:42:54.38585	
4061	.	8233947335	2025-07-18 10:00:00	Needs Followup	Not requirement 	2025-02-15 10:45:15.893617	4	2025-05-31 08:43:10.854377	
4062	.	8005682692	2025-07-04 18:30:00	Needs Followup	Grand vitara 2200 penal	2025-02-15 10:49:25.494997	6	2025-07-02 11:11:36.727989	
4064	.	9462930732	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-15 10:51:20.282257	6	2025-05-31 08:42:58.621937	
4068	.	7742830042	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-15 11:07:26.203645	6	2025-05-31 08:42:58.621937	
4076	.	8209216347	2025-07-18 10:00:00	Needs Followup	Ertiga 2899\r\nMany time call but call cut	2025-02-15 11:24:48.624605	4	2025-05-31 08:43:10.854377	
4072	.	9829078879	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-15 11:17:17.191352	6	2025-05-31 08:42:58.621937	
4073	.	7014131101	2025-07-15 10:00:00	Needs Followup	Not pick\r\nCall cut	2025-02-15 11:19:24.026822	6	2025-05-31 08:42:58.621937	
4082	.	8005747838	2025-07-15 10:00:00	Needs Followup	Etioes cross visit workshop claim \r\nNot interested 	2025-02-15 12:06:21.375667	6	2025-05-31 08:42:58.621937	
4367	Cx541	7568496068	2025-07-17 10:00:00	Needs Followup	Wrv \r\nCar service 3199	2025-02-25 09:12:55.308823	6	2025-05-31 08:43:06.869056	
4083	.	8441083978	2025-07-18 10:00:00	Needs Followup	Not requirement 	2025-02-15 12:09:39.891496	4	2025-05-31 08:43:10.854377	
4261	Cx511	9588935949	2025-07-18 10:00:00	Needs Followup	Tata harrier	2025-02-21 12:26:09.326503	4	2025-05-31 08:43:10.854377	
5072	Customer 	9602721909	2025-07-18 18:30:00	Needs Followup	Maruti beleno 2799	2025-03-26 05:59:12.298096	8	2025-04-27 04:45:36.70343	
4505	Etios Dent paint ke 	9783541812	2025-07-06 10:00:00	Needs Followup	Etios dent paint \r\n23000	2025-03-04 04:54:21.321527	4	2025-05-31 08:42:22.030114	
4608	gaadimech 	9079747250	2025-07-18 10:00:00	Needs Followup	Dzire 2499	2025-03-08 09:35:19.81053	4	2025-05-31 08:43:10.854377	
755	.	9928527140	2025-07-20 10:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	6	2025-05-31 08:43:19.077196	
3897	.	9887818848	2025-07-07 10:00:00	Needs Followup	Not interested \r\nCall cut	2025-02-07 10:20:37.99656	6	2025-05-31 08:42:26.111514	
7173	gaadimech 	8003579284	2025-07-22 10:00:00	Needs Followup	Eon 2299	2025-05-14 07:11:58.887335	6	2025-05-31 08:43:27.624295	
4590	gaadimech 	9251308076	2025-07-08 10:00:00	Needs Followup	Eco sport 3199\r\nCall back after eid \r\nNext sundy 	2025-03-08 05:26:08.129531	4	2025-05-31 08:42:30.087566	
4414	gaadimech 	7891082181	2025-07-08 10:00:00	Needs Followup	Mene koi inquiry nhi ki gaadimech.com par	2025-02-27 04:32:04.609288	4	2025-05-31 08:42:30.087566	
7064	gaadimech 	9314621260	2025-07-28 10:00:00	Needs Followup	Alto 2399	2025-05-10 07:22:01.581048	6	2025-05-31 08:43:51.744985	
7174	Cx2011	9588815404	2025-07-26 10:00:00	Needs Followup	Verna service 3399	2025-05-14 07:12:42.854162	4	2025-05-31 08:43:43.903509	
4412	gaadimech	6280204535	2025-07-27 10:00:00	Needs Followup	Car service pr de di  next time dekhenge 	2025-02-27 04:23:19.092278	4	2025-05-31 08:43:47.842094	
4594	gaadimech 	9351106161	2025-07-27 10:00:00	Needs Followup	Service done by other workshop 	2025-03-08 05:49:01.430995	4	2025-05-31 08:43:47.842094	
4603	gaadimech 	7792807868	2025-07-27 10:00:00	Needs Followup	Eon 1999\r\nNot required 	2025-03-08 06:51:05.942731	4	2025-05-31 08:43:47.842094	
4602	gaadimech 	7378161728	2025-07-16 10:00:00	Needs Followup	Etios ac checkup sharp motors \r\nCustomer compressor lekr aayenge	2025-03-08 06:46:35.165614	4	2025-05-31 08:43:02.994951	
4606	gaadimech 	9529369059	2025-07-27 10:00:00	Needs Followup	Ciaz ac checkup banipark\r\nNot interested compressor charge jyada hai\r\nNot interested 	2025-03-08 09:18:32.572292	4	2025-05-31 08:43:47.842094	
4084	ajit	9352687028	2025-07-08 10:00:00	Needs Followup	Customer denied not interested mene koi interest show nahi kia 	2025-02-16 07:10:23.883578	6	2025-05-31 08:42:30.087566	
4077	amit	9571118855	2025-07-18 18:30:00	Feedback	Mahindra logan 2999\r\n7700 cash\r\n	2025-02-15 11:34:33.70958	6	2025-06-28 11:07:19.076707	
4475	Safari Dent paint 	7742446960	2025-07-17 10:00:00	Needs Followup	Safari \r\nDent paint 	2025-03-02 11:49:35.872563	6	2025-05-31 08:43:06.869056	
4605	sujal	9602710332	2025-07-30 18:30:00	Feedback	Not picking 	2025-03-08 08:00:44.957343	9	2025-07-05 07:42:33.352262	
7647	gaadimech 	8619934118	2025-07-25 18:30:00	Did Not Pick Up	Baleno 2799 service done already 2 month back	2025-05-31 10:07:12.656733	6	2025-06-01 05:19:02.853774	
4447	sanjay sharma	9828083497	2025-07-14 10:00:00	Needs Followup	Wagnor 2399 tonk road\r\n	2025-03-01 06:51:11.79692	4	2025-05-31 08:42:54.38585	
4428	gaadimech	8005734890	2025-07-05 10:00:00	Needs Followup	Busy call u later 	2025-02-28 05:49:33.788525	4	2025-05-31 08:42:17.990214	
4501	Cx912	8302588740	2025-07-05 10:00:00	Needs Followup	Swift. \r\nSunday \r\nDrycleaning 	2025-03-04 04:49:49.034837	4	2025-05-31 08:42:17.990214	
3899	.	8005612446	2025-07-09 10:00:00	Needs Followup	Switch off	2025-02-07 12:25:47.929394	4	2025-05-31 08:42:34.144665	
4474	Cx590	6376366221	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-02 11:47:55.944958	4	2025-05-31 08:43:06.869056	
4503	Cx914	7414034686	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-04 04:52:01.728017	4	2025-05-31 08:42:17.990214	
4504	CX 915	8278621765	2025-07-05 10:00:00	Needs Followup	Venu ac \r\nService 	2025-03-04 04:53:19.252894	4	2025-05-31 08:42:17.990214	
7757	gaadimech 	7976447168	2025-10-17 18:30:00	Did Not Pick Up	Call cut\r\nService karwa li mene 	2025-06-29 11:55:20.827544	6	2025-06-30 06:27:58.178976	
4604	gaadimech 	9166623578	2025-07-09 10:00:00	Needs Followup	Dzire ac checkup 999	2025-03-08 06:56:35.202778	4	2025-05-31 08:42:34.144665	
4506	Cx914	9785371909	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-04 04:55:23.615722	4	2025-05-31 08:42:17.990214	
4593	mannu gaadimech 	9314517948	2025-07-05 10:00:00	Needs Followup	Etios 2899	2025-03-08 05:46:34.048046	6	2025-05-31 08:42:17.990214	
4085	mohan	7357964173	2025-07-15 10:00:00	Needs Followup	Not pick\r\nNot interested 	2025-02-16 07:12:05.946757	6	2025-05-31 08:42:58.621937	
4107	.	9829793000	2025-07-03 10:00:00	Needs Followup	Call cut	2025-02-16 10:26:51.02764	4	2025-05-31 08:42:09.584832	
4086	.	7988572883	2025-07-05 10:00:00	Needs Followup	Not connect 	2025-02-16 09:09:20.121898	4	2025-05-31 08:42:17.990214	
4092	.	9828073070	2025-07-08 10:00:00	Needs Followup	Swik 2999	2025-02-16 09:37:08.298621	4	2025-05-31 08:42:30.087566	
4088	.	9829007321	2025-07-05 10:00:00	Needs Followup	Not interested 	2025-02-16 09:12:18.024415	4	2025-05-31 08:42:17.990214	
4099	.	6386032322	2025-07-08 10:00:00	Needs Followup	Not interest \r\nDon't have car 	2025-02-16 10:08:56.323869	4	2025-05-31 08:42:30.087566	
4104	.	9983657585	2025-07-08 10:00:00	Needs Followup	Busy call cut	2025-02-16 10:19:17.400003	4	2025-05-31 08:42:30.087566	
7066	Cx1178	7737188349	2025-07-25 10:00:00	Needs Followup	Xuv 500	2025-05-10 08:13:53.421227	6	2025-05-31 08:43:39.880052	
4105	.	9314522525	2025-07-24 10:00:00	Needs Followup	Not requirement \r\nCall cut\r\nNot requirment 	2025-02-16 10:23:50.050244	4	2025-05-31 08:43:35.995616	
4091	.	9829241262	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-02-16 09:28:07.308707	4	2025-05-31 08:43:23.449024	
4089	.	7877648455	2025-07-08 10:00:00	Needs Followup	Don't have car 	2025-02-16 09:13:23.527396	6	2025-05-31 08:42:30.087566	
4101	.	9462177723	2025-07-21 10:00:00	Needs Followup	Switch off 	2025-02-16 10:15:25.842779	4	2025-05-31 08:43:23.449024	
4111	.	9829250038	2025-07-21 10:00:00	Needs Followup	Call cut	2025-02-16 10:41:11.090108	4	2025-05-31 08:43:23.449024	
4268	.	9251496300	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-02-22 04:49:22.912343	4	2025-05-31 08:43:23.449024	
4378	.	9079383035	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-02-25 11:26:00.252276	4	2025-05-31 08:43:23.449024	
4269	.	9314506780	2025-07-24 10:00:00	Needs Followup	Creta insurance claim sharp motors 	2025-02-22 04:51:37.496243	4	2025-05-31 08:43:35.995616	
5074	gaadimech 	9425092584	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-03-26 06:01:00.355074	4	2025-05-31 08:43:35.995616	
4097	.	9462729772	2025-07-08 10:00:00	Needs Followup	Not requirement 	2025-02-16 10:04:27.252299	6	2025-05-31 08:42:30.087566	
4098	.	9929737597	2025-07-08 10:00:00	Needs Followup	Call cut	2025-02-16 10:07:55.527039	6	2025-05-31 08:42:30.087566	
4087	.	9602075566	2025-07-09 10:00:00	Needs Followup	Not interested \r\nActiva hai	2025-02-16 09:11:05.365404	4	2025-05-31 08:42:34.144665	
4373	customer 	9782197827	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-25 11:18:24.746732	4	2025-05-31 08:42:34.144665	
4094	.	9314383980	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-02-16 09:42:52.21969	4	2025-05-31 08:42:54.38585	
4271	.	9214327567	2025-07-14 10:00:00	Needs Followup	March me visit krenge 	2025-02-22 04:56:15.233507	4	2025-05-31 08:42:54.38585	
4090	.	9829007292	2025-07-11 18:30:00	Needs Followup	Call cut busy	2025-02-16 09:26:22.326898	6	2025-06-30 09:55:24.827134	
4103	.	9314011327	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-16 10:18:05.424983	6	2025-05-31 08:42:58.621937	
4114	.	9414827357	2025-07-15 10:00:00	Needs Followup	Not requirement \r\nCall cut	2025-02-16 10:54:07.654873	6	2025-05-31 08:42:58.621937	
4117	.	9414045377	2025-07-15 10:00:00	Needs Followup	Not pick	2025-02-16 11:10:59.513769	6	2025-05-31 08:42:58.621937	
4267	gaadimech	9929698507	2025-07-15 10:00:00	Needs Followup	Dzire 2699 today sharp motor\r\nservice done	2025-02-22 04:37:25.631009	6	2025-05-31 08:42:58.621937	
4379	.	9636260046	2025-07-15 10:00:00	Needs Followup	Meecdies  not interested 	2025-02-25 11:27:02.809497	6	2025-05-31 08:42:58.621937	
3194	Customer	9057777677	2025-07-26 10:00:00	Needs Followup	Beat 2599 package share\r\nNext week out of jaipur \r\nMany time follow up karne ke bad service ke liye mana kia 	2025-01-19 10:35:57.536291	6	2025-05-31 08:43:43.903509	
4131	.	9887150756	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-16 12:10:35.080479	6	2025-06-30 09:47:09.247914	
4123	.	9829015701	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-02-16 11:56:23.970319	4	2025-05-31 08:43:23.449024	
4280	.	9887346078	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-22 05:49:27.892084	4	2025-05-31 08:42:17.990214	
4119	.	6378288403	2025-07-08 10:00:00	Needs Followup	Not requirement 	2025-02-16 11:54:49.782453	4	2025-05-31 08:42:30.087566	
4129	.	9351366696	2025-07-08 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-02-16 12:07:37.463351	4	2025-05-31 08:42:30.087566	
4130	.	9829017105	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-16 12:09:57.840552	4	2025-05-31 08:42:34.144665	
4277	.	8107564248	2025-07-09 10:00:00	Needs Followup	Ertiga 2899 siker se h	2025-02-22 05:39:14.961002	4	2025-05-31 08:42:34.144665	
4279	.	8949564388	2025-07-21 10:00:00	Needs Followup	Honda mobilo 2999  jagatpura	2025-02-22 05:46:12.357633	4	2025-05-31 08:43:23.449024	
4274	.	6350353310	2025-07-24 10:00:00	Needs Followup	Ac service pass wali shop par karwa li 	2025-02-22 05:27:49.444349	4	2025-05-31 08:43:35.995616	
4127	.	9829014916	2025-07-14 10:00:00	Needs Followup	Repid filhal requirement nahi hai hogi to bta denge	2025-02-16 12:01:07.873433	4	2025-05-31 08:42:54.38585	
4382	.	9694095962	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-25 11:31:41.864152	4	2025-05-31 08:43:35.995616	
4385	.	9413378584	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-25 11:36:19.072041	4	2025-05-31 08:43:35.995616	
4125	.	9829794561	2025-08-28 18:30:00	Did Not Pick Up	Not pick \r\nDon't again call	2025-02-16 11:57:09.572689	6	2025-05-16 10:44:17.397839	
4388	.	9314055999	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-25 11:49:27.279768	4	2025-05-31 08:43:35.995616	
4121	.	9887570785	2025-07-26 10:00:00	Needs Followup	Call cut\r\n	2025-02-16 11:55:31.642296	6	2025-05-31 08:43:43.903509	
4133	.	9352629593	2025-07-26 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-02-16 12:15:42.918785	6	2025-05-31 08:43:43.903509	
4281	gaadimech 	8005648810	2025-07-27 10:00:00	Needs Followup	Figo drycleaning 	2025-02-22 05:52:27.013703	4	2025-05-31 08:43:47.842094	
4387	.	9414050328	2025-07-27 10:00:00	Needs Followup	Call cut 	2025-02-25 11:43:13.999005	4	2025-05-31 08:43:47.842094	
7175	Cx2013	9982635568	2025-07-28 10:00:00	Needs Followup	Vki .dent paint 	2025-05-14 07:16:06.089631	6	2025-05-31 08:43:51.744985	
4374	.	7877797772	2025-07-18 18:30:00	Did Not Pick Up	Service done by other workshop 	2025-02-25 11:20:39.127963	6	2025-06-28 10:56:00.381024	
4118	.	7850974066	2025-07-11 18:30:00	Did Not Pick Up	Switch off 	2025-02-16 11:34:59.7674	6	2025-06-28 11:06:46.456801	
4113	.	9929664407	2025-07-24 18:30:00	Did Not Pick Up	Call cut\r\nNot interested 	2025-02-16 10:52:42.966623	6	2025-06-30 09:52:31.965682	
3903	Cx272	9829067777	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-08 09:16:58.786102	9	2025-07-01 06:50:29.884428	
5036	gaadimech 	9549919228	2025-07-21 10:00:00	Needs Followup	Altroz 3499 not pick 	2025-03-25 06:40:31.853537	4	2025-05-31 08:43:23.449024	
4303	customer 	9828017357	2025-07-23 10:00:00	Needs Followup	Past experience khrab tha isliye yha service nhi krwani 	2025-02-22 11:51:31.360127	4	2025-05-31 08:43:31.574711	
7726	gaadimech	9460286926	2025-07-02 18:30:00	Needs Followup	Grand i10 dent paint vki	2025-06-28 12:05:44.513586	6	2025-06-28 12:05:44.513594	
4306	customer 	9983487111	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-02-22 11:55:10.458308	4	2025-05-31 08:42:09.584832	
5079	Customer 	9680284617	2025-07-03 10:00:00	Needs Followup	Maruti desire:  2299\r\nI 20 : 2299 	2025-03-26 06:50:20.809755	6	2025-05-31 08:42:09.584832	
7071	Cx1182	9828188021	2025-07-25 10:00:00	Needs Followup	Car service 	2025-05-10 09:35:02.897581	6	2025-05-31 08:43:39.880052	
4316	Cx526	9881078813	2025-07-05 10:00:00	Needs Followup	In coming nahi hai \r\nVoice call 	2025-02-23 13:02:35.608521	4	2025-05-31 08:42:17.990214	
4314	Cx527	8769032642	2025-07-06 10:00:00	Needs Followup	Dent paint 	2025-02-23 12:50:27.920531	4	2025-05-31 08:42:22.030114	
4336	gaadimech	7976874298	2025-07-07 10:00:00	Needs Followup	Swift rubbing polishing \r\nCall cut	2025-02-24 05:01:00.14903	6	2025-05-31 08:42:26.111514	
4297	.	9666340741	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-22 11:26:41.125485	4	2025-05-31 08:42:34.144665	
4301	.	8387880878	2025-07-09 10:00:00	Needs Followup	Busy call u letter \r\nCall cut	2025-02-22 11:32:04.668558	4	2025-05-31 08:42:34.144665	
4292	.	7014744407	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-22 09:08:08.07173	6	2025-05-31 08:42:58.621937	
4295	.	8949632220	2025-07-15 10:00:00	Needs Followup	Dzire. Busy call later \r\nBhilwara se hai 	2025-02-22 09:58:43.625689	6	2025-05-31 08:42:58.621937	
4334	gaadimech	7877523290	2025-07-15 10:00:00	Needs Followup	Rent pr car chahiye	2025-02-24 04:54:59.494157	6	2025-05-31 08:42:58.621937	
4332	Cx542	8003964451	2025-07-17 10:00:00	Needs Followup	Car service 	2025-02-23 13:24:09.348937	4	2025-05-31 08:43:06.869056	
4304	customer 	7976162929	2025-07-15 18:30:00	Did Not Pick Up	Alredy other workshop done by company 	2025-02-22 11:52:08.435348	6	2025-02-28 06:44:36.763601	
4081	.	9602847443	2025-07-21 10:00:00	Needs Followup	Call cut 	2025-02-15 11:59:57.381078	4	2025-05-31 08:43:23.449024	
7073	Cx 1184	8949616218	2025-07-28 10:00:00	Needs Followup	Baleno 	2025-05-10 09:36:53.220783	6	2025-05-31 08:43:51.744985	
4287	.	9680814241	2025-07-25 18:30:00	Needs Followup	Dutson go 2299\r\nService done by other workshop \r\nNot pick 	2025-02-22 08:11:01.797787	6	2025-06-28 11:00:48.16159	
4556	gaadimech 8504014658	9401605487	2025-07-02 18:30:00	Needs Followup	Innova cresta dent paint \r\nCall end 	2025-03-07 08:46:43.954516	4	2025-07-02 07:58:01.127376	
4338	gaadimech 	9829322256	2025-07-19 18:30:00	Did Not Pick Up	Dzire service 2999	2025-02-24 05:07:22.500858	6	2025-06-28 12:06:48.832685	
4214	Cx 	9829066243	2025-07-03 18:30:00	Needs Followup	Car service \r\n	2025-02-18 12:04:57.304528	4	2025-07-02 08:07:37.009191	
5083	Devansh 	7877467780	2025-07-03 10:00:00	Needs Followup	Sonnet 3399	2025-03-26 07:13:49.551343	4	2025-05-31 08:42:09.584832	
4144	Cx402	9928766667	2025-07-05 10:00:00	Needs Followup	Car service 	2025-02-18 06:54:49.674124	4	2025-05-31 08:42:17.990214	
4435	Cx574	8955777710	2025-07-05 10:00:00	Needs Followup	Tuv 300\r\n4999\r\nService 	2025-02-28 07:58:03.513002	4	2025-05-31 08:42:17.990214	
4342	gaadimech	7014629763	2025-07-07 10:00:00	Needs Followup	Swift full body dent paint 	2025-02-24 09:13:27.690025	6	2025-05-31 08:42:26.111514	
4162	Cx422	9929781672	2025-07-17 10:00:00	Needs Followup	Dent paint 	2025-02-18 07:11:59.390196	4	2025-05-31 08:43:06.869056	
4203	.	8619519212	2025-07-21 10:00:00	Needs Followup	Call cut 	2025-02-18 11:45:53.926694	4	2025-05-31 08:43:23.449024	
4190	.	8947905050	2025-07-05 10:00:00	Needs Followup	I20 dent paint\r\n2200 per panel charge sharp motors 	2025-02-18 10:32:31.81401	4	2025-05-31 08:42:17.990214	
4211	.	7757008566	2025-07-05 10:00:00	Needs Followup	Not interested 	2025-02-18 12:02:12.173181	4	2025-05-31 08:42:17.990214	
4183	Cx453	7240070440	2025-07-06 10:00:00	Needs Followup	Alto service 	2025-02-18 10:04:51.507776	4	2025-05-31 08:42:22.030114	
4218	.	9314006474	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-02-18 12:10:13.595815	4	2025-05-31 08:43:23.449024	
4199	.	9829831034	2025-07-08 10:00:00	Needs Followup	Not requirement 	2025-02-18 11:40:11.679593	4	2025-05-31 08:42:30.087566	
4194	.	7073284250	2025-07-23 10:00:00	Needs Followup	Alto 1999 package\r\nService alredy done  normaly check kia 	2025-02-18 10:54:33.94972	4	2025-05-31 08:43:31.574711	
4193	ayusman	9982455284	2025-07-24 10:00:00	Needs Followup	Other workshop par service par de di	2025-02-18 10:52:06.923091	4	2025-05-31 08:43:35.995616	
4210	.	7014972248	2025-07-24 10:00:00	Needs Followup	Not interested 	2025-02-18 12:01:56.393578	4	2025-05-31 08:43:35.995616	
4216	.	9928579656	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-02-18 12:07:00.008451	4	2025-05-31 08:43:35.995616	
5080	Himmat Singh 	9829004555	2025-07-11 18:30:00	Did Not Pick Up	Not pick 	2025-03-26 07:01:04.438019	6	2025-06-28 10:07:25.077812	
4220	.	8890586767	2025-07-02 18:30:00	Needs Followup	Abhi nahi 	2025-02-18 12:15:03.207252	4	2025-06-28 10:32:51.079353	
4573	gaadimech	7568359614	2025-07-10 18:30:00	Needs Followup	Mercede	2025-03-07 10:13:43.619443	4	2025-07-02 07:53:49.76782	
7077	Cx1185	9588827242	2025-07-25 10:00:00	Needs Followup	Duster dent paint 25000	2025-05-10 09:40:21.732802	6	2025-05-31 08:43:39.880052	
4212	.	7757008566	2025-07-27 10:00:00	Needs Followup	Not interested 	2025-02-18 12:02:58.184147	4	2025-05-31 08:43:47.842094	
4204	.	9314500051	2025-07-09 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-02-18 11:47:30.503464	4	2025-05-31 08:42:34.144665	
4222	.	8741927756	2025-07-09 10:00:00	Needs Followup	Call cut 	2025-02-18 12:18:20.408809	4	2025-05-31 08:42:34.144665	
4187	Cx459	7240070440	2025-07-13 10:00:00	Needs Followup	Alto service 	2025-02-18 10:10:02.505822	6	2025-05-31 08:42:50.438237	
4208	.	9784974155	2025-07-14 10:00:00	Needs Followup	Switch off 	2025-02-18 11:57:41.336992	4	2025-05-31 08:42:54.38585	
4191	.	9636677728	2025-07-15 10:00:00	Needs Followup	Wagnor 2199 switch off\r\nNot pick many time call	2025-02-18 10:35:43.894117	6	2025-05-31 08:42:58.621937	
3860	.	8107864122	2025-07-03 18:30:00	Needs Followup	Call cut 	2025-02-07 09:03:50.545995	4	2025-07-02 08:52:01.987656	
4196	.	8696778005	2025-07-15 10:00:00	Needs Followup	Not connect \r\n	2025-02-18 11:07:32.128754	6	2025-05-31 08:42:58.621937	
4347	Aman ji Alto 	7240070440	2025-07-10 18:30:00	Completed	Not picking 	2025-02-24 13:37:54.16783	9	2025-07-01 08:58:54.055569	
4438	Cx577	8871477698	2025-07-06 10:00:00	Needs Followup	Baleno service 2499	2025-02-28 08:01:10.72659	4	2025-05-31 08:42:22.030114	
4479	Cx893	9782345839	2025-07-17 10:00:00	Needs Followup	Brezza car service 	2025-03-03 05:51:09.230152	6	2025-05-31 08:43:06.869056	
5632	Phool Chand 	9829992941	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:35:28.985872	4	2025-05-31 08:42:38.503765	
4227	.	9983947895	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-19 05:01:37.805589	4	2025-05-31 08:42:34.144665	
4226	.	9828801013	2025-07-25 18:30:00	Did Not Pick Up	Gangapur city se hai jaipur aaye to contact krenge Dzire 2699	2025-02-19 04:59:49.228336	6	2025-05-16 10:46:01.164147	
3945	.	9828531418	2025-07-15 10:00:00	Needs Followup	I10 dent paint\r\nTime milte hi visit karenge 	2025-02-11 05:19:28.695162	6	2025-05-31 08:42:58.621937	
4478	Cx892	8764665780	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-03 05:44:19.217913	4	2025-05-31 08:42:22.030114	
5087	Shekhawat 	9799462460	2025-07-18 18:30:00	Needs Followup	Baleno 2799\r\nI10 2299 call cut	2025-03-26 07:33:22.279174	6	2025-06-28 09:22:04.486704	
5085	Saurabh nagpal	9820505380	2025-07-10 18:30:00	Did Not Pick Up	Not interested \r\nNot pick 	2025-03-26 07:20:30.429017	6	2025-06-28 10:03:32.322737	
4221	.	9001993995	2025-07-18 18:30:00	Did Not Pick Up	Call cut\r\nNot requirement 	2025-02-18 12:16:03.519383	6	2025-06-28 11:06:03.720482	
3466	.	9571129075	2025-07-10 18:30:00	Did Not Pick Up	Self call karenge till not requirment 	2025-01-27 04:07:45.870122	6	2025-06-30 10:18:58.672309	
5086	Customer 	9414771276	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-26 07:31:22.086487	4	2025-05-31 08:42:14.037958	
4567	CX 943	6375669072	2025-07-06 10:00:00	Needs Followup	Swift \r\nFree service 	2025-03-07 10:00:18.868917	4	2025-05-31 08:42:22.030114	
3848	.	9672615087	2025-07-03 18:30:00	Needs Followup	Call cut	2025-02-07 09:03:50.545995	4	2025-07-02 08:53:44.890295	
4231	.	9799024940	2025-07-05 10:00:00	Needs Followup	Not connect 	2025-02-19 05:12:52.294449	4	2025-05-31 08:42:17.990214	
4510	Cx917	8005947634	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-04 05:12:55.877797	4	2025-05-31 08:42:17.990214	
4561	gaadimech 	9829514367	2025-07-16 10:00:00	Needs Followup	By mistake check ho gya tha plz again cal na kare	2025-03-07 09:04:32.429304	4	2025-05-31 08:43:02.994951	
4543	Cx936	9166172074	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-05 09:21:40.914681	6	2025-05-31 08:42:17.990214	
4509	Cx918	9414179312	2025-07-17 10:00:00	Needs Followup	Ac gas Bolero 	2025-03-04 05:08:08.811011	6	2025-05-31 08:43:06.869056	
4570	Skoda 4300	9929779698	2025-07-06 10:00:00	Needs Followup	Skoda 4399	2025-03-07 10:10:33.522375	6	2025-05-31 08:42:22.030114	
4224	.	9950793821	2025-07-15 10:00:00	Needs Followup	Vitara Brezza 2999\r\nSawai madhopur se service karwayenge	2025-02-19 04:45:20.052231	6	2025-05-31 08:42:58.621937	
4566	Cx942	8290475121	2025-07-05 10:00:00	Needs Followup	Alto car service 	2025-03-07 09:53:20.734975	6	2025-05-31 08:42:17.990214	
4572	Cx948	9982473303	2025-07-05 10:00:00	Needs Followup	Kwid  2699	2025-03-07 10:13:33.391089	6	2025-05-31 08:42:17.990214	
4574	Cx948	8000330902	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-07 10:14:36.940993	6	2025-05-31 08:42:17.990214	
4575	Cx949	8104283066	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-07 10:17:43.513505	6	2025-05-31 08:42:17.990214	
4233	.	8559818101	2025-07-15 10:00:00	Needs Followup	I10 rubbing polishing drycleaning \r\nNot required customer ne drycleaning home service me karwa li 	2025-02-19 05:30:02.755139	6	2025-05-31 08:42:58.621937	
4416	gaadimech	8058205747	2025-07-15 10:00:00	Needs Followup	Kwid 2199\r\nDent paint 2000 per panel charge \r\nRamzan ki wajh se busy h khud contact krenge 	2025-02-27 04:52:46.111717	6	2025-05-31 08:42:58.621937	
4449	customer 	9314938773	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-03-01 08:23:09.716601	6	2025-05-31 08:42:58.621937	
7047	Cx1172	9660242492	2025-07-20 10:00:00	Needs Followup	Dent paint 	2025-05-09 04:42:02.406031	6	2025-05-31 08:43:19.077196	
4421	gaadimech	9829214782	2025-07-24 10:00:00	Needs Followup	Duster Suspension work 	2025-02-27 05:16:20.663923	4	2025-05-31 08:43:35.995616	
7177	Sonnet 	9928013588	2025-07-26 10:00:00	Needs Followup	Dent paint sharp motor 	2025-05-14 07:17:34.133154	4	2025-05-31 08:43:43.903509	
7079	Cx1186	9928320976	2025-07-28 10:00:00	Needs Followup	Creta dent paint	2025-05-10 09:41:51.596282	6	2025-05-31 08:43:51.744985	
5091	ggadimech	9414458957	2025-07-14 10:00:00	Needs Followup	Tiago 3199	2025-03-26 09:02:33.227561	4	2025-05-31 08:42:54.38585	
4576	Cx950	7877523449	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-07 10:19:08.560293	6	2025-05-31 08:43:06.869056	
4480	Cx893	9773312349	2025-07-17 10:00:00	Needs Followup	Dent paint 	2025-03-03 05:57:22.406578	4	2025-05-31 08:43:06.869056	
4483	Cx895	9147148205	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-03 05:59:39.234353	4	2025-05-31 08:43:06.869056	
4484	Cx896	8107172862	2025-07-17 10:00:00	Needs Followup	Caiz rubbing \r\n1500\r\nAjmer road 	2025-03-03 06:00:28.195952	4	2025-05-31 08:43:06.869056	
4620	Cx489	9887190428	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-09 10:43:34.33986	6	2025-05-31 08:43:06.869056	
4511	Cx916	8302419608	2025-07-06 10:00:00	Needs Followup	Baleno 2499	2025-03-04 07:29:17.826005	4	2025-05-31 08:42:22.030114	
4512	Cx917	9929934884	2025-07-06 10:00:00	Needs Followup	Alto ac gas 	2025-03-04 07:29:57.693034	4	2025-05-31 08:42:22.030114	
4515	Cx919	8955993716	2025-07-06 10:00:00	Needs Followup	Car service \r\n\r\n\r\n\r\nCar service \r\n\r\n	2025-03-04 07:35:48.629058	4	2025-05-31 08:42:22.030114	
4450	Vishal nair	9001530306	2025-07-24 18:30:00	Did Not Pick Up	Car insurance claim \r\nNot interested 	2025-03-01 09:03:38.850448	6	2025-03-08 08:07:29.957763	
5088	Customer 	9970266776	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2025-03-26 08:43:32.449765	6	2025-06-28 09:19:24.72043	
4398	gaadimech 	9413489898	2025-07-23 18:30:00	Needs Followup	Wagnor 2000 dent paint per panel	2025-02-26 05:19:04.20933	4	2025-06-28 09:32:40.124876	
4448	gourav ji	9828574365	2025-07-25 18:30:00	Feedback	Kwid service total payment 5600\r\n\r\nDay 1  8/03/2025 not pick\r\nDay 2  11/03/2025 satisfied customer \r\n	2025-03-01 07:04:12.083932	6	2025-06-29 09:18:26.949767	RJ45CD9348
3658	Cx252	8741001102	2025-07-07 00:00:00	Needs Followup	Alto service 1999	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	\N
3975	.	9799228071	2025-07-05 10:00:00	Needs Followup	Not pick	2025-02-12 09:20:18.421586	4	2025-05-31 08:42:17.990214	
4513	i10 old 1999	6350041766	2025-07-05 10:00:00	Needs Followup	i10 1999\r\nAjmer road 	2025-03-04 07:30:54.595112	4	2025-05-31 08:42:17.990214	
4351	gaadimech	9891865643	2025-07-03 18:30:00	Needs Followup	Call cut	2025-02-25 04:47:20.288421	4	2025-07-02 08:03:13.231224	
4516	Cx920	8955993716	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-04 07:36:37.202932	4	2025-05-31 08:42:22.030114	
4577	Cx951	7627025781	2025-07-05 10:00:00	Needs Followup	Service aur Dent  	2025-03-07 10:20:15.419758	6	2025-05-31 08:42:17.990214	
4611	gaadimech 	8078608150	2025-07-05 10:00:00	Needs Followup	Dzire 2599 	2025-03-08 09:50:31.862701	6	2025-05-31 08:42:17.990214	
4619	Cx948	9636046176	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-09 10:31:58.757958	6	2025-05-31 08:42:17.990214	
4622	Cx481	7733838379	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-09 10:45:59.003809	6	2025-05-31 08:42:17.990214	
4623	Cx481	9782896424	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-09 10:47:05.326133	6	2025-05-31 08:42:17.990214	
4548	Cx940	6206534277	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-05 09:57:01.60827	4	2025-05-31 08:42:22.030114	
4621	Cx480	7733838379	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-09 10:44:22.79326	6	2025-05-31 08:42:22.030114	
7780	gaadimech 	9461109880	2025-07-03 18:30:00	Needs Followup	Beat ac 999	2025-06-30 07:11:16.340871	6	2025-07-02 09:50:24.226757	
4624	Cx482	7665928484	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-09 10:47:47.286224	6	2025-05-31 08:42:22.030114	
3956	.	9974105690	2025-09-12 18:30:00	Needs Followup	Dzire 2699\r\nAhmdabad se hai	2025-02-12 05:00:21.929098	6	2025-07-02 11:43:15.248717	
4397	gaadimech 	9829930400	2025-07-24 10:00:00	Needs Followup	Creta ac checkup  sharp visit krenge	2025-02-26 05:12:43.739248	4	2025-05-31 08:43:35.995616	
4616	gaadimech	9784849868	2025-07-27 10:00:00	Needs Followup	Sonet 2899	2025-03-09 04:51:35.75189	4	2025-05-31 08:43:47.842094	
4494	Cx904	7878927181	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-03 06:26:25.938028	4	2025-05-31 08:42:22.030114	
4243	.	8302458811	2025-07-08 10:00:00	Needs Followup	Karouli se hai jarurt hui to visit krenhe	2025-02-19 12:25:35.687777	4	2025-05-31 08:42:30.087566	
3958	.	9929781672	2025-07-09 10:00:00	Needs Followup	Not pick 	2025-02-12 05:06:58.198402	4	2025-05-31 08:42:34.144665	
4492	Cx902	9269721044	2025-07-17 10:00:00	Needs Followup	Alto service 1999\r\nCall cut	2025-03-03 06:23:57.681951	6	2025-05-31 08:43:06.869056	
5633	Tushar 	9829982288	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:41:13.816019	4	2025-05-31 08:42:38.503765	
7081	Customer 	8269966545	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:29:24.871209	4	2025-05-31 08:43:14.897002	
4272	.	8560988425	2025-07-09 10:00:00	Needs Followup	Vento dent paint panel charge 2500\r\nRoof 4000 soch kr btayenge\r\n	2025-02-22 04:58:31.269366	4	2025-05-31 08:42:34.144665	
4612	gaadimech 	9660348676	2025-07-16 10:00:00	Needs Followup	Dzire dent paint 	2025-03-09 04:36:06.151112	4	2025-05-31 08:43:02.994951	
3950	.	9950191947	2025-07-15 10:00:00	Needs Followup	Scross  vki workshop visit. \r\nCall cut	2025-02-12 04:37:44.429822	6	2025-05-31 08:42:58.621937	
4613	gaadimech	9928550038	2025-07-16 10:00:00	Needs Followup	Busy call u later \r\nNot requirement 	2025-03-09 04:44:16.005964	4	2025-05-31 08:43:02.994951	
3951	.	9001071708	2025-07-05 10:00:00	Needs Followup	Tigor 2599 not interested 	2025-02-12 04:39:49.487901	4	2025-05-31 08:42:17.990214	
4352	gaadimech 	9664099418	2025-07-09 10:00:00	Needs Followup	Call cut\r\nDzire ac checkup visit after holi	2025-02-25 04:50:05.397023	4	2025-05-31 08:42:34.144665	
5634	Reeta 	9829979797	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:41:38.365068	4	2025-05-31 08:42:38.503765	
3953	.	9119287877	2025-07-05 10:00:00	Needs Followup	Not interested 	2025-02-12 04:45:24.516697	4	2025-05-31 08:42:17.990214	
5635	Akhil	9829979792	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:42:00.27533	4	2025-05-31 08:42:38.503765	
3959	.	8209347443	2025-07-05 10:00:00	Needs Followup	Not pick	2025-02-12 05:08:12.90123	4	2025-05-31 08:42:17.990214	
4394	gaadimech 	8432661627	2025-07-05 10:00:00	Needs Followup	Dzire 2699\r\nNot pick 	2025-02-26 05:05:29.040899	4	2025-05-31 08:42:17.990214	
5092	Manoj g	8302430042	2025-07-17 18:30:00	Needs Followup		2025-03-26 09:07:03.560011	6	2025-06-28 09:18:17.93876	
6032	Customer 	9602307236	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:25:57.737378	6	2025-05-31 08:42:46.397595	
4520	Cx920	8279293067	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-04 08:38:11.742441	4	2025-05-31 08:42:17.990214	
6033	Customer 	9799495546	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:26:24.624498	6	2025-05-31 08:42:46.397595	
4519	Honda amaze 	9829666763	2025-07-14 10:00:00	Needs Followup	Dent paint \r\n24000	2025-03-04 08:37:13.647765	4	2025-05-31 08:42:54.38585	
5096	gaadimech 	9116093223	2025-07-14 10:00:00	Needs Followup	Not pick \r\nSwitch off	2025-03-26 09:18:15.383108	4	2025-05-31 08:42:54.38585	
4452	gaadimech	9829014465	2025-07-15 10:00:00	Needs Followup	Not pick \r\nMene koi inquiry nhi ki 	2025-03-01 10:19:30.96696	6	2025-05-31 08:42:58.621937	
4422	Cx562	9001484597	2025-07-17 10:00:00	Needs Followup	i20 \r\nCar service \r\nCall cut	2025-02-27 06:35:58.220487	4	2025-05-31 08:43:06.869056	
4487	Cx897	8171162201	2025-07-17 10:00:00	Needs Followup	Alto \r\nService 	2025-03-03 06:10:23.377305	4	2025-05-31 08:43:06.869056	
4069	.	9887088701	2025-07-07 18:30:00	Did Not Pick Up	Call cut	2025-02-15 11:09:14.704564	6	2025-07-02 11:05:25.800607	
5112	gaadimech 	7737122892	2025-07-21 10:00:00	Needs Followup	Eon 2299 	2025-03-26 11:41:37.606865	4	2025-05-31 08:43:23.449024	
5656	gaadimech 	8875700666	2025-07-21 10:00:00	Needs Followup	Baleno 2799	2025-04-08 07:38:13.752293	6	2025-05-31 08:43:23.449024	
5642	gaadimech 	8952930101	2025-07-22 10:00:00	Needs Followup	I10 service sharp	2025-04-08 05:15:11.562849	4	2025-05-31 08:43:27.624295	
7084	Customer 	9828112085	2025-07-22 10:00:00	Needs Followup		2025-05-10 12:30:48.89687	6	2025-05-31 08:43:27.624295	
5649	Customer 	9602466011	2025-07-23 10:00:00	Needs Followup	Seltos 3599	2025-04-08 05:35:55.769703	4	2025-05-31 08:43:31.574711	
7083	Customer 	9928283817	2025-07-25 10:00:00	Needs Followup		2025-05-10 12:30:25.450553	4	2025-05-31 08:43:39.880052	
5643	Cx648	9649122939	2025-07-25 10:00:00	Needs Followup	Tavera ac gas	2025-04-08 05:15:27.479429	6	2025-05-31 08:43:39.880052	
5639	Cx642	7976763290	2025-07-27 10:00:00	Needs Followup	Liniya 	2025-04-08 05:05:35.776673	6	2025-05-31 08:43:47.842094	
3960	.	9314398870	2025-07-18 18:30:00	Needs Followup	Not interested 	2025-02-12 07:06:48.475568	6	2025-07-02 11:44:01.798532	
5654	gaadimech	9462393066	2025-07-17 18:30:00	Needs Followup	Polo car service 	2025-04-08 07:21:15.500416	4	2025-07-04 10:39:49.70694	
4110	.	9840216821	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-02-16 10:39:51.485392	6	2025-06-30 09:54:46.624175	
5113	vikram singh	9414136702	2025-07-30 18:30:00	Feedback	Not picking 	2025-03-26 11:43:05.982896	9	2025-07-05 07:47:09.574857	RJ14CR5280
4198	.	9828022728	2025-07-05 10:00:00	Needs Followup	Not requirement 	2025-02-18 11:39:53.935115	4	2025-05-31 08:42:17.990214	
4571	C948	9982473303	2025-07-05 10:00:00	Needs Followup	Kwid 2699	2025-03-07 10:11:54.2325	6	2025-05-31 08:42:17.990214	
5653	Customer 	9929348000	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 05:44:30.882121	4	2025-05-31 08:42:38.503765	
4120	.	9829015700	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-16 11:55:13.041535	6	2025-05-31 08:42:58.621937	
5078	gaadimech	9950368339	2025-07-06 10:00:00	Needs Followup	TRIBER ac check 	2025-03-26 06:39:17.632545	4	2025-05-31 08:42:22.030114	
5646	Customer 	8003298880	2025-07-06 10:00:00	Needs Followup		2025-04-08 05:23:01.203189	6	2025-05-31 08:42:22.030114	
5650	Customer 	9214304550	2025-07-06 10:00:00	Needs Followup		2025-04-08 05:39:27.137021	6	2025-05-31 08:42:22.030114	
5651	Customer 	9929348000	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-04-08 05:43:44.583583	6	2025-05-31 08:42:22.030114	
5652	Customer 	9929348000	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-04-08 05:43:47.019119	6	2025-05-31 08:42:22.030114	
5636	Cx638	9799380297	2025-07-18 10:00:00	Needs Followup	Call cut	2025-04-08 05:02:54.826031	4	2025-05-31 08:43:10.854377	
5638	Cx641	8005858687	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-08 05:04:41.128334	4	2025-05-31 08:43:10.854377	
7082	Customer 	8766046639	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:30:01.979277	4	2025-05-31 08:43:14.897002	
5640	Cx643	9413970397	2025-07-19 10:00:00	Needs Followup	Tata Vista shoker 	2025-04-08 05:07:59.182891	6	2025-05-31 08:43:14.897002	
6841	Cx1160	9928209714	2025-07-20 10:00:00	Needs Followup	Dent paint 	2025-05-02 07:09:29.898546	4	2025-05-31 08:43:19.077196	
7180	Cx2015	7792052510	2025-07-26 10:00:00	Needs Followup	Service 	2025-05-14 07:20:40.717024	4	2025-05-31 08:43:43.903509	
7201	gaadimech	6377068462	2025-07-20 10:00:00	Needs Followup	Dzire ac checkup	2025-05-15 10:22:41.885436	6	2025-05-31 08:43:19.077196	
4817	gaadimech	8209086183	2025-07-21 10:00:00	Needs Followup	Wagnor 2599	2025-03-18 04:54:43.05019	4	2025-05-31 08:43:23.449024	
5118	gaadimech 	9509008975	2025-07-21 10:00:00	Needs Followup	Accent dent paint Not pick 	2025-03-27 04:33:52.66364	4	2025-05-31 08:43:23.449024	
5120	gaadimech 	9829169200	2025-07-21 10:00:00	Needs Followup	Baleno 2799	2025-03-27 04:44:49.597732	4	2025-05-31 08:43:23.449024	
7122	gaadimech 	7976861380	2025-07-28 10:00:00	Needs Followup	Accent 2999 Not pick	2025-05-13 04:50:51.60919	6	2025-05-31 08:43:51.744985	
3817	.	9829886888	2025-07-09 18:30:00	Needs Followup	Accent bumper charge 2500	2025-02-07 04:30:18.562584	4	2025-06-30 07:17:17.474626	
5659	Customer 	9929348000	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:32:06.953152	4	2025-05-31 08:42:38.503765	
7178	Cx2014	8769811711	2025-07-28 10:00:00	Needs Followup	Car service \r\nCall end 	2025-05-14 07:18:42.997205	6	2025-05-31 08:43:51.744985	
6865	gaadimech 	8340333082	2025-07-22 10:00:00	Needs Followup	Ciaz 3199	2025-05-03 05:43:15.307815	6	2025-05-31 08:43:27.624295	
7181	Cx2016	9756230447	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-14 07:21:57.034436	6	2025-05-31 08:43:51.744985	
899	Cx116	7225094127	2025-09-30 18:30:00	Needs Followup	Interested 	2024-12-03 05:16:04	9	2025-07-02 04:20:35.366084	\N
6034	Customer 	9799495546	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:26:26.772684	6	2025-05-31 08:42:46.397595	
7092	Customer 	8079073349	2025-07-22 10:00:00	Needs Followup		2025-05-10 12:33:25.570673	6	2025-05-31 08:43:27.624295	
7130	gaadimech 	7023476287	2025-07-22 10:00:00	Needs Followup	Safari Strom 5999\r\nCall u later 	2025-05-13 06:10:59.709197	6	2025-05-31 08:43:27.624295	
7170	gaadimech	9289800193	2025-07-22 10:00:00	Needs Followup	Ameo  car service 3999	2025-05-14 06:58:28.48179	6	2025-05-31 08:43:27.624295	
3637	.	9829062282	2025-07-24 10:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	4	2025-05-31 08:43:35.995616	
6035	Customer 	9414606683	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:26:55.059062	6	2025-05-31 08:42:46.397595	
6036	Customer 	9314509107	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:27:22.412055	6	2025-05-31 08:42:46.397595	
7086	Customer 	9829019040	2025-07-25 10:00:00	Needs Followup		2025-05-10 12:31:36.807822	4	2025-05-31 08:43:39.880052	
7091	Customer 	9116094580	2025-07-26 10:00:00	Needs Followup		2025-05-10 12:32:57.033415	4	2025-05-31 08:43:43.903509	
7197	gaadiemch	9783226865	2025-07-25 18:30:00	Feedback	Dzire 2000 dent paint\r\nDone sharp motors	2025-05-15 05:30:50.166787	6	2025-05-21 10:43:58.616385	
7087	Customer 	8769871143	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:32:00.986313	4	2025-05-31 08:43:14.897002	
7088	Customer 	8769871143	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:32:03.179051	4	2025-05-31 08:43:14.897002	
7089	Customer 	7014583039	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:32:31.000051	4	2025-05-31 08:43:14.897002	
7090	Customer 	7014583039	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:32:31.912131	4	2025-05-31 08:43:14.897002	
7145	Cx2005	7077160420	2025-07-19 10:00:00	Needs Followup	Baleno car service 2899\r\nIn coming nahi hai	2025-05-13 07:02:57.249569	4	2025-05-31 08:43:14.897002	
7085	Customer 	9643549871	2025-07-19 10:00:00	Needs Followup		2025-05-10 12:31:12.840902	6	2025-05-31 08:43:14.897002	
5676	Customer 	9828533000	2025-07-23 10:00:00	Needs Followup	Verna 3399	2025-04-08 11:46:00.502146	6	2025-05-31 08:43:31.574711	
5125	gaadimech 	7727044920	2025-07-27 10:00:00	Needs Followup	Not interested 	2025-03-27 05:33:23.178767	4	2025-05-31 08:43:47.842094	
5124	Cx560	8107765488	2025-07-19 10:00:00	Needs Followup	Alto \r\nDrycleaning \r\nRubbing 	2025-03-27 05:19:19.656451	6	2025-05-31 08:43:14.897002	
5147	Interested 	9302101400	2025-07-03 10:00:00	Needs Followup	Grand I10 2299	2025-03-27 07:16:01.06468	4	2025-05-31 08:42:09.584832	
5148	Customer 	9770101760	2025-07-03 10:00:00	Needs Followup	Busy	2025-03-27 07:16:45.001982	4	2025-05-31 08:42:09.584832	
5139	Customer 	9818431558	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-27 07:08:19.061897	6	2025-05-31 08:42:09.584832	
5145	Anup g	9414048371	2025-07-03 10:00:00	Needs Followup	Not interested for now 	2025-03-27 07:14:38.691298	6	2025-05-31 08:42:09.584832	
5149	Customer 	9764409743	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-27 07:17:21.396653	6	2025-05-31 08:42:09.584832	
5663	Customer 	9460307431	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:33:56.237464	6	2025-05-31 08:42:26.111514	
5664	Customer 	9828112364	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:34:15.825181	6	2025-05-31 08:42:26.111514	
5672	Customer 	9602466011	2025-07-07 10:00:00	Needs Followup	Seltos 3599	2025-04-08 11:39:43.824193	6	2025-05-31 08:42:26.111514	
5674	Customer 	9711043808	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:44:22.98126	6	2025-05-31 08:42:26.111514	
7664	gaadimech	7976073292	2025-07-22 18:30:00	Needs Followup	Not picking 	2025-06-01 05:09:39.310328	9	2025-07-03 08:23:11.825558	
5122	gaadimech	8302816333	2025-07-30 18:30:00	Did Not Pick Up	Sonet 2499 dent paint \r\nNot interested 	2025-03-27 05:10:04.089514	6	2025-04-02 08:55:53.260025	
7746	gaadimech 	8078687147	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-06-29 05:38:19.254876	6	2025-06-30 07:24:26.793375	
5675	Customer 	9828533000	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:45:23.790221	6	2025-05-31 08:42:26.111514	
5681	Customer 	9314501121	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:48:53.146644	6	2025-05-31 08:42:26.111514	
5662	Customer 	9001195125	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:33:32.567305	4	2025-05-31 08:42:38.503765	
5665	Customer 	9950909090	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:34:42.000458	4	2025-05-31 08:42:38.503765	
5666	Customer 	9929083143	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:35:21.377807	4	2025-05-31 08:42:38.503765	
5667	Customer 	9680431831	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:35:44.295484	6	2025-05-31 08:42:38.503765	
5668	Customer 	9829371086	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:36:13.471466	6	2025-05-31 08:42:38.503765	
5669	Customer 	9829371086	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:36:18.697587	6	2025-05-31 08:42:38.503765	
5670	Customer 	9928491764	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:38:22.310294	6	2025-05-31 08:42:38.503765	
5671	Customer 	9929559414	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:38:50.652597	6	2025-05-31 08:42:38.503765	
5673	Customer 	9829236251	2025-07-10 10:00:00	Needs Followup	Audi 13999\r\nMercedes 14399	2025-04-08 11:43:45.355726	6	2025-05-31 08:42:38.503765	
5677	Customer 	9829037734	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:46:49.270008	6	2025-05-31 08:42:38.503765	
5678	Customer 	9829353860	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:47:22.569835	6	2025-05-31 08:42:38.503765	
5679	Customer 	9828436180	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:48:00.016881	6	2025-05-31 08:42:38.503765	
5131	Cx561	9887172121	2025-07-14 10:00:00	Needs Followup	i10 \r\n2299	2025-03-27 05:56:12.483376	4	2025-05-31 08:42:54.38585	
5129	gaadiemch 	9413591777	2025-07-14 10:00:00	Needs Followup	Not pick	2025-03-27 05:39:58.294011	4	2025-05-31 08:42:54.38585	
5156	Eon ac gas 	6367015383	2025-07-17 10:00:00	Needs Followup	Eon ac gas 	2025-03-27 07:45:44.380917	6	2025-05-31 08:43:06.869056	
5134	Cx564	9828056904	2025-07-18 10:00:00	Needs Followup	Car service 	2025-03-27 06:31:20.542234	6	2025-05-31 08:43:10.854377	
5158	gaadimech 	9680038319	2025-07-27 10:00:00	Needs Followup	TRIBER 3399 Saturday 	2025-03-27 09:29:01.781554	4	2025-05-31 08:43:47.842094	
5683	Customer 	9828074155	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:49:44.799434	6	2025-05-31 08:42:38.503765	
3352	Customer 	9660763880	2025-07-08 10:00:00	Needs Followup	Swift dant paint per penal 2000\r\nSunday call back\r\nSwitch off 	2025-01-24 04:17:20.62172	4	2025-05-31 08:42:30.087566	
3966	.	8209463139	2025-07-08 10:00:00	Needs Followup	Not requirement alredy service hai 	2025-02-12 08:17:37.323293	4	2025-05-31 08:42:30.087566	
5684	Customer 	9928151455	2025-07-10 10:00:00	Needs Followup	Hyundai 2799	2025-04-08 11:54:52.927658	6	2025-05-31 08:42:38.503765	
5687	Customer 	9829408806	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:56:29.40307	6	2025-05-31 08:42:38.503765	
5688	Customer 	9414913441	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:56:59.802125	6	2025-05-31 08:42:38.503765	
5689	Customer 	9314950191	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:57:34.337131	6	2025-05-31 08:42:38.503765	
5685	Customer 	9414605607	2025-07-19 10:00:00	Needs Followup	Creta 3599	2025-04-08 11:55:33.199341	4	2025-05-31 08:43:14.897002	
1095	Cx118	8875030317	2025-11-25 18:30:00	Needs Followup	Barmer shift hogye 	2024-12-05 10:39:15	9	2025-07-04 06:50:57.422988	
5159	gaadimech 	9887646287	2025-07-24 10:00:00	Needs Followup	Call cut	2025-03-27 12:21:25.983866	4	2025-05-31 08:43:35.995616	
7099	gaadimech 	9001221606	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-05-11 06:44:51.136985	6	2025-05-31 08:43:51.744985	
7738	gaadinech	6376807893	2025-09-19 18:30:00	Did Not Pick Up	Tata curv dent paint \r\nNot interested 	2025-06-29 05:22:32.055348	6	2025-06-30 07:26:10.080177	
5729	Customer 	9001241273	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:26:14.132672	4	2025-05-31 08:42:42.451086	
5730	Customer 	9929290026	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:26:39.303905	4	2025-05-31 08:42:42.451086	
6052	Customer 	9414226482	2025-07-12 10:00:00	Needs Followup	Not 	2025-04-15 12:38:33.219641	6	2025-05-31 08:42:46.397595	
6053	Customer 	9414265577	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:38:59.701391	6	2025-05-31 08:42:46.397595	
6054	Customer 	9828313537	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:39:26.429507	6	2025-05-31 08:42:46.397595	
6055	Customer 	9414887807	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:39:53.237672	6	2025-05-31 08:42:46.397595	
6056	Customer 	9680462102	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:40:29.668012	6	2025-05-31 08:42:46.397595	
6057	Customer 	9982228885	2025-07-12 10:00:00	Needs Followup	Tata aria 4999	2025-04-15 12:41:22.222204	6	2025-05-31 08:42:46.397595	
6058	Customer 	9829007557	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:41:49.158903	6	2025-05-31 08:42:46.397595	
6059	Customer 	9828012009	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:42:15.599711	6	2025-05-31 08:42:46.397595	
6060	Customer 	9828110051	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:42:38.521627	6	2025-05-31 08:42:46.397595	
6061	Customer 	9314360690	2025-07-12 10:00:00	Needs Followup	N	2025-04-15 12:43:12.001642	6	2025-05-31 08:42:46.397595	
6062	Customer 	9929987159	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:43:41.785527	6	2025-05-31 08:42:46.397595	
4531	Cx923	9352677238	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-04 12:40:16.535478	6	2025-05-31 08:43:06.869056	
5160	gaadimech 	7229871324	2025-07-18 10:00:00	Needs Followup	Not interested  call cut	2025-03-27 12:23:22.447398	4	2025-05-31 08:43:10.854377	
7096	gaadimech 	9782750211	2025-07-18 10:00:00	Needs Followup	Alto 2399  vki	2025-05-11 05:56:15.643742	4	2025-05-31 08:43:10.854377	
5165	gaadimech 	9460232681	2025-07-07 10:00:00	Needs Followup	I10 ac check	2025-03-28 05:52:04.351298	6	2025-05-31 08:42:26.111514	
6310	Cx1005	7792088758	2025-07-20 10:00:00	Needs Followup	i10 service \r\n2299\r\nAjmer road \r\nCall cut \r\n\r\n	2025-04-19 05:17:10.638385	4	2025-05-31 08:43:19.077196	
5162	gaadimech	7427873988	2025-07-21 10:00:00	Needs Followup	Ciaz ac checkup basically ajmer se hai jaipur aayenge to visit krenhe	2025-03-28 04:52:03.156564	4	2025-05-31 08:43:23.449024	
5166	gaadiemch 	9602154307	2025-07-21 10:00:00	Needs Followup	Busy call u later \r\nCall cut	2025-03-28 05:53:17.283578	4	2025-05-31 08:43:23.449024	
5746	gaadimech 	9571543591	2025-07-21 10:00:00	Needs Followup	Alto K10 clutch issue \r\nCall cut	2025-04-09 04:51:17.549998	6	2025-05-31 08:43:23.449024	
6205	gaadimech 	9660464258	2025-07-21 10:00:00	Needs Followup	Baleno 2799 sharp\r\nKaroli se h	2025-04-17 09:39:59.368671	6	2025-05-31 08:43:23.449024	
6313	Cx1007	8619844632	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-19 05:18:51.371903	6	2025-05-31 08:43:39.880052	
7733	gaadimech 	7088037123	2025-11-07 18:30:00	Did Not Pick Up	Not pick by mistake inquiry ki hai 	2025-06-29 05:04:09.299879	6	2025-06-30 07:30:38.237557	
6308	gaadimech 	9351626335	2025-07-27 10:00:00	Needs Followup	Polo 3699\r\nNot interested 	2025-04-19 05:14:15.010505	6	2025-05-31 08:43:47.842094	
1327	Cx125	7020222902	2025-07-07 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-02 04:23:07.877304	\N
7060	gaadimech 	9521918604	2025-07-28 10:00:00	Needs Followup	Call cut	2025-05-10 05:11:08.553494	4	2025-05-31 08:43:51.744985	
6069	Customer 	9983511111	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-04-15 12:46:49.003668	6	2025-05-31 08:42:30.087566	
5168	gaadimech 	7976686902	2025-07-30 18:30:00	Did Not Pick Up	Swift ac coil issue. Rk\r\nCall cut	2025-03-28 06:01:53.0459	6	2025-05-14 11:58:23.770065	
6063	Customer 	9414456662	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:44:02.998811	6	2025-05-31 08:42:46.397595	
6064	Customer 	9289080871	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:44:28.16716	6	2025-05-31 08:42:46.397595	
6068	Customer 	9950107371	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:46:25.052435	4	2025-05-31 08:42:50.438237	
6071	Customer 	9599207719	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:49:29.460772	4	2025-05-31 08:42:50.438237	
6072	Customer 	9599207719	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:49:31.393609	4	2025-05-31 08:42:50.438237	
6073	Customer 	9414041881	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:50:11.971359	4	2025-05-31 08:42:50.438237	
6074	Customer 	9314083000	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:50:36.897426	4	2025-05-31 08:42:50.438237	
5747	gaadimech 	8306643903	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-04-09 05:05:58.579889	4	2025-05-31 08:42:54.38585	
6181	Customer 	9929988124	2025-07-16 10:00:00	Needs Followup		2025-04-17 07:57:41.783757	4	2025-05-31 08:43:02.994951	
5164	gaadimech 	9214165659	2025-07-18 10:00:00	Needs Followup	Gi10 2699 sharp	2025-03-28 05:29:12.169398	4	2025-05-31 08:43:10.854377	
5167	gaadimech 	7742209457	2025-07-18 10:00:00	Needs Followup	Not pick 	2025-03-28 05:55:51.921841	4	2025-05-31 08:43:10.854377	
6309	Cx1005	9929204111	2025-07-18 10:00:00	Needs Followup	Fortuner \r\nAc service 	2025-04-19 05:15:42.745486	6	2025-05-31 08:43:10.854377	
6312	Cx1008	9653713741	2025-07-18 10:00:00	Needs Followup	Eon  2399	2025-04-19 05:18:15.748962	6	2025-05-31 08:43:10.854377	
6314	Cx1007	9529852224	2025-07-18 10:00:00	Needs Followup	Dent paint \r\nAjmer road 	2025-04-19 05:19:55.943781	6	2025-05-31 08:43:10.854377	
7101	Cx1181	9786999113	2025-07-20 10:00:00	Needs Followup	Wr 2599\r\nCar service 	2025-05-11 07:37:11.899467	6	2025-05-31 08:43:19.077196	
5520	gaadimech 	9829214782	2025-07-22 10:00:00	Needs Followup	Duster 3699	2025-04-03 05:22:14.912902	4	2025-05-31 08:43:27.624295	
5197	gaadimech 	7976416521	2025-07-24 10:00:00	Needs Followup	Zen estilo ac checkup\r\nCall cut not interested 	2025-03-28 08:04:09.092047	4	2025-05-31 08:43:35.995616	
7198	Cx2015	8769425871	2025-07-26 10:00:00	Needs Followup	Dent paint 	2025-05-15 05:51:30.940037	4	2025-05-31 08:43:43.903509	
5196	gaadimech 	9571740504	2025-07-27 10:00:00	Needs Followup	Busy call u later \r\nNot requirement 	2025-03-28 08:03:23.458023	4	2025-05-31 08:43:47.842094	
5169	Customer 	9314871631	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:06:17.701396	4	2025-05-31 08:42:09.584832	
5177	Customer 	9920896641	2025-07-06 10:00:00	Needs Followup	Asked me to call back later after 15 days 	2025-03-28 07:14:32.028159	6	2025-05-31 08:42:22.030114	
5176	Customer 	9602655086	2025-07-18 18:30:00	Needs Followup	No need	2025-03-28 07:13:26.114519	6	2025-06-30 09:30:32.723784	
5170	Customer 	9783557777	2025-07-03 10:00:00	Needs Followup	Grand I10 2299	2025-03-28 07:07:11.526205	4	2025-05-31 08:42:09.584832	
5759	Honda Amaze 3199	8875527555	2025-07-25 10:00:00	Needs Followup	Amaze 3199	2025-04-09 07:45:45.167509	4	2025-05-31 08:43:39.880052	
5751	Customer 	8824995618	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-09 07:22:42.294446	6	2025-05-31 08:42:26.111514	
5163	gaadimech 	9460635787	2025-07-24 18:30:00	Did Not Pick Up	Wagnore 2399 rk\r\nNot required 	2025-03-28 05:06:01.720652	6	2025-06-28 08:10:51.213201	
5754	Customer 	8003366863	2025-07-11 10:00:00	Needs Followup		2025-04-09 07:24:52.594109	4	2025-05-31 08:42:42.451086	
5787	Customer 	7610949367	2025-07-03 18:30:00	Needs Followup	Amanya hai no 	2025-04-09 09:58:54.443386	4	2025-07-04 10:36:44.179425	
5755	Customer 	9560018351	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 07:25:45.207629	4	2025-05-31 08:42:42.451086	
5761	Customer 	7568488886	2025-07-07 10:00:00	Needs Followup	Nexon ev 	2025-04-09 08:18:58.258381	6	2025-05-31 08:42:26.111514	
5756	Customer 	9560018351	2025-07-11 10:00:00	Needs Followup		2025-04-09 07:26:38.980802	4	2025-05-31 08:42:42.451086	
5762	Customer 	9414054332	2025-07-07 10:00:00	Needs Followup		2025-04-09 09:07:46.052586	6	2025-05-31 08:42:26.111514	
5763	Customer 	9414054332	2025-07-07 10:00:00	Needs Followup		2025-04-09 09:07:48.213033	6	2025-05-31 08:42:26.111514	
3971	.	9351369162	2025-07-08 10:00:00	Needs Followup	Call cut\r\nBy mistake hua hoga mene koi interest show nahi kia 	2025-02-12 08:57:26.736448	6	2025-05-31 08:42:30.087566	
5764	Customer 	9414054332	2025-07-08 10:00:00	Needs Followup		2025-04-09 09:07:49.122496	6	2025-05-31 08:42:30.087566	
5780	Customer 	9636660900	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-04-09 09:53:10.648407	6	2025-05-31 08:42:30.087566	
5748	Customer 	7891962750	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 07:20:00.957366	4	2025-05-31 08:42:42.451086	
5749	Customer 	9414378551	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 07:21:05.730013	4	2025-05-31 08:42:42.451086	
5750	Customer 	9414311547	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 07:21:56.553496	4	2025-05-31 08:42:42.451086	
5752	Customer 	9828247663	2025-07-11 10:00:00	Needs Followup		2025-04-09 07:23:16.496181	4	2025-05-31 08:42:42.451086	
5753	Customer 	9828247663	2025-07-11 10:00:00	Needs Followup		2025-04-09 07:24:17.567207	4	2025-05-31 08:42:42.451086	
5757	Customer 	9414296277	2025-07-11 10:00:00	Needs Followup		2025-04-09 07:27:37.953288	4	2025-05-31 08:42:42.451086	
5760	Customer 	9636080006	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 08:09:51.01692	4	2025-05-31 08:42:42.451086	
5765	Customer 	9829244286	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:10:20.254986	4	2025-05-31 08:42:42.451086	
5766	Customer 	9983117003	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:10:48.207073	4	2025-05-31 08:42:42.451086	
5767	Customer 	9001896629	2025-07-11 10:00:00	Needs Followup	Seltos 	2025-04-09 09:12:50.350685	4	2025-05-31 08:42:42.451086	
5768	Customer 	9414336749	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:15:41.120968	4	2025-05-31 08:42:42.451086	
5769	Customer 	9587692000	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:16:45.478744	4	2025-05-31 08:42:42.451086	
5770	Customer 	9828021995	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:17:44.785946	4	2025-05-31 08:42:42.451086	
5771	Customer 	9929492000	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:18:21.451724	4	2025-05-31 08:42:42.451086	
5772	Customer 	9929492000	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:18:23.780961	4	2025-05-31 08:42:42.451086	
3970	.	7436050678	2025-07-15 10:00:00	Needs Followup	Don't have car 	2025-02-12 08:55:43.368082	6	2025-05-31 08:42:58.621937	
5779	Customer 	9461673858	2025-07-16 10:00:00	Needs Followup		2025-04-09 09:51:37.866647	4	2025-05-31 08:43:02.994951	
5758	Cx642	8209914618	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-09 07:41:35.142074	6	2025-05-31 08:43:10.854377	
5260	gaapdimech 	7339749299	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-03-29 05:46:53.847164	4	2025-05-31 08:43:23.449024	
5805	gaadimech 	9829055346	2025-07-21 10:00:00	Needs Followup	Eon\r\nCall cut	2025-04-09 10:10:12.104066	6	2025-05-31 08:43:23.449024	
5807	gaadimech 	9929596221	2025-07-21 10:00:00	Needs Followup	Out of station \r\nNot pick	2025-04-09 10:11:46.428928	6	2025-05-31 08:43:23.449024	
5827	Customer 	8559876315	2025-07-21 10:00:00	Needs Followup	Aura 2799	2025-04-09 10:36:52.263041	6	2025-05-31 08:43:23.449024	
5806	gaadimech	9828860905	2025-07-22 10:00:00	Needs Followup	Scorpio dent paint malpura 	2025-04-09 10:10:52.194086	4	2025-05-31 08:43:27.624295	
5824	Customer 	9828622788	2025-07-23 10:00:00	Needs Followup	Figo 2799	2025-04-09 10:33:56.255044	4	2025-05-31 08:43:31.574711	
5259	gaapdimech	8104888171	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-03-29 05:45:47.311479	4	2025-05-31 08:43:47.842094	
5817	Customer 	7891276050	2025-07-07 10:00:00	Needs Followup	Zen 2599	2025-04-09 10:29:45.164175	4	2025-05-31 08:42:26.111514	
5801	Customer 	9313612266	2025-07-07 10:00:00	Needs Followup		2025-04-09 10:08:02.756602	6	2025-05-31 08:42:26.111514	
5786	Customer 	9785907535	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:58:18.54927	4	2025-05-31 08:42:42.451086	
5788	Customer 	9829089454	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:59:28.305297	4	2025-05-31 08:42:42.451086	
5789	Customer 	7877688832	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:00:43.946656	4	2025-05-31 08:42:42.451086	
5826	Customer 	9414535328	2025-07-06 10:00:00	Needs Followup	Kia  \r\nI 10 2999	2025-04-09 10:36:11.376787	4	2025-05-31 08:42:22.030114	
5243	Cx568	9983325224	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-29 05:10:08.603549	6	2025-05-31 08:42:22.030114	
3663	Cx254	7014394620	2025-07-07 00:00:00	Needs Followup	Swift 24000\r\nDent paint 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	\N
5790	Customer 	9784864520	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:01:12.709868	4	2025-05-31 08:42:42.451086	
5791	Customer 	9414035551	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:01:36.535695	4	2025-05-31 08:42:42.451086	
5792	Customer 	9414035551	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:01:38.735377	4	2025-05-31 08:42:42.451086	
5256	gaadimech	8441038435	2025-07-14 10:00:00	Needs Followup	Only washing ??	2025-03-29 05:41:03.848486	4	2025-05-31 08:42:54.38585	
5820	Customer 	9649600400	2025-07-14 10:00:00	Needs Followup		2025-04-09 10:31:14.476732	4	2025-05-31 08:42:54.38585	
2744	Customer	9828045555	2025-07-15 10:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	4	2025-05-31 08:42:58.621937	
5244	Cx569	8209658181	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-29 05:11:01.322086	6	2025-05-31 08:43:06.869056	
5245	Cx570	9001838393	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-29 05:11:43.753347	6	2025-05-31 08:43:06.869056	
5248	Cx573	8005833371	2025-07-17 10:00:00	Needs Followup	Accent 2999\r\nCall cut 	2025-03-29 05:19:57.431188	6	2025-05-31 08:43:06.869056	
5254	Cx579	9828051516	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-29 05:25:54.559312	6	2025-05-31 08:43:06.869056	
5258	gaadimech 	9828235667	2025-07-18 10:00:00	Needs Followup	Xcent 2799 out of jaipur	2025-03-29 05:43:44.493604	4	2025-05-31 08:43:10.854377	
5252	Cx579	9214362911	2025-07-18 10:00:00	Needs Followup	i10 car service 	2025-03-29 05:24:09.997831	6	2025-05-31 08:43:10.854377	
4786	Cx631	9799887756	2025-07-19 10:00:00	Needs Followup	i10 ac service \r\nNo answer 	2025-03-16 11:10:02.293946	6	2025-05-31 08:43:14.897002	
6468	Customer 	9829058249	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-21 09:53:46.715864	6	2025-05-31 08:42:50.438237	
5262	gaadimech 	9782992098	2025-07-21 10:00:00	Needs Followup	Wagnor 2299	2025-03-29 08:07:55.022048	6	2025-05-31 08:43:23.449024	
1628	Raj meena	9799918600	2025-07-11 18:30:00	Needs Followup	cus call not picked\r\nNot interested 	2024-12-10 05:43:58	6	2025-06-01 11:25:54.269294	
1621	Govind Sharma	9414071155	2025-07-06 18:30:00	Needs Followup	cus call not picked\r\nNot interested 	2024-12-10 05:43:58	6	2025-06-01 11:39:27.836889	
6088	gaadimech	9116007636	2025-07-21 10:00:00	Needs Followup	Estilo 2599	2025-04-16 04:55:49.22183	6	2025-05-31 08:43:23.449024	
6092	gaadimech 	7877611444	2025-07-21 10:00:00	Needs Followup	Busy call u later	2025-04-16 05:11:42.644614	6	2025-05-31 08:43:23.449024	
6098	gaadimech 	9414203294	2025-07-21 10:00:00	Needs Followup	Swift 2799	2025-04-16 06:17:47.55898	6	2025-05-31 08:43:23.449024	
1305	Customer	9351436919	2025-07-16 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-02 04:24:59.937888	\N
5265	gaadimech 	8432747729	2025-07-22 10:00:00	Needs Followup	Kwid 2699\r\nOut of jaipur call back after 15 days	2025-03-29 08:51:14.127155	4	2025-05-31 08:43:27.624295	
7067	gaadimech 	8385055658	2025-07-22 10:00:00	Needs Followup	Ac check-up  busy call u later 	2025-05-10 08:30:46.752162	6	2025-05-31 08:43:27.624295	
6447	Customer 	9928400000	2025-07-23 10:00:00	Needs Followup		2025-04-21 09:43:28.089912	4	2025-05-31 08:43:31.574711	
2067	.	9414065113	2025-07-08 10:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-17 07:03:37.548744	6	2025-05-31 08:42:30.087566	
6094	gaadimech 	9610475123	2025-07-24 10:00:00	Needs Followup	Etios 3399\r\nSelf call karenge 	2025-04-16 05:24:07.39732	6	2025-05-31 08:43:35.995616	
6070	Customer 	9414188855	2025-07-16 10:00:00	Needs Followup		2025-04-15 12:47:12.75586	4	2025-05-31 08:43:02.994951	
6459	Customer 	9414360848	2025-07-19 10:00:00	Needs Followup		2025-04-21 09:51:04.410101	4	2025-05-31 08:43:14.897002	
6097	gaadimech 	8979840640	2025-07-24 10:00:00	Needs Followup	Micra 2999	2025-04-16 05:46:54.741837	6	2025-05-31 08:43:35.995616	
6095	gaadimech 	9261626263	2025-07-19 10:00:00	Needs Followup	Alto dent paint 	2025-04-16 05:26:47.127729	4	2025-05-31 08:43:14.897002	
6454	Customer 	9829056300	2025-07-23 10:00:00	Needs Followup		2025-04-21 09:48:05.457832	4	2025-05-31 08:43:31.574711	
6440	Customer 	9414256003	2025-07-23 10:00:00	Needs Followup		2025-04-21 09:27:05.968383	6	2025-05-31 08:43:31.574711	
6460	Customer 	9829307733	2025-07-23 10:00:00	Needs Followup		2025-04-21 09:51:34.546673	6	2025-05-31 08:43:31.574711	
6446	Customer 	9829224600	2025-07-24 10:00:00	Needs Followup		2025-04-21 09:43:03.417221	6	2025-05-31 08:43:35.995616	
6448	Customer 	9829053335	2025-07-19 10:00:00	Needs Followup		2025-04-21 09:43:54.35573	4	2025-05-31 08:43:14.897002	
5266	gaadimech 	9784800627	2025-07-27 10:00:00	Needs Followup	Bmw 12000 	2025-03-29 08:54:37.711091	6	2025-05-31 08:43:47.842094	
6455	Customer 	9829054583	2025-07-25 10:00:00	Needs Followup		2025-04-21 09:48:36.049495	6	2025-05-31 08:43:39.880052	
5828	gaadimech 	8890999990	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-04-09 10:53:45.209252	6	2025-05-31 08:43:47.842094	
6091	gaadimech 	8094517948	2025-07-27 10:00:00	Needs Followup	Call cut	2025-04-16 05:06:45.720955	6	2025-05-31 08:43:47.842094	
6441	Customer 	9314017264	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:36:41.997767	6	2025-05-31 08:42:50.438237	
6438	Customer 	9828137320	2025-07-14 10:00:00	Needs Followup		2025-04-21 09:25:48.594828	4	2025-05-31 08:42:54.38585	
5264	gaadimech	7357566277	2025-07-14 10:00:00	Needs Followup	Creta 3599	2025-03-29 08:36:23.171532	4	2025-05-31 08:42:54.38585	
6456	Customer 	9829056582	2025-07-14 10:00:00	Needs Followup		2025-04-21 09:49:26.705987	6	2025-05-31 08:42:54.38585	
3977	.	9413088851	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-12 09:26:42.832253	6	2025-05-31 08:42:58.621937	
6439	Customer 	9413341452	2025-07-16 10:00:00	Needs Followup		2025-04-21 09:26:14.55524	6	2025-05-31 08:43:02.994951	
6450	Customer 	9414269649	2025-07-16 10:00:00	Needs Followup		2025-04-21 09:45:19.044617	6	2025-05-31 08:43:02.994951	
6437	Customer 	9829066438	2025-07-17 10:00:00	Needs Followup		2025-04-21 09:25:16.240609	4	2025-05-31 08:43:06.869056	
5250	Cx577	9829202350	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-29 05:21:22.467103	6	2025-05-31 08:43:06.869056	
6326	Customer 	9810089518	2025-07-07 10:00:00	Needs Followup		2025-04-19 11:18:51.251278	6	2025-05-31 08:42:26.111514	
5831	gaadimech 	9782709010	2025-07-21 10:00:00	Needs Followup	Santro 2399 	2025-04-11 04:37:51.734789	6	2025-05-31 08:43:23.449024	
6338	Cx110	9509627070	2025-07-27 10:00:00	Needs Followup	Creta dent paint \r\nCall cut	2025-04-19 11:31:56.126757	6	2025-05-31 08:43:47.842094	
6323	Customer 	9828020064	2025-07-20 10:00:00	Needs Followup		2025-04-19 11:14:11.693834	4	2025-05-31 08:43:19.077196	
6331	Customer 	9929210008	2025-07-13 10:00:00	Needs Followup		2025-04-19 11:21:23.657879	6	2025-05-31 08:42:50.438237	
6333	Customer 	9829034486	2025-07-20 10:00:00	Needs Followup		2025-04-19 11:22:13.860171	4	2025-05-31 08:43:19.077196	
6336	Cx1009	9610780627	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-19 11:31:04.759469	4	2025-05-31 08:43:19.077196	
3981	.	9832393265	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-02-12 09:37:11.685027	4	2025-05-31 08:42:30.087566	
5270	gaadimech 	6375597645	2025-07-24 10:00:00	Needs Followup	Busy call u later \r\nNot interested 	2025-03-30 04:44:58.928761	4	2025-05-31 08:43:35.995616	
7737	gaadiemch	9119693627	2025-07-30 18:30:00	Did Not Pick Up	Busy call u later \r\nUp 	2025-06-29 05:16:20.240898	6	2025-07-02 10:25:31.644517	
6343	Cx111	7733852579	2025-07-20 10:00:00	Needs Followup	Dzire \r\nDent paint 	2025-04-19 11:33:43.732658	4	2025-05-31 08:43:19.077196	
6342	Customer 	9829055559	2025-07-13 10:00:00	Needs Followup		2025-04-19 11:33:37.074477	6	2025-05-31 08:42:50.438237	
6349	Customer 	9829066551	2025-07-20 10:00:00	Needs Followup		2025-04-19 11:35:28.26845	4	2025-05-31 08:43:19.077196	
6335	Customer 	9982665000	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:30:55.051407	4	2025-05-31 08:42:54.38585	
6104	gaadimech	9772345673	2025-08-30 18:30:00	Did Not Pick Up	Brezza\r\nNot pick	2025-04-16 07:02:48.78496	6	2025-05-10 10:51:09.357873	
6350	Cx1113	9828774464	2025-07-20 10:00:00	Needs Followup	Figo dent paint 	2025-04-19 11:35:35.807045	4	2025-05-31 08:43:19.077196	
6352	Cx1114	7690098432	2025-07-20 10:00:00	Needs Followup	Swift \r\nDent paint \r\nCall cut 	2025-04-19 11:36:22.679531	4	2025-05-31 08:43:19.077196	
7103	Cx1183	9168819992	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-11 11:03:10.18895	6	2025-05-31 08:43:19.077196	
7104	Cx1185	6376795983	2025-07-20 10:00:00	Needs Followup	Xuv 300\r\nDent 28000	2025-05-11 11:05:47.776733	6	2025-05-31 08:43:19.077196	
7105	C 1184	8078624048	2025-07-20 10:00:00	Needs Followup	Thar dent paint 	2025-05-11 11:07:19.353945	6	2025-05-31 08:43:19.077196	
6100	gaadimech	9680170043	2025-07-21 10:00:00	Needs Followup	Dzire  dent paint	2025-04-16 06:50:22.036003	6	2025-05-31 08:43:23.449024	
6102	gaadimech 	9828089997	2025-07-21 10:00:00	Needs Followup	Celerio dent paint 	2025-04-16 06:52:51.475478	6	2025-05-31 08:43:23.449024	
6330	Customer 	9829012007	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:20:54.6631	4	2025-05-31 08:42:54.38585	
6327	Customer 	9829054803	2025-07-21 10:00:00	Needs Followup		2025-04-19 11:19:22.743786	6	2025-05-31 08:43:23.449024	
6321	Customer 	9829065457	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:13:40.402637	6	2025-05-31 08:42:54.38585	
6099	gaadimech	9672713103	2025-07-22 10:00:00	Needs Followup	Alto dent paint 	2025-04-16 06:49:41.331434	4	2025-05-31 08:43:27.624295	
6322	Customer 	9829065457	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:13:41.599316	6	2025-05-31 08:42:54.38585	
6344	Customer 	9829300091	2025-07-23 10:00:00	Needs Followup	Baleno 2899	2025-04-19 11:34:13.863871	6	2025-05-31 08:43:31.574711	
6347	Cx1112	9667929798	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-19 11:34:39.39173	6	2025-05-31 08:43:10.854377	
6103	gaadimech 	7568372506	2025-07-24 10:00:00	Needs Followup	Alto 1800 panel 	2025-04-16 06:55:25.035332	6	2025-05-31 08:43:35.995616	
6348	Customer 	9414042295	2025-07-19 10:00:00	Needs Followup	Not interested 	2025-04-19 11:35:04.91695	4	2025-05-31 08:43:14.897002	
6105	gaadimech 	9257041954	2025-07-24 10:00:00	Needs Followup	Verna 2199	2025-04-16 07:06:23.195635	6	2025-05-31 08:43:35.995616	
6334	Customer 	9929210008	2025-07-24 10:00:00	Needs Followup	Not interested 	2025-04-19 11:30:22.991218	6	2025-05-31 08:43:35.995616	
6351	Customer 	9829058600	2025-07-26 10:00:00	Needs Followup		2025-04-19 11:36:05.361215	6	2025-05-31 08:43:43.903509	
6107	gaadimech 	9214832814	2025-07-27 10:00:00	Needs Followup	Nexon 3399\r\nRitzz 2599\r\nAbhi plan nhi h	2025-04-16 07:17:28.38347	6	2025-05-31 08:43:47.842094	
5832	gaadimech 	9829096600	2025-07-25 18:30:00	Did Not Pick Up	Fortuner dent paint 	2025-04-11 04:40:35.08067	6	2025-05-22 12:11:48.603014	
6329	Customer 	9829067167	2025-07-19 10:00:00	Needs Followup		2025-04-19 11:20:27.953147	6	2025-05-31 08:43:14.897002	
6320	Customer 	9414052513	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:11:53.898216	6	2025-05-31 08:43:02.994951	
6328	Customer 	9829067948	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:19:49.180278	6	2025-05-31 08:43:02.994951	
6466	Customer 	9829144126	2025-07-20 10:00:00	Needs Followup		2025-04-21 09:52:51.926527	4	2025-05-31 08:43:19.077196	
6478	Customer 	9829811343	2025-07-20 10:00:00	Needs Followup		2025-04-21 11:32:53.078745	4	2025-05-31 08:43:19.077196	
6492	Customer 	9829014429	2025-07-20 10:00:00	Needs Followup		2025-04-21 11:40:05.191358	4	2025-05-31 08:43:19.077196	
7106	Baleno cx1183	9828783322	2025-07-20 10:00:00	Needs Followup	Service 2799  aur dent paint 2100	2025-05-11 11:22:08.160502	6	2025-05-31 08:43:19.077196	
6486	Customer 	9602939559	2025-07-19 10:00:00	Needs Followup		2025-04-21 11:37:22.422108	4	2025-05-31 08:43:14.897002	
5836	gaadimech 	8696486779	2025-07-21 10:00:00	Needs Followup	Not pick 	2025-04-11 05:30:01.878276	6	2025-05-31 08:43:23.449024	
6363	Customer 	9829139769	2025-07-21 10:00:00	Needs Followup		2025-04-19 11:54:36.612632	6	2025-05-31 08:43:23.449024	
6473	Customer 	9829056037	2025-07-21 10:00:00	Needs Followup		2025-04-21 11:30:24.571685	6	2025-05-31 08:43:23.449024	
6106	gaadimech 	9461462324	2025-07-22 10:00:00	Needs Followup	Eco sport 3699	2025-04-16 07:11:52.724469	4	2025-05-31 08:43:27.624295	
6360	Customer 	9414053923	2025-07-23 10:00:00	Needs Followup	Not interested 	2025-04-19 11:53:04.64363	4	2025-05-31 08:43:31.574711	
6487	Customer 	9414062808	2025-07-23 10:00:00	Needs Followup		2025-04-21 11:37:44.786678	6	2025-05-31 08:43:31.574711	
6488	Customer 	9413333381	2025-07-23 10:00:00	Needs Followup		2025-04-21 11:38:14.703155	6	2025-05-31 08:43:31.574711	
5272	gaapdimech 	9828330080	2025-07-24 10:00:00	Needs Followup	Alto K10 2499 self call karenge\r\nNot interested 	2025-03-30 05:21:08.465257	4	2025-05-31 08:43:35.995616	
6479	Customer 	9829043431	2025-07-19 10:00:00	Needs Followup		2025-04-21 11:33:12.509444	6	2025-05-31 08:43:14.897002	
5277	gaadimech 	9828892788	2025-07-24 10:00:00	Needs Followup	Eco sport 3699	2025-03-30 05:33:04.045069	4	2025-05-31 08:43:35.995616	
5834	gaadimech 	8947917896	2025-07-24 10:00:00	Needs Followup	Altroz 2999 month end nd next month 1st week	2025-04-11 05:22:31.421839	6	2025-05-31 08:43:35.995616	
7080	Cx1186	8955943329	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-10 09:42:28.992501	4	2025-05-31 08:43:43.903509	
5837	gaadimech 	9784932307	2025-07-27 10:00:00	Needs Followup	Honda city 3399	2025-04-11 05:34:24.995708	6	2025-05-31 08:43:47.842094	
6355	Customer 	9829107870	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:49:37.120894	4	2025-05-31 08:42:54.38585	
6365	Customer 	9828157900	2025-07-13 10:00:00	Needs Followup		2025-04-19 11:55:39.430574	6	2025-05-31 08:42:50.438237	
7107	Cx1189	8302395564	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-11 11:22:46.963902	6	2025-05-31 08:43:51.744985	
6367	Customer 	9829063326	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-19 11:56:35.626454	6	2025-05-31 08:42:50.438237	
3777	.	8947982469	2025-07-17 18:30:00	Needs Followup	Nahi karwani 	2025-02-05 11:59:45.332338	4	2025-07-02 08:57:54.951785	
6357	Customer 	9829057587	2025-07-09 10:00:00	Needs Followup		2025-04-19 11:51:18.180304	4	2025-05-31 08:42:34.144665	
6358	Customer 	9829057587	2025-07-09 10:00:00	Needs Followup		2025-04-19 11:51:20.648842	4	2025-05-31 08:42:34.144665	
6359	Customer 	9829173619	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:52:31.447565	6	2025-05-31 08:42:54.38585	
6362	Customer 	9314160985	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:54:06.208525	6	2025-05-31 08:42:54.38585	
6361	Customer 	9829068400	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:53:42.96519	6	2025-05-31 08:43:02.994951	
6482	Customer 	9829055305	2025-07-14 10:00:00	Needs Followup		2025-04-21 11:34:49.053437	6	2025-05-31 08:42:54.38585	
6366	Customer 	9829210300	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:56:08.170917	6	2025-05-31 08:43:02.994951	
6491	Customer 	9829060111	2025-07-14 10:00:00	Needs Followup		2025-04-21 11:39:42.123283	6	2025-05-31 08:42:54.38585	
6465	Customer 	9414060043	2025-07-16 10:00:00	Needs Followup		2025-04-21 09:52:13.968559	6	2025-05-31 08:43:02.994951	
6467	Customer 	9352954488	2025-07-16 10:00:00	Needs Followup		2025-04-21 09:53:17.930078	6	2025-05-31 08:43:02.994951	
6475	Customer 	9829157089	2025-07-16 10:00:00	Needs Followup	Verna \r\nCreta \r\nI 19	2025-04-21 11:31:41.160984	6	2025-05-31 08:43:02.994951	
6497	gaadimech 	8619133415	2025-07-22 10:00:00	Needs Followup	Eon 2299	2025-04-21 11:55:31.984161	6	2025-05-31 08:43:27.624295	
6515	Customer 	9829063338	2025-07-27 10:00:00	Needs Followup		2025-04-21 12:29:09.472779	6	2025-05-31 08:43:47.842094	
6562	Customer 	9829077149	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:00:51.576055	4	2025-05-31 08:43:31.574711	
6509	Customer 	9829288901	2025-07-19 10:00:00	Needs Followup	Wagonr 2399	2025-04-21 12:26:15.12242	4	2025-05-31 08:43:14.897002	
6506	Customer 	9829013433	2025-07-20 10:00:00	Needs Followup		2025-04-21 12:25:44.036399	4	2025-05-31 08:43:19.077196	
6502	Customer 	9001097000	2025-07-14 10:00:00	Needs Followup		2025-04-21 12:17:35.485986	4	2025-05-31 08:42:54.38585	
6316	Cx1009	9694636799	2025-07-25 10:00:00	Needs Followup	Ac service \r\ni20	2025-04-19 05:21:43.802654	6	2025-05-31 08:43:39.880052	
7076	Cc1184	9693777888	2025-07-20 10:00:00	Needs Followup	Dent paint \r\nCall cut	2025-05-10 09:39:42.884788	6	2025-05-31 08:43:19.077196	
5840	gaadimech 	9717955131	2025-07-21 10:00:00	Needs Followup	Ritz 2599	2025-04-11 07:15:01.860175	6	2025-05-31 08:43:23.449024	
6564	Customer 	9829049397	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:01:57.351165	4	2025-05-31 08:43:31.574711	
6368	gaadimech 	8278602499	2025-07-21 10:00:00	Needs Followup	Not pick \r\nNot required 	2025-04-20 04:44:21.149012	6	2025-05-31 08:43:23.449024	
6500	gaadimech 	8003603823	2025-07-21 10:00:00	Needs Followup	Alto dent paint 	2025-04-21 11:56:58.43416	6	2025-05-31 08:43:23.449024	
5279	gaadimech 	9887172121	2025-07-24 10:00:00	Needs Followup	I10 2299 out of jaipur\r\nCall cut	2025-03-30 06:15:17.651011	4	2025-05-31 08:43:35.995616	
1780	.	9672120702	2025-07-25 18:30:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-13 11:43:31	6	2025-05-09 08:27:28.151255	
6560	Customer 	9829064094	2025-07-26 10:00:00	Needs Followup		2025-04-22 10:00:00.111893	6	2025-05-31 08:43:43.903509	
6501	gaadimech 	9785693640	2025-07-21 10:00:00	Needs Followup	Karoli etios claim	2025-04-21 11:57:39.593329	6	2025-05-31 08:43:23.449024	
6565	Customer 	9829050801	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:02:31.55616	4	2025-05-31 08:43:31.574711	
6508	Customer 	9829013433	2025-07-23 10:00:00	Needs Followup		2025-04-21 12:25:48.342509	6	2025-05-31 08:43:31.574711	
5839	gaadimech 	9587918963	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-04-11 07:11:21.551392	6	2025-05-31 08:43:47.842094	
6559	Customer 	9829030580	2025-07-23 10:00:00	Needs Followup		2025-04-22 09:59:30.602268	6	2025-05-31 08:43:31.574711	
5842	gaadimech 	8209826882	2025-07-24 10:00:00	Needs Followup	Beat suspension 	2025-04-11 07:22:47.875617	6	2025-05-31 08:43:35.995616	
6111	gaadimech 	9460301700	2025-07-24 10:00:00	Needs Followup	Fortuner washing charge 400 jyada hai price	2025-04-16 09:00:50.105184	6	2025-05-31 08:43:35.995616	
6514	Customer 	9829033104	2025-07-24 10:00:00	Needs Followup		2025-04-21 12:28:46.38537	6	2025-05-31 08:43:35.995616	
5841	gaadimech 	9351742589	2025-07-27 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-04-11 07:18:20.176039	6	2025-05-31 08:43:47.842094	
6563	Customer 	9829014967	2025-07-24 10:00:00	Needs Followup		2025-04-22 10:01:25.602885	6	2025-05-31 08:43:35.995616	
6371	gaadimech 	9782136006	2025-07-27 10:00:00	Needs Followup	Call cut\r\n	2025-04-20 05:27:41.053094	6	2025-05-31 08:43:47.842094	
6373	gaadimech 	9772944553	2025-07-27 10:00:00	Needs Followup	Micra 2999	2025-04-20 05:28:43.727191	6	2025-05-31 08:43:47.842094	
7072	Cx1183	8003722685	2025-07-28 10:00:00	Needs Followup	Wr service 2599	2025-05-10 09:36:20.403102	6	2025-05-31 08:43:51.744985	
6561	Customer 	9829058337	2025-07-19 10:00:00	Needs Followup		2025-04-22 10:00:25.935023	4	2025-05-31 08:43:14.897002	
6372	gaadimech 	9079256432	2025-07-30 18:30:00	Did Not Pick Up	Kwid 2699\r\nClutch plate charge bht jyada h islye nhi krwana	2025-04-20 05:28:04.315874	6	2025-05-23 10:10:49.489385	
3987	.	7790927812	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-02-12 10:13:46.247499	4	2025-05-31 08:42:34.144665	
6513	Customer 	9636778779	2025-07-14 10:00:00	Needs Followup		2025-04-21 12:28:17.365823	4	2025-05-31 08:42:54.38585	
3765	.	8107267508	2025-07-03 18:30:00	Needs Followup	Call end 	2025-02-05 08:55:58.705632	4	2025-07-02 09:03:50.78726	
5843	gaadimech 	9314197508	2025-07-07 10:00:00	Needs Followup	Figo 3399 d	2025-04-11 10:30:23.39639	4	2025-05-31 08:42:26.111514	
6374	gaadimech 	9116337516	2025-07-21 10:00:00	Needs Followup	Verna 3399	2025-04-20 06:28:33.008901	6	2025-05-31 08:43:23.449024	
6375	gaadimech 	6378774567	2025-07-21 10:00:00	Needs Followup	Call cut	2025-04-20 06:28:56.009684	6	2025-05-31 08:43:23.449024	
7144	Cx2003	8882125658	2025-07-26 10:00:00	Needs Followup	Wr service 2599	2025-05-13 07:02:01.952445	4	2025-05-31 08:43:43.903509	
5281	gaadimech 	7339749299	2025-07-27 10:00:00	Needs Followup	Dzire Dent paint 	2025-03-30 06:38:42.555392	6	2025-05-31 08:43:47.842094	
6142	Customer 	8112279728	2025-07-27 10:00:00	Needs Followup	Thar 5199	2025-04-16 12:20:59.9494	6	2025-05-31 08:43:47.842094	
6113	Customer 	9829213700	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 11:57:27.375576	4	2025-05-31 08:42:50.438237	
5844	gaadimech	9079341238	2025-08-21 18:30:00	Did Not Pick Up	ECCO van 2000 panel charge\r\nNot interested 	2025-04-11 12:15:56.279348	6	2025-04-24 12:15:38.640556	
7731	gaadimech	9784947926	2025-07-24 18:30:00	Did Not Pick Up	Not pick\r\nNot interested mene koi inquiry nahi ki	2025-06-29 04:49:34.392927	6	2025-06-30 07:35:23.452119	
6145	Customer 	9314608551	2025-07-14 10:00:00	Needs Followup	Grand vitara 3399	2025-04-16 12:24:29.504042	6	2025-05-31 08:42:54.38585	
6154	Customer 	9352245660	2025-07-14 10:00:00	Needs Followup	Amaze 3199\r\nThar 5199	2025-04-16 12:31:42.553698	6	2025-05-31 08:42:54.38585	
6152	Customer 	9314565360	2025-07-16 10:00:00	Needs Followup	Eco sports 2899	2025-04-16 12:29:48.970613	4	2025-05-31 08:43:02.994951	
6378	Customer 	9829051411	2025-07-17 10:00:00	Needs Followup		2025-04-20 07:39:02.414782	4	2025-05-31 08:43:06.869056	
5154	Cx565	9414071612	2025-07-19 10:00:00	Needs Followup	Swift 	2025-03-27 07:44:27.170728	6	2025-05-31 08:43:14.897002	
6521	Cx1121	9799809240	2025-07-25 10:00:00	Needs Followup	Honda City \r\n3699	2025-04-22 05:54:42.980945	6	2025-05-31 08:43:39.880052	
6434	Customer 	9829065652	2025-07-20 10:00:00	Needs Followup		2025-04-21 08:55:45.258538	4	2025-05-31 08:43:19.077196	
6524	Cx1122	7426981707	2025-07-20 10:00:00	Needs Followup	Dent paint 	2025-04-22 05:59:08.969854	4	2025-05-31 08:43:19.077196	
6526	Cx1125	8209735206	2025-07-20 10:00:00	Needs Followup	Creta 4199\r\nAjmer road 	2025-04-22 06:06:23.639334	4	2025-05-31 08:43:19.077196	
6533	Customer 	9414069726	2025-07-20 10:00:00	Needs Followup		2025-04-22 06:57:16.037307	4	2025-05-31 08:43:19.077196	
7002	Customer 	9829502065	2025-07-20 10:00:00	Needs Followup		2025-05-08 11:20:21.832478	6	2025-05-31 08:43:19.077196	
6535	Customer 	9829262781	2025-07-23 10:00:00	Needs Followup		2025-04-22 07:05:51.049859	4	2025-05-31 08:43:31.574711	
6382	Customer 	9829099667	2025-07-26 10:00:00	Needs Followup		2025-04-20 07:41:17.185849	6	2025-05-31 08:43:43.903509	
5286	gaadimech 	9828655333	2025-07-27 10:00:00	Needs Followup	Tata zest 3599 switch off\r\nNot interested 	2025-03-30 06:58:53.81781	6	2025-05-31 08:43:47.842094	
6381	Customer 	9829056390	2025-07-23 10:00:00	Needs Followup		2025-04-20 07:40:46.298072	6	2025-05-31 08:43:31.574711	
6541	Customer 	9414042711	2025-07-23 10:00:00	Needs Followup		2025-04-22 07:29:38.396252	6	2025-05-31 08:43:31.574711	
6993	Customer 	9718768444	2025-07-23 10:00:00	Needs Followup	Vitrus 4499	2025-05-08 11:11:29.985364	6	2025-05-31 08:43:31.574711	
5284	gaadimech 	9166271323	2025-07-24 10:00:00	Needs Followup	Alto 2499 not pick 	2025-03-30 06:56:38.353492	4	2025-05-31 08:43:35.995616	
759	Kamal sharma 	7790909779	2025-07-23 10:00:00	Needs Followup	Eon h dent pent 1999 btaye h mine per pannel next Monday ko visit pr aayenge ydi shi lga to dent krwayenfe\r\nNot required 	2024-12-02 04:50:36	6	2025-05-31 08:43:31.574711	
5287	gaadimech 	7023545406	2025-07-24 10:00:00	Needs Followup	Not pick \r\n	2025-03-30 07:11:10.339424	4	2025-05-31 08:43:35.995616	
5289	gaadimech 	9351470172	2025-07-24 10:00:00	Needs Followup	Alto K10 2499 with air filter \r\nWithout air filter 1999	2025-03-30 07:27:15.635063	4	2025-05-31 08:43:35.995616	
5291	gaadimech 	9694128098	2025-07-24 10:00:00	Needs Followup	Alto cooling issue\r\nNot interested 	2025-03-30 07:29:29.989917	4	2025-05-31 08:43:35.995616	
6380	Customer 	9828024212	2025-07-09 10:00:00	Needs Followup		2025-04-20 07:40:21.578094	4	2025-05-31 08:42:34.144665	
5846	gaadimech	9119297994	2025-07-24 10:00:00	Needs Followup	Santro 2399	2025-04-12 05:04:38.063607	6	2025-05-31 08:43:35.995616	
6387	gaadimech 	7023081175	2025-07-24 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-20 09:56:55.410945	6	2025-05-31 08:43:35.995616	
5296	gaadimech 	9887147127	2025-07-27 10:00:00	Needs Followup	Call cut\r\nNot interested 	2025-03-30 07:47:39.578665	6	2025-05-31 08:43:47.842094	
6517	Cx1118	9828155381	2025-07-25 10:00:00	Needs Followup	Sunny service 3999	2025-04-22 05:29:36.150359	6	2025-05-31 08:43:39.880052	
6519	Cx1119	9414477693	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-22 05:49:39.673308	6	2025-05-31 08:43:39.880052	
6388	gaadimech 	9999638702	2025-07-27 10:00:00	Needs Followup	Not interested 	2025-04-20 10:01:05.672307	6	2025-05-31 08:43:47.842094	
5288	Customer 	9660886957	2025-07-04 10:00:00	Needs Followup		2025-03-30 07:27:00.264081	4	2025-05-31 08:42:14.037958	
5294	Customer 	7728078522	2025-07-06 10:00:00	Needs Followup	Tata nexon 3899	2025-03-30 07:34:05.242105	6	2025-05-31 08:42:22.030114	
5559	Cx630	9928070403	2025-07-18 10:00:00	Needs Followup	Xuv300 \r\n3899 package \r\nNo save hai mai call kar loga	2025-04-06 08:36:28.859379	4	2025-05-31 08:43:10.854377	
6386	gaadimech 	9829380888	2025-07-30 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-04-20 09:55:19.178939	6	2025-05-03 07:26:03.468109	
6534	Cx1117	9950227724	2025-07-18 10:00:00	Needs Followup	Xuv400\r\nDent paint 	2025-04-22 07:03:10.964072	4	2025-05-31 08:43:10.854377	
4012	.	9314507660	2025-07-18 18:30:00	Did Not Pick Up	Kch hoga to btayenge\r\nNot interested 	2025-02-12 11:40:38.378261	6	2025-07-02 11:37:56.105958	
7187	gaadimech 	8302295315	2025-07-29 18:30:00	Confirmed	Maruti XL6 dent paint pickup tomorrow \r\nTonk road 	2025-05-14 11:28:44.895463	9	2025-07-01 08:24:23.833486	
4010	.	9929522296	2025-07-10 18:30:00	Did Not Pick Up	Not pick	2025-02-12 11:34:10.104762	6	2025-07-02 11:38:49.544577	
5847	gaadimech 	8209691838	2025-07-08 10:00:00	Needs Followup	Wognor cng ges syply nor work	2025-04-12 05:23:02.257787	4	2025-05-31 08:42:30.087566	
5292	Customer 	9414381566	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-03-30 07:29:57.2122	6	2025-05-31 08:42:30.087566	
6379	Customer 	9829092548	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-20 07:39:40.380373	4	2025-05-31 08:42:54.38585	
6516	Cx1117	9829812233	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-22 05:25:57.602221	6	2025-05-31 08:43:10.854377	
6520	Cx1120	9783708270	2025-07-18 10:00:00	Needs Followup	Swift Dzire \r\n2899\r\nService 	2025-04-22 05:50:55.032116	6	2025-05-31 08:43:10.854377	
6523	Cx1123	8486662132	2025-07-18 10:00:00	Needs Followup	Call cut 	2025-04-22 05:58:14.623033	6	2025-05-31 08:43:10.854377	
6525	Cx1123	7014758179	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-22 06:03:31.608277	6	2025-05-31 08:43:10.854377	
4014	.	9828114717	2025-08-13 18:30:00	Did Not Pick Up	Not interested \r\nNew car hai free service due 	2025-02-12 11:46:45.668445	6	2025-03-20 10:23:41.260117	
6158	Cx689	7738093886	2025-07-20 10:00:00	Needs Followup	Ac service 	2025-04-17 05:08:26.739593	4	2025-05-31 08:43:19.077196	
4000	Ashok Sharma	9828315905	2025-07-15 10:00:00	Needs Followup	Alto swift, Unanswered 	2025-02-12 10:51:06.536311	6	2025-05-31 08:42:58.621937	
6155	Scorpio dent paint 	9799191919	2025-07-18 10:00:00	Needs Followup	Scorpio dent pent 28000	2025-04-17 05:05:49.943737	6	2025-05-31 08:43:10.854377	
5301	gaadimech 	8005667566	2025-07-27 10:00:00	Needs Followup	Tata punch ac service \r\nBusy call u later 	2025-03-30 08:49:23.596345	6	2025-05-31 08:43:47.842094	
5850	gaadimech	9460380502	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-12 06:18:46.642479	6	2025-05-31 08:43:35.995616	
3995	.	6377415707	2025-07-21 10:00:00	Needs Followup	Not requirement 	2025-02-12 10:27:24.317876	4	2025-05-31 08:43:23.449024	
6160	Cx691	7827731625	2025-07-18 10:00:00	Needs Followup	Etios car service \r\nCall cut	2025-04-17 05:09:36.629655	6	2025-05-31 08:43:10.854377	
6163	Cx 692	9680498073	2025-07-18 10:00:00	Needs Followup	Service Swift. 2999\r\nAjmer ka rehne wala hu 	2025-04-17 05:11:58.778764	6	2025-05-31 08:43:10.854377	
7117	Cx1196	8290780403	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-13 04:30:46.168442	6	2025-05-31 08:43:51.744985	
6162	Vki 	9928716067	2025-07-20 10:00:00	Needs Followup	Wr 2599\r\nVki	2025-04-17 05:11:16.492291	4	2025-05-31 08:43:19.077196	
7108	Cx1185	9001199933	2025-07-20 10:00:00	Needs Followup	Sannet  bumper paint 	2025-05-12 05:56:04.543012	6	2025-05-31 08:43:19.077196	
6161	Cx692	7412052275	2025-07-27 10:00:00	Needs Followup	Sharp motor \r\nCar service 	2025-04-17 05:10:23.214209	6	2025-05-31 08:43:47.842094	
7109	Cx1190	7891840255	2025-07-20 10:00:00	Needs Followup	S cross 	2025-05-12 05:57:14.320901	6	2025-05-31 08:43:19.077196	
7127	Cx1199	9829065028	2025-07-26 10:00:00	Needs Followup	Call cut	2025-05-13 05:14:15.915047	4	2025-05-31 08:43:43.903509	
4009	।	7688863791	2025-07-21 10:00:00	Needs Followup	Call cut	2025-02-12 11:33:16.573563	4	2025-05-31 08:43:23.449024	
5852	gaadimech 	9887052103	2025-07-21 10:00:00	Needs Followup	I20 2999	2025-04-12 06:54:12.973396	6	2025-05-31 08:43:23.449024	
6156	Ac service 	9602640686	2025-07-25 10:00:00	Needs Followup	Ac service 	2025-04-17 05:06:52.894105	6	2025-05-31 08:43:39.880052	
7128	Cx2001	7229909965	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 05:15:00.587436	4	2025-05-31 08:43:43.903509	
5854	gaadimech 	7300110151	2025-07-24 10:00:00	Needs Followup	Vitara Brezza  dent paint sharp	2025-04-12 06:55:56.202133	6	2025-05-31 08:43:35.995616	
6453	Customer 	9828011666	2025-07-24 10:00:00	Needs Followup		2025-04-21 09:46:46.776737	6	2025-05-31 08:43:35.995616	
6531	Customer 	9351430756	2025-07-24 10:00:00	Needs Followup	Duster 3999	2025-04-22 06:44:56.27572	6	2025-05-31 08:43:35.995616	
6157	Cx683	9289389315	2025-07-25 10:00:00	Needs Followup	Ac service 	2025-04-17 05:07:49.503877	6	2025-05-31 08:43:39.880052	
6159	Cx690	8875569414	2025-07-25 10:00:00	Needs Followup	Ac service 	2025-04-17 05:08:59.59835	6	2025-05-31 08:43:39.880052	
7136	Cx2004	8290780403	2025-07-26 10:00:00	Needs Followup	Dzire service 	2025-05-13 06:57:19.925039	4	2025-05-31 08:43:43.903509	
7139	Cx2006	8882125658	2025-07-26 10:00:00	Needs Followup	Wr service 2599	2025-05-13 06:58:02.703655	4	2025-05-31 08:43:43.903509	
7140	Cx2006	8882125658	2025-07-26 10:00:00	Needs Followup	Wr service 2599	2025-05-13 06:58:10.236694	4	2025-05-31 08:43:43.903509	
7186	gaadimech 	8112207372	2025-07-28 10:00:00	Needs Followup	Baleno 2799\r\nBhahr 2100 me service krke de rhe h	2025-05-14 11:27:42.486906	6	2025-05-31 08:43:51.744985	
3993	.	9571042418	2025-07-08 10:00:00	Needs Followup	Call cut not pick 	2025-02-12 10:25:16.356068	6	2025-05-31 08:42:30.087566	
3994	.	9001998813	2025-07-08 10:00:00	Needs Followup	Cll cut	2025-02-12 10:26:11.499451	6	2025-05-31 08:42:30.087566	
4007	.	8955579453	2025-07-08 10:00:00	Needs Followup	Call cut	2025-02-12 11:22:28.495279	6	2025-05-31 08:42:30.087566	
4001	.	9672724188	2025-09-25 18:30:00	Did Not Pick Up	Ertiga 2899\r\nNear diwali service requirement hogi	2025-02-12 10:54:08.955624	6	2025-03-09 08:45:38.616484	
3999	anjani medical 	9887419843	2025-08-07 18:30:00	Needs Followup	Baleno 2499\r\nNano 2000 not pick \r\nService done by kp 	2025-02-12 10:49:42.234861	6	2025-06-29 09:25:21.298154	
3681	.	9413342912	2025-06-30 18:30:00	Needs Followup	Only company mai 	2025-02-04 08:21:25.650869	4	2025-07-02 09:08:22.991388	
6216	Customer 	9214300998	2025-07-21 10:00:00	Needs Followup	Not interested 	2025-04-17 10:50:02.301412	6	2025-05-31 08:43:23.449024	
4641	Cx502	9314753912	2025-07-17 10:00:00	Needs Followup	Tata tiago 2699	2025-03-10 10:52:12.383393	4	2025-05-31 08:43:06.869056	
7110	Cx1191	9509742300	2025-07-26 10:00:00	Needs Followup	Eceo 2899	2025-05-12 05:59:38.938959	4	2025-05-31 08:43:43.903509	
7112	Vc1191	9414991973	2025-07-26 10:00:00	Needs Followup	Voice call 	2025-05-13 04:19:52.846984	4	2025-05-31 08:43:43.903509	
4638	Cx490	9057434523	2025-07-06 10:00:00	Needs Followup	Dent paint \r\nCall cut	2025-03-10 10:47:32.283145	6	2025-05-31 08:42:22.030114	
3344	Customer 	9829062115	2025-07-17 18:30:00	Confirmed	Not picking 	2025-01-24 04:17:20.62172	9	2025-07-03 05:24:26.54301	\N
4655	Cx589	9649946768	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-11 05:29:51.768323	6	2025-05-31 08:42:22.030114	
4672	Wr 	9782158200	2025-07-06 10:00:00	Needs Followup	Wr car service 	2025-03-11 12:32:46.889084	6	2025-05-31 08:42:22.030114	
5305	Ashish g	9549301222	2025-07-03 10:00:00	Needs Followup		2025-03-30 10:58:00.150351	6	2025-05-31 08:42:09.584832	
5307	Vk gupta 	9829538080	2025-07-08 10:00:00	Needs Followup	Not interested 	2025-03-30 10:59:10.76719	6	2025-05-31 08:42:30.087566	
4656	Cx590	9828099992	2025-07-14 10:00:00	Needs Followup	Car service 	2025-03-11 05:30:28.10356	4	2025-05-31 08:42:54.38585	
4633	Cx491	9179969861	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-10 10:40:35.401583	6	2025-05-31 08:42:17.990214	
4627	gaadimech 	8003268751	2025-07-14 10:00:00	Needs Followup	Ertiga 2899 banipark\r\nCall cut	2025-03-09 11:55:28.66755	4	2025-05-31 08:42:54.38585	
4634	Cx483	9828019003	2025-07-05 10:00:00	Needs Followup	Service scross\r\n2999	2025-03-10 10:42:19.555987	6	2025-05-31 08:42:17.990214	
4630	gaadimech 	6375117572	2025-07-16 10:00:00	Needs Followup	Swift ac work \r\nNot interested 	2025-03-09 12:17:48.952352	4	2025-05-31 08:43:02.994951	
4636	Cx489	9419032421	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-10 10:45:24.794466	6	2025-05-31 08:43:06.869056	
4635	Cx485	8872314523	2025-07-05 10:00:00	Needs Followup	Honda City 	2025-03-10 10:43:47.775639	6	2025-05-31 08:42:17.990214	
4643	Tavera 	9782803348	2025-07-17 10:00:00	Needs Followup	Tavera 	2025-03-10 10:54:29.742958	6	2025-05-31 08:43:06.869056	
4648	Cx585	7988217922	2025-07-17 10:00:00	Needs Followup	Ac compressor \r\nCall cut	2025-03-11 05:22:10.771238	6	2025-05-31 08:43:06.869056	
4654	Cx588	7665532513	2025-07-17 10:00:00	Needs Followup	Car abhi gav hai 	2025-03-11 05:28:57.734996	6	2025-05-31 08:43:06.869056	
4704	gaadimech 	9783846675	2025-07-21 10:00:00	Needs Followup	Busy call u later \r\n1800 me maruti kr rhi h service	2025-03-13 06:29:35.958911	4	2025-05-31 08:43:23.449024	
4707	ivr	8955918842	2025-07-21 10:00:00	Needs Followup	TIYAGO 2899	2025-03-13 07:24:43.049412	4	2025-05-31 08:43:23.449024	
5302	gaadimech 	9413062523	2025-07-18 18:30:00	Did Not Pick Up	Honda jazz 3199\r\nNot interested\r\nNot pick 	2025-03-30 08:51:00.170085	6	2025-06-28 08:07:48.958476	
7113	Cx1192	8107765488	2025-07-26 10:00:00	Needs Followup	Abhi nahi 	2025-05-13 04:21:34.101073	4	2025-05-31 08:43:43.903509	
4720	.	9829015395	2025-07-21 10:00:00	Needs Followup	Not pick\r\nCall cut	2025-03-13 11:00:11.980942	4	2025-05-31 08:43:23.449024	
4724	.	9725455545	2025-07-21 10:00:00	Needs Followup	Switch off \r\nNot requirement 	2025-03-13 11:03:53.863536	4	2025-05-31 08:43:23.449024	
4687	gaadimech 	9680396012	2025-07-24 10:00:00	Needs Followup	By mistake hua hai mene koi inquiry nhi ki \r\nCall cut	2025-03-12 06:11:37.815056	4	2025-05-31 08:43:35.995616	
4725	.	9983215431	2025-07-24 10:00:00	Needs Followup	Not pick	2025-03-13 11:04:37.73689	4	2025-05-31 08:43:35.995616	
7111	Cx1190	9924700499	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 04:19:11.180146	4	2025-05-31 08:43:43.903509	
4705	gaadimech 	9116032619	2025-07-27 10:00:00	Needs Followup	Not requirement jarurt hogi to contact kr lunga\r\nDon't have car	2025-03-13 06:31:38.417393	4	2025-05-31 08:43:47.842094	
4716	.	9414058729	2025-07-27 10:00:00	Needs Followup	Call cut	2025-03-13 10:56:19.688934	4	2025-05-31 08:43:47.842094	
4721	.	9829011357	2025-07-27 10:00:00	Needs Followup	Call cut	2025-03-13 11:01:01.822209	4	2025-05-31 08:43:47.842094	
4731	.	9829063045	2025-07-27 10:00:00	Needs Followup	Call cut\r\nNot interested 	2025-03-13 11:13:28.670663	4	2025-05-31 08:43:47.842094	
3482	Carlust automotive 	7891120152	2025-07-30 18:30:00	Feedback	Celerio\r\nBumper paint \r\nFender Dent paint 	2025-01-27 07:48:39.446419	9	2025-07-01 07:39:48.708634	RJ45CZ2633
4659	gaadimech 	8839108981	2025-07-18 10:00:00	Needs Followup	Alto ac checkup 999\r\nDelhi me kam karwa lia	2025-03-11 07:43:22.536716	4	2025-05-31 08:43:10.854377	
4675	gaadimech 	8058229897	2025-07-18 10:00:00	Needs Followup	Xcent 2899	2025-03-12 04:27:39.874835	4	2025-05-31 08:43:10.854377	
4673	Cx597	9057578296	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 12:33:23.699118	6	2025-05-31 08:42:17.990214	
4708	gaadimech	9982460928	2025-07-08 10:00:00	Needs Followup	Kwid 2399	2025-03-13 08:22:20.88951	4	2025-05-31 08:42:30.087566	
4695	.	8949822286	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-03-12 11:21:29.863659	4	2025-05-31 08:42:54.38585	
4688	gaadimech 	9680269716	2025-07-18 10:00:00	Needs Followup	Corolla dent paint full body  28000	2025-03-12 09:41:42.600139	4	2025-05-31 08:43:10.854377	
4694	.	8949822286	2025-07-18 10:00:00	Needs Followup	Not interested 	2025-03-12 11:20:12.892745	4	2025-05-31 08:43:10.854377	
4681	gaadimech 	8005671279	2025-08-21 18:30:00	Did Not Pick Up	Datsun go 2199\r\nService done other workshop 	2025-03-12 05:06:53.112595	6	2025-03-18 08:27:25.651206	
4696	.	7073009912	2025-07-16 18:30:00	Needs Followup	Brezza service done company workshop 	2025-03-12 11:29:11.523278	6	2025-03-18 05:32:24.700888	
4702	.	9602849363	2025-07-25 18:30:00	Did Not Pick Up	Not interested 	2025-03-12 11:44:46.02964	6	2025-05-23 10:44:42.252785	
4692	.	9950798309	2026-01-30 18:30:00	Did Not Pick Up	Not required 	2025-03-12 11:16:24.491901	6	2025-04-04 11:16:11.967211	
4738	.	9799252930	2025-07-24 10:00:00	Needs Followup	Call cut	2025-03-13 11:39:08.816323	4	2025-05-31 08:43:35.995616	
7115	Cx1195	9509742300	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 04:28:42.798967	4	2025-05-31 08:43:43.903509	
7118	Cx1198	7611823420	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 04:35:52.666297	4	2025-05-31 08:43:43.903509	
4740	.	7427802081	2025-07-27 10:00:00	Needs Followup	Not pick\r\nDon't have car 	2025-03-13 11:45:31.854335	4	2025-05-31 08:43:47.842094	
4743	.	9660594444	2025-07-27 10:00:00	Needs Followup	Not pick\r\nDon't have car 	2025-03-13 11:51:58.948513	4	2025-05-31 08:43:47.842094	
7114	Cx1193	8824825254	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-13 04:22:03.001301	6	2025-05-31 08:43:51.744985	
7116	Cx1194	9667777542	2025-07-28 10:00:00	Needs Followup	Dent paint 	2025-05-13 04:30:00.743157	6	2025-05-31 08:43:51.744985	
3576	.	9414076900	2025-07-08 18:30:00	Needs Followup	Abhi need nahi hai 	2025-01-31 11:39:32.99819	4	2025-06-30 08:12:20.956563	
4744	.	6375623060	2025-08-14 18:30:00	Did Not Pick Up	Baleno 2799 service done	2025-03-13 11:53:40.521517	6	2025-03-27 09:31:25.494534	
4732	.	9829063045	2025-07-05 10:00:00	Needs Followup	Not pick	2025-03-13 11:14:16.902047	6	2025-05-31 08:42:17.990214	
4736	.	9414071458	2025-07-18 10:00:00	Needs Followup	Out of jaipur\r\nCall cut	2025-03-13 11:37:00.864087	4	2025-05-31 08:43:10.854377	
4750	Cx589	9694128021	2026-03-18 18:30:00	Needs Followup	Ac service 	2025-03-15 11:11:10.953585	4	2025-03-17 05:31:37.611299	
4746	Cx583	7297015298	2025-07-05 10:00:00	Needs Followup	Call cut 	2025-03-15 11:06:38.857315	6	2025-05-31 08:42:17.990214	
4741	.	8209410061	2025-07-18 18:30:00	Did Not Pick Up	Not pick	2025-03-13 11:46:36.636981	6	2025-06-30 09:35:54.047731	
2232	.	9351100070	2025-07-11 18:30:00	Did Not Pick Up	Not requirement 	2024-12-20 08:28:57.743192	6	2025-06-29 11:21:45.471503	
2231	.	9928087873	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:24:06.594282	
2230	.	9929441494	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 04:42:01.100851	6	2025-06-29 11:29:26.764682	
2228	.	9829609746	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 04:42:01.100851	6	2025-06-29 11:36:31.870591	
2229	.	9829216070	2025-07-18 18:30:00	Did Not Pick Up	Call cut	2024-12-20 04:42:01.100851	6	2025-06-29 11:34:52.411434	
2225	.	8290840916	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 04:42:01.100851	6	2025-06-29 11:38:43.227773	
2223	.	9828010050	2025-07-24 18:30:00	Did Not Pick Up	Not requirement 	2024-12-20 04:42:01.100851	6	2025-06-29 11:39:27.121144	
2224	.	9785676014	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 04:42:01.100851	6	2025-06-29 11:42:45.135595	
2227	.	9950996904	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 04:42:01.100851	6	2025-06-29 11:43:50.552586	
4737	.	9829029180	2025-07-18 18:30:00	Needs Followup	Call cut	2025-03-13 11:37:43.9873	6	2025-06-30 09:36:50.310984	
2199	.	9828050222	2025-07-29 00:00:00	Needs Followup	Busy 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
271	Avinash Sharma 	9828015057	2025-07-11 18:30:00	Did Not Pick Up	What's app details share \r\nNot picke	2024-11-25 11:37:32	6	2025-07-01 11:39:11.259352	
216	.	8107769902	2025-07-18 18:30:00	Did Not Pick Up	Not required 	2024-11-25 06:10:01	6	2025-07-01 11:47:25.999865	
204	.	9664312727	2025-07-11 18:30:00	Did Not Pick Up	Car sale out\r\nNot pick	2024-11-24 11:59:41	6	2025-07-01 11:48:50.689304	
7728	gaadiench	8739892833	2025-07-03 18:30:00	Did Not Pick Up	Call cut	2025-06-29 04:24:28.188544	6	2025-07-02 10:33:38.95042	
4034	.	9784773640	2025-07-02 18:30:00	Needs Followup	Car service 	2025-02-15 07:53:42.645125	4	2025-06-30 06:49:16.678486	
260	Jitendra sir	9784370603	2025-07-23 10:00:00	Needs Followup	What's app details share \r\nNot interested 	2024-11-25 09:15:50	6	2025-05-31 08:43:31.574711	
285	.	7737199721	2025-07-23 10:00:00	Needs Followup	What's app details share \r\nNot interested 	2024-11-25 12:45:17	6	2025-05-31 08:43:31.574711	
288	Hemraj sir	9660488886	2025-07-23 10:00:00	Needs Followup	Busy call u letter\r\nNot interested 	2024-11-26 05:56:36	6	2025-05-31 08:43:31.574711	
3226	Customer 	9503841580	2025-07-09 18:30:00	Needs Followup	Abhi nahi	2025-01-20 04:31:19.397625	4	2025-06-30 08:20:59.092607	
290	Sunil sir	9982286430	2025-07-04 10:00:00	Needs Followup	What's app details share \r\nSwift 2599 not requirement 	2024-11-26 07:02:49	4	2025-05-31 08:42:14.037958	
483	.....	7014347872	2025-07-08 10:00:00	Needs Followup	Abhi busy hu\r\nNot pick 	2024-11-28 06:03:20	4	2025-05-31 08:42:30.087566	
4032	.	9782626569	2025-07-02 18:30:00	Needs Followup	Abhi nahi karwani 	2025-02-15 07:44:42.272254	4	2025-06-28 11:51:40.612308	
4006	.	9414043186	2025-07-02 18:30:00	Needs Followup	Jeep compass 	2025-02-12 11:20:41.132771	4	2025-06-28 12:39:02.872542	
4005	.	9829061611	2025-07-10 18:30:00	Needs Followup	Car service 	2025-02-12 11:19:22.133249	4	2025-06-28 12:50:34.046818	
3395	.	9829127289	2025-07-11 18:30:00	Did Not Pick Up	Not interested 	2025-01-25 04:07:13.578442	6	2025-06-29 09:43:34.994326	
3150	Customer	9610666419	2025-07-11 18:30:00	Did Not Pick Up	Not interested 	2025-01-19 09:01:07.792367	6	2025-06-29 10:53:25.266123	
2256	.	9560255990	2025-07-17 18:30:00	Did Not Pick Up	Not interested & cut a call 	2024-12-20 08:28:57.743192	6	2025-06-29 10:59:19.912167	
2255	.	9772991215	2025-07-25 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 10:59:47.955468	
2254	.	9829212864	2025-07-24 18:30:00	Did Not Pick Up	Only company me service 	2024-12-20 08:28:57.743192	6	2025-06-29 11:00:35.361958	
2253	.	9414048698	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-20 08:28:57.743192	6	2025-06-29 11:02:29.246119	
2251	.	9166645843	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-20 08:28:57.743192	6	2025-06-29 11:04:10.834128	
2249	.	9828575368	2025-07-11 18:30:00	Did Not Pick Up	Not interested 	2024-12-20 08:28:57.743192	6	2025-06-29 11:04:48.567014	
2248	.	9928772605	2025-07-11 18:30:00	Did Not Pick Up	Not requirement 	2024-12-20 08:28:57.743192	6	2025-06-29 11:05:20.358801	
2247	.	9829936367	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:05:53.407164	
2246	.	9928089570	2025-07-09 18:30:00	Did Not Pick Up	Not pick	2024-12-20 08:28:57.743192	6	2025-06-29 11:06:23.63673	
2245	.	9460578539	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:07:00.213441	
2244	.	9602794011	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-20 08:28:57.743192	6	2025-06-29 11:07:40.0241	
2243	.	9414461047	2025-07-17 18:30:00	Did Not Pick Up	Not interested 	2024-12-20 08:28:57.743192	6	2025-06-29 11:08:19.432293	
2242	.	9529220924	2025-07-17 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:08:58.98697	
2241	.	9784809551	2025-07-18 18:30:00	Did Not Pick Up	New car free service due \r\nCall cut	2024-12-20 08:28:57.743192	6	2025-06-29 11:09:53.409814	
2240	.	9414052156	2025-07-18 18:30:00	Did Not Pick Up	Not requirement 	2024-12-20 08:28:57.743192	6	2025-06-29 11:11:45.150475	
2239	.	9829136985	2025-07-11 18:30:00	Did Not Pick Up	Not interested \r\nNot pick \r\nMotorcycle chalata hu	2024-12-20 08:28:57.743192	6	2025-06-29 11:12:29.834505	
2257	.	7821807007	2025-07-18 18:30:00	Did Not Pick Up	Car out of Jaipur 	2024-12-20 08:28:57.743192	6	2025-06-29 11:13:26.420818	
2238	.	9352244733	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:14:16.29694	
2237	.	9414074190	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:16:19.848556	
2236	.	9468763961	2025-07-25 18:30:00	Did Not Pick Up	Not interested \r\nNot interested 	2024-12-20 08:28:57.743192	6	2025-06-29 11:18:09.464679	
2235	.	9314814235	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:18:37.958	
2234	.	7976074212	2025-07-18 18:30:00	Did Not Pick Up	Not requirement 	2024-12-20 08:28:57.743192	6	2025-06-29 11:19:41.127992	
321	Coustmer 	9950355544	2025-07-25 18:30:00	Needs Followup	Call cut	2024-11-26 11:16:10	6	2025-07-01 11:37:27.230551	
7729	gaadimech	9782041862	2025-07-04 18:30:00	Did Not Pick Up	Volvo 15999 call cut busy 	2025-06-29 04:38:33.384237	6	2025-07-02 10:32:46.012705	
248	Rakesh sir 	9694229559	2026-06-25 18:30:00	Needs Followup	New car 	2024-11-25 08:05:02	6	2025-03-17 12:12:45.285072	
7123	gaadimech	8890233313	2025-07-22 10:00:00	Needs Followup	Kwid 2699 not pick	2025-05-13 04:55:08.848678	6	2025-05-31 08:43:27.624295	
377	.	9829414551	2025-07-26 10:00:00	Needs Followup	Not interested 	2024-11-27 07:21:40	6	2025-05-31 08:43:43.903509	
386	Sanjay ji 	9414513581	2025-07-26 10:00:00	Needs Followup	Abhi 2 din pahle ho gai sarvice ab next sarvice pr c.b\r\nDon't have car \r\n	2024-11-27 07:21:40	6	2025-05-31 08:43:43.903509	
342	.	9414064314	2025-07-11 18:30:00	Did Not Pick Up	Call back 	2024-11-26 12:40:58	6	2025-06-29 11:48:10.055644	
329	Suraj	7728036238	2025-07-04 10:00:00	Needs Followup	Varna gadi h 2999 ka pack diya h abhi out of Rajas/than h 4 dec ko Jaipur aayenge tb c.b/abhi khi aaya Bua hu khud call kr lunga\r\nNot interested 	2024-11-26 11:35:22	4	2025-05-31 08:42:14.037958	
384	.	9828011871	2025-07-04 10:00:00	Needs Followup	Not interested 	2024-11-27 07:21:40	4	2025-05-31 08:42:14.037958	
373	.	9866089164	2025-07-06 10:00:00	Needs Followup	Cute a call	2024-11-27 07:21:40	4	2025-05-31 08:42:22.030114	
371	.	8233131051	2025-07-08 10:00:00	Needs Followup	Not interested distance jyada h agra road par rhte h\r\n	2024-11-27 07:21:40	4	2025-05-31 08:42:30.087566	
382	.	7976052733	2025-07-14 10:00:00	Needs Followup	Not interested\r\nService alredy done 	2024-11-27 07:21:40	6	2025-05-31 08:42:54.38585	
4579	gaadimech 	9660946013	2025-07-10 18:30:00	Needs Followup	Baleno 2499	2025-03-08 04:28:59.421856	4	2025-06-28 07:48:01.34199	
7163	gaadimech 	9366931292	2025-07-08 18:30:00	Did Not Pick Up	Out of jaipur\r\nNot pick	2025-05-14 05:35:08.068223	6	2025-06-30 08:23:51.486423	
4112	Cx	9829011544	2025-07-10 18:30:00	Needs Followup	Car service 	2025-02-16 10:51:46.546779	4	2025-06-30 06:42:56.315216	
404	.	7014476293	2025-08-15 18:30:00	Needs Followup	Cut a call\r\nCall cut\r\nCycle hai mere pass 	2024-11-27 11:01:48	6	2025-07-01 11:16:54.644981	
396	.	9828028087	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-11-27 07:21:40	6	2025-07-01 11:17:52.966422	
3596	prakash ji	9351062701	2025-08-19 18:30:00	Feedback	Not required not interested 	2025-02-01 04:09:42.798808	9	2025-07-03 05:42:53.672179	
7126	gaadimech	9664240322	2025-07-22 10:00:00	Needs Followup	BREZZA 3599 self call 	2025-05-13 05:07:48.588884	6	2025-05-31 08:43:27.624295	
4851	gaadimech	9166174427	2025-07-03 18:30:00	Needs Followup	Eon ac issue	2025-03-19 04:49:03.305174	4	2025-06-30 06:10:32.860157	
7730	gaadimech 	8800836587	2025-07-11 18:30:00	Did Not Pick Up	Not interested 	2025-06-29 04:46:51.685876	6	2025-06-29 04:46:51.685884	
7120	Cx1199	9116436693	2025-07-26 10:00:00	Needs Followup	Tata tiago 3199	2025-05-13 04:43:03.96281	4	2025-05-31 08:43:43.903509	
389	Arun Sharma 	7221942000	2026-02-25 18:30:00	Needs Followup	WhatsApp package shared \r\nCall cut\r\nNew car free service due	2024-11-27 07:21:40	6	2025-03-17 06:47:59.015559	
4803	gaadimech	9828171117	2025-07-02 18:30:00	Needs Followup	Bmw wednesday pickup 12000 package 	2025-03-17 08:45:41.661968	4	2025-06-28 07:07:30.375801	
4881	gaadimech 	9549541515	2025-07-17 18:30:00	Did Not Pick Up	Verna claim\r\nOut of jaipur hai	2025-03-20 08:52:24.227277	6	2025-06-28 10:37:46.034841	
4879	gaadimech	8239067551	2025-07-06 18:30:00	Did Not Pick Up	Vki ac check up swift	2025-03-20 07:27:02.675718	6	2025-06-28 10:38:32.892069	
4878	gaadimech	9166143510	2025-07-03 18:30:00	Did Not Pick Up	I20 ac chrckup	2025-03-20 06:46:25.074213	6	2025-06-28 10:45:51.923695	
7732	gaadimech 	8829039071	2025-07-04 18:30:00	Did Not Pick Up	Not pick\r\nCall cut 	2025-06-29 04:54:51.154438	6	2025-07-02 10:31:19.212211	
3597	parth baheti	7300033066	2025-07-30 18:30:00	Confirmed	Not picking 	2025-02-01 04:09:42.798808	9	2025-07-06 06:47:18.432716	
549	.........	9680193300	2025-07-20 10:00:00	Needs Followup	Not intrested 	2024-11-29 07:12:53	6	2025-05-31 08:43:19.077196	
529	.	9829058899	2025-07-02 10:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	4	2025-05-31 08:42:04.112745	
510	Sidharth jain	9828888666	2025-07-26 10:00:00	Needs Followup	Abhi need nhi\r\nCall cut	2024-11-28 06:03:20	6	2025-05-31 08:43:43.903509	
544	Anmol ji 	8003240353	2025-07-26 10:00:00	Needs Followup	Switch off\r\nNot interested 	2024-11-29 04:57:07	6	2025-05-31 08:43:43.903509	
503	.....	7878623231	2025-07-04 10:00:00	Needs Followup	Call Not pik	2024-11-28 06:03:20	4	2025-05-31 08:42:14.037958	
531	.	9549148437	2025-07-02 10:00:00	Needs Followup	Not interested & cut a call \r\nNot pick 	2024-11-28 12:42:48	4	2025-05-31 08:42:04.112745	
534	.	8003322999	2025-07-02 10:00:00	Needs Followup	Cut a call 	2024-11-28 12:42:48	4	2025-05-31 08:42:04.112745	
506	.	9351374748	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	4	2025-05-31 08:42:14.037958	
504	.....	7878623231	2025-07-14 10:00:00	Needs Followup	Call Not pik	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
500	.	9351637488	2025-07-08 10:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-11-28 06:03:20	4	2025-05-31 08:42:30.087566	
509	.	9314931184	2025-07-04 10:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	4	2025-05-31 08:42:14.037958	
564	........	9414066618	2025-07-08 10:00:00	Needs Followup	Not intrested 	2024-11-29 07:12:53	4	2025-05-31 08:42:30.087566	
545	...	9414052121	2025-07-06 10:00:00	Needs Followup	Abhi busy hu agle mhine me dekhenge	2024-11-29 04:57:07	4	2025-05-31 08:42:22.030114	
547	........	9928182900	2025-07-06 10:00:00	Needs Followup	Not intrested 	2024-11-29 06:32:08	4	2025-05-31 08:42:22.030114	
535	.	7014592481	2025-07-02 10:00:00	Needs Followup	Cut a call 	2024-11-28 12:42:48	4	2025-05-31 08:42:04.112745	
543	Javed sir	9352344392	2025-07-04 10:00:00	Needs Followup	 \r\nNot pick\r\nNot puck\r\nNot pick\r\nNot pick	2024-11-28 12:42:48	4	2025-05-31 08:42:14.037958	
505	.....	7878623231	2025-07-14 10:00:00	Needs Followup	Call Not pik\r\nCall cut	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
541	.	8823911911	2025-07-02 10:00:00	Needs Followup	Cut a call	2024-11-28 12:42:48	4	2025-05-31 08:42:04.112745	
546	Alesh gour 	9887422791	2025-07-04 10:00:00	Needs Followup	N.respons	2024-11-29 06:32:08	4	2025-05-31 08:42:14.037958	
502	.	9460326717	2025-07-08 10:00:00	Needs Followup	Busy 	2024-11-28 06:03:20	4	2025-05-31 08:42:30.087566	
524	.	9820247118	2025-07-08 10:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	4	2025-05-31 08:42:30.087566	
528	.	9311121145	2025-07-08 10:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	4	2025-05-31 08:42:30.087566	
508	.	9636367736	2025-07-14 10:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
558	.......	9414795333	2025-07-08 10:00:00	Needs Followup	Ciaz 2899 \r\nAbhi requirement nahi hai	2024-11-29 07:12:53	4	2025-05-31 08:42:30.087566	
525	.	9252693091	2025-07-14 10:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
526	...........	9680108080	2025-07-14 10:00:00	Needs Followup	Call Not pick	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
527	.	9829214443	2025-07-14 10:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
538	.	9928363127	2025-07-14 10:00:00	Needs Followup	Requirement hogi to bta Denge\r\nNot requirement \r\nI10 	2024-11-28 12:42:48	6	2025-05-31 08:42:54.38585	
5101	Rahul 	7877727432	2025-07-11 18:30:00	Did Not Pick Up	Not interested for now \r\nNot pick 	2025-03-26 10:02:10.208397	6	2025-06-28 09:14:23.248102	
5094	Customer 	9785895166	2025-08-22 18:30:00	Needs Followup	Etios 3399 \r\nNot interested 	2025-03-26 09:15:35.897324	6	2025-06-28 09:17:37.020642	
5065	gaadimech 	7792807868	2025-07-10 18:30:00	Did Not Pick Up	I10 2299 booking slot morning 9 am\r\nNot pick 	2025-03-26 05:12:07.796528	6	2025-06-28 10:08:21.373482	
4921	Triber	9426829415	2025-07-11 18:30:00	Did Not Pick Up	Triber-follow\r\nNot pick 	2025-03-21 07:35:43.147845	6	2025-06-28 10:28:55.068505	
4908	gaadimech 	7665112604	2025-07-17 18:30:00	Did Not Pick Up	Not pick 	2025-03-21 05:49:31.463003	6	2025-06-28 10:31:40.014348	
4882	gaadimech	8076631613	2025-07-10 18:30:00	Did Not Pick Up	Out of jaipur h self call krenge\r\nNot pick 	2025-03-20 09:38:38.214556	6	2025-06-28 10:36:58.945888	
7734	gaadimech	9024456699	2025-07-03 18:30:00	Did Not Pick Up	 Not pick 	2025-06-29 05:06:21.854098	6	2025-07-02 10:27:57.021271	
7156	gaadimech 	8890991121	2025-07-18 18:30:00	Did Not Pick Up	Ertiga 3699 out of jaipur \r\nNot pick 	2025-05-14 04:55:00.36051	6	2025-06-30 09:13:26.961061	
580	.	9314315285	2025-07-02 10:00:00	Needs Followup	No car	2024-11-30 07:06:42	4	2025-05-31 08:42:04.112745	
586	.	9928820400	2025-07-02 10:00:00	Needs Followup	Cut a call 	2024-11-30 07:06:42	4	2025-05-31 08:42:04.112745	
566	......	9414079240	2025-07-06 10:00:00	Needs Followup	Creta h under warrunty	2024-11-29 07:12:53	4	2025-05-31 08:42:22.030114	
603	Pradeep ji	9929299947	2025-07-08 10:00:00	Needs Followup	Dent pent h 	2024-11-30 09:37:30	4	2025-05-31 08:42:30.087566	
581	.	9314315285	2025-07-09 10:00:00	Needs Followup	Not interested 	2024-11-30 07:06:42	4	2025-05-31 08:42:34.144665	
572	.	9414293348	2025-08-21 18:30:00	Did Not Pick Up	Not requirement \r\nService done last month	2024-11-30 05:56:38	6	2025-03-18 09:18:30.542097	
567	......	9414079240	2025-07-17 18:30:00	Needs Followup	Creta h under warrunty\r\nNot interested 	2024-11-29 07:12:53	6	2025-04-21 10:23:19.998529	
5140	Customer 	9001436887	2025-07-04 18:30:00	Did Not Pick Up	Grand I10 2299	2025-03-27 07:09:20.447352	6	2025-06-28 08:27:47.753844	
5117	Customer 	9699930702	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-03-26 11:52:29.68746	6	2025-06-28 08:31:25.155482	
5137	Customer 	9928183522	2025-07-24 18:30:00	Did Not Pick Up	Not pick 	2025-03-27 06:55:21.230171	6	2025-06-28 08:28:47.38219	
5116	Kamal ji 	8875311728	2025-07-17 18:30:00	Did Not Pick Up	Not pick 	2025-03-26 11:51:07.225896	6	2025-06-28 08:32:06.293599	
5115	Customer 	9447309814	2025-07-10 18:30:00	Did Not Pick Up	Not interested 	2025-03-26 11:50:25.039652	6	2025-06-28 08:42:23.367106	
5114	Customer 	7014163418	2025-07-04 18:30:00	Did Not Pick Up	Not pick 	2025-03-26 11:49:51.595179	6	2025-06-28 08:43:27.262857	
5111	Vikas 	9899832454	2025-07-25 18:30:00	Needs Followup	Not interested 	2025-03-26 11:21:34.200088	6	2025-06-28 08:44:06.630577	
5110	Customer 	9619094856	2025-09-26 18:30:00	Needs Followup	Recently done with the services 	2025-03-26 11:17:47.622678	6	2025-06-28 08:44:46.12026	
5109	Vikas g	9928722111	2025-07-04 18:30:00	Did Not Pick Up	Grand I10:not pick 	2025-03-26 10:51:19.578566	6	2025-06-28 08:45:44.660463	
5108	Customer 	8740011111	2025-07-25 18:30:00	Did Not Pick Up	Not pick	2025-03-26 10:50:24.195785	6	2025-06-28 08:51:16.257379	
5106	Customer 	8347172108	2025-11-14 18:30:00	Needs Followup	Not interested \r\nGujrat	2025-03-26 10:04:49.444139	6	2025-06-28 09:10:28.507951	
5105	Customer 	9587955555	2025-07-18 18:30:00	Did Not Pick Up	Call cut	2025-03-26 10:04:10.55952	6	2025-06-28 09:11:41.725174	
5103	Vikas 	9982827007	2025-07-25 18:30:00	Did Not Pick Up	Call not connect 	2025-03-26 10:03:09.859993	6	2025-06-28 09:12:42.459997	
2278	Dinesh sir 	9887487818	2025-07-18 18:30:00	Needs Followup	Car service \r\nAbhi nahi 	2024-12-21 06:02:55.801736	4	2025-06-30 13:16:22.901002	
7078	Cx1185	9680454446	2025-07-26 10:00:00	Needs Followup	Tata tiago 	2025-05-10 09:40:54.023962	4	2025-05-31 08:43:43.903509	
7735	Altoz 2999	7878906090	2025-07-10 18:30:00	Needs Followup	Altoz 2999	2025-06-29 05:11:24.226582	4	2025-06-30 05:50:04.50313	
3792	Cx261	9929177108	2025-07-07 00:00:00	Needs Followup	Car service 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	\N
686	........	6378087992	2025-07-14 10:00:00	Needs Followup	N.r /madam abhi busy hu 11 ko c.b\r\nNot interested 	2024-12-01 06:01:07	6	2025-05-31 08:42:54.38585	
761	...	9696552764	2025-07-04 10:00:00	Needs Followup	Abhi so rha hu sham ko c.b\r\nCall cut	2024-12-02 04:50:36	6	2025-05-31 08:42:14.037958	
7131	gaadimech 	9785001109	2025-07-30 18:30:00	Did Not Pick Up	Repid 4599\r\nNo5 requirement 	2025-05-13 06:17:43.646496	6	2025-05-16 05:13:40.376818	
7133	gaadimech	7665005650	2025-07-22 10:00:00	Needs Followup	Kwid 	2025-05-13 06:35:08.536179	6	2025-05-31 08:43:27.624295	
7132	gaadimech	9829405873	2025-07-09 18:30:00	Did Not Pick Up	Dzire 2999  self call back\r\nNot pick 	2025-05-13 06:21:32.11681	6	2025-06-30 09:16:59.51961	
763	...	8890470250	2025-07-02 10:00:00	Needs Followup	N.r	2024-12-02 04:50:36	4	2025-05-31 08:42:04.112745	
5152	Customer 	9950675758	2025-07-13 18:30:00	Needs Followup	Not interested 	2025-03-27 07:19:57.374605	6	2025-06-28 08:13:50.057384	
5151	Customer 	9251008147	2025-07-17 18:30:00	Needs Followup	Not interested 	2025-03-27 07:18:58.710778	6	2025-06-28 08:18:08.864455	
5150	Customer 	7877442546	2025-07-10 18:30:00	Did Not Pick Up	Call cut	2025-03-27 07:17:51.959083	6	2025-06-28 08:19:06.691891	
5146	Customer 	9461165686	2025-07-03 18:30:00	Needs Followup	Not pick 	2025-03-27 07:15:20.499412	6	2025-06-28 08:20:01.07497	
5144	Customer 	9314613737	2025-07-17 18:30:00	Did Not Pick Up	Not pick 	2025-03-27 07:13:54.347272	6	2025-06-28 08:21:10.329415	
5143	Customer 	9588239839	2025-07-17 18:30:00	Needs Followup	Call cut	2025-03-27 07:10:18.8216	6	2025-06-28 08:21:52.913856	
2297	.	8949979725	2025-07-03 18:30:00	Needs Followup	Car service 	2024-12-21 08:31:22.208151	4	2025-06-29 07:37:55.504763	
2296	.	9828468480	2025-07-04 18:30:00	Needs Followup	Car service 	2024-12-21 08:31:22.208151	4	2025-06-29 07:44:24.850445	
2301	Anil sir 	9079362373	2025-07-01 18:30:00	Needs Followup	Abhi nahi 	2024-12-21 08:31:22.208151	4	2025-06-29 08:12:01.608717	
2302	.	8302522297	2025-07-24 18:30:00	Needs Followup	Abhi nahi	2024-12-21 08:31:22.208151	4	2025-06-29 08:16:46.007925	
2305	.	8963863570	2025-07-01 18:30:00	Needs Followup	Call cut	2024-12-21 08:31:22.208151	4	2025-06-30 13:07:55.772197	
2319	.	9887951076	2025-07-17 18:30:00	Did Not Pick Up	Switch off 	2024-12-21 08:31:22.208151	6	2025-06-29 08:29:27.485102	
2318	.	9829061630	2025-07-25 18:30:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-21 08:31:22.208151	6	2025-06-29 08:37:48.667403	
2298	.	9414280355	2025-07-11 18:30:00	Needs Followup	Nahi karwani abhi 	2024-12-21 08:31:22.208151	4	2025-06-30 13:10:43.633502	
2309	.	9828544004	2025-07-17 18:30:00	Needs Followup	Abhi nHi 	2024-12-21 08:31:22.208151	4	2025-06-29 11:08:47.831184	
2312	.	9413344057	2025-07-01 18:30:00	Needs Followup	Call cut	2024-12-21 08:31:22.208151	4	2025-06-29 11:29:31.696329	
2313	.	9828116383	2025-07-24 18:30:00	Needs Followup	Abhi nahi july tak 	2024-12-21 08:31:22.208151	4	2025-06-29 11:33:49.030934	
2314	.	9024282964	2025-07-10 18:30:00	Needs Followup	Not requirement 	2024-12-21 08:31:22.208151	4	2025-06-29 11:37:57.344421	
2315	.	9414065049	2025-07-03 18:30:00	Needs Followup	Nahi karwani 	2024-12-21 08:31:22.208151	4	2025-06-29 11:45:43.660037	
2294	.	9828172284	2025-07-09 18:30:00	Needs Followup	Abhi nahi no save kar letha hu 	2024-12-21 08:31:22.208151	4	2025-06-29 12:19:51.1188	
2276	Avneet kour	9999905315	2025-07-01 18:30:00	Needs Followup	Feedback call	2024-12-21 06:02:55.801736	4	2025-06-29 13:31:14.678503	
2277	.	8094688666	2025-07-03 18:30:00	Needs Followup	Abhi nahi 	2024-12-21 06:02:55.801736	4	2025-06-29 13:33:30.296942	
2279	.	9615500006	2025-07-01 18:30:00	Needs Followup	Call cut	2024-12-21 06:02:55.801736	4	2025-06-29 13:45:34.177527	
2624	Sankalp	9818049030	2025-07-30 18:30:00	Confirmed	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-04 06:23:54.301027	\N
2333	.	9314144415	2025-07-30 18:30:00	Needs Followup	Don't have car	2024-12-21 12:16:01.229869	6	2025-06-29 08:07:48.464793	
2334	.	9649302073	2025-07-17 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 12:16:01.229869	6	2025-06-29 08:08:58.772949	
2336	.	9828922441	2025-07-03 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 12:16:01.229869	6	2025-06-29 08:10:37.086485	
2335	.	9024587127	2025-07-18 18:30:00	Needs Followup	Call not pick \r\nNot pick	2024-12-21 12:16:01.229869	6	2025-06-29 08:12:00.70464	
2337	.	7976896981	2025-07-17 18:30:00	Needs Followup	Busy 	2024-12-21 12:16:01.229869	6	2025-06-29 08:13:08.588802	
2332	.	9314555999	2025-07-24 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 12:16:01.229869	6	2025-06-29 08:14:09.870256	
2338	.	9799137188	2025-07-16 18:30:00	Did Not Pick Up	Not interested 	2024-12-21 12:16:01.229869	6	2025-06-29 08:15:17.896245	
2339	.	8279232671	2025-07-30 18:30:00	Did Not Pick Up	Not requirement 	2024-12-21 12:16:01.229869	6	2025-06-29 08:22:07.848344	
2320	.	8955258267	2025-07-25 18:30:00	Needs Followup	Call not pick 	2024-12-21 08:31:22.208151	6	2025-06-29 08:30:23.897629	
2322	Pushpendra 	9829211468	2025-07-24 18:30:00	Did Not Pick Up	Call back 	2024-12-21 08:31:22.208151	6	2025-06-29 08:31:52.467121	
2323	.	9928331137	2025-07-25 18:30:00	Needs Followup	Call not pick \r\nCall cut	2024-12-21 08:31:22.208151	6	2025-06-29 08:32:48.473815	
2324	.	8949446242	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 08:31:22.208151	6	2025-06-29 08:34:48.31791	
2326	.	9887764105	2025-07-30 18:30:00	Needs Followup	Call not pick 	2024-12-21 08:31:22.208151	6	2025-06-29 08:36:18.480409	
2325	.	7014319051	2025-07-10 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 08:31:22.208151	6	2025-06-29 08:37:01.290553	
2328	B.P Sharma 	9414067770	2025-07-30 18:30:00	Did Not Pick Up	Not pick	2024-12-21 08:31:22.208151	6	2025-06-29 08:40:00.411286	
2327	.	8952928790	2025-07-25 18:30:00	Did Not Pick Up	Not interested 	2024-12-21 08:31:22.208151	6	2025-06-29 08:39:19.226162	
3397	.	9891474428	2025-07-03 18:30:00	Needs Followup	Car nahi hai 	2025-01-25 04:07:13.578442	4	2025-06-30 08:15:40.271577	
5219	Ramesh g	8005952979	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2025-03-28 08:17:01.709033	6	2025-06-30 09:29:26.824256	
3793	Cx262	8742001317	2025-07-07 00:00:00	Needs Followup	Call cut	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
2357	.	9829059010	2025-07-02 18:30:00	Did Not Pick Up	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 07:18:23.969485	
2368	.	9145936219	2025-07-16 18:30:00	Did Not Pick Up	Not requirement 	2024-12-22 08:06:41.389566	6	2025-06-29 07:15:23.058418	
2356	.	8890535131	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:23:03.907116	
2354	.	9414042990	2025-07-10 18:30:00	Did Not Pick Up	Cut a call 	2024-12-22 05:49:31.118194	6	2025-06-29 07:27:06.199864	
2355	.	8619600548	2025-07-30 18:30:00	Did Not Pick Up	Not interested \r\n	2024-12-22 05:49:31.118194	6	2025-06-29 07:25:04.447721	
2353	.	9828580120	2025-07-03 18:30:00	Did Not Pick Up	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 07:29:11.667344	
2359	.	9352604153	2025-07-30 18:30:00	Did Not Pick Up	Cut a call \r\nNot interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:31:20.232235	
2358	.	9680287594	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:33:20.495397	
2343	.	9352889950	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:42:03.605196	
2342	.	9660082665	2025-07-09 18:30:00	Needs Followup	Cut a call 	2024-12-22 05:49:31.118194	6	2025-06-29 07:43:32.215402	
2345	.	9928038341	2025-07-30 18:30:00	Needs Followup	Call not pick \r\nNit required 	2024-12-22 05:49:31.118194	6	2025-06-29 07:44:24.039985	
2341	.	9024405831	2025-07-09 18:30:00	Needs Followup	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 07:45:09.407106	
2361	.	8384937501	2025-07-18 18:30:00	Did Not Pick Up	Wagnor 2199	2024-12-22 05:49:31.118194	6	2025-06-29 07:46:30.23836	
2362	.	9352919563	2025-07-17 18:30:00	Needs Followup	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:47:58.786076	
2363	.	9928408984	2025-07-16 18:30:00	Needs Followup	Cut a call 	2024-12-22 05:49:31.118194	6	2025-06-29 07:50:08.013945	
2364	.	9829427664	2025-07-09 18:30:00	Did Not Pick Up	Not requirement \r\nNit pick	2024-12-22 05:49:31.118194	6	2025-06-29 07:51:28.23021	
2365	.	9829054871	2025-07-17 18:30:00	Did Not Pick Up	Call not pick \r\nSwitch off	2024-12-22 05:49:31.118194	6	2025-06-29 07:52:38.876302	
2366	.	9413396501	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:53:35.22559	
2367	.	8769833988	2025-08-22 18:30:00	Needs Followup	Not requirement 	2024-12-22 05:49:31.118194	6	2025-06-29 07:55:07.506064	
2360	.	8949248244	2025-07-10 18:30:00	Did Not Pick Up	Cut a call 	2024-12-22 05:49:31.118194	6	2025-06-29 07:56:03.67498	
2352	.	9414042321	2025-07-17 18:30:00	Did Not Pick Up	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 07:56:45.245487	
2351	.	9413846191	2025-07-17 18:30:00	Did Not Pick Up	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:57:17.716725	
2350	.	9413312866	2025-07-17 18:30:00	Did Not Pick Up	Cut a call 	2024-12-22 05:49:31.118194	6	2025-06-29 08:02:11.303234	
2349	.	9166604864	2025-07-17 18:30:00	Needs Followup	Not interested 	2024-12-22 05:49:31.118194	6	2025-06-29 08:03:11.56474	
2348	.	9680191906	2025-07-10 18:30:00	Did Not Pick Up	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 08:04:01.028881	
2347	.	9680199100	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 08:04:41.831816	
2346	.	9828567969	2025-07-24 18:30:00	Needs Followup	Call not pick 	2024-12-22 05:49:31.118194	6	2025-06-29 08:05:24.772747	
2340	.	8875599996	2025-07-25 18:30:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-21 12:16:01.229869	6	2025-06-29 08:23:06.282791	
2429	.	9214888000	2025-08-07 18:30:00	Did Not Pick Up	Not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:25:41.268415	
2430	.	7014359649	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:28:01.782538	
2431	.	9828813201	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:29:17.689101	
2427	.	9950606987	2025-07-11 18:30:00	Did Not Pick Up	Not requirement \r\nNot pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:33:58.360891	
2424	.	9667805736	2025-07-07 18:30:00	Did Not Pick Up	Not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:35:39.449897	
2425	.	9571110005	2025-07-06 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 08:16:54.59051	6	2025-06-30 10:47:54.94298	
2426	.	9694081002	2025-07-30 18:30:00	Did Not Pick Up	Not requirement 	2024-12-23 08:16:54.59051	6	2025-06-30 10:50:13.658561	
2400	.	9594852693	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 10:51:17.755011	
2401	.	8279275685	2025-11-14 18:30:00	Did Not Pick Up	Switch off 	2024-12-23 04:37:08.828595	6	2025-06-30 10:52:13.395614	
2402	.	7014803366	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 10:54:43.987109	
2403	.	9828888825	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:10:24.907848	
2404	.	9829012406	2025-07-25 18:30:00	Needs Followup	Not interested 	2024-12-23 04:37:08.828595	6	2025-06-30 11:11:26.093698	
2405	.	9414058572	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-23 04:37:08.828595	6	2025-06-30 11:20:02.540283	
2406	.	9414077320	2025-07-17 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:23:01.488015	
2407	.	9414980389	2025-07-10 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:25:18.285389	
2408	.	9982069928	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:26:41.794215	
2409	.	9314221612	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:27:37.486398	
2410	.	9928365457	2025-07-11 18:30:00	Did Not Pick Up	Busy call cut	2024-12-23 04:37:08.828595	6	2025-06-30 11:28:34.257744	
2411	.	9982305737	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:29:14.545105	
2413	.	9982466931	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:30:39.526701	
2414	.	9983230230	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:31:31.322064	
2415	.	9983230230	2025-07-13 18:30:00	Did Not Pick Up	Cut a call \r\nNot pick	2024-12-23 04:37:08.828595	6	2025-06-30 11:32:03.692108	
2416	.	9314851516	2025-07-13 18:30:00	Did Not Pick Up	Not interested \r\nNot pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:32:52.768809	
2417	.	9314503874	2025-07-15 18:30:00	Needs Followup	Not interested \r\nNot responding 	2024-12-23 04:37:08.828595	6	2025-06-30 11:34:04.65161	
2418	.	9928977770	2025-07-09 18:30:00	Did Not Pick Up	Not interested & cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:34:45.693502	
2419	.	7300366004	2025-07-15 18:30:00	Did Not Pick Up	Cut a 	2024-12-23 04:37:08.828595	6	2025-06-30 11:35:35.280423	
2420	.	9829019652	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 04:37:08.828595	6	2025-06-30 11:36:55.502566	
2421	.	9829057771	2025-07-08 18:30:00	Did Not Pick Up	Busy \r\nNot pic\r\nNot pick\r\nNot pick	2024-12-23 04:37:08.828595	6	2025-06-30 11:37:49.537995	
2422	.	8949998677	2025-07-10 18:30:00	Did Not Pick Up	Call Not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:38:41.250702	
2423	.	8949998677	2025-07-16 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:39:02.569859	
2399	.	9314501050	2025-07-09 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:39:48.273687	
2475	.	9828315905	2025-07-06 18:30:00	Needs Followup	Alto 1999\r\nSwift 2699	2024-12-24 04:36:55.430908	4	2025-07-01 07:23:11.645676	
2485	Xuv 700	9887567685	2025-07-07 18:30:00	Needs Followup	Xuv 700\r\nService 5999	2024-12-24 04:36:55.430908	4	2025-07-01 08:30:09.176897	
2483	.	6376248416	2025-07-17 18:30:00	Needs Followup	Baleno 2499	2024-12-24 04:36:55.430908	4	2025-07-01 10:01:43.752673	
2487	.	9829052848	2025-07-03 18:30:00	Needs Followup	Car service 	2024-12-24 04:36:55.430908	4	2025-07-01 07:06:39.29625	
2482	.	7014870722	2025-07-01 18:30:00	Needs Followup	Switch off 	2024-12-24 04:36:55.430908	4	2025-07-01 10:06:01.499541	
3662	SURESH JI 	6377426737	2025-07-09 18:30:00	Feedback	Not interested 	2025-02-03 08:13:54.657127	9	2025-07-01 08:22:06.860988	RJ45CG4906
2486	.	9413345569	2025-08-05 18:30:00	Needs Followup	Call not pick 	2024-12-24 04:36:55.430908	4	2025-07-01 07:10:03.396692	
2490	.	9784028112	2025-07-10 18:30:00	Did Not Pick Up	Call not pick 	2024-12-24 04:36:55.430908	6	2025-07-01 10:14:11.347853	
2472	.	9587991199	2025-07-02 18:30:00	Needs Followup	Call cut	2024-12-24 04:36:55.430908	4	2025-07-01 08:01:26.622021	
2730	Pc jain	9414405948	2025-07-16 18:30:00	Confirmed	call for service but not interested	2025-01-08 11:00:12.657946	9	2025-07-01 08:04:37.07856	\N
2474	Alto aur swift 	9828315905	2025-07-03 18:30:00	Needs Followup	Alto 1999\r\nSwift 2699	2024-12-24 04:36:55.430908	4	2025-07-01 07:44:14.972728	
2489	.	9414818360	2025-07-06 18:30:00	Needs Followup	Out of jaipur 	2024-12-24 04:36:55.430908	4	2025-07-01 08:22:21.901711	
2480	Honda City 	9950752287	2025-07-06 18:30:00	Needs Followup	Honda City 	2024-12-24 04:36:55.430908	4	2025-07-01 08:07:41.526648	
2473	Xxent	9928637946	2025-07-17 18:30:00	Needs Followup	Xcent 2499	2024-12-24 04:36:55.430908	4	2025-07-01 07:47:01.940052	
2477	.	9829050330	2025-07-02 18:30:00	Needs Followup	Cut a call 	2024-12-24 04:36:55.430908	4	2025-07-01 07:19:30.08467	
2468	.	9829022444	2025-07-16 18:30:00	Needs Followup	Abhi nahi 	2024-12-24 04:36:55.430908	4	2025-07-01 08:23:43.543774	
2491	.	9829577737	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-24 04:36:55.430908	6	2025-07-01 10:14:56.712595	
2479	.	7976670462	2025-08-06 18:30:00	Needs Followup	Abhi nahi 	2024-12-24 04:36:55.430908	4	2025-07-01 07:48:52.791951	
2471	.	9414043069	2025-07-03 18:30:00	Needs Followup	Car service 	2024-12-24 04:36:55.430908	4	2025-07-01 08:15:49.626146	
2481	.	9414042891	2025-07-01 18:30:00	Needs Followup	No answer 	2024-12-24 04:36:55.430908	4	2025-07-01 08:18:20.344001	
2470	Sandeep Agnihotri 	9829212085	2025-07-09 18:30:00	Needs Followup	Car service 	2024-12-24 04:36:55.430908	4	2025-07-01 10:55:19.607695	
2469	.	9829066277	2025-07-03 18:30:00	Needs Followup	Car service 	2024-12-24 04:36:55.430908	4	2025-07-01 10:57:51.841553	
2484	Swift aur santro	9460061200	2025-07-05 18:30:00	Needs Followup	Santro aur swift 	2024-12-24 04:36:55.430908	4	2025-07-01 11:03:58.826807	
2466	.	9461301017	2025-07-02 18:30:00	Needs Followup	Cal cut	2024-12-23 12:40:16.565752	4	2025-07-01 11:13:20.806181	
2467	.	9829094297	2025-07-01 18:30:00	Needs Followup	Busy 	2024-12-23 12:40:16.565752	4	2025-07-01 11:18:51.630163	
2434	.	9829052440	2025-07-25 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:32:51.587935	
2435	.	9799006609	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:34:44.34445	
2478	.	9351504129	2025-07-02 18:30:00	Needs Followup	Jodhpur se	2024-12-24 04:36:55.430908	4	2025-07-01 10:08:29.697927	
2515	.	9414075357	2025-07-18 18:30:00	Did Not Pick Up	Call not pick \r\nCall cut	2024-12-24 09:44:45.910357	6	2025-07-01 09:57:09.093451	
2522	.	9352435980	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-24 11:21:22.912482	6	2025-07-01 09:22:33.529552	
2517	.	9829490394	2025-07-24 18:30:00	Needs Followup	Scorpio Not required	2024-12-24 11:21:22.912482	6	2025-07-01 07:44:46.443984	
551	Khushal 	9001200777	2025-07-02 10:00:00	Needs Followup	M gadi campney me hi krwata hu	2024-11-29 07:12:53	4	2025-05-31 08:42:04.112745	
552	Pawan ji 	9829011416	2025-07-02 10:00:00	Needs Followup	Baleno ka pack diya h but abhi need nhi h\r\nNot pick 	2024-11-29 07:12:53	4	2025-05-31 08:42:04.112745	
1607	.	7221911446	2025-07-02 10:00:00	Needs Followup	Not pick\r\nNot pick	2024-12-10 05:43:58	4	2025-05-31 08:42:04.112745	
2885	Customer	9057203601	2025-07-02 10:00:00	Needs Followup	Etioes 2999 \r\nNot required 	2025-01-12 04:36:11.819946	4	2025-05-31 08:42:04.112745	
3264	customer 	9828166669	2025-07-02 10:00:00	Needs Followup	Not pick\r\nDon't have car	2025-01-20 12:02:14.345371	4	2025-05-31 08:42:04.112745	
2526	.	9314887024	2025-08-15 18:30:00	Needs Followup	Not interested \r\nDzire sale krni hai	2024-12-24 12:00:21.095211	6	2025-07-01 07:29:21.477191	
2524	.	8740002299	2025-07-10 18:30:00	Did Not Pick Up	Call not pick \r\nNot pick 	2024-12-24 12:00:21.095211	6	2025-07-01 07:30:03.134487	
2525	.	8766194083	2025-07-25 18:30:00	Did Not Pick Up	Call not pick \r\nNot interested 	2024-12-24 12:00:21.095211	6	2025-07-01 07:32:20.806816	
2521	.	9829060346	2025-07-24 18:30:00	Needs Followup	Cut a call \r\nScooter hai	2024-12-24 11:21:22.912482	6	2025-07-01 07:46:58.904851	
2519	.	9314944222	2025-08-29 18:30:00	Did Not Pick Up	Not interested 	2024-12-24 11:21:22.912482	6	2025-07-01 09:24:05.2505	
2520	.	9414009251	2025-07-18 18:30:00	Needs Followup	Cut a call 	2024-12-24 11:21:22.912482	6	2025-07-01 09:25:16.744387	
2504	.	9024978491	2025-07-18 18:30:00	Did Not Pick Up	Voice mail \r\nNot requirement 	2024-12-24 09:44:45.910357	6	2025-07-01 09:29:37.128891	
2503	.	9214436898	2025-07-25 18:30:00	Did Not Pick Up	Not requirement \r\nNot pick	2024-12-24 09:44:45.910357	6	2025-07-01 09:30:35.159298	
2502	.	8005889191	2025-07-11 18:30:00	Did Not Pick Up	Not pick	2024-12-24 09:44:45.910357	6	2025-07-01 09:35:45.259282	
2501	.	9505025941	2025-08-22 18:30:00	Did Not Pick Up	Call not pick 	2024-12-24 09:44:45.910357	6	2025-07-01 09:38:35.307083	
2500	.	9829138080	2025-07-18 18:30:00	Did Not Pick Up	Cut a call \r\n	2024-12-24 09:44:45.910357	6	2025-07-01 09:41:37.930575	
2505	.	9982631905	2025-07-25 18:30:00	Needs Followup	Not requirement \r\nCall cut	2024-12-24 09:44:45.910357	6	2025-07-01 09:42:25.265536	
2506	.	9828542661	2025-07-25 18:30:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-24 09:44:45.910357	6	2025-07-01 09:47:00.267454	
2510	.	9887497414	2025-08-22 18:30:00	Did Not Pick Up	Not interested 	2024-12-24 09:44:45.910357	6	2025-07-01 09:49:12.630602	
2516	.	9829361117	2025-07-18 18:30:00	Needs Followup	Xuv 300 3899	2024-12-24 09:44:45.910357	6	2025-07-01 09:53:11.502352	
2514	.	8769481927	2025-07-18 18:30:00	Needs Followup	Call cut	2024-12-24 09:44:45.910357	6	2025-07-01 09:54:20.600663	
2511	.	9772714777	2025-08-29 18:30:00	Did Not Pick Up	Free service dine	2024-12-24 09:44:45.910357	6	2025-07-01 09:56:06.20454	
2513	.	9314936531	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-24 09:44:45.910357	6	2025-07-01 09:58:11.607315	
2498	.	9414335890	2025-07-11 18:30:00	Did Not Pick Up	Not pick	2024-12-24 08:43:31.110765	6	2025-07-01 09:59:30.072599	
2499	.	9828375729	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-24 08:43:31.110765	6	2025-07-01 10:00:20.701597	
2492	.	9672271198	2025-07-30 18:30:00	Did Not Pick Up	Not requirement 	2024-12-24 04:36:55.430908	6	2025-07-01 10:44:48.793537	
2493	.	9828011730	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-24 04:36:55.430908	6	2025-07-01 10:49:04.836052	
2494	.	9351156007	2025-07-11 18:30:00	Did Not Pick Up	Cut a call 	2024-12-24 04:36:55.430908	6	2025-07-01 10:50:38.343673	
2495	.	9414076734	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-12-24 04:36:55.430908	6	2025-07-01 10:52:35.304907	
2496	.	9829060608	2025-07-07 18:30:00	Did Not Pick Up	Call cut	2024-12-24 04:36:55.430908	6	2025-07-01 10:53:35.338109	
2497	.	9314913799	2025-07-11 18:30:00	Did Not Pick Up	Voice mail	2024-12-24 04:36:55.430908	6	2025-07-01 10:54:30.185007	
431	.	9829007938	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2024-11-28 06:03:20	6	2025-07-01 11:15:15.98777	
448	.	9950999338	2025-08-08 18:30:00	Needs Followup	Not interested & cut a call \r\nCall cut	2024-11-28 06:03:20	6	2025-07-01 10:56:06.788966	
378	.	9950993993	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-11-27 07:21:40	6	2025-07-01 11:28:11.053903	
4070	.	9887384879	2025-07-23 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-02-15 11:11:36.334822	6	2025-07-02 11:02:55.406236	
356	Dipendra ji	9672421421	2025-07-24 18:30:00	Needs Followup	Not  interested 	2024-11-27 05:30:57	6	2025-07-01 11:29:41.800608	
351	.	9829937771	2025-07-25 18:30:00	Did Not Pick Up	Call not pick \r\n	2024-11-27 05:30:57	6	2025-07-01 11:33:12.777102	
347	.	8209471564	2025-09-29 18:30:00	Needs Followup	Nexon 3899 service alredy done	2024-11-26 12:44:59	6	2025-07-01 11:36:27.415944	
4065	.	9783064343	2025-07-11 18:30:00	Did Not Pick Up	Not pick 	2025-02-15 10:53:58.800067	6	2025-07-02 11:09:50.520554	
4048	.	9828293263	2025-09-19 18:30:00	Did Not Pick Up	Not requirement 	2025-02-15 10:04:58.35299	6	2025-07-02 11:12:46.059265	
4044	.	9321330383	2025-09-11 18:30:00	Needs Followup	Alto1999 still not requirment 	2025-02-15 09:53:32.960497	6	2025-07-02 11:13:39.696002	
3540	.	8005907330	2025-07-03 18:30:00	Needs Followup	Call cut	2025-01-31 04:20:51.980955	4	2025-07-02 11:25:51.583198	
3983	.	9660755024	2025-07-25 18:30:00	Did Not Pick Up	Not interested \r\nCall cut	2025-02-12 09:39:22.165637	6	2025-07-02 11:39:33.039911	
4023	.	9829096416	2025-07-18 18:30:00	Did Not Pick Up	Not interested 	2025-02-15 07:40:57.110813	6	2025-07-02 11:40:13.577897	
3982	.	9660755024	2025-07-14 18:30:00	Did Not Pick Up	Not pick 	2025-02-12 09:38:05.469775	6	2025-07-02 11:41:29.29591	
3979	.	7891928002	2025-07-10 18:30:00	Did Not Pick Up	Brezza 2999 \r\nCall cut	2025-02-12 09:30:48.148105	6	2025-07-02 11:42:58.612496	
3869	.	7499835374	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-07 10:20:37.99656	6	2025-07-02 11:44:53.720466	
3892	.	9998930555	2025-07-25 18:30:00	Did Not Pick Up		2025-02-07 10:20:37.99656	6	2025-07-02 11:47:36.883363	
3873	.	7728809159	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-02-07 10:20:37.99656	6	2025-07-02 11:48:26.762878	
3849	.	7414801010	2025-07-06 18:30:00	Did Not Pick Up		2025-02-07 09:03:50.545995	6	2025-07-02 11:51:28.370925	
3847	.	8875001696	2025-07-09 18:30:00	Needs Followup	Not connect 	2025-02-07 09:03:50.545995	6	2025-07-02 12:17:43.994102	
3751	.	9950345510	2025-07-16 18:30:00	Did Not Pick Up	Not pick	2025-02-05 08:55:58.705632	6	2025-07-02 12:22:34.036881	
3461	.	9414243432	2025-07-03 18:30:00	Needs Followup	I20 2699\r\nAbhi nahi 	2025-01-26 09:16:05.01535	4	2025-07-02 12:22:44.203462	
3762	.	9899980992	2025-08-15 18:30:00	Did Not Pick Up	Not pick \r\nNot requirement 	2025-02-05 08:55:58.705632	6	2025-07-02 12:23:29.281452	
3676	.	9251966666	2025-07-18 18:30:00	Did Not Pick Up	Call cut	2025-02-04 08:21:25.650869	6	2025-07-02 12:29:46.183288	
3638	.	9829058058	2025-07-18 18:30:00	Did Not Pick Up	Not pick 	2025-02-02 10:46:12.681522	6	2025-07-02 12:31:40.850598	
5171	Customer 	9511600259	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:07:50.72018	4	2025-05-31 08:42:09.584832	
5172	Prashant 	9414771276	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:09:53.500773	4	2025-05-31 08:42:09.584832	
5173	Customer 	9829918648	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:10:37.827807	4	2025-05-31 08:42:09.584832	
5174	Customer 	9829562276	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:11:16.77251	4	2025-05-31 08:42:09.584832	
5178	Customer 	9660075525	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:15:00.290762	4	2025-05-31 08:42:09.584832	
5179	Customer 	8890597938	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:20:04.619309	4	2025-05-31 08:42:09.584832	
5180	Avinash ji 	9829097200	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:20:46.429818	4	2025-05-31 08:42:09.584832	
5181	Avinash Kumar 	7665491318	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:22:03.010406	4	2025-05-31 08:42:09.584832	
5182	Saurabh 	9829562713	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:22:38.615144	4	2025-05-31 08:42:09.584832	
5184	Customer 	7007138776	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:23:51.135738	4	2025-05-31 08:42:09.584832	
5185	Naveen 	9414073188	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:24:15.176641	4	2025-05-31 08:42:09.584832	
5186	Abhi raj Gupta 	9829011003	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:24:49.84523	4	2025-05-31 08:42:09.584832	
5187	Ashok g	9829015373	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:25:29.117911	4	2025-05-31 08:42:09.584832	
5188	Customer 	9785172311	2025-07-03 10:00:00	Needs Followup	Creata 3599	2025-03-28 07:27:16.400249	4	2025-05-31 08:42:09.584832	
5190	Mukesh g	9799571917	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:28:33.98765	4	2025-05-31 08:42:09.584832	
5191	Customer 	9782949527	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:29:14.232452	4	2025-05-31 08:42:09.584832	
5192	Customer 	9928304098	2025-07-03 10:00:00	Needs Followup		2025-03-28 07:33:05.139711	4	2025-05-31 08:42:09.584832	
5193	Vikram 	7340498871	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 07:33:52.335862	4	2025-05-31 08:42:09.584832	
5203	Monu g	7619748808	2025-07-03 10:00:00	Needs Followup	Etios 3399	2025-03-28 08:08:10.112627	4	2025-05-31 08:42:09.584832	
5204	Customer 	7023634064	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:08:37.325821	4	2025-05-31 08:42:09.584832	
5206	Meena	9891200940	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 08:09:40.275885	4	2025-05-31 08:42:09.584832	
5207	Nitesh 	7703009322	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:10:18.826743	4	2025-05-31 08:42:09.584832	
5208	Customer 	6367699619	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:10:43.203053	4	2025-05-31 08:42:09.584832	
5209	Customer 	7838146154	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:11:07.654723	4	2025-05-31 08:42:09.584832	
5210	Customer 	9309329394	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:11:39.110242	4	2025-05-31 08:42:09.584832	
5211	Customer 	7976427693	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 08:12:20.38597	4	2025-05-31 08:42:09.584832	
5212	Devesh g	9828212786	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:12:53.849228	4	2025-05-31 08:42:09.584832	
5213	Customer 	7240101000	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:13:21.574205	4	2025-05-31 08:42:09.584832	
4071	.	8209362642	2025-09-25 18:30:00	Needs Followup	Vento 3699\r\n koi requirement nahi hai hogi to contacg krunga \r\nNot interested 	2025-02-15 11:13:39.071268	6	2025-07-02 11:00:49.923251	
5214	Customer 	8946862616	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:13:50.961226	4	2025-05-31 08:42:09.584832	
5215	Sourabh 	9352549020	2025-07-03 10:00:00	Needs Followup	Alto 2399	2025-03-28 08:14:48.221035	4	2025-05-31 08:42:09.584832	
5216	Customer 	7804948730	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:15:10.283339	4	2025-05-31 08:42:09.584832	
5217	Customer 	8824510150	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:15:46.636379	4	2025-05-31 08:42:09.584832	
5218	Dharam veer ji 	9509222225	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:16:27.471683	4	2025-05-31 08:42:09.584832	
5226	Customer 	9001004445	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:10:56.360577	4	2025-05-31 08:42:09.584832	
5227	Customer 	8428991252	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:11:36.020867	4	2025-05-31 08:42:09.584832	
5228	Ashok g 	9811512661	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:12:09.384368	4	2025-05-31 08:42:09.584832	
5229	Customer 	9680812794	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:13:25.72425	4	2025-05-31 08:42:09.584832	
5230	Customer 	8233448679	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:13:54.394297	4	2025-05-31 08:42:09.584832	
5231	Customer 	8005721794	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:14:27.179006	4	2025-05-31 08:42:09.584832	
5232	Customer 	8837204131	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:14:52.242136	6	2025-05-31 08:42:09.584832	
5233	Customer 	9950478112	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:15:30.236115	6	2025-05-31 08:42:09.584832	
5234	Shyam ji 	7726929205	2025-07-03 10:00:00	Needs Followup	Xuv 700	2025-03-28 12:16:23.551233	6	2025-05-31 08:42:09.584832	
5235	Customer 	9003735898	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:16:55.614004	6	2025-05-31 08:42:09.584832	
5236	Pulkit g	9928423280	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:17:34.186569	6	2025-05-31 08:42:09.584832	
5237	Customer 	8209079378	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:18:18.513846	6	2025-05-31 08:42:09.584832	
5238	Customer 	9982344443	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:19:01.841908	6	2025-05-31 08:42:09.584832	
5239	Customer 	9928044454	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:19:29.790349	6	2025-05-31 08:42:09.584832	
5240	Radhey shyam ji 	9887071543	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:20:04.0139	6	2025-05-31 08:42:09.584832	
5241	Customer 	9694320701	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:20:30.4215	6	2025-05-31 08:42:09.584832	
5242	Customer 	9829494114	2025-07-03 10:00:00	Needs Followup		2025-03-28 12:21:05.291911	6	2025-05-31 08:42:09.584832	
5225	Customer 	9664016164	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 12:10:24.051792	6	2025-05-31 08:42:09.584832	
5183	Subhash 	8764426654	2025-07-03 10:00:00	Needs Followup	Verna 3399	2025-03-28 07:23:19.712605	6	2025-05-31 08:42:09.584832	
5290	Customer 	9672994302	2025-07-03 10:00:00	Needs Followup	Cx was out of station 	2025-03-30 07:28:21.137032	6	2025-05-31 08:42:09.584832	
5293	Customer 	9414968066	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 07:31:10.0971	6	2025-05-31 08:42:09.584832	
5295	Ajit 	7742664453	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 07:35:14.56797	6	2025-05-31 08:42:09.584832	
5304	Customer 	9829131820	2025-07-03 10:00:00	Needs Followup	Xcent 2799	2025-03-30 10:57:22.032629	6	2025-05-31 08:42:09.584832	
1291	.	9602224466	2025-07-02 10:00:00	Needs Followup	Cut a call 	2024-12-07 05:46:09	4	2025-05-31 08:42:04.112745	
5318	Customer 	9829065718	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:10:32.730726	6	2025-05-31 08:42:09.584832	
5320	Customer 	8949903727	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:11:50.794695	6	2025-05-31 08:42:09.584832	
5328	Subhash 	9829011017	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:15:40.731103	6	2025-05-31 08:42:09.584832	
5329	Customer 	9724993746	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:16:48.012224	6	2025-05-31 08:42:09.584832	
5331	Mahesh g	9828155724	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:18:03.827276	6	2025-05-31 08:42:09.584832	
5333	Customer 	6378452600	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:19:11.212996	6	2025-05-31 08:42:09.584832	
5338	Customer 	9784542151	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:22:44.373444	6	2025-05-31 08:42:09.584832	
5346	Customer 	8279212297	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:27:14.88465	6	2025-05-31 08:42:09.584832	
1282	.	9828540132	2025-07-20 10:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	6	2025-05-31 08:43:19.077196	
1311	.	9829068848	2025-07-20 10:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:43:19.077196	
1294	.	9829366999	2025-07-23 10:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-07 05:46:09	6	2025-05-31 08:43:31.574711	
1319	.	9314500978	2025-07-26 10:00:00	Needs Followup	Not reachable\r\nXuv7OO service done other workshop 	2024-12-07 05:46:09	6	2025-05-31 08:43:43.903509	
5175	Vikram 	7014284591	2025-07-02 18:30:00	Needs Followup	Celerio 2699	2025-03-28 07:12:55.786547	6	2025-05-31 10:12:37.920279	
3247	.	9829025698	2025-07-02 18:30:00	Needs Followup	Car service 	2025-01-20 04:31:19.397625	4	2025-06-30 09:22:34.911228	
5348	Customer 	7014810021	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:29:08.077617	6	2025-05-31 08:42:09.584832	
5350	Customer 	9981135511	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:30:15.393186	6	2025-05-31 08:42:09.584832	
5189	Customer 	8209054833	2025-07-03 10:00:00	Needs Followup	Honda Crv 4499	2025-03-28 07:27:59.746443	6	2025-05-31 08:42:09.584832	
5200	Customer 	7726938887	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 08:06:07.315837	6	2025-05-31 08:42:09.584832	
5201	Apeksha g	8003766627	2025-07-03 10:00:00	Needs Followup		2025-03-28 08:06:46.431215	6	2025-05-31 08:42:09.584832	
5306	Sunil 	9829322256	2025-10-16 18:30:00	Needs Followup		2025-03-30 10:58:31.572327	6	2025-06-28 12:07:10.499044	
5202	Jain	9351120720	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 08:07:26.824131	6	2025-05-31 08:42:09.584832	
5205	Customer 	7877082118	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-28 08:09:03.446197	6	2025-05-31 08:42:09.584832	
5314	Customer 	9079993414	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:03:30.2857	6	2025-05-31 08:42:09.584832	
5319	Customer 	8559997041	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:11:02.477939	6	2025-05-31 08:42:09.584832	
5332	Naveen g	9166774114	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:18:41.826876	4	2025-05-31 08:42:14.037958	
5335	Customer 	9828163404	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:20:22.51884	4	2025-05-31 08:42:14.037958	
5339	Customer 	8875892811	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:23:24.432862	4	2025-05-31 08:42:14.037958	
5341	Customer 	9828015181	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:24:21.212618	4	2025-05-31 08:42:14.037958	
5342	Customer 	9829998648	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:25:01.669064	4	2025-05-31 08:42:14.037958	
5343	Jagdish g	9166662211	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-03-30 11:25:36.202199	4	2025-05-31 08:42:14.037958	
5381	Rohit 	7838146154	2025-07-04 10:00:00	Needs Followup		2025-04-01 06:54:52.472945	4	2025-05-31 08:42:14.037958	
1284	.	9829566666	2025-07-04 10:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-07 05:46:09	4	2025-05-31 08:42:14.037958	
5268	gaadimech	9256453096	2025-07-04 10:00:00	Needs Followup	Bolero 4599 dungerpur 	2025-03-29 09:40:02.323212	4	2025-05-31 08:42:14.037958	
5349	Customer 	9980966637	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:29:43.891242	4	2025-05-31 08:42:14.037958	
5353	Customer 	9351234350	2025-07-04 10:00:00	Needs Followup		2025-03-30 11:32:15.614709	4	2025-05-31 08:42:14.037958	
5797	Customer 	9414377055	2025-07-05 18:30:00	Needs Followup	Voice message 	2025-04-09 10:04:22.626805	4	2025-07-04 09:58:47.270362	
5487	Bilkesh	9829679072	2025-07-03 18:30:00	Needs Followup	No not use 	2025-04-02 12:18:18.285013	4	2025-07-04 10:51:48.577294	
1315	.	9839111004	2025-07-17 10:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	6	2025-05-31 08:43:06.869056	
1286	.	9772435783	2025-07-06 10:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	4	2025-05-31 08:42:22.030114	
5430	Vishal dagara 	9529599088	2025-07-05 18:30:00	Needs Followup	Call cut	2025-04-01 09:21:19.483001	4	2025-07-04 12:09:52.23382	
1293	.	9799277436	2025-07-07 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:26.111514	
1318	.	9829797313	2025-07-08 10:00:00	Needs Followup	Call not pick	2024-12-07 05:46:09	4	2025-05-31 08:42:30.087566	
1285	.	9413300494	2025-07-14 10:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:54.38585	
1307	.	7239939912	2025-07-14 10:00:00	Needs Followup	Switch off \r\nVenue 2999\r\nScorpio 4699\r\nNot pick\r\nAmaze 2899 package share	2024-12-07 05:46:09	6	2025-05-31 08:42:54.38585	
1317	.	9702927777	2025-07-14 10:00:00	Needs Followup	Cut a call 	2024-12-07 05:46:09	6	2025-05-31 08:42:54.38585	
5382	Customer 	9636088099	2025-07-04 10:00:00	Needs Followup		2025-04-01 06:55:38.216543	4	2025-05-31 08:42:14.037958	
5383	Ankit 	9928081533	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-04-01 06:56:29.510941	4	2025-05-31 08:42:14.037958	
1413	Jitendra Chaudhary	9024357418	2025-07-02 10:00:00	Needs Followup	Repid 3199	2024-12-08 05:58:11	4	2025-05-31 08:42:04.112745	
5377	Cx 619	9413417462	2025-07-04 10:00:00	Needs Followup	Swift \r\nDent paint 	2025-04-01 06:08:02.883405	4	2025-05-31 08:42:14.037958	
316	Govind singh	8005613799	2025-07-04 10:00:00	Needs Followup	Eco Sport Ford ki front mirror and sarvice next week/ n.r\r\nNot requirement 	2024-11-26 11:11:43	4	2025-05-31 08:42:14.037958	
1278	.	7597626630	2025-07-04 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1279	.	9314033313	2025-07-04 10:00:00	Needs Followup	Not interested \r\nCall cut	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1280	.	9928000051	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1281	.	9413341554	2025-07-04 10:00:00	Needs Followup	Service not required 	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1283	.	9828855579	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1295	.	9887513232	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot requirement 	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1299	.	9610088886	2025-07-04 10:00:00	Needs Followup	Not requirement 	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1301	.	9982111188	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1312	.	9314656508	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1314	.	9829468329	2025-07-04 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1316	.	9460064198	2025-07-04 10:00:00	Needs Followup	Call not pick \r\nNot intrested	2024-12-07 05:46:09	6	2025-05-31 08:42:14.037958	
1394	.....	9829900036	2025-07-04 10:00:00	Needs Followup	Not pick 	2024-12-07 11:39:13	6	2025-05-31 08:42:14.037958	
1417	.	9116525102	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1420	......	9411009041	2025-07-04 10:00:00	Needs Followup	N.r	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1422	.	9892785007	2025-07-04 10:00:00	Needs Followup	Cut a call 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1474	Vinod sir	9983777715	2025-07-04 10:00:00	Needs Followup	Call back 	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1483	.	9950662611	2025-07-04 10:00:00	Needs Followup	Cut a call 	2024-12-08 09:50:19	6	2025-05-31 08:42:14.037958	
1487	.	9643025940	2025-07-04 10:00:00	Needs Followup	Not interested & cut a call \r\nNot pick\r\nCall cut	2024-12-08 10:41:33	6	2025-05-31 08:42:14.037958	
2756	Rahul	9982942414	2025-07-04 10:00:00	Needs Followup	Honda city 2799\r\nSantro 2199	2025-01-09 08:07:34.075518	6	2025-05-31 08:42:14.037958	
2884	Customer	9950062614	2025-07-04 10:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	6	2025-05-31 08:42:14.037958	
7135	Cx2004	8290780403	2025-07-26 10:00:00	Needs Followup	Dzire service 	2025-05-13 06:57:12.058557	4	2025-05-31 08:43:43.903509	
1415	.	9672222493	2025-07-26 10:00:00	Needs Followup	Not requirement 	2024-12-08 05:58:11	6	2025-05-31 08:43:43.903509	
2997	Customer	9915970537	2025-07-04 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nCall cut	2025-01-13 09:02:24.989067	6	2025-05-31 08:42:14.037958	
3390	.	9001995391	2025-07-04 10:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	6	2025-05-31 08:42:14.037958	
4093	.	9414065217	2025-07-05 10:00:00	Needs Followup	Call cut	2025-02-16 09:41:56.56655	4	2025-05-31 08:42:17.990214	
1416	....	9785000016	2025-07-06 10:00:00	Needs Followup	Switch off	2024-12-08 05:58:11	4	2025-05-31 08:42:22.030114	
1426	.	9829428111	2025-07-06 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-08 05:58:11	4	2025-05-31 08:42:22.030114	
1396	......	9672443465	2025-07-08 10:00:00	Needs Followup	M apne hisab se jo open workshop h unse hi krtwata hu\r\nNot pick\r\nCall cut	2024-12-07 11:39:13	4	2025-05-31 08:42:30.087566	
1414	.	9111018403	2025-07-14 10:00:00	Needs Followup	Not interested  service done	2024-12-08 05:58:11	6	2025-05-31 08:42:54.38585	
1425	.......	9602622307	2025-07-15 10:00:00	Needs Followup	Don't have car 	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1428	.	9571889422	2025-07-15 10:00:00	Needs Followup	Not interested 	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1432	.	9899980992	2025-07-15 10:00:00	Needs Followup	Switch off \r\nSwitch off \r\nSwitch off \r\nNot pick	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1429	.	9829972087	2025-07-26 10:00:00	Needs Followup	Not interested 	2024-12-08 05:58:11	6	2025-05-31 08:43:43.903509	
1441	.	9460617918	2025-07-20 10:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-08 05:58:11	6	2025-05-31 08:43:19.077196	
1464	Chakarveer sir	9929396075	2025-07-20 10:00:00	Needs Followup	WhatsApp package shared 	2024-12-08 08:15:33	6	2025-05-31 08:43:19.077196	
1475	.	7976429174	2025-07-21 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-08 08:15:33	4	2025-05-31 08:43:23.449024	
1479	.	9784608686	2025-07-21 10:00:00	Needs Followup	Not requirement 	2024-12-08 09:50:19	4	2025-05-31 08:43:23.449024	
1482	.	7737773778	2025-07-21 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nCall cut	2024-12-08 09:50:19	4	2025-05-31 08:43:23.449024	
1485	.	9950358333	2025-07-21 10:00:00	Needs Followup	Call back \r\nNot pick\r\nNot pick	2024-12-08 10:41:33	4	2025-05-31 08:43:23.449024	
1454	Sandeep sir	9928024391	2025-07-23 10:00:00	Needs Followup	WhatsApp package shared 	2024-12-08 08:15:33	6	2025-05-31 08:43:31.574711	
7137	Cx2004	8290780403	2025-07-26 10:00:00	Needs Followup	Dzire service 	2025-05-13 06:57:24.101279	4	2025-05-31 08:43:43.903509	
1459	.	9828700053	2025-07-26 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-08 08:15:33	6	2025-05-31 08:43:43.903509	
1471	.	9352464555	2025-07-26 10:00:00	Needs Followup	Not interested \r\nCall cut	2024-12-08 08:15:33	6	2025-05-31 08:43:43.903509	
1443	.	9993933595	2025-07-04 10:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot interested 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1445	.	9911997202	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot requirement 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1447	.	9999288540	2025-07-04 10:00:00	Needs Followup	Not interested 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1451	.	8947982469	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-12-08 05:58:11	6	2025-05-31 08:42:14.037958	
1456	.	9642194000	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1457	.	8812096536	2025-07-04 10:00:00	Needs Followup	Call back \r\nCall cut	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1462	.	7838018232	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1468	.	9950333399	2025-07-04 10:00:00	Needs Followup	Cut a call 	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1470	.	9982265149	2025-07-04 10:00:00	Needs Followup	Not interested \r\nNot connect \r\nNot pick	2024-12-08 08:15:33	6	2025-05-31 08:42:14.037958	
1434	.	9654429555	2025-07-06 10:00:00	Needs Followup	Cut a call 	2024-12-08 05:58:11	4	2025-05-31 08:42:22.030114	
1477	.	9001162871	2025-07-17 10:00:00	Needs Followup	Call back \r\nNot pick\r\nNot interested 	2024-12-08 08:15:33	6	2025-05-31 08:43:06.869056	
1440	..	9314418542	2025-07-15 10:00:00	Needs Followup	Inova ka pack 4599 me bhut .mahanga \r\nh madam\r\nNot interested 	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1439	.	9116001140	2025-07-06 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-08 05:58:11	4	2025-05-31 08:42:22.030114	
1453	.	8955995943	2025-07-08 10:00:00	Needs Followup	Not interested 	2024-12-08 05:58:11	6	2025-05-31 08:42:30.087566	
1463	....	9460765607	2025-07-06 10:00:00	Needs Followup	Not interested 	2024-12-08 08:15:33	4	2025-05-31 08:42:22.030114	
1442	.	9993933595	2025-07-15 10:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot interested \r\nCall cut	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1476	.	8003666635	2025-07-06 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-08 08:15:33	4	2025-05-31 08:42:22.030114	
1437	.....	9414058983	2025-07-08 10:00:00	Needs Followup	N.r	2024-12-08 05:58:11	4	2025-05-31 08:42:30.087566	
1467	.	9252546472	2025-07-08 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-08 08:15:33	6	2025-05-31 08:42:30.087566	
1438	.	9001195004	2025-07-08 10:00:00	Needs Followup	N.r	2024-12-08 05:58:11	4	2025-05-31 08:42:30.087566	
1446	.....	9314525288	2025-07-08 10:00:00	Needs Followup	Not interested 	2024-12-08 05:58:11	4	2025-05-31 08:42:30.087566	
1486	.	9828501494	2025-07-08 10:00:00	Needs Followup	Cut a call 	2024-12-08 10:41:33	6	2025-05-31 08:42:30.087566	
1436	.	9833220233	2025-07-15 10:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
1448	Shyam suthar ji	9929110651	2025-07-15 10:00:00	Needs Followup	Dzire 2899 package  \r\nVisit company ofc IBC tower  shyam suthar ji	2024-12-08 05:58:11	4	2025-05-31 08:42:58.621937	
4096	.	9829013307	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-16 10:02:27.414006	4	2025-05-31 08:42:17.990214	
4100	.	9001452266	2025-07-05 10:00:00	Needs Followup	Not pick 	2025-02-16 10:12:26.737441	4	2025-05-31 08:42:17.990214	
4375	.	9314682161	2025-07-05 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-02-25 11:21:56.981376	4	2025-05-31 08:42:17.990214	
4625	Cx 483	8949463718	2025-07-05 10:00:00	Needs Followup	Beawar se 	2025-03-09 10:48:36.41198	6	2025-05-31 08:42:17.990214	
4626	Cx483	8875692999	2025-07-05 10:00:00	Needs Followup	Honda civic 2999	2025-03-09 10:49:20.495796	6	2025-05-31 08:42:17.990214	
4637	Cx490	9829427495	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-10 10:47:00.457455	6	2025-05-31 08:42:17.990214	
4639	Cx491	9983489489	2025-07-05 10:00:00	Needs Followup	Amaze Honda car service 	2025-03-10 10:48:43.123347	6	2025-05-31 08:42:17.990214	
4640	Cx501	9782060812	2025-07-05 10:00:00	Needs Followup	Paint problem	2025-03-10 10:51:22.436761	6	2025-05-31 08:42:17.990214	
4642	Santro 	9166565132	2025-07-05 10:00:00	Needs Followup	Dent paint ke liye	2025-03-10 10:52:44.147232	6	2025-05-31 08:42:17.990214	
4646	Cx584	9001050181	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 05:20:17.897963	6	2025-05-31 08:42:17.990214	
4647	Cx,584	9782226444	2025-07-05 10:00:00	Needs Followup	i10 old 1999	2025-03-11 05:21:22.784924	6	2025-05-31 08:42:17.990214	
4651	Cx588	9079662913	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 05:26:25.810441	6	2025-05-31 08:42:17.990214	
4652	Cx588	8440803512	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 05:27:01.529897	6	2025-05-31 08:42:17.990214	
4653	Swift 	9783416539	2025-07-05 10:00:00	Needs Followup	Sharp motor \r\nSwift 2699	2025-03-11 05:27:42.850937	6	2025-05-31 08:42:17.990214	
4658	gaadimech	8233757071	2025-07-05 10:00:00	Needs Followup	Expresso 3199\r\n	2025-03-11 07:03:20.288464	6	2025-05-31 08:42:17.990214	
4669	Cx591	7665532513	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 12:31:04.407993	6	2025-05-31 08:42:17.990214	
4671	Cx594	8107753423	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-11 12:32:20.650646	6	2025-05-31 08:42:17.990214	
4690	.	9414076968	2025-07-05 10:00:00	Needs Followup	Call cut	2025-03-12 11:10:05.17342	6	2025-05-31 08:42:17.990214	
4726	.	9414752009	2025-07-05 10:00:00	Needs Followup	Switch off 	2025-03-13 11:06:17.187546	6	2025-05-31 08:42:17.990214	
4747	Cx582	9521452261	2025-07-05 10:00:00	Needs Followup	Honda City \r\n2200	2025-03-15 11:07:24.177753	6	2025-05-31 08:42:17.990214	
4748	Cx 587	9828012041	2025-07-05 10:00:00	Needs Followup	S cross 	2025-03-15 11:08:15.672713	6	2025-05-31 08:42:17.990214	
4749	Cx588	8094304164	2025-07-05 10:00:00	Needs Followup	Ac check 	2025-03-15 11:09:02.256119	6	2025-05-31 08:42:17.990214	
4751	Cx591	8209223300	2025-07-05 10:00:00	Needs Followup	Xuv 30000\r\nDent paint 	2025-03-15 11:12:42.049087	6	2025-05-31 08:42:17.990214	
4753	Cx600	8824288455	2025-07-05 10:00:00	Needs Followup	Swift Dent paint 2300/24000	2025-03-15 11:18:49.97553	6	2025-05-31 08:42:17.990214	
4754	Cx601	9694743208	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-15 13:35:19.977303	6	2025-05-31 08:42:17.990214	
4755	Cx602	7877950150	2025-07-05 10:00:00	Needs Followup	Car service 	2025-03-15 13:36:07.728446	6	2025-05-31 08:42:17.990214	
4756	Cx602	9660484560	2025-07-05 10:00:00	Needs Followup	Ac service 	2025-03-15 13:36:39.330819	6	2025-05-31 08:42:17.990214	
4757	Cx603	9887747410	2025-07-05 10:00:00	Needs Followup	Ac service 	2025-03-15 13:37:07.228452	6	2025-05-31 08:42:17.990214	
4828	.	9772435655	2025-07-05 10:00:00	Needs Followup	Busy call u later 	2025-03-18 11:26:22.928412	6	2025-05-31 08:42:17.990214	
4789	Cx631	9828154615	2025-07-06 10:00:00	Needs Followup	Ac \r\nSharp motor 	2025-03-16 11:13:17.04102	6	2025-05-31 08:42:22.030114	
4795	Bolero ac 2000	8562827066	2025-07-06 10:00:00	Needs Followup	Bolero ac service 2000	2025-03-16 11:32:08.36818	6	2025-05-31 08:42:22.030114	
4933	Cx509	9529929029	2025-07-06 10:00:00	Needs Followup	i10\r\nService 2799	2025-03-22 07:10:21.761909	6	2025-05-31 08:42:22.030114	
4934	Cx510	6350332283	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-22 07:16:57.445071	6	2025-05-31 08:42:22.030114	
4945	Cx516	9257744566	2025-07-06 10:00:00	Needs Followup	Car service\r\nTata punch 	2025-03-22 10:43:44.89044	6	2025-05-31 08:42:22.030114	
4946	Cx519	9079935915	2025-07-06 10:00:00	Needs Followup	Car service \r\nSwitch off \r\n	2025-03-22 10:45:31.220958	6	2025-05-31 08:42:22.030114	
5246	Cx571	9829017849	2025-07-06 10:00:00	Needs Followup	Car service 	2025-03-29 05:12:21.380248	6	2025-05-31 08:42:22.030114	
5247	Cx572	9928341197	2025-07-06 10:00:00	Needs Followup	Swift package 2799	2025-03-29 05:13:02.679676	6	2025-05-31 08:42:22.030114	
5249	Cx576	9024166420	2025-07-06 10:00:00	Needs Followup	Call cut 	2025-03-29 05:20:46.291127	6	2025-05-31 08:42:22.030114	
5823	Customer 	9116014256	2025-07-06 10:00:00	Needs Followup	Creta 3599	2025-04-09 10:33:24.067639	6	2025-05-31 08:42:22.030114	
5686	Customer 	9314887845	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-08 11:56:03.408423	4	2025-05-31 08:42:26.111514	
5888	Customer 	9785079984	2025-07-07 10:00:00	Needs Followup	Honda Amaze: 3199	2025-04-13 11:50:01.654333	4	2025-05-31 08:42:26.111514	
5989	Customer 	9929333444	2025-07-07 10:00:00	Needs Followup		2025-04-15 11:38:09.359127	4	2025-05-31 08:42:26.111514	
6011	Customer 	9887502212	2025-07-07 10:00:00	Needs Followup		2025-04-15 12:12:51.94947	4	2025-05-31 08:42:26.111514	
5391	Customer 	9887981487	2025-07-07 10:00:00	Needs Followup		2025-04-01 07:15:52.304991	4	2025-05-31 08:42:26.111514	
5392	Customer 	9414717351	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:16:23.166967	4	2025-05-31 08:42:26.111514	
5394	Customer 	9166878999	2025-07-07 10:00:00	Needs Followup		2025-04-01 07:17:43.735279	4	2025-05-31 08:42:26.111514	
5397	Customer 	8769063320	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:19:27.991336	4	2025-05-31 08:42:26.111514	
5398	Customer 	8619251327	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 07:20:03.865161	4	2025-05-31 08:42:26.111514	
5403	Harikesh 	8955234776	2025-07-07 10:00:00	Needs Followup	Seltos 2299	2025-04-01 08:40:01.859845	4	2025-05-31 08:42:26.111514	
5404	Customer 	9928068111	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 08:40:29.249355	4	2025-05-31 08:42:26.111514	
5406	Customer 	9636488436	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 08:41:40.868703	4	2025-05-31 08:42:26.111514	
5407	Customer 	9828571315	2025-07-07 10:00:00	Needs Followup		2025-04-01 08:42:10.951317	4	2025-05-31 08:42:26.111514	
5408	Gaurav g	9381934803	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-01 08:42:43.319016	4	2025-05-31 08:42:26.111514	
5461	Kuldeep gautam 	9898049585	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 07:26:50.493076	4	2025-05-31 08:42:26.111514	
5462	Kunal vyas 	9893160944	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 07:27:25.21566	4	2025-05-31 08:42:26.111514	
5495	Arshad Ali 	9829675611	2025-07-07 10:00:00	Needs Followup		2025-04-02 12:24:50.491265	4	2025-05-31 08:42:26.111514	
5505	Vinod deg	9829666661	2025-07-07 10:00:00	Needs Followup		2025-04-02 12:34:06.475989	4	2025-05-31 08:42:26.111514	
5506	Komal 	9829666181	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:34:38.669856	4	2025-05-31 08:42:26.111514	
5507	Amit	9829665825	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:35:33.328644	4	2025-05-31 08:42:26.111514	
5511	Himanshu 	9829651964	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:38:39.120458	4	2025-05-31 08:42:26.111514	
5512	Christopher 	9829651072	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:43:54.458597	4	2025-05-31 08:42:26.111514	
5513	Christopher 	9829651072	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-02 12:43:58.773709	4	2025-05-31 08:42:26.111514	
5585	Mukesh 	9845201885	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-07 11:56:26.525817	4	2025-05-31 08:42:26.111514	
5587	Ashwani 	9839285758	2025-07-07 10:00:00	Needs Followup		2025-04-07 11:57:42.979934	4	2025-05-31 08:42:26.111514	
1611	.	8114466156	2025-07-04 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-10 05:43:58	4	2025-05-31 08:42:14.037958	
1602	.	9528545038	2025-07-04 10:00:00	Needs Followup	Till time not required \r\nNot pick 	2024-12-10 05:43:58	6	2025-05-31 08:42:14.037958	
1603	Ankit sir 	9929659423	2025-07-04 10:00:00	Needs Followup	Not requirement \r\nNot pick	2024-12-10 05:43:58	6	2025-05-31 08:42:14.037958	
1604	.	7828849334	2025-07-04 10:00:00	Needs Followup	Don't have car	2024-12-10 05:43:58	6	2025-05-31 08:42:14.037958	
1605	.	7014642772	2025-07-04 10:00:00	Needs Followup	Call not pick 	2024-12-10 05:43:58	6	2025-05-31 08:42:14.037958	
1613	Saurabh sir i20	9929268001	2025-07-04 10:00:00	Needs Followup	Call back 	2024-12-10 05:43:58	6	2025-05-31 08:42:14.037958	
1608	.	8003070032	2025-07-06 10:00:00	Needs Followup	Cut a call 	2024-12-10 05:43:58	4	2025-05-31 08:42:22.030114	
1609	Sunil sir	9829735935	2025-07-06 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick \r\nNot pick	2024-12-10 05:43:58	4	2025-05-31 08:42:22.030114	
1612	.	9672269269	2025-07-06 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-10 05:43:58	4	2025-05-31 08:42:22.030114	
5589	Nilay 	9839010693	2025-07-07 10:00:00	Needs Followup		2025-04-07 11:59:20.73606	4	2025-05-31 08:42:26.111514	
5601	Deepak 	9829628469	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:06:27.246863	4	2025-05-31 08:42:26.111514	
5605	Anil pareek 	9829625947	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:08:46.323935	6	2025-05-31 08:42:26.111514	
5613	Dilip Singh 	9829614875	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:12:57.559077	6	2025-05-31 08:42:26.111514	
5616	Gajendra 	9829610585	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:14:03.081912	6	2025-05-31 08:42:26.111514	
5619	Mukesh 	9829610433	2025-07-07 10:00:00	Needs Followup		2025-04-07 12:15:34.939014	6	2025-05-31 08:42:26.111514	
5660	Customer 	9414055791	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:32:29.761809	6	2025-05-31 08:42:26.111514	
5661	Customer 	9829157633	2025-07-07 10:00:00	Needs Followup		2025-04-08 11:33:04.779857	6	2025-05-31 08:42:26.111514	
5708	Customer 	8233003974	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-08 12:14:49.961365	6	2025-05-31 08:42:26.111514	
5710	Customer 	9001296022	2025-07-07 10:00:00	Needs Followup		2025-04-08 12:16:17.59733	6	2025-05-31 08:42:26.111514	
5711	Customer 	9001296022	2025-07-07 10:00:00	Needs Followup		2025-04-08 12:16:19.844028	6	2025-05-31 08:42:26.111514	
5718	Customer 	9414207876	2025-07-07 10:00:00	Needs Followup		2025-04-08 12:19:59.193702	6	2025-05-31 08:42:26.111514	
6356	Customer 	9828078965	2025-07-07 10:00:00	Needs Followup		2025-04-19 11:50:34.907388	6	2025-05-31 08:42:26.111514	
6190	Customer 	9829076780	2025-07-07 10:00:00	Needs Followup		2025-04-17 08:11:15.34664	6	2025-05-31 08:42:26.111514	
6194	Customer 	9983357600	2025-07-07 10:00:00	Needs Followup		2025-04-17 08:13:39.28191	6	2025-05-31 08:42:26.111514	
6195	Customer 	9737873687	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-17 08:14:18.077817	6	2025-05-31 08:42:26.111514	
6196	Customer 	9351311148	2025-07-07 10:00:00	Needs Followup	Not interested 	2025-04-17 08:14:50.477412	6	2025-05-31 08:42:26.111514	
6198	Customer 	7426892940	2025-07-07 10:00:00	Needs Followup		2025-04-17 08:16:26.96335	6	2025-05-31 08:42:26.111514	
6369	gaadimech 	7850994516	2025-07-07 10:00:00	Needs Followup	Audi 14999	2025-04-20 05:26:53.636349	6	2025-05-31 08:42:26.111514	
6430	Customer 	9829056198	2025-07-07 10:00:00	Needs Followup	Honda jazz\r\nDent paint 	2025-04-21 08:44:04.372725	6	2025-05-31 08:42:26.111514	
1601	.	9680138795	2025-07-15 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-10 05:43:58	4	2025-05-31 08:42:58.621937	
1599	.	9958929279	2025-07-23 10:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2024-12-10 05:43:58	6	2025-05-31 08:43:31.574711	
1610	.	8120933233	2025-07-15 10:00:00	Needs Followup	Call not pick 	2024-12-10 05:43:58	4	2025-05-31 08:42:58.621937	
6490	Customer 	9829198293	2025-07-07 10:00:00	Needs Followup		2025-04-21 11:39:14.317994	6	2025-05-31 08:42:26.111514	
4559	gaadimech 	9401605487	2025-07-07 10:00:00	Needs Followup	Eon ac checkup dent paint	2025-03-07 08:54:12.725944	6	2025-05-31 08:42:26.111514	
570	.........	9952001058	2025-07-08 10:00:00	Needs Followup	Not requirement 	2024-11-29 11:36:59	4	2025-05-31 08:42:30.087566	
571	.	9829115444	2025-07-08 10:00:00	Needs Followup	Not interested 	2024-11-30 05:56:38	4	2025-05-31 08:42:30.087566	
574	.	9829293030	2025-07-08 10:00:00	Needs Followup	Not interested 	2024-11-30 05:56:38	4	2025-05-31 08:42:30.087566	
576	.	9610003987	2025-07-08 10:00:00	Needs Followup	Not interested 	2024-11-30 06:34:08	4	2025-05-31 08:42:30.087566	
3250	.	9057230953	2025-07-08 10:00:00	Needs Followup	Not interested call cut\r\n800 2399 	2025-01-20 04:31:19.397625	6	2025-05-31 08:42:30.087566	
4008	।	9829053215	2025-07-08 10:00:00	Needs Followup	Call cut	2025-02-12 11:23:54.085316	6	2025-05-31 08:42:30.087566	
4122	.	7850974066	2025-07-08 10:00:00	Needs Followup	Not pick	2025-02-16 11:55:52.007787	6	2025-05-31 08:42:30.087566	
6209	Customer 	9660211100	2025-07-09 10:00:00	Needs Followup		2025-04-17 10:44:44.863903	4	2025-05-31 08:42:34.144665	
6210	Customer 	9887451312	2025-07-09 10:00:00	Needs Followup		2025-04-17 10:45:27.740586	4	2025-05-31 08:42:34.144665	
6217	Customer 	7014870239	2025-07-09 10:00:00	Needs Followup		2025-04-17 10:50:25.685458	4	2025-05-31 08:42:34.144665	
6220	Customer 	9694008541	2025-07-09 10:00:00	Needs Followup		2025-04-17 10:51:58.002702	4	2025-05-31 08:42:34.144665	
6364	Customer 	9829018119	2025-07-09 10:00:00	Needs Followup		2025-04-19 11:55:04.568872	4	2025-05-31 08:42:34.144665	
5414	Customer 	8058589954	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:08:31.55577	6	2025-05-31 08:42:34.144665	
5415	Customer 	8561020140	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:08:59.301244	6	2025-05-31 08:42:34.144665	
5416	Customer 	9829086082	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:09:23.169975	6	2025-05-31 08:42:34.144665	
5417	Customer 	8302227089	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:09:44.943681	6	2025-05-31 08:42:34.144665	
5418	Customer 	8929848400	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:10:16.020753	6	2025-05-31 08:42:34.144665	
5419	Customer 	7877502402	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:11:07.274122	6	2025-05-31 08:42:34.144665	
5420	Omprakash g	9829810789	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:11:40.176231	6	2025-05-31 08:42:34.144665	
5421	Customer 	9314938773	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-01 09:12:04.827081	6	2025-05-31 08:42:34.144665	
5422	Naveen g 	9314203978	2025-07-09 10:00:00	Needs Followup		2025-04-01 09:12:33.285808	6	2025-05-31 08:42:34.144665	
5467	Hanuman 	9892055193	2025-07-09 10:00:00	Needs Followup		2025-04-02 07:30:53.543993	6	2025-05-31 08:42:34.144665	
5479	Manohar 	9829699719	2025-07-09 10:00:00	Needs Followup		2025-04-02 12:04:12.367264	6	2025-05-31 08:42:34.144665	
5480	Jai prakash 	9829698453	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:04:46.044543	6	2025-05-31 08:42:34.144665	
5481	Narsi lal 	9829694624	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:05:16.473202	6	2025-05-31 08:42:34.144665	
5483	Vineet 	9829683762	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:06:28.934783	6	2025-05-31 08:42:34.144665	
1636	.	9555471472	2025-07-26 10:00:00	Needs Followup	Call not pick \r\nFree service due 	2024-12-10 05:43:58	6	2025-05-31 08:43:43.903509	
3602	AMIT JI 	9680345678	2025-07-18 18:30:00	Feedback	safari not picking 	2025-02-02 08:44:54.392846	9	2025-07-03 05:27:44.147558	RJ14UJ4831
1794	.	9982010820	2025-07-21 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-14 04:46:30	4	2025-05-31 08:43:23.449024	
1795	.	8527225999	2025-07-21 10:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-14 06:02:14	4	2025-05-31 08:43:23.449024	
1791	.	9222303402	2025-07-24 10:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 12:47:07	4	2025-05-31 08:43:35.995616	
1774	.	8619455495	2025-07-26 10:00:00	Needs Followup	Living mumbai  self call back	2024-12-13 10:36:16	6	2025-05-31 08:43:43.903509	
1778	.	9928871518	2025-07-26 10:00:00	Needs Followup	Cut a call 	2024-12-13 10:36:16	6	2025-05-31 08:43:43.903509	
1790	.	9828563164	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2024-12-13 12:47:07	6	2025-06-30 11:43:58.52812	
1781	.	9694487878	2025-07-04 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-13 11:43:31	6	2025-05-31 08:42:14.037958	
1772	.	8442070916	2025-07-06 10:00:00	Needs Followup	Cut a call 	2024-12-13 10:36:16	4	2025-05-31 08:42:22.030114	
1776	.	9694057690	2025-07-06 10:00:00	Needs Followup	Cut a call 	2024-12-13 10:36:16	4	2025-05-31 08:42:22.030114	
1777	.	8890060168	2025-07-06 10:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-13 10:36:16	4	2025-05-31 08:42:22.030114	
1783	.	8947816090	2025-07-06 10:00:00	Needs Followup	Cut a call 	2024-12-13 11:43:31	4	2025-05-31 08:42:22.030114	
1784	.	9887515147	2025-07-06 10:00:00	Needs Followup	Switch off \r\nCall cut	2024-12-13 11:43:31	4	2025-05-31 08:42:22.030114	
1786	.	7568115144	2025-07-06 10:00:00	Needs Followup	Beat 2499	2024-12-13 12:31:02	4	2025-05-31 08:42:22.030114	
1792	.	9620369559	2025-07-08 10:00:00	Needs Followup	Ciaz 2999	2024-12-13 12:47:07	4	2025-05-31 08:42:30.087566	
1787	.	7568115144	2025-07-15 10:00:00	Needs Followup	Beat 2499	2024-12-13 12:47:07	4	2025-05-31 08:42:58.621937	
1788	.	7568115144	2025-07-15 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nBeat suspension work 	2024-12-13 12:47:07	4	2025-05-31 08:42:58.621937	
1773	.	9928322080	2025-07-18 10:00:00	Needs Followup	Call not pick 	2024-12-13 10:36:16	4	2025-05-31 08:43:10.854377	
1803	.	8003368098	2025-07-21 10:00:00	Needs Followup	Not requirement 	2024-12-14 07:02:01	4	2025-05-31 08:43:23.449024	
1810	.	8239741149	2025-07-24 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-14 07:02:01	4	2025-05-31 08:43:35.995616	
7142	Cx2006	8882125658	2025-07-26 10:00:00	Needs Followup	Wr service 2599	2025-05-13 06:58:16.806822	4	2025-05-31 08:43:43.903509	
1805	.	8561823636	2025-07-26 10:00:00	Needs Followup	Cut a call 	2024-12-14 07:02:01	6	2025-05-31 08:43:43.903509	
1809	.	9785820692	2025-07-25 18:30:00	Did Not Pick Up	Call not pick\r\nNot pick	2024-12-14 07:02:01	6	2025-05-16 11:35:19.028222	
1785	.	9799942157	2025-07-11 18:30:00	Did Not Pick Up	Cut a call \r\nNot pick	2024-12-13 11:43:31	6	2025-06-28 11:45:33.239921	9
1808	.	9983169755	2025-07-08 10:00:00	Needs Followup	Not requirement 	2024-12-14 07:02:01	6	2025-05-31 08:42:30.087566	
1798	.	7425886780	2025-07-15 10:00:00	Needs Followup	Cut a call\r\nNot interested 	2024-12-14 07:02:01	4	2025-05-31 08:42:58.621937	
1801	.	9828777751	2025-07-15 10:00:00	Needs Followup	Cut a call 	2024-12-14 07:02:01	4	2025-05-31 08:42:58.621937	
1802	.	9509308169	2025-07-15 10:00:00	Needs Followup	Call not pick \r\nDon't have car	2024-12-14 07:02:01	4	2025-05-31 08:42:58.621937	
1806	.	9887535364	2025-07-15 10:00:00	Needs Followup	Cut a call 	2024-12-14 07:02:01	4	2025-05-31 08:42:58.621937	
1811	.	8875001696	2025-07-15 10:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 07:02:01	4	2025-05-31 08:42:58.621937	
7098	gaadimech	7014673944	2025-09-11 18:30:00	Did Not Pick Up	Wagnore 2399\r\nNot required 	2025-05-11 05:59:55.419548	6	2025-06-30 09:23:59.122997	
2263	.	9829011156	2025-07-25 18:30:00	Needs Followup	Call back \r\nNot interested 	2024-12-20 08:28:57.743192	6	2025-06-28 11:22:30.695002	
2258	.	9983662625	2025-07-11 18:30:00	Needs Followup	Call not pick	2024-12-20 08:28:57.743192	6	2025-06-28 11:23:05.718475	
2261	.	9828444496	2025-10-24 18:30:00	Needs Followup	Cut a call \r\nAlto service done 	2024-12-20 08:28:57.743192	6	2025-06-28 11:29:44.501352	
2262	.	9672606606	2025-07-02 18:30:00	Did Not Pick Up	Not interested 	2024-12-20 08:28:57.743192	6	2025-06-28 11:41:03.552532	
2260	.	9929661636	2025-07-04 18:30:00	Did Not Pick Up	Not pick 	2024-12-20 08:28:57.743192	6	2025-06-28 11:42:55.16285	
2465	.	9314311321	2025-07-01 18:30:00	Needs Followup	No answer 	2024-12-23 12:40:16.565752	4	2025-07-01 11:20:36.589097	
2461	.	9166882071	2025-07-02 18:30:00	Needs Followup	Call cut	2024-12-23 11:53:22.068392	4	2025-07-01 11:22:38.196666	
2463	.	9887930242	2025-07-22 18:30:00	Needs Followup	Abhi nahi 	2024-12-23 11:53:22.068392	4	2025-07-01 11:28:27.352558	
2462	.	7023908480	2025-06-30 18:30:00	Needs Followup	Alwar se	2024-12-23 11:53:22.068392	4	2025-07-01 11:34:22.757214	
2458	.	9414057735	2025-07-23 18:30:00	Needs Followup	Car service 	2024-12-23 11:53:22.068392	4	2025-07-01 11:42:15.574128	
2459	.	9983662323	2025-06-30 18:30:00	Needs Followup	Alwar rehta hu 	2024-12-23 11:53:22.068392	4	2025-07-01 11:44:47.073621	
2460	.	9828021364	2025-07-18 18:30:00	Needs Followup	8 din daad	2024-12-23 11:53:22.068392	4	2025-07-01 11:46:51.722315	
2457	.	8955333302	2025-07-05 18:30:00	Needs Followup	Call not pick 	2024-12-23 11:29:14.814402	4	2025-07-01 11:48:38.289318	
2456	.	7838378583	2025-06-30 18:30:00	Needs Followup	Delhi se hu 	2024-12-23 10:08:03.720269	4	2025-07-01 11:50:58.127544	
2455	.	9314885521	2025-07-18 18:30:00	Needs Followup	Car service 	2024-12-23 10:08:03.720269	4	2025-07-01 11:57:16.7744	
2454	.	9785281055	2025-07-11 18:30:00	Needs Followup	Car service 	2024-12-23 10:08:03.720269	4	2025-07-01 12:03:44.397113	
2453	.	9314276457	2025-07-02 18:30:00	Needs Followup	Call cut	2024-12-23 10:08:03.720269	4	2025-07-01 12:06:08.411432	
2452	.	9829100008	2025-07-06 18:30:00	Needs Followup	Abhi nahi 	2024-12-23 10:08:03.720269	4	2025-07-01 12:07:52.77712	
2451	.	8696913756	2025-06-30 18:30:00	Needs Followup	Amanya hai no 	2024-12-23 10:08:03.720269	4	2025-07-01 12:08:45.848259	
2448	.	9587229466	2025-07-17 18:30:00	Needs Followup	Tata punch 	2024-12-23 10:08:03.720269	4	2025-07-01 12:10:28.249451	
2394	.	9314966522	2025-07-02 18:30:00	Needs Followup	Car service 	2024-12-23 04:37:08.828595	4	2025-06-30 10:07:03.212892	
2449	.	8107775917	2025-07-10 18:30:00	Needs Followup	Car service 	2024-12-23 10:08:03.720269	4	2025-07-01 12:34:04.405257	
2392	.	9414041881	2025-07-02 18:30:00	Needs Followup	Car service 	2024-12-23 04:37:08.828595	4	2025-06-30 10:22:35.514884	
2391	.	9829267590	2025-07-01 18:30:00	Needs Followup	Call end 	2024-12-23 04:37:08.828595	4	2025-06-30 10:27:29.996432	
2390	.	9672970270	2025-07-01 18:30:00	Needs Followup	Call cut 	2024-12-22 12:38:01.590161	4	2025-06-30 10:32:17.094849	
2389	.	9414210512	2025-07-01 18:30:00	Needs Followup	Call cut 	2024-12-22 12:38:01.590161	4	2025-06-30 10:36:16.04503	
2388	.	9214327232	2025-07-17 18:30:00	Needs Followup	Honda mobilio 2999	2024-12-22 12:38:01.590161	4	2025-06-30 10:39:33.859084	
2387	.	9214327232	2025-07-17 18:30:00	Needs Followup	Abhi nahi karwani 	2024-12-22 11:59:29.710349	4	2025-06-30 10:42:29.357601	
2386	.	9829277575	2025-07-02 18:30:00	Needs Followup	Cut a call 	2024-12-22 11:59:29.710349	4	2025-06-30 10:45:03.792554	
2450	.	7230062308	2025-07-01 18:30:00	Needs Followup	Switch off 	2024-12-23 10:08:03.720269	4	2025-07-01 12:37:17.495442	
2439	.	8387945065	2025-07-02 18:30:00	Needs Followup	Call  cut	2024-12-23 08:16:54.59051	4	2025-07-01 12:40:35.134176	
2383	Swift 	9829010041	2025-07-03 18:30:00	Needs Followup	Swift 2899\r\nNo save kar loga	2024-12-22 11:18:43.642026	4	2025-06-30 11:11:23.947659	
2382	.	9829345135	2025-07-01 18:30:00	Needs Followup	Cut a call 	2024-12-22 11:18:43.642026	4	2025-06-30 11:23:17.044413	
2438	.	9929999503	2025-07-01 18:30:00	Needs Followup	No answer 	2024-12-23 08:16:54.59051	4	2025-07-01 12:41:14.493553	
2375	.	9783032111	2025-07-01 18:30:00	Needs Followup	Call cut	2024-12-22 09:44:02.370203	4	2025-06-30 11:39:47.633833	
2396	.	8094446777	2025-07-16 18:30:00	Did Not Pick Up	Callcut	2024-12-23 04:37:08.828595	6	2025-06-30 11:41:15.722034	
2397	.	9828896555	2025-07-08 18:30:00	Did Not Pick Up	Busy not pick 	2024-12-23 04:37:08.828595	6	2025-06-30 11:42:38.368362	
2398	.	9828896555	2025-07-11 18:30:00	Did Not Pick Up	Busy \r\nCall cut	2024-12-23 04:37:08.828595	6	2025-06-30 11:43:03.473957	
2376	.	9799362222	2025-07-02 18:30:00	Needs Followup	Cut a call 	2024-12-22 09:44:02.370203	4	2025-06-30 11:44:19.314096	
2379	.	9214694051	2025-07-01 18:30:00	Needs Followup	Car service 	2024-12-22 09:44:02.370203	4	2025-06-30 12:44:39.340272	
2377	Ankush sir	9828533710	2025-07-01 18:30:00	Needs Followup	WhatsApp package shared \r\nAlto 1999	2024-12-22 09:44:02.370203	4	2025-06-30 12:47:51.510408	
2440	.	9672724188	2025-07-24 18:30:00	Needs Followup	Ertiga 2899	2024-12-23 08:16:54.59051	4	2025-07-01 12:43:58.538509	
2442	.	9610444823	2025-07-10 18:30:00	Needs Followup	Tata punch 	2024-12-23 08:16:54.59051	4	2025-07-01 12:49:26.928469	
2441	.	9819806748	2025-07-03 18:30:00	Needs Followup	Cut a call 	2024-12-23 08:16:54.59051	4	2025-07-01 12:50:34.769853	
2373	.	9414067627	2025-07-01 18:30:00	Needs Followup	Call cut	2024-12-22 08:06:41.389566	4	2025-06-30 12:59:45.390077	
2443	.	8824674004	2025-07-09 18:30:00	Needs Followup	Car service 	2024-12-23 08:16:54.59051	4	2025-07-01 12:55:49.011472	
2444	.	9352784459	2025-07-03 18:30:00	Needs Followup	Car service 	2024-12-23 08:16:54.59051	4	2025-07-01 12:59:56.894593	
2445	.	7014930436	2025-07-05 18:30:00	Needs Followup	Honda accent 	2024-12-23 08:16:54.59051	4	2025-07-01 13:05:13.94799	
2446	.	9602455551	2025-07-02 18:30:00	Needs Followup	Call cut	2024-12-23 08:16:54.59051	4	2025-07-01 13:08:36.288299	
2436	.	9251444442	2025-06-30 18:30:00	Needs Followup	Bikaner se hu	2024-12-23 08:16:54.59051	4	2025-07-01 13:10:08.784766	
418	Cx76	9773356222	2025-07-13 18:30:00	Needs Followup	Nissan Sunny 3999 Not picking 	2024-11-27 11:01:48	9	2025-07-03 05:26:22.002624	
2447	.	9610838245	2025-06-30 18:30:00	Needs Followup	Rajsamand se hu	2024-12-23 08:16:54.59051	4	2025-07-01 13:13:25.434482	
3483	.	9887419843	2025-07-03 10:00:00	Needs Followup	Baleno 2599\r\nNano 2000	2025-01-27 09:13:20.568933	6	2025-05-31 08:42:09.584832	
5309	Customer 	9414542305	2025-07-03 10:00:00	Needs Followup	Not interested 	2025-03-30 11:00:59.289607	6	2025-05-31 08:42:09.584832	
5310	Customer 	6350380492	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:01:30.756094	6	2025-05-31 08:42:09.584832	
5311	Customer 	8094272067	2025-07-03 10:00:00	Needs Followup		2025-03-30 11:02:00.89721	6	2025-05-31 08:42:09.584832	
5312	Customer 	9975214746	2025-07-06 10:00:00	Needs Followup	Not interested 	2025-03-30 11:02:29.309636	6	2025-05-31 08:42:22.030114	
5308	Customer 	9899751654	2025-07-16 10:00:00	Needs Followup	Honda City 3399\r\nWill plan after 2nd April 	2025-03-30 11:00:26.279806	4	2025-05-31 08:43:02.994951	
6569	Customer 	9829056081	2025-07-20 10:00:00	Needs Followup		2025-04-22 10:05:01.146032	4	2025-05-31 08:43:19.077196	
6588	Customer 	9829055528	2025-07-20 10:00:00	Needs Followup		2025-04-22 12:08:36.840016	4	2025-05-31 08:43:19.077196	
6598	Customer 	9414326445	2025-07-20 10:00:00	Needs Followup		2025-04-22 12:13:47.934232	4	2025-05-31 08:43:19.077196	
5313	Customer 	9414249278	2025-07-06 18:30:00	Needs Followup	Not interested 	2025-03-30 11:03:01.323466	6	2025-07-06 09:57:17.1322	
6599	Customer 	9829379006	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:14:21.859113	4	2025-05-31 08:43:14.897002	
6628	Customer 	9314511107	2025-07-20 10:00:00	Needs Followup		2025-04-24 12:42:33.827571	4	2025-05-31 08:43:19.077196	
6579	Customer 	9414200103	2025-07-21 10:00:00	Needs Followup		2025-04-22 10:56:37.754512	6	2025-05-31 08:43:23.449024	
6584	Customer 	9828085094	2025-07-21 10:00:00	Needs Followup		2025-04-22 12:06:50.781276	6	2025-05-31 08:43:23.449024	
6602	Customer 	9829067761	2025-07-22 10:00:00	Needs Followup		2025-04-22 12:20:43.410132	6	2025-05-31 08:43:27.624295	
6577	Customer 	9829064211	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:55:45.42705	4	2025-05-31 08:43:31.574711	
6578	Customer 	9414044533	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:56:07.524967	4	2025-05-31 08:43:31.574711	
6567	Customer 	9829069532	2025-07-23 10:00:00	Needs Followup		2025-04-22 10:03:58.97812	6	2025-05-31 08:43:31.574711	
6596	Customer 	9314502710	2025-07-23 10:00:00	Needs Followup		2025-04-22 12:12:29.631388	6	2025-05-31 08:43:31.574711	
6601	Customer 	9414812083	2025-07-23 10:00:00	Needs Followup	Creata 3599	2025-04-22 12:20:17.008164	6	2025-05-31 08:43:31.574711	
6603	Customer 	9829081651	2025-07-23 10:00:00	Needs Followup		2025-04-22 12:21:05.800443	6	2025-05-31 08:43:31.574711	
6573	Customer 	9829064211	2025-07-24 10:00:00	Needs Followup		2025-04-22 10:28:35.531864	6	2025-05-31 08:43:35.995616	
6621	gaadimech 	9982730803	2025-07-24 10:00:00	Needs Followup	Xuv service 	2025-04-24 04:24:06.596752	6	2025-05-31 08:43:35.995616	
6627	Customer 	9314527607	2025-07-24 10:00:00	Needs Followup		2025-04-24 12:40:49.755656	6	2025-05-31 08:43:35.995616	
6522	Cx1121	8420030628	2025-07-25 10:00:00	Needs Followup	Car ac service 	2025-04-22 05:55:22.58787	6	2025-05-31 08:43:39.880052	
6575	Cx1129	9414774422	2025-07-25 10:00:00	Needs Followup	Tata tiago 3199	2025-04-22 10:39:38.092104	6	2025-05-31 08:43:39.880052	
6576	Cx1130	9001929879	2025-07-25 10:00:00	Needs Followup	Honda City \r\n3699	2025-04-22 10:40:45.547336	6	2025-05-31 08:43:39.880052	
7147	Cx2006	8209425353	2025-07-26 10:00:00	Needs Followup	Dent paint 	2025-05-13 07:04:54.528939	4	2025-05-31 08:43:43.903509	
7150	Cx2006	8559828682	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 07:07:21.80525	4	2025-05-31 08:43:43.903509	
6594	Customer 	9829021114	2025-07-26 10:00:00	Needs Followup		2025-04-22 12:11:35.423519	6	2025-05-31 08:43:43.903509	
6600	Customer 	9414812083	2025-07-26 10:00:00	Needs Followup		2025-04-22 12:14:42.894081	6	2025-05-31 08:43:43.903509	
6629	gadimech	9116040046	2025-07-27 10:00:00	Needs Followup	I20 bumper paint 2299\r\nNot pick 	2025-04-25 04:42:08.482198	6	2025-05-31 08:43:47.842094	
7149	Cx2006	8559828682	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-13 07:07:16.912865	6	2025-05-31 08:43:51.744985	
6572	Customer 	9829018088	2025-07-19 10:00:00	Needs Followup	Skoda \r\nBmw\r\nX2\r\nX5	2025-04-22 10:27:50.818387	4	2025-05-31 08:43:14.897002	
6568	Customer 	9829015040	2025-07-17 10:00:00	Needs Followup		2025-04-22 10:04:25.022414	4	2025-05-31 08:43:06.869056	
6581	Customer 	9414304484	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:05:03.230523	4	2025-05-31 08:43:14.897002	
6582	Customer 	9829065710	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:05:41.431914	4	2025-05-31 08:43:14.897002	
5543	Cx616	9571041686	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-05 05:04:05.503874	4	2025-05-31 08:43:10.854377	
6605	Cx1126	7982208785	2025-07-18 10:00:00	Needs Followup	Voice call \r\nIn coming nahi hai 	2025-04-23 05:52:28.597829	6	2025-05-31 08:43:10.854377	
6606	Cx1127	9660089992	2025-07-18 10:00:00	Needs Followup	Accent dent paint 	2025-04-23 05:53:34.730758	6	2025-05-31 08:43:10.854377	
6607	Cc1128	9828000000	2025-07-18 10:00:00	Needs Followup	Nexon 3699 service 	2025-04-23 05:56:27.11434	6	2025-05-31 08:43:10.854377	
6609	Cx1129	8000756979	2025-07-18 10:00:00	Needs Followup	Scorpio 5199\r\n	2025-04-23 05:58:21.907273	6	2025-05-31 08:43:10.854377	
6614	Cc1131	9571664886	2025-07-18 10:00:00	Needs Followup	Duster 4899	2025-04-23 06:12:09.184178	6	2025-05-31 08:43:10.854377	
6589	Customer 	9829028406	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:09:02.757574	4	2025-05-31 08:43:14.897002	
6597	Customer 	9411870905	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:13:03.591251	4	2025-05-31 08:43:14.897002	
6626	gaadimech 	9782682396	2025-07-30 18:30:00	Needs Followup	Datson go 2799\r\nService done other workshop	2025-04-24 08:29:28.825378	6	2025-04-29 07:02:09.828041	
6604	Customer 	9829043783	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:21:33.612939	4	2025-05-31 08:43:14.897002	
6590	Customer 	9414051201	2025-07-19 10:00:00	Needs Followup	I 20	2025-04-22 12:09:34.144584	6	2025-05-31 08:43:14.897002	
6615	Cx1131	8209685604	2025-07-18 10:00:00	Needs Followup	i10 era \r\nService \r\n	2025-04-23 06:14:25.54747	6	2025-05-31 08:43:10.854377	
6617	Cx133	9571000399	2025-07-18 10:00:00	Needs Followup	Alto 2399	2025-04-23 07:57:54.6895	6	2025-05-31 08:43:10.854377	
6593	Customer 	9829016693	2025-07-19 10:00:00	Needs Followup		2025-04-22 12:11:13.798337	6	2025-05-31 08:43:14.897002	
6660	Cx1137	9828444320	2025-07-20 10:00:00	Needs Followup	Wrv service 3999	2025-04-25 10:19:02.270612	4	2025-05-31 08:43:19.077196	
6632	gaadimech 	9829046868	2025-09-26 18:30:00	Needs Followup	Amaze service done	2025-04-25 05:01:33.267541	6	2025-04-25 05:01:33.26755	
6669	gaadimech 	9782060812	2025-07-19 10:00:00	Needs Followup	Not pick 	2025-04-25 10:43:59.167821	6	2025-05-31 08:43:14.897002	
7075	gaadimech 	9829873393	2025-07-05 18:30:00	Did Not Pick Up	Santro 2599 vki	2025-05-10 09:38:07.54188	6	2025-07-02 10:57:34.328627	
6622	gaadimech 	9001098302	2025-09-18 18:30:00	Did Not Pick Up	Service done Xcent  next time requirement hui to call karenge	2025-04-24 04:54:16.350484	6	2025-04-25 06:31:09.900808	
7189	Customer 	7611003892	2025-07-22 10:00:00	Needs Followup		2025-05-14 12:15:26.052741	4	2025-05-31 08:43:27.624295	
6630	gaadimech 	9983343292	2025-07-22 10:00:00	Needs Followup	Call back 2 pm\r\nNot pick 	2025-04-25 04:49:33.478766	6	2025-05-31 08:43:27.624295	
6655	gaadimech 	9784147797	2025-07-22 10:00:00	Needs Followup	Call cut	2025-04-25 10:00:34.498416	6	2025-05-31 08:43:27.624295	
6671	gaadimech	8233659820	2025-07-22 10:00:00	Needs Followup	Injecter clean Xcent sharp	2025-04-25 10:58:47.009472	6	2025-05-31 08:43:27.624295	
6638	gaadimech 	9413422262	2025-07-24 10:00:00	Needs Followup	Not interested 	2025-04-25 09:15:37.9913	6	2025-05-31 08:43:35.995616	
6641	gaadimech 	9460688888	2025-07-24 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-04-25 09:25:03.750394	6	2025-05-31 08:43:35.995616	
6642	gaadimech 	8107309090	2025-07-24 10:00:00	Needs Followup	Call cut	2025-04-25 09:26:58.791149	6	2025-05-31 08:43:35.995616	
6643	gaadimech 	9828998881	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-25 09:32:00.239223	6	2025-05-31 08:43:35.995616	
6646	gaadimech 	8650565758	2025-07-24 10:00:00	Needs Followup	Not pick 	2025-04-25 09:39:51.879543	6	2025-05-31 08:43:35.995616	
6666	gaadimech 	7742996198	2025-07-25 10:00:00	Needs Followup	Call cut	2025-04-25 10:34:31.722552	4	2025-05-31 08:43:39.880052	
6670	gaadimech 	9314753912	2025-07-25 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-25 10:47:16.180326	4	2025-05-31 08:43:39.880052	
6683	gaadimech 	9166565132	2025-07-25 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-25 11:40:04.923271	4	2025-05-31 08:43:39.880052	
7151	Cx2007	9929891224	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 07:08:07.165785	4	2025-05-31 08:43:43.903509	
6686	gaadimech 	9610611130	2025-07-25 10:00:00	Needs Followup	Not interested 	2025-04-25 11:46:07.441492	4	2025-05-31 08:43:39.880052	
7152	Cx2008	8094222777	2025-07-26 10:00:00	Needs Followup	Polo dent paint 	2025-05-13 07:09:00.111632	4	2025-05-31 08:43:43.903509	
6682	gaadimech 	7737773249	2025-11-27 18:30:00	Did Not Pick Up	Call cut\r\nNot required free service due 	2025-04-25 11:38:48.630553	6	2025-04-26 06:11:41.863336	
7155	Cx2009	7737748724	2025-07-26 10:00:00	Needs Followup	Car service \r\n	2025-05-13 07:11:36.454911	4	2025-05-31 08:43:43.903509	
6635	gaadimech 	8114460084	2025-07-27 10:00:00	Needs Followup	I10 2299\r\nNot pick 	2025-04-25 05:15:37.259555	6	2025-05-31 08:43:47.842094	
6676	Cx1136	9602760909	2025-07-09 10:00:00	Needs Followup	Dzire car service 	2025-04-25 11:14:55.834552	4	2025-05-31 08:42:34.144665	
6640	gaadimech 	8287541488	2025-07-27 10:00:00	Needs Followup	Busy call u later \r\nCall cut	2025-04-25 09:21:51.781922	6	2025-05-31 08:43:47.842094	
6647	gaadimech 	9829515318	2025-07-27 10:00:00	Needs Followup	Not pick 	2025-04-25 09:41:27.085279	6	2025-05-31 08:43:47.842094	
6651	gaadimech 	9828277276	2025-07-28 10:00:00	Needs Followup	Call cut\r\nNot required 	2025-04-25 09:50:41.408487	4	2025-05-31 08:43:51.744985	
6672	gaadimech 	9983489489	2025-07-30 18:30:00	Did Not Pick Up	Amaze 3199 \r\nService done alredy 	2025-04-25 11:03:11.899149	6	2025-05-02 12:37:15.931532	
6652	gaadimech 	7976824500	2025-07-28 10:00:00	Needs Followup	Not required 	2025-04-25 09:52:57.593692	4	2025-05-31 08:43:51.744985	
6649	gaadimech 	9351166878	2025-07-29 18:30:00	Did Not Pick Up	Not pick \r\nNot interested service done	2025-04-25 09:46:49.907682	6	2025-04-27 08:25:04.069863	
6656	gaadimech 	9166380038	2025-07-28 10:00:00	Needs Followup	Carnival 6999	2025-04-25 10:02:18.440187	4	2025-05-31 08:43:51.744985	
6661	gaadimech 	9829118523	2025-07-28 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-25 10:19:50.931472	4	2025-05-31 08:43:51.744985	
6662	gaadimech 	9982615227	2025-07-28 10:00:00	Needs Followup	Not interested 	2025-04-25 10:24:09.046296	4	2025-05-31 08:43:51.744985	
6665	gaadimech 	7732972800	2025-07-28 10:00:00	Needs Followup	Call cut 	2025-04-25 10:32:47.411898	4	2025-05-31 08:43:51.744985	
6618	Cx1134	9571000399	2025-07-18 10:00:00	Needs Followup	Alto service 2399	2025-04-23 08:01:59.425112	6	2025-05-31 08:43:10.854377	
6639	gaadimech 	7976290234	2025-09-26 18:30:00	Did Not Pick Up	Busy call u later \r\nCall cut \r\nVoice mail 	2025-04-25 09:21:13.810554	6	2025-05-17 12:16:09.908729	
6634	gaadimech 	8690889811	2025-09-25 18:30:00	Did Not Pick Up	Swift 2799 2 may book \r\nNot pick 	2025-04-25 05:08:33.637112	6	2025-05-20 10:20:19.518417	
6636	gaadimech 	8003747857	2025-07-14 10:00:00	Needs Followup	Honda city 3199	2025-04-25 09:05:37.748574	6	2025-05-31 08:42:54.38585	
6695	Cx1142	9928403432	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-26 04:49:59.785341	4	2025-05-31 08:43:19.077196	
6701	Vc1146	7014372551	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-26 04:58:04.131962	4	2025-05-31 08:43:19.077196	
6714	Cx1146	9571142186	2025-07-20 10:00:00	Needs Followup	Ac service 	2025-04-26 10:13:28.268427	4	2025-05-31 08:43:19.077196	
6742	Cx1140	8302686952	2025-07-20 10:00:00	Needs Followup	Ac service 	2025-04-27 06:54:34.410157	4	2025-05-31 08:43:19.077196	
6744	Grand vitara 	8881777469	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-28 04:42:56.854827	4	2025-05-31 08:43:19.077196	
6746	Cx1150	7689983011	2025-07-20 10:00:00	Needs Followup	Car service 	2025-04-28 04:44:52.15083	4	2025-05-31 08:43:19.077196	
6748	Tiago chhat dent paint 	9799995117	2025-07-20 10:00:00	Needs Followup	Tiago chhat dent paint 	2025-04-28 04:46:30.096211	4	2025-05-31 08:43:19.077196	
6924	Cx1172	8104049061	2025-07-20 10:00:00	Needs Followup	Skoda 4699	2025-05-06 07:06:55.821491	6	2025-05-31 08:43:19.077196	
7070	Cx1180	7737188349	2025-07-20 10:00:00	Needs Followup	Xuv  500 service 5199	2025-05-10 08:52:38.912896	6	2025-05-31 08:43:19.077196	
6728	customer 	8696789996	2025-07-22 10:00:00	Needs Followup	Call cut	2025-04-26 11:21:19.417362	4	2025-05-31 08:43:27.624295	
6708	gaadimech 	8690819357	2025-07-25 10:00:00	Needs Followup	S-presso 2599	2025-04-26 05:31:51.891268	4	2025-05-31 08:43:39.880052	
6712	customer 	9461645011	2025-07-25 10:00:00	Needs Followup	Not interested 	2025-04-26 10:02:09.904374	4	2025-05-31 08:43:39.880052	
6688	Cx1139	9314822198	2025-07-18 10:00:00	Needs Followup	Dent paint 	2025-04-25 12:16:00.128251	6	2025-05-31 08:43:10.854377	
6719	customer 	9782522726	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-26 10:16:34.29872	4	2025-05-31 08:43:39.880052	
5484	Ritesh 	9829682212	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:07:13.098457	6	2025-05-31 08:42:34.144665	
6663	customer 	8949491032	2025-07-25 18:30:00	Did Not Pick Up	Not interested 	2025-04-25 10:26:57.64437	6	2025-06-28 07:24:01.77613	
6654	gaadimech 	9694659072	2025-07-25 18:30:00	Needs Followup	Service done i10	2025-04-25 09:58:48.604019	6	2025-06-28 07:25:06.55144	
6722	 customer 	9680900900	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-26 10:19:40.558202	4	2025-05-31 08:43:39.880052	
6723	gaadimech 	9414186409	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-26 10:23:31.910155	4	2025-05-31 08:43:39.880052	
6727	gaadimech 	8104053861	2025-07-25 10:00:00	Needs Followup	Not interested 	2025-04-26 11:09:37.972863	4	2025-05-31 08:43:39.880052	
6729	customer 	9649905005	2025-07-30 18:30:00	Did Not Pick Up	Not pick \r\nService done  other workshop	2025-04-26 11:25:51.691256	6	2025-04-28 06:25:57.188667	
6732	customer 	9149786358	2025-07-25 10:00:00	Needs Followup	Call cut	2025-04-26 11:37:37.795543	4	2025-05-31 08:43:39.880052	
6734	customer 	9782865100	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-26 12:20:16.75407	4	2025-05-31 08:43:39.880052	
6736	gaadimech 	9983850518	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-04-26 12:27:06.224184	4	2025-05-31 08:43:39.880052	
6737	customer 	8955939918	2025-07-25 10:00:00	Needs Followup	Call cut	2025-04-26 12:28:51.155222	4	2025-05-31 08:43:39.880052	
6805	gaadimech 	9509310143	2025-07-25 10:00:00	Needs Followup	800 2299 call back\r\nCall cut	2025-04-30 05:55:20.615465	4	2025-05-31 08:43:39.880052	
6687	Cx1137	8386967973	2025-07-25 10:00:00	Needs Followup	Dent paint 	2025-04-25 12:15:24.133256	6	2025-05-31 08:43:39.880052	
6718	Cx1148	9897317887	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-26 10:16:27.884679	6	2025-05-31 08:43:39.880052	
6720	Cx1147	9214074189	2025-07-25 10:00:00	Needs Followup	Car service 	2025-04-26 10:17:06.624051	6	2025-05-31 08:43:39.880052	
6700	Cx1146	9849592329	2025-07-28 10:00:00	Needs Followup	Car service 	2025-04-26 04:57:24.120887	4	2025-05-31 08:43:51.744985	
6706	gaadimech 	9667828002	2025-07-30 18:30:00	Did Not Pick Up	Call cut\r\nNot interested 	2025-04-26 05:30:55.922033	6	2025-04-29 07:32:07.748501	
6715	gaadimech 	9784716210	2025-07-28 10:00:00	Needs Followup	Not connect 	2025-04-26 10:14:48.272432	4	2025-05-31 08:43:51.744985	
6721	customer 	9460942475	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-04-26 10:17:52.635078	4	2025-05-31 08:43:51.744985	
6730	customer 	9887813078	2025-07-28 10:00:00	Needs Followup	Not pick \r\nBaleno venue not interested 	2025-04-26 11:26:55.70942	4	2025-05-31 08:43:51.744985	
6738	customer 	9351782897	2025-07-28 10:00:00	Needs Followup	Call cut	2025-04-26 12:31:26.34221	4	2025-05-31 08:43:51.744985	
6739	customer 	9462587383	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-04-26 12:33:08.949776	4	2025-05-31 08:43:51.744985	
6745	Cx1149	9529001541	2025-07-28 10:00:00	Needs Followup	Car service 	2025-04-28 04:43:35.110318	4	2025-05-31 08:43:51.744985	
5486	Dhirendra 	9829680079	2025-07-09 10:00:00	Needs Followup		2025-04-02 12:08:27.618333	6	2025-05-31 08:42:34.144665	
6704	gaadimech 	9785004277	2025-08-29 18:30:00	Did Not Pick Up	Xuv 300 3899\r\nNot required 	2025-04-26 05:29:53.658763	6	2025-05-08 08:39:52.727286	
1720	Cx127	6350338813	2025-07-30 18:30:00	Confirmed	 Not picking twice 	2024-12-13 04:40:11	9	2025-07-06 06:46:07.952716	\N
6709	gaadimech 	7023211211	2025-07-30 18:30:00	Did Not Pick Up	Call cut \r\nNot interested 	2025-04-26 05:32:17.214741	6	2025-05-07 09:07:31.5349	
6988	Cc1173	8104605528	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-08 05:31:55.613954	6	2025-05-31 08:43:19.077196	
6754	gaadimech 	9828645205	2025-07-28 10:00:00	Needs Followup	WAGNOR 2399\r\nNot interested 	2025-04-28 05:02:53.571709	4	2025-05-31 08:43:51.744985	
6756	gaadimech 	7976926959	2025-07-28 10:00:00	Needs Followup	Grand vitara 2099 panel charge\r\nNot interested 	2025-04-28 05:06:59.816917	4	2025-05-31 08:43:51.744985	
7049	Cx1175	8437853783	2025-07-20 10:00:00	Needs Followup	Out of network 	2025-05-09 04:43:52.689598	6	2025-05-31 08:43:19.077196	
5488	Satish chand	9829678052	2025-07-09 10:00:00	Needs Followup	Not interested 	2025-04-02 12:19:00.891809	6	2025-05-31 08:42:34.144665	
6769	gaadimech	9829048232	2025-07-25 18:30:00	Feedback	Nexon done sharp motors	2025-04-28 05:58:14.002184	6	2025-05-08 12:18:50.369036	RJ45CE9807
6761	gaadimech	7792930003	2025-07-22 10:00:00	Needs Followup	Not pick 	2025-04-28 05:23:07.928168	4	2025-05-31 08:43:27.624295	
6751	gaadimech 	7297860941	2025-07-14 10:00:00	Needs Followup	Ertiga nd dzire	2025-04-28 05:00:35.013801	6	2025-05-31 08:42:54.38585	
6759	gaadimech 	7791072133	2025-07-28 10:00:00	Needs Followup	Swift 2799 \r\nAbhi requirement nahi h self call kar lenge	2025-04-28 05:12:26.794456	4	2025-05-31 08:43:51.744985	
6778	gaadimech 	9166255811	2025-07-28 10:00:00	Needs Followup	Polo 3699\r\nCall cut	2025-04-28 09:27:53.371423	4	2025-05-31 08:43:51.744985	
5596	Deep 	9829639203	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:03:27.093437	4	2025-05-31 08:42:38.503765	
6797	Cx1152	8005615447	2025-07-18 10:00:00	Needs Followup	Tata punch clutch work 	2025-04-29 10:18:19.623084	6	2025-05-31 08:43:10.854377	
5598	Ram Kishore 	9829636841	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:04:42.514759	4	2025-05-31 08:42:38.503765	
6786	gaadimech 	9828583593	2025-07-10 18:30:00	Did Not Pick Up	Not pick verna 3999\r\nOut of town	2025-04-29 05:35:03.001557	6	2025-05-28 11:37:06.35813	
6784	gaadimech 	9001170111	2025-07-28 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-04-29 05:22:34.142937	4	2025-05-31 08:43:51.744985	
6775	gaadimech 	6376768330	2025-07-22 10:00:00	Needs Followup	Ameo 999 ac service 	2025-04-28 09:23:19.300906	4	2025-05-31 08:43:27.624295	
7190	Customer 	9887575000	2025-07-23 10:00:00	Needs Followup		2025-05-14 12:15:49.940166	6	2025-05-31 08:43:31.574711	
7191	Customer 	9810952253	2025-07-23 10:00:00	Needs Followup		2025-05-14 12:16:20.332685	6	2025-05-31 08:43:31.574711	
5599	Bhanu	9829636137	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:05:12.040551	4	2025-05-31 08:42:38.503765	
6789	gaadimech 	8949725438	2025-07-28 10:00:00	Needs Followup	Alto 2399\r\nTill time plan postponed requirement hui to self call karenge	2025-04-29 06:16:30.289897	4	2025-05-31 08:43:51.744985	
6799	gaadimech 	9079807228	2025-07-28 10:00:00	Needs Followup	Not pick \r\nCall cut	2025-04-30 05:02:00.368461	4	2025-05-31 08:43:51.744985	
7195	gaadimech 	9359346047	2025-07-28 10:00:00	Needs Followup	Fortuner 6999\r\nBaleno 2799	2025-05-15 05:01:14.544604	6	2025-05-31 08:43:51.744985	
5907	karishna sharma gaadimech	9151391514	2025-07-23 18:30:00	Feedback	Alto K10 ac check\r\n1830 total payment\r\nAjmer road \r\nFeedback\r\nSatisfied customer 	2025-04-14 06:24:58.242359	6	2025-06-28 07:28:47.640644	RJ14WC5129
6753	gaadimech 	9971445552	2025-07-25 10:00:00	Needs Followup	Amaze 3199\r\nTill time not required 	2025-04-28 05:02:25.521309	4	2025-05-31 08:43:39.880052	
6825	Kushal 	6367875806	2025-07-15 18:30:00	Confirmed	Not interested 	2025-05-01 08:48:28.108279	9	2025-07-01 08:36:28.476226	
7739	Cx3086	9571421835	2025-07-04 18:30:00	Needs Followup	Car service \r\nCall cut 	2025-06-29 05:23:20.798857	4	2025-07-03 13:28:11.495849	
6771	gaadimech 	9549651535	2025-07-18 18:30:00	Feedback	Punch service \r\n3199 total payment received \r\nFeedback 	2025-04-28 06:40:18.524972	6	2025-05-31 09:16:31.723459	RJ45CT3117
6768	gaadimech 	8290704311	2025-07-11 18:30:00	Feedback	Kuv 100 \r\nTotal payment 3639	2025-04-28 05:47:41.998694	6	2025-05-31 09:17:35.38151	RJ14UF4322
6764	gaadimech 	9587437888	2025-07-25 10:00:00	Needs Followup	Alcazar 4999 	2025-04-28 05:29:39.274488	4	2025-05-31 08:43:39.880052	
6762	gaadimech 	9982814000	2025-07-08 18:30:00	Feedback	Beat service done \r\n3999 total payment \r\nFeedback 	2025-04-28 05:25:35.271183	6	2025-05-31 09:18:26.00948	RJ14CQ2012
6766	gaadimech 	9887726000	2025-07-25 10:00:00	Needs Followup	Ciaz 2199\r\nxuv 2500\r\nCall cut	2025-04-28 05:35:00.790239	4	2025-05-31 08:43:39.880052	
6790	Shahid Khan gaadimech 	7688979602	2025-07-17 10:00:00	Needs Followup	Honda civic 22000	2025-04-29 08:49:46.267505	6	2025-05-31 08:43:06.869056	
6619	Cx1136	7340376211	2025-07-20 10:00:00	Needs Followup	Ertiga service 3399\r\n	2025-04-23 08:03:02.917623	4	2025-05-31 08:43:19.077196	
5600	Nirmal 	9829630530	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:05:42.464824	4	2025-05-31 08:42:38.503765	
5562	apporva bhargav gaadimech	7073744888	2025-07-21 10:00:00	Needs Followup	Dzire dent paint  drycleaning rubbing polishing wind shield 	2025-04-07 05:51:40.6931	6	2025-05-31 08:43:23.449024	
6808	gaadimech 	9352433109	2025-09-26 18:30:00	Did Not Pick Up	Not pick \r\nCall cut\r\nCelerio service done 	2025-04-30 06:11:03.573459	6	2025-05-03 06:16:39.40529	
7125	Honda Amaze 3199	9929608575	2025-07-26 10:00:00	Needs Followup	3199 service 	2025-05-13 05:03:57.302975	4	2025-05-31 08:43:43.903509	
6822	gaadimech 	8696924320	2025-07-25 18:30:00	Did Not Pick Up	Wagnor 2599	2025-05-01 05:35:12.883958	6	2025-05-22 11:48:59.12584	
6831	Customer 	9829012571	2025-07-20 10:00:00	Needs Followup		2025-05-01 11:58:26.30986	4	2025-05-31 08:43:19.077196	
6812	Cx1156	9772502517	2025-07-18 10:00:00	Needs Followup	Alto service 	2025-04-30 08:31:32.418173	6	2025-05-31 08:43:10.854377	
6809	gaadimech	9511544345	2025-07-28 10:00:00	Needs Followup	Vento 1999\r\nCall cut	2025-04-30 06:23:56.065623	4	2025-05-31 08:43:51.744985	
6833	Customer 	9828120621	2025-07-20 10:00:00	Needs Followup		2025-05-01 11:59:44.613569	4	2025-05-31 08:43:19.077196	
6847	gaadimech 	9829117439	2025-07-22 10:00:00	Needs Followup	Duster 4899	2025-05-02 09:25:24.843986	4	2025-05-31 08:43:27.624295	
5602	Prem 	9829628448	2025-07-10 10:00:00	Needs Followup	Swift 	2025-04-07 12:07:02.301102	4	2025-05-31 08:42:38.503765	
6852	gaadimech 	7732980139	2025-07-22 10:00:00	Needs Followup	Bolero 4599	2025-05-02 10:01:08.349393	4	2025-05-31 08:43:27.624295	
5603	Tarun 	9829627585	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-07 12:07:37.182935	4	2025-05-31 08:42:38.503765	
6837	Cx1156	9414228923	2025-07-19 10:00:00	Needs Followup	Call cut	2025-05-02 07:05:40.230408	4	2025-05-31 08:43:14.897002	
6849	gaadimech 	9214548491	2025-10-30 18:30:00	Did Not Pick Up	Eon 2299	2025-05-02 09:56:08.995526	6	2025-05-28 07:14:25.477485	
5641	Cx642	9414227748	2025-07-27 10:00:00	Needs Followup	Swift Dzire 2899\r\n	2025-04-08 05:14:39.40533	6	2025-05-31 08:43:47.842094	
6829	Customer 	9829188920	2025-07-23 10:00:00	Needs Followup		2025-05-01 11:57:43.16889	6	2025-05-31 08:43:31.574711	
6810	Cx1152	7016798071	2025-07-28 10:00:00	Needs Followup	Car service 	2025-04-30 07:36:08.196738	4	2025-05-31 08:43:51.744985	
6817	gaadimech 	9461341361	2025-07-30 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-05-01 05:02:02.58647	6	2025-05-04 05:42:50.900318	
6830	Customer 	9829188920	2025-07-22 10:00:00	Needs Followup		2025-05-01 11:57:44.081202	6	2025-05-31 08:43:27.624295	
6832	Customer 	9828010444	2025-07-19 10:00:00	Needs Followup		2025-05-01 11:59:13.541288	6	2025-05-31 08:43:14.897002	
6816	gaadimech 	7426810524	2025-07-28 10:00:00	Needs Followup	Not pick	2025-05-01 04:48:10.869324	4	2025-05-31 08:43:51.744985	
6835	Customer 	9314285086	2025-07-22 10:00:00	Needs Followup		2025-05-01 12:04:27.74528	6	2025-05-31 08:43:27.624295	
6806	gaadimech 	7073742735	2025-07-25 10:00:00	Needs Followup	BREZZA dent paint 2200	2025-04-30 06:07:54.511158	4	2025-05-31 08:43:39.880052	
6807	gaadimech 	9549141121	2025-07-25 10:00:00	Needs Followup	Voice mail \r\nNot interested 	2025-04-30 06:09:28.558398	4	2025-05-31 08:43:39.880052	
6815	gaadimech 	9549306798	2025-07-25 10:00:00	Needs Followup	Kwid not pick 	2025-05-01 04:44:05.002169	4	2025-05-31 08:43:39.880052	
6850	gaadimech 	9828263132	2025-10-24 18:30:00	Did Not Pick Up	Swift 2799\r\nNot pick \r\nCall cut	2025-05-02 09:57:08.305386	6	2025-05-20 09:59:56.856977	
6828	Customer 	9001395955	2025-07-25 10:00:00	Needs Followup		2025-05-01 11:57:11.913125	4	2025-05-31 08:43:39.880052	
6851	gaadimech 	9079837203	2025-08-14 18:30:00	Open	Eon 2299 sharp motors 	2025-05-02 10:00:35.880987	6	2025-06-28 07:17:23.898122	RJ14CT4213
6848	gaadimech	9828688182	2025-08-29 18:30:00	Feedback	Grand i10 service done total payment 8200\r\nFeedback 	2025-05-02 09:26:16.673937	6	2025-06-28 07:17:41.400619	RJ14CV9543
6819	gaadimech 	9461109880	2025-07-28 10:00:00	Needs Followup	Beat 2599	2025-05-01 05:07:23.442142	4	2025-05-31 08:43:51.744985	
6823	Gaadimech	9414392799	2025-07-28 10:00:00	Needs Followup	Honda City 3399	2025-05-01 07:21:20.323701	4	2025-05-31 08:43:51.744985	
6827	Customer 	9828155724	2025-07-28 10:00:00	Needs Followup		2025-05-01 11:56:31.242555	4	2025-05-31 08:43:51.744985	
6859	Cx1161	9829576691	2025-07-20 10:00:00	Needs Followup	Running board Dent paint 	2025-05-03 05:39:07.210762	4	2025-05-31 08:43:19.077196	
6881	Customer 	9829697077	2025-07-22 10:00:00	Needs Followup		2025-05-03 11:52:53.117847	6	2025-05-31 08:43:27.624295	
7157	gaadimech 	9588878010	2025-07-22 10:00:00	Needs Followup	Baleno break pad	2025-05-14 04:55:47.779442	6	2025-05-31 08:43:27.624295	
6862	Cx1163	9549999961	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-03 05:41:00.938715	4	2025-05-31 08:43:19.077196	
6863	Etios 3399	8824023094	2025-07-20 10:00:00	Needs Followup	Etios service 3399	2025-05-03 05:41:40.327969	6	2025-05-31 08:43:19.077196	
6868	Cx1164	8619844632	2025-07-20 10:00:00	Needs Followup	Brio service 2599\r\nNo answer 	2025-05-03 05:59:03.338398	6	2025-05-31 08:43:19.077196	
6884	Customer 	8003159159	2025-07-20 10:00:00	Needs Followup		2025-05-03 11:54:26.772144	6	2025-05-31 08:43:19.077196	
6867	Cx1163	8696927112	2025-07-28 10:00:00	Needs Followup	i10 \r\nDent paint \r\nOnly company mai free hogi	2025-05-03 05:57:41.703338	4	2025-05-31 08:43:51.744985	
6889	Customer 	9829015540	2025-07-20 10:00:00	Needs Followup		2025-05-03 12:24:33.039764	6	2025-05-31 08:43:19.077196	
6869	gaadimech 	9001508816	2025-07-25 10:00:00	Needs Followup	Switch off	2025-05-03 08:29:04.14509	4	2025-05-31 08:43:39.880052	
6880	Customer 	9829157005	2025-07-19 10:00:00	Needs Followup		2025-05-03 11:51:17.323026	4	2025-05-31 08:43:14.897002	
6899	Cx1167	7014946451	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-04 06:23:02.30371	6	2025-05-31 08:43:19.077196	
6910	Cx1169	9929270000	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-05 08:14:05.007664	6	2025-05-31 08:43:19.077196	
6911	Cx1168	6377141044	2025-07-20 10:00:00	Needs Followup	Figo service 3299	2025-05-05 08:15:23.81906	6	2025-05-31 08:43:19.077196	
6912	Baleno 2799	9829004089	2025-07-20 10:00:00	Needs Followup	Car service 	2025-05-05 08:17:12.175844	6	2025-05-31 08:43:19.077196	
6918	Cx1169	8384940609	2025-07-20 10:00:00	Needs Followup	Alto new bumper aur paint \r\n	2025-05-06 06:29:44.960944	6	2025-05-31 08:43:19.077196	
6919	Cx1169	9509806111	2025-07-20 10:00:00	Needs Followup	Dent paint 	2025-05-06 06:34:45.878996	6	2025-05-31 08:43:19.077196	
6920	Wr 2599	9414751546	2025-07-20 10:00:00	Needs Followup	Wr service 	2025-05-06 06:39:38.276923	6	2025-05-31 08:43:19.077196	
6895	Customer 	9829777235	2025-07-23 10:00:00	Needs Followup		2025-05-03 12:27:50.599201	4	2025-05-31 08:43:31.574711	
6887	Customer 	9829065999	2025-07-23 10:00:00	Needs Followup		2025-05-03 12:23:09.570717	4	2025-05-31 08:43:31.574711	
6875	Customer 	9829050548	2025-07-23 10:00:00	Needs Followup		2025-05-03 11:38:47.258861	4	2025-05-31 08:43:31.574711	
6876	Customer 	9414387071	2025-07-23 10:00:00	Needs Followup		2025-05-03 11:48:00.281983	6	2025-05-31 08:43:31.574711	
2553	Cx1130 	9001159595	2025-07-17 18:30:00	Confirmed	Not picking 	2025-01-01 08:53:47.57208	9	2025-07-02 04:10:29.564417	\N
6913	gaadimech 	9828440229	2025-07-25 10:00:00	Needs Followup	Not pick 	2025-05-05 11:44:05.716159	4	2025-05-31 08:43:39.880052	
6877	Customer 	9828068493	2025-07-23 10:00:00	Needs Followup		2025-05-03 11:49:43.278343	6	2025-05-31 08:43:31.574711	
6871	gaadimech 	9950234777	2025-08-22 18:30:00	Needs Followup	Xcent 2799\r\nNot requirement company me service krwa li	2025-05-03 08:30:00.280676	6	2025-05-30 12:36:39.566754	
6890	Customer 	9829050403	2025-07-23 10:00:00	Needs Followup		2025-05-03 12:24:55.701648	6	2025-05-31 08:43:31.574711	
6898	Cc1167	9833703931	2025-07-28 10:00:00	Needs Followup	Dent paint \r\nErtiga	2025-05-04 04:59:11.213136	4	2025-05-31 08:43:51.744985	
6906	gaadimech 	9982694918	2025-07-30 18:30:00	Did Not Pick Up	Busy call u later \r\nNot interested 	2025-05-05 06:56:05.166024	6	2025-05-07 07:50:13.698815	
6864	Cx1164	9672012341	2025-07-25 10:00:00	Needs Followup	Etios liva Dent paint 	2025-05-03 05:42:56.495709	6	2025-05-31 08:43:39.880052	
6902	Cx1164	9654575851	2025-07-25 10:00:00	Needs Followup	Dzire \r\n	2025-05-04 06:50:57.923009	6	2025-05-31 08:43:39.880052	
6915	Cx1163	9887224786	2025-07-25 10:00:00	Needs Followup	Kwid  service 2899	2025-05-06 05:23:45.091581	6	2025-05-31 08:43:39.880052	
6921	Cx 1171	9913039720	2025-07-25 10:00:00	Needs Followup	Car service 	2025-05-06 06:48:54.989973	6	2025-05-31 08:43:39.880052	
6883	Customer 	9314512013	2025-07-19 10:00:00	Needs Followup		2025-05-03 11:54:04.299163	4	2025-05-31 08:43:14.897002	
6900	Cx1164	7014946451	2025-07-28 10:00:00	Needs Followup	Car service \r\nVoice call 	2025-05-04 06:45:53.009573	4	2025-05-31 08:43:51.744985	
6901	Cx1164	9654575851	2025-07-28 10:00:00	Needs Followup	Dzire \r\nNo answer 	2025-05-04 06:50:56.964927	4	2025-05-31 08:43:51.744985	
6882	Customer 	9829010198	2025-07-26 10:00:00	Needs Followup	Fortuner \r\nBaleno 	2025-05-03 11:53:36.888744	6	2025-05-31 08:43:43.903509	
6917	Cx1167	8005668660	2025-07-28 10:00:00	Needs Followup	WhatsApp call 	2025-05-06 05:56:19.542419	4	2025-05-31 08:43:51.744985	
6922	Cx1171	9413375386	2025-07-28 10:00:00	Needs Followup	Triber dent paint ok	2025-05-06 06:58:19.921001	4	2025-05-31 08:43:51.744985	
7158	gaadimech 	8423933539	2025-07-28 10:00:00	Needs Followup	Not pick	2025-05-14 05:01:32.353215	6	2025-05-31 08:43:51.744985	
6926	Cc1174	9828440229	2025-07-20 10:00:00	Needs Followup	G-i10 service 2999	2025-05-06 07:09:27.949508	6	2025-05-31 08:43:19.077196	
6933	Cx1164	8946991155	2025-07-20 10:00:00	Needs Followup	Alto Dent paint \r\nNo answer 	2025-05-07 05:39:58.857174	6	2025-05-31 08:43:19.077196	
5604	Sumer 	9829627570	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-07 12:08:09.129798	4	2025-05-31 08:42:38.503765	
6937	Cx1172	7014106043	2025-07-20 10:00:00	Needs Followup	In coming nahi onle whatapp message 	2025-05-07 05:45:02.819751	6	2025-05-31 08:43:19.077196	
6951	Customer 	9829027282	2025-07-20 10:00:00	Needs Followup	Ciaz 3199	2025-05-07 11:00:28.270723	6	2025-05-31 08:43:19.077196	
6962	Customer 	9829069569	2025-07-20 10:00:00	Needs Followup		2025-05-07 11:47:41.579318	6	2025-05-31 08:43:19.077196	
6966	Customer 	9322532079	2025-07-20 10:00:00	Needs Followup		2025-05-07 11:52:03.956854	6	2025-05-31 08:43:19.077196	
5062	Ravi gaadi mech 	9829121222	2025-09-10 18:30:00	Feedback	Honda City 3399  sharp motors\r\nTOTAL PAYMENT - 4400 ( cash) \r\nFEEDBACK\r\n27/03/2023 service achi lagi \r\n 	2025-03-26 05:09:05.690483	6	2025-06-28 10:08:47.901952	RJ14CX4336
6974	Customer 	9829030903	2025-07-20 10:00:00	Needs Followup		2025-05-07 12:09:10.633252	6	2025-05-31 08:43:19.077196	
6942	Customer 	9829060066	2025-07-21 10:00:00	Needs Followup		2025-05-07 10:50:19.181715	6	2025-05-31 08:43:23.449024	
6943	Customer 	9829068777	2025-07-21 10:00:00	Needs Followup		2025-05-07 10:50:57.993789	6	2025-05-31 08:43:23.449024	
6952	Customer 	9829062997	2025-07-21 10:00:00	Needs Followup		2025-05-07 11:00:51.663729	6	2025-05-31 08:43:23.449024	
6963	Customer 	9783023939	2025-07-21 10:00:00	Needs Followup	Scross 3199	2025-05-07 11:49:06.621868	6	2025-05-31 08:43:23.449024	
6964	Customer 	9314274809	2025-07-21 10:00:00	Needs Followup		2025-05-07 11:49:51.087572	6	2025-05-31 08:43:23.449024	
6969	Customer 	9314292199	2025-07-22 10:00:00	Needs Followup		2025-05-07 11:53:28.619785	4	2025-05-31 08:43:27.624295	
6976	Customer 	9829061565	2025-07-22 10:00:00	Needs Followup		2025-05-07 12:11:54.93819	4	2025-05-31 08:43:27.624295	
6977	Customer 	9829061565	2025-07-22 10:00:00	Needs Followup		2025-05-07 12:11:57.181155	4	2025-05-31 08:43:27.624295	
6978	Customer 	9982474303	2025-07-22 10:00:00	Needs Followup		2025-05-07 12:12:17.813025	4	2025-05-31 08:43:27.624295	
5607	Vandana 	9829620272	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:09:45.691419	4	2025-05-31 08:42:38.503765	
6939	Customer 	9829047000	2025-07-19 10:00:00	Needs Followup	Honda City 3399	2025-05-07 10:49:08.259798	4	2025-05-31 08:43:14.897002	
6941	Customer 	9829060343	2025-07-25 10:00:00	Needs Followup		2025-05-07 10:49:52.728872	4	2025-05-31 08:43:39.880052	
5608	Vijay Kumar 	9829620272	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:10:14.45333	4	2025-05-31 08:42:38.503765	
6936	Cx1171	7976668572	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-07 05:42:11.1467	4	2025-05-31 08:43:51.744985	
7159	gaadimech	9314515012	2025-07-22 10:00:00	Needs Followup	Not pick	2025-05-14 05:09:50.17513	6	2025-05-31 08:43:27.624295	
7160	gaadimech 	8005519690	2025-07-22 10:00:00	Needs Followup	I20 2999	2025-05-14 05:21:24.196932	6	2025-05-31 08:43:27.624295	
6916	Alto bumper paint 1700	8384940609	2025-07-25 10:00:00	Needs Followup	Alto bumper paint 1700\r\n	2025-05-06 05:51:48.9812	6	2025-05-31 08:43:39.880052	
6935	Cx1170	6378490855	2025-07-25 10:00:00	Needs Followup	Car service 	2025-05-07 05:41:27.16599	6	2025-05-31 08:43:39.880052	
6955	Customer 	9950696066	2025-07-26 10:00:00	Needs Followup		2025-05-07 11:37:53.223623	6	2025-05-31 08:43:43.903509	
6945	Customer 	9352666665	2025-07-23 10:00:00	Needs Followup	I 10 2299	2025-05-07 10:52:10.758644	4	2025-05-31 08:43:31.574711	
6959	Customer 	9829056610	2025-07-23 10:00:00	Needs Followup		2025-05-07 11:40:52.734503	4	2025-05-31 08:43:31.574711	
6940	Customer 	9829047000	2025-07-23 10:00:00	Needs Followup		2025-05-07 10:49:30.757289	4	2025-05-31 08:43:31.574711	
6949	Customer 	9829065718	2025-07-23 10:00:00	Needs Followup		2025-05-07 10:58:36.412445	4	2025-05-31 08:43:31.574711	
7162	gaadimech 	7217864028	2025-07-28 10:00:00	Needs Followup	Not pick ac checkup 	2025-05-14 05:32:38.39745	6	2025-05-31 08:43:51.744985	
5609	Rahul Sharma 	9829620202	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:10:58.304254	4	2025-05-31 08:42:38.503765	
6749	Cx1151	9983011140	2025-07-28 10:00:00	Needs Followup	Car service 	2025-04-28 04:47:25.060868	4	2025-05-31 08:43:51.744985	
6950	Customer 	9829227222	2025-07-23 10:00:00	Needs Followup		2025-05-07 10:59:34.601736	4	2025-05-31 08:43:31.574711	
6928	gaadimech 	8003111001	2025-07-28 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-05-07 05:12:39.386739	4	2025-05-31 08:43:51.744985	
7164	gaadimech 	8385843081	2025-07-28 10:00:00	Needs Followup	Call cut\r\nEco sport washing	2025-05-14 05:37:09.882618	6	2025-05-31 08:43:51.744985	
6971	Customer 	9413114838	2025-07-23 10:00:00	Needs Followup		2025-05-07 12:06:33.842925	4	2025-05-31 08:43:31.574711	
6946	Customer 	9950158355	2025-07-23 10:00:00	Needs Followup	Grand I10 2699	2025-05-07 10:53:12.193424	6	2025-05-31 08:43:31.574711	
6956	Customer 	9829060558	2025-07-23 10:00:00	Needs Followup		2025-05-07 11:39:04.68114	6	2025-05-31 08:43:31.574711	
6944	Customer 	9829014495	2025-07-23 10:00:00	Needs Followup		2025-05-07 10:51:35.653259	6	2025-05-31 08:43:31.574711	
6965	Customer 	9829770000	2025-07-23 10:00:00	Needs Followup		2025-05-07 11:51:31.456474	6	2025-05-31 08:43:31.574711	
6967	Customer 	9772077774	2025-07-23 10:00:00	Needs Followup		2025-05-07 11:52:33.971802	6	2025-05-31 08:43:31.574711	
6968	Customer 	9829054121	2025-07-23 10:00:00	Needs Followup		2025-05-07 11:52:58.045523	6	2025-05-31 08:43:31.574711	
6954	Customer 	9828076282	2025-07-19 10:00:00	Needs Followup		2025-05-07 11:03:58.101627	4	2025-05-31 08:43:14.897002	
5610	Ram gopal 	9829620153	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:11:28.422479	4	2025-05-31 08:42:38.503765	
3338	Cx231	9829031031	2025-07-19 18:30:00	Confirmed	Not picking 	2025-01-23 08:37:13.385523	9	2025-07-03 05:22:09.308944	\N
5611	Deen dayal	9829619897	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:11:58.323625	4	2025-05-31 08:42:38.503765	
7215	Customer 	9960103974	2025-07-23 10:00:00	Needs Followup		2025-05-15 11:21:30.124771	4	2025-05-31 08:43:31.574711	
7225	Customer 	8058075330	2025-07-23 10:00:00	Needs Followup		2025-05-15 11:53:53.48519	4	2025-05-31 08:43:31.574711	
7212	Customer 	9509008975	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:20:00.097817	4	2025-05-31 08:43:27.624295	
7229	Customer 	9462140626	2025-07-23 10:00:00	Needs Followup		2025-05-15 11:57:33.19524	4	2025-05-31 08:43:31.574711	
7213	Customer 	9509008975	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:20:43.504167	4	2025-05-31 08:43:27.624295	
7214	Customer 	9490944433	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:21:04.871618	4	2025-05-31 08:43:27.624295	
7219	Customer 	9772201687	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:23:05.77359	4	2025-05-31 08:43:27.624295	
7222	Customer 	7877366612	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:29:00.222547	4	2025-05-31 08:43:27.624295	
7223	Customer 	9821405840	2025-07-22 10:00:00	Needs Followup		2025-05-15 11:29:20.187268	4	2025-05-31 08:43:27.624295	
7235	Customer 	9660975727	2025-07-23 10:00:00	Needs Followup	Seltos 3599	2025-05-15 12:04:20.153002	4	2025-05-31 08:43:31.574711	
7239	Customer 	9828076488	2025-07-23 10:00:00	Needs Followup	Eco sports \r\nZen	2025-05-15 12:15:28.623241	4	2025-05-31 08:43:31.574711	
7248	Customer 	9828050432	2025-07-23 10:00:00	Needs Followup	I20	2025-05-15 12:21:10.129783	4	2025-05-31 08:43:31.574711	
7249	Customer 	9314301982	2025-07-23 10:00:00	Needs Followup	Honda City 3399	2025-05-15 12:21:52.297397	4	2025-05-31 08:43:31.574711	
7231	Customer 	7726812598	2025-07-23 10:00:00	Needs Followup	Tata Tiago 3199	2025-05-15 11:58:46.17889	4	2025-05-31 08:43:31.574711	
7218	Customer 	9887982307	2025-07-23 10:00:00	Needs Followup		2025-05-15 11:22:45.253397	6	2025-05-31 08:43:31.574711	
7216	Customer 	9468801204	2025-07-25 10:00:00	Needs Followup		2025-05-15 11:22:00.631503	4	2025-05-31 08:43:39.880052	
7217	Customer 	9717946271	2025-07-25 10:00:00	Needs Followup		2025-05-15 11:22:24.009508	4	2025-05-31 08:43:39.880052	
7221	Customer 	9829124094	2025-07-25 10:00:00	Needs Followup		2025-05-15 11:27:27.378831	4	2025-05-31 08:43:39.880052	
7208	Customer 	8894990698	2025-07-25 10:00:00	Needs Followup		2025-05-15 11:11:24.809342	4	2025-05-31 08:43:39.880052	
7119	Cx1198	8107316729	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 04:42:12.679521	4	2025-05-31 08:43:43.903509	
7154	Cx2009	7357047601	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-13 07:10:19.499307	4	2025-05-31 08:43:43.903509	
6112	gaadimech 	9111459000	2025-07-27 10:00:00	Needs Followup	Baleno 2799 4000 to 5000 km due h	2025-04-16 11:55:22.946506	6	2025-05-31 08:43:47.842094	
6390	Cx1014	8287108276	2025-07-27 10:00:00	Needs Followup	Car service ke liye 	2025-04-21 04:37:25.310844	6	2025-05-31 08:43:47.842094	
7059	gaadimech 	7206666494	2025-07-28 10:00:00	Needs Followup	Verna service nd dent paint	2025-05-10 05:10:40.20697	4	2025-05-31 08:43:51.744985	
7134	Cx2004	9205515564	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-13 06:56:08.524676	6	2025-05-31 08:43:51.744985	
7146	 Cx2005	9205515564	2025-07-28 10:00:00	Needs Followup	Dent paint 	2025-05-13 07:03:57.843906	6	2025-05-31 08:43:51.744985	
3361	Creta 	9929450333	2025-07-30 18:30:00	Confirmed	Not picking twice 	2025-01-24 08:53:51.25089	9	2025-07-05 08:04:20.497006	\N
7254	Cx2019	9530405067	2025-08-07 18:30:00	Needs Followup	Not interested 	2025-05-17 05:09:57.142878	9	2025-07-05 08:06:03.738094	
222	Ranjeet 	8963026779	2025-08-29 18:30:00	Needs Followup	Dzire break show sarvice 1450 + 500 +2999 total amount 4949/ madam abhi m tur pr hu jis week meri gadi tur pr nhi jayegi m gadi de dunga\r\nNot required 	2024-11-25 06:55:01	6	2025-05-16 12:06:36.389225	
4735	.	7014923491	2025-07-27 10:00:00	Needs Followup	Call cut\r\nNot connect 	2025-03-13 11:34:16.95702	4	2025-05-31 08:43:47.842094	
6733	customer 	9413333621	2025-07-28 10:00:00	Needs Followup	Wrv 3399\r\n800 2399\r\nCall cit	2025-04-26 12:17:11.426449	4	2025-05-31 08:43:51.744985	
7263	gaadimech 	9782113674	2025-07-23 10:00:00	Needs Followup	Alto drycleaning 	2025-05-17 07:57:30.940385	4	2025-05-31 08:43:31.574711	
7253	gaadimech 	6378110539	2025-07-28 10:00:00	Needs Followup	Verna 3999	2025-05-17 05:03:02.074129	6	2025-05-31 08:43:51.744985	
7266	gaadimech 	8949255408	2025-07-28 10:00:00	Needs Followup	Fronx 2999	2025-05-17 10:53:02.811119	6	2025-05-31 08:43:51.744985	
7275	gaadimech 	9530027163	2025-07-28 10:00:00	Needs Followup	Nit pick 	2025-05-18 04:30:33.187242	6	2025-05-31 08:43:51.744985	
4615	gaadimech 	8303463863	2025-07-24 10:00:00	Needs Followup	Mene koi inquiry nhi ki \r\nNot pick	2025-03-09 04:46:44.779531	4	2025-05-31 08:43:35.995616	
7276	gaadimech 	7300044545	2025-07-28 10:00:00	Needs Followup	Call u later 	2025-05-18 04:32:15.482012	6	2025-05-31 08:43:51.744985	
7284	gaadimech 	8104216363	2025-07-28 10:00:00	Needs Followup	Not pick 	2025-05-18 05:54:47.031201	6	2025-05-31 08:43:51.744985	
7289	Cx2020	7426872382	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-19 05:25:04.484865	6	2025-05-31 08:43:51.744985	
7291	Cx2025	8209476610	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-19 05:27:51.492414	6	2025-05-31 08:43:51.744985	
7293	Cx2027	9928820000	2025-07-28 10:00:00	Needs Followup	Creta dent paint 	2025-05-19 05:31:08.388146	6	2025-05-31 08:43:51.744985	
7179	Cx2015	8003477726	2025-07-26 10:00:00	Needs Followup	In coming nahi hai \r\nVoice call 	2025-05-14 07:19:49.555487	4	2025-05-31 08:43:43.903509	
7255	Cx2020	9352479941	2025-07-26 10:00:00	Needs Followup	Dent paint \r\n	2025-05-17 05:10:38.310051	4	2025-05-31 08:43:43.903509	
7256	Cx2020	9352479941	2025-07-26 10:00:00	Needs Followup	Dent paint \r\n	2025-05-17 05:10:46.828175	4	2025-05-31 08:43:43.903509	
7257	Cx2020	9352479941	2025-07-26 10:00:00	Needs Followup	Dent paint \r\n	2025-05-17 05:10:51.16614	4	2025-05-31 08:43:43.903509	
7258	Cx2022	6377839307	2025-07-26 10:00:00	Needs Followup	Sonnet dent paint \r\nCall cut \r\n	2025-05-17 05:12:00.15113	4	2025-05-31 08:43:43.903509	
7278	Cx2026	9314494819	2025-07-26 10:00:00	Needs Followup	Wr \r\nAc gas 	2025-05-18 05:13:15.173756	4	2025-05-31 08:43:43.903509	
7281	Cx2014	9509259067	2025-07-26 10:00:00	Needs Followup	Brezza dent paint 	2025-05-18 05:17:27.543768	4	2025-05-31 08:43:43.903509	
7287	Cx2019	9785781611	2025-07-26 10:00:00	Needs Followup	i20\r\nDrycleaning 	2025-05-19 05:24:16.510146	4	2025-05-31 08:43:43.903509	
7290	Cx2021	9660259204	2025-07-26 10:00:00	Needs Followup	Car service aur ac	2025-05-19 05:26:45.463637	4	2025-05-31 08:43:43.903509	
7292	Cx2026	9887213378	2025-07-26 10:00:00	Needs Followup	Car service 	2025-05-19 05:30:20.641132	4	2025-05-31 08:43:43.903509	
3349	Customer 	9782273342	2025-08-21 18:30:00	Feedback	\r\nNot pick	2025-01-24 04:17:20.62172	6	2025-06-30 10:20:15.827946	
7342	gaadimech 	8000265898	2025-08-29 18:30:00	Needs Followup	Figo 2799\r\nNot interested 	2025-05-21 05:08:16.362446	6	2025-05-22 07:05:58.391838	
5612	Nakul	9829619008	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:12:27.191313	4	2025-05-31 08:42:38.503765	
5614	Dinesh 	9829610599	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:13:32.030014	4	2025-05-31 08:42:38.503765	
6813	gaadimech 	9414321335	2025-07-25 10:00:00	Needs Followup	Wagnor 2399\r\nOut of jaipur self call karenge	2025-05-01 04:28:32.136663	4	2025-05-31 08:43:39.880052	
7300	Cx2027	9887151396	2025-07-28 10:00:00	Needs Followup	Company mein karva le	2025-05-19 05:33:24.867002	6	2025-05-31 08:43:51.744985	
7299	Cx2027	9413707359	2025-07-26 10:00:00	Needs Followup	Wr 2599	2025-05-19 05:32:26.467219	4	2025-05-31 08:43:43.903509	
7309	Cx2027	9664042926	2025-07-28 10:00:00	Needs Followup	Dent paint 	2025-05-19 09:05:35.2048	6	2025-05-31 08:43:51.744985	
7311	Cx2027	9891202825	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-19 09:08:25.281766	6	2025-05-31 08:43:51.744985	
7313	Cx2029	7737552270	2025-07-28 10:00:00	Needs Followup	Ecosport 3799 service 	2025-05-19 09:09:43.866771	6	2025-05-31 08:43:51.744985	
7315	Cx2031	9571993366	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-19 09:11:34.791502	6	2025-05-31 08:43:51.744985	
7316	Figo 	8963006086	2025-07-28 10:00:00	Needs Followup	Dent paint 	2025-05-19 12:31:12.227349	6	2025-05-31 08:43:51.744985	
7318	Cx2027	9829974729	2025-07-28 10:00:00	Needs Followup	Only washing 	2025-05-19 12:33:41.058716	6	2025-05-31 08:43:51.744985	
7341	gaadimech 	9610780627	2025-07-28 10:00:00	Needs Followup	Call u later 	2025-05-21 04:59:56.760902	6	2025-05-31 08:43:51.744985	
7381	Cx2037	9413336000	2025-07-29 10:00:00	Needs Followup	Dent paint 	2025-05-22 06:06:36.973928	4	2025-05-31 08:43:55.621424	
7382	Thar 5199	9982111222	2025-07-29 10:00:00	Needs Followup	Thar 5199	2025-05-22 06:07:47.465748	4	2025-05-31 08:43:55.621424	
3362	Ritik 	8955458504	2025-07-14 18:30:00	Confirmed	Kwid petrol interested 	2025-01-24 08:53:51.25089	9	2025-07-03 05:13:01.185129	\N
7383	Cx2037	9766092309	2025-07-29 10:00:00	Needs Followup	Dzire bumper paint 	2025-05-22 06:09:16.338763	4	2025-05-31 08:43:55.621424	
7384	gaadimech 	9782328113	2025-07-29 10:00:00	Needs Followup	Not pick	2025-05-22 07:45:20.506118	4	2025-05-31 08:43:55.621424	
5615	Dinesh 	9829610599	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:13:34.369119	4	2025-05-31 08:42:38.503765	
7395	gaadimech	8619284200	2025-07-29 10:00:00	Needs Followup	Dzire 2999	2025-05-22 12:38:29.569136	4	2025-05-31 08:43:55.621424	
7398	gaadiemch	8949752884	2025-07-29 10:00:00	Needs Followup	Dzire 2999 \r\nBusy call u later 7 pm	2025-05-22 12:40:12.169999	4	2025-05-31 08:43:55.621424	
7401	gaadimech 	8005830779	2025-07-29 10:00:00	Needs Followup	Not pick \r\nCelerio isn claim 	2025-05-23 04:46:57.570509	4	2025-05-31 08:43:55.621424	
7402	gaadimech 	7014156167	2025-07-29 10:00:00	Needs Followup	Busy call u later \r\nNot pick	2025-05-23 05:27:48.701078	4	2025-05-31 08:43:55.621424	
5617	Jaideep 	9829610463	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:14:38.125822	4	2025-05-31 08:42:38.503765	
5618	Ilyas	9829610449	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:15:10.042368	4	2025-05-31 08:42:38.503765	
7358	gaadimech 	9928078471	2025-07-28 10:00:00	Needs Followup	Ciaz 3199\r\nI20 2999\r\nCall back	2025-05-21 07:58:41.049111	6	2025-05-31 08:43:51.744985	
7363	Cx2030	7568018818	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-21 11:05:03.425689	6	2025-05-31 08:43:51.744985	
7365	Cx2033	9873700603	2025-07-28 10:00:00	Needs Followup	Car service 	2025-05-21 11:06:06.670533	6	2025-05-31 08:43:51.744985	
7403	Cx2036	8058101563	2025-07-29 10:00:00	Needs Followup	Car service 	2025-05-23 05:28:04.601491	4	2025-05-31 08:43:55.621424	
7418	gaadimech 	9829611117	2025-07-18 18:30:00	Did Not Pick Up	Not pick \r\nService done company workshop 	2025-05-23 06:50:11.215799	6	2025-06-01 07:14:29.983598	
7425	gaadimech 	9509429998	2025-08-29 18:30:00	Did Not Pick Up	BREZZA 3499 free service due 	2025-05-23 07:24:22.054358	6	2025-05-29 09:56:30.04078	
7743	Kwid Jagatpura	9660828420	2025-07-05 18:30:00	Needs Followup	Kwid Jagatpura \r\nCall cut 	2025-06-29 05:29:20.507273	4	2025-07-04 09:25:28.017051	
7452	gaadimech 	7428829683	2025-08-29 18:30:00	Did Not Pick Up	Call cut\r\nCall cut	2025-05-24 06:54:02.549122	6	2025-05-28 04:48:23.892286	
5629	Amit	9830195417	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:29:09.868742	4	2025-05-31 08:42:38.503765	
7378	gaadimech 	7568030559	2025-07-29 10:00:00	Needs Followup	Not pick \r\nClutch workke 4000 amount btaye h	2025-05-22 05:15:36.261585	4	2025-05-31 08:43:55.621424	
5630	Nilotpal	9830031975	2025-07-10 10:00:00	Needs Followup		2025-04-07 12:30:05.900883	4	2025-05-31 08:42:38.503765	
5680	Customer 	9887284361	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:48:29.636225	6	2025-05-31 08:42:38.503765	
5682	Customer 	9828074155	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:49:42.416271	6	2025-05-31 08:42:38.503765	
7436	Mobilio 3699	9799196980	2025-07-29 10:00:00	Needs Followup	Mobilio 3699	2025-05-23 09:53:40.475148	4	2025-05-31 08:43:55.621424	
7502	gaadimech 	9314524660	2025-09-26 18:30:00	Did Not Pick Up	Gi10 2699\r\nKukas se service krwa li 	2025-05-25 08:50:46.324653	6	2025-05-28 07:19:50.152801	
5690	Customer 	9649990957	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:57:57.76014	6	2025-05-31 08:42:38.503765	
5691	Customer 	9001796959	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:58:25.751695	6	2025-05-31 08:42:38.503765	
5692	Customer 	9252530515	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:59:14.160888	6	2025-05-31 08:42:38.503765	
5693	Customer 	9252530515	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:59:16.419979	6	2025-05-31 08:42:38.503765	
5694	Customer 	9252530515	2025-07-10 10:00:00	Needs Followup		2025-04-08 11:59:17.37694	6	2025-05-31 08:42:38.503765	
5695	Customer 	9214076100	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 11:59:46.586055	6	2025-05-31 08:42:38.503765	
7473	gaadimech 	8504074182	2025-07-03 18:30:00	Did Not Pick Up	Ameo 3999 \r\nCall cut	2025-05-24 10:33:49.016248	6	2025-06-28 07:01:21.766286	
6981	gaadimech 	9672800256	2025-07-11 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-05-08 04:52:37.397667	6	2025-06-30 09:26:09.082761	
7744	gaadimech	9828409640	2025-07-03 18:30:00	Needs Followup	Q3 dent paint \r\nCall u later 	2025-06-29 05:30:25.1022	6	2025-07-02 10:23:00.82616	
5696	Customer 	9928926333	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:00:20.554253	6	2025-05-31 08:42:38.503765	
5697	Customer 	9829120095	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:00:43.372843	6	2025-05-31 08:42:38.503765	
7515	Cx2057	9928803405	2025-07-29 10:00:00	Needs Followup	Car service \r\n3 baje call 	2025-05-27 08:52:00.092894	4	2025-05-31 08:43:55.621424	
7560	gaadimech 	9928909624	2025-07-03 18:30:00	Did Not Pick Up	Eco service done next time	2025-05-29 05:03:35.482605	6	2025-05-29 05:03:35.482614	
7551	gaadimech 	9982053145	2025-07-25 18:30:00	Did Not Pick Up	Busy call u later \r\nNot interested 	2025-05-28 12:05:37.274203	6	2025-05-31 08:20:40.698223	
5793	Customer 	9414035551	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:01:39.645399	4	2025-05-31 08:42:42.451086	
7535	gaadimech 	9571774390	2025-07-04 18:30:00	Did Not Pick Up	Not pick Herrier 4999\r\n\r\nNot requirement 	2025-05-28 06:26:44.186789	6	2025-06-28 06:56:34.00988	
3363	Eon 	6350455185	2025-07-06 18:30:00	Confirmed	Not picking 	2025-01-24 08:53:51.25089	9	2025-07-01 09:05:10.073976	\N
5698	Customer 	9929105282	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:01:14.991839	6	2025-05-31 08:42:38.503765	
5699	Customer 	9413566310	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:02:01.945642	6	2025-05-31 08:42:38.503765	
5700	Customer 	9001195789	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:02:38.690561	6	2025-05-31 08:42:38.503765	
5701	Customer 	9828352242	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:03:09.485339	6	2025-05-31 08:42:38.503765	
5702	Customer 	9828385585	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:03:43.197605	6	2025-05-31 08:42:38.503765	
5704	Customer 	7568488886	2025-07-10 10:00:00	Needs Followup	Nexon ev 	2025-04-08 12:06:01.851649	6	2025-05-31 08:42:38.503765	
5705	Customer 	9001896629	2025-07-10 10:00:00	Needs Followup	Seltos 3899	2025-04-08 12:06:40.66931	6	2025-05-31 08:42:38.503765	
5706	Customer 	9887666300	2025-07-10 10:00:00	Needs Followup	Swift: 2799\r\nI 10 :2299	2025-04-08 12:07:48.698575	6	2025-05-31 08:42:38.503765	
5707	Customer 	9785302466	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:13:37.301114	6	2025-05-31 08:42:38.503765	
5709	Customer 	9829195055	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:15:33.693518	6	2025-05-31 08:42:38.503765	
5712	Customer 	9837024830	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:16:52.499509	6	2025-05-31 08:42:38.503765	
5713	Customer 	9001091029	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:17:19.065987	6	2025-05-31 08:42:38.503765	
5714	Customer 	9950655551	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:17:48.041547	6	2025-05-31 08:42:38.503765	
5715	Customer 	9829061246	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:18:21.446085	6	2025-05-31 08:42:38.503765	
5716	Customer 	9785009033	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:18:51.270516	6	2025-05-31 08:42:38.503765	
5717	Customer 	9785258958	2025-07-10 10:00:00	Needs Followup	Alto:2399	2025-04-08 12:19:30.694902	6	2025-05-31 08:42:38.503765	
5719	Customer 	9829012263	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:20:28.160833	6	2025-05-31 08:42:38.503765	
5720	Customer 	9414909571	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:20:57.877215	6	2025-05-31 08:42:38.503765	
5721	Customer 	9461586970	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:21:32.878048	6	2025-05-31 08:42:38.503765	
5722	Customer 	8769020202	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:21:57.695805	6	2025-05-31 08:42:38.503765	
5723	Customer 	9314621125	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:22:22.551893	6	2025-05-31 08:42:38.503765	
5724	Customer 	8209526442	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:23:48.806687	6	2025-05-31 08:42:38.503765	
5725	Customer 	8058928484	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:24:16.735485	6	2025-05-31 08:42:38.503765	
5726	Customer 	7568563454	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:24:48.661325	6	2025-05-31 08:42:38.503765	
5727	Customer 	9414795962	2025-07-10 10:00:00	Needs Followup	Not interested 	2025-04-08 12:25:21.670453	6	2025-05-31 08:42:38.503765	
5728	Customer 	9929597406	2025-07-10 10:00:00	Needs Followup		2025-04-08 12:25:49.864703	6	2025-05-31 08:42:38.503765	
5731	Customer 	8003728439	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:27:03.061132	4	2025-05-31 08:42:42.451086	
5732	Customer 	9413313131	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-08 12:27:29.238871	4	2025-05-31 08:42:42.451086	
5733	Customer 	9785552525	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:27:48.234368	4	2025-05-31 08:42:42.451086	
5734	Customer 	9785644075	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-08 12:28:15.266612	4	2025-05-31 08:42:42.451086	
5735	Customer 	9549666604	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-08 12:28:42.051737	4	2025-05-31 08:42:42.451086	
5736	Customer 	9414778794	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:29:04.343208	4	2025-05-31 08:42:42.451086	
5737	Customer 	9314430319	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-08 12:29:32.927155	4	2025-05-31 08:42:42.451086	
5738	Customer 	9314524652	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:29:59.239478	4	2025-05-31 08:42:42.451086	
5739	Customer 	9414045907	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:30:40.196055	4	2025-05-31 08:42:42.451086	
5740	Customer 	9414045907	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:30:42.044648	4	2025-05-31 08:42:42.451086	
5741	Customer 	9414045907	2025-07-11 10:00:00	Needs Followup		2025-04-08 12:30:46.991169	4	2025-05-31 08:42:42.451086	
5742	Customer 	7891962750	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-08 12:34:16.021674	4	2025-05-31 08:42:42.451086	
5773	Customer 	9829166099	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:21:11.822369	4	2025-05-31 08:42:42.451086	
5774	Customer 	9413966881	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:22:08.475901	4	2025-05-31 08:42:42.451086	
5775	Customer 	9602599033	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:22:33.371136	4	2025-05-31 08:42:42.451086	
7589	gaadimech	9950081164	2025-07-18 18:30:00	Did Not Pick Up	Not pick\r\nFronx service done by company \r\nNext time try krenge	2025-05-29 11:45:32.814994	6	2025-05-31 06:19:20.174547	
5776	Customer 	9414049220	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:41:28.530619	4	2025-05-31 08:42:42.451086	
5777	Customer 	8107223344	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:43:55.28848	4	2025-05-31 08:42:42.451086	
5778	Customer 	9829190602	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:44:34.178959	4	2025-05-31 08:42:42.451086	
5781	Customer 	9602375464	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:54:13.86773	4	2025-05-31 08:42:42.451086	
5782	Customer 	9828111839	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:54:49.624431	4	2025-05-31 08:42:42.451086	
5783	Customer 	9314557770	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 09:57:05.475747	4	2025-05-31 08:42:42.451086	
5784	Customer 	9782311111	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:57:30.241087	4	2025-05-31 08:42:42.451086	
5785	Customer 	9783911111	2025-07-11 10:00:00	Needs Followup		2025-04-09 09:57:52.465978	4	2025-05-31 08:42:42.451086	
7575	gaadimech 	9950081164	2025-08-29 18:30:00	Did Not Pick Up	Not interested 	2025-05-29 10:06:01.438354	6	2025-06-30 08:17:37.682835	
5794	Customer 	9414035551	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:01:41.264721	6	2025-05-31 08:42:42.451086	
5795	Customer 	9414745808	2025-07-11 10:00:00	Needs Followup	I 20 2999	2025-04-09 10:02:45.324505	6	2025-05-31 08:42:42.451086	
5796	Customer 	9529574305	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:03:31.700706	6	2025-05-31 08:42:42.451086	
5798	Customer 	9829013793	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:05:03.492411	6	2025-05-31 08:42:42.451086	
5799	Customer 	9001140511	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:06:49.676441	6	2025-05-31 08:42:42.451086	
5800	Customer 	9414052177	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:07:19.476727	6	2025-05-31 08:42:42.451086	
5802	Customer 	9352611228	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:08:34.731287	6	2025-05-31 08:42:42.451086	
5803	Customer 	9929603270	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:08:59.419756	6	2025-05-31 08:42:42.451086	
5804	Customer 	9414077933	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:09:29.700702	6	2025-05-31 08:42:42.451086	
5808	Customer 	9929603270	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:24:31.994564	6	2025-05-31 08:42:42.451086	
5809	Customer 	9414077933	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:24:59.411329	6	2025-05-31 08:42:42.451086	
5810	Customer 	9414064696	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:25:33.801224	6	2025-05-31 08:42:42.451086	
5811	Customer 	9829142601	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:26:08.162727	6	2025-05-31 08:42:42.451086	
5812	Customer 	9829142601	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:26:09.165896	6	2025-05-31 08:42:42.451086	
5813	Customer 	9828170057	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:26:38.707527	6	2025-05-31 08:42:42.451086	
5814	Customer 	9928783999	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:27:04.226705	6	2025-05-31 08:42:42.451086	
5815	Customer 	9887347337	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:28:03.595272	6	2025-05-31 08:42:42.451086	
5816	Customer 	9887295441	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:28:36.717233	6	2025-05-31 08:42:42.451086	
5818	Customer 	9413961781	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:30:16.899162	6	2025-05-31 08:42:42.451086	
5819	Customer 	9413901611	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:30:43.529276	6	2025-05-31 08:42:42.451086	
5821	Customer 	8058797966	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-09 10:31:42.493261	6	2025-05-31 08:42:42.451086	
5822	Customer 	9414229396	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:32:24.208104	6	2025-05-31 08:42:42.451086	
5825	Customer 	9414297814	2025-07-11 10:00:00	Needs Followup		2025-04-09 10:34:23.199667	6	2025-05-31 08:42:42.451086	
5921	Customer 	9413127393	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:11:33.089259	6	2025-05-31 08:42:42.451086	
5922	Customer 	9413127393	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:11:33.975011	6	2025-05-31 08:42:42.451086	
5926	Customer 	9414489547	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:13:13.668137	6	2025-05-31 08:42:42.451086	
5927	Customer 	9468591638	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:13:41.910565	6	2025-05-31 08:42:42.451086	
5929	Customer 	9928406810	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:14:47.062185	6	2025-05-31 08:42:42.451086	
5930	Customer 	9314267785	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:15:15.472979	6	2025-05-31 08:42:42.451086	
5931	Customer 	9887821606	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:15:42.709558	6	2025-05-31 08:42:42.451086	
5932	Customer 	9672166660	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:16:05.23172	6	2025-05-31 08:42:42.451086	
5933	Customer 	9829144497	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:16:38.482658	6	2025-05-31 08:42:42.451086	
5934	Customer 	9460417194	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:17:07.592695	6	2025-05-31 08:42:42.451086	
5935	Customer 	9799812279	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:17:34.892999	6	2025-05-31 08:42:42.451086	
5936	Customer 	9782222536	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:18:10.353417	6	2025-05-31 08:42:42.451086	
5937	Customer 	9414769967	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:18:44.861181	6	2025-05-31 08:42:42.451086	
5938	Customer 	9351767195	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:19:08.456129	6	2025-05-31 08:42:42.451086	
5939	Customer 	9352995421	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:19:30.907603	6	2025-05-31 08:42:42.451086	
5940	Customer 	9929603492	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:19:55.758688	6	2025-05-31 08:42:42.451086	
5941	Customer 	9829866676	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:20:28.262855	6	2025-05-31 08:42:42.451086	
5942	Customer 	9887060301	2025-07-11 10:00:00	Needs Followup	Honda Amaze 3199	2025-04-14 11:23:14.975111	6	2025-05-31 08:42:42.451086	
5943	Customer 	9116000371	2025-07-11 10:00:00	Needs Followup	Not interested 	2025-04-14 11:23:48.175466	6	2025-05-31 08:42:42.451086	
5945	Customer 	9413626333	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:30:40.69643	6	2025-05-31 08:42:42.451086	
5946	Customer 	9829324893	2025-07-11 10:00:00	Needs Followup		2025-04-14 11:31:20.258212	6	2025-05-31 08:42:42.451086	
5964	Customer 	9413748583	2025-07-12 10:00:00	Needs Followup	Baleno 2799	2025-04-15 10:40:55.786609	4	2025-05-31 08:42:46.397595	
5965	Customer 	9980923068	2025-07-12 10:00:00	Needs Followup		2025-04-15 10:47:17.180023	4	2025-05-31 08:42:46.397595	
5966	Customer 	7665032666	2025-07-12 10:00:00	Needs Followup		2025-04-15 10:47:44.668871	4	2025-05-31 08:42:46.397595	
5967	Customer 	8302470376	2025-07-12 10:00:00	Needs Followup		2025-04-15 10:48:27.480058	4	2025-05-31 08:42:46.397595	
5968	Customer 	8003240097	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:01:23.482098	4	2025-05-31 08:42:46.397595	
5969	Customer 	9413349430	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:01:47.44458	4	2025-05-31 08:42:46.397595	
5970	Customer 	9829692661	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:19:50.821485	4	2025-05-31 08:42:46.397595	
5971	Customer 	9982053076	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:22:56.787832	4	2025-05-31 08:42:46.397595	
5972	Customer 	9414070478	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:23:28.920842	4	2025-05-31 08:42:46.397595	
5973	Customer 	9414339735	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:23:51.916224	4	2025-05-31 08:42:46.397595	
5974	Customer 	9772114441	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:24:49.205374	4	2025-05-31 08:42:46.397595	
5975	Customer 	9414752966	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:26:17.387652	4	2025-05-31 08:42:46.397595	
5976	Customer 	9928352424	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:26:53.326469	4	2025-05-31 08:42:46.397595	
5977	Customer 	9928352424	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:26:55.660947	4	2025-05-31 08:42:46.397595	
5978	Customer 	9929560028	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:27:28.220646	4	2025-05-31 08:42:46.397595	
5979	Customer 	7597924870	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:27:55.572148	4	2025-05-31 08:42:46.397595	
5980	Customer 	9887976453	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:28:28.625191	4	2025-05-31 08:42:46.397595	
5981	Customer 	9460778890	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:29:04.783023	4	2025-05-31 08:42:46.397595	
5982	Customer 	9929560028	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:32:22.000456	4	2025-05-31 08:42:46.397595	
5983	Customer 	7597924870	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:33:16.598712	4	2025-05-31 08:42:46.397595	
5987	Customer 	9414250773	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:35:17.683345	4	2025-05-31 08:42:46.397595	
5988	Customer 	9672989995	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:35:42.358717	4	2025-05-31 08:42:46.397595	
5990	Customer 	9799970989	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:38:41.962766	4	2025-05-31 08:42:46.397595	
5991	Customer 	9929371095	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:39:08.502975	4	2025-05-31 08:42:46.397595	
5992	Customer 	7976717454	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:42:17.630126	4	2025-05-31 08:42:46.397595	
5993	Customer 	9610456782	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:46:49.984426	4	2025-05-31 08:42:46.397595	
5994	Customer 	9413678741	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:47:13.048564	4	2025-05-31 08:42:46.397595	
5995	Customer 	9413765833	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:48:35.552672	4	2025-05-31 08:42:46.397595	
5996	Customer 	9549263696	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:49:21.890725	4	2025-05-31 08:42:46.397595	
5997	Customer 	9549263696	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:49:52.70323	4	2025-05-31 08:42:46.397595	
5998	Customer 	8890359797	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:53:58.146525	4	2025-05-31 08:42:46.397595	
5999	Customer 	9982199966	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:55:04.550204	4	2025-05-31 08:42:46.397595	
6000	Customer 	9610988887	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:55:35.112867	4	2025-05-31 08:42:46.397595	
6001	Customer 	9610988887	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:57:44.237008	4	2025-05-31 08:42:46.397595	
6002	Customer 	9413418240	2025-07-12 10:00:00	Needs Followup	Hyundai Verna 3399	2025-04-15 11:58:30.497926	4	2025-05-31 08:42:46.397595	
6003	Customer 	9610445959	2025-07-12 10:00:00	Needs Followup		2025-04-15 11:58:56.724373	4	2025-05-31 08:42:46.397595	
6004	Customer 	9828581500	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 11:59:33.779719	4	2025-05-31 08:42:46.397595	
6005	Customer 	8824841784	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:00:02.571576	4	2025-05-31 08:42:46.397595	
6006	Customer 	9829304207	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:00:44.076414	4	2025-05-31 08:42:46.397595	
6007	Customer 	7737813391	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:01:20.830214	4	2025-05-31 08:42:46.397595	
6008	Customer 	9460117877	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:02:38.114619	4	2025-05-31 08:42:46.397595	
6009	Customer 	9414058857	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:11:39.973782	4	2025-05-31 08:42:46.397595	
6010	Customer 	9414058857	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:11:42.118413	4	2025-05-31 08:42:46.397595	
6013	Customer 	9001008013	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:14:30.132398	4	2025-05-31 08:42:46.397595	
6016	Customer 	9460190988	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:17:11.000356	4	2025-05-31 08:42:46.397595	
6017	Customer 	9829018084	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:17:35.45976	4	2025-05-31 08:42:46.397595	
6018	Customer 	9928021316	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:18:02.770204	6	2025-05-31 08:42:46.397595	
6019	Customer 	9829922401	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:18:30.086848	6	2025-05-31 08:42:46.397595	
6020	Customer 	9782844053	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:19:02.014886	6	2025-05-31 08:42:46.397595	
6021	Customer 	9928009570	2025-07-12 10:00:00	Needs Followup	Amaze 3199	2025-04-15 12:19:36.01475	6	2025-05-31 08:42:46.397595	
6022	Customer 	9680141028	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:20:20.175609	6	2025-05-31 08:42:46.397595	
6023	Customer 	9829260999	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:20:45.927147	6	2025-05-31 08:42:46.397595	
6024	Customer 	9829222043	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:21:34.939057	6	2025-05-31 08:42:46.397595	
6025	Customer 	9829222043	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:22:42.280145	6	2025-05-31 08:42:46.397595	
6026	Customer 	9829364140	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:23:42.231004	6	2025-05-31 08:42:46.397595	
6027	Customer 	9829242562	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:24:08.042876	6	2025-05-31 08:42:46.397595	
6028	Customer 	9414055205	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:24:31.938854	6	2025-05-31 08:42:46.397595	
6029	Customer 	9414055205	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:24:34.128969	6	2025-05-31 08:42:46.397595	
6030	Customer 	9829473733	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:25:01.968064	6	2025-05-31 08:42:46.397595	
6031	Customer 	9829473733	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:25:04.175834	6	2025-05-31 08:42:46.397595	
6037	Customer 	9314509107	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:27:25.620678	6	2025-05-31 08:42:46.397595	
6038	Customer 	9314509107	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:27:26.863849	6	2025-05-31 08:42:46.397595	
6039	Customer 	9314509107	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:27:27.749553	6	2025-05-31 08:42:46.397595	
6040	Customer 	9828066894	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:27:47.229163	6	2025-05-31 08:42:46.397595	
6041	Customer 	8875622221	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:28:09.294441	6	2025-05-31 08:42:46.397595	
6042	Customer 	8875622221	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:28:11.51689	6	2025-05-31 08:42:46.397595	
6043	Customer 	8875622221	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:28:12.715685	6	2025-05-31 08:42:46.397595	
6044	Customer 	9694883000	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:28:39.11158	6	2025-05-31 08:42:46.397595	
6045	Customer 	9414070327	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:29:09.890693	6	2025-05-31 08:42:46.397595	
6046	Customer 	9829127041	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:29:34.936925	6	2025-05-31 08:42:46.397595	
6047	Customer 	9352995574	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:30:01.795191	6	2025-05-31 08:42:46.397595	
6048	Customer 	9530138389	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:30:32.058647	6	2025-05-31 08:42:46.397595	
6049	Customer 	9602953066	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:37:09.582181	6	2025-05-31 08:42:46.397595	
6050	Customer 	9828108660	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:37:36.535669	6	2025-05-31 08:42:46.397595	
6051	Customer 	9829100999	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:37:57.51484	6	2025-05-31 08:42:46.397595	
6065	Customer 	9587703777	2025-07-12 10:00:00	Needs Followup	Not interested 	2025-04-15 12:44:57.680678	6	2025-05-31 08:42:46.397595	
6066	Customer 	9828055166	2025-07-12 10:00:00	Needs Followup	Not interested to 	2025-04-15 12:45:23.236366	6	2025-05-31 08:42:46.397595	
6067	Customer 	9828055166	2025-07-12 10:00:00	Needs Followup		2025-04-15 12:45:54.310931	6	2025-05-31 08:42:46.397595	
6075	Customer 	9829043551	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:50:58.955034	4	2025-05-31 08:42:50.438237	
6076	Customer 	8619226253	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:51:24.599829	4	2025-05-31 08:42:50.438237	
6077	Customer 	9511565621	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:51:50.198952	4	2025-05-31 08:42:50.438237	
6078	Customer 	9511565621	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:51:51.299665	4	2025-05-31 08:42:50.438237	
6079	Customer 	6378110509	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:52:15.534879	4	2025-05-31 08:42:50.438237	
6080	Customer 	7073716650	2025-07-13 10:00:00	Needs Followup	Scorpio 5199	2025-04-15 12:52:52.924493	4	2025-05-31 08:42:50.438237	
6081	Customer 	6375390620	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:53:21.458632	4	2025-05-31 08:42:50.438237	
6082	Customer 	8118835613	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:53:49.926462	4	2025-05-31 08:42:50.438237	
6083	Customer 	8118835613	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:53:52.743733	4	2025-05-31 08:42:50.438237	
6084	Customer 	9829120244	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-15 12:54:19.309311	4	2025-05-31 08:42:50.438237	
6085	Customer 	9711458958	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:54:54.839655	4	2025-05-31 08:42:50.438237	
6086	Customer 	9799557712	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:55:20.886105	4	2025-05-31 08:42:50.438237	
6087	Customer 	9799557712	2025-07-13 10:00:00	Needs Followup		2025-04-15 12:55:40.008946	4	2025-05-31 08:42:50.438237	
6114	Customer 	6377244948	2025-07-13 10:00:00	Needs Followup	Scorpio 5199	2025-04-16 11:58:40.471423	4	2025-05-31 08:42:50.438237	
6115	Customer 	9829089693	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 11:59:35.157811	4	2025-05-31 08:42:50.438237	
6116	Customer 	9829012288	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 11:59:59.903005	4	2025-05-31 08:42:50.438237	
6117	Customer 	7878623231	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:00:39.987225	4	2025-05-31 08:42:50.438237	
6118	Customer 	9819016466	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:01:42.013886	4	2025-05-31 08:42:50.438237	
6119	Customer 	8562802595	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:03:16.621248	4	2025-05-31 08:42:50.438237	
6120	Customer 	9828888666	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:03:46.629674	4	2025-05-31 08:42:50.438237	
6121	Customer 	9414058022	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:04:12.420296	4	2025-05-31 08:42:50.438237	
6122	Customer 	9929091356	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:04:34.018526	4	2025-05-31 08:42:50.438237	
6123	Customer 	8005582547	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:05:10.743227	4	2025-05-31 08:42:50.438237	
6124	Customer 	9828100559	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:05:38.989526	4	2025-05-31 08:42:50.438237	
6125	Customer 	9680108080	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:06:23.124515	4	2025-05-31 08:42:50.438237	
6126	Customer 	9887422791	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:06:46.472337	4	2025-05-31 08:42:50.438237	
6127	Customer 	9928182900	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:07:24.395543	4	2025-05-31 08:42:50.438237	
6128	Customer 	9314222999	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:07:51.198688	4	2025-05-31 08:42:50.438237	
3364	i20 	8058888115	2025-07-30 18:30:00	Confirmed	Not picking twice	2025-01-24 08:53:51.25089	9	2025-07-05 08:28:34.140382	\N
6129	Customer 	8005400069	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:08:22.072486	4	2025-05-31 08:42:50.438237	
6130	Customer 	9667002854	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-16 12:08:48.069569	4	2025-05-31 08:42:50.438237	
6131	Customer 	8209010273	2025-07-13 10:00:00	Needs Followup	Verna 3399	2025-04-16 12:10:04.63914	4	2025-05-31 08:42:50.438237	
6132	Customer 	9620717001	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:11:02.24551	4	2025-05-31 08:42:50.438237	
6133	Customer 	9352592584	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:16:15.258725	4	2025-05-31 08:42:50.438237	
6134	Customer 	9352592584	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:16:16.144146	4	2025-05-31 08:42:50.438237	
6135	Customer 	9680193300	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:16:45.214386	4	2025-05-31 08:42:50.438237	
6136	Customer 	9549133990	2025-07-13 10:00:00	Needs Followup	Amaze 3199	2025-04-16 12:17:23.249122	4	2025-05-31 08:42:50.438237	
6137	Customer 	9509725887	2025-07-13 10:00:00	Needs Followup	Swift dizire 2999	2025-04-16 12:18:01.808707	4	2025-05-31 08:42:50.438237	
6138	Customer 	9783330787	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:18:37.139603	4	2025-05-31 08:42:50.438237	
6139	Customer 	9928273000	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:19:24.106959	4	2025-05-31 08:42:50.438237	
6140	Customer 	8160262381	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:19:51.151912	4	2025-05-31 08:42:50.438237	
6141	Customer 	9001908360	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:20:22.047404	4	2025-05-31 08:42:50.438237	
6143	Customer 	9319055791	2025-07-13 10:00:00	Needs Followup		2025-04-16 12:21:28.374471	4	2025-05-31 08:42:50.438237	
6144	Customer 	6378087992	2025-07-13 10:00:00	Needs Followup	I 10 2299	2025-04-16 12:22:11.961632	4	2025-05-31 08:42:50.438237	
6146	Customer 	8279202495	2025-07-13 10:00:00	Needs Followup	Xcent 2799	2025-04-16 12:25:07.21792	4	2025-05-31 08:42:50.438237	
6147	Customer 	8279202495	2025-07-13 10:00:00	Needs Followup	Xcent 2799	2025-04-16 12:26:12.170015	6	2025-05-31 08:42:50.438237	
6148	Customer 	9829012433	2025-07-13 10:00:00	Needs Followup	Venue 3199	2025-04-16 12:26:53.165549	6	2025-05-31 08:42:50.438237	
6149	Customer 	8561868058	2025-07-13 10:00:00	Needs Followup	Baleno \r\nDent paint 2099	2025-04-16 12:27:43.913893	6	2025-05-31 08:42:50.438237	
6150	Customer 	6377707166	2025-07-13 10:00:00	Needs Followup	Alto 2299\r\nCreata 	2025-04-16 12:28:20.215228	6	2025-05-31 08:42:50.438237	
6151	Customer 	6367921147	2025-07-13 10:00:00	Needs Followup	Alto 2399	2025-04-16 12:28:50.842	6	2025-05-31 08:42:50.438237	
6153	Customer 	6375439598	2025-07-13 10:00:00	Needs Followup	Swift dizire 2999	2025-04-16 12:30:59.660442	6	2025-05-31 08:42:50.438237	
6291	Customer 	9829066657	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-18 10:51:36.715969	6	2025-05-31 08:42:50.438237	
6414	Customer 	9829068522	2025-07-13 10:00:00	Needs Followup		2025-04-21 06:49:58.508811	6	2025-05-31 08:42:50.438237	
6420	Customer 	9829056081	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:24:07.449083	6	2025-05-31 08:42:50.438237	
6422	Customer 	9829054020	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:25:27.116003	6	2025-05-31 08:42:50.438237	
6431	Customer 	9828858190	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:45:46.809877	6	2025-05-31 08:42:50.438237	
6432	Customer 	9828858190	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-21 08:52:44.20871	6	2025-05-31 08:42:50.438237	
6433	Customer 	9829056234	2025-07-13 10:00:00	Needs Followup		2025-04-21 08:53:54.76094	6	2025-05-31 08:42:50.438237	
6435	Customer 	9829057132	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:23:51.872153	6	2025-05-31 08:42:50.438237	
6442	Customer 	9414441045	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:39:33.10959	6	2025-05-31 08:42:50.438237	
6443	Customer 	9829014700	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-21 09:40:58.757086	6	2025-05-31 08:42:50.438237	
6444	Customer 	9828328000	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:42:05.453826	6	2025-05-31 08:42:50.438237	
6445	Customer 	9829770101	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:42:35.559798	6	2025-05-31 08:42:50.438237	
6449	Customer 	9610130000	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:44:23.251647	6	2025-05-31 08:42:50.438237	
6451	Customer 	9829055545	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:45:44.231061	6	2025-05-31 08:42:50.438237	
6452	Customer 	9314506937	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:46:11.672167	6	2025-05-31 08:42:50.438237	
6457	Customer 	9829162900	2025-07-13 10:00:00	Needs Followup	Not interested 	2025-04-21 09:49:55.660018	6	2025-05-31 08:42:50.438237	
6458	Customer 	9829016227	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:50:19.049624	6	2025-05-31 08:42:50.438237	
6469	Customer 	9414042573	2025-07-13 10:00:00	Needs Followup		2025-04-21 09:55:24.502155	6	2025-05-31 08:42:50.438237	
6470	Customer 	9314957585	2025-07-13 10:00:00	Needs Followup		2025-04-21 10:05:36.076982	6	2025-05-31 08:42:50.438237	
7596	gaadimech	9414066759	2025-08-15 18:30:00	Needs Followup	Duster service done next time dekhenge\r\nNot interested 	2025-05-30 04:54:49.869139	6	2025-06-28 06:50:25.530953	
6471	Customer 	9314502023	2025-07-13 10:00:00	Needs Followup		2025-04-21 11:29:33.280906	6	2025-05-31 08:42:50.438237	
6472	Customer 	9414064883	2025-07-13 10:00:00	Needs Followup		2025-04-21 11:30:00.092413	6	2025-05-31 08:42:50.438237	
6474	Customer 	9414250768	2025-07-13 10:00:00	Needs Followup		2025-04-21 11:30:54.397047	6	2025-05-31 08:42:50.438237	
6693	Sudhir Sonker 	9166649220	2025-07-13 10:00:00	Needs Followup	Wagonr service 2599\r\nTotal Payment - 3549 ( Online) \r\nClutch work in progress \r\n	2025-04-26 04:48:46.513736	6	2025-05-31 08:42:50.438237	RJ14CQ1864
6229	Customer 	7737666665	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:45:07.409617	4	2025-05-31 08:42:54.38585	
6254	Customer 	8003384326	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:08:46.311276	4	2025-05-31 08:42:54.38585	
4861	gaadimech 	9649915055	2025-07-14 10:00:00	Needs Followup	Amaze 2999 package share	2025-03-19 07:01:32.867102	4	2025-05-31 08:42:54.38585	
4905	gaadimech 	8955549338	2025-07-14 10:00:00	Needs Followup	Ignis 2799 sharp motors 	2025-03-21 05:36:21.443225	4	2025-05-31 08:42:54.38585	
5498	gaadimech 	8432063939	2025-07-14 10:00:00	Needs Followup	Not pick 	2025-04-02 12:30:06.100881	4	2025-05-31 08:42:54.38585	
6237	Customer 	7451011116	2025-07-14 10:00:00	Needs Followup	Not interested 	2025-04-17 11:49:45.93566	6	2025-05-31 08:42:54.38585	
6238	Customer 	9414447870	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:50:17.526884	6	2025-05-31 08:42:54.38585	
6245	Customer 	9549569882	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:53:37.787016	6	2025-05-31 08:42:54.38585	
6246	Customer 	9828161719	2025-07-14 10:00:00	Needs Followup		2025-04-17 11:54:03.503439	6	2025-05-31 08:42:54.38585	
6247	Customer 	9667822280	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:03:07.831478	6	2025-05-31 08:42:54.38585	
6251	Customer 	9829483799	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:07:01.752205	6	2025-05-31 08:42:54.38585	
6263	Customer 	9829067542	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:15:30.320939	6	2025-05-31 08:42:54.38585	
6265	Customer 	9079845465	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:16:29.464781	6	2025-05-31 08:42:54.38585	
6267	Customer 	9079845465	2025-07-14 10:00:00	Needs Followup		2025-04-17 12:17:34.408963	6	2025-05-31 08:42:54.38585	
6325	Customer 	9314086915	2025-07-14 10:00:00	Needs Followup		2025-04-19 11:17:45.737955	6	2025-05-31 08:42:54.38585	
6765	gaadimech 	9828651602	2025-07-14 10:00:00	Needs Followup	Swift dent paint 2199	2025-04-28 05:32:38.921823	6	2025-05-31 08:42:54.38585	
430	.	6350064826	2025-07-14 10:00:00	Needs Followup	Car warranty period me hai	2024-11-28 06:03:20	6	2025-05-31 08:42:54.38585	
550	Hemmant ji	9549133990	2025-07-14 10:00:00	Needs Followup	Ap payment jyada le rhe ho 2899 oil to Bus 1500 ka hi dalta h\r\nNot interested 	2024-11-29 07:12:53	6	2025-05-31 08:42:54.38585	
561	Yogesh ji 	9828011000	2025-07-14 10:00:00	Needs Followup	Dzire ka pack send kiya h but abhi need nhi h\r\nCall cut	2024-11-29 07:12:53	6	2025-05-31 08:42:54.38585	
3811	gaadimech	9950787467	2025-07-15 10:00:00	Needs Followup	Not pick call cut	2025-02-07 04:30:18.562584	4	2025-05-31 08:42:58.621937	
3813	.	9530027997	2025-07-15 10:00:00	Needs Followup	Venue 3199 	2025-02-07 04:30:18.562584	4	2025-05-31 08:42:58.621937	
4024	.	9352683079	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-15 07:41:20.966295	6	2025-05-31 08:42:58.621937	
4124	.	7014648081	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-16 11:56:52.510387	6	2025-05-31 08:42:58.621937	
4200	.	9509097527	2025-07-15 10:00:00	Needs Followup	Call cut	2025-02-18 11:42:31.822707	6	2025-05-31 08:42:58.621937	
4207	.	8766195004	2025-07-15 10:00:00	Needs Followup	Not pick \r\nNot interested 	2025-02-18 11:56:38.510917	6	2025-05-31 08:42:58.621937	
4217	.	9352666434	2025-07-15 10:00:00	Needs Followup	Not interested 	2025-02-18 12:09:11.552454	6	2025-05-31 08:42:58.621937	
4283	.	8949115922	2025-07-15 10:00:00	Needs Followup	Busy call u later \r\nBharatpur se hai jaipur ana hua to bat krenhe	2025-02-22 06:03:16.770154	6	2025-05-31 08:42:58.621937	
4384	.	9829060442	2025-07-15 10:00:00	Needs Followup	Not requirement 	2025-02-25 11:33:41.571171	6	2025-05-31 08:42:58.621937	
4390	gaadimech	9414550325	2025-07-15 10:00:00	Needs Followup	\r\nNot interested 	2025-02-25 11:52:12.725008	6	2025-05-31 08:42:58.621937	
4392	.	9829017648	2025-07-15 10:00:00	Needs Followup	Not pick 	2025-02-25 11:58:25.481247	6	2025-05-31 08:42:58.621937	
4413	gaadimech	7742185849	2025-07-15 10:00:00	Needs Followup	Not respond \r\nNot interested 	2025-02-27 04:28:09.486761	6	2025-05-31 08:42:58.621937	
4443	gaadimech 	9024764519	2025-07-15 10:00:00	Needs Followup	Etioes 2699. \r\n2 din pahle service ho gaye next time requirement hui to contact krenge	2025-02-28 12:19:33.003421	6	2025-05-31 08:42:58.621937	
4558	gaadimech 	9414071370	2025-07-16 10:00:00	Needs Followup	Seltos 3399 package\r\nCall cutis package me company me service ho jayegi\r\nCall cut	2025-03-07 08:51:51.708612	4	2025-05-31 08:43:02.994951	
4697	.	9829053858	2025-07-16 10:00:00	Needs Followup	Not pick	2025-03-12 11:32:33.212595	4	2025-05-31 08:43:02.994951	
4699	.	9783952739	2025-07-16 10:00:00	Needs Followup	Not pick	2025-03-12 11:36:48.785298	4	2025-05-31 08:43:02.994951	
4700	.	9887691351	2025-07-16 10:00:00	Needs Followup	Honda amaze 3199	2025-03-12 11:37:54.447894	4	2025-05-31 08:43:02.994951	
4701	.	9828395108	2025-07-16 10:00:00	Needs Followup	Not pick\r\n	2025-03-12 11:39:35.201944	4	2025-05-31 08:43:02.994951	
4714	.	9024570531	2025-07-16 10:00:00	Needs Followup	Not pick	2025-03-13 10:51:17.025865	4	2025-05-31 08:43:02.994951	
4715	.	9414058729	2025-07-16 10:00:00	Needs Followup	Not connect \r\nDon't have car	2025-03-13 10:51:51.430619	4	2025-05-31 08:43:02.994951	
4717	.	9414050027	2025-07-16 10:00:00	Needs Followup	Not required 	2025-03-13 10:56:44.186983	4	2025-05-31 08:43:02.994951	
4718	.	9829414103	2025-07-16 10:00:00	Needs Followup	Call cut	2025-03-13 10:57:32.346474	4	2025-05-31 08:43:02.994951	
4728	.	9829040503	2025-07-16 10:00:00	Needs Followup	Not pick	2025-03-13 11:09:08.359463	4	2025-05-31 08:43:02.994951	
4730	.	9829677272	2025-07-16 10:00:00	Needs Followup	Call cut	2025-03-13 11:11:59.905401	4	2025-05-31 08:43:02.994951	
4841	.	9636942211	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-03-18 11:59:33.916793	4	2025-05-31 08:43:02.994951	
6250	Customer 	9929298501	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:05:57.936344	4	2025-05-31 08:43:02.994951	
6255	Customer 	9624454668	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:09:22.633945	4	2025-05-31 08:43:02.994951	
6258	Customer 	8890307026	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:10:53.520818	4	2025-05-31 08:43:02.994951	
6259	Customer 	8094215933	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:11:21.160906	4	2025-05-31 08:43:02.994951	
6260	Customer 	8094215933	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:11:23.354903	4	2025-05-31 08:43:02.994951	
6261	Customer 	8094215933	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:12:43.786867	4	2025-05-31 08:43:02.994951	
6262	Customer 	9829108385	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:15:06.103759	4	2025-05-31 08:43:02.994951	
6264	Customer 	9314042233	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-17 12:15:54.237983	6	2025-05-31 08:43:02.994951	
6266	Customer 	9079845465	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:16:30.352297	6	2025-05-31 08:43:02.994951	
6269	Customer 	9314056599	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:18:55.254297	6	2025-05-31 08:43:02.994951	
6270	Customer 	9829054727	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:21:54.177789	6	2025-05-31 08:43:02.994951	
6272	Customer 	9784050000	2025-07-16 10:00:00	Needs Followup		2025-04-17 12:22:45.818655	6	2025-05-31 08:43:02.994951	
6289	Customer 	9660975727	2025-07-16 10:00:00	Needs Followup	Kia seltos 3599	2025-04-18 10:36:54.624621	6	2025-05-31 08:43:02.994951	
6292	Customer 	9828281104	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-18 10:55:00.925124	6	2025-05-31 08:43:02.994951	
6299	Customer 	9314501840	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-18 11:03:24.010281	6	2025-05-31 08:43:02.994951	
6301	Customer 	9829011339	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-18 11:20:41.481974	6	2025-05-31 08:43:02.994951	
6302	Customer 	9314612070	2025-07-16 10:00:00	Needs Followup	Not interested 	2025-04-18 11:22:13.870538	6	2025-05-31 08:43:02.994951	
6332	Customer 	9982665000	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:21:46.927156	6	2025-05-31 08:43:02.994951	
6337	Customer 	9828318344	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:31:20.619366	6	2025-05-31 08:43:02.994951	
6340	Customer 	9829069362	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:32:45.686778	6	2025-05-31 08:43:02.994951	
6341	Customer 	9829788888	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:33:09.231165	6	2025-05-31 08:43:02.994951	
6345	Customer 	9829205583	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:34:36.336847	6	2025-05-31 08:43:02.994951	
6346	Customer 	9829205583	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:34:38.507953	6	2025-05-31 08:43:02.994951	
6353	Customer 	9829107870	2025-07-16 10:00:00	Needs Followup		2025-04-19 11:47:26.923505	6	2025-05-31 08:43:02.994951	
6383	Customer 	9829055171	2025-07-16 10:00:00	Needs Followup		2025-04-20 07:41:43.119001	6	2025-05-31 08:43:02.994951	
6384	Customer 	9828158871	2025-07-16 10:00:00	Needs Followup		2025-04-20 07:42:51.587798	6	2025-05-31 08:43:02.994951	
6403	Customer 	9829011488	2025-07-16 10:00:00	Needs Followup		2025-04-21 06:02:19.072649	6	2025-05-31 08:43:02.994951	
6407	Customer 	9828788888	2025-07-16 10:00:00	Needs Followup		2025-04-21 06:44:01.723706	6	2025-05-31 08:43:02.994951	
6409	Customer 	9351690660	2025-07-16 10:00:00	Needs Followup		2025-04-21 06:45:28.557856	6	2025-05-31 08:43:02.994951	
6410	Customer 	9351690660	2025-07-16 10:00:00	Needs Followup		2025-04-21 06:45:29.520771	6	2025-05-31 08:43:02.994951	
6413	Customer 	9829011642	2025-07-16 10:00:00	Needs Followup		2025-04-21 06:48:00.232747	6	2025-05-31 08:43:02.994951	
6416	Customer 	9829010046	2025-07-16 10:00:00	Needs Followup		2025-04-21 07:10:50.529209	6	2025-05-31 08:43:02.994951	
6417	Customer 	9414949149	2025-07-16 10:00:00	Needs Followup		2025-04-21 07:13:14.181321	6	2025-05-31 08:43:02.994951	
6476	Customer 	9829157089	2025-07-16 10:00:00	Needs Followup	Verna \r\nCreta \r\nI 10	2025-04-21 11:31:44.008972	6	2025-05-31 08:43:02.994951	
6477	Customer 	9829006085	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:32:13.645815	6	2025-05-31 08:43:02.994951	
6480	Customer 	9024497772	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:33:56.796952	6	2025-05-31 08:43:02.994951	
6481	Customer 	9829051001	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:34:18.041151	6	2025-05-31 08:43:02.994951	
6483	Customer 	9829015800	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:35:12.083533	6	2025-05-31 08:43:02.994951	
6484	Customer 	9610160000	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:36:24.680452	6	2025-05-31 08:43:02.994951	
6485	Customer 	9829014742	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:36:48.803423	6	2025-05-31 08:43:02.994951	
6489	Customer 	9314139544	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:38:40.847499	6	2025-05-31 08:43:02.994951	
6493	Customer 	9828076488	2025-07-16 10:00:00	Needs Followup	Eco sports \r\nZen\r\n	2025-04-21 11:40:43.500489	6	2025-05-31 08:43:02.994951	
6496	Customer 	9828594555	2025-07-16 10:00:00	Needs Followup		2025-04-21 11:43:32.533985	6	2025-05-31 08:43:02.994951	
6503	Customer 	9314287443	2025-07-16 10:00:00	Needs Followup		2025-04-21 12:24:29.01419	6	2025-05-31 08:43:02.994951	
6504	Customer 	9414507365	2025-07-16 10:00:00	Needs Followup		2025-04-21 12:24:56.74932	6	2025-05-31 08:43:02.994951	
6505	Customer 	9314507781	2025-07-16 10:00:00	Needs Followup		2025-04-21 12:25:15.471955	6	2025-05-31 08:43:02.994951	
6510	Customer 	9001639636	2025-07-17 10:00:00	Needs Followup		2025-04-21 12:26:45.041715	4	2025-05-31 08:43:06.869056	
6511	Customer 	9314506613	2025-07-17 10:00:00	Needs Followup		2025-04-21 12:27:23.630356	4	2025-05-31 08:43:06.869056	
6512	Customer 	9829792851	2025-07-17 10:00:00	Needs Followup		2025-04-21 12:27:53.987567	4	2025-05-31 08:43:06.869056	
6528	Customer 	9828014013	2025-07-17 10:00:00	Needs Followup		2025-04-22 06:34:49.497134	4	2025-05-31 08:43:06.869056	
6529	Customer 	9414042256	2025-07-17 10:00:00	Needs Followup		2025-04-22 06:36:15.281267	4	2025-05-31 08:43:06.869056	
6530	Customer 	9828118214	2025-07-17 10:00:00	Needs Followup		2025-04-22 06:37:22.748061	4	2025-05-31 08:43:06.869056	
6532	Customer 	9829247641	2025-07-17 10:00:00	Needs Followup		2025-04-22 06:55:37.11609	4	2025-05-31 08:43:06.869056	
6536	Customer 	9829012133	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:07:14.556477	4	2025-05-31 08:43:06.869056	
6537	Customer 	9414326330	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:10:10.815099	4	2025-05-31 08:43:06.869056	
6539	Customer 	9414333339	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:25:30.883711	4	2025-05-31 08:43:06.869056	
6542	Customer 	9414056340	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:36:29.242091	4	2025-05-31 08:43:06.869056	
6547	Customer 	9829066125	2025-07-17 10:00:00	Needs Followup		2025-04-22 09:53:21.173527	4	2025-05-31 08:43:06.869056	
6566	Customer 	9829077143	2025-07-17 10:00:00	Needs Followup	Bhilwara 	2025-04-22 10:03:07.758844	4	2025-05-31 08:43:06.869056	
6570	Customer 	9829018088	2025-07-17 10:00:00	Needs Followup		2025-04-22 10:05:27.497811	4	2025-05-31 08:43:06.869056	
6585	Customer 	9314517737	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:07:24.253858	4	2025-05-31 08:43:06.869056	
6586	Customer 	9829014309	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:07:46.955318	4	2025-05-31 08:43:06.869056	
6587	Customer 	9460060787	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:08:08.074356	4	2025-05-31 08:43:06.869056	
6591	Customer 	9982004648	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:09:59.316564	4	2025-05-31 08:43:06.869056	
6592	Customer 	7665011133	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:10:45.456273	4	2025-05-31 08:43:06.869056	
6595	Customer 	9460149786	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:12:05.330977	4	2025-05-31 08:43:06.869056	
6339	Customer 	9314632176	2025-07-17 10:00:00	Needs Followup	Kia sonnet 3199\r\nDent paint 	2025-04-19 11:32:06.560009	4	2025-05-31 08:43:06.869056	
6495	Customer 	9829056582	2025-07-17 10:00:00	Needs Followup	I 10 \r\nCreta \r\nMust be looking for Dent paint as well as ac service 	2025-04-21 11:42:58.671648	4	2025-05-31 08:43:06.869056	
6538	Customer 	9414044873	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:15:05.177517	4	2025-05-31 08:43:06.869056	
6540	Customer 	9414038888	2025-07-17 10:00:00	Needs Followup		2025-04-22 07:27:47.573215	4	2025-05-31 08:43:06.869056	
6550	Customer 	9928957579	2025-07-17 10:00:00	Needs Followup		2025-04-22 09:54:48.814943	4	2025-05-31 08:43:06.869056	
6555	Customer 	9352744111	2025-07-17 10:00:00	Needs Followup		2025-04-22 09:57:46.88966	4	2025-05-31 08:43:06.869056	
6583	Customer 	9829066883	2025-07-17 10:00:00	Needs Followup		2025-04-22 12:06:27.683635	4	2025-05-31 08:43:06.869056	
7616	Cx2080	7976372378	2025-07-17 10:00:00	Needs Followup	Car service 	2025-05-30 10:21:34.090705	4	2025-05-31 08:43:06.869056	
6824	Caiz  3399	9024074340	2025-07-17 10:00:00	Needs Followup	Caiz service 3399\r\nSuspension work 	2025-05-01 08:29:04.682836	4	2025-05-31 08:43:06.869056	
6872	Kamal ji 	9929944244	2025-07-17 10:00:00	Needs Followup	Wr service 	2025-05-03 11:13:56.632284	4	2025-05-31 08:43:06.869056	
4252	Cx501	8290295780	2025-07-17 10:00:00	Needs Followup	Etios Dent paint 24000	2025-02-21 10:43:44.80181	4	2025-05-31 08:43:06.869056	
4488	Cx898	8171162201	2025-07-17 10:00:00	Needs Followup	Tiber dent paint \r\n2200	2025-03-03 06:15:16.399944	4	2025-05-31 08:43:06.869056	
4489	Cx899	9166806552	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-03 06:16:02.452395	4	2025-05-31 08:43:06.869056	
4490	Cx900	9667705694	2025-07-17 10:00:00	Needs Followup	Ac service \r\nAccent 	2025-03-03 06:19:17.451479	4	2025-05-31 08:43:06.869056	
4794	Cx638	9309253582	2025-07-17 10:00:00	Needs Followup	Ac service 	2025-03-16 11:31:17.776771	6	2025-05-31 08:43:06.869056	
4943	Cx519	9530065044	2025-07-17 10:00:00	Needs Followup	Car service \r\nTuv 	2025-03-22 10:29:35.473128	6	2025-05-31 08:43:06.869056	
5273	Cx571	8104417050	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-30 05:28:48.472089	6	2025-05-31 08:43:06.869056	
5276	Cx575	8560877861	2025-07-17 10:00:00	Needs Followup	Ac service \r\n	2025-03-30 05:30:02.695051	6	2025-05-31 08:43:06.869056	
5356	Duster 3999	9001601000	2025-07-17 10:00:00	Needs Followup	Duster 3999 service 	2025-03-31 06:31:48.57463	6	2025-05-31 08:43:06.869056	
5357	Cx582	8769941676	2025-07-17 10:00:00	Needs Followup	Alto service 	2025-03-31 06:32:27.432129	6	2025-05-31 08:43:06.869056	
5359	Cx 587	9414141991	2025-07-17 10:00:00	Needs Followup	Car service 	2025-03-31 06:33:53.297186	6	2025-05-31 08:43:06.869056	
5361	Cx 587	9950368339	2025-07-17 10:00:00	Needs Followup	Ac not working 	2025-03-31 06:35:10.665714	6	2025-05-31 08:43:06.869056	
6624	gaadimech 	9928182619	2025-07-17 10:00:00	Needs Followup	Alto 2299	2025-04-24 05:04:41.125329	6	2025-05-31 08:43:06.869056	
6856	gaadimech 	9921351960	2025-07-17 10:00:00	Needs Followup	Polo claim 	2025-05-03 05:33:10.488586	6	2025-05-31 08:43:06.869056	
6747	Civic 	7688979602	2025-07-17 10:00:00	Needs Followup	Car service 	2025-04-28 04:45:22.05367	6	2025-05-31 08:43:06.869056	
6927	gaadimech 8619279042	8094992866	2025-07-17 10:00:00	Needs Followup	Audi workshop visit 	2025-05-07 05:12:12.256915	6	2025-05-31 08:43:06.869056	
6914	gaadimech 	9829073343	2025-07-17 10:00:00	Needs Followup	Thar 5199	2025-05-05 12:07:16.514806	6	2025-05-31 08:43:06.869056	
6932	gaadimech 	7424946288	2025-07-17 10:00:00	Needs Followup	Wagnor  2399	2025-05-07 05:15:06.213073	6	2025-05-31 08:43:06.869056	
6657	Cx1132	8426977345	2025-07-18 10:00:00	Needs Followup	Ac service 	2025-04-25 10:17:18.229779	6	2025-05-31 08:43:10.854377	
6658	Cx1132	9015654181	2025-07-18 10:00:00	Needs Followup	Washing 	2025-04-25 10:17:52.55833	6	2025-05-31 08:43:10.854377	
6659	Cx1134	9829074365	2025-07-18 10:00:00	Needs Followup	Ac gas 	2025-04-25 10:18:18.482519	6	2025-05-31 08:43:10.854377	
6677	Cx1137	6367977994	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-25 11:15:35.856646	6	2025-05-31 08:43:10.854377	
6689	Cx1140	6367977994	2025-07-18 10:00:00	Needs Followup	Swift Dzire 2899\r\nNivai se	2025-04-25 12:16:53.151942	6	2025-05-31 08:43:10.854377	
6691	Cx1140	6377582392	2025-07-18 10:00:00	Needs Followup	Dent paint 	2025-04-26 04:47:40.271671	6	2025-05-31 08:43:10.854377	
6692	Cx1141	8504808138	2025-07-18 10:00:00	Needs Followup	Ac service 	2025-04-26 04:48:06.235942	6	2025-05-31 08:43:10.854377	
6694	Cx1141	9116464195	2025-07-18 10:00:00	Needs Followup	Car service  	2025-04-26 04:49:20.81151	6	2025-05-31 08:43:10.854377	
6696	Cx1143	7568120473	2025-07-18 10:00:00	Needs Followup	Tiber service 3599	2025-04-26 04:51:55.699329	6	2025-05-31 08:43:10.854377	
6697	Cx1145	9680163105	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-26 04:54:40.466006	6	2025-05-31 08:43:10.854377	
6698	Cx1145	8824218446	2025-07-18 10:00:00	Needs Followup	Voice call 	2025-04-26 04:55:27.59841	6	2025-05-31 08:43:10.854377	
6699	Cx1146	7073060433	2025-07-18 10:00:00	Needs Followup	Brezza 3499\r\nDent paint 	2025-04-26 04:56:27.357061	6	2025-05-31 08:43:10.854377	
6702	Cx1147	9928182619	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-26 04:58:35.91781	6	2025-05-31 08:43:10.854377	
6716	Cx1147	7877777090	2025-07-18 10:00:00	Needs Followup	Car dent 	2025-04-26 10:15:00.475298	6	2025-05-31 08:43:10.854377	
6717	Cx1147	9982814000	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-26 10:15:53.811985	6	2025-05-31 08:43:10.854377	
6740	Cx1149	9887333757	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-27 05:43:48.630161	6	2025-05-31 08:43:10.854377	
6743	Cx1146	9571862280	2025-07-18 10:00:00	Needs Followup	Car service 	2025-04-27 08:46:34.809291	6	2025-05-31 08:43:10.854377	
6886	Customer 	9314062144	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:22:43.099025	4	2025-05-31 08:43:14.897002	
6893	Customer 	9414046908	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:27:05.401482	4	2025-05-31 08:43:14.897002	
6874	Customer 	9414717916	2025-07-19 10:00:00	Needs Followup		2025-05-03 11:38:21.706928	4	2025-05-31 08:43:14.897002	
6879	Customer 	9829028841	2025-07-19 10:00:00	Needs Followup		2025-05-03 11:50:50.243441	4	2025-05-31 08:43:14.897002	
6885	Customer 	9829094348	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:22:17.209867	4	2025-05-31 08:43:14.897002	
6888	Customer 	9314505735	2025-07-19 10:00:00	Needs Followup	Verna	2025-05-03 12:23:36.439898	4	2025-05-31 08:43:14.897002	
6891	Customer 	9829533517	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:25:29.610146	4	2025-05-31 08:43:14.897002	
6892	Customer 	9828011585	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:26:10.327612	4	2025-05-31 08:43:14.897002	
6897	Customer 	9929089999	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:28:30.636911	4	2025-05-31 08:43:14.897002	
6938	Customer 	9829011667	2025-07-19 10:00:00	Needs Followup		2025-05-07 10:48:35.633865	4	2025-05-31 08:43:14.897002	
6970	Customer 	9414055184	2025-07-19 10:00:00	Needs Followup		2025-05-07 12:05:16.389286	4	2025-05-31 08:43:14.897002	
6878	Customer 	9829376667	2025-07-19 10:00:00	Needs Followup		2025-05-03 11:50:08.712448	6	2025-05-31 08:43:14.897002	
6894	Customer 	9829057101	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:27:23.686896	6	2025-05-31 08:43:14.897002	
6896	Customer 	9829061262	2025-07-19 10:00:00	Needs Followup		2025-05-03 12:28:12.946122	6	2025-05-31 08:43:14.897002	
6947	Customer 	9610530000	2025-07-19 10:00:00	Needs Followup		2025-05-07 10:57:22.810006	6	2025-05-31 08:43:14.897002	
6948	Customer 	9950158355	2025-07-19 10:00:00	Needs Followup		2025-05-07 10:58:00.675783	6	2025-05-31 08:43:14.897002	
6953	Customer 	9829061076	2025-07-19 10:00:00	Needs Followup	Safari 5999	2025-05-07 11:02:53.161251	6	2025-05-31 08:43:14.897002	
6957	Customer 	9829010081	2025-07-19 10:00:00	Needs Followup		2025-05-07 11:40:02.024081	6	2025-05-31 08:43:14.897002	
6958	Customer 	9829048887	2025-07-19 10:00:00	Needs Followup		2025-05-07 11:40:26.669472	6	2025-05-31 08:43:14.897002	
6960	Customer 	9829050589	2025-07-19 10:00:00	Needs Followup		2025-05-07 11:41:16.08647	6	2025-05-31 08:43:14.897002	
6961	Customer 	9829069569	2025-07-19 10:00:00	Needs Followup		2025-05-07 11:41:39.58319	6	2025-05-31 08:43:14.897002	
6972	Customer 	9829197170	2025-07-19 10:00:00	Needs Followup		2025-05-07 12:06:58.827332	6	2025-05-31 08:43:14.897002	
6973	Customer 	9314439933	2025-07-19 10:00:00	Needs Followup		2025-05-07 12:08:47.810093	6	2025-05-31 08:43:14.897002	
7641	gaadimech	9460593901	2025-07-29 10:00:00	Needs Followup	Amaze 3199	2025-05-31 08:37:02.25264	4	2025-05-31 08:43:55.621424	
61	Cx13	9351406543	2025-12-17 18:30:00	Needs Followup	Bumper paint Swift 2200\r\nService done other workshop 	2024-11-23 11:04:04	6	2025-06-01 11:21:17.901872	
2952	Cx 175	9982738292	2025-07-04 18:30:00	Needs Followup	Not from jaipur 	2025-01-13 04:34:12.585813	9	2025-07-06 10:22:33.805696	\N
7617	Cx2081	9672993434	2025-07-29 10:00:00	Needs Followup	Alto 800 glass change \r\n4 baje call	2025-05-30 10:22:11.099195	4	2025-05-31 08:43:55.621424	
3365	Wr	8824404572	2025-07-07 18:30:00	Confirmed	Not picking 	2025-01-24 08:53:51.25089	9	2025-07-01 09:09:16.889892	\N
3366	Swift 	8107779118	2025-10-17 18:30:00	Confirmed	service done  tonk road	2025-01-24 08:53:51.25089	9	2025-07-01 09:12:21.703419	\N
3367	Linea 	9251658942	2025-07-19 18:30:00	Confirmed	Not interested 	2025-01-24 08:53:51.25089	9	2025-07-01 09:14:06.196581	\N
3369	i10 silencer	9829120011	2025-07-08 18:30:00	Confirmed	Not picking 	2025-01-24 08:53:51.25089	9	2025-07-01 09:15:35.316398	\N
3370	Safari 	8290706269	2025-09-09 18:30:00	Confirmed	Service done in april	2025-01-24 08:53:51.25089	9	2025-07-01 09:18:33.119158	\N
3780	Cx257	7976625287	2025-07-24 18:30:00	Confirmed	Poor service review i10 	2025-02-06 08:20:15.28343	9	2025-07-01 09:28:15.994616	\N
3947	uday agarwal	9828676933	2025-07-27 18:30:00	Feedback	Not interested 	2025-02-11 06:35:19.320597	9	2025-07-01 09:29:42.962962	RJ45CU5796
3368	Honda jazz 	9828355915	2025-07-28 18:30:00	Confirmed	Honda jazz kuch problem hoga toh bta denge not any requirement 	2025-01-24 08:53:51.25089	9	2025-07-01 09:31:39.036664	
4020	Aman ji	7240070440	2025-07-16 18:30:00	Feedback	Not interested 	2025-02-13 11:45:13.613575	9	2025-07-01 09:33:26.674113	RJ19CJ0251
2825	Deepak	7791900400	2025-07-08 18:30:00	Confirmed	Not picking 	2025-01-11 04:14:05.019885	9	2025-07-01 09:36:52.044098	\N
3307	Cx211	7877799012	2025-07-09 18:30:00	Completed	Not picking 	2025-01-22 05:25:41.038653	9	2025-07-01 09:38:23.299091	
4019	Rajendra (Swift)	7734820041	2025-07-15 18:30:00	Feedback	Not picking 	2025-02-13 06:12:10.528296	9	2025-07-01 09:43:23.268042	RJ32CB0710
4149	Cx411	9783226865	2025-12-19 18:30:00	Feedback	Service done on 20 june 2025 swift Dzire 	2025-02-18 06:58:52.039798	9	2025-07-01 09:45:42.893799	RJ10CA2026
4689	manoj ji gaadimech 	9660738438	2025-07-29 18:30:00	Feedback	Datsun service 	2025-03-12 10:32:22.767691	9	2025-07-01 09:48:06.276493	RJ14UD8352
3532	Deepak	8529997152	2025-07-10 18:30:00	Feedback	Not picking 	2025-01-30 06:21:32.306288	9	2025-07-01 09:49:34.537514	RJ45CG7299
6200	gaadimech 	8233330471	2025-07-18 18:30:00	Did Not Pick Up	Polo dent paint \r\nCallcut	2025-04-17 08:39:44.338051	6	2025-06-30 09:26:53.112712	
4239	Prdeep 	8005620650	2025-07-23 18:30:00	Feedback	Not picking 	2025-02-19 11:31:49.876486	9	2025-07-01 09:54:07.015314	RJ42ZC8099
4241	Car lust 	7891120152	2025-07-22 18:30:00	Completed	Not picking 	2025-02-19 11:33:30.437778	9	2025-07-01 09:54:28.6958	RJ14TF6836
4242	Pankaj ji	9588936365	2025-07-14 18:30:00	Feedback	Service needed for alto and swift	2025-02-19 11:34:21.05159	9	2025-07-01 09:58:48.318531	
4348	Dileep ji aura 	9057943212	2025-07-10 18:30:00	Completed	Not picking 	2025-02-24 13:39:04.095636	9	2025-07-01 10:00:42.482789	
39	Mohammed Sharif	9314608689	2025-11-06 18:30:00	Confirmed	Nyi gaadi h toh service ki need nhi thi 	2024-11-23 10:02:54	9	2025-07-01 10:14:56.679515	\N
2875	Customer	8849137334	2025-12-15 18:30:00	Feedback	Gadi hi bech di 	2025-01-12 04:36:11.819946	9	2025-07-01 10:08:15.642976	
3207	Rajesh	8949982183	2025-11-19 18:30:00	Feedback	Not picking 	2025-01-20 04:31:19.397625	9	2025-07-04 05:31:25.130569	RJ14KC8718
31	.	8078680477	2025-12-11 18:30:00	Confirmed	Gadi hi nhi h 	2024-11-23 09:32:31	9	2025-07-01 10:12:30.944411	\N
3946	dhuruv 	9343212538	2025-07-30 18:30:00	Feedback	Not picking twice 	2025-02-11 06:31:29.412051	9	2025-07-06 06:48:24.796923	MP04CK0003
4349	Tarun ji Swift 	9828344200	2025-07-12 18:30:00	Completed	Swift Dzire Called Baad me dekhenge 	2025-02-24 13:39:49.02627	9	2025-07-01 10:03:08.526341	
1247	Avneet kour	9999905315	2025-07-07 18:30:00	Confirmed	Not picking 	2024-12-07 04:43:50	9	2025-07-01 10:18:51.712173	\N
3481	 Cx 2267	7014650488	2025-07-30 18:30:00	Confirmed	Not picking thrice 	2025-01-27 07:48:39.446419	9	2025-07-06 06:41:42.632885	
2777	Customer	6350288568	2025-07-23 18:30:00	Confirmed	Still Not picking 	2025-01-09 08:07:34.075518	9	2025-07-03 05:14:13.754878	\N
25	.	9414072257	2025-07-30 18:30:00	Feedback	Not picking 	2024-11-23 09:22:12	9	2025-07-05 07:56:52.90184	
3084	sonu	9680493633	2025-07-11 18:30:00	Feedback	Not picking 	2025-01-16 08:25:50.621567	9	2025-07-01 10:17:43.050806	
4184	Ritik 	8955458504	2025-08-12 18:30:00	Feedback	Not interested 	2025-02-18 10:06:34.60149	9	2025-07-05 08:06:58.8709	RJ14NC1503
4285	rahul choudhary	8239394331	2025-07-06 18:30:00	Confirmed	\tGrand i10 interested and coming on sat or sun.	2025-02-22 07:01:40.314481	9	2025-07-06 06:33:49.1173	RJ45CG5104
3669	kartavya 	9717030898	2025-07-30 18:30:00	Feedback	Not picking 	2025-02-04 06:34:09.222618	9	2025-07-05 07:43:13.072107	RJ14CB4528
5257	gaadimech 	9667424247	2025-07-18 18:30:00	Did Not Pick Up	Scorpio 5199 alwar\r\nNt pick	2025-03-29 05:42:27.535561	6	2025-06-30 09:27:47.924905	
4893	.	9829743431	2025-07-25 18:30:00	Needs Followup	Call cut	2025-03-20 12:16:50.581425	6	2025-06-30 09:33:22.528459	
4185	Vinod ji 	7665499600	2025-07-12 18:30:00	Feedback	Interested 	2025-02-18 10:07:49.299666	9	2025-07-01 10:30:56.231512	RJ10CB8308
3794	Cx266	7891440393	2025-07-07 00:00:00	Needs Followup	No answer 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	\N
4186	Amit ji 	9571118855	2025-07-17 18:30:00	Feedback	Not picking 	2025-02-18 10:08:43.010154	9	2025-07-01 10:32:21.661837	GJ23H4202
7748	gaadimech 	6375702080	2025-07-03 18:30:00	Did Not Pick Up	Not pick 	2025-06-29 06:00:14.348713	6	2025-07-02 10:20:21.402874	
349	Ashutosh ji	7488793853	2025-07-24 18:30:00	Feedback	Not interested 	2024-11-27 04:49:10	9	2025-07-01 10:36:03.5123	 RJ14ZC6669
3328	Ankit ji	8302260964	2025-07-26 18:30:00	Confirmed	Cutting the call not picking 	2025-01-23 06:14:00.724431	9	2025-07-02 04:15:52.493017	\N
4550	Figo 	8058444404	2025-12-26 18:30:00	Completed	Not interested 	2025-03-05 10:02:07.373097	9	2025-07-01 10:40:08.826042	
5195	ravi	9829121222	2025-09-05 18:30:00	Completed	Interested 	2025-03-28 08:01:21.310272	9	2025-07-01 10:41:57.522069	RJ14CX4336
3949	shubham	9079018309	2025-09-12 18:30:00	Feedback	Doing 	2025-02-11 08:37:00.273132	9	2025-07-01 10:44:28.414317	RJ60CA9279
4036	Rohit ji	8107300300	2025-10-07 18:30:00	Feedback	Not interested 	2025-02-15 08:23:03.978301	9	2025-07-01 10:46:18.997201	RJ45CE1973
4132	nikhil	9828803668	2025-07-17 18:30:00	Feedback	Not interested 	2025-02-16 12:13:29.785181	9	2025-07-01 10:51:30.018023	RJ45CX4851
3671	upendra	9911464775	2025-08-14 18:30:00	Feedback	Not picking 	2025-02-04 08:21:25.650869	9	2025-07-01 10:54:02.673147	HR26DD5225
7747	gaadimech 	7976191723	2025-07-03 18:30:00	Did Not Pick Up	Voice mail \r\nCall cut	2025-06-29 05:50:43.846567	6	2025-07-02 10:21:47.215703	
2573	Bhuvneshwar jangid 	9024165167	2025-09-24 18:30:00	Feedback	Service interested	2025-01-03 06:33:58.732764	9	2025-07-01 11:00:35.414307	
2576	Customer	9649331222	2025-07-06 18:30:00	Feedback	Not picking 	2025-01-03 06:33:58.732764	9	2025-07-01 11:13:18.89889	
2826	Ashish	8432375632	2025-07-24 18:30:00	Feedback	Not picking 	2025-01-11 04:14:05.019885	9	2025-07-01 11:14:41.533322	
2949	Bhardwaj ji	9314071092	2025-07-22 18:30:00	Feedback	Not picking 	2025-01-13 04:34:12.585813	9	2025-07-01 11:17:02.332285	
3016	Customer	7791801713	2025-07-13 18:30:00	Feedback	Not interested 	2025-01-13 09:02:24.989067	9	2025-07-01 11:17:19.390644	
3018	Customer	9351062701	2025-11-11 18:30:00	Feedback	Not interested 	2025-01-13 09:02:24.989067	9	2025-07-01 11:17:43.850358	
397	Manish sir 	9414612339	2025-07-21 18:30:00	Feedback	Not interested 	2024-11-27 11:01:48	9	2025-07-01 11:19:55.02698	
3059	sandeep	8005970370	2025-07-17 18:30:00	Feedback	Interested 	2025-01-16 04:14:34.232859	9	2025-07-01 11:27:51.569558	RJ25CA2666
3124	Lokesh	9818667188	2026-02-10 18:30:00	Confirmed	Servicing 	2025-01-18 08:45:20.427947	9	2025-07-01 11:29:20.226237	
3672	.	9742696444	2025-07-06 18:30:00	Feedback	Not picking 	2025-02-04 08:21:25.650869	9	2025-07-01 11:30:54.269089	
3725	Nitesh Sharma	7976462393	2026-01-22 18:30:00	Feedback	Not interested 	2025-02-05 07:07:42.885137	9	2025-07-01 11:32:11.992338	RJ14CY1167
4468	Dilip ji (amaze)	8094989888	2025-07-09 18:30:00	Completed	Not picking 	2025-03-02 06:56:45.393998	9	2025-07-01 11:33:13.809839	RJ45CE9370
5647	Rakshit ji	8740886522	2025-07-07 18:30:00	Completed	Not picking 	2025-04-08 05:23:28.318639	9	2025-07-01 11:35:04.226941	RJ52CA1252
3531	PS Jain	9414405948	2026-01-21 18:30:00	Feedback	Not interested 	2025-01-30 06:21:32.306288	9	2025-07-01 11:35:41.270107	RJ14XC5462
5830	RAM POONIA	6378413543	2026-02-25 18:30:00	Completed	Gadi nhi h 	2025-04-09 11:06:53.340291	9	2025-07-01 11:38:48.364642	RJ14CL7172
3717	somesh soni	9521890803	2025-07-13 18:30:00	Feedback	Not interested 	2025-02-05 04:25:05.267449	9	2025-07-01 11:44:10.138738	RJ45CT7037
3285	Ankit Ji 	9660085160	2025-07-09 18:30:00	Feedback	Interested 	2025-01-21 10:32:21.170778	9	2025-07-01 11:42:23.465801	RJ45UA0361
4464	Eon 	9929727221	2025-07-09 18:30:00	Completed	Safari not interested 	2025-03-02 06:19:34.485319	9	2025-07-03 05:45:24.12085	RJ14CX8269
5829	urvinder ji 	9810021056	2025-08-21 18:30:00	Completed	Not interested 	2025-04-09 11:05:56.541061	9	2025-07-01 11:37:11.008407	HR26CD0855
4551	NISHKAM JI 	9828355915	2025-08-12 18:30:00	Completed	Not interested 	2025-03-05 12:05:10.797003	9	2025-07-01 11:35:59.670003	RJ14QC2675
4632	Carens 3199	9784137284	2025-11-08 18:30:00	Completed	Gadi sell krdi 	2025-03-10 10:38:09.159595	9	2025-07-01 11:45:15.202084	
4644	Cx551	9799978077	2025-07-14 18:30:00	Completed	Not picking 	2025-03-11 05:19:22.901936	9	2025-07-01 11:47:13.660475	
3313	Customer 	9928102346	2025-07-12 18:30:00	Feedback	Not picking 	2025-01-22 05:25:41.038653	9	2025-07-02 04:08:56.360617	
5468	gaadimech 	7300004548	2025-07-27 18:30:00	Feedback	Not picking 	2025-04-02 09:02:03.300553	9	2025-07-02 04:14:27.601978	DL10CT9098
3487	Gulab ji	8200940732	2025-12-26 18:30:00	Feedback	total loss	2025-01-28 04:58:56.197876	9	2025-07-01 08:24:56.7306	RJ14CK2406
7724	gaadimech 	9509777321	2025-07-05 18:30:00	Did Not Pick Up	Baleno 2799	2025-06-28 11:20:56.920752	6	2025-07-02 10:47:57.734183	
6108	gulfam gaadimech 	8107211492	2025-07-10 18:30:00	Feedback	Not interested 	2025-04-16 07:46:32.582175	9	2025-07-03 05:20:23.331553	RJ14TG1492
3593	deepak Kumar saini	9358942722	2025-07-17 18:30:00	Feedback	Not picking 	2025-02-01 04:09:42.798808	9	2025-07-02 04:38:24.364432	RJ14CU8110
7750	gaadiemch	7300062403	2025-07-02 18:30:00	Did Not Pick Up	Scorpio S11 5199 jagatpura	2025-06-29 06:16:50.990604	6	2025-06-30 07:18:38.3515	
7749	gaadimech 	9988799241	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-06-29 06:15:42.910447	6	2025-06-30 07:20:24.278146	
5023	gaadimech 	9250257052	2025-07-18 18:30:00	Did Not Pick Up	Swlift 2799 self visit krenge \r\nNot interested 	2025-03-25 04:54:08.223202	6	2025-06-30 09:32:17.496595	
4723	.	9314284515	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-03-13 11:02:44.600877	6	2025-06-30 09:40:26.544287	
4209	.	6376258580	2025-07-02 18:30:00	Did Not Pick Up	Dzire 2999\r\nErtiga 3399\r\nScorpio 5199 jagatpura 	2025-02-18 11:58:37.525635	6	2025-06-30 09:46:10.562109	
2659	Customer	7983099570	2025-07-01 18:30:00	Needs Followup	Seltos 3999 package\r\nCall cut 	2025-01-08 04:05:57.844174	4	2025-06-30 09:48:47.903686	
4663	Sweety ji (polo)	8005564189	2025-07-20 18:30:00	Completed	Not interested 	2025-03-11 08:15:57.392156	9	2025-07-01 11:52:01.964884	
5571	Executive chairman 	7976329640	2025-07-16 18:30:00	Feedback	Not picking 	2025-04-07 08:43:14.181959	9	2025-07-01 11:53:13.026682	
3480	Kishan Gurjar	7014650488	2025-07-19 18:30:00	Feedback	Not picking 	2025-01-27 07:48:39.446419	9	2025-07-01 11:53:34.225339	RJ11TA1089
3591	Abhinav ji	9911095813	2025-07-23 18:30:00	Feedback	Not picking 	2025-02-01 04:09:42.798808	9	2025-07-01 11:54:21.56052	UP13BD8936
3804	vinit	8005632905	2025-07-30 18:30:00	Feedback	Honda Amaze not picking 	2025-02-07 04:30:18.562584	9	2025-07-04 06:26:59.331089	RJ14CT9057
4481	Sanja ji 	8561007733	2025-07-12 18:30:00	Completed	Not picking 	2025-03-03 05:58:08.50167	9	2025-07-01 12:05:10.706595	
4631	i10 old 	6350041766	2025-07-17 18:30:00	Completed	Not picking 	2025-03-10 10:36:53.669979	9	2025-07-01 12:10:45.758909	
4711	i10 	8561007733	2025-07-07 18:30:00	Confirmed	Not picking 	2025-03-13 08:34:03.285505	9	2025-07-01 12:13:00.61552	
4787	Tigor 2699	9887965010	2025-07-06 18:30:00	Completed	Not picking 	2025-03-16 11:10:51.291429	9	2025-07-01 12:17:51.132556	
5648	Rohan ji	8003774288	2025-11-19 18:30:00	Feedback	Service done	2025-04-08 05:27:32.774184	9	2025-07-01 12:18:49.351741	RJ14CP8241
5833	Shyam Arora 	9413397022	2025-07-10 18:30:00	Completed	Not picking 	2025-04-11 04:54:48.430705	9	2025-07-01 12:19:36.826676	RJ13CA4132
5884	shariq	9560603181	2025-07-12 18:30:00	Completed	Not picking 	2025-04-13 09:34:36.840425	9	2025-07-01 12:20:25.286798	DL9CBC5753
5567	gaadimech	8505050740	2025-07-02 18:30:00	Did Not Pick Up	Eon not pick 	2025-04-07 07:33:19.331059	6	2025-06-28 08:06:34.827244	
5222	gaadimech 	7339749299	2025-07-24 18:30:00	Did Not Pick Up	Dzire 2799 call cut	2025-03-28 09:14:29.268697	6	2025-06-28 08:08:53.710165	
3781	Cx257	7567979358	2025-07-06 18:30:00	Feedback	Isuzu d max 5199 service interested 	2025-02-06 08:20:15.28343	9	2025-07-03 05:44:10.821783	
4962	gaadimech 	7023258754	2025-07-25 18:30:00	Did Not Pick Up	Not pick \r\nBy mistak inquiry ki hai 	2025-03-24 04:43:17.197679	6	2025-06-28 10:26:28.856122	
4922	gaadimech	9571791192	2025-07-18 18:30:00	Needs Followup	Not pick \r\nCall cut	2025-03-21 08:19:18.96655	6	2025-06-28 10:28:07.047977	
4894	customer 	9636039721	2025-07-06 18:30:00	Did Not Pick Up	I20 ac check up\r\nCall cut not interested \r\nCall cut	2025-03-20 12:20:34.963211	6	2025-06-28 10:34:57.777473	
5470	Gajendra ji 	7014410715	2025-11-19 18:30:00	Feedback	Not interested 	2025-04-02 09:11:50.583585	9	2025-07-01 12:24:07.558406	RJ14NC9892
2888	Customer	7610972462	2025-07-16 18:30:00	Confirmed	Not picking 	2025-01-12 04:36:11.819946	9	2025-07-01 12:24:43.077319	
3251	VIKAS JI 	8290308273	2025-07-24 18:30:00	Feedback	Not interested 	2025-01-20 04:31:19.397625	9	2025-07-01 12:27:06.239885	HR821003
3598	shweta ji	9828555544	2025-07-13 18:30:00	Feedback	Not picking 	2025-02-01 04:09:42.798808	9	2025-07-01 12:28:14.512167	
3778	rahul ji	8952861361	2025-07-18 18:30:00	Feedback	Not interested 	2025-02-06 04:15:16.210235	9	2025-07-01 12:29:06.545408	RJ14CM3189
3063	manoj ji	9694002677	2025-08-06 18:30:00	Confirmed	Interested 	2025-01-16 04:14:34.232859	9	2025-07-01 12:41:23.510658	RJ45CP9269
1466	Pc jain	9414405948	2025-08-27 18:30:00	Feedback	Not interested 	2024-12-08 08:15:33	9	2025-07-01 12:31:22.229541	
4864	shuruti jain	9116078388	2025-10-15 18:30:00	Feedback	Do not have car	2025-03-19 09:28:45.917028	9	2025-07-01 12:30:57.212839	RJ14CY9792
4812	gaadimech	9785775527	2025-07-01 18:30:00	Needs Followup	Dosa se hu	2025-03-18 04:28:34.778346	4	2025-07-02 07:05:30.221441	
3558	Anil kumar	9672492289	2025-07-10 18:30:00	Feedback	Not picking 	2025-01-31 08:47:45.318294	9	2025-07-02 04:27:14.633682	RJ45CX8412
5020	gaadimech 	8094566600	2025-12-19 18:30:00	Feedback	Innova service call	2025-03-25 04:38:14.702722	9	2025-07-04 05:32:59.823181	RJ14TD0072
7420	gaadimech 	9314510146	2025-07-11 18:30:00	Did Not Pick Up	Amaze 3199\r\nNot pick 	2025-05-23 06:58:02.477802	6	2025-07-02 10:55:55.488185	
4949	ivr	9414072400	2025-07-24 18:30:00	Did Not Pick Up	Polo 2999	2025-03-23 05:05:52.258818	6	2025-07-02 10:59:53.467978	
3948	manish	9351290020	2025-07-30 18:30:00	Feedback	Not picking twice 	2025-02-11 06:37:50.305369	9	2025-07-05 08:00:11.438892	RJ14CX7205
4712	Figo ( RAHUL JI) 	7339856566	2025-07-07 18:30:00	Confirmed	\tFord figo confirmed tommorrow	2025-03-13 08:35:39.317054	9	2025-07-06 09:41:53.227059	RJ07CB7524
3407	mannu ji	9462575853	2025-07-30 18:30:00	Feedback	Not picking 	2025-01-26 08:47:16.296997	9	2025-07-05 07:42:11.687464	RJ14WC8595
4205	.	9829014029	2025-07-06 18:30:00	Did Not Pick Up	Not pick 	2025-02-18 11:49:39.838425	6	2025-06-29 06:59:07.106396	
2369	.	9829480001	2025-07-30 18:30:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-22 08:06:41.389566	6	2025-06-29 07:01:24.389499	
4265	.	6377907513	2025-07-04 18:30:00	Did Not Pick Up	Alto dent paint 	2025-02-22 04:18:25.99402	6	2025-06-30 09:41:27.505887	
4021	Arvind 	7014794308	2025-10-09 18:30:00	Feedback	Service done happy customer 	2025-02-14 06:45:39.848806	9	2025-07-02 04:55:11.526414	RJ14ZC9214
2395	.	9414606315	2025-07-01 18:30:00	Needs Followup	Cut call 	2024-12-23 04:37:08.828595	4	2025-06-30 09:55:15.622531	
4177	RITESH 	9783226865	2025-12-23 18:30:00	Feedback	Service done happy customer 	2025-02-18 09:56:21.716824	9	2025-07-02 04:59:42.276992	RJ10CA2026
4244	Raghuraj	9829009462	2025-09-19 18:30:00	Feedback	Not have car in jaipur 	2025-02-20 04:36:45.329706	9	2025-07-02 05:16:03.549982	MP06CA5299
4278	Nachiket Shah	9784073139	2025-07-06 18:30:00	Feedback	Not picking 	2025-02-22 05:43:57.857894	9	2025-07-02 05:17:26.974015	RJ45CX4851
4284	chintu permar	6398599073	2025-09-24 18:30:00	Feedback	Not in jaipur 	2025-02-22 06:06:29.110662	9	2025-07-02 05:19:50.404981	HR05AM2550
4302	raj kamal	9828020888	2025-07-28 18:30:00	Feedback	Not interested 	2025-02-22 11:50:33.817855	9	2025-07-02 05:21:47.679055	RJ14AC1504
4232	nikki	9166101962	2025-07-08 18:30:00	Feedback	Ertiga etios diesel not picking 	2025-02-19 05:25:26.334887	9	2025-07-04 06:25:07.717633	RJ14TD4085
4357	deepak	9887797305	2025-09-02 18:30:00	Feedback	Not required 	2025-02-25 05:21:59.521061	9	2025-07-02 05:35:36.893072	RJ14CB3729
4383	akhil ji	9352360784	2025-07-12 18:30:00	Feedback	Not picking 	2025-02-25 11:32:17.103802	9	2025-07-02 05:36:57.349645	RJ19CE7790
4552	ishan	9887334488	2025-08-11 18:30:00	Feedback	Not interested 	2025-03-07 05:37:45.841369	9	2025-07-02 05:38:19.008357	
4599	Madhukar ji	9414055369	2025-07-15 18:30:00	Feedback	Not picking 	2025-03-08 06:12:17.124163	9	2025-07-02 05:47:37.653365	RJ45CG5205
4674	gaadimech 	6378023022	2025-07-15 18:30:00	Feedback	Phone switched off tha	2025-03-12 04:23:54.094622	9	2025-07-02 06:00:02.923842	
1303	Nikhil jain	8095045079	2025-07-17 18:30:00	Feedback	Not picking 	2024-12-07 05:46:09	9	2025-07-02 06:06:08.430077	
3799	Dinesh ji	7597670534	2025-07-20 18:30:00	Feedback	Not picking 	2025-02-07 04:30:18.562584	9	2025-07-02 06:08:39.467476	RJ14UH4114
4002	Samay 	8826623406	2025-07-21 18:30:00	Feedback	Switched off 	2025-02-12 10:57:07.881387	9	2025-07-02 06:09:47.916996	RJ01CB4081
4936	Rohit ji	8107300300	2025-10-19 18:30:00	Feedback	Interested 	2025-03-22 07:31:29.394144	9	2025-07-02 06:11:36.37545	RJ45CE1973
4947	Dhiraj vijayvargiye	9928221100	2025-11-20 18:30:00	Feedback	Not required 	2025-03-22 12:31:19.922811	9	2025-07-02 06:13:39.471663	RJ45CE0039
5081	kishor singh	9828023888	2025-08-18 18:30:00	Feedback	Not picking 	2025-03-26 07:02:38.756598	9	2025-07-02 06:16:03.185404	RJ14UC9435
4596	karan mathur gaadimech 	8529401689	2025-07-07 18:30:00	Confirmed	Etios verna and innova all are in Diesel Must call service needed not picking on 06 jul	2025-03-08 05:57:07.017689	9	2025-07-06 06:37:36.635644	
5657	 nitin gaadimech 	9649446220	2025-07-12 18:30:00	Feedback	Not picking 	2025-04-08 07:38:50.199338	9	2025-07-02 06:26:55.529401	RJ45CX7745
5845	Sita Ram Ji 	7568880962	2025-10-20 18:30:00	Feedback	Not interested 	2025-04-12 05:03:53.653618	9	2025-07-02 06:28:27.490858	RJ14CH3357
5869	Adhips	9024865114	2025-07-27 18:30:00	Feedback	Not picking 	2025-04-12 10:47:16.757845	9	2025-07-02 06:29:18.420777	RJ19CH3337
6275	gaadimech 	9314722665	2025-07-13 18:30:00	Feedback	Not picking 	2025-04-18 05:11:24.190513	9	2025-07-02 06:30:57.081589	
5645	Cris pharma india ltd	9314513730	2025-11-20 18:30:00	Feedback	Service done 	2025-04-08 05:21:48.853359	9	2025-07-02 06:51:32.153925	RJ14CR2634
4935	RAJ JI 	9828139100	2025-11-19 18:30:00	Feedback	Ajmer se h nhi aa skte 	2025-03-22 07:30:09.012254	9	2025-07-02 07:08:00.935427	RJ01CA9291
4340	SIDDHARTH JI 	9685985092	2025-11-20 18:30:00	Open	Zen altis service 	2025-02-24 07:20:54.672931	9	2025-07-04 06:22:59.867171	RJ08CA0571
4925	mubeen khan	7014540432	2025-07-12 18:30:00	Feedback	Not picking 	2025-03-21 11:26:48.023838	9	2025-07-02 07:04:33.771608	RJ14TG0331
4857	deepak joshi	9828161208	2025-07-09 18:30:00	Feedback	Bumperr scratch complaint through the drop service 	2025-03-19 06:39:04.645955	9	2025-07-02 07:03:12.886364	RJ45CP8340
5363	Anupam sharma 	7877675673	2025-09-13 18:30:00	Confirmed	Thar needs follow up	2025-03-31 07:48:10.388578	9	2025-07-02 11:49:58.114736	RJ23UB0340
4960	Anshul ( Altroz) 	9829043735	2025-07-20 18:30:00	Feedback	Not picking 	2025-03-23 11:56:45.258926	9	2025-07-02 07:09:28.919936	RJ60CA7394
4601	Nathmal	9530028021	2025-08-07 18:30:00	Feedback	Bill dropped connect for service 	2025-03-08 06:44:44.696021	9	2025-07-02 07:02:16.567022	RJ45CG2171
4664	gaadimech	7568768625	2025-09-13 18:30:00	Feedback	Swift Service need	2025-03-11 08:18:20.831659	9	2025-07-02 11:50:58.270583	
5033	RAM SINGH	8529070202	2025-11-29 18:30:00	Confirmed	Ertiga service required 	2025-03-25 06:33:35.597622	9	2025-07-03 08:21:43.672815	HR55AN0362
5034	Ravinder ji ( Vento) 	9950066469	2025-09-30 18:30:00	Feedback	Vento service needed in October 	2025-03-25 06:34:54.485232	9	2025-07-02 07:17:07.259738	RJ14CX2610
5142	Customer 	9588239839	2025-07-18 18:30:00	Did Not Pick Up	Not pick	2025-03-27 07:10:17.869812	6	2025-06-30 09:31:28.671511	
5271	rohit gaadiemch 	9521088202	2025-08-31 18:30:00	Feedback	Alto need service 	2025-03-30 04:47:52.143228	9	2025-07-02 07:21:10.425348	RJ45CU1870
7699	Cx3081	9636798623	2025-07-02 18:30:00	Needs Followup	Marazzo \r\nAc problem 	2025-06-28 05:59:51.032637	4	2025-07-02 06:59:59.558993	
4862	ajay patil	9828557751	2025-07-08 18:30:00	Feedback	Not picking 	2025-03-19 07:39:22.366439	9	2025-07-03 05:29:19.188622	RJ14AC1302
2299	.	9314446600	2025-07-02 18:30:00	Needs Followup	Abhi nahi	2024-12-21 08:31:22.208151	4	2025-06-29 07:18:12.277235	
4046	.	9829055399	2025-07-07 18:30:00	Did Not Pick Up	Not pick 	2025-02-15 10:01:17.601909	6	2025-06-30 09:56:55.588912	
3720	.	9887926962	2025-07-30 18:30:00	Needs Followup	Honda city 2999 till service done\r\nNot interested 	2025-02-05 07:07:42.885137	6	2025-06-30 10:17:40.05545	
3796	Cx267	7983879383	2025-07-07 00:00:00	Needs Followup	No 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	\N
5280	ashok ji	8949208045	2025-09-05 18:30:00	Feedback	Service needed swift	2025-03-30 06:38:10.652816	9	2025-07-02 07:22:53.814281	RJ45CG5825
5282	Manish Choudhary 	8619150569	2025-07-17 18:30:00	Feedback	Not picking 	2025-03-30 06:54:04.761571	9	2025-07-02 07:24:12.39551	RJ45CX7773
5469	vinod ji	9413162982	2025-09-18 18:30:00	Feedback	service eon and grand vitara\n	2025-04-02 09:10:35.351814	9	2025-07-02 07:30:58.065435	RJ14CW6039
5658	gaadimech	9414077509	2025-07-22 18:30:00	Feedback	Not picking 	2025-04-08 10:37:44.59679	9	2025-07-02 07:33:07.921437	RJ14CR5239
5865	Aadil Pathan 	7229909965	2025-07-15 18:30:00	Feedback	Not picking 	2025-04-12 09:51:11.319873	9	2025-07-02 07:34:56.86516	RJ45CT9148
5874	gaadimech 	9875202098	2025-07-20 18:30:00	Feedback	Not picking 	2025-04-13 06:29:50.595016	9	2025-07-02 07:36:08.450079	RJ14CG0706
6752	mahaveer ji	9414572700	2025-08-26 18:30:00	Feedback	Not interested 	2025-04-28 05:01:56.869252	9	2025-07-02 07:37:22.09662	RJ06UB3975
6703	Cc1147	9509217703	2025-07-24 18:30:00	Completed	Not picking 	2025-04-26 04:59:05.081534	9	2025-07-02 07:38:43.212452	
6934	Cx1164	7424946288	2025-11-29 18:30:00	Confirmed	Not interested complaining 	2025-05-07 05:40:28.943162	9	2025-07-02 07:42:25.364331	
7176	Ignis 	9828056904	2025-07-10 18:30:00	Confirmed	Not picking 	2025-05-14 07:16:54.075195	9	2025-07-02 07:43:56.787983	
7100	Devanand sharma ji 	8058258160	2025-12-18 18:30:00	Confirmed	not in service	2025-05-11 07:05:00.524511	9	2025-07-02 07:48:17.9845	
4246	amar Chand ji  9413563024	6350597484	2025-08-12 18:30:00	Feedback	Eon Service coolant chng	2025-02-20 05:30:38.272777	9	2025-07-02 07:53:33.951963	RJ14CY1704
4339	shahrukh	9001919197	2025-08-26 18:30:00	Feedback	Verna service 	2025-02-24 05:42:20.945099	9	2025-07-02 07:59:59.747806	RJ14CT4725
4427	rajesh ji	8949982183	2025-07-12 18:30:00	Feedback	Not picking 	2025-02-27 11:32:49.032815	9	2025-07-02 08:01:22.000772	RJ148C8718
4610	gaadimech	9828159466	2025-07-17 18:30:00	Feedback	Ritz interested 	2025-03-08 09:41:58.57474	9	2025-07-02 08:04:29.767917	
4668	bharat 	9829200060	2025-07-22 18:30:00	Feedback	Not picking 	2025-03-11 12:09:13.579851	9	2025-07-02 08:05:52.965554	RJ14CG7090
4865	abhinav	7976041348	2025-11-16 18:30:00	Feedback	Amaze Interested 	2025-03-19 09:31:44.500676	9	2025-07-02 08:10:57.081963	RJ45CF9549
4866	Vaid Ji 	8963803593	2025-07-14 18:30:00	Feedback	Not picking 	2025-03-19 10:04:49.500674	9	2025-07-02 08:13:40.833854	23BH0206C
5220	gaadiemch 	9772214200	2025-08-08 18:30:00	Did Not Pick Up	Sonet 3199	2025-03-28 09:11:10.78071	6	2025-06-28 08:10:08.934082	
5141	Customer 	9588239839	2025-07-04 18:30:00	Needs Followup	Call cut	2025-03-27 07:10:08.726215	6	2025-06-28 08:24:04.774498	
5136	Customer 	8451941616	2025-07-03 18:30:00	Did Not Pick Up	Not pick 	2025-03-27 06:53:04.13291	6	2025-06-28 08:29:43.182956	
5127	gaadimech	9828531393	2025-07-10 18:30:00	Did Not Pick Up	Eon 2299 \r\nNot pick 	2025-03-27 05:36:03.652103	6	2025-06-28 08:30:38.553327	
4906	gaadimech 	9549007855	2025-07-10 18:30:00	Needs Followup	Ertiga 3399\r\nCall cut	2025-03-21 05:45:52.554073	6	2025-06-28 10:32:28.983344	
4899	gaadimech	7878612096	2025-07-11 18:30:00	Needs Followup	Swift ac checkup \r\nSwitch off 	2025-03-21 04:27:20.435191	6	2025-06-28 10:33:15.142144	
4896	.	8368489575	2025-07-17 18:30:00	Did Not Pick Up	Not pick \r\nCall cut	2025-03-20 12:23:49.177336	6	2025-06-28 10:34:10.250898	
4128	.	9828505433	2025-07-03 18:30:00	Needs Followup	Abhi nahi karwani	2025-02-16 12:04:54.800522	4	2025-06-28 10:47:40.316805	
4926	Giraj ji	9116114331	2025-11-26 18:30:00	Feedback	Amaze not interested 	2025-03-21 11:47:34.914037	9	2025-07-04 06:28:46.47608	RJ14WC8548
4973	NARPAT SINGH SHEKHAWAT 	7357312932	2025-07-22 18:30:00	Feedback	Not interested 	2025-03-24 06:45:02.126272	9	2025-07-02 09:07:35.152592	RJ14XC5452
5014	gaadimech	9982038183	2025-07-14 18:30:00	Feedback	Not picking 	2025-03-24 10:38:22.837963	9	2025-07-02 09:08:32.343378	
5518	kamal ji gaadimech 	9929944244	2025-11-09 18:30:00	Feedback	Wagon r Service 	2025-04-03 04:57:05.888852	9	2025-07-02 09:11:31.47298	RJ14CF5149
5526	gaadimech 9352999904	9782753873	2025-12-12 18:30:00	Feedback	Baleno service 	2025-04-03 07:59:29.144201	9	2025-07-02 09:14:07.379716	RJ45CE5172
5525	gaadimech 	8003005333	2025-11-23 18:30:00	Feedback	Dzire service 	2025-04-03 07:56:30.599167	9	2025-07-02 09:12:38.190801	DL6CP2153
5132	Vijay pareek ( Eon) 	9928853672	2025-07-15 18:30:00	Feedback	Not picking 	2025-03-27 06:01:15.518216	9	2025-07-02 09:09:43.557803	RJ14CT8173
7700	gaadimech 	9309397093	2025-07-11 18:30:00	Did Not Pick Up	Swift ac	2025-06-28 05:59:58.381094	6	2025-07-02 10:52:45.662972	
7697	gaadimech 	9680498073	2025-07-06 18:30:00	Did Not Pick Up	Dzire 2999	2025-06-28 05:59:08.704881	6	2025-07-02 10:53:55.713708	
4957	gaadimech	8058141143	2025-12-22 18:30:00	Confirmed	Nexon Service,	2025-03-23 08:39:30.885462	9	2025-07-02 11:58:10.720565	RJ45CH1844
2344	.	9950501808	2025-07-25 18:30:00	Needs Followup	Cut a call\r\nNot interested 	2024-12-22 05:49:31.118194	6	2025-06-29 07:34:50.667164	
5655	Aashish Ji	9928403442	2025-07-08 18:30:00	Feedback	Not picking 	2025-04-08 07:26:58.84203	9	2025-07-02 09:15:40.533523	RJ45CX6664
4028	.	9829189656	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-02-15 07:43:11.337256	6	2025-06-30 09:58:59.279713	
2428	.	9024183599	2025-07-18 18:30:00	Did Not Pick Up	Cut a call 	2024-12-23 08:16:54.59051	6	2025-06-30 10:23:53.472661	
5743	naresh jigaadimech 	9829186130	2025-07-12 18:30:00	Feedback	Alto service not picking 	2025-04-09 04:30:05.865699	9	2025-07-02 09:17:22.054134	RJ45CH8307
5862	 Ramesh gaadiemch 	7726999564	2025-07-11 18:30:00	Feedback	Not picking 	2025-04-12 09:49:04.584312	9	2025-07-02 09:19:23.742235	RJ14LC0218
5873	chakdhar pandey	9621474749	2025-09-15 18:30:00	Feedback	I10 Service 	2025-04-13 06:28:54.997463	9	2025-07-02 09:23:47.275468	RJ14CU7036
5885	Sk mathur ji	9935723125	2025-07-22 18:30:00	Feedback	Not picking 	2025-04-13 09:38:12.265151	9	2025-07-02 09:25:01.453115	RJ23CD6067
6278	Ravi kala gaadimech 	7665460306	2025-07-28 18:30:00	Feedback	Not picking 	2025-04-18 05:12:51.543415	9	2025-07-02 09:26:11.094983	RJ01UC2711
6281	gaadimech 	9828023233	2025-07-10 18:30:00	Feedback	Not picking 	2025-04-18 05:15:17.705903	9	2025-07-02 09:28:07.480148	RJ60Ca1833
6318	gaadimech 	7688849485	2025-07-17 18:30:00	Feedback	Brezza Not interested 	2025-04-19 11:04:37.440863	9	2025-07-02 09:29:55.978299	RJ45CQ5113
6707	gaadimech 	8426977345	2025-07-20 18:30:00	Feedback	Not picking 	2025-04-26 05:31:22.382433	9	2025-07-02 09:32:24.181539	
6750	gaadimech 	9887770016	2025-11-07 18:30:00	Feedback	Breeza service 	2025-04-28 04:59:45.987831	9	2025-07-02 09:34:20.157994	RJ14 Y5345
7645	Sanjay ji 	9024386980	2025-07-12 18:30:00	Open	Not picking 	2025-05-31 09:57:21.257906	9	2025-07-02 09:35:31.34356	
2934	Customer	9928172624	2025-07-27 18:30:00	Did Not Pick Up	Not picking 	2025-01-12 04:36:11.819946	9	2025-07-02 09:37:07.865376	\N
7651	pawan gaadimech	8005542433	2025-07-23 18:30:00	Open	Not picking 	2025-06-01 04:32:19.672467	9	2025-07-02 09:37:54.684465	
235	Cx41	7412843481	2026-01-10 18:30:00	Needs Followup	Do not have car 	2024-11-25 07:35:35	9	2025-07-02 09:39:25.498124	\N
275	Cx50	9887807161	2025-11-12 18:30:00	Needs Followup	I20Not required 	2024-11-25 12:00:32	9	2025-07-02 09:40:37.68631	\N
281	Cx56	9928965032	2025-07-18 18:30:00	Needs Followup	Not picking 	2024-11-25 12:12:18	9	2025-07-02 09:42:20.955236	\N
294	Cx62	9079184418	2025-08-07 18:30:00	Needs Followup	Not picking 	2024-11-26 08:11:38	9	2025-07-02 09:43:45.350275	\N
348	Test User for Timestamp	9999999999	2026-02-12 18:30:00	Needs Followup	Test user	2024-11-26 16:51:03	9	2025-07-02 09:45:02.583864	\N
424	Cx78	7229955691	2025-10-22 18:30:00	Needs Followup	Invalid no.	2024-11-27 11:01:48	9	2025-07-02 09:45:35.047565	\N
426	Time Test	9999999999	2026-02-13 18:30:00	Needs Followup	Test user	2024-11-27 16:20:25	9	2025-07-02 09:45:51.772197	\N
615	Cx85	9785291939	2025-07-20 18:30:00	Needs Followup	Not picking 	2024-11-30 09:37:30	9	2025-07-02 09:47:08.961808	\N
618	Cx87	8955458504	2025-07-17 18:30:00	Needs Followup	Not picking 	2024-11-30 09:37:30	9	2025-07-02 09:48:09.420341	\N
624	Cx87 ,	9660046700	2025-07-30 18:30:00	Needs Followup	no answer\n	2024-11-30 09:37:30	9	2025-07-02 09:49:27.385049	\N
626	Cx88	9828546860	2025-08-12 18:30:00	Needs Followup	Polo service 	2024-11-30 09:37:30	9	2025-07-02 09:58:21.438869	\N
629	CX 89	9829491044	2025-11-11 18:30:00	Needs Followup	I20 service 	2024-11-30 09:37:30	9	2025-07-02 10:01:44.075105	\N
661	Cx94	9911447765	2025-12-22 18:30:00	Needs Followup	Not required 	2024-11-30 12:05:01	9	2025-07-02 10:04:48.38856	\N
742	Cx102	9462619602	2025-07-21 18:30:00	Needs Followup	Not picking 	2024-12-01 10:44:45	9	2025-07-02 10:06:04.863065	\N
1304	Customer	9521101613	2025-07-17 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-02 10:07:33.126197	\N
1308	Customer	9887698153	2025-07-17 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-02 10:08:36.866908	\N
1368	Ashok Kumar	9785684816	2025-07-10 18:30:00	Needs Followup	Swift Service 	2024-12-07 05:46:09	9	2025-07-02 10:14:51.21176	\N
338	Cx66	9649456778	2025-12-13 18:30:00	Needs Followup	Not have a car	2024-11-26 12:38:59	9	2025-07-02 10:16:21.90137	
1338	Cx127	8890522842	2025-11-27 18:30:00	Needs Followup	Not required 	2024-12-07 05:46:09	9	2025-07-02 10:17:32.542219	
1667	SACHIN GUPTA	9828518088	2025-10-21 18:30:00	Needs Followup	Amaze service 	2024-12-12 10:59:46	9	2025-07-02 10:20:44.166965	
2609	Cx156	9929822222	2025-07-17 18:30:00	Did Not Pick Up	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-02 10:21:52.020617	
4790	Cx634	9887563041	2025-09-16 18:30:00	Needs Followup	Not have a car	2025-03-16 11:15:32.412245	9	2025-07-02 10:22:57.988655	
6781	gaadimech 	8947922222	2025-08-13 18:30:00	Did Not Pick Up	Not required 	2025-04-28 09:51:16.895349	9	2025-07-02 10:28:44.487321	
6811	Cx1156	9783059002	2025-07-18 18:30:00	Needs Followup	Not picking 	2025-04-30 08:25:59.890354	9	2025-07-02 10:29:42.972038	
7062	gaadimech 	7891165018	2025-07-30 18:30:00	Did Not Pick Up	Invalid no.	2025-05-10 07:20:58.287013	9	2025-07-02 10:30:24.036811	
7068	gaadimech 	8094323306	2025-07-21 18:30:00	Did Not Pick Up	Not picking 	2025-05-10 08:44:48.068017	9	2025-07-02 10:31:10.836355	
7069	gaadimech 	9829502065	2025-07-18 18:30:00	Did Not Pick Up	Not picking 	2025-05-10 08:45:19.371183	9	2025-07-02 10:32:20.977624	
7121	gaadimech 	7726801795	2025-08-12 18:30:00	Did Not Pick Up	Not picking 	2025-05-13 04:50:01.116131	9	2025-07-02 10:34:08.912053	
7129	Cx2002	7357047601	2025-07-24 18:30:00	Needs Followup	Not picking 	2025-05-13 05:15:37.879505	9	2025-07-02 10:35:05.34343	
7184	gaadimech 	7728972440	2025-07-24 18:30:00	Did Not Pick Up	Swift not picking 	2025-05-14 11:26:13.371916	9	2025-07-03 05:52:47.247837	
7168	gaadimech 	9929869939	2025-07-26 18:30:00	Needs Followup	Not picking 	2025-05-14 06:33:59.725488	9	2025-07-02 10:36:13.370578	
7259	Cx2024	8690115283	2025-09-19 18:30:00	Needs Followup	Ciaz not picking 	2025-05-17 05:12:54.290859	9	2025-07-03 05:55:38.012418	
7282	Cx2015	8302356001	2025-07-17 18:30:00	Needs Followup	Dzire not picking 	2025-05-18 05:17:57.668985	9	2025-07-03 05:57:17.412606	
7302	Rahul Sharma Alto 	8505071942	2025-07-25 18:30:00	Completed	Not picking 	2025-05-19 05:35:45.701532	9	2025-07-03 05:58:31.731155	
7305	Caiz 	9610004144	2025-08-21 18:30:00	Completed	Ciaz not interested 	2025-05-19 09:02:05.873197	9	2025-07-03 06:00:36.337845	
7306	Brio( 2399)	9829213431	2025-09-24 18:30:00	Needs Followup	Brio Not interested 	2025-05-19 09:03:51.720973	9	2025-07-03 06:02:47.472078	
7330	Alto 	8949163265	2025-07-20 18:30:00	Completed	Not picking 	2025-05-20 10:38:12.461115	9	2025-07-03 06:04:04.475491	
5848	pritam singh gaadimech 	7597939296	2025-07-30 18:30:00	Feedback	Xylo service 	2025-04-12 06:01:49.864383	9	2025-07-04 05:38:51.241117	RJ29UA1209
7707	gaadimech	9826616523	2025-07-18 18:30:00	Feedback	I10 service \r\n3799 online big boss 28/06/2025\r\n	2025-06-28 06:08:02.022799	6	2025-06-28 11:54:08.957735	RJ14CJ8106
7704	gaadirmch	7597033164	2025-07-08 18:30:00	Did Not Pick Up	Call back after 4 days\r\nUdaipur me karwa li	2025-06-28 06:05:09.98992	6	2025-07-02 10:49:01.820019	
7705	gaadinech	7043327787	2025-07-17 18:30:00	Did Not Pick Up	Not pick	2025-06-28 06:05:43.733827	6	2025-06-29 06:44:57.914114	
7701	gaadimech	9785392295	2025-07-04 18:30:00	Did Not Pick Up	Scorpio 5199 	2025-06-28 06:03:22.826785	6	2025-07-02 10:51:37.770543	
7338	gaadimech 	9828337733	2025-07-27 18:30:00	Did Not Pick Up	Innova diesel santro petrol service interested 	2025-05-21 04:45:13.046467	9	2025-07-03 06:09:29.986931	
2331	.	9314140090	2025-07-11 18:30:00	Did Not Pick Up	Call not pick 	2024-12-21 12:16:01.229869	6	2025-06-29 08:06:52.671221	
7703	 om prakash ji gaadimech	9351851212	2025-07-03 18:30:00	Feedback	Wagnor service done \r\n3549 sharp motors\r\nFeedback	2025-06-28 06:04:39.730325	6	2025-06-30 08:15:06.082149	RJ14TG3406
3198	Customer	9799996467	2025-07-10 18:30:00	Did Not Pick Up	Not pick \r\nNot pick	2025-01-19 10:35:57.536291	6	2025-06-30 10:21:22.424784	
2432	.	7891234187	2025-07-07 18:30:00	Did Not Pick Up	Call not pick 	2024-12-23 08:16:54.59051	6	2025-06-30 10:30:27.193462	
7518	Virendra Singh Bhati	9829210025	2025-07-05 18:30:00	Open	S cross diesel service and ac package 	2025-05-27 08:55:19.170412	9	2025-07-06 09:05:15.691009	RJ14LC1503
7702	gaadimech	9509591919	2025-07-06 18:30:00	Did Not Pick Up	Not pick 	2025-06-28 06:03:58.691199	6	2025-07-02 10:49:48.181959	
7349	gaadimech	9680351779	2025-07-29 18:30:00	Did Not Pick Up	Scala not picking 	2025-05-21 06:45:53.536216	9	2025-07-03 06:10:49.888939	
7350	gaadimech 	9314964324	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-21 06:48:00.257449	9	2025-07-03 06:11:46.387532	
7364	Cx2031	9116636007	2025-07-28 18:30:00	Needs Followup	Not picking 	2025-05-21 11:05:31.659295	9	2025-07-03 06:13:48.088126	
7498	Himanshu Kumar	9636396961	2025-07-03 18:30:00	Open	Alto 800 service start	2025-05-25 06:44:15.221789	9	2025-07-05 09:42:47.810622	RJ14CU3296
7396	gaadimech	9079985234	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-22 12:39:00.360096	9	2025-07-03 06:17:48.772515	
7412	gaadimech 	9461542486	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-23 06:03:57.891764	9	2025-07-03 06:18:48.973556	
7415	gaadimech 	9571542128	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-23 06:27:15.444737	9	2025-07-03 06:19:44.127464	
7416	gaadimech 	9571542128	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-23 06:47:16.322402	9	2025-07-03 06:30:23.080249	
7419	gaadimech 	9548506913	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-23 06:54:46.666543	9	2025-07-03 06:32:14.716763	
7421	gaadimech 	9782940347	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-23 07:02:12.415804	9	2025-07-03 06:33:17.01642	
7426	gaadimech 	9414714947	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-23 07:29:14.552107	9	2025-07-03 06:35:16.266269	
7433	Brio 	9680427714	2025-11-28 18:30:00	Needs Followup	Not picking 	2025-05-23 09:49:53.816742	9	2025-07-03 06:38:53.977712	
7435	Cx2043	7426809353	2025-07-28 18:30:00	Needs Followup	Not picking 	2025-05-23 09:51:56.012417	9	2025-07-03 06:39:53.553097	
7445	gaadimech 	9772864000	2025-07-28 18:30:00	Needs Followup	Figo verna diesel interested 	2025-05-24 06:16:24.628105	9	2025-07-03 06:43:45.604776	
7447	gaadimech 	7976711627	2025-07-28 18:30:00	Did Not Pick Up	Not picking 	2025-05-24 06:30:56.392016	9	2025-07-03 06:45:06.891276	
7448	gaadimech 	8005760209	2025-11-29 18:30:00	Needs Followup	Not needed 	2025-05-24 06:31:30.269548	9	2025-07-03 06:47:20.695518	
7449	gaadimech 	8278630042	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-24 06:41:38.410945	9	2025-07-03 06:48:33.626588	
7454	gaadimech 	9250025700	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-24 07:00:30.514427	9	2025-07-03 06:49:13.735722	
7460	Cx2041	9116530464	2025-07-16 18:30:00	Needs Followup	Dzire Need daint paint 	2025-05-24 09:32:46.048492	9	2025-07-03 06:53:59.206705	
7465	Cx2046	9990854111	2025-07-21 18:30:00	Needs Followup	Not picking 	2025-05-24 09:41:07.256175	9	2025-07-03 06:54:56.311214	
7467	Cx2047	9983303007	2025-07-26 18:30:00	Needs Followup	Dzire bumper change service 	2025-05-24 09:55:57.447559	9	2025-07-03 07:01:28.955031	
7468	Alto ac 	7877768004	2025-07-23 18:30:00	Needs Followup	Not picking 	2025-05-24 09:56:48.393503	9	2025-07-03 07:02:38.956619	
7469	Cx2048	9024418856	2025-07-13 18:30:00	Needs Followup	Not picking 	2025-05-24 09:57:52.319361	9	2025-07-03 07:03:58.385764	
7470	Cx2049	9529051786	2025-07-24 18:30:00	Needs Followup	Not picking 	2025-05-24 09:58:35.653649	9	2025-07-03 07:05:05.060367	
7480	gaadimech	9468749564	2025-07-16 18:30:00	Needs Followup	Honda city petrol service needed 	2025-05-25 04:54:08.189242	9	2025-07-03 07:07:51.650902	
7482	Cx2041	9414216391	2025-10-29 18:30:00	Needs Followup	Not interested 	2025-05-25 05:00:05.003472	9	2025-07-03 07:08:51.52035	
7484	Cx2043	6206534277	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-25 05:02:29.008893	9	2025-07-03 07:11:23.983205	
7492	gaadimech 	9509440446	2025-09-24 18:30:00	Did Not Pick Up	Not required 	2025-05-25 05:38:05.873102	9	2025-07-03 07:12:55.518172	
7493	gaadimech 	8839685944	2025-07-24 18:30:00	Did Not Pick Up	Not picking 	2025-05-25 05:40:24.961408	9	2025-07-03 07:14:35.048553	
7501	gaadimech 	9672055046	2025-07-24 18:30:00	Did Not Pick Up	Not interested 	2025-05-25 07:47:01.331693	9	2025-07-03 07:18:03.95152	
7505	Cx2051	8690575384	2025-10-22 18:30:00	Needs Followup	Not required 	2025-05-27 08:45:19.577426	9	2025-07-03 07:19:31.62282	
7506	Cx2050	9257436555	2025-08-19 18:30:00	Needs Followup	Not interested 	2025-05-27 08:46:06.656259	9	2025-07-03 07:21:48.802853	
7508	Eon 2399	8270609774	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-27 08:47:24.390008	9	2025-07-03 07:23:07.359967	
7509	Cx 2053	9928262283	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-27 08:48:29.113186	9	2025-07-03 07:23:54.138787	
7510	Cc2055	9252591709	2025-07-20 18:30:00	Needs Followup	Not picking 	2025-05-27 08:48:51.357627	9	2025-07-03 07:24:46.804978	
7512	Honda Amaze 3199	9772689293	2025-10-15 18:30:00	Needs Followup	Not have a car 	2025-05-27 08:50:18.908507	9	2025-07-03 07:26:01.809973	
7513	Tata punch 3199	9910203553	2025-07-24 18:30:00	Needs Followup	Not picking 	2025-05-27 08:50:58.19691	9	2025-07-03 07:54:58.294394	
7514	Cx2056	7413843428	2025-07-28 18:30:00	Needs Followup	Not picking 	2025-05-27 08:51:31.027674	9	2025-07-03 07:56:55.466329	
7517	Cx2058	8107149595	2025-10-28 18:30:00	Needs Followup	Not required 	2025-05-27 08:54:08.319961	9	2025-07-03 07:59:04.762016	
7522	Cx,2062	9887050969	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-27 08:58:26.454007	9	2025-07-03 08:04:41.751889	
7524	Cx2064	9772203107	2025-07-28 18:30:00	Needs Followup	Not picking 	2025-05-27 09:06:06.534707	9	2025-07-03 08:05:16.510207	
7525	Cx2066	9024822321	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-27 09:06:51.644434	9	2025-07-03 08:05:51.849823	
7526	Cx2064	8690575384	2025-07-30 18:30:00	Needs Followup	Not interested 	2025-05-27 09:07:40.328295	9	2025-07-03 08:06:21.870424	
7528	Cx2069	8949132130	2025-08-30 18:30:00	Needs Followup	Not interested 	2025-05-27 09:09:37.892739	9	2025-07-03 08:21:20.213508	
7533	Cx2067	8005790795	2025-07-29 18:30:00	Needs Followup	Not interested 	2025-05-27 11:11:54.655757	9	2025-07-03 08:28:09.192108	
7539	Cx2061	9461030753	2025-08-20 18:30:00	Did Not Pick Up	Switched off 	2025-05-28 06:40:41.46721	9	2025-07-03 08:28:44.661663	
7557	gaadimech 	9982309422	2025-09-24 18:30:00	Did Not Pick Up	Not interested 	2025-05-29 04:59:11.907082	9	2025-07-03 08:30:07.196911	
2321	.	9928000008	2025-07-30 18:30:00	Needs Followup	Call not pick \r\nNit interested 	2024-12-21 08:31:22.208151	6	2025-06-29 08:31:15.724792	
2433	.	9358898806	2025-07-18 18:30:00	Did Not Pick Up	WhatsApp package shared \r\nService done by other workshop \r\nNot pick	2024-12-23 08:16:54.59051	6	2025-06-30 10:31:45.855211	
7570	gaadimech	9799560522	2025-07-27 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 07:07:57.570958	9	2025-07-03 08:52:53.380425	
7685	Cx2095	9636317074	2025-09-24 18:30:00	Needs Followup	Not interested 	2025-06-02 05:43:57.227636	9	2025-07-03 09:55:44.190374	
7561	gaadimech 	8112283780	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 05:06:15.407252	9	2025-07-03 08:45:49.308219	
7601	Cx2071	9314398952	2025-07-09 18:30:00	Needs Followup	I10 Service needed not picking 	2025-05-30 05:11:00.673933	9	2025-07-06 06:38:58.881758	
7586	gaadimech 	8707603677	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 11:36:18.290385	9	2025-07-03 08:59:30.558415	
7600	Cx2070	8559858023	2025-07-28 18:30:00	Needs Followup	Not interested 	2025-05-30 05:09:36.75913	9	2025-07-03 09:00:22.322418	
7604	gaadimech	8233588242	2025-09-29 18:30:00	Needs Followup	Not interested 	2025-05-30 06:01:36.623824	9	2025-07-03 09:06:47.133264	
7611	Cx2076	7340044885	2025-08-30 18:30:00	Needs Followup	Not interested 	2025-05-30 10:15:48.326329	9	2025-07-03 09:07:44.307057	
7612	Cx2074	7014658771	2025-11-26 18:30:00	Needs Followup	No car	2025-05-30 10:17:01.130181	9	2025-07-03 09:09:14.592732	
7613	Cx2076	7230940006	2025-07-29 18:30:00	Needs Followup	Not picking 	2025-05-30 10:18:46.739773	9	2025-07-03 09:10:23.61023	
7615	Cx2079	8058119097	2025-10-23 18:30:00	Needs Followup	Eon Service 	2025-05-30 10:20:42.904991	9	2025-07-03 09:18:26.010584	
7626	gaadimech 	9829084944	2025-08-21 18:30:00	Needs Followup	Not interested 	2025-05-31 04:53:36.646573	9	2025-07-03 09:19:37.983225	
7629	Cx2083	9351317532	2025-07-28 18:30:00	Did Not Pick Up	Not picking 	2025-05-31 05:08:33.673828	9	2025-07-03 09:21:04.843568	
7630	Cx2082	8005654125	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-05-31 05:09:53.988188	9	2025-07-03 09:22:11.508745	
7631	Cx2084	7733852579	2025-07-30 18:30:00	Did Not Pick Up	Dzire Interested 	2025-05-31 05:10:44.762662	9	2025-07-03 09:25:31.229165	
7638	gaadimech 	9461620543	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-05-31 07:34:12.525943	9	2025-07-03 09:26:44.450499	
7642	gaadimech 	8114482231	2025-08-29 18:30:00	Needs Followup	Not interested 	2025-05-31 08:37:29.702891	9	2025-07-03 09:29:19.085144	
7644	gaadimech 	8854878548	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-31 08:38:20.474493	9	2025-07-03 09:30:08.032558	
7649	Kia cranes 	7737253989	2025-10-24 18:30:00	Needs Followup	Service 	2025-05-31 12:55:16.01125	9	2025-07-03 09:31:23.842878	
7650	Gaadimech	7737253989	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 04:31:40.673438	9	2025-07-03 09:31:41.886651	
7652	gaadimech 	8307310762	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 04:34:44.761647	9	2025-07-03 09:32:25.962116	
7653	gaadimech 	7852886538	2026-01-27 18:30:00	Did Not Pick Up	Not interested not picking 	2025-06-01 04:38:11.681459	9	2025-07-03 09:33:15.712903	
7654	gaadimech 	9928551134	2025-09-23 18:30:00	Did Not Pick Up	Not interested 	2025-06-01 04:39:55.309788	9	2025-07-03 09:34:39.167276	
7655	gaadimech	8209475247	2025-07-06 18:30:00	Needs Followup	Amaze interested must	2025-06-01 04:44:17.501921	9	2025-07-03 09:37:24.651556	
7656	gaadimech	9413240039	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 04:46:39.711482	9	2025-07-03 09:38:04.020075	
7657	gaadimech 	8233140904	2025-07-28 18:30:00	Needs Followup	Not picking 	2025-06-01 04:56:47.815549	9	2025-07-03 09:39:19.264306	
7658	Cx2086	9664124312	2025-09-24 18:30:00	Did Not Pick Up	Etios fatehpur 	2025-06-01 05:02:05.180972	9	2025-07-03 09:43:30.316023	
7659	Cx2090	8952943394	2025-07-29 18:30:00	Did Not Pick Up	Not interested 	2025-06-01 05:03:35.895566	9	2025-07-03 09:46:15.703842	
7666	gaadimech 	7976073292	2025-07-30 18:30:00	Did Not Pick Up	Not interested 	2025-06-01 05:14:38.890255	9	2025-07-03 09:46:32.778602	
7670	GaadiMech 	9672989709	2026-02-18 18:30:00	Needs Followup	Problem facing 	2025-06-01 08:35:20.622757	9	2025-07-03 09:48:51.630455	
7671	gaadimech	9035336123	2025-07-29 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 08:38:31.309246	9	2025-07-03 09:49:52.035615	
7672	gaadimech 	7452938645	2025-07-28 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 08:42:15.003193	9	2025-07-03 09:50:31.726009	
7674	gaadimech 	8118836596	2025-07-28 18:30:00	Did Not Pick Up	Not picking 	2025-06-01 09:10:33.106843	9	2025-07-03 09:52:04.150885	
7675	gaadimech 	7791919113	2025-10-28 18:30:00	Needs Followup	Not interested 	2025-06-01 09:28:52.817529	9	2025-07-03 09:53:26.141831	
7676	gaadimech 	6375069752	2025-07-28 18:30:00	Did Not Pick Up	Not picking \n	2025-06-01 09:38:29.696193	9	2025-07-03 09:54:13.585609	
48	Cx9	8209336512	2025-11-12 18:30:00	Needs Followup	Not picking 	2024-11-23 10:55:40	9	2025-07-03 09:57:26.332349	\N
53	Cx11	7742861650	2025-07-27 18:30:00	Needs Followup	Audi q7 19699 service 	2024-11-23 10:59:39	9	2025-07-03 10:01:39.984713	\N
85	Cx 21 	8078653809	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-23 12:43:11	9	2025-07-03 10:02:22.559096	\N
96	Cx25	8233720328	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-23 13:04:13	9	2025-07-03 10:02:52.903693	\N
98	Cx26	8952068748	2025-09-29 18:30:00	Needs Followup	Not needed 	2024-11-23 13:05:43	9	2025-07-03 10:07:08.392201	\N
119	Cx32	9829407523	2025-10-30 18:30:00	Needs Followup	Not required 	2024-11-24 06:37:02	9	2025-07-03 10:08:25.043753	\N
230	Cx38	8279588011	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-25 07:27:10	9	2025-07-03 10:09:31.22602	\N
231	Cx39	9887047758	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-11-25 07:28:07	9	2025-07-03 10:10:25.859507	\N
242	CX 46	8209144278	2025-07-07 18:30:00	Needs Followup	Polo diesel Interested 	2024-11-25 07:48:51	9	2025-07-03 10:13:30.476032	\N
273	Cx48	8114483868	2025-11-16 18:30:00	Needs Followup	Not interested 	2024-11-25 11:59:19	9	2025-07-03 10:14:06.920262	\N
276	Cx51	8824332890	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-25 12:01:13	9	2025-07-03 10:15:20.546347	\N
277	Cx52	7976766155	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-25 12:02:16	9	2025-07-03 10:15:57.247068	\N
286	Cx58	8560932337	2025-08-30 18:30:00	Needs Followup	Not interested 	2024-11-25 13:07:57	9	2025-07-03 10:22:00.981151	\N
293	Cx61	7851053552	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 08:11:03	9	2025-07-03 10:22:59.31066	\N
296	Cx63	9650292307	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 08:23:22	9	2025-07-03 10:24:07.438853	\N
299	Cx65	8562804250	2025-07-13 18:30:00	Needs Followup	Honda accent service needed 	2024-11-26 08:27:56	9	2025-07-03 10:28:06.804448	\N
300	Cx65	9540872034	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 08:28:48	9	2025-07-03 10:29:27.773393	\N
301	CX 65	9079184418	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 08:29:28	9	2025-07-03 10:31:58.76203	\N
337	Cx65	9214681263	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-11-26 12:37:55	9	2025-07-03 10:34:34.818547	\N
344	Cx67	9079208435	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 12:41:34	9	2025-07-03 10:35:13.933769	\N
346	Cx67	9772414141	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 12:44:24	9	2025-07-04 06:51:49.376502	\N
7585	RD Rathore	8000250176	2025-07-06 18:30:00	Confirmed	Polo petrol service booked	2025-05-29 11:24:15.001355	9	2025-07-06 06:33:35.216367	RJ45CF2967
4854	gaadimech 	9001009008	2025-07-17 18:30:00	Needs Followup	Dzire 2699 vki	2025-03-19 05:28:54.590009	4	2025-06-28 05:31:58.88352	
403	Cx68	8955001234	2025-08-07 18:30:00	Needs Followup	Scorpio follow up 	2024-11-27 11:01:48	9	2025-07-04 06:54:27.930963	\N
410	Cx70	9829074016	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-27 11:01:48	9	2025-07-04 06:55:11.788739	\N
7595	gaadimech	9414066759	2025-07-25 18:30:00	Needs Followup	Duster service done next time dekhenge\r\nNot interested 	2025-05-30 04:47:05.938755	6	2025-06-29 06:56:49.022716	
7488	gaadimech 	9521237791	2025-07-25 18:30:00	Did Not Pick Up	Not interested 	2025-05-25 05:06:50.10123	6	2025-06-29 09:08:11.346876	
5267	gaadimech 	8949401030	2025-07-03 18:30:00	Did Not Pick Up	Not pick 	2025-03-29 09:04:27.041996	6	2025-06-29 09:11:58.270791	
3523	gaadimech 	9929886211	2025-07-25 18:30:00	Did Not Pick Up	Wagnor dent paint 2000 penal charge	2025-01-30 05:36:29.015053	6	2025-06-29 09:29:10.05521	
3499	.	9414418912	2025-07-25 18:30:00	Did Not Pick Up	Dzire 2699	2025-01-28 06:07:51.486916	6	2025-06-29 09:31:55.869859	
622	Cx89	9664490339	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-30 09:37:30	9	2025-07-04 07:28:25.723086	\N
411	Cx71 	7375076031	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-27 11:01:48	9	2025-07-04 06:56:25.720343	\N
421	Cx76	9829019299	2025-07-21 18:30:00	Needs Followup	Mercedes Glc 15199  	2024-11-27 11:01:48	9	2025-07-04 07:07:04.74099	\N
471	Cx78	9024739291	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:08:34.681782	\N
473	Cx80 	7877779617	2025-07-30 18:30:00	Needs Followup	Tata nexon	2024-11-28 06:03:20	9	2025-07-04 07:16:11.789721	\N
476	Cx80	7976597195	2025-07-30 18:30:00	Needs Followup	Switched off 	2024-11-28 06:03:20	9	2025-07-04 07:17:12.673714	\N
487	Cx80	8824881554	2025-07-30 18:30:00	Needs Followup	Switch off 	2024-11-28 06:03:20	9	2025-07-04 07:18:16.58136	\N
507	Cx81	8209066146	2025-07-30 18:30:00	Needs Followup	Invalid no 	2024-11-28 06:03:20	9	2025-07-04 07:19:01.807888	\N
511	Cx81	8209066146	2025-07-30 18:30:00	Needs Followup	Switched off 	2024-11-28 06:03:20	9	2025-07-04 07:19:19.131416	\N
512	Cx82	6377617291	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-04 07:20:27.005677	\N
516	Cx84	9657312337	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:22:42.756949	\N
517	Cx85	9057871297	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:23:32.561782	\N
518	Cx85	9057871297	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:23:48.850797	\N
520	Cx86 	9571677858	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:24:39.974724	\N
521	Cx89	8619087774	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-28 06:03:20	9	2025-07-04 07:25:47.813548	\N
523	Cx91	9414480246	2026-01-22 18:30:00	Needs Followup	Not have a car	2024-11-28 06:03:20	9	2025-07-04 07:27:08.930906	\N
658	Cx92	6378565882	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-30 12:05:01	9	2025-07-04 07:29:05.582072	\N
659	Cx94	7732945339	2025-08-30 18:30:00	Needs Followup	Not interested 	2024-11-30 12:05:01	9	2025-07-04 07:30:40.461108	\N
662	Cx94	9414185881	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-30 12:05:01	9	2025-07-04 07:32:22.10515	\N
663	Cx95	8561063272	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-11-30 12:05:01	9	2025-07-04 07:33:52.171478	\N
736	Cx98	8239105888	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-01 10:44:45	9	2025-07-04 07:35:04.470383	\N
750	Cx106	9887719234	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-01 12:23:34	9	2025-07-04 07:37:30.620891	\N
849	Cx109	8000831673	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-02 04:50:36	9	2025-07-04 07:38:51.80132	\N
851	Cx105	9813858491	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-02 04:50:36	9	2025-07-04 07:39:28.03158	\N
896	Cx111	9672610041	2025-10-23 18:30:00	Needs Followup	Not interested 	2024-12-03 05:16:04	9	2025-07-04 07:40:48.947287	\N
1071	Cx109	9667575858	2025-08-05 18:30:00	Needs Followup	Not interested 	2024-12-04 05:17:16	9	2025-07-04 07:43:16.125734	\N
1072	Cx109	7014518364	2025-09-16 18:30:00	Needs Followup	Not interested 	2024-12-04 05:17:16	9	2025-07-04 07:47:29.121375	\N
1073	Cx110	8529111210	2025-07-30 18:30:00	Needs Followup	Switched off 	2024-12-04 05:17:16	9	2025-07-04 07:50:58.237538	\N
1078	Cx117	8387956021	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-04 05:17:16	9	2025-07-04 07:51:45.643034	\N
1331	Cx127	7014297281	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 07:52:30.313288	\N
1354	Cx137	9829677171	2025-07-30 18:30:00	Needs Followup	Switched off 	2024-12-07 05:46:09	9	2025-07-04 07:53:13.428184	\N
1355	Cx137	7225094127	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 07:54:26.524384	\N
1356	Cx138	6378360077	2025-07-30 18:30:00	Needs Followup	Switch off 	2024-12-07 05:46:09	9	2025-07-04 07:55:01.693765	\N
1718	Cx125	7833015572	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 07:55:40.814398	\N
1719	Cx125	9680611600	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 07:56:49.367004	\N
1721	Cx127	7737495233	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-04 07:58:26.377776	\N
1723	Cx128	7021866278	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-04 08:01:22.10247	\N
1727	Cx130	9335031358	2026-01-22 18:30:00	Needs Followup	Not have any car	2024-12-13 04:40:11	9	2025-07-04 08:03:23.736722	\N
1729	Cx131	9783561313	2025-07-27 18:30:00	Needs Followup	Audi a6 break pad and sensor connect must 	2024-12-13 04:40:11	9	2025-07-04 08:08:09.365868	\N
1733	Cx132	8209563410	2025-08-17 18:30:00	Needs Followup	Alto ertiga scorpio but not in jaipur 	2024-12-13 04:40:11	9	2025-07-04 08:10:26.581645	\N
1735	Cx134	9782196980	2025-08-31 18:30:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-04 08:11:49.65172	\N
1740	Cx136	8104576938	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 08:17:19.626969	\N
1741	Cx137	9358679577	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 08:18:03.141102	\N
1743	Cx137	6209626473	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 08:18:56.555824	\N
1745	Cx137	7611066682	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-13 04:40:11	9	2025-07-04 08:19:36.331756	\N
1753	Cx137	6367129596	2025-07-30 18:30:00	Needs Followup	Switch off 	2024-12-13 04:40:11	9	2025-07-04 08:20:12.996322	\N
1883	Cx137	7790929773	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-14 12:39:55	9	2025-07-04 08:20:48.725877	\N
1884	Cx137	9414624404	2025-08-19 18:30:00	Needs Followup	Not interested 	2024-12-14 12:39:55	9	2025-07-04 08:21:59.735681	\N
1887	Cx140	9672655495	2025-12-30 18:30:00	Needs Followup	Not required 	2024-12-14 12:39:55	9	2025-07-04 08:26:10.517897	\N
2528	Cx122	9664176310	2025-07-07 18:30:00	Needs Followup	Not interested 	2024-12-30 11:05:48.996851	9	2025-07-04 08:36:24.471909	\N
2529	Cx123	7300448353	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:05:48.996851	9	2025-07-04 08:42:56.19024	\N
2531	Cx124	8273646792	2025-10-17 18:30:00	Needs Followup	Khud mechanic h 	2024-12-30 11:05:48.996851	9	2025-07-04 08:47:03.615737	\N
2532	Cx127	7023636151	2025-10-23 18:30:00	Needs Followup	Not interested 	2024-12-30 11:05:48.996851	9	2025-07-04 08:50:19.705465	\N
7719	Cx3085	9694562439	2025-07-04 18:30:00	Needs Followup	Service \r\nCall cut 	2025-06-28 08:26:48.963142	4	2025-07-04 09:31:50.846476	
2535	CX 128	9785788828	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:47:49.431366	9	2025-07-06 06:44:38.721327	\N
7709	gaadinech	9829029190	2025-10-09 18:30:00	Did Not Pick Up	Voice mail\r\nNit interested abhi service requirement nahi hai	2025-06-28 06:20:55.257352	6	2025-06-29 06:40:06.105939	
5285	gaadimech 	7976999601	2025-08-08 18:30:00	Did Not Pick Up	Jazz 3199 \r\nCall cut\r\nNot interested 	2025-03-30 06:57:16.417042	6	2025-06-29 09:10:18.891454	
4657	gaadimech	9314026599	2025-07-02 18:30:00	Did Not Pick Up	Service alredy done normaly check kia tha 	2025-03-11 06:58:05.170932	6	2025-06-29 09:12:57.813642	
4560	gaadimech 	7877133158	2025-07-11 18:30:00	Did Not Pick Up	Swift 2699 banipark\r\nNext time try krunga abhi to bhai bhahr se karwa chuka tha\r\nCall cut	2025-03-07 09:02:12.136648	6	2025-06-29 09:15:28.316337	
4554	gaadimech 	9024205357	2025-07-10 18:30:00	Did Not Pick Up	Service done by hundai workshop \r\nNot pick	2025-03-07 05:50:45.994902	6	2025-06-29 09:16:17.865529	
7721	gaadimech	8447042410	2025-10-02 18:30:00	Did Not Pick Up	Tiago not pick \r\nNit requirement 	2025-06-28 08:39:52.190371	6	2025-06-30 07:56:30.377754	
7710	gaadimech	9829476376	2025-07-02 18:30:00	Did Not Pick Up	Ford Fiesta dent paint\r\nCall cut	2025-06-28 06:24:21.176288	6	2025-06-30 08:00:20.604315	
7708	gaadimech	9999787830	2025-07-02 18:30:00	Needs Followup	Baleno 2799	2025-06-28 06:12:24.257661	6	2025-06-30 08:01:47.011677	
3066	Customer	9304313497	2025-09-10 18:30:00	Did Not Pick Up	Not pick \r\nNot pick\r\nNot pick	2025-01-16 04:14:34.232859	6	2025-06-30 10:22:36.343788	
2412	.	9828331207	2025-07-11 18:30:00	Did Not Pick Up	Not interested 	2024-12-23 04:37:08.828595	6	2025-06-30 11:29:56.510278	
2533	Cc126	9773311058	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:47:49.431366	9	2025-07-04 08:51:40.06562	\N
4441	arpit	9680345607	2025-08-21 18:30:00	Feedback	TIYAGO 2899\r\ntotal payment 3000\r\nFeedback call \r\n7/03/2025 call back 11 march\r\n11/03/2025 call cut\r\n	2025-02-28 12:11:07.666722	6	2025-06-28 10:54:30.742016	RJ45CM4077
4426	gaadimech	9414072346	2025-08-14 18:30:00	Did Not Pick Up	Alto full gaadi 20000 charge\r\n10k me puri car dent paint karwa li	2025-02-27 08:45:39.918326	6	2025-06-28 10:54:47.79995	
4722	.	9829011357	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-03-13 11:02:24.915711	6	2025-06-28 10:55:27.917927	
2539	Cx129	9799931338	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:47:49.431366	9	2025-07-04 09:04:41.996045	\N
2538	Cx126	9610961095	2026-01-29 18:30:00	Needs Followup	not interested facing problems 	2024-12-30 11:47:49.431366	9	2025-07-04 09:02:51.020163	\N
2541	Cx128	9529852224	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:47:49.431366	9	2025-07-04 09:05:25.170502	\N
2542	Cx127	7976217098	2025-08-21 18:30:00	Needs Followup	Not interested 	2024-12-30 11:47:49.431366	9	2025-07-04 09:10:37.176687	\N
2544	Cx129	9351160100	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-30 11:47:49.431366	9	2025-07-04 09:11:31.095643	\N
2545	RJ Purohit	6378105806	2026-01-15 18:30:00	Needs Followup	Out of state	2024-12-31 06:23:43.015407	9	2025-07-04 09:13:03.116885	\N
2555	Cx131	9694883847	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-02 12:06:04.008231	9	2025-07-04 09:14:23.760673	\N
2563	Cx137	8290706269	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-02 12:06:04.008231	9	2025-07-04 09:15:07.700967	\N
2567	Cx137	8527128075	2025-07-24 18:30:00	Needs Followup	Tata tiago diesel not interested 	2025-01-02 12:06:04.008231	9	2025-07-04 09:17:47.176691	\N
2569	Cx137	8302260964	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-02 12:06:04.008231	9	2025-07-04 09:18:33.800956	\N
2570	Cx137	8619623216	2025-09-21 18:30:00	Needs Followup	Celerio petrol service 	2025-01-02 12:06:04.008231	9	2025-07-04 09:22:04.961237	\N
2579	Ayush Test	7023620070	2026-01-16 18:30:00	Needs Followup	Not picking 	2025-01-04 20:22:19.384118	9	2025-07-04 09:22:29.410473	\N
7720	Cx3089	7976450020	2025-07-04 18:30:00	Needs Followup	Swift Drycleaning \r\n	2025-06-28 08:27:38.046611	4	2025-07-04 09:29:07.976959	
2583	Cx139	7849906505	2025-10-24 18:30:00	Needs Followup	Valksvegan Vento not interested 	2025-01-06 11:15:01.167732	9	2025-07-04 09:32:35.930503	\N
2584	Cx136	7425951435	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-06 11:15:01.167732	9	2025-07-04 09:33:30.877446	\N
2599	Mo. Rizwan	8114466227	2026-01-28 18:30:00	Needs Followup	From sikar 	2025-01-07 04:42:15.913695	9	2025-07-04 09:34:52.242075	\N
2606	Cx150	9509403529	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-04 09:35:48.361326	\N
2793	Praveen Choudhary	9784283860	2026-01-15 18:30:00	Needs Followup	Not from jaipur 	2025-01-10 04:20:50.707156	9	2025-07-04 09:38:39.041152	\N
2847	Cus	9887326176	2025-07-29 18:30:00	Needs Followup	Not interested wp msg dropped 	2025-01-12 04:36:11.819946	9	2025-07-04 09:41:20.120222	\N
3041	Cx179	9829120011	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-01-13 09:02:24.989067	9	2025-07-04 09:42:39.371408	\N
51	Cx10 	7011427148	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-23 10:57:22	9	2025-07-04 09:44:21.750817	
83	Cx20	9001273943	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-23 12:40:43	9	2025-07-04 09:45:07.100836	
120	Cx33	9660652629	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-24 06:38:07	9	2025-07-04 09:46:30.920432	
122	Cx33	9649297911	2025-11-26 18:30:00	Needs Followup	Not picking 	2024-11-24 06:39:20	9	2025-07-04 09:47:45.004198	
124	CX35	9024074897	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-24 06:40:19	9	2025-07-04 09:51:29.206808	
202	CX38	8740048025	2025-12-30 18:30:00	Needs Followup	Hogyi service 	2024-11-24 11:56:16	9	2025-07-04 09:53:02.16699	
303	Cx65	9829208888	2025-11-27 18:30:00	Needs Followup	Not interested 	2024-11-26 08:35:37	9	2025-07-04 10:02:55.251196	
343	CX67	9660000375	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-26 12:40:59	9	2025-07-04 10:30:34.125641	
415	Cx74	6367813048	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-27 11:01:48	9	2025-07-04 10:31:53.885808	
631	Cx91 	9799300452	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-11-30 09:37:30	9	2025-07-04 10:32:51.923954	
743	Cx104	9414022195	2025-07-30 18:30:00	Needs Followup	Switch off 	2024-12-01 10:44:45	9	2025-07-04 10:33:39.353544	
744	Cx105	9588941570	2026-01-15 18:30:00	Needs Followup	Bhilwara	2024-12-01 10:44:45	9	2025-07-04 10:36:34.424479	
746	CX 105	9588941570	2025-12-24 18:30:00	Needs Followup	Bhilwara	2024-12-01 12:23:34	9	2025-07-04 10:37:32.893604	
902	Cx117	6378360077	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-03 05:16:04	9	2025-07-04 10:37:52.713203	
1096	Cx119	8587821314	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-05 10:39:15	9	2025-07-04 10:39:04.419489	
1097	Cx120	7300008721	2025-07-23 18:30:00	Needs Followup	Glanza	2024-12-05 10:39:15	9	2025-07-04 10:40:29.059996	
1146	Cx121	8871235605	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-06 08:38:44	9	2025-07-04 10:41:12.399564	
1153	Cx124	9257437800	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-06 08:38:44	9	2025-07-04 10:42:43.821124	
1155	Cx125	8209187428	2025-11-27 18:30:00	Needs Followup	Car sold 	2024-12-06 08:38:44	9	2025-07-04 10:44:15.005727	
100	Vijay	9314624012	2025-07-06 18:30:00	Needs Followup	Alto  service booking at sunday call	2024-11-23 13:07:32	9	2025-07-06 06:40:27.912709	RJ45CM4796
1157	Cx126	9084268987	2025-11-26 18:30:00	Needs Followup	Agra	2024-12-06 08:38:44	9	2025-07-04 10:47:10.025994	
7714	Innova service 	8278607571	2025-07-02 18:30:00	Needs Followup	Innova service \r\n	2025-06-28 06:34:03.929369	4	2025-06-28 06:34:03.929376	
7715	Cx3087	9414781287	2025-07-05 18:30:00	Needs Followup	Baleno dent paint 	2025-06-28 06:36:43.745364	4	2025-07-04 09:32:36.776503	
4251	Pradeep ji	9314722211	2025-07-25 18:30:00	Feedback	Wiper blade change 580\r\n.Feedback\r\nDay 01  wiper blade sahi hai koi preshani nh h	2025-02-20 11:51:02.15334	6	2025-06-28 11:01:42.604789	RJ45CT7348
1160	Cx127	7987287237	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-06 08:38:44	9	2025-07-04 10:48:22.723909	
1168	Cx 126	7987287237	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-06 08:38:44	9	2025-07-04 10:48:45.643854	
3809	.	9829556793	2025-07-25 18:30:00	Did Not Pick Up	Grand i10 2499 banipark\r\nService done by other workshop 	2025-02-07 04:30:18.562584	6	2025-06-28 11:08:17.897629	
3677	.	9829922125	2025-07-11 18:30:00	Did Not Pick Up	Busy call cut\r\nCall cut	2025-02-04 08:21:25.650869	6	2025-06-28 11:11:34.851892	
7713	Cx3084	9828354481	2025-07-09 18:30:00	Needs Followup	CNG 	2025-06-28 06:29:37.834357	4	2025-06-29 06:14:25.958077	
1328	Cx126	8824458830	2026-01-15 18:30:00	Needs Followup	Not have a car 	2024-12-07 05:46:09	9	2025-07-04 10:51:56.724512	
1329	Cx127	9414742200	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 10:52:40.518808	
4003	.	9414077378	2025-07-25 18:30:00	Needs Followup	Honda City 2999\r\nCar out of jaipur thi wahi service karwa li\r\nNot interested 	2025-02-12 11:06:21.978066	6	2025-06-29 09:24:42.604612	
1339	Cx127	9166052057	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 10:53:45.464949	
1341	Cx127	9829015627	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 10:54:49.143355	
1345	Cx129	7357144838	2025-07-30 18:30:00	Needs Followup	Not picking 	2024-12-07 05:46:09	9	2025-07-04 10:56:06.269729	
7722	gaadimech	9982402610	2025-07-18 18:30:00	Needs Followup	Sunny ac check up \r\nNai ki thadi\r\nCall cut	2025-06-28 08:57:48.800904	6	2025-06-30 07:51:10.505945	
1347	Cx130	7597598125	2025-07-30 18:30:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-04 10:56:44.629255	
5838	gaadimech 	8955014758	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-04-11 07:09:29.386009	9	2025-07-04 10:57:32.314241	
7393	Arvind ji	8059670455	2025-07-03 18:30:00	Completed	not have a car	2025-05-22 11:24:54.321477	9	2025-07-05 10:56:20.814961	
6613	Cx1131	9829843221	2025-07-30 18:30:00	Confirmed	Not picking 	2025-04-23 06:05:14.086341	9	2025-07-04 11:04:44.951406	
6631	gaadimech	8384930872	2025-08-26 18:30:00	Did Not Pick Up	Not interested 	2025-04-25 04:52:44.783466	9	2025-07-04 11:05:55.385496	
6767	gaadimech 	9826616523	2025-11-26 18:30:00	Did Not Pick Up	I10 Service 	2025-04-28 05:36:59.575406	9	2025-07-04 11:07:08.202482	
6804	gaadimech 	6375194451	2025-08-26 18:30:00	Did Not Pick Up	Not interested 	2025-04-30 05:50:13.214927	9	2025-07-04 11:08:22.170462	
6820	gaadimech 	9782049163	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-05-01 05:09:08.861429	9	2025-07-04 11:09:19.465447	
7094	gaadimech 	8503838511	2025-07-04 18:30:00	Needs Followup	No. does not exist	2025-05-11 05:53:03.819501	9	2025-07-05 08:35:41.85835	
7143	Cx2006	8882125658	2025-07-30 18:30:00	Needs Followup	Switched off 	2025-05-13 06:58:26.35286	9	2025-07-05 08:37:00.249997	
7148	Abhinav Sharma 	9911095813	2025-07-30 18:30:00	Completed	Not picking 	2025-05-13 07:06:27.705694	9	2025-07-05 08:38:05.590478	
7166	gaadimech 	9602265080	2025-07-14 18:30:00	Needs Followup	Verna DIESEL Needs follow up 1500km remains in service	2025-05-14 05:53:00.134953	9	2025-07-05 09:01:47.947877	RJ45CN6410
7169	gaadimech 	9571637626	2025-07-04 18:30:00	Needs Followup	not from jaipur	2025-05-14 06:53:13.070974	9	2025-07-05 09:06:04.040887	
7279	Cx2011	9928182619	2025-07-14 18:30:00	Needs Followup	Alto 800 service call must	2025-05-18 05:14:43.795303	9	2025-07-05 09:15:22.316016	
7280	Cx2012	7877189018	2025-07-21 18:30:00	Needs Followup	I10 needs follow up 	2025-05-18 05:16:29.881826	9	2025-07-05 09:17:55.766159	
7288	Cx2019	9785781611	2025-09-10 18:30:00	Needs Followup	I20 interested 	2025-05-19 05:24:23.819229	9	2025-07-05 09:21:19.11926	
7303	Micra 2999	9251454947	2025-11-04 18:30:00	Needs Followup	Micra 2999 service \r\n	2025-05-19 06:31:25.089439	9	2025-07-05 09:30:44.961218	
7319	gaadimech	6376097545	2025-09-04 18:30:00	Needs Followup	Aura service	2025-05-20 05:22:39.331912	9	2025-07-05 09:34:17.236077	
7324	gaadimech 	8788637179	2025-10-22 18:30:00	Did Not Pick Up	not interested	2025-05-20 06:44:16.070411	9	2025-07-05 09:38:08.696185	
7334	Gaadimech 	8000515155	2025-07-04 18:30:00	Did Not Pick Up	not incoming valid no.	2025-05-20 12:26:09.668435	9	2025-07-05 09:39:12.469794	
7346	gaadimech 	9893717176	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-05-21 06:36:56.892563	9	2025-07-05 10:44:46.662094	
7360	gaadimech	9928182313	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-21 09:28:23.363454	9	2025-07-05 10:45:58.719114	
7361	gaadimech 	8955137418	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-05-21 09:52:54.707866	9	2025-07-05 10:46:51.618895	
7370	gaadimech 	9119123364	2025-07-30 18:30:00	Did Not Pick Up	Not picking up twice 	2025-05-21 12:07:10.634243	9	2025-07-05 10:48:07.415434	
7385	gaadimech 	9782778007	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-22 08:33:24.712628	9	2025-07-05 10:48:54.600034	
7390	gaadinech	9766092309	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-22 08:38:08.757954	9	2025-07-05 10:49:42.7352	
7391	gaadimech 	9828859808	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-22 08:38:50.292438	9	2025-07-05 10:50:49.865405	
7405	gaadimech 	7222835222	2025-10-22 18:30:00	Did Not Pick Up	Not interested 	2025-05-23 05:28:51.638199	9	2025-07-05 11:05:41.845248	
7411	gaadimech 	9929955990	2025-08-09 18:30:00	Needs Followup	\tI10 2299	2025-05-23 05:59:05.921985	9	2025-07-06 05:24:32.161893	
6571	ARVIND JI	8059670455	2025-07-03 18:30:00	Completed	not have a car 	2025-04-22 10:27:02.908094	9	2025-07-05 10:56:37.373708	
7413	gaadimech 	7877216587	2025-08-09 18:30:00	Needs Followup	\tAlto 2399	2025-05-23 06:09:35.855144	9	2025-07-06 05:24:47.739364	
7431	Cx2041	9654575851	2025-08-09 18:30:00	Needs Followup	Dzire service	2025-05-23 09:46:19.418175	9	2025-07-06 05:25:02.906443	
6838	Vc1156	9413838777	2025-08-09 18:30:00	Needs Followup	\tCar service	2025-05-02 07:06:57.355316	9	2025-07-06 06:32:41.302847	
6929	gaadimech 	9521247651	2025-08-09 18:30:00	Did Not Pick Up	Verna ac checkup 999 Out of station	2025-05-07 05:13:15.601508	9	2025-07-06 06:32:54.714683	
7261	gaadimech 	6377039790	2025-08-09 18:30:00	Did Not Pick Up	\tAmaze 3199 service vki	2025-05-17 06:27:27.544341	9	2025-07-06 06:33:06.301952	
7138	Cx2006	8882125658	2025-08-09 18:30:00	Needs Followup	Wr service 2599	2025-05-13 06:57:56.589811	9	2025-07-06 06:33:19.907327	
7434	Cx2045	8829904909	2025-08-09 18:30:00	Needs Followup	Car service\t\n	2025-05-23 09:50:43.829967	9	2025-07-06 05:25:18.175421	
7583	gaadimech 	9024132606	2025-07-30 18:30:00	Did Not Pick Up	Dzire 2999\r\nService done	2025-05-29 11:23:20.221961	6	2025-06-28 06:53:27.674086	
3470	gaadimech 	9887720111	2025-07-29 18:30:00	Needs Followup	Jazz dent paint  1800 	2025-01-27 04:07:45.870122	6	2025-06-29 09:39:49.238342	
7441	gaadimech 	8638043063	2025-08-09 18:30:00	Did Not Pick Up	\tEco sport bumper paint	2025-05-24 05:49:30.173025	9	2025-07-06 05:25:35.665301	
2303	.	9413825873	2025-07-03 18:30:00	Needs Followup	Abhi nahi 	2024-12-21 08:31:22.208151	4	2025-06-30 13:06:04.105746	
2317	.	9829026849	2025-07-17 18:30:00	Needs Followup	Car service swift 	2024-12-21 08:31:22.208151	4	2025-06-30 13:14:30.556341	
785	.	9829380821	2025-07-01 18:30:00	Needs Followup	Call not pick \r\nSwitch off 	2024-12-02 04:50:36	4	2025-06-30 13:18:21.289021	
7609	gaadimech 	8107433043	2025-08-09 18:30:00	Did Not Pick Up	\tNot pick	2025-05-30 09:47:24.654499	9	2025-07-06 05:48:04.624711	
5107	Rajkumar 	9314074008	2025-07-02 18:30:00	Did Not Pick Up	Not interested 	2025-03-26 10:49:55.857057	6	2025-06-28 09:09:52.935147	
7464	Cx2045	9667549029	2025-08-09 18:30:00	Needs Followup	\tCar service	2025-05-24 09:36:57.058398	9	2025-07-06 05:25:49.525073	
7485	Cx2045	8107113073	2025-08-09 18:30:00	Did Not Pick Up	\tCall cut	2025-05-25 05:04:05.894807	9	2025-07-06 05:26:02.377443	
7489	Cx 2046	8955045716	2025-08-09 18:30:00	Needs Followup	\tDent paint	2025-05-25 05:07:51.662869	9	2025-07-06 05:26:15.496185	
7494	gaadimech 	9166623578	2025-08-09 18:30:00	Did Not Pick Up	Dzire service 2999	2025-05-25 05:43:04.717952	9	2025-07-06 05:26:34.425121	
7496	gaadimech 	9829958344	2025-08-09 18:30:00	Needs Followup	\tI10 2299	2025-05-25 05:50:14.698355	9	2025-07-06 05:26:49.271232	
7504	Cx2049	8619661475	2025-08-09 18:30:00	Needs Followup	Car service	2025-05-27 08:44:28.298123	9	2025-07-06 05:27:02.775698	
7507	Cx2051	8690575384	2025-08-09 18:30:00	Needs Followup	\tCar paint	2025-05-27 08:46:44.973013	9	2025-07-06 05:27:15.310572	
7511	Cx2056	9413563717	2025-08-09 18:30:00	Needs Followup	Call cut	2025-05-27 08:49:27.316406	9	2025-07-06 05:27:26.952175	
7521	Cx2061	9887050969	2025-08-09 18:30:00	Needs Followup	\tCar service No answer	2025-05-27 08:57:51.21038	9	2025-07-06 05:27:39.820449	
7523	Cx2064	8441925628	2025-08-09 18:30:00	Needs Followup	Ac service\t\n	2025-05-27 09:04:41.657152	9	2025-07-06 05:27:54.300203	
7540	Cx2063	9950285110	2025-08-09 18:30:00	Needs Followup	\tSwift service 2899	2025-05-28 06:54:05.751918	9	2025-07-06 05:29:19.771019	
7564	Cx2071	9887333637	2025-08-09 18:30:00	Needs Followup	\tCar service	2025-05-29 05:22:04.611731	9	2025-07-06 05:29:36.504422	
7567	gaadimech 	9352589835	2025-08-09 18:30:00	Did Not Pick Up	\tK10 2399	2025-05-29 07:02:03.34681	9	2025-07-06 05:30:53.829406	
7572	gaadimech	9887125118	2025-08-09 18:30:00	Did Not Pick Up	Nit pick	2025-05-29 08:21:06.947776	9	2025-07-06 05:46:08.16903	
7581	gaadimech 	9351585611	2025-08-09 18:30:00	Did Not Pick Up	\tDent paint	2025-05-29 11:20:11.235841	9	2025-07-06 05:46:25.481057	
7587	gaadimech 	9828090161	2025-08-09 18:30:00	Needs Followup	\tFord Fiesta 3999	2025-05-29 11:40:24.483408	9	2025-07-06 05:46:38.492326	
7590	gaadimech	9314398952	2025-08-09 18:30:00	Did Not Pick Up	Not pick I10 Dent paint call cut	2025-05-30 04:27:40.152469	9	2025-07-06 05:46:51.982826	
7591	gaadimech 	9828115600	2025-08-09 18:30:00	Did Not Pick Up	\tAlto 2399 call cut	2025-05-30 04:32:18.183883	9	2025-07-06 05:47:04.113307	
7592	gaadimech 	9214901374	2025-08-09 18:30:00	Did Not Pick Up	\tBusy call u later	2025-05-30 04:33:52.246457	9	2025-07-06 05:47:16.711974	
7597	gaadimech	9636595822	2025-08-09 18:30:00	Did Not Pick Up	Busy call u later	2025-05-30 04:56:34.370936	9	2025-07-06 05:47:41.394222	
7602	Cx2072	9116181686	2025-08-09 18:30:00	Needs Followup	Paint Call cut	2025-05-30 05:11:37.137627	9	2025-07-06 05:47:52.656334	
7610	Cx2072	9352513118	2025-08-09 18:30:00	Needs Followup	\tCaiz dent paint 2800 Call cut	2025-05-30 10:15:00.095165	9	2025-07-06 05:48:16.467768	
7614	Cx2079	8955344459	2025-08-09 18:30:00	Needs Followup	\tHonda Amaze\n	2025-05-30 10:19:34.297571	9	2025-07-06 05:48:29.685331	
7618	Cx2082	9414297511	2025-08-09 18:30:00	Needs Followup	\ti20 service	2025-05-30 10:23:03.472518	9	2025-07-06 05:48:41.311967	
7619	gaadimech 	9549367310	2025-08-09 18:30:00	Did Not Pick Up	\tCall cut	2025-05-30 12:06:44.102939	9	2025-07-06 05:48:53.094266	
7621	gaadimech 	9462823255	2025-08-09 18:30:00	Did Not Pick Up	\tTiago 3199 Call cut	2025-05-30 12:12:45.108263	9	2025-07-06 05:49:07.3407	
7625	gaadimech 	9660328222	2025-08-09 18:30:00	Did Not Pick Up	Not pick	2025-05-31 04:50:01.997747	9	2025-07-06 05:49:19.385743	
7628	Cx2081	9910957594	2025-08-09 18:30:00	Needs Followup	Car service No answer	2025-05-31 05:07:41.824126	9	2025-07-06 05:49:36.971729	
7632	Cx2084	9509060432	2025-08-09 18:30:00	Needs Followup	\tSantro 2699	2025-05-31 05:12:29.887068	9	2025-07-06 05:49:49.369866	
7633	gaadimech 	9653713741	2025-08-09 18:30:00	Did Not Pick Up	\tEon 2299 call cut	2025-05-31 06:49:19.09212	9	2025-07-06 05:50:04.216205	
7643	gaadimech 	7976572216	2025-08-09 18:30:00	Did Not Pick Up	Call cut	2025-05-31 08:37:52.293536	9	2025-07-06 05:50:17.160934	
7663	Cx2094	6376527250	2025-08-09 18:30:00	Needs Followup	\tXuv 300 Fender dent paint 2199 ek parts	2025-06-01 05:09:27.085908	9	2025-07-06 05:50:29.61703	
7667	Beat 	9829362919	2025-08-09 18:30:00	Needs Followup	\tBeat service Dent paint 8 parts	2025-06-01 05:17:27.767828	9	2025-07-06 05:50:44.271411	
7681	Cx2094	7073742735	2025-08-09 18:30:00	Did Not Pick Up	No answer	2025-06-02 05:41:44.408128	9	2025-07-06 05:51:08.368914	
7682	Cx2094	7982126584	2025-08-09 18:30:00	Needs Followup	Dzire	2025-06-02 05:42:24.474027	9	2025-07-06 05:51:19.496063	
7686	Cx2094	7827066084	2025-08-09 18:30:00	Needs Followup	\tAura dent paint	2025-06-02 05:45:02.133906	9	2025-07-06 05:51:30.51653	
7688	Cx2097	8128081103	2025-08-09 18:30:00	Needs Followup	\tVki Swift service	2025-06-02 05:46:09.965208	9	2025-07-06 05:51:43.776026	
7691	Cx2098	7014479889	2025-08-09 18:30:00	Needs Followup	\tDzire service	2025-06-02 06:10:16.878028	9	2025-07-06 05:51:54.826188	
97	Cx26	8209144278	2025-08-09 18:30:00	Needs Followup	\tPolo 4 parts Follow up ke liye Complete Feedback call Feedback call	2024-11-23 13:04:48	9	2025-07-06 05:52:08.66455	\N
104	Cx31	9829498186	2025-08-09 18:30:00	Needs Followup	\tAudi Service	2024-11-23 13:09:57	9	2025-07-06 05:52:20.304179	\N
522	Cx90	8469217364	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-11-28 06:03:20	9	2025-07-06 05:52:33.609944	\N
616	Cx 86	8233387626	2025-08-09 18:30:00	Needs Followup	\tNo answer	2024-11-30 09:37:30	9	2025-07-06 05:52:45.916963	\N
841	Cx107	7877877975	2025-08-09 18:30:00	Needs Followup	\tBumper paint Accent	2024-12-02 04:50:36	9	2025-07-06 05:52:59.216568	\N
850	Cx104	7878907433	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-02 04:50:36	9	2025-07-06 05:53:10.966718	\N
901	Cx117	8194097699	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-12-03 05:16:04	9	2025-07-06 05:53:23.391155	\N
1070	Cx107	8949473203	2025-08-09 18:30:00	Needs Followup	\tNo answer	2024-12-04 05:17:16	9	2025-07-06 05:53:38.810296	\N
1074	Cx111	6375686439	2025-08-09 18:30:00	Needs Followup	\tNo answer	2024-12-04 05:17:16	9	2025-07-06 05:53:50.439202	\N
1076	Cx113	9571800140	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-04 05:17:16	9	2025-07-06 06:19:16.746282	\N
1083	Cx116	8815752970	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-04 11:58:59	9	2025-07-06 06:19:28.116332	\N
7679	Cx2091	9001048563	2025-08-10 18:30:00	Did Not Pick Up	\tNo answer	2025-06-02 05:40:20.768105	9	2025-07-06 06:21:24.813437	
7762	Ac service 	8502003726	2025-07-05 18:30:00	Needs Followup	Ac service 	2025-06-30 04:46:57.231052	4	2025-07-04 08:50:55.869664	
1091	CX 118	7073020140	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-04 11:58:59	9	2025-07-06 06:19:46.276264	\N
2806	Cx165	9772689293	2025-07-06 18:30:00	Needs Followup	Amaze \r\n	2025-01-10 04:20:50.707156	9	2025-07-06 06:20:34.934195	\N
2562	CX 137	8290706269	2025-08-09 18:30:00	Needs Followup	Call cut	2025-01-02 12:06:04.008231	9	2025-07-06 06:31:44.141147	\N
2582	Cx138	7014650488	2025-07-06 00:00:00	Needs Followup	Swift service \r\n2699	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	\N
2586	Cx139	6378707202	2025-07-06 00:00:00	Needs Followup	Verna Dent paint \r\nBani park \r\n2200 ek part 	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	\N
2587	Cx142	9660953070	2025-07-06 00:00:00	Needs Followup	Duster\r\nDent paint 	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	\N
2590	Cx145	7062179919	2025-07-06 00:00:00	Needs Followup	Etios Dent paint \r\n24000	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	\N
2591	Cx146	9828076488	2025-07-06 00:00:00	Needs Followup	Zen service \r\n	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	\N
2604	Cx148	9694908591	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-06 07:43:58.961994	\N
2605	Cx149	9694908591	2025-07-06 00:00:00	Needs Followup	Swift 2699 \r\n	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2820	Cx174	9785786543	2025-07-06 00:00:00	Needs Followup	Polo \r\nBanin park \r\nEngine work	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2951	Cx172	9530190334	2025-07-06 00:00:00	Needs Followup	Tata tiago service \r\n 2499	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
1152	Cx123	9588810749	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-06 08:38:44	9	2025-07-06 06:25:26.821774	\N
1300	Customer	8824999991	2025-08-09 18:30:00	Needs Followup	\tkalwar Rd, washing. unanswered	2024-12-07 05:46:09	9	2025-07-06 06:25:40.572089	\N
1326	Cx124	8619150956	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-12-07 05:46:09	9	2025-07-06 06:26:11.049165	\N
1336	Cx126	7878963251	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-12-07 05:46:09	9	2025-07-06 06:26:22.255293	\N
1346	Cx129	9799808794	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-12-07 05:46:09	9	2025-07-06 06:26:32.584108	\N
1369	Lokesh	8000740078	2025-08-09 18:30:00	Needs Followup	\tCus want call back on 21-jan	2024-12-07 05:46:09	9	2025-07-06 06:26:45.20273	\N
1371	Customer	9521101613	2025-08-09 18:30:00	Needs Followup	\tcall back on what's app, i10 & corolla altis	2024-12-07 05:46:09	9	2025-07-06 06:26:57.994088	\N
1665	mukesh choudhary	9828330261	2025-08-09 18:30:00	Needs Followup	Washing lead,	2024-12-11 07:05:55	9	2025-07-06 06:27:16.317843	\N
1724	Cx128	7021866278	2025-08-09 18:30:00	Needs Followup	\tSwitch off	2024-12-13 04:40:11	9	2025-07-06 06:27:30.646539	\N
1726	Cx129	8005583429	2025-08-09 18:30:00	Needs Followup	\tCall cut	2024-12-13 04:40:11	9	2025-07-06 06:27:42.495925	\N
1728	Cx130	7611066682	2025-08-09 18:30:00	Needs Followup	\ti20 Drycleaning	2024-12-13 04:40:11	9	2025-07-06 06:27:54.197358	\N
1742	Cx136	7023015416	2025-08-09 18:30:00	Needs Followup	\tS cross Service	2024-12-13 04:40:11	9	2025-07-06 06:28:06.50093	\N
1886	Cx139	9413888866	2025-08-09 18:30:00	Needs Followup	Ppf seltos	2024-12-14 12:39:55	9	2025-07-06 06:28:18.197204	\N
2118	Cx147	8562820633	2025-08-09 18:30:00	Needs Followup	\tKwid Service done on 17th Feedback of service Acchi h service costume Happy	2024-12-17 11:10:05.840506	9	2025-07-06 06:28:31.595144	\N
2207	Aditya Verma	9314052174	2025-08-09 18:30:00	Needs Followup	cus want call on sunday and he also visit on sunday	2024-12-20 04:42:01.100851	9	2025-07-06 06:28:43.600254	\N
2530	Cx124	9414054822	2025-08-09 18:30:00	Needs Followup	\tCar service	2024-12-30 11:05:48.996851	9	2025-07-06 06:28:56.640893	\N
2534	Cx126	9773311058	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-30 11:47:49.431366	9	2025-07-06 06:29:10.605141	\N
2543	Cx128	8306936536	2025-08-09 18:30:00	Needs Followup	No answer	2024-12-30 11:47:49.431366	9	2025-07-06 06:29:21.330821	\N
2546	Devi shankar	9413239757	2025-08-09 18:30:00	Needs Followup	Honda Brio petrol, 1999 pack shared, cus location agra rd.	2024-12-31 06:23:43.015407	9	2025-07-06 06:29:34.289695	\N
2549	Cx128	8559947200	2025-08-09 18:30:00	Needs Followup	\tG-10 2499 Service	2025-01-01 08:53:47.57208	9	2025-07-06 06:29:48.905567	\N
2550	Cx128	8003397814	2025-08-09 18:30:00	Needs Followup	\tDuster Service 5999	2025-01-01 08:53:47.57208	9	2025-07-06 06:30:02.329385	\N
2551	Cx129	9829666763	2025-08-09 18:30:00	Needs Followup	\tHonda city Dent paint Full Dent paint (24000)	2025-01-01 08:53:47.57208	9	2025-07-06 06:30:15.391913	\N
2552	Cx130 	9057291204	2025-08-09 18:30:00	Needs Followup	\tAlto Dent paint (20000)	2025-01-01 08:53:47.57208	9	2025-07-06 06:30:29.81023	\N
2554	Rahul lakhan	7300452570	2025-08-09 18:30:00	Needs Followup	Accent, package 2199Rs. Cus is visit on15th jan, unanswered	2025-01-02 08:54:19.444473	9	2025-07-06 06:30:41.262896	\N
2557	CX 133	9799887750	2025-08-09 18:30:00	Needs Followup	\tNo answer	2025-01-02 12:06:04.008231	9	2025-07-06 06:30:55.124643	\N
2558	Cx134	7073450472	2025-08-09 18:30:00	Needs Followup	\tEtios Service 3199 Switch off	2025-01-02 12:06:04.008231	9	2025-07-06 06:31:07.037651	\N
2559	Cx134	9413390645	2025-08-09 18:30:00	Needs Followup	\tSeltos car service 2999	2025-01-02 12:06:04.008231	9	2025-07-06 06:31:19.719729	\N
2560	Cx135	9024829408	2025-08-09 18:30:00	Needs Followup	\tDrycleaning Bolero/santro	2025-01-02 12:06:04.008231	9	2025-07-06 06:31:32.435865	\N
2565	Cx137	9694653655	2025-08-09 18:30:00	Needs Followup	\tCar service	2025-01-02 12:06:04.008231	9	2025-07-06 06:31:56.299542	\N
2568	Cx136	9990565686	2025-08-09 18:30:00	Needs Followup	\tCelerio Service 2199	2025-01-02 12:06:04.008231	9	2025-07-06 06:32:09.265653	\N
2571	Cx137	9256419515	2025-08-09 18:30:00	Needs Followup	\tCar service	2025-01-02 12:06:04.008231	9	2025-07-06 06:32:31.33595	\N
2593	Tejendra Singh	7357960205	2025-07-07 18:30:00	Confirmed	THAR DIESEL NEED PAINT WORK 28550 RS AND CONNECT ON WP	2025-01-06 11:15:01.167732	9	2025-07-06 07:40:14.603297	RJ20UC0123
2608	Cx152	8979232237	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-06 07:47:35.560741	\N
2611	Cx157	9413023322	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-07 04:42:15.913695	9	2025-07-06 07:48:51.171645	\N
2722	Cx157	8619668207	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-08 11:00:12.657946	9	2025-07-06 08:02:02.60693	\N
2723	Cx157	8952813781	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-08 11:00:12.657946	9	2025-07-06 08:03:09.182836	\N
2794	Customer	7597050930	2025-07-04 18:30:00	Needs Followup	out of service	2025-01-10 04:20:50.707156	9	2025-07-06 09:43:00.889922	\N
2822	Cx176	7728845348	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-11 04:14:05.019885	9	2025-07-06 08:15:34.24209	\N
2839	Cx163	9785027004	2025-08-13 18:30:00	Needs Followup	Honda city petrol service 	2025-01-11 12:38:10.703782	9	2025-07-06 08:19:11.257561	\N
2901	Customer	9829012417	2025-07-31 18:30:00	Needs Followup	Not picking thrice 	2025-01-12 04:36:11.819946	9	2025-07-06 08:20:38.167769	\N
2954	Cx178	7976415341	2025-08-12 18:30:00	Needs Followup	Tata tiago connect for service 	2025-01-13 04:34:12.585813	9	2025-07-06 08:27:40.055691	\N
2956	Cx178	9166984139	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-13 04:34:12.585813	9	2025-07-06 08:29:16.694745	\N
2792	Govind Mittal	9829129771	2025-07-04 18:30:00	Needs Followup	Not have a car and not from jaipur	2025-01-10 04:20:50.707156	9	2025-07-06 09:42:47.190433	\N
2958	Cx179	9252234387	2025-07-04 18:30:00	Needs Followup	Not have a car	2025-01-13 04:34:12.585813	9	2025-07-06 09:42:33.668698	\N
4853	sanjay sharma 	9529834949	2025-08-21 18:30:00	Feedback	Thar  ac check \r\nTotal Payment - 1998 cash \r\nFeedback \r\n4/04/2025 same issue repeat 	2025-03-19 05:25:47.415684	6	2025-06-29 06:57:41.469715	RJ45CR1001
3025	Satyam 	9309260546	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-13 09:02:24.989067	9	2025-07-06 08:31:22.820472	\N
7752	gaadiemch 9799968107	9799972966	2025-07-04 18:30:00	Did Not Pick Up	Not pick \r\nDry clining 	2025-06-29 10:28:09.637381	6	2025-07-02 10:17:28.63547	
7756	gaadimech 	9783247773	2025-07-02 18:30:00	Did Not Pick Up	Not pick 	2025-06-29 10:43:03.777016	6	2025-06-30 06:28:53.467847	
2967	Customer	9829167067	2025-07-06 00:00:00	Needs Followup	Call cut\r\nNot pick	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
3036	Customer	9784532569	2025-10-22 18:30:00	Needs Followup	Not required 	2025-01-13 09:02:24.989067	9	2025-07-06 08:32:51.145216	\N
7753	gaadimech	9649171617	2025-07-02 18:30:00	Did Not Pick Up	Dzire 2999 call back after 3 days	2025-06-29 10:32:14.320243	6	2025-06-30 06:39:38.688065	
7754	gaadimech	9001991453	2026-01-09 18:30:00	Did Not Pick Up	Not pick \r\nUdaipur 	2025-06-29 10:38:45.946318	6	2025-06-30 06:40:10.402706	
3040	Vikash	9785558886	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-13 09:02:24.989067	9	2025-07-06 08:34:11.135428	\N
3054	Cx185	9672864170	2025-07-06 00:00:00	Needs Followup	Swift paint \r\n28000	2025-01-15 06:44:10.074469	9	2025-07-01 06:50:29.884428	\N
3089	Cx189	8386962176	2025-07-06 00:00:00	Needs Followup	Wr 2199	2025-01-16 11:14:31.747592	9	2025-07-01 06:50:29.884428	\N
3090	Cx189	9664141067	2025-07-06 00:00:00	Needs Followup	Etios Dent paint\r\nComplete done \r\nFeedback call 3 day	2025-01-16 12:57:53.461976	9	2025-07-01 06:50:29.884428	\N
3091	Cx187	7891120152	2025-07-06 00:00:00	Needs Followup	Verna Dent paint \r\nComplete done \r\nFeedback call 3 day	2025-01-16 12:57:53.461976	9	2025-07-01 06:50:29.884428	\N
3092	Cx187	8290706269	2025-07-06 00:00:00	Needs Followup	Safari 4999\r\nService done \r\nFeedback call 3 	2025-01-16 12:57:53.461976	9	2025-07-01 06:50:29.884428	\N
3093	Praveen ji	7976415341	2025-07-06 00:00:00	Needs Followup	Cus visit on Sunday Bani park	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	\N
3097	Cx193	9982959494	2025-07-06 00:00:00	Needs Followup	No answer 	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	\N
3098	Cx194	8923545861	2025-07-06 00:00:00	Needs Followup	Honda City diggi \r\nDent paint 	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	\N
3114	Cx199	8952016642	2025-07-06 00:00:00	Needs Followup	Scorpio wedding \r\nAjmer road 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	\N
3133	Cx205	9664483692	2025-07-06 00:00:00	Needs Followup	No answer 	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	\N
3208	MO. Arsalan	9887029293	2025-07-06 00:00:00	Needs Followup	Cus need call back on Wednesday 22/01	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3218	Anit 	9887067337	2025-07-06 00:00:00	Needs Followup	Wagnor 2299\r\n500 me bhahar all gaadi genrat check up ho jata h  with washing nd cleaning package jyada h apka	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3228	Ayush	9001436050	2025-07-06 00:00:00	Needs Followup		2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3325	Customer 	9672068516	2025-07-06 00:00:00	Needs Followup	Service amaze 2999	2025-01-23 04:13:07.245769	9	2025-07-01 06:50:29.884428	\N
7549	gaadimech 	9982366663	2025-08-08 18:30:00	Did Not Pick Up	Swift 2799\r\nnot intrested 	2025-05-28 11:57:49.119959	6	2025-06-28 06:54:54.720473	
7491	gaadimech 	7891329017	2025-07-03 18:30:00	Did Not Pick Up	Alto 2399 5000 km due h\r\nNot pick 	2025-05-25 05:27:35.528211	6	2025-06-28 06:58:06.970239	
5102	Customer 	9983877787	2025-07-11 18:30:00	Did Not Pick Up	Call cut	2025-03-26 10:02:38.075795	6	2025-06-28 09:13:39.273031	
5099	Ajeet Singh 	9829282574	2025-07-18 18:30:00	Did Not Pick Up	Not interested \r\nNot pick 	2025-03-26 10:01:27.008639	6	2025-06-28 09:15:08.746695	
5097	Customer 	9887417794	2025-07-04 18:30:00	Did Not Pick Up		2025-03-26 09:22:23.103312	6	2025-06-28 09:16:24.18195	
3326	Ravish Aman 	7849869588	2025-07-06 00:00:00	Needs Followup	PPF ,\r\nThar roxx, cus not confirmed visit timing & date.\r\nUnanswered \r\n\r\nVisit today 	2025-01-23 04:13:07.245769	9	2025-07-01 06:50:29.884428	\N
3339	Shiv Kumar soni	9829541319	2025-07-06 00:00:00	Needs Followup	Package  -2699Rs\r\nCus will visit or call back on sunday	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	\N
3354	Ram singh	8696676726	2025-07-06 00:00:00	Needs Followup	Service package -2899Rs\r\nAir Filter -380Rs\r\nAC filter -370\r\nDiesel filter - 1500\r\nERG & intake-2999\r\nEngine flashing - 650\r\nRadiator flashing -850\r\nCoolant -280Rs Per L\r\nWheel Balancing charge extra\r\n\r\nEstimate shared to cus he will confirmed 	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	\N
3356	Deepak Rastogi	9829013353	2025-07-06 00:00:00	Needs Followup	Cus is not pickup my calls, unanswered, again unanswered	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	\N
209	Cx38	7300007364	2025-07-06 00:00:00	Needs Followup	Swift \r\nDent paint 	2024-11-24 12:31:06	9	2025-07-01 06:50:29.884428	
241	CX	7220816516	2025-07-06 00:00:00	Needs Followup	Tata tiago \r\nBumper paint 2200\r\nFollow up ke liye call 	2024-11-25 07:47:47	9	2025-07-01 06:50:29.884428	
280	Cx55	8000078902	2025-07-06 00:00:00	Needs Followup	Insurance work	2024-11-25 12:10:49	9	2025-07-01 06:50:29.884428	
298	Cx64	9024560090	2025-07-06 00:00:00	Needs Followup	Call cut\r\n\r\n\r\n	2024-11-26 08:26:12	9	2025-07-01 06:50:29.884428	
660	Cx93	7404304847	2025-07-06 00:00:00	Needs Followup	Nexon 3199	2024-11-30 12:05:01	9	2025-07-01 06:50:29.884428	
740	Cx100	9549452168	2025-07-06 00:00:00	Needs Followup	Beat \r\nBumper paint 2000	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	
895	110	8904466084	2025-07-06 00:00:00	Needs Followup	Eon \r\nAjmer road \r\n\r\n\r\n\r\n	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	
1077	Cx113	6376765495	2025-07-06 00:00:00	Needs Followup	Verna \r\nBonut aur roof dent paint 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1080	CX 118	7850807726	2025-07-06 00:00:00	Needs Followup	Baleno paint	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	
1150	Cx122	8302163660	2025-07-06 00:00:00	Needs Followup	Car service 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	
1154	Cx124	7877472168	2025-07-06 00:00:00	Needs Followup	No answer 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	
1158	Cx126	9782559166	2025-07-06 00:00:00	Needs Followup	No answer 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	
1340	Cx128	8949541259	2025-07-06 00:00:00	Needs Followup	Car service aur ac 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1344	Cx128	8003735959	2025-07-06 00:00:00	Needs Followup	Car service 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
3048	Rahul prajapat	7742067066	2025-08-21 18:30:00	Needs Followup	Not interested 	2025-01-15 05:41:49.663902	9	2025-07-06 09:07:23.114829	\N
3049	Cx180	7610808385	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-15 06:44:10.074469	9	2025-07-06 09:09:36.143523	\N
3056	Cx186	7073706605	2025-12-30 18:30:00	Needs Followup	Brio service call 	2025-01-15 06:44:10.074469	9	2025-07-06 09:13:04.834037	\N
3086	Cx183	9001793140	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-16 11:14:31.747592	9	2025-07-06 09:17:08.875595	\N
620	Cx87	7300066685	2025-07-31 18:30:00	Needs Followup	Not picking 	2024-11-30 09:37:30	9	2025-07-06 09:26:00.192622	
3094	Aditi	7742819200	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-01-17 04:24:01.411996	9	2025-07-06 09:26:55.321311	\N
3051	Cx182	8057721717	2025-07-04 18:30:00	Needs Followup	\tNot from jaipur	2025-01-15 06:44:10.074469	9	2025-07-06 09:43:48.331505	\N
7379	gaadimech 	9829004301	2025-07-03 18:30:00	Needs Followup	Wagnor 2599  not pick	2025-05-22 05:20:01.420386	6	2025-06-28 07:03:47.94216	
4734	Eon 	9079825564	2025-07-03 18:30:00	Needs Followup	Eon 1999	2025-03-13 11:33:03.707008	4	2025-06-28 07:10:50.057111	
4415	gaadimech	7891341574	2025-07-24 18:30:00	Needs Followup	Nishan micra 	2025-02-27 04:47:43.852992	4	2025-06-28 09:37:09.130169	
1348	Cx131	9352555743	2025-07-06 00:00:00	Needs Followup	Car dent paint 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
7717	gaadimech 	9636457413	2025-07-17 18:30:00	Did Not Pick Up	Not pick call cut	2025-06-28 07:05:49.92162	6	2025-06-30 07:58:46.680902	
532	.	9928194666	2025-07-02 18:30:00	Did Not Pick Up	Cut a call 	2024-11-28 12:42:48	6	2025-06-29 08:40:59.504537	
3234	customer 	7424826202	2025-07-18 18:30:00	Did Not Pick Up	5000km due xuv 300 3699 package\r\nNt pick	2025-01-20 04:31:19.397625	6	2025-06-29 10:52:48.15441	
2643	Ramjash 	9828329185	2025-07-18 18:30:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	6	2025-06-29 10:57:14.866028	
2252	Dinesh Sharma 	8952063320	2025-07-18 18:30:00	Did Not Pick Up	WhatsApp package shared \r\nCall cut	2024-12-20 08:28:57.743192	6	2025-06-29 11:03:03.799551	
7782	Drycleaning 	9166101962	2025-07-02 18:30:00	Needs Followup	Drycleaning \r\nMehga hai 	2025-07-01 04:41:22.051573	4	2025-07-04 08:32:55.974791	9166101962
1666	Pankaj saini	9929955990	2025-07-06 00:00:00	Did Not Pick Up	location sent Call cut\r\n	2024-12-11 07:05:55	9	2025-07-01 06:50:29.884428	
2594	gaadimech 	9782048838	2025-07-06 00:00:00	Needs Followup	Xcent 2799 Car service 	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	
4248	.	7903584441	2025-07-06 00:00:00	Needs Followup	Car service \r\nFeedback call \r\nNo problem 	2025-02-20 07:35:16.789676	9	2025-07-01 06:50:29.884428	
4300	.	9899959672	2025-07-06 00:00:00	Did Not Pick Up	Not requirement 	2025-02-22 11:30:12.731218	9	2025-07-01 06:50:29.884428	
4341	gaadimech 	7014953132	2025-07-06 00:00:00	Did Not Pick Up	Mene koi interest show nahi kia h\r\nCall cut	2025-02-24 07:23:08.076954	9	2025-07-01 06:50:29.884428	
4454	gaadimech	8949132130	2025-07-06 00:00:00	Did Not Pick Up	Santro  ac check up	2025-03-01 10:34:28.664938	9	2025-07-01 06:50:29.884428	
5126	Micra 2499	9571142186	2025-07-06 00:00:00	Completed	Micra 2499\r\nTotal Payment - 28600\r\nFeedback \r\nAbhi car use nahi ki	2025-03-27 05:36:02.711056	9	2025-07-01 06:50:29.884428	RJ14CK5054
6110	Pratik ji 	9928341197	2025-07-06 00:00:00	Completed	Swift 2799\r\nFeedback call \r\nNo problem Day 1 \r\nGood service Day 2 	2025-04-16 09:00:37.940562	9	2025-07-01 06:50:29.884428	
6317	i20(ac gas)	8302247982	2025-07-06 00:00:00	Completed	i20\r\nAc service \r\nFeedback call \r\nWashing issue\r\nNo answer \r\n	2025-04-19 06:41:38.276411	9	2025-07-01 06:50:29.884428	
6616	Ghanshyaam Sharma 	8239430151	2025-07-06 00:00:00	Completed	Mobilio service 3999\r\nTotal Payment - 16219 ( online) \r\nBigg boss\r\nNo answer \r\nGood service \r\nService acchi hai Day 1 \r\nSub ok \r\n\r\n	2025-04-23 07:56:20.914796	9	2025-07-01 06:50:29.884428	RJ59UA0756
6653	gaadimech 	7791931006	2025-07-06 00:00:00	Did Not Pick Up	Tata safari 5999	2025-04-25 09:55:00.630354	9	2025-07-01 06:50:29.884428	
6785	gaadimech 	9982404841	2025-07-06 00:00:00	Did Not Pick Up	Bolero dent paint 	2025-04-29 05:30:33.083575	9	2025-07-01 06:50:29.884428	
6844	gaadimech 	9549269000	2025-07-06 00:00:00	Did Not Pick Up	Scala 1999	2025-05-02 09:24:00.9541	9	2025-07-01 06:50:29.884428	
6930	gaadimech 	7611047712	2025-07-06 00:00:00	Did Not Pick Up	Not pick 	2025-05-07 05:14:07.324288	9	2025-07-01 06:50:29.884428	
7063	gaadimech 	9772848903	2025-07-06 00:00:00	Did Not Pick Up	Not pick 	2025-05-10 07:21:35.478847	9	2025-07-01 06:50:29.884428	
7124	gaadiemch	6350659685	2025-07-06 00:00:00	Did Not Pick Up	Xuv 3oo 3899\r\nOut of jaipur	2025-05-13 05:03:39.085542	9	2025-07-01 06:50:29.884428	
7183	gaadimech 	8107899207	2025-07-06 00:00:00	Did Not Pick Up	Tiago 3199 not pick 	2025-05-14 11:25:36.914738	9	2025-07-01 06:50:29.884428	
7199	Vaibhav	9610771717	2025-07-06 00:00:00	Completed	Completed dent paint \r\ni20 dent paint \r\nFeedback call \r\nAcchi service 	2025-05-15 10:01:00.352382	9	2025-07-01 06:50:29.884428	
7321	gaadimech	9351851212	2025-07-06 00:00:00	Did Not Pick Up	Wagnore 2599	2025-05-20 05:39:10.980706	9	2025-07-01 06:50:29.884428	
7329	sanjiv ji gaadimech 	9828518889	2025-07-06 00:00:00	Feedback	I20 ac  ajmer road\r\n1000 cash 	2025-05-20 09:11:40.615769	9	2025-07-01 06:50:29.884428	
7335	Gaadimech 	8239742057	2025-07-06 00:00:00	Did Not Pick Up	Kwid ac 999	2025-05-20 12:26:41.335867	9	2025-07-01 06:50:29.884428	
7352	gaadimech 	8233172864	2025-07-06 00:00:00	Did Not Pick Up	Venue 3399	2025-05-21 06:52:37.782893	9	2025-07-01 06:50:29.884428	
7357	gaadimech 	9509855835	2025-07-06 00:00:00	Did Not Pick Up	Alto 1799 panel charge	2025-05-21 07:58:00.089807	9	2025-07-01 06:50:29.884428	
7368	Santa Fe 	9911293133	2025-07-06 00:00:00	Completed	Service \r\nFeedback call 	2025-05-21 11:09:55.036779	9	2025-07-01 06:50:29.884428	
7376	gaadimech 	8890935553	2025-07-06 00:00:00	Did Not Pick Up	Polo 3899 tonk road 	2025-05-22 05:11:17.759399	9	2025-07-01 06:50:29.884428	
7599	gaadimech 	8209064185	2025-07-30 18:30:00	Needs Followup	Not picking 	2025-05-30 05:08:17.627857	9	2025-07-06 07:17:07.907816	
7634	gaadimech	7790913982	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-31 06:52:55.604998	9	2025-07-06 06:51:57.177185	
7608	gaadimech	9571392004	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-30 09:43:46.152887	9	2025-07-06 06:52:41.117356	
7605	gaadimech	9950060640	2025-07-30 18:30:00	Feedback	Not picking 	2025-05-30 06:02:01.313252	9	2025-07-06 06:54:11.477669	RJ14UB3516
7579	gaadimech 	9442246792	2025-07-30 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 10:26:01.919987	9	2025-07-06 07:18:19.957857	
7574	Anup ji 	9982946281	2025-11-05 18:30:00	Needs Followup	follow up for service	2025-05-29 08:47:10.960564	9	2025-07-06 07:25:37.686192	
7565	gaadimech 	9462650910	2025-07-31 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 06:59:30.00375	9	2025-07-06 07:29:23.157255	
7562	gaadimech 	9166011031	2025-07-31 18:30:00	Did Not Pick Up	Not picking 	2025-05-29 05:10:27.810798	9	2025-07-06 07:30:48.597457	
7519	Cx2090	9887091889	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-05-27 08:55:53.739514	9	2025-07-06 10:23:39.309566	
7477	gaadimech 	8529671506	2025-07-31 18:30:00	Did Not Pick Up	not picking twice	2025-05-24 11:19:46.839895	9	2025-07-06 09:40:39.59435	
7529	Cx2064	9571774390	2025-07-04 18:30:00	Needs Followup	\tNot have incoming call	2025-05-27 10:47:00.189403	9	2025-07-06 09:42:06.115021	
7499	gaadimech 	9251674309	2025-11-21 18:30:00	Did Not Pick Up	Wagon r Service 	2025-05-25 07:43:21.921329	9	2025-07-06 10:26:22.546782	
7481	gaadimech 	9828396419	2025-11-26 18:30:00	Did Not Pick Up	Glanza service 	2025-05-25 04:59:25.578564	9	2025-07-06 10:27:40.886461	
7462	Cx2042	9950009303	2025-07-15 18:30:00	Needs Followup	Eon Service confirm contact plz	2025-05-24 09:34:29.127769	9	2025-07-06 10:30:13.638916	
7451	gaadimech 	9166225271	2025-07-31 18:30:00	Did Not Pick Up	Not picking 	2025-05-24 06:52:24.603786	9	2025-07-06 10:31:11.145284	
7444	gaadimech 	7388254228	2025-07-31 18:30:00	Did Not Pick Up	Not picking 	2025-05-24 06:11:00.55025	9	2025-07-06 10:31:51.405683	
7424	gaadimech 	9785143920	2025-07-31 18:30:00	Needs Followup	Not picking 	2025-05-23 07:22:10.87359	9	2025-07-06 10:37:23.801246	
7410	gaadimech 	9772108575	2025-10-15 18:30:00	Did Not Pick Up	Service 	2025-05-23 05:54:25.690332	9	2025-07-06 10:38:57.366055	
7392	Naresh Alto 	9571000399	2025-07-04 18:30:00	Completed	Not have incoming call 	2025-05-22 11:23:17.645714	9	2025-07-06 10:39:47.740306	
7387	gaadimech 	8058406452	2025-07-31 18:30:00	Did Not Pick Up	Not picking thrice 	2025-05-22 08:35:03.652671	9	2025-07-06 10:41:07.221564	
6866	gaadimech 	9414369005	2025-07-30 18:30:00	Did Not Pick Up	Tata Tiago 3699\r\nCall u later \r\nNot interested 	2025-05-03 05:44:40.735174	6	2025-06-28 07:16:24.063901	
6854	gaadimech 	8208424972	2025-08-21 18:30:00	Feedback	Punch 3199\r\nService done ajmer road \r\nSatisfied customer 	2025-05-03 05:32:11.219426	6	2025-06-28 07:16:44.074429	
6276	gaadimech 	9461801187	2025-07-03 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-04-18 05:11:55.316638	6	2025-06-28 07:26:16.334162	
6101	gaadimech	8949868332	2025-07-30 18:30:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-04-16 06:50:55.148761	6	2025-06-28 07:27:53.949935	
4293	.	9024505955	2025-07-08 18:30:00	Needs Followup	Mai call kar loga 	2025-02-22 09:55:02.567514	4	2025-06-28 09:43:33.573698	
7182	gaadimech 	9166628888	2025-07-25 18:30:00	Feedback	Ameo ac\r\nJagatpura \r\n1000 qr code jagatpura	2025-05-14 11:24:59.526944	6	2025-06-29 06:57:25.662952	
3010	Customer	9672212006	2025-07-17 18:30:00	Did Not Pick Up	Not pick	2025-01-13 09:02:24.989067	6	2025-06-29 10:54:31.525082	
2742	Customer	9119174090	2025-07-30 18:30:00	Needs Followup	Not pick\r\nBharatpur se hai jaipur aaye to visit krenge\r\nSwift2699\r\nNot pick	2025-01-09 04:06:43.856234	6	2025-06-29 10:55:52.337961	
2725	Pawan	7838018232	2025-07-25 18:30:00	Did Not Pick Up	Call cut \r\nNot pick	2025-01-08 11:00:12.657946	6	2025-06-29 10:56:48.056926	
7785	gaadimech 	9950619585	2025-07-25 18:30:00	Did Not Pick Up	Call cut	2025-07-01 04:48:33.835358	6	2025-07-02 09:19:44.287055	
7784	gaadimech 	9116585115	2025-07-04 18:30:00	Needs Followup	Swift ac out of jaipur 	2025-07-01 04:46:33.682118	6	2025-07-01 04:46:33.682126	
4660	gaadimech	9136790575	2025-07-02 18:30:00	Needs Followup	Aura 2899 \r\nin coming nahi hai voice call 	2025-03-11 07:50:03.914191	4	2025-06-30 13:37:05.208995	
7786	Vki Dzire 	6376875742	2025-07-06 18:30:00	Needs Followup	Ac problem 	2025-07-01 04:49:44.660954	4	2025-07-01 05:05:05.751244	
7637	gaadimech 	7877338815	2025-07-07 00:00:00	Did Not Pick Up	Not pick 	2025-05-31 07:20:11.800906	9	2025-07-01 06:50:29.884428	
7640	Ajay ji 	8560027716	2025-07-07 00:00:00	Completed	Swift service \r\nFeedback call 	2025-05-31 08:20:35.258821	9	2025-07-01 06:50:29.884428	
7661	Cx2091	9479483111	2025-07-07 00:00:00	Needs Followup	Abhi nahi 	2025-06-01 05:07:37.124128	9	2025-07-01 06:50:29.884428	
7665	Cx2094	9029020347	2025-07-07 00:00:00	Needs Followup	i20\r\nDrycleaning 	2025-06-01 05:10:01.698317	9	2025-07-01 06:50:29.884428	
7669	gaadimech	7014640860	2025-07-07 00:00:00	Did Not Pick Up	Ameo 4299  not pick 	2025-06-01 06:52:02.657259	9	2025-07-01 06:50:29.884428	
7677	Cx2090	8233462019	2025-07-07 00:00:00	Needs Followup	Grand i10 service 2999	2025-06-02 05:38:48.140578	9	2025-07-01 06:50:29.884428	
7680	Cx2094	9166932130	2025-07-07 00:00:00	Needs Followup	Dzire service aur ac	2025-06-02 05:40:58.230514	9	2025-07-01 06:50:29.884428	
7687	Cx2098	9660661809	2025-07-07 00:00:00	Needs Followup	i20 dent paint 	2025-06-02 05:45:33.320064	9	2025-07-01 06:50:29.884428	
4	Sarvesh	8952068748	2025-07-07 00:00:00	Needs Followup	Dent paint-26000	2024-11-22 13:16:14	9	2025-07-01 06:50:29.884428	\N
5	Cx 87	8952068748	2025-07-07 00:00:00	Needs Followup	Polo Dent pent 26000, \r\nKal aana hoga Aaj busy the sir	2024-11-22 13:28:00	9	2025-07-01 06:50:29.884428	\N
46	Cx7	9385393952	2025-07-07 00:00:00	Needs Followup	Eon car service 1999	2024-11-23 10:53:27	9	2025-07-01 06:50:29.884428	\N
283	Cx57	8529741928	2025-07-07 00:00:00	Needs Followup	Baleno \r\nDent paint \r\n23000	2024-11-25 12:14:52	9	2025-07-01 06:50:29.884428	\N
341	Cx66	8949616218	2025-07-07 00:00:00	Needs Followup	Baleno \r\nService \r\nSharp 	2024-11-26 12:40:15	9	2025-07-01 06:50:29.884428	\N
1089	Cx116	6367774943	2025-07-07 00:00:00	Needs Followup	Honda city \r\nService \r\n2999	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1763	Hritik soni	9079148344	2025-07-07 00:00:00	Needs Followup	TATA tigor \r\nCall after one month	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
2601	Gaurav kashyap	9887822255	2025-07-07 00:00:00	Needs Followup	Cus visit on 08Jan, \r\nestimated service pack Rs 2199.\r\ncus want followup again	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2640	Manisha	7891948142	2025-07-07 00:00:00	Needs Followup	Not interested \r\nCall cut	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2655	Manoj ji	9829011375	2025-07-07 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2677	Customer	8559912064	2025-07-07 00:00:00	Needs Followup	Call cut\r\nCall cut	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2681	Customer	9828555544	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2684	Customer	9829165810	2025-07-07 00:00:00	Needs Followup	Not interested 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2685	Customer	9660600999	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot requirement 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2693	Abhishek	8114452851	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2700	Sushil	8239297047	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2707	Cx156	9928946237	2025-07-07 00:00:00	Needs Followup	Bumper paint 2500	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2721	Deepanshu	8946980544	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2734	Customer	9351674205	2025-07-07 00:00:00	Needs Followup	Call cut\r\nCall cut\r\nNot pick 	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2753	Cx157	9887260000	2025-07-07 00:00:00	Needs Followup	Dent paint bonet	2025-01-09 06:01:54.641402	9	2025-07-01 06:50:29.884428	\N
2754	Cx157	9887260000	2025-07-07 00:00:00	Needs Followup	Dent paint bonet	2025-01-09 06:01:54.641402	9	2025-07-01 06:50:29.884428	\N
2784	Customer	9828503804	2025-07-07 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2797	Cx159	9667118595	2025-07-07 00:00:00	Needs Followup	Amaze dent paint \r\n2200	2025-01-10 04:20:50.707156	9	2025-07-01 06:50:29.884428	
2817	Cx167	9414844707	2025-07-07 00:00:00	Needs Followup	Figo \r\nDent paint 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2824	Customer	7003450195	2025-07-07 00:00:00	Needs Followup	Creta 3199 package share \r\nNot pick\r\nNot pick but khud aayenge 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2840	Cx166	8619150569	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-11 12:38:10.703782	9	2025-07-01 06:50:29.884428	\N
2894	Customer	9015400167	2025-07-07 00:00:00	Needs Followup	Call cut\r\nNot pivk	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
3052	Cx183	9461593557	2025-07-07 00:00:00	Needs Followup	Creta 3199	2025-01-15 06:44:10.074469	9	2025-07-01 06:50:29.884428	\N
3053	Cx184	9799547453	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-15 06:44:10.074469	9	2025-07-01 06:50:29.884428	\N
3055	Cx185	9887977980	2025-07-07 00:00:00	Needs Followup	Safari\r\nDent paint 28000	2025-01-15 06:44:10.074469	9	2025-07-01 06:50:29.884428	\N
3085	Cx182	9571711212	2025-07-07 00:00:00	Needs Followup	Swift bumper paint \r\n	2025-01-16 11:14:31.747592	9	2025-07-01 06:50:29.884428	\N
3088	Cx187	9352456289	2025-07-07 00:00:00	Needs Followup	Caiz \r\n4 part Dent paint 	2025-01-16 11:14:31.747592	9	2025-07-01 06:50:29.884428	\N
3095	Cx190	9782086240	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	\N
3100	Cx195	7792000209	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	\N
4677	gaadimech 	6375887231	2025-07-10 18:30:00	Needs Followup	Ignis car service \r\n	2025-03-12 04:42:02.499811	4	2025-07-02 07:42:23.738234	
6735	customer 	8890575791	2025-07-06 18:30:00	Did Not Pick Up	Not pick 	2025-04-26 12:25:47.91837	6	2025-07-02 10:59:35.983474	
6678	gaadimech 	9680342242	2025-09-26 18:30:00	Did Not Pick Up	Nexon 3199 service done by company workshop \r\nNot interested 	2025-04-25 11:30:57.405775	6	2025-06-28 07:22:54.747374	
5899	gaadimech 	8302124496	2025-07-17 18:30:00	Did Not Pick Up	Call cut by mistake inquiry ho gaye higu	2025-04-14 05:57:06.274576	6	2025-06-28 07:30:38.965338	
5855	gaadimech 	9887113174	2025-07-18 18:30:00	Did Not Pick Up	Clutch issue\r\nSwitch off	2025-04-12 06:56:24.148713	6	2025-06-28 07:31:27.043263	
5835	gaadimech 	8005678107	2025-07-03 18:30:00	Did Not Pick Up	Dzire 2999 rk\r\nCall cut\r\n	2025-04-11 05:27:03.715425	6	2025-06-28 07:33:28.25567	
3110	Cx194	9414408515	2025-07-07 00:00:00	Needs Followup		2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	\N
3111	Cx196	9001587565	2025-07-07 00:00:00	Needs Followup	Out of service 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	\N
3112	Cx197	8233171572	2025-07-07 00:00:00	Needs Followup	Car service 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	\N
2233	.	9928979000	2025-07-18 18:30:00	Did Not Pick Up	Call not pick 	2024-12-20 08:28:57.743192	6	2025-06-29 11:20:20.819773	
7723	gaadimech 	9314529564	2025-07-04 18:30:00	Feedback	Amaze \r\nTotal payment 3959 big boss \r\nFeedback	2025-06-28 10:01:46.485357	6	2025-06-30 11:45:38.94043	RJ14CT0680
3118	Cx202	7014638512	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	\N
3129	Cx202	9116113773	2025-07-07 00:00:00	Needs Followup	Terrano 5999	2025-01-19 05:26:31.430473	9	2025-07-01 06:50:29.884428	\N
3132	Cx205	9588973566	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-19 05:26:31.430473	9	2025-07-01 06:50:29.884428	\N
3136	Cx206	6378961230	2025-07-07 00:00:00	Needs Followup	City 2999	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	\N
3210	Cx209	8949433064	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3211	Cx210	7011066613	2025-07-07 00:00:00	Needs Followup	Call cut 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3212	Cx211	9982959494	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3236	mohd rafi	9999209859	2025-07-07 00:00:00	Needs Followup	Santro 2299 package share call bqck\r\nNot pick\r\nCall back 2,3 days	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3302	Customer 	9079761567	2025-07-07 00:00:00	Needs Followup	Figo full gadi dent paint today visit	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	\N
3306	Cx210	9999209859	2025-07-07 00:00:00	Needs Followup	Santro 2199	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	\N
3310	Cx213	8949272995	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	\N
3312	Cx215	9983303007	2025-07-07 00:00:00	Needs Followup	Swift Dent paint \r\nService 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	\N
3316	Cx206	9929789476	2025-07-07 00:00:00	Needs Followup	Beawar se  \r\nCostume call	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	
3317	Cx213	9929766684	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-22 08:08:27.280335	9	2025-07-01 06:50:29.884428	\N
3319	Cx216	8432531265	2025-07-07 00:00:00	Needs Followup	Skoda service 	2025-01-22 08:08:27.280335	9	2025-07-01 06:50:29.884428	\N
3320	Cx217	8107970802	2025-07-07 00:00:00	Needs Followup	Swift\r\nDiggi aur bumper 	2025-01-22 08:08:27.280335	9	2025-07-01 06:50:29.884428	\N
3321	Cx218	9785483028	2025-07-07 00:00:00	Needs Followup	Ignis \r\nDent paint 	2025-01-22 08:08:27.280335	9	2025-07-01 06:50:29.884428	\N
3322	Cx219	9119123364	2025-07-07 00:00:00	Needs Followup	Swift \r\ndent paint 	2025-01-22 08:08:27.280335	9	2025-07-01 06:50:29.884428	
3329	Cx219	9829010990	2025-07-07 00:00:00	Needs Followup	Creta \r\nD/p	2025-01-23 06:14:00.724431	9	2025-07-01 06:50:29.884428	\N
3330	Cx219	8946960294	2025-07-07 00:00:00	Needs Followup	Insurance work Reliance se	2025-01-23 06:14:00.724431	9	2025-07-01 06:50:29.884428	
3331	Cx220 	8529782855	2025-07-07 00:00:00	Needs Followup	No answer 	2025-01-23 06:14:00.724431	9	2025-07-01 06:50:29.884428	\N
3332	Cx221	9610480120	2025-07-07 00:00:00	Needs Followup	Wr 2199	2025-01-23 06:14:00.724431	9	2025-07-01 06:50:29.884428	\N
3333	Cx219	8209937843	2025-07-07 00:00:00	Needs Followup	Alto \r\nBonut aur roof Dent paint 	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	\N
3334	Cx226	9667646218	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	\N
3335	Cx225	9829820496	2025-07-07 00:00:00	Needs Followup	Call cut 	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	\N
3336	Cx228	8949814797	2025-07-07 00:00:00	Needs Followup	Cruise rubbing \r\n1400	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	\N
3403	Cx229	7028973109	2025-07-07 00:00:00	Needs Followup	Call cut 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3404	Cx229	9314398952	2025-07-07 00:00:00	Needs Followup	Bani park 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3405	Cx230	7737890164	2025-07-07 00:00:00	Needs Followup	Call cut 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	\N
3419	Cx231	7976847806	2025-07-07 00:00:00	Needs Followup	Scorpio \r\nWashing 450	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3469	.	8890202226	2025-07-07 00:00:00	Needs Followup	Polo 3199	2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	\N
3488	Cz137	9343987560	2025-07-07 00:00:00	Needs Followup	Service \r\nAjmer road 	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	\N
3492	Cx239	9928127678	2025-07-07 00:00:00	Needs Followup	Alto \r\nDrycleaning and rubbing 	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3494	Cx241	6377343862	2025-07-07 00:00:00	Needs Followup	Dent paint 	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3507	Cx231	6378740411	2025-07-07 00:00:00	Needs Followup	Duster 5999	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
3509	Cx234	9610447943	2025-07-07 00:00:00	Needs Followup	Tata punch \r\nDiggi dent paint 	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	\N
3525	Cx237	9784420386	2025-07-07 00:00:00	Needs Followup	Omni Dent paint 	2025-01-30 06:21:32.306288	9	2025-07-01 06:50:29.884428	\N
3527	Cx240	9867867322	2025-07-07 00:00:00	Needs Followup	Polo 2999	2025-01-30 06:21:32.306288	9	2025-07-01 06:50:29.884428	
3533	Cx242	9828023414	2025-07-07 00:00:00	Needs Followup	Octvia 5999	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3534	Cx243	7275528047	2025-07-07 00:00:00	Needs Followup	Call cut	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3535	Cx247	9694703942	2025-07-07 00:00:00	Needs Followup	Wr \r\nBumper paint 	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3537	Cx248	9928415411	2025-07-07 00:00:00	Needs Followup	Brio \r\nDent paint (24000)	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3539	Cx246	8890692936	2025-07-07 00:00:00	Needs Followup	Alto \r\nBumper paint 	2025-01-30 09:45:21.587775	9	2025-07-01 06:50:29.884428	
3550	Cx243	9887962541	2025-07-07 00:00:00	Needs Followup	G-i10\r\n2499	2025-01-31 08:11:35.091138	9	2025-07-01 06:50:29.884428	\N
3552	Cx245	9783696778	2025-07-07 00:00:00	Needs Followup	Ertiga Dent pant	2025-01-31 08:11:35.091138	9	2025-07-01 06:50:29.884428	
3553	Cx244	8384939824	2025-07-07 00:00:00	Needs Followup	Vki 1\r\nCelerio 2199	2025-01-31 08:11:35.091138	9	2025-07-01 06:50:29.884428	
3589	.	8619363811	2025-07-07 00:00:00	Needs Followup	Swift 2699	2025-02-01 04:09:42.798808	9	2025-07-01 06:50:29.884428	\N
3607	Cx451	9571205742	2025-07-07 00:00:00	Needs Followup	Swift 2699	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	\N
3608	Cx451	8104659176	2025-07-07 00:00:00	Needs Followup	No answer 	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	\N
3634	.	9782000106	2025-07-07 00:00:00	Needs Followup	I20 2699	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	\N
3657	Cx251	9929259159	2025-07-07 00:00:00	Needs Followup	Call cut	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3819	Cx261	8058889143	2025-07-07 00:00:00	Needs Followup	Tata tiago dent paint \r\n24000	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	\N
3820	Cx262	8690941918	2025-07-07 00:00:00	Needs Followup	Brezza Dent paint \r\n26000	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	\N
3821	Cx263	9024839392	2025-07-07 00:00:00	Needs Followup	Grand -i10\r\nDent paint \r\n2200	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	\N
3824	Cx266	9782431995	2025-07-07 00:00:00	Needs Followup	Seltoz \r\nEk part Dent paint 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	\N
3836	Test User	9999999999	2025-07-07 00:00:00	Needs Followup	Test User	2025-02-07 14:40:39.968892	9	2025-07-01 06:50:29.884428	\N
232	Cx40	7412843481	2025-07-07 00:00:00	Did Not Pick Up	Call cut	2024-11-25 07:29:06	9	2025-07-01 06:50:29.884428	
243	Assif	8209035774	2025-07-07 00:00:00	Did Not Pick Up	Dzire 2999 sarvice pack \r\nDon't have car	2024-11-25 07:49:07	9	2025-07-01 06:50:29.884428	
4466	Swift 	9413085867	2025-07-07 00:00:00	Completed	Swift \r\nAc aur car service \r\nFeedback call \r\nAcchi service hai \r\nAcchi service hai Day 1\r\nAcchi service hai Day 2\r\nGood service Day 3	2025-03-02 06:21:51.769539	9	2025-07-01 06:50:29.884428	RJ09CA2165
4595	gaadimech 	9314048399	2025-07-07 00:00:00	Did Not Pick Up	Alto 1999\r\nCall cut not interested 	2025-03-08 05:55:01.097836	9	2025-07-01 06:50:29.884428	
5052	Honda Amaze 3199	9983334080	2025-07-07 00:00:00	Completed	3199 \r\nFeedback call \r\nAcchi service hai Day 1 \r\nWashing issue Day 2\r\n\r\n	2025-03-25 10:57:10.41001	9	2025-07-01 06:50:29.884428	
5224	Saurabh ji ( swift )	9772743657	2025-07-07 00:00:00	Completed	Lh fender Dent paint \r\nTotal Payment - 2200 (cash) \r\nFeedback \r\nGood service Day 1 \r\n	2025-03-28 11:40:20.45294	9	2025-07-01 06:50:29.884428	RJ45CY9761
5355	Verna 3999	9803199120	2025-07-07 00:00:00	Completed	Car service Verna 3999\r\nFeedback call \r\nAcchi service hai Day 1 \r\nNo issues Day 2\r\n\r\n	2025-03-31 06:26:19.763819	9	2025-07-01 06:50:29.884428	
5413	Customer 	9982881110	2025-07-07 00:00:00	Needs Followup	Suv300: 3899	2025-04-01 09:08:07.383736	9	2025-07-01 06:50:29.884428	
5517	gaadimech 	6377040542	2025-07-07 00:00:00	Did Not Pick Up	Civik 3299 drycleaning 1200 rubbing polishing 1200\r\nSelf call	2025-04-03 04:55:03.743338	9	2025-07-01 06:50:29.884428	
5879	Rk ji 	9509642345	2025-07-07 00:00:00	Completed	S cross \r\n3699\r\nFeedback call \r\nKoi problem nahi hai ok service Day 1 \r\n	2025-04-13 09:17:22.205705	9	2025-07-01 06:50:29.884428	
5911	gaadimech 	8949133030	2025-07-08 00:00:00	Did Not Pick Up	Swift 2799 call cut	2025-04-14 07:14:27.626178	9	2025-07-01 06:50:29.884428	
6274	Skoda 	7610010056	2025-07-08 00:00:00	Confirmed	Service 4599\r\nFeedback call \r\nWashing issue Day 1 	2025-04-18 04:49:44.73842	9	2025-07-01 06:50:29.884428	
6287	Sweety mam 	8005564189	2025-07-08 00:00:00	Completed	Aevo \r\nSuspension plus clutch work\r\nFeedback call \r\nAcchi 	2025-04-18 06:46:32.559941	9	2025-07-01 06:50:29.884428	
6370	gaadimech 	9983335177	2025-07-08 00:00:00	Did Not Pick Up	Swift 2799 not pick	2025-04-20 05:27:19.923151	9	2025-07-01 06:50:29.884428	
6385	gaadimech 	7023081175	2025-07-08 00:00:00	Did Not Pick Up	Not interested 	2025-04-20 09:52:27.28083	9	2025-07-01 06:50:29.884428	
6788	gaadimech 	9414274023	2025-07-08 00:00:00	Did Not Pick Up	Not pick 	2025-04-29 06:14:41.695644	9	2025-07-01 06:50:29.884428	
6826	Vijay ji 	9352677238	2025-07-08 00:00:00	Confirmed	Swift 2899\r\nFeedback call \r\nWashing issue Day 1 	2025-05-01 08:53:30.998963	9	2025-07-01 06:50:29.884428	
6836	Yaris (3399)	9828032483	2025-07-08 00:00:00	Confirmed	Yaris service 3399\r\nFeedback call \r\nWashing issue 	2025-05-02 04:24:42.404475	9	2025-07-01 06:50:29.884428	
6861	Cx1162	8208424972	2025-07-08 00:00:00	Confirmed	Tata punch \r\nFeedback call \r\nAcchi service \r\nGood service 	2025-05-03 05:40:28.300274	9	2025-07-01 06:50:29.884428	
6903	gaadimech 	9314612070	2025-07-08 00:00:00	Did Not Pick Up	Kwid 2699	2025-05-05 05:20:10.047392	9	2025-07-01 06:50:29.884428	
6904	gaadimech 	9950139598	2025-07-08 00:00:00	Did Not Pick Up	Eco sport dent paint 	2025-05-05 05:33:43.525188	9	2025-07-01 06:50:29.884428	
7046	Jay deep sharma 	9829811062	2025-07-08 00:00:00	Confirmed	Venu dent paint 	2025-05-08 12:58:41.93919	9	2025-07-01 06:50:29.884428	
7048	Cx1174	9587591819	2025-07-08 00:00:00	Completed	Corolla 3899\r\nFeedback call\r\nAcchi hai 	2025-05-09 04:43:10.783162	9	2025-07-01 06:50:29.884428	
7052	Kushal ji 	9529929029	2025-07-08 00:00:00	Confirmed	Service 2299\r\ni10 \r\nGood service 	2025-05-09 11:59:54.871323	9	2025-07-01 06:50:29.884428	
7074	gaadimech 	9680427714	2025-07-08 00:00:00	Did Not Pick Up	Brio 2599	2025-05-10 09:37:36.422899	9	2025-07-01 06:50:29.884428	
7097	gaadimech 	9636152361	2025-07-08 00:00:00	Did Not Pick Up	Nexon 3699\r\nCall cut	2025-05-11 05:57:03.047594	9	2025-07-01 06:50:29.884428	
7102	gaadimech 	6350118426	2025-07-08 00:00:00	Needs Followup	Swift	2025-05-11 08:54:42.327039	9	2025-07-01 06:50:29.884428	
7196	gaadimech 	7976755269	2025-07-08 00:00:00	Needs Followup	Santro 2499	2025-05-15 05:30:08.003772	9	2025-07-01 06:50:29.884428	
7274	gaadimech	7073280499	2025-07-08 00:00:00	Did Not Pick Up	Aura 2799 call cut	2025-05-18 04:13:04.064084	9	2025-07-01 06:50:29.884428	
7285	gaadimech 	9660555886	2025-07-08 00:00:00	Did Not Pick Up	Kwid 2899\r\nCall cut	2025-05-18 06:32:12.259478	9	2025-07-01 06:50:29.884428	
7286	gaadimech	8058629280	2025-07-08 00:00:00	Did Not Pick Up	Not pick	2025-05-18 06:34:39.272212	9	2025-07-01 06:50:29.884428	
7340	gaadimech 	9414335096	2025-07-08 00:00:00	Needs Followup	Swift 2799	2025-05-21 04:58:09.282498	9	2025-07-01 06:50:29.884428	
7343	gaadimech 	9460759690	2025-07-08 00:00:00	Open	Getz service done \r\nSharp motors 6500 sharp online\r\n\r\nFeedback	2025-05-21 05:09:02.537846	9	2025-07-01 06:50:29.884428	
7351	gaadimech 	9929450006	2025-07-08 00:00:00	Did Not Pick Up	Verna 3399	2025-05-21 06:52:07.520802	9	2025-07-01 06:50:29.884428	
7399	gaadimech 	9672646514	2025-07-08 00:00:00	Did Not Pick Up	Not pick	2025-05-22 12:40:47.039233	9	2025-07-01 06:50:29.884428	
7428	Ignis 2599	9549257123	2025-07-08 00:00:00	Completed	Ignis 2599\r\nFeedback call \r\nGood service 	2025-05-23 09:32:24.04981	9	2025-07-01 06:50:29.884428	
7446	gaadimech 	8769196918	2025-07-08 00:00:00	Did Not Pick Up	Not pick	2025-05-24 06:24:27.347472	9	2025-07-01 06:50:29.884428	
7458	gaadimech	9784599322	2025-07-08 00:00:00	Feedback	Baleno 2799\r\nService done	2025-05-24 08:49:05.172576	9	2025-07-01 06:50:29.884428	
7472	gaadimech 	6375555935	2025-07-08 00:00:00	Did Not Pick Up	Not pick tigor 3299	2025-05-24 10:31:03.758786	9	2025-07-01 06:50:29.884428	
7476	gaadimech 	7220968228	2025-07-08 00:00:00	Did Not Pick Up	Not pick 	2025-05-24 11:14:09.22774	9	2025-07-01 06:50:29.884428	
7478	gaadimech 	9929822032	2025-07-08 00:00:00	Did Not Pick Up	Etios 3399 tonk road \r\nOut of jaipur 	2025-05-25 04:24:16.281162	9	2025-07-01 06:50:29.884428	
7497	gaadimech 	9928326690	2025-07-08 00:00:00	Did Not Pick Up	Not pick i10 2299 package share \r\n	2025-05-25 06:15:42.139699	9	2025-07-01 06:50:29.884428	
7538	gaadimech 	9001085077	2025-07-08 00:00:00	Did Not Pick Up	Dzire 2999	2025-05-28 06:35:39.734107	9	2025-07-01 06:50:29.884428	
7546	gaadimech	9413239227	2025-07-08 00:00:00	Needs Followup	Baleno 2799	2025-05-28 10:32:28.141824	9	2025-07-01 06:50:29.884428	
7547	Cx2067	8432891238	2025-07-08 00:00:00	Needs Followup	Abhi nahi 	2025-05-28 11:30:58.772709	9	2025-07-01 06:50:29.884428	
7550	gaadimech	9414975053	2025-07-08 00:00:00	Did Not Pick Up	Not pick	2025-05-28 12:00:24.938046	9	2025-07-01 06:50:29.884428	
7555	gaadimech 	7878059797	2025-07-08 00:00:00	Did Not Pick Up	Busy call u later \r\nWagnor 2599\r\nCompany se 2000 ki service ho jati hai apke yaha jyada price hai 	2025-05-29 04:49:17.283412	9	2025-07-01 06:50:29.884428	
7568	gaadimech	9413990030	2025-07-08 00:00:00	Did Not Pick Up	Baleno 2799 	2025-05-29 07:04:32.48943	9	2025-07-01 06:50:29.884428	
7569	gaadimech 	9259851025	2025-07-08 00:00:00	Did Not Pick Up	Call cut	2025-05-29 07:05:37.340967	9	2025-07-01 06:50:29.884428	
7576	gaadimech 	9950534824	2025-07-08 00:00:00	Did Not Pick Up	Not pick 	2025-05-29 10:08:22.284822	9	2025-07-01 06:50:29.884428	
7588	gaadimech 	9468887132	2025-07-08 00:00:00	Did Not Pick Up	Not pick wagnor 2599\r\nSelf call back	2025-05-29 11:42:39.608384	9	2025-07-01 06:50:29.884428	
7606	gaadimech	9509443080	2025-07-08 00:00:00	Did Not Pick Up	Dzire coolant leaked 	2025-05-30 06:04:40.131862	9	2025-07-01 06:50:29.884428	
7646	gaadimech 	8769584994	2025-07-08 00:00:00	Needs Followup	Eon 2299	2025-05-31 10:06:17.529935	9	2025-07-01 06:50:29.884428	
7668	Ac service 	9035336123	2025-07-08 00:00:00	Completed	Ac \r\nSharp motor 	2025-06-01 06:23:13.539818	9	2025-07-01 06:50:29.884428	
2600	Dharmveer	9929105744	2025-07-08 00:00:00	Needs Followup	Creta PPF, cus from Alwar.\r\nPPF starting from 40k but give him estimate for 5 years warranty 65k for USA TPU, 75k For Garware.\r\n\r\nnot coming 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2612	Cx157	8696611234	2025-07-08 00:00:00	Needs Followup	Baleno Dent paint\r\nService 2499	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2623	Ratnesh	9784592847	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pickx	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2628	Krishna	7014662020	2025-07-08 00:00:00	Needs Followup	Not pick 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2631	Shubham	8233484805	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2637	Vivek	9001100007	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2644	Kiran	8107304398	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\n\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2645	Rakesh	9828283639	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2651	Rahul	9828233154	2025-07-08 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2661	Customer	6377433954	2025-07-08 00:00:00	Needs Followup	Not pick\r\nSwitch off \r\nSwitch off \r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2672	Customer	6378730161	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2683	Customer	9829062967	2025-07-08 00:00:00	Needs Followup	Not pick\r\nBusy call u later \r\nNot pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2687	Customer	9717792204	2025-07-08 00:00:00	Needs Followup	Belgaadi hai\r\nNot pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2689	Customer	9414051637	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2698	Vijay 	9314505244	2025-07-08 00:00:00	Needs Followup	Not intrested	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2702	Atul	7073762173	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2705	Ritik	9636670333	2025-07-08 00:00:00	Needs Followup	Not interested \r\nNot pick 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2709	Customer	9829070779	2025-07-08 00:00:00	Needs Followup		2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2713	Krushan	9503104726	2025-07-08 00:00:00	Needs Followup	Not pick\r\nCall back 20 jan 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2715	Customer	8826911077	2025-07-08 00:00:00	Needs Followup	Not pick 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2732	Satish	9252546472	2025-07-08 00:00:00	Needs Followup	Not pick \r\nNot. Pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2745	Customer	9887421900	2025-07-08 00:00:00	Needs Followup	Switch off \r\nNot pick\r\nNot valid no\r\nNot valid no	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2747	Customer	8107132729	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2759	Customer	9672222493	2025-07-08 00:00:00	Needs Followup	Call cut\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2770	Customer	9610723629	2025-07-08 00:00:00	Needs Followup	Not pick \r\nCall cut\r\nNot pick 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2774	Customer	9928958043	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot interested 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2775	Customer	7060053456	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nCall cut	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2776	Customer	6375308390	2025-07-08 00:00:00	Needs Followup	Call cut\r\nCall cut\r\n	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2780	Customer	9636947320	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nNot pick\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2781	Customer	9636947320	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2782	Customer	9610800196	2025-07-08 00:00:00	Needs Followup	Busy call u letter	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2788	Customer	8742041076	2025-07-08 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2790	Customer	7737773778	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 12:05:45.647682	9	2025-07-01 06:50:29.884428	\N
2816	Customer	8890901590	2025-07-08 00:00:00	Needs Followup	Not pick\r\nDzire drycleaning nd rubbing polishing \r\n3 bje tak visit krenge\r\nCall cut	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2821	Cx175	6353856986	2025-07-08 00:00:00	Needs Followup	Service 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
2832	Imran khan	8005753618	2025-07-08 00:00:00	Needs Followup	Not interested 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2838	Customer	7021423919	2025-07-08 00:00:00	Needs Followup	Call cut\r\nCall cut	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2850	Customer	8890000132	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2854	Customer	9828866646	2025-07-08 00:00:00	Needs Followup	Not pick\r\nI10 1999	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2855	Customer	9828866646	2025-07-08 00:00:00	Needs Followup	Not pick\r\nI101999	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2859	Customer	8920513941	2025-07-08 00:00:00	Needs Followup	Busy hu not interested \r\nCall cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2863	Customer	9829071540	2025-07-08 00:00:00	Needs Followup	Not pick \r\nCall cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2866	Customer	9929666028	2025-07-08 00:00:00	Needs Followup	Not connec\r\nNot connect 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2868	Customer	9314264439	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2869	Customer	8696266662	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2873	Customer	8386825583	2025-07-08 00:00:00	Needs Followup	Switch off \r\nTiyago 2999	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2882	Customer	9352464555	2025-07-08 00:00:00	Needs Followup	Not pick\r\n Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2887	Customer	6377718145	2025-07-08 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2890	Customer	9828221022	2025-07-08 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2891	Customer	7627059417	2025-07-08 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2900	Customer	9982881110	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2903	Customer	9001156333	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2907	Customer	9867303343	2025-07-08 00:00:00	Needs Followup	Call cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2910	Customer	9685607838	2025-07-08 00:00:00	Needs Followup	Switch off 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2912	Customer	8112283737	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2916	Customer	7838966378	2025-07-08 00:00:00	Needs Followup	Call cut\r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2918	Customer	7877889761	2025-07-08 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2921	Customer	9784151515	2025-07-08 00:00:00	Needs Followup		2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2953	Cx177	7878417039	2025-07-08 00:00:00	Needs Followup	Verna \r\nRubbing 1500	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
3304	Cx209	9351282722	2025-07-08 00:00:00	Needs Followup	Out of service 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	\N
3406	Cx131	9352393083	2025-07-08 00:00:00	Needs Followup	Call cut 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3490	Cx238	8849137334	2025-07-08 00:00:00	Needs Followup	Swift car service 	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3510	Cx235	6266970427	2025-07-08 00:00:00	Needs Followup	Car service 	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
3526	Cx238	9413563717	2025-07-08 00:00:00	Needs Followup	No answer 	2025-01-30 06:21:32.306288	9	2025-07-01 06:50:29.884428	
3536	Cx247	9557996646	2025-07-08 00:00:00	Needs Followup	Service 	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3538	Cx249	8442021195	2025-07-08 00:00:00	Needs Followup	Swift \r\nService 2699	2025-01-30 09:05:10.708331	9	2025-07-01 06:50:29.884428	
3547	Cx241	9351632511	2025-07-08 00:00:00	Needs Followup	Call cut	2025-01-31 04:20:51.980955	9	2025-07-01 06:50:29.884428	
3549	Cx243	8426899882	2025-07-08 00:00:00	Needs Followup	Swift 24000\r\nFull Dent paint 	2025-01-31 04:20:51.980955	9	2025-07-01 06:50:29.884428	
3551	Cx243	9887962541	2025-07-08 00:00:00	Needs Followup	G-i10\r\n2499	2025-01-31 08:11:35.091138	9	2025-07-01 06:50:29.884428	
3555	Cx445	8739929655	2025-07-08 00:00:00	Needs Followup	City 2999	2025-01-31 08:47:45.318294	9	2025-07-01 06:50:29.884428	
3556	Cx246	8005747242	2025-07-08 00:00:00	Needs Followup	Bani park \r\nInsurance work	2025-01-31 08:47:45.318294	9	2025-07-01 06:50:29.884428	
3603	Cx247	9928971754	2025-07-08 00:00:00	Needs Followup	i20\r\nService 2699	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3606	Cx450	7891071089	2025-07-09 00:00:00	Needs Followup	G-i10\r\n2699\r\nVerna ppf 	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3659	Cx253	8118898470	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3660	Cx253	9462422518	2025-07-09 00:00:00	Needs Followup	Call cut 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3664	Cx255	9314052174	2025-07-09 00:00:00	Needs Followup	Call cut 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3665	Cx256	9413563717	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3666	Cx256	7023805624	2025-07-09 00:00:00	Needs Followup	Service 	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3668	Polo 	8104659176	2025-07-09 00:00:00	Needs Followup	Polo bonut 2500	2025-02-03 11:08:52.140331	9	2025-07-01 06:50:29.884428	
3779	Cx251	9784827786	2025-07-09 00:00:00	Needs Followup	Tata punch 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3782	Cx258	8764058611	2025-07-09 00:00:00	Needs Followup	Switch off 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3783	Cx257	9649915055	2025-07-09 00:00:00	Needs Followup	Honda amaze 2699	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3784	Cx258	7357319906	2025-07-09 00:00:00	Needs Followup	Call cut 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3785	Cx258	9523307593	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3787	Cx261	8814991669	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3788	Cx259	8814991669	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3790	Piyush ji 	7014601660	2025-07-09 00:00:00	Needs Followup	i10\r\n2499	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	RJ19CF5841
3791	Cx261	9929177108	2025-07-09 00:00:00	Needs Followup	Call cut	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3825	Cx267	9024925240	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3827	Cx268	6375685634	2025-07-09 00:00:00	Needs Followup	i-20\r\nService 2699	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3828	Cc269	8239990091	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3832	Cx275	7297065595	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3833	Cx274	9610959807	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3834	Cx274	9610692240	2025-07-09 00:00:00	Needs Followup	Tiguan \r\nService 3399\r\n4999	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3901	Cx269	7568112345	2025-07-09 00:00:00	Needs Followup	Service 	2025-02-08 09:15:21.683541	9	2025-07-01 06:50:29.884428	
3902	Cx270	9530191950	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-08 09:16:01.309115	9	2025-07-01 06:50:29.884428	
3909	Cx277	8209148252	2025-07-09 00:00:00	Needs Followup	Call cut	2025-02-08 09:21:27.613549	9	2025-07-01 06:50:29.884428	
3910	Cx277	8619608551	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-08 09:22:05.547954	9	2025-07-01 06:50:29.884428	
3911	Cx278	9784363642	2025-07-09 00:00:00	Needs Followup	No answer 	2025-02-08 09:23:04.58095	9	2025-07-01 06:50:29.884428	
3914	Cx281	9509008975	2025-07-09 00:00:00	Needs Followup	Service 	2025-02-08 09:25:12.551994	9	2025-07-01 06:50:29.884428	
2675	Customer	9983402076	2025-07-09 00:00:00	Did Not Pick Up	Gadi mech par service pr de di hai\r\nSwitch off \r\nService done by workshop 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
3013	Customer	9928235524	2025-07-09 00:00:00	Did Not Pick Up	Service done by other workshop 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3992	.	7023474618	2025-07-09 00:00:00	Did Not Pick Up	Call cut not pick \r\nNot interested 	2025-02-12 10:23:36.132911	9	2025-07-01 06:50:29.884428	
4234	gaadimech 	8005678873	2025-07-09 00:00:00	Did Not Pick Up	Not pick \r\nNot pick 	2025-02-19 05:31:43.579786	9	2025-07-01 06:50:29.884428	
4240	Suraj ji 	6350000636	2025-07-09 00:00:00	Feedback	Dent paint \r\nMagnite \r\nHappy costume Day 1 \r\nAcchi hai services Day 2\r\nRubbing baki hai day 3	2025-02-19 11:32:46.541505	9	2025-07-01 06:50:29.884428	
4298	Customer 	7891266666	2025-07-09 00:00:00	Needs Followup	Service done by other workshop 	2025-02-22 11:27:59.437107	9	2025-07-01 06:50:29.884428	
4376	gaadimech 	9509008975	2025-07-09 00:00:00	Did Not Pick Up	Xcent dent paint. 	2025-02-25 11:23:28.116805	9	2025-07-01 06:50:29.884428	
4401	Santosh ji. Alto 	8209162008	2025-07-09 00:00:00	Completed	Car service \r\nTotal Payment - 44454\r\n33800 PAYMENT COMPLETE WITH 💳 CARD\r\nFEEDBACK 	2025-02-26 08:18:39.02282	9	2025-07-01 06:50:29.884428	RJ14CD8811
4410	Amit ji 	7567979358	2025-07-09 00:00:00	Completed	7 pannel dent paint \r\nFeedback call Day 1 \r\nAcchi hai service Day 2 	2025-02-26 11:48:43.849275	9	2025-07-01 06:50:29.884428	RJ14GJ9392
4467	AMAR JI  ( SWIFT) 	9610004096	2025-07-09 00:00:00	Completed	Swift service \r\n2699\r\nTOTAL PAYMENT - 6039\r\nFeedback call \r\nAcchi service hai Day 1\r\nThik hai Day 2\r\nAcchi service hai Day 3\r\nNo answer	2025-03-02 06:54:44.610144	9	2025-07-01 06:50:29.884428	RJ18CC0697
4471	Carlust automotive (brio)	7891120152	2025-07-09 00:00:00	Feedback	Feedback call \r\nAcchi hai service Day 1 \r\nGood service Day 2\r\nAcchi service hai Day 3\r\nService acchi lagi Day 4\r\nGood service Day 5	2025-03-02 11:20:44.377664	9	2025-07-01 06:50:29.884428	
4472	Brezza 	7734820041	2025-07-09 00:00:00	Feedback	Brezza Dent paint \r\nFeedback call \r\nAcchi hai service Day 1 \r\nPaint mai problem hai \r\nGood service Day 2	2025-03-02 11:21:58.085224	9	2025-07-01 06:50:29.884428	
4473	Sharma ji (seltos)	9782431995	2025-07-09 00:00:00	Feedback	Haaf bumper paint ka \r\nAcchi hai service Day 1\r\nAcchi service hai bay 2 \r\nNo problem Day 3	2025-03-02 11:23:06.985072	9	2025-07-01 06:50:29.884428	
4932	Cx509	9928221100	2025-07-09 00:00:00	Completed	Nexon 36999\r\nFeedback call \r\nAll good ok Day 1 	2025-03-22 07:09:42.364531	9	2025-07-01 06:50:29.884428	
5130	G-i10	9413205652	2025-07-09 00:00:00	Confirmed	G-i10\r\n2999\r\nFeedback call \r\n	2025-03-27 05:54:31.936167	9	2025-07-01 06:50:29.884428	
5223	Caiz 3499 	9660330598	2025-07-09 00:00:00	Completed	Car service caiz \r\nFeedback call \r\nAccha hai service Day 1 \r\nThik hai service Day 2	2025-03-28 11:39:20.398306	9	2025-07-01 06:50:29.884428	
5269	Xuv 5199	9214015127	2025-07-09 00:00:00	Completed	Feedback call \r\nWashing issue Day 1\r\nAcchi service hai\r\nService ok\r\nWashing issue 	2025-03-29 11:54:47.072131	9	2025-07-01 06:50:29.884428	
5275	gaadimech 	6376097921	2025-07-09 00:00:00	Did Not Pick Up	Call cut	2025-03-30 05:29:23.962081	9	2025-07-01 06:50:29.884428	
5529	Rahul ji 	8003691200	2025-07-09 00:00:00	Completed	Swift 2899\r\nService \r\nFeedback call \r\nAcchi service hai Day 1 \r\nAverage issues Day 2	2025-04-03 08:40:56.710727	9	2025-07-01 06:50:29.884428	
5851	gaadimech	9529648417	2025-07-09 00:00:00	Did Not Pick Up	800 2299\r\nSelf call	2025-04-12 06:37:28.143719	9	2025-07-01 06:50:29.884428	
5886	Cx683	9928143323	2025-07-09 00:00:00	Completed	i10\r\n2299\r\nService \r\nFeedback call \r\nFeedback call \r\nNo answer \r\nFeedback call \r\nNo problem 	2025-04-13 11:45:08.080698	9	2025-07-01 06:50:29.884428	
6109	Harish ji	9024717226	2025-07-09 00:00:00	Completed	 harrier 4999 service\r\nFeedback call \r\nAbhi koi problem nahi hai Day 1 \r\nAcchi service Day 2 	2025-04-16 08:59:37.89827	9	2025-07-01 06:50:29.884428	
6315	Cx1008	8209992669	2025-07-09 00:00:00	Feedback	Dent paint\r\nAcchi hai service 	2025-04-19 05:20:33.469966	9	2025-07-01 06:50:29.884428	
6418	gaadimech 	9928648262	2025-07-09 00:00:00	Did Not Pick Up	Ciaz 3199\r\nCall cut	2025-04-21 07:27:39.790229	9	2025-07-01 06:50:29.884428	
6674	gaadimech 	9782803348	2025-07-09 00:00:00	Did Not Pick Up	Tavera 4999	2025-04-25 11:10:09.902172	9	2025-07-01 06:50:29.884428	
6741	Vivan Ji 	8824722792	2025-07-09 00:00:00	Completed	Dzire 2899\r\nService \r\nTotal Payment - 4739 ( ONLINE) BIGG BOSS\r\nFeedback \r\nAcchi service 	2025-04-27 05:50:15.722692	9	2025-07-01 06:50:29.884428	RJ14XC5220
6798	Cx1156	9783222634	2025-07-09 00:00:00	Needs Followup	Dent paint \r\nAbhi nahi 	2025-04-29 10:18:50.190625	9	2025-07-01 06:50:29.884428	
6855	gaadimech 	8209670089	2025-07-09 00:00:00	Did Not Pick Up	Duster 4899\r\nKwid 2699	2025-05-03 05:32:46.58753	9	2025-07-01 06:50:29.884428	
7200	Ritesh ji 	9783226865	2025-07-09 00:00:00	Completed	Swift 3 parts dent paint \r\nFeedback call \r\nGood service 	2025-05-15 10:02:47.891546	9	2025-07-01 06:50:29.884428	
7397	gaadiemch	8279283919	2025-07-09 00:00:00	Did Not Pick Up	SX4 servixe 3199	2025-05-22 12:39:35.53592	9	2025-07-01 06:50:29.884428	
7422	gaadimech 	7023579660	2025-07-09 00:00:00	Did Not Pick Up	Call cut\r\nNot interested 	2025-05-23 07:13:51.316649	9	2025-07-01 06:50:29.884428	
7440	gaadimech 	9783303503	2025-07-09 00:00:00	Did Not Pick Up	Dzire dent paint 	2025-05-24 05:39:57.260866	9	2025-07-01 06:50:29.884428	
7471	gaadimech 	9414344912	2025-07-09 00:00:00	Needs Followup	Etios 3399	2025-05-24 10:26:35.351236	9	2025-07-01 06:50:29.884428	
7495	gaadi ech	7568458527	2025-07-09 00:00:00	Needs Followup	I20 pickup issue	2025-05-25 05:47:14.056701	9	2025-07-01 06:50:29.884428	
7571	Alto	8005854225	2025-07-09 00:00:00	Did Not Pick Up	Alto 2399	2025-05-29 08:14:52.375077	9	2025-07-01 06:50:29.884428	
7577	gaadimech 	9950534824	2025-07-09 00:00:00	Did Not Pick Up	Not pick 	2025-05-29 10:14:34.4512	9	2025-07-01 06:50:29.884428	
7678	Cx2091	9929512876	2025-07-09 00:00:00	Needs Followup	Oil chamber 	2025-06-02 05:39:23.057859	9	2025-07-01 06:50:29.884428	
7683	Eon roof 	9829335503	2025-07-09 00:00:00	Needs Followup	Eon roof dent paint 	2025-06-02 05:43:07.070617	9	2025-07-01 06:50:29.884428	
2621	Govind	9261121299	2025-07-09 00:00:00	Needs Followup	Not pick venue\r\nNot pick\r\nNot pick\r\nSwitch off 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2626	Mahendra	9414003477	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2635	Ankit	9599286392	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2641	Sanjay	9414054966	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2652	Rahul	9828233154	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2654	Prem prakash	9950667518	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2666	Customer	8742876013	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot connect \r\nCall cut	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2673	Customer	7038209420	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2676	Customer	9828677171	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2690	Customer	9785600448	2025-07-09 00:00:00	Needs Followup	Call cut\r\nNot interested 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2697	Vishwa bhushan ji	9001896001	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2706	Vijay	9314505244	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2712	Rahul	9982174354	2025-07-09 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick\r\nCall cut	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2717	Customer	7297920661	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2718	Customer	9672412000	2025-07-09 00:00:00	Needs Followup	Call cut\r\nNot pick 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2720	Kamal	9887177878	2025-07-09 00:00:00	Needs Followup	Call cut	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2727	Customer	9413601033	2025-07-09 00:00:00	Needs Followup	Don't have car	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2737	Customer	7792094645	2025-07-09 00:00:00	Needs Followup	Busy call u letter\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2749	Customer	6367321119	2025-07-09 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nBusy call u letter 	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2751	Customer	7597050930	2025-07-09 00:00:00	Needs Followup	Not pock\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	\N
2767	Customer	8769010542	2025-07-09 00:00:00	Needs Followup	Not connect\r\nNot pick\r\nSwitch off 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2771	Customer	9610723629	2025-07-09 00:00:00	Needs Followup	Not pick \r\nCall cut\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2778	Customer	9929235504	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2783	Customer	8233448679	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2787	Customer	9649174000	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	\N
2833	Customer	7425017549	2025-07-09 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2853	Customer	9783229441	2025-07-09 00:00:00	Needs Followup	Call cut\r\nCall cut\r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2930	Customer	9571727777	2025-07-09 00:00:00	Needs Followup	Not pick \r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2939	Customer	8279200312	2025-07-09 00:00:00	Needs Followup	Switch off \r\nNot pick\r\nNot pock	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2940	Customer	8851607742	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2944	Customer	9813526261	2025-07-09 00:00:00	Needs Followup	Call cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2946	Customer	9643047246	2025-07-09 00:00:00	Needs Followup	Not pick\r\n	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2962	Customer	8385829556	2025-07-09 00:00:00	Needs Followup	Busy call u letter\r\nNot pick\r\nNot pick	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2963	Customer	8560092512	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2964	Customer	9214323353	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nCus call not picked\r\nNot requirement 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2965	Customer	9829167067	2025-07-09 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick \r\nNot pick 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2966	Customer	9815872435	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2968	Customer	9829970557	2025-07-09 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2969	Customer	9930733721	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2970	Rohit	8769046936	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2971	Customer	9782222080	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2972	Customer	9990001968	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2975	Customer	9785141415	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2977	Customer	8800529145	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2981	Customer	9414414912	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nSwitch off 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2982	Customer	9540889886	2025-07-09 00:00:00	Needs Followup	Not pick\r\n	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2984	Customer	7248107391	2025-07-09 00:00:00	Needs Followup	Not interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2985	Customer	9680445584	2025-07-09 00:00:00	Needs Followup	Not requirement 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2989	Customer	7738117189	2025-07-09 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	\N
2994	Customer	8233858622	2025-07-09 00:00:00	Needs Followup	Not pic\r\nNot pick\r\nBusy call u letter	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
2996	Customer	7838146154	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
2998	Customer	8971652799	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3002	Customer	9314654211	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3006	Customer	9660191714	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3007	Customer	9079949215	2025-07-10 00:00:00	Needs Followup	Not requirement 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3014	Customer	8696243040	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot intrdted	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3020	Customer	9740609877	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3021	Customer	8824387444	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3022	Jay shankar sharma	9319829933	2025-07-10 00:00:00	Needs Followup	3XO Mahapura location, need door step service. cus refused the work.\r\n\r\nfollowup for future service.	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3023	Customer	9983144666	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nnot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3024	Customer	9952820924	2025-07-10 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3032	Customer	9828079341	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3039	Customer	9983228186	2025-07-10 00:00:00	Needs Followup	Switch off \r\nNotl pick\r\nSwitch off 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3042	Customer	7426969798	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot interested \r\nNot interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3043	Customer	9375845135	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	\N
3069	Customer	8949640677	2025-07-10 00:00:00	Needs Followup	Not pic\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	\N
3074	Customer	9783652463	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	\N
3080	Customer	9634430798	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	\N
3141	Customer	9871264908	2025-07-10 00:00:00	Needs Followup	Not requirement 	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	\N
3144	Customer	7976041223	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	\N
3146	Customer	9314053824	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	\N
3161	Customer	9321252423	2025-07-10 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3165	Customer	9829055990	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3178	Customer	9214436898	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3181	Customer	9079479730	2025-07-10 00:00:00	Needs Followup	Call xut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3185	Customer	8562810909	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3188	Customer	9824843138	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot pick	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3192	Customer	9829135775	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	\N
3219	Customer 	9667877771	2025-07-10 00:00:00	Needs Followup	Call back 2 days\r\nNot pick\r\nNot interested 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3238	customer 	9800140002	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3248	.	8209103571	2025-07-10 00:00:00	Needs Followup	Call xut	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3259	.	9599043548	2025-07-10 00:00:00	Needs Followup	Not pick 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	\N
3268	customer 	9643025940	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot connect \r\nNot requirement 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	\N
3290	.	7023004484	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-21 10:32:21.170778	9	2025-07-01 06:50:29.884428	\N
3291	karan	9509677722	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-21 10:32:21.170778	9	2025-07-01 06:50:29.884428	\N
3295	kapil	9958692666	2025-07-10 00:00:00	Needs Followup	Switch off \r\nNot requirement 	2025-01-21 10:55:25.845211	9	2025-07-01 06:50:29.884428	\N
3327	Customer	9772233988	2025-07-10 00:00:00	Needs Followup	Duster wheel  paint 3000\r\n	2025-01-23 06:14:00.724431	9	2025-07-01 06:50:29.884428	\N
3372	.	7023135801	2025-07-10 00:00:00	Needs Followup	Ritz dant pant	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	\N
3398	.	9829022220	2025-07-10 00:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	\N
3409	.	9818441261	2025-07-10 00:00:00	Needs Followup		2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	\N
3411	.	9785647318	2025-07-10 00:00:00	Needs Followup	Call cut not interested 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	\N
3424	.	9929450624	2025-07-10 00:00:00	Needs Followup	Package share 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	\N
3438	.	8114466156	2025-07-10 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	\N
3467	.	9636087983	2025-07-10 00:00:00	Needs Followup	Xcent full general checkup 	2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	\N
3566	.	9829018909	2025-07-10 00:00:00	Needs Followup	Don't have car 	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3568	.	9829052451	2025-07-10 00:00:00	Needs Followup		2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	\N
3697	.	9953654567	2025-07-10 00:00:00	Needs Followup	Don't have car 	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3741	.	9328051016	2025-07-10 00:00:00	Needs Followup	Gujrat rahte h	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
4249	.	7033678613	2025-07-10 00:00:00	Needs Followup	Ajmer se hai	2025-02-20 07:35:47.914839	9	2025-07-01 06:50:29.884428	
1431	.	7060053456	2025-07-10 00:00:00	Did Not Pick Up	Call not pick 	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	
1458	.	9251722324	2025-07-10 00:00:00	Did Not Pick Up	Cut a call \r\nNot pick	2024-12-08 08:15:33	9	2025-07-01 06:50:29.884428	
2636	Anuksha	9680004561	2025-07-10 00:00:00	Did Not Pick Up	Not required \r\n	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
3472	.	8107904038	2025-07-10 00:00:00	Did Not Pick Up	Scorpio 4699 \r\nNot requirement \r\nCall cut	2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	
4041	.	9829938222	2025-07-10 00:00:00	Did Not Pick Up	Not requirement apke wahi aati h gadi jarurt hogi tab bta denge\r\nCall cut	2025-02-15 09:47:19.595513	9	2025-07-01 06:50:29.884428	
4134	.	9887192293	2025-07-10 00:00:00	Did Not Pick Up	Voice mail \r\nBusy call u letter 	2025-02-16 12:18:58.730445	9	2025-07-01 06:50:29.884428	
4275	.	8696090070	2025-07-10 00:00:00	Needs Followup	Swift  dent paint 2000 penal charge \r\nCall cut	2025-02-22 05:31:39.448589	9	2025-07-01 06:50:29.884428	
4666	gaadimech 	7412878721	2025-07-10 00:00:00	Did Not Pick Up	Chevrolet Sail 2699 \r\nAc check up 1000	2025-03-11 11:13:43.608571	9	2025-07-01 06:50:29.884428	
4686	gaadimech 	8952943403	2025-07-10 00:00:00	Did Not Pick Up	Not pick	2025-03-12 05:52:41.725531	9	2025-07-01 06:50:29.884428	
4909	gaadimech	9214905252	2025-07-10 00:00:00	Did Not Pick Up	Swift ac checkup \r\nNot pick 	2025-03-21 05:54:47.241904	9	2025-07-01 06:50:29.884428	
5745	gaadimech 	9928816539	2025-07-10 00:00:00	Feedback	Wagnor 2300 payment bigg boss ajmer road\r\nFeedback \r\n10/04/2025 call cut	2025-04-09 04:47:02.594297	9	2025-07-01 06:50:29.884428	RJ14CZ5223
6089	gaadimech 	9982151004	2025-07-10 00:00:00	Feedback	Dzire  Service done tonk road \r\nTotal payment 3980 \r\n\r\nFeedback satisfied customer hai 	2025-04-16 04:59:02.600872	9	2025-07-01 06:50:29.884428	RJ14CQ9347
6282	gaadimech 	9460129631	2025-07-10 00:00:00	Did Not Pick Up	Baleno 2799 abhi requirement nhi h sirf check kia tha	2025-04-18 05:16:18.969323	9	2025-07-01 06:50:29.884428	
6311	gaadimech 	7568278637	2025-07-10 00:00:00	Needs Followup	WAGNOR 2399	2025-04-19 05:18:04.777048	9	2025-07-01 06:50:29.884428	
6779	gaadimech 	8233809586	2025-07-10 00:00:00	Did Not Pick Up	Punch 1999	2025-04-28 09:29:01.438769	9	2025-07-01 06:50:29.884428	
6860	gaadimech	9680804528	2025-07-10 00:00:00	Did Not Pick Up	Alto 2399\r\nNot pick 	2025-05-03 05:39:19.022645	9	2025-07-01 06:50:29.884428	
7057	gaadimech 	9024427212	2025-07-10 00:00:00	Did Not Pick Up	I20 2999\r\nOut of jaipur \r\nCall cut	2025-05-10 05:08:32.658799	9	2025-07-01 06:50:29.884428	
7268	gaadimech 	9414780170	2025-07-10 00:00:00	Did Not Pick Up	BREZZA ac call cut	2025-05-17 10:53:53.713183	9	2025-07-01 06:50:29.884428	
7273	gaadimech	9660816000	2025-07-10 00:00:00	Did Not Pick Up	Call cut	2025-05-18 04:09:17.298219	9	2025-07-01 06:50:29.884428	
7283	gaadimech 	9602014143	2025-07-10 00:00:00	Did Not Pick Up	Not pick	2025-05-18 05:18:52.115791	9	2025-07-01 06:50:29.884428	
7443	gaadimech 	7388254228	2025-07-10 00:00:00	Did Not Pick Up	Not pick	2025-05-24 06:10:36.205451	9	2025-07-01 06:50:29.884428	
7453	gaadimech 	9928012212	2025-07-10 00:00:00	Did Not Pick Up	I10 2299	2025-05-24 06:57:32.547108	9	2025-07-01 06:50:29.884428	
7486	gaadimech 	9799490308	2025-07-10 00:00:00	Needs Followup	Dzire 2999	2025-05-25 05:04:14.96048	9	2025-07-01 06:50:29.884428	
7580	gaadimech	9530305560	2025-07-10 00:00:00	Did Not Pick Up	Not interested 	2025-05-29 11:19:41.886319	9	2025-07-01 06:50:29.884428	
7582	gaadimech 	7015264709	2025-07-10 00:00:00	Feedback	Rang rower ac checkup ajmer road \r\n5200 cash paid\r\n\r\nFeedback	2025-05-29 11:20:48.626308	9	2025-07-01 06:50:29.884428	
7684	Cx2094	9887029828	2025-07-10 00:00:00	Needs Followup	Car service 	2025-06-02 05:43:31.657393	9	2025-07-01 06:50:29.884428	
848	Cx108	7400876160	2025-07-10 00:00:00	Needs Followup	Car service 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
904	Ritz bumper paint 	8696857545	2025-07-10 00:00:00	Needs Followup	Car service 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	
2639	Customer	9660791404	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2662	Customer	8983345000	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nNot pick \r\nNot pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2667	gaadimech	9057335000	2025-07-10 00:00:00	Needs Followup	Tata altroz 2999	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2670	Customer	9784421829	2025-07-10 00:00:00	Needs Followup	I20 2699\r\nSiker se hai 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2694	Rohit	9652829000	2025-07-10 00:00:00	Needs Followup	not pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2699	Rohit	9652829000	2025-07-10 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	\N
2795	Customer	9314657307	2025-07-10 00:00:00	Needs Followup	Kwid package 1999\r\nWhenever I need than I call u\r\n	2025-01-10 04:20:50.707156	9	2025-07-01 06:50:29.884428	
2803	Customer	9887500191	2025-07-10 00:00:00	Needs Followup	Repid 5499 package share sundy call back\r\nCall back	2025-01-10 04:20:50.707156	9	2025-07-01 06:50:29.884428	
2827	Customer	9772259290	2025-07-10 00:00:00	Needs Followup	Verna engin work\r\nNot pick \r\nNot pick 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
2829	Customer	9205306687	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	\N
2860	Customer	9928068111	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2867	Customer	8619857104	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2893	Customer	7891775758	2025-07-10 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2906	Customer	9414454809	2025-07-10 00:00:00	Needs Followup	Celerio 2399 not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2920	Customer	7568815000	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2935	Customer	9414386334	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2936	Customer	9414386334	2025-07-10 00:00:00	Needs Followup	plan hoga service ka call back karti hu	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2955	Cx177	9635875054	2025-07-10 00:00:00	Needs Followup	Car service 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
2973	Customer	7888993005	2025-07-10 00:00:00	Needs Followup	Not interested 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
3038	Customer	9983029556	2025-07-10 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nCall cut\r\n	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3071	Customer	6207225561	2025-07-10 00:00:00	Needs Followup	Switch off 	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3077	Customer	9982600999	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3099	Cx194	9352230135	2025-07-10 00:00:00	Needs Followup	Dent paint 	2025-01-17 04:24:01.411996	9	2025-07-01 06:50:29.884428	
3134	Cx206	6378961230	2025-07-10 00:00:00	Needs Followup	City 2999\r\n	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	
3204	Customer	9429893903	2025-07-10 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3209	Cx209	9352954216	2025-07-10 00:00:00	Needs Followup	No answer 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3244	.	8437794768	2025-07-10 00:00:00	Needs Followup	Busy call u letter altroz 2799\r\nNot pick	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3270	customer 	8755296784	2025-07-10 00:00:00	Needs Followup	Call requirement 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3271	customer 	9579594531	2025-07-10 00:00:00	Needs Followup	Switch off 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3311	Cx214	8440069192	2025-07-10 00:00:00	Needs Followup	Skoda D/p \r\nService 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	
3314	Cx216	9509060432	2025-07-10 00:00:00	Needs Followup	Abhi nahi 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	
3371	Ram chandra	9828076488	2025-07-10 00:00:00	Needs Followup	Maruti Zen petrol \r\n\r\ncarburetor me problem hai he will visit sharp motors on Sunday,\r\nunanswered\r\nhe is busy right now he will call me.\r\nunanswered  	2025-01-24 08:53:51.25089	9	2025-07-01 06:50:29.884428	
3389	.	9314516506	2025-07-10 00:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3399	.	9672222259	2025-07-10 00:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3511	Cx235	7275528047	2025-07-10 00:00:00	Needs Followup	Call cut 	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
3529	Cx241	9314966100	2025-07-10 00:00:00	Needs Followup	Ajmer road \r\nDent paint 	2025-01-30 06:21:32.306288	9	2025-07-01 06:50:29.884428	
3572	.	9983334450	2025-07-10 00:00:00	Needs Followup		2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	\N
3604	Cx450	9116650776	2025-07-10 00:00:00	Needs Followup	Car service 	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3611	Cx453	9667898990	2025-07-10 00:00:00	Needs Followup	Swift \r\n24000	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3612	.	9314877356	2025-07-11 00:00:00	Needs Followup		2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	\N
3616	.	8946801919	2025-07-11 00:00:00	Needs Followup		2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	\N
3618	.	9828448500	2025-07-11 00:00:00	Needs Followup		2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	\N
3622	.	9829342327	2025-07-11 00:00:00	Needs Followup		2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	\N
3642	.	9871171534	2025-07-11 00:00:00	Needs Followup		2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	\N
3667	Brio 	9887000228	2025-07-11 00:00:00	Needs Followup	Brio service \r\n2199	2025-02-03 08:13:54.657127	9	2025-07-01 06:50:29.884428	
3675	.	9694404066	2025-07-11 00:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3684	.	9680979252	2025-07-11 00:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3685	.	9799495511	2025-07-11 00:00:00	Needs Followup		2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3693	.	9314448842	2025-07-11 00:00:00	Needs Followup		2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3698	.	8619312317	2025-07-11 00:00:00	Needs Followup		2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3699	.	9166325201	2025-07-11 00:00:00	Needs Followup		2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
3709	.	7004494722	2025-07-11 00:00:00	Needs Followup		2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	\N
3712	.	9680660644	2025-07-11 00:00:00	Needs Followup		2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	\N
3715	.	9001164569	2025-07-11 00:00:00	Needs Followup		2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	\N
3721	.	9982283338	2025-07-11 00:00:00	Needs Followup		2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	\N
3722	.	9982090444	2025-07-11 00:00:00	Needs Followup		2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	\N
3723	.	9982228773	2025-07-11 00:00:00	Needs Followup		2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	\N
3724	.	8952876959	2025-07-11 00:00:00	Needs Followup		2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	\N
3727	.	7610092452	2025-07-11 00:00:00	Needs Followup		2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	\N
3740	.	9328051016	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3743	.	7742701190	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3752	.	9414327771	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3756	.	9468844043	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3758	.	9680221379	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3760	.	8619604668	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3769	.	7004495625	2025-07-11 00:00:00	Needs Followup		2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	\N
3789	Cx259	9352096969	2025-07-11 00:00:00	Needs Followup	Service 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3795	Cx267	8696102765	2025-07-11 00:00:00	Needs Followup	Ciaz service \r\n2999	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3797	Cx264	7983879383	2025-07-11 00:00:00	Needs Followup	Car service 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3822	Cx264	9983488448	2025-07-11 00:00:00	Needs Followup	Switch off 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3830	Cx270	9588254154	2025-07-11 00:00:00	Needs Followup	Dent paint 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3843	.	9983169755	2025-07-11 00:00:00	Needs Followup		2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3852	.	8949956313	2025-07-11 00:00:00	Needs Followup		2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3854	.	9602736331	2025-07-11 00:00:00	Needs Followup		2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3855	.	9887594724	2025-07-11 00:00:00	Needs Followup	Call cut	2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3858	.	9982222590	2025-07-11 00:00:00	Needs Followup		2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3866	.	9828148088	2025-07-11 00:00:00	Needs Followup	Not pick 	2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	\N
3894	.	7568293337	2025-07-11 00:00:00	Needs Followup		2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3896	.	8561823636	2025-07-11 00:00:00	Needs Followup		2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3898	.	7665601906	2025-07-11 00:00:00	Needs Followup		2025-02-07 12:25:47.929394	9	2025-07-01 06:50:29.884428	
3907	Cx276	9314813795	2025-07-11 00:00:00	Needs Followup	Brezza bumper 2200	2025-02-08 09:20:06.920002	9	2025-07-01 06:50:29.884428	
3913	Cx280	7023399604	2025-07-11 00:00:00	Needs Followup	Service 	2025-02-08 09:24:41.893251	9	2025-07-01 06:50:29.884428	
3921	Cx293	8005625460	2025-07-11 00:00:00	Needs Followup	Baleno \r\nSharp 	2025-02-08 09:31:00.210407	9	2025-07-01 06:50:29.884428	
3924	Cx284	9887024692	2025-07-11 00:00:00	Needs Followup	Swift \r\nQuarter aur bumper paint 	2025-02-08 09:33:04.960429	9	2025-07-01 06:50:29.884428	
3925	Cx295	9530065044	2025-07-11 00:00:00	Needs Followup	No answer 	2025-02-08 09:33:33.369533	9	2025-07-01 06:50:29.884428	
3930	Cx300	7877342787	2025-07-11 00:00:00	Needs Followup	Door handle check	2025-02-08 10:03:01.52927	9	2025-07-01 06:50:29.884428	
3933	Cx302	9001641836	2025-07-11 00:00:00	Needs Followup	No answer 	2025-02-09 10:55:17.592054	9	2025-07-01 06:50:29.884428	
3935	Cx304	8005682692	2025-07-11 00:00:00	Needs Followup	No answer 	2025-02-09 10:57:51.371238	9	2025-07-01 06:50:29.884428	
3937	Cx306	9662164666	2025-07-11 00:00:00	Needs Followup	Call cut 	2025-02-09 10:59:33.22313	9	2025-07-01 06:50:29.884428	
3938	Cx307	8947064768	2025-07-11 00:00:00	Needs Followup	Call cut 	2025-02-09 11:01:25.806901	9	2025-07-01 06:50:29.884428	
3939	CX 308	9314289482	2025-07-11 00:00:00	Needs Followup	Tata zest \r\n2999	2025-02-09 11:04:04.081758	9	2025-07-01 06:50:29.884428	
4270	.	7043193513	2025-07-11 00:00:00	Needs Followup	Not interested pali se hai	2025-02-22 04:54:17.568699	9	2025-07-01 06:50:29.884428	
4276	.	8958440241	2025-07-11 00:00:00	Needs Followup	Not interested  mene koi inquiry nhi ki	2025-02-22 05:36:34.395043	9	2025-07-01 06:50:29.884428	
4308	Testing	7023620070	2025-07-11 00:00:00	Needs Followup	Do not call, this is for testing.	2025-02-22 21:27:15.820151	9	2025-07-01 06:50:29.884428	
4440	Brio 	7891120152	2025-07-11 00:00:00	Needs Followup	Brio service 	2025-02-28 11:15:37.596675	9	2025-07-01 06:50:29.884428	
7333	Gaadimech 	7976066296	2025-07-11 00:00:00	Did Not Pick Up	Honda city999	2025-05-20 12:25:39.19884	9	2025-07-01 06:50:29.884428	
7347	gaadimech 	6377128628	2025-07-11 00:00:00	Did Not Pick Up	Ciaz 3199 out of jaipur call back after one week	2025-05-21 06:39:22.531651	9	2025-07-01 06:50:29.884428	
7627	Cx2080	9414323010	2025-07-11 00:00:00	Needs Followup	Brezza 3399 service 	2025-05-31 05:05:39.28894	9	2025-07-01 06:50:29.884428	
1320	.	9828504412	2025-07-11 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
2117	Cx145	9450505862	2025-07-11 00:00:00	Needs Followup	Spark 2199\r\nService Done\r\nFollowup call service done \r\nCostume Happy 	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2561	Cx136	9828484146	2025-07-11 00:00:00	Needs Followup	Amaze 2699\r\nBani park 	2025-01-02 12:06:04.008231	9	2025-07-01 06:50:29.884428	
2580	Cx135	8005529735	2025-07-11 00:00:00	Needs Followup	Swift service \r\n2699	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	
2588	Cx143	7742963246	2025-07-11 00:00:00	Needs Followup	Car service ke liye 	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	
2649	Customer	9001273636	2025-07-11 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nNot interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2663	Customer	9829078206	2025-07-11 00:00:00	Needs Followup	Not pick\r\nGi10 2699 sunday morning call\r\nOut of jaipur call back\r\nNot pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2674	Customer	8527128075	2025-07-11 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2682	Customer	9829062967	2025-07-11 00:00:00	Needs Followup	Not pick\r\nBusy caal u later \r\nCall not pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2686	Customer	9799317689	2025-07-11 00:00:00	Needs Followup	Not interested 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2701	Customer	9529569602	2025-07-11 00:00:00	Needs Followup	Call cut	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2728	Chakarveer	9929396075	2025-07-11 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2748	Customer	9887887879	2025-07-11 00:00:00	Needs Followup	Not connect 	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	
2752	Cx157	9799812251	2025-07-11 00:00:00	Needs Followup	i20\r\nAjmer road \r\nService \r\nSwitch off 	2025-01-09 06:01:54.641402	9	2025-07-01 06:50:29.884428	
2758	Customer	9111018403	2025-07-11 00:00:00	Needs Followup	Baleno 5000km due h \r\ncall back after 2 3 days	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2768	Customer	8386969313	2025-07-11 00:00:00	Needs Followup	Not interested 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2807	Customer	9782888997	2025-07-11 00:00:00	Needs Followup	Creta dant paint \r\nNot pick \r\nLalsot 	2025-01-10 04:20:50.707156	9	2025-07-01 06:50:29.884428	
2810	Customer	8619545692	2025-07-11 00:00:00	Needs Followup	Call cut	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
2856	Customer	9782132336	2025-07-11 00:00:00	Needs Followup	Not pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2862	Customer	9828283817	2025-07-11 00:00:00	Needs Followup	Not pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2926	Customer	9829022309	2025-07-11 00:00:00	Needs Followup	K10 1999	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2932	Customer	9929577841	2025-07-11 00:00:00	Needs Followup	Not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2960	Cx180	9413451056	2025-07-11 00:00:00	Needs Followup	Swift bumper paint 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
2974	Customer	7888993005	2025-07-11 00:00:00	Needs Followup	Not interested \r\nSwitch off 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
3061	Customer	7665883370	2025-07-11 00:00:00	Needs Followup	Not pick	2025-01-16 04:14:34.232859	9	2025-07-01 06:50:29.884428	
3078	Customer	9983888090	2025-07-11 00:00:00	Needs Followup	Switch off \r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3108	Customer	9116643833	2025-07-11 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3130	Cx203	9929673444	2025-07-11 00:00:00	Needs Followup	Car service 	2025-01-19 05:26:31.430473	9	2025-07-01 06:50:29.884428	
3162	Customer	9571756588	2025-07-11 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3163	Customer	9929909954	2025-07-11 00:00:00	Needs Followup	Not pick	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3170	Customer	9829620580	2025-07-11 00:00:00	Needs Followup	Not pick  	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3172	Customer	9414238304	2025-07-11 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3195	Customer	7263086665	2025-07-11 00:00:00	Needs Followup	Not pick \r\nNot pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3216	Customer	7413000019	2025-07-11 00:00:00	Needs Followup	Not pick \r\nNot pick 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3253	.	7357516567	2025-07-11 00:00:00	Needs Followup	Not pick \r\nCall cut	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3255	.	9829067590	2025-07-11 00:00:00	Needs Followup	Call cit	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3257	.	8562002256	2025-07-11 00:00:00	Needs Followup	Call cut	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3281	ashok	9829015373	2025-07-11 00:00:00	Needs Followup	Call cut	2025-01-21 08:47:29.498491	9	2025-07-01 06:50:29.884428	
3308	Customer 	8209093196	2025-07-11 00:00:00	Needs Followup	Not pick	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	
3337	Cx230	9420590000	2025-07-11 00:00:00	Needs Followup	Tata tiago \r\n3 part Dent paint 	2025-01-23 08:37:13.385523	9	2025-07-01 06:50:29.884428	
3341	Customer 	8830966766	2025-07-11 00:00:00	Needs Followup	Not pick\r\nCall cut	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3377	Customer 	6350130061	2025-07-11 00:00:00	Needs Followup	Etioes suspension \r\nNot pick	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3394	.	9829055590	2025-07-11 00:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3408	.	9586427216	2025-07-11 00:00:00	Needs Followup	Note requirement 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3414	.	7822012121	2025-07-11 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3416	.	8875025146	2025-07-11 00:00:00	Needs Followup	Not interested 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3445	Cx137	7014259375	2025-07-11 00:00:00	Needs Followup	Tata punch 3199	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3465	Cx231	8949489990	2025-07-11 00:00:00	Needs Followup	Dzire \r\nService \r\n\r\n	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3491	Cx239	9001611046	2025-07-11 00:00:00	Needs Followup	Ciaz\r\nDent paint 	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3508	Cx232	9799602600	2025-07-11 00:00:00	Needs Followup	Tata glennja \r\nService 2699\r\n	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
3528	Cx239	9929934884	2025-07-11 00:00:00	Needs Followup	ECCO Dent paint 	2025-01-30 06:21:32.306288	9	2025-07-01 06:50:29.884428	
3610	Cx452	7742371635	2025-07-11 00:00:00	Needs Followup	Call cut 	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3786	Cx258	8302260607	2025-07-11 00:00:00	Needs Followup	No answer 	2025-02-06 08:20:15.28343	9	2025-07-01 06:50:29.884428	
3823	Cx265	7742344174	2025-07-11 00:00:00	Needs Followup	Car dent paint 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3826	Cx268	6375937736	2025-07-11 00:00:00	Needs Followup	Swift \r\nService 2699	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3829	Cx269	7737022933	2025-07-11 00:00:00	Needs Followup	i20\r\nService 2699	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3831	Cx271	9667626045	2025-07-12 00:00:00	Needs Followup	Scorpio \r\nService 4999	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3905	Cx274	7023965996	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-08 09:18:37.282111	9	2025-07-01 06:50:29.884428	
3906	Cx275	7014023233	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-08 09:19:09.995429	9	2025-07-01 06:50:29.884428	
3908	Cx276	9352074900	2025-07-12 00:00:00	Needs Followup	Ac compressor \r\nAjmer road 	2025-02-08 09:20:44.125927	9	2025-07-01 06:50:29.884428	
3915	Cx281	7727054371	2025-07-12 00:00:00	Needs Followup	Car service 	2025-02-08 09:25:45.651705	9	2025-07-01 06:50:29.884428	
3916	Cx283	9783333353	2025-07-12 00:00:00	Needs Followup	Bumper paint dono \r\n2200	2025-02-08 09:27:02.484299	9	2025-07-01 06:50:29.884428	
3918	Cx287	8373938470	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-08 09:28:02.16941	9	2025-07-01 06:50:29.884428	
3919	Cx286	8696329270	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-08 09:28:59.989915	9	2025-07-01 06:50:29.884428	
3922	Cx294	9829560774	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-08 09:31:33.026141	9	2025-07-01 06:50:29.884428	
3923	Cx295	9509047132	2025-07-12 00:00:00	Needs Followup	Car service 	2025-02-08 09:32:09.206365	9	2025-07-01 06:50:29.884428	
3936	Cx306	8000254251	2025-07-12 00:00:00	Needs Followup	Creta \r\nService 	2025-02-09 10:58:27.609903	9	2025-07-01 06:50:29.884428	
3943	Cx314	7665592664	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-09 11:15:32.509926	9	2025-07-01 06:50:29.884428	
3944	Cx312	7791919165	2025-07-12 00:00:00	Needs Followup	Alto service \r\nDent paint 	2025-02-09 11:16:15.485628	9	2025-07-01 06:50:29.884428	
4136	Cx302	9057919681	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-18 06:23:59.244554	9	2025-07-01 06:50:29.884428	
4138	Cx304	9529926927	2025-07-12 00:00:00	Needs Followup	Drycleaning 	2025-02-18 06:31:21.589132	9	2025-07-01 06:50:29.884428	
4139	Cx305	9829300051	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-18 06:32:04.305806	9	2025-07-01 06:50:29.884428	
4140	Cx308	8559935252	2025-07-12 00:00:00	Needs Followup	Dent paint 	2025-02-18 06:50:58.61261	9	2025-07-01 06:50:29.884428	
4141	Cx310	9929698507	2025-07-12 00:00:00	Needs Followup	Car service 	2025-02-18 06:51:54.392082	9	2025-07-01 06:50:29.884428	
4142	Cx400	8560027272	2025-07-12 00:00:00	Needs Followup	i20\r\nBumper new\r\nPaint \r\n	2025-02-18 06:52:49.387411	9	2025-07-01 06:50:29.884428	
4146	Cx407	9782992098	2025-07-12 00:00:00	Needs Followup	Ac gas \r\nWr 	2025-02-18 06:57:04.898156	9	2025-07-01 06:50:29.884428	
4151	Cx412	7387372170	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-18 07:03:15.819562	9	2025-07-01 06:50:29.884428	
4152	Cx413	8655486158	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-18 07:03:46.562167	9	2025-07-01 06:50:29.884428	
4153	Cx414	8387020066	2025-07-12 00:00:00	Needs Followup	Service  car	2025-02-18 07:04:28.427275	9	2025-07-01 06:50:29.884428	
4160	Cx420	9024263040	2025-07-12 00:00:00	Needs Followup	Innova 4999	2025-02-18 07:10:46.026453	9	2025-07-01 06:50:29.884428	
4163	Cx423	9929944244	2025-07-12 00:00:00	Needs Followup	Wr \r\nService 2199	2025-02-18 07:12:47.931532	9	2025-07-01 06:50:29.884428	
4166	Cx426	9784137284	2025-07-12 00:00:00	Needs Followup	Dent paint 	2025-02-18 07:15:16.808942	9	2025-07-01 06:50:29.884428	
4171	Cx428	9950191947	2025-07-12 00:00:00	Needs Followup	S cross  Service  2999	2025-02-18 07:22:17.246566	9	2025-07-01 06:50:29.884428	
4173	Cx430	7726093040	2025-07-12 00:00:00	Needs Followup	Service  	2025-02-18 07:31:37.72057	9	2025-07-01 06:50:29.884428	
4174	Cx431	9680538361	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-18 07:37:02.687229	9	2025-07-01 06:50:29.884428	
4188	Cx460	7791919165	2025-07-12 00:00:00	Needs Followup	Alto Dent paint 	2025-02-18 10:10:53.972987	9	2025-07-01 06:50:29.884428	
4235	Cx449	9529062827	2025-07-12 00:00:00	Needs Followup	Swift Dent paint \r\n24000	2025-02-19 07:56:58.892765	9	2025-07-01 06:50:29.884428	
4245	anil jain	9414046252	2025-07-12 00:00:00	Needs Followup	Verna dent paint 	2025-02-20 04:45:45.236499	9	2025-07-01 06:50:29.884428	
4257	Cx506	9950569696	2025-07-12 00:00:00	Needs Followup	Car service 	2025-02-21 11:11:57.713013	9	2025-07-01 06:50:29.884428	
4258	Cx506	9950569696	2025-07-12 00:00:00	Needs Followup	Skoda \r\nAc gas 	2025-02-21 11:17:31.972755	9	2025-07-01 06:50:29.884428	
4263	Cx514	9928846449	2025-07-12 00:00:00	Needs Followup	Ac gas\r\nSharp 	2025-02-21 12:27:51.602492	9	2025-07-01 06:50:29.884428	
4288	CX 514	9587968413	2025-07-12 00:00:00	Needs Followup	Car service \r\nAbhi out off jaipur 	2025-02-22 08:39:23.116395	9	2025-07-01 06:50:29.884428	
4291	Cx516	8058258160	2025-07-12 00:00:00	Needs Followup	Dent paint  tata tiago 	2025-02-22 08:47:53.887663	9	2025-07-01 06:50:29.884428	
4309	Cx519	6377208269	2025-07-12 00:00:00	Needs Followup	No answer 	2025-02-23 11:35:34.004246	9	2025-07-01 06:50:29.884428	
4320	Cx531	8006306950	2025-07-12 00:00:00	Needs Followup	Car service \r\nBaleno\r\nCall cut 	2025-02-23 13:08:33.785007	9	2025-07-01 06:50:29.884428	
4329	Cx540	6350502938	2025-07-12 00:00:00	Needs Followup	Ac service 	2025-02-23 13:17:14.22713	9	2025-07-01 06:50:29.884428	
4345	gaadimech	8385998599	2025-07-12 00:00:00	Needs Followup	Denide swift service price jyada hai-3699\r\nCall cut	2025-02-24 10:06:41.178121	9	2025-07-01 06:50:29.884428	
4368	Cx541	8955777666	2025-07-12 00:00:00	Needs Followup	Swift 2699\r\n	2025-02-25 09:13:50.200813	9	2025-07-01 06:50:29.884428	
4400	CX 550	9881078813	2025-07-12 00:00:00	Needs Followup	Ac service 	2025-02-26 08:17:41.17104	9	2025-07-01 06:50:29.884428	
7327	gaadimech 	8058309756	2025-07-12 00:00:00	Did Not Pick Up	Not pick 	2025-05-20 09:10:47.330555	9	2025-07-01 06:50:29.884428	
7427	gaadimech	8829904909	2025-07-12 00:00:00	Did Not Pick Up	Baleno 2799\r\nNext month 8 june ke bad	2025-05-23 07:35:38.259776	9	2025-07-01 06:50:29.884428	
7530	Cx2065	7597020116	2025-07-12 00:00:00	Needs Followup	i10 service \r\n	2025-05-27 10:54:37.885297	9	2025-07-01 06:50:29.884428	
7537	gaadimech 	6350628508	2025-07-12 00:00:00	Needs Followup	Baleno 2799\r\nAbhi plan nahi h next month sochenge	2025-05-28 06:32:20.155543	9	2025-07-01 06:50:29.884428	
2695	Sushil 	8239297047	2025-07-12 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot requirement service done 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
2789	Customer	9996017865	2025-07-12 00:00:00	Needs Followup	Busy call u letter \r\nService done\r\nAgain open inquiry 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2845	Customer	8824894374	2025-07-12 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
3000	Customer	9887099994	2025-07-12 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3044	Customer	9654293781	2025-07-12 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3045	Customer	9950672697	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3103	Customer	9873160755	2025-07-12 00:00:00	Needs Followup	Exter dent paint 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3107	Customer	9116643833	2025-07-12 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3160	Customer	9950876161	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3167	Customer	9829733757	2025-07-12 00:00:00	Needs Followup	Honda City। 2899\r\n	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3217	Customer 	7742185499	2025-07-12 00:00:00	Needs Followup	Call cut	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3292	.	9929414647	2025-07-12 00:00:00	Needs Followup	Creta 3199 package share	2025-01-21 10:32:21.170778	9	2025-07-01 06:50:29.884428	
3342	Customer 	7737584167	2025-07-12 00:00:00	Needs Followup	Altroz 2799	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3388	.	9828070565	2025-07-12 00:00:00	Needs Followup	Call cut not interested 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3418	.	9828878408	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3459	.	8112240791	2025-07-12 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3462	.	9828224987	2025-07-12 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3495	.	8851879828	2025-07-12 00:00:00	Needs Followup	Ford eco sport suspension \r\nCall cut 	2025-01-28 06:07:51.486916	9	2025-07-01 06:50:29.884428	
3501	.	9460190288	2025-07-12 00:00:00	Needs Followup	Xcent 2799	2025-01-28 06:07:51.486916	9	2025-07-01 06:50:29.884428	
3505	.	9828112353	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
3544	.	7878576113	2025-07-12 00:00:00	Needs Followup	Swift 2599	2025-01-31 04:20:51.980955	9	2025-07-01 06:50:29.884428	
3565	.	9828222220	2025-07-12 00:00:00	Needs Followup	Call cut	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3627	.	9829011151	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3628	.	9829017171	2025-07-12 00:00:00	Needs Followup	Not interested 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3652	.	9414073558	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3703	.	9828777751	2025-07-12 00:00:00	Needs Followup	Call back sundy busy in shadi\r\nNot pick 	2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	
3718	.	9829012007	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-05 04:25:05.267449	9	2025-07-01 06:50:29.884428	
3726	.	7689000555	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-05 07:07:42.885137	9	2025-07-01 06:50:29.884428	
3753	.	9509007072	2025-07-12 00:00:00	Needs Followup	Not pick	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3764	.	8076028564	2025-07-12 00:00:00	Needs Followup	Sonet 2699	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3767	.	7230800541	2025-07-12 00:00:00	Needs Followup	Not requirement 	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3774	.	9993933595	2025-07-12 00:00:00	Needs Followup		2025-02-05 11:59:45.332338	9	2025-07-01 06:50:29.884428	\N
3800	.	7073290341	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3859	.	9166284546	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	
3863	.	9783696600	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-07 09:03:50.545995	9	2025-07-01 06:50:29.884428	
3881	.	9414883100	2025-07-12 00:00:00	Needs Followup		2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3883	.	9887172121	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3885	.	9876548053	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3968	.	9784338911	2025-07-12 00:00:00	Needs Followup	Not pick	2025-02-12 08:22:32.395323	9	2025-07-01 06:50:29.884428	
3991	.	9331007200	2025-07-12 00:00:00	Needs Followup	Not required 	2025-02-12 10:22:17.778046	9	2025-07-01 06:50:29.884428	
4004	.	9828130882	2025-07-12 00:00:00	Needs Followup	Not interested 	2025-02-12 11:17:28.203679	9	2025-07-01 06:50:29.884428	
4017	.	9717220797	2025-07-12 00:00:00	Needs Followup	Not interested 	2025-02-12 11:51:51.00811	9	2025-07-01 06:50:29.884428	
4043	.	8003457888	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-15 09:51:12.14967	9	2025-07-01 06:50:29.884428	
4045	.	7348923553	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-15 09:55:06.303673	9	2025-07-01 06:50:29.884428	
4066	.	8058048635	2025-07-12 00:00:00	Needs Followup	Eon steering wheel issue banipark	2025-02-15 10:56:29.460525	9	2025-07-01 06:50:29.884428	
4109	.	9829006811	2025-07-12 00:00:00	Needs Followup	Not connect 	2025-02-16 10:37:22.742944	9	2025-07-01 06:50:29.884428	
4115	.	9829067071	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-16 10:55:18.652708	9	2025-07-01 06:50:29.884428	
4116	gaadimech 	9983298277	2025-07-12 00:00:00	Needs Followup	Eco van 2499	2025-02-16 10:58:54.284816	9	2025-07-01 06:50:29.884428	
4126	.	9829771100	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-16 11:59:12.756474	9	2025-07-01 06:50:29.884428	
4195	.	9828015792	2025-07-12 00:00:00	Needs Followup	Sonet 2599	2025-02-18 11:06:00.551761	9	2025-07-01 06:50:29.884428	
4202	.	9582340766	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-18 11:45:11.496672	9	2025-07-01 06:50:29.884428	
4206	.	9929604585	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-18 11:55:29.593265	9	2025-07-01 06:50:29.884428	
4219	.	9828031334	2025-07-12 00:00:00	Needs Followup	Switch off 	2025-02-18 12:11:10.43707	9	2025-07-01 06:50:29.884428	
4223	jeet	6376226726	2025-07-12 00:00:00	Needs Followup	Santa fe 3199 call cut gadimech	2025-02-19 04:42:08.849779	9	2025-07-01 06:50:29.884428	
4229	.	9811421493	2025-07-12 00:00:00	Needs Followup	Wagnor 2199	2025-02-19 05:09:01.981384	9	2025-07-01 06:50:29.884428	
4250	gaadimech	8306741847	2025-07-12 00:00:00	Needs Followup	Call cut	2025-02-20 09:19:28.992753	9	2025-07-01 06:50:29.884428	
4266	gadimech 	8740960047	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-22 04:26:50.481727	9	2025-07-01 06:50:29.884428	
4294	.	6375081791	2025-07-12 00:00:00	Needs Followup	Dent paint jhunjhunu se hai jaipur visit karenge than contact kar lenge	2025-02-22 09:56:42.574551	9	2025-07-01 06:50:29.884428	
4296	.	9057243346	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-22 11:25:52.966054	9	2025-07-01 06:50:29.884428	
4335	gaadimech	8955763978	2025-07-12 00:00:00	Needs Followup	Xuv 500 dent paint \r\nBusy call u later 	2025-02-24 04:58:35.49494	9	2025-07-01 06:50:29.884428	
4344	gaadimech 	9694081717	2025-07-12 00:00:00	Needs Followup	I20 service 2699\r\nDent paint 2200 penal\r\nRubbing polishing 1200 	2025-02-24 10:03:26.147972	9	2025-07-01 06:50:29.884428	
4350	raju thakur gaadimech	6209626473	2025-07-12 00:00:00	Needs Followup	Scorpio 4699	2025-02-25 04:41:56.874325	9	2025-07-01 06:50:29.884428	
4358	gaadimech 	8003008023	2025-07-12 00:00:00	Needs Followup	Wagnore 2000 panel	2025-02-25 05:44:31.216395	9	2025-07-01 06:50:29.884428	
4370	mohit	6375844390	2025-07-12 00:00:00	Needs Followup	Amaze ac checkup	2025-02-25 09:20:12.854026	9	2025-07-01 06:50:29.884428	
4377	.	9653768533	2025-07-12 00:00:00	Needs Followup	Not valid no 	2025-02-25 11:24:36.345801	9	2025-07-01 06:50:29.884428	
4380	.	9828140703	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-25 11:28:36.94486	9	2025-07-01 06:50:29.884428	
4381	.	9829899994	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-25 11:29:44.022448	9	2025-07-01 06:50:29.884428	
4386	.	9414261879	2025-07-12 00:00:00	Needs Followup	Call cut 	2025-02-25 11:38:18.134943	9	2025-07-01 06:50:29.884428	
4389	.	9829033594	2025-07-12 00:00:00	Needs Followup	Not pick 	2025-02-25 11:50:52.329099	9	2025-07-01 06:50:29.884428	
4391	.	9414214191	2025-07-13 00:00:00	Needs Followup	Not pick \r\nNot connect 	2025-02-25 11:56:20.241402	9	2025-07-01 06:50:29.884428	
4395	gaadimech 	7300366493	2025-07-13 00:00:00	Needs Followup	Honda city 2999 at jodhpur hai	2025-02-26 05:06:02.982497	9	2025-07-01 06:50:29.884428	
4396	gaadimech 	9414380988	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-02-26 05:07:44.887945	9	2025-07-01 06:50:29.884428	
4417	gaadimech 	7073235939	2025-07-13 00:00:00	Needs Followup	Alto1999 swift 2599\r\nHome service ke liye check kia tha 	2025-02-27 05:05:09.042431	9	2025-07-01 06:50:29.884428	
4424	gaadimech 	7727933666	2025-07-13 00:00:00	Needs Followup	Not pick \r\nCall cut	2025-02-27 08:35:09.135298	9	2025-07-01 06:50:29.884428	
4453	gaadimech 	7891071089	2025-07-13 00:00:00	Needs Followup	Parts ke liye check kia tha	2025-03-01 10:31:24.424388	9	2025-07-01 06:50:29.884428	
4529	Ivr	8003356223	2025-07-13 00:00:00	Needs Followup	Baleno dent paint 2300	2025-03-04 12:10:06.026618	9	2025-07-01 06:50:29.884428	
4553	gadimech 	7976610053	2025-07-13 00:00:00	Needs Followup	Alto 800 didwana se hai Holi ke bad try krenge aane ki 	2025-03-07 05:46:57.365937	9	2025-07-01 06:50:29.884428	
4555	gaadimech 	8619932919	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-07 06:39:29.314317	9	2025-07-01 06:50:29.884428	
4557	gaadimech 	7023814498	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-07 08:49:19.235379	9	2025-07-01 06:50:29.884428	
4586	gaadimech	9783507743	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-08 05:07:48.397878	9	2025-07-01 06:50:29.884428	
4588	gaadimech 	7737407731	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-08 05:11:09.352249	9	2025-07-01 06:50:29.884428	
4597	gaadimech 	9829502418	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-08 06:03:56.142979	9	2025-07-01 06:50:29.884428	
4598	gaadimech 	9001738974	2025-07-13 00:00:00	Needs Followup	Eco van 2599	2025-03-08 06:08:50.194441	9	2025-07-01 06:50:29.884428	
4607	gaadimech	9660423811	2025-07-13 00:00:00	Needs Followup	Not pick 	2025-03-08 09:26:08.069798	9	2025-07-01 06:50:29.884428	
4609	gaadimech 	9928383855	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-08 09:37:49.282109	9	2025-07-01 06:50:29.884428	
4617	gaadimech 	9587777878	2025-07-13 00:00:00	Needs Followup	Call cut	2025-03-09 04:59:54.929476	9	2025-07-01 06:50:29.884428	
4628	gaadimech 	7878145216	2025-07-13 00:00:00	Needs Followup	Beat 2399 jhunjhunu se hai 	2025-03-09 11:58:01.607637	9	2025-07-01 06:50:29.884428	
4629	gaadimech 	8239394083	2025-07-13 00:00:00	Needs Followup	Switch off 	2025-03-09 12:04:04.32592	9	2025-07-01 06:50:29.884428	
4661	gaadimech 	8887543602	2025-07-13 00:00:00	Needs Followup	 Mene koi inquiry nhi ki 	2025-03-11 07:51:21.203023	9	2025-07-01 06:50:29.884428	
4667	gaadimech 	7014723006	2025-07-13 00:00:00	Needs Followup	Call cut	2025-03-11 11:22:05.940156	9	2025-07-01 06:50:29.884428	
4676	gaadimech 	7727093406	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-12 04:34:44.2711	9	2025-07-01 06:50:29.884428	
4678	gaadimech 	8696445526	2025-07-13 00:00:00	Needs Followup	Busy call u later 	2025-03-12 04:55:11.402898	9	2025-07-01 06:50:29.884428	
4682	gaadimech 	9929220972	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-12 05:09:27.98703	9	2025-07-01 06:50:29.884428	
4683	gaadimech 	9828047065	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-12 05:29:02.389811	9	2025-07-01 06:50:29.884428	
4684	gaadimech 	9166028562	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-12 05:31:57.292435	9	2025-07-01 06:50:29.884428	
4685	gaadimech 	9413314226	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-12 05:50:49.37865	9	2025-07-01 06:50:29.884428	
4706	gaadimech	9782960091	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-13 06:34:36.045675	9	2025-07-01 06:50:29.884428	
4709	gaadimech 	8290357480	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-13 08:25:15.225348	9	2025-07-01 06:50:29.884428	
4710	gaadimech 	9828807954	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-13 08:27:26.362787	9	2025-07-01 06:50:29.884428	
4713	gaadimech 	9799385447	2025-07-13 00:00:00	Needs Followup	Not pick	2025-03-13 10:27:24.539684	9	2025-07-01 06:50:29.884428	
1292	Cx123	9116499546	2025-07-13 00:00:00	Did Not Pick Up	No answer	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
3478	MAYANK GOYAL	8949758653	2025-07-13 00:00:00	Feedback	I10 cluch issue\r\nLebour 700 only	2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	RJ36CA2581
3749	.	8800648282	2025-07-13 00:00:00	Needs Followup	Not requirement \r\n	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
6711	gaadimech 	9214074189	2025-07-13 00:00:00	Did Not Pick Up	Venue 3199\r\nNot pick 	2025-04-26 09:55:50.984895	9	2025-07-01 06:50:29.884428	
7331	Gaadimech 	7690013522	2025-07-13 00:00:00	Did Not Pick Up	Brezza  service 3599	2025-05-20 12:24:23.487802	9	2025-07-01 06:50:29.884428	
7339	gaadimech 	9587111897	2025-07-13 00:00:00	Did Not Pick Up	Amaze 3199 call back	2025-05-21 04:49:10.586923	9	2025-07-01 06:50:29.884428	
7459	Cx2040	8741922256	2025-07-13 00:00:00	Needs Followup	Seltos dent paint \r\nJayada hai amount	2025-05-24 09:04:24.108336	9	2025-07-01 06:50:29.884428	
7461	Cx2041	8302477588	2025-07-13 00:00:00	Needs Followup	Dent paint 	2025-05-24 09:33:37.85739	9	2025-07-01 06:50:29.884428	
7563	Cx 2070	6377385045	2025-07-13 00:00:00	Needs Followup	Car service\r\nAbhi nahi karwani hai 	2025-05-29 05:21:21.511819	9	2025-07-01 06:50:29.884428	
7620	gaadimech 	9352660300	2025-07-13 00:00:00	Did Not Pick Up	Beat 2999 \r\nNor requirment 	2025-05-30 12:09:57.982528	9	2025-07-01 06:50:29.884428	
7635	Cx2086	9785448444	2025-07-13 00:00:00	Needs Followup	ECCO service \r\n	2025-05-31 06:53:46.350788	9	2025-07-01 06:50:29.884428	
1	Surakshit Soni	9001436050	2025-07-13 00:00:00	Needs Followup	Creta Car Servicing Rs.3599	2024-11-22 11:47:53	9	2025-07-01 06:50:29.884428	\N
2	Test User	9414795219	2025-07-13 00:00:00	Needs Followup	Alto Servicing Rs.1999	2024-11-22 11:49:14	9	2025-07-01 06:50:29.884428	\N
11	.	9828165635	2025-07-13 00:00:00	Needs Followup	Not pick a call tomorrow will be call	2024-11-23 07:56:25	9	2025-07-01 06:50:29.884428	\N
13	.	9887567685	2025-07-13 00:00:00	Needs Followup	Call back 	2024-11-23 08:38:49	9	2025-07-01 06:50:29.884428	\N
15	.	6375744828	2025-07-13 00:00:00	Needs Followup	Call back	2024-11-23 08:41:33	9	2025-07-01 06:50:29.884428	\N
16	.	6375744828	2025-07-13 00:00:00	Needs Followup	Call back	2024-11-23 08:41:37	9	2025-07-01 06:50:29.884428	\N
17	.	9530043900	2025-07-13 00:00:00	Needs Followup	Call back not pick a call 	2024-11-23 08:48:04	9	2025-07-01 06:50:29.884428	\N
18	.	9829233911	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-23 08:51:02	9	2025-07-01 06:50:29.884428	\N
19	.	7240666659	2025-07-13 00:00:00	Needs Followup	Number is not available 	2024-11-23 08:53:28	9	2025-07-01 06:50:29.884428	\N
20	.	9887169779	2025-07-13 00:00:00	Needs Followup	Call back 	2024-11-23 09:00:53	9	2025-07-01 06:50:29.884428	\N
23	.	8561099830	2025-07-13 00:00:00	Needs Followup	What's app par details share	2024-11-23 09:10:25	9	2025-07-01 06:50:29.884428	\N
24	.	9828841021	2025-07-13 00:00:00	Needs Followup	Call back 	2024-11-23 09:17:39	9	2025-07-01 06:50:29.884428	\N
26	.	9414072257	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-23 09:24:21	9	2025-07-01 06:50:29.884428	\N
32	.	7340661006	2025-07-13 00:00:00	Needs Followup	Service Done not interested 	2024-11-23 09:37:19	9	2025-07-01 06:50:29.884428	\N
33	.	9636735847	2025-07-13 00:00:00	Needs Followup	Wrong number 	2024-11-23 09:39:08	9	2025-07-01 06:50:29.884428	\N
34	.	6375308379	2025-07-13 00:00:00	Needs Followup	Incoming call not available 	2024-11-23 09:40:26	9	2025-07-01 06:50:29.884428	\N
35	.	9783557777	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-23 09:42:27	9	2025-07-01 06:50:29.884428	\N
36	.	9829075536	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-23 09:46:46	9	2025-07-01 06:50:29.884428	\N
37	.	8955688404	2025-07-13 00:00:00	Needs Followup	Swich off 	2024-11-23 09:51:56	9	2025-07-01 06:50:29.884428	\N
38	.	8005977377	2025-07-13 00:00:00	Needs Followup	Not interested cut a call 	2024-11-23 09:54:53	9	2025-07-01 06:50:29.884428	\N
40	.	9828652272	2025-07-13 00:00:00	Needs Followup	Customer busy call back 	2024-11-23 10:09:30	9	2025-07-01 06:50:29.884428	\N
41	.	9829040013	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-23 10:12:25	9	2025-07-01 06:50:29.884428	\N
42	.	9829040013	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-23 10:13:58	9	2025-07-01 06:50:29.884428	\N
43	.	9314022240	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-23 10:14:44	9	2025-07-01 06:50:29.884428	\N
44	.	9829027708	2025-07-13 00:00:00	Needs Followup	Service Done & cut a call 	2024-11-23 10:19:51	9	2025-07-01 06:50:29.884428	\N
50	.	9414084090	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-23 10:57:20	9	2025-07-01 06:50:29.884428	\N
54	.	9414157915	2025-07-13 00:00:00	Needs Followup	Out of Jaipur shift Udaipur	2024-11-23 11:00:04	9	2025-07-01 06:50:29.884428	\N
59	.	9314522078	2025-07-13 00:00:00	Needs Followup	Wrong number 	2024-11-23 11:02:51	9	2025-07-01 06:50:29.884428	\N
62	.	9314522078	2025-07-13 00:00:00	Needs Followup	Wrong number 	2024-11-23 11:04:54	9	2025-07-01 06:50:29.884428	\N
67	.	9828595940	2025-07-13 00:00:00	Needs Followup	Not interested & cut a call \r\n	2024-11-23 11:14:44	9	2025-07-01 06:50:29.884428	\N
68	.	9351999383	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-23 11:16:55	9	2025-07-01 06:50:29.884428	\N
69	.	9782607757	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-23 11:18:47	9	2025-07-01 06:50:29.884428	\N
70	.	7737196496	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-23 11:28:50	9	2025-07-01 06:50:29.884428	\N
71	.	9829638933	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-23 11:32:30	9	2025-07-01 06:50:29.884428	\N
72	.	9314749604	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-23 11:34:30	9	2025-07-01 06:50:29.884428	\N
73	.	9414777780	2025-07-13 00:00:00	Needs Followup	Call back 	2024-11-23 11:36:32	9	2025-07-01 06:50:29.884428	\N
74	.	9414777780	2025-07-13 00:00:00	Needs Followup	Wrong number 	2024-11-23 11:53:07	9	2025-07-01 06:50:29.884428	\N
75	.	9314046594	2025-07-13 00:00:00	Needs Followup	Switch off 	2024-11-23 11:55:25	9	2025-07-01 06:50:29.884428	\N
76	.	9351425647	2025-07-13 00:00:00	Needs Followup	Cut a call & not interested 	2024-11-23 11:57:22	9	2025-07-01 06:50:29.884428	\N
77	.	9983593372	2025-07-13 00:00:00	Needs Followup	Not interested & cheap language	2024-11-23 12:13:32	9	2025-07-01 06:50:29.884428	\N
78	.	9829064143	2025-07-13 00:00:00	Needs Followup	Service Done only company 	2024-11-23 12:24:31	9	2025-07-01 06:50:29.884428	\N
79	.	8619911300	2025-07-13 00:00:00	Needs Followup	Only company me service 	2024-11-23 12:28:37	9	2025-07-01 06:50:29.884428	\N
81	.	9414049583	2025-07-13 00:00:00	Needs Followup	Not interested cut a call 	2024-11-23 12:31:26	9	2025-07-01 06:50:29.884428	\N
82	.	9530370225	2025-07-13 00:00:00	Needs Followup	Number out of service	2024-11-23 12:36:01	9	2025-07-01 06:50:29.884428	\N
87	.	9414032025	2025-07-13 00:00:00	Needs Followup	Not a car 	2024-11-23 12:52:40	9	2025-07-01 06:50:29.884428	\N
89	.	7737281190	2025-07-13 00:00:00	Needs Followup	No car 	2024-11-23 12:54:55	9	2025-07-01 06:50:29.884428	\N
105	Madhav sir	9636777379	2025-07-13 00:00:00	Needs Followup	Out of Jaipur, cus want call back\r\n\r\n call back Tommorow \r\nCall back 1st fab	2024-11-24 05:11:21	9	2025-07-01 06:50:29.884428	
106	.	9983215431	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-24 05:18:09	9	2025-07-01 06:50:29.884428	\N
107	.	9414752009	2025-07-13 00:00:00	Needs Followup	Cut a call not interested 	2024-11-24 05:21:34	9	2025-07-01 06:50:29.884428	\N
108	.	7976550585	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-24 05:23:58	9	2025-07-01 06:50:29.884428	\N
109	.	9829040503	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-24 05:26:36	9	2025-07-01 06:50:29.884428	\N
110	.	9509173031	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-24 05:35:20	9	2025-07-01 06:50:29.884428	\N
111	.	9829063045	2025-07-13 00:00:00	Needs Followup	Only company me service 	2024-11-24 05:39:42	9	2025-07-01 06:50:29.884428	\N
112	.	9565704023	2025-07-13 00:00:00	Needs Followup	Call not pick 	2024-11-24 05:42:06	9	2025-07-01 06:50:29.884428	\N
113	.	9829650566	2025-07-13 00:00:00	Needs Followup	Out of Jaipur shift 	2024-11-24 05:45:38	9	2025-07-01 06:50:29.884428	\N
114	.	9829650566	2025-07-13 00:00:00	Needs Followup	Out of Jaipur shift 	2024-11-24 05:48:36	9	2025-07-01 06:50:29.884428	\N
115	.	7014923491	2025-07-13 00:00:00	Needs Followup	Not interested cut a call 	2024-11-24 05:54:29	9	2025-07-01 06:50:29.884428	\N
116	.	7014923491	2025-07-13 00:00:00	Needs Followup	Not interested cut a call 	2024-11-24 05:58:44	9	2025-07-01 06:50:29.884428	\N
117	.	9828497475	2025-07-13 00:00:00	Needs Followup	Service Done 10 days pahle 	2024-11-24 06:00:13	9	2025-07-01 06:50:29.884428	\N
118	.	9799252930	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-24 06:34:38	9	2025-07-01 06:50:29.884428	\N
123	.	7339996487	2025-07-13 00:00:00	Needs Followup	Wrong number 	2024-11-24 06:39:39	9	2025-07-01 06:50:29.884428	\N
125	.	9887341786	2025-07-13 00:00:00	Needs Followup	Call back 	2024-11-24 06:42:04	9	2025-07-01 06:50:29.884428	\N
128	.	9819525227	2025-07-13 00:00:00	Needs Followup	New car 	2024-11-24 06:48:43	9	2025-07-01 06:50:29.884428	\N
129	.	7742145453	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-24 06:50:49	9	2025-07-01 06:50:29.884428	\N
130	.	7742145453	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-24 06:54:21	9	2025-07-01 06:50:29.884428	\N
131	.	7427802081	2025-07-13 00:00:00	Needs Followup	Switch off	2024-11-24 06:55:00	9	2025-07-01 06:50:29.884428	\N
132	.	8209410061	2025-07-13 00:00:00	Needs Followup	Cut a call 	2024-11-24 06:57:25	9	2025-07-01 06:50:29.884428	\N
133	.	9351094794	2025-07-13 00:00:00	Needs Followup	Incoming call is not available	2024-11-24 06:58:44	9	2025-07-01 06:50:29.884428	\N
134	.	9828155977	2025-07-13 00:00:00	Needs Followup	Out of Jaipur /Sirohi	2024-11-24 07:05:18	9	2025-07-01 06:50:29.884428	\N
135	.	6375623060	2025-07-13 00:00:00	Needs Followup	No car available 	2024-11-24 07:07:39	9	2025-07-01 06:50:29.884428	\N
136	.	9829012828	2025-07-13 00:00:00	Needs Followup	No requirement	2024-11-24 07:10:39	9	2025-07-01 06:50:29.884428	\N
137	.	9680140150	2025-07-13 00:00:00	Needs Followup	Not interested 	2024-11-24 07:12:42	9	2025-07-01 06:50:29.884428	\N
138	.	9414251346	2025-07-13 00:00:00	Needs Followup	Only company me service 	2024-11-24 07:16:46	9	2025-07-01 06:50:29.884428	\N
139	.	9414251346	2025-07-13 00:00:00	Needs Followup	Only company me service 	2024-11-24 07:16:49	9	2025-07-01 06:50:29.884428	\N
140	.	8708098001	2025-07-13 00:00:00	Needs Followup	Number invalid	2024-11-24 07:20:04	9	2025-07-01 06:50:29.884428	\N
142	.	9829012464	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 07:24:47	9	2025-07-01 06:50:29.884428	\N
143	.	9829061116	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 07:27:46	9	2025-07-01 06:50:29.884428	\N
144	.	8963003037	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 07:56:35	9	2025-07-01 06:50:29.884428	\N
145	.	9829259909	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 07:59:48	9	2025-07-01 06:50:29.884428	\N
146	.	9414111700	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 08:02:48	9	2025-07-01 06:50:29.884428	\N
147	Brijesh sir	9829031100	2025-07-14 00:00:00	Needs Followup	What's app details share 	2024-11-24 08:30:54	9	2025-07-01 06:50:29.884428	\N
148	.	8209306764	2025-07-14 00:00:00	Needs Followup	New car 	2024-11-24 08:31:44	9	2025-07-01 06:50:29.884428	\N
149	.	9983978899	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 08:34:44	9	2025-07-01 06:50:29.884428	\N
150	.	9119346115	2025-07-14 00:00:00	Needs Followup	Wrong number 	2024-11-24 08:36:34	9	2025-07-01 06:50:29.884428	\N
151	.	9694444977	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 08:38:43	9	2025-07-01 06:50:29.884428	\N
152	.	9828018899	2025-07-14 00:00:00	Needs Followup	What's app details share 	2024-11-24 08:51:17	9	2025-07-01 06:50:29.884428	\N
153	.	9799899143	2025-07-14 00:00:00	Needs Followup	Switch off 	2024-11-24 08:53:04	9	2025-07-01 06:50:29.884428	\N
154	.	9875019789	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 08:55:21	9	2025-07-01 06:50:29.884428	\N
155	.	9829950500	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 08:57:25	9	2025-07-01 06:50:29.884428	\N
156	.	9414054204	2025-07-14 00:00:00	Needs Followup	Cut a call not interested 	2024-11-24 08:58:52	9	2025-07-01 06:50:29.884428	\N
157	.	9660575025	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-24 09:01:04	9	2025-07-01 06:50:29.884428	\N
158	.	7665156560	2025-07-14 00:00:00	Needs Followup	Delhi shift 	2024-11-24 09:06:01	9	2025-07-01 06:50:29.884428	\N
159	.	7976860487	2025-07-14 00:00:00	Needs Followup	Cut a call	2024-11-24 09:07:42	9	2025-07-01 06:50:29.884428	\N
160	.	9829512233	2025-07-14 00:00:00	Needs Followup	No requirement	2024-11-24 09:09:59	9	2025-07-01 06:50:29.884428	\N
161	.	9660287961	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 09:12:01	9	2025-07-01 06:50:29.884428	\N
162	.	9829058796	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-24 09:13:44	9	2025-07-01 06:50:29.884428	\N
163	.	7891056888	2025-07-14 00:00:00	Needs Followup	Not interested cut a call 	2024-11-24 09:15:26	9	2025-07-01 06:50:29.884428	\N
4679	gaadimech 	8739909820	2025-07-14 00:00:00	Needs Followup	Not pick	2025-03-12 04:59:43.952504	9	2025-07-01 06:50:29.884428	
4680	gaadimech 	9352322216	2025-07-14 00:00:00	Needs Followup	Call cut	2025-03-12 05:01:34.652097	9	2025-07-01 06:50:29.884428	
4727	.	7976550585	2025-07-14 00:00:00	Needs Followup	not pick	2025-03-13 11:07:16.312628	9	2025-07-01 06:50:29.884428	
3988	.	7790927812	2025-07-14 00:00:00	Did Not Pick Up	Not interested \r\nCall cut	2025-02-12 10:14:19.345775	9	2025-07-01 06:50:29.884428	
6498	gaadimech 	9650635354	2025-07-14 00:00:00	Did Not Pick Up	Brezza 3599	2025-04-21 11:56:02.15386	9	2025-07-01 06:50:29.884428	
7307	Cx2027	9828277276	2025-07-14 00:00:00	Needs Followup	Baleno \r\nService 	2025-05-19 09:04:38.457014	9	2025-07-01 06:50:29.884428	
7400	gaadimech	7891725560	2025-07-14 00:00:00	Did Not Pick Up	Kuv 100 2999	2025-05-22 12:41:52.372233	9	2025-07-01 06:50:29.884428	
7531	Cx2060	8619938693	2025-07-14 00:00:00	Needs Followup	Abhi nahi	2025-05-27 10:56:14.684654	9	2025-07-01 06:50:29.884428	
7566	gaadimech 	7665555951	2025-07-14 00:00:00	Did Not Pick Up	I10 2299\r\nSeltos3599 \r\nTonk road\r\n	2025-05-29 06:59:59.658037	9	2025-07-01 06:50:29.884428	
7603	gaadimech	9549651214	2025-07-14 00:00:00	Did Not Pick Up	Verna 3599 not requirement 	2025-05-30 05:17:01.957956	9	2025-07-01 06:50:29.884428	
7690	Cx2097	9639073745	2025-07-14 00:00:00	Needs Followup	Altoz abhi free service hai	2025-06-02 06:09:41.931535	9	2025-07-01 06:50:29.884428	
164	.	9079205551	2025-07-14 00:00:00	Needs Followup	Wrong number 	2024-11-24 09:17:13	9	2025-07-01 06:50:29.884428	\N
165	.	9314512704	2025-07-14 00:00:00	Needs Followup	Not requirement	2024-11-24 09:19:44	9	2025-07-01 06:50:29.884428	\N
166	.	8094881487	2025-07-14 00:00:00	Needs Followup	Incoming call not available	2024-11-24 09:24:14	9	2025-07-01 06:50:29.884428	\N
167	.	7728917696	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 09:26:13	9	2025-07-01 06:50:29.884428	\N
168	.	9929108240	2025-07-14 00:00:00	Needs Followup	Number is not available\r\n	2024-11-24 09:28:03	9	2025-07-01 06:50:29.884428	\N
169	.	9530022721	2025-07-14 00:00:00	Needs Followup	Service done by other workshop \r\nEtios 2899	2024-11-24 09:30:37	9	2025-07-01 06:50:29.884428	\N
170	.	9785961068	2025-07-14 00:00:00	Needs Followup	Number out of service	2024-11-24 09:32:10	9	2025-07-01 06:50:29.884428	\N
171	.	9929055226	2025-07-14 00:00:00	Needs Followup	No car 	2024-11-24 09:34:09	9	2025-07-01 06:50:29.884428	\N
172	.	9875045467	2025-07-14 00:00:00	Needs Followup	Service Done not requirement	2024-11-24 09:42:07	9	2025-07-01 06:50:29.884428	\N
173	.	9928515982	2025-07-14 00:00:00	Needs Followup	Incoming call not available	2024-11-24 09:44:15	9	2025-07-01 06:50:29.884428	\N
175	.	6377703450	2025-07-14 00:00:00	Needs Followup	No car 	2024-11-24 10:29:27	9	2025-07-01 06:50:29.884428	\N
176	.	9057290453	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 10:31:10	9	2025-07-01 06:50:29.884428	\N
177	.	9352058000	2025-07-14 00:00:00	Needs Followup	Call back 	2024-11-24 10:33:33	9	2025-07-01 06:50:29.884428	\N
178	.	9829071466	2025-07-14 00:00:00	Needs Followup	 Cut a call 	2024-11-24 10:37:36	9	2025-07-01 06:50:29.884428	\N
179	.	9571969219	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-24 10:42:01	9	2025-07-01 06:50:29.884428	\N
180	.	9828560648	2025-07-14 00:00:00	Needs Followup	Out of Jaipur shift 	2024-11-24 10:44:41	9	2025-07-01 06:50:29.884428	\N
181	.	8619816751	2025-07-14 00:00:00	Needs Followup	Call back 	2024-11-24 10:47:27	9	2025-07-01 06:50:29.884428	\N
182	.	8302759948	2025-07-14 00:00:00	Needs Followup	Number invalid	2024-11-24 10:49:06	9	2025-07-01 06:50:29.884428	\N
183	.	9828023232	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 10:52:11	9	2025-07-01 06:50:29.884428	\N
184	.	9314910051	2025-07-14 00:00:00	Needs Followup	 Number invalid 	2024-11-24 10:54:31	9	2025-07-01 06:50:29.884428	\N
185	.	9887201469	2025-07-14 00:00:00	Needs Followup	Only company service 	2024-11-24 10:59:15	9	2025-07-01 06:50:29.884428	\N
186	.	9828045845	2025-07-14 00:00:00	Needs Followup	WhatsApp package share\r\n	2024-11-24 11:04:27	9	2025-07-01 06:50:29.884428	\N
187	.	9829244496	2025-07-14 00:00:00	Needs Followup	Call back 	2024-11-24 11:10:51	9	2025-07-01 06:50:29.884428	\N
188	.	9828541070	2025-07-14 00:00:00	Needs Followup	Ajmer shift	2024-11-24 11:16:44	9	2025-07-01 06:50:29.884428	\N
189	.	9829011933	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-24 11:18:56	9	2025-07-01 06:50:29.884428	\N
190	.	7014122937	2025-07-14 00:00:00	Needs Followup	WhatsApp package share 	2024-11-24 11:26:18	9	2025-07-01 06:50:29.884428	\N
191	.	9887508878	2025-07-14 00:00:00	Needs Followup	Incoming call is not available	2024-11-24 11:30:53	9	2025-07-01 06:50:29.884428	\N
192	.	9414052285	2025-07-14 00:00:00	Needs Followup	No car	2024-11-24 11:36:24	9	2025-07-01 06:50:29.884428	\N
193	.	9829050200	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 11:37:56	9	2025-07-01 06:50:29.884428	\N
194	.	9636514863	2025-07-14 00:00:00	Needs Followup	Out of Jaipur 	2024-11-24 11:40:08	9	2025-07-01 06:50:29.884428	\N
199	.	9887154541	2025-07-14 00:00:00	Needs Followup	No car 	2024-11-24 11:49:49	9	2025-07-01 06:50:29.884428	\N
205	.	8168536017	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-24 12:01:51	9	2025-07-01 06:50:29.884428	\N
206	Manish sir 	9352868731	2025-07-14 00:00:00	Needs Followup	WhatsApp package share 	2024-11-24 12:08:51	9	2025-07-01 06:50:29.884428	\N
207	.	7737096760	2025-07-14 00:00:00	Needs Followup	No requirement	2024-11-24 12:26:55	9	2025-07-01 06:50:29.884428	\N
210	.	7737096760	2025-07-14 00:00:00	Needs Followup	No requirement	2024-11-24 12:32:11	9	2025-07-01 06:50:29.884428	\N
211	.	9773307236	2025-07-14 00:00:00	Needs Followup	Wrong number 	2024-11-24 12:32:51	9	2025-07-01 06:50:29.884428	\N
215	.	8696100161	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-24 13:01:46	9	2025-07-01 06:50:29.884428	\N
217	.	9799138596	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-25 06:12:33	9	2025-07-01 06:50:29.884428	\N
221	.	9636039721	2025-07-14 00:00:00	Needs Followup	Call back & busy 	2024-11-25 06:52:55	9	2025-07-01 06:50:29.884428	\N
227	.	8619775446	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-25 07:22:54	9	2025-07-01 06:50:29.884428	\N
244	Vipin ji	9414057596	2025-07-14 00:00:00	Needs Followup	Abhi inki family mekoi admitted h hospital se free hone pr call back	2024-11-25 07:51:37	9	2025-07-01 06:50:29.884428	\N
251	Bhajanlal vishnoi	7412941729	2025-07-14 00:00:00	Needs Followup	Kal subah 11 bje Scorpio 4699 ka sarvice pack Reg.no GJ17xx1399 Garage R.k.motars /madam m sham tk Jaipur phunchuga or Kal subah gadi chjod dunga.\r\n\r\nnow cus meet with an accident, call after 09-Dec	2024-11-25 08:27:31	9	2025-07-01 06:50:29.884428	
253	.	9829198505	2025-07-14 00:00:00	Needs Followup	Call back 	2024-11-25 08:37:08	9	2025-07-01 06:50:29.884428	\N
264	Dilip	9079179456	2025-07-14 00:00:00	Needs Followup	Scorpio 4699 sarvice pack 27 ko R.k Motors pr aayenge 	2024-11-25 09:59:26	9	2025-07-01 06:50:29.884428	
336	.	7877630301	2025-07-14 00:00:00	Needs Followup	Call not pick\r\nNot pick	2024-11-26 12:37:33	9	2025-07-01 06:50:29.884428	
368	.	9352550631	2025-07-14 00:00:00	Needs Followup	New car warranty period me ha	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	\N
437	.	9782469500	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
438	.	9829017630	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
439	.	9166818899	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
440	.	9001292919	2025-07-14 00:00:00	Needs Followup	What's app details shared 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
441	.	9887423893	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
443	.	9982319954	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
445	.	9314716000	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
446	.	9414053198	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
447	.	9829036946	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
449	.	9715321194	2025-07-14 00:00:00	Needs Followup	Cut a call	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
450	Sanjay sir	9828015181	2025-07-14 00:00:00	Needs Followup	What's app details shared service package shared \r\nRitz, ecosport, punch \r\nNot pick\r\nNot pick	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
451	.	9799811068	2025-07-14 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
452	.	9571262363	2025-07-14 00:00:00	Needs Followup	Car not available 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
453	.	9840307937	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
454	.	7737711135	2025-07-14 00:00:00	Needs Followup	Not interested & cut a call	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
455	.	8209871877	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
456	Gopal sir	9314178390	2025-07-14 00:00:00	Needs Followup	WhatsApp package shared \r\nVki location share \r\nCall notpick\r\nNot pick\r\nInnova 4699\r\nCall back after 5 days\r\n	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
457	.	9352753004	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
458	.	9310912419	2025-07-14 00:00:00	Needs Followup	Car not available 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
462	Ravi chudhray	9983333116	2025-07-14 00:00:00	Needs Followup	Abhi under warranty h jise hi khata hogi  apko c.back	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
463	Manmohan 	9828145348	2025-07-14 00:00:00	Needs Followup	Abhi to sarvice ho gai hu h next time c.b\r\n	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
465	.	9414058194	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
466	Anil Rawat 	9828055166	2025-07-14 00:00:00	Needs Followup	Not intrested	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
467	......	9718001381	2025-07-14 00:00:00	Needs Followup	Out if sarvice	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
468	.	9828460045	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
470	.	7976281724	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
474	....	8209888927	2025-07-14 00:00:00	Needs Followup	C.b	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
475	....	8209888927	2025-07-14 00:00:00	Needs Followup	C.b	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
477	.	9829011607	2025-07-14 00:00:00	Needs Followup	Call back 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
478	Chandram	9829043551	2025-07-14 00:00:00	Needs Followup	Abhi need nhi h	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
479	Chandram	9829043551	2025-07-14 00:00:00	Needs Followup	Abhi need nhi h	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
481	Gajendar ji	8619226253	2025-07-14 00:00:00	Needs Followup	Abhi need nhi 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
482	.....	7014347872	2025-07-14 00:00:00	Needs Followup	Abhi busy hu	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
484	.	9314162952	2025-07-14 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
486	.	9414015248	2025-07-14 00:00:00	Needs Followup	Cut a call	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
488	........	7073716650	2025-07-14 00:00:00	Needs Followup	Call discancet	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
489	Vishnu sir 	9694999333	2025-07-14 00:00:00	Needs Followup	WhatsApp package shared 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
490	.	9352551356	2025-07-14 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
492	.........	9425855035	2025-07-15 00:00:00	Needs Followup	Do not distribute me	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
493	.	9414076947	2025-07-15 00:00:00	Needs Followup	Not interested & cut a call	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
494	.	7976795683	2025-07-15 00:00:00	Needs Followup	Not interested & cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
495	.	9828078376	2025-07-15 00:00:00	Needs Followup	Car not available 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
496	.................	9829120244	2025-07-15 00:00:00	Needs Followup	Abhi time nhi h\r\nNot pick	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
497	.	9214489899	2025-07-15 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
498	.	9887511449	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
501	.	9351637488	2025-07-15 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	\N
596	Gunjan Ramawat	9001094449	2025-07-15 00:00:00	Needs Followup	Pilot DL3CVW1198 inko mine 5499 ka pack diya tha ye banipark Aaye bhi the but inko ye pack me break oil mang rhe the alag se pise nhi dena chah rhe the\r\nNot pick	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
597	.	9983440440	2025-07-15 00:00:00	Needs Followup	Only company me service 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
599	Waseem Ansari 	9982631905	2025-07-15 00:00:00	Needs Followup	Ye visit kr ke ja chuke h 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
600	.	9887075100	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
601	.	9828015852	2025-07-15 00:00:00	Needs Followup	Cut a call 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
602	Pradeep ji	9929299947	2025-07-15 00:00:00	Needs Followup	Dent pent h 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
4807	CX	9982374514	2025-07-15 00:00:00	Needs Followup	Express Door Step Dry Cleaning!	2025-03-17 11:13:11.073217	9	2025-07-01 06:50:29.884428	
4809	gaadimech 	8955617015	2025-07-15 00:00:00	Needs Followup	I20 ac ges issue 	2025-03-17 11:39:22.615214	9	2025-07-01 06:50:29.884428	
2668	Customer	8005938032	2025-07-15 00:00:00	Needs Followup	Brezza 3299 call back\r\nMonday call back\r\n	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
3997	.	9269498375	2025-07-15 00:00:00	Did Not Pick Up	Honda city 2999\r\nNot interested 	2025-02-12 10:32:57.515346	9	2025-07-01 06:50:29.884428	
4901	gaadimech	8740095016	2025-07-15 00:00:00	Did Not Pick Up	Swift ac ch kukas se 10 km dur rhta hu islye  nahi aaya mene apne side kam karwa lia dur jyada tha workshop apka	2025-03-21 04:49:40.935455	9	2025-07-01 06:50:29.884428	
6166	Cx695	9571205742	2025-07-15 00:00:00	Needs Followup	Swift 2999	2025-04-17 05:14:08.842651	9	2025-07-01 06:50:29.884428	
7054	gaadimech 	9024946698	2025-07-15 00:00:00	Did Not Pick Up	Dzire 2999	2025-05-10 05:07:05.689713	9	2025-07-01 06:50:29.884428	
7354	Scorpio 	8003722685	2025-07-15 00:00:00	Did Not Pick Up	Dent Paint \r\nNot required 	2025-05-21 06:53:37.98961	9	2025-07-01 06:50:29.884428	
604	Sunil sharma 	9414400888	2025-07-15 00:00:00	Needs Followup	Ab March me aayegi next sarvice 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
606	Sudhir Gupta	9828013701	2025-07-15 00:00:00	Needs Followup	October me sarvice ho gai h ab next sarvice pr c.b	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
608	Arnav songh	8696909673	2025-07-15 00:00:00	Needs Followup	Abhi need nhi h	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
609	Dr seema 	9828029495	2025-07-15 00:00:00	Needs Followup	April me aayegi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
610	Mayne sharma 	7665954607	2025-07-15 00:00:00	Needs Followup	Skoda rapid h RJ14CP7860 visit kr ke ja chuke R.k pr	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
613	.	9660903606	2025-07-15 00:00:00	Needs Followup	Not interested 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
614	Sandeep ji	9001290136	2025-07-15 00:00:00	Needs Followup	Venu h October me sarvice ho Gai  h next sarvice pr c.b/n\r\nN.r	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
617	Nitin ji 	9024590581	2025-07-15 00:00:00	Needs Followup	Abhi Bahar hu 2 mhine  bad call krna	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
619	Umesh ji	9166181161	2025-07-15 00:00:00	Needs Followup	Abhi udaipur hu	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
623	.	9829441676	2025-07-15 00:00:00	Needs Followup	Not interested 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
625	Hardik sharma	7073571429	2025-07-15 00:00:00	Needs Followup	Dry clean ka charj  1500 diya hua h\r\nNot interested 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
627	.	9414053674	2025-07-15 00:00:00	Needs Followup	Company me service 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
628	Vikram singh 	7877906535	2025-07-15 00:00:00	Needs Followup	Sarvice deu hogi jan me	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
630	Sanjay ji	9414513581	2025-07-15 00:00:00	Needs Followup	Dec ke bad aayegi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
632	Sanjay ji	9414513581	2025-07-15 00:00:00	Needs Followup	Dec ke bad aayegi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
633	.	9982706121	2025-07-15 00:00:00	Needs Followup	Cut a call	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
634	Sanjay ji	9414513581	2025-07-15 00:00:00	Needs Followup	Dec ke bad aayegi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
635	Ritik sharma	9351492711	2025-07-15 00:00:00	Needs Followup	Sarvice March me aayegi	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
636	Manish ji	8619140569	2025-07-15 00:00:00	Needs Followup	December ke last me hogi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
637	Rajendar Gangwal	9355000988	2025-07-15 00:00:00	Needs Followup	January me due hogi	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
638	Manish ji	8619140569	2025-07-15 00:00:00	Needs Followup	December ke last me hogi sarvice	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
639	DIxit ji	9799811068	2025-07-15 00:00:00	Needs Followup	October me sarvice hui h 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
640	Shantnu	7300000303	2025-07-15 00:00:00	Needs Followup	December ke last me deu hogi	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
641	Jugal snoi	9828269129	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared \r\nHonda City 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
642	Nikhil ji	9680166165	2025-07-15 00:00:00	Needs Followup	December ke last me deu hogi	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
643	Raju	9145950940	2025-07-15 00:00:00	Needs Followup	Ap pise jyada le rhe ho	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
644	.	9414076384	2025-07-15 00:00:00	Needs Followup	Cut a call 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
645	Jitendar ji	7877896904	2025-07-15 00:00:00	Needs Followup	Abhi to ho fai h sarvive ab April me aayegi	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
646	.	9828555056	2025-07-15 00:00:00	Needs Followup	Not interested 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
647	Virendar ji	9982016165	2025-07-15 00:00:00	Needs Followup	Abhi m 26 tak Delhi hu 26 ko Jaipur aaunga tb aaunga visit pr	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
648	Ankit soni	9460475862	2025-07-15 00:00:00	Needs Followup	Abhi December ke last me	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
649	.	9414075138	2025-07-15 00:00:00	Needs Followup	Cut a call	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
650	Abhishek 	9549922087	2025-07-15 00:00:00	Needs Followup	January ke last me call jrna abhi mujhe time nhi h	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
651	Abhishek 	9549922087	2025-07-15 00:00:00	Needs Followup	January ke last me call jrna abhi mujhe time nhi h	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
653	Anjum trivedi	7568343879	2025-07-15 00:00:00	Needs Followup	M jb bhi aaunga jan me Banipark hi aaunga	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
654	Rakesh sir 	9414888730	2025-07-15 00:00:00	Needs Followup	Not pick\r\nNot requirement 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
655	Amit	8690345678	2025-07-15 00:00:00	Needs Followup	Madam jb mujhe time hoga tbhi aaunga a abhi  busy hu	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
656	.	9024684788	2025-07-15 00:00:00	Needs Followup	Cut a call 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	\N
657	.	9782266422	2025-07-15 00:00:00	Needs Followup	Cut a call	2024-11-30 11:41:25	9	2025-07-01 06:50:29.884428	\N
664	Prakash sir	8559922444	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared \r\nNot requirement 	2024-11-30 12:05:01	9	2025-07-01 06:50:29.884428	\N
665	.	9829065479	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-11-30 12:05:01	9	2025-07-01 06:50:29.884428	\N
666	.	9521891838	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-11-30 12:05:01	9	2025-07-01 06:50:29.884428	\N
668	.	9351572115	2025-07-15 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
669	.	9414716577	2025-07-15 00:00:00	Needs Followup	Cut a call 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
672	Anukait sir	9983311222	2025-07-15 00:00:00	Needs Followup	Call not pick	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
675	........	9828269395	2025-07-15 00:00:00	Needs Followup	N.r 25 ke bad c.back	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
676	........	9828269395	2025-07-15 00:00:00	Needs Followup	N.r/call back 15 ke bad	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
677	.	9929957110	2025-07-15 00:00:00	Needs Followup	Cut a call	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
679	.	8728937282	2025-07-15 00:00:00	Needs Followup	Cut a call \r\nNot interested \r\nNot interested 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
680	Sunil 	9672322439	2025-07-15 00:00:00	Needs Followup	Abhi Bahar hu 8 ko c.b 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
681	.	9829950511	2025-07-15 00:00:00	Needs Followup	Not interested cut a call 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
683	......	9214560520	2025-07-15 00:00:00	Needs Followup	Gadimech se mujhe need nhi h thanku	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
684	Shanu sir	9672068516	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared \r\nHonda amaze \r\nNot pick\r\nTomorrow 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
685	......	9214560520	2025-07-15 00:00:00	Needs Followup	Gadimech se mujhe need nhi h thanku	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
687	.......	9425332230	2025-07-15 00:00:00	Needs Followup	C.b / 15 ke bad call back	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
688	........	6378087992	2025-07-15 00:00:00	Needs Followup	N.r/ 25 ke bad c.b 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
690	......	9829100677	2025-07-15 00:00:00	Needs Followup	N.i	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
691	.....	9829100677	2025-07-15 00:00:00	Needs Followup	N.r/ n.r 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
693	.........	8739896969	2025-07-15 00:00:00	Needs Followup	Not intrested	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
694	......	7014162795	2025-07-15 00:00:00	Needs Followup	Kal Kat diye	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
697	.	7348624841	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared \r\nNot interested 	2024-12-01 06:01:07	9	2025-07-01 06:50:29.884428	\N
699	........	9610000092	2025-07-15 00:00:00	Needs Followup	Call Kat diye rong number bol kr	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
700	.......	8279202495	2025-07-15 00:00:00	Needs Followup	Call Not pik	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
701	.	7877022726	2025-07-15 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
704	.	9829127947	2025-07-15 00:00:00	Needs Followup	Not interested 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
705	.......	8279202495	2025-07-15 00:00:00	Needs Followup	Call Not pik/19 ke bad cb	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
706	......	9829075760	2025-07-15 00:00:00	Needs Followup	N.r	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
707	.	9829555223	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
708	......	9351311148	2025-07-15 00:00:00	Needs Followup	Switch off/n.r 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
709	.	9784802145	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
710	.	8003869660	2025-07-15 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
712	...	9829018992	2025-07-15 00:00:00	Needs Followup	Mere pass Maruti ki fronk E.V  Car h 	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
714	.	9001395328	2025-07-15 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
716	....	9160965000	2025-07-15 00:00:00	Needs Followup	Call Kat diya	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
718	.....	9829057237	2025-07-15 00:00:00	Needs Followup	Abhi Bahar hu m 6 ko aaunga tab bat krta hu/m thoda busy hu free hoke call back	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	\N
719	.	9828113723	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
722	....	7014915303	2025-07-15 00:00:00	Needs Followup	N.respons	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
723	.	9829162481	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
726	.	9829076830	2025-07-15 00:00:00	Needs Followup	Cut a call\r\nNot interested 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
728	.	9799572680	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
729	.....	9929254903	2025-07-15 00:00:00	Needs Followup	Abhi koi admit h hospital me free hoke call krunga	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
730	.....	9929254903	2025-07-15 00:00:00	Needs Followup	Madam kuchh nhi chahiye	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
731	.....	9829156123	2025-07-15 00:00:00	Needs Followup	Bhle detail dal do pr gadi ka name nhi btaunga	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
732	.......	9829144308	2025-07-15 00:00:00	Needs Followup	Call Kat diya 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
734	.....	9829097635	2025-07-15 00:00:00	Needs Followup	N.r 	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
745	Prkash yadav	9001424129	2025-07-15 00:00:00	Needs Followup	Abhi to meri 1st sarvice hui h under warranty h	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	\N
752	.....	9414079080	2025-07-15 00:00:00	Needs Followup	N.r	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
753	.	9649915551	2025-07-15 00:00:00	Needs Followup	Not interested \r\nCall not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
754	.....	7568877773	2025-07-15 00:00:00	Needs Followup	Not intrested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
764	.	9799996689	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
765	..	9351576244	2025-07-15 00:00:00	Needs Followup	Switch off	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
766	.	9828931596	2025-07-15 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
769	.	7568830333	2025-07-15 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
770	.	9414231373	2025-07-15 00:00:00	Needs Followup	Cut a call & call back 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
773	.	9829108344	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
774	.	8875000058	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
775	.	9929666995	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
777	.	9414074281	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
779	.	9413966964	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
780	.	9636027999	2025-07-16 00:00:00	Needs Followup	Not required 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
514	.	9414870289	2025-07-16 00:00:00	Did Not Pick Up	Cut a call \r\nCall cut	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
539	.	9001199857	2025-07-16 00:00:00	Did Not Pick Up	Only company service\r\nNot requirement 	2024-11-28 12:42:48	9	2025-07-01 06:50:29.884428	
1289	.	9672803643	2025-07-16 00:00:00	Did Not Pick Up	WhatsApp package shared \r\nGrand vitara 3499 jarurat hui to contact krenge	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1450	.....	9460765607	2025-07-16 00:00:00	Did Not Pick Up	Abhi out of Jaipur bu Kal tk hi aa \r\nNe ka Sambhanv hoga\r\nCall cut	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	
2995	Customer	9414207604	2025-07-16 00:00:00	Did Not Pick Up	Not requirement service alredy done	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3895	.	9950711976	2025-07-16 00:00:00	Did Not Pick Up	Don't have car 	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3961	.	6376621223	2025-07-16 00:00:00	Did Not Pick Up	Call cut	2025-02-12 07:07:56.679599	9	2025-07-01 06:50:29.884428	
4047	.	9829055399	2025-07-16 00:00:00	Did Not Pick Up	Call cut	2025-02-15 10:03:28.393576	9	2025-07-01 06:50:29.884428	
4225	.	9079131341	2025-07-16 00:00:00	Did Not Pick Up	Not interested 	2025-02-19 04:57:11.030333	9	2025-07-01 06:50:29.884428	
4273	.	9799110094	2025-07-16 00:00:00	Did Not Pick Up	Swift dent paint 2500 panel charge\r\nbassi se h 40km distasnce hai 	2025-02-22 05:04:14.70874	9	2025-07-01 06:50:29.884428	
4337	gaadimech 	8000949670	2025-07-16 00:00:00	Did Not Pick Up	 Not interested mene koi page par interest show nhi kia\r\nCall cut 	2025-02-24 05:03:44.009089	9	2025-07-01 06:50:29.884428	
4691	.	9829162530	2025-07-16 00:00:00	Did Not Pick Up	Not pick	2025-03-12 11:12:15.341678	9	2025-07-01 06:50:29.884428	
5303	gaadimech 	9649408845	2025-07-16 00:00:00	Did Not Pick Up	Not pick \r\nAlto 2399\r\nOut of jaipur vki	2025-03-30 08:52:34.272142	9	2025-07-01 06:50:29.884428	
5532	gaadimech 	8890203210	2025-07-16 00:00:00	Did Not Pick Up	I10 ac checkup \r\nNot interested 	2025-04-04 04:44:25.67503	9	2025-07-01 06:50:29.884428	
5876	gaadimech 	9694094051	2025-07-16 00:00:00	Did Not Pick Up	Wrv 3699	2025-04-13 06:43:41.780127	9	2025-07-01 06:50:29.884428	
6620	gaadimech 	9351563128	2025-07-16 00:00:00	Did Not Pick Up	Not pick 	2025-04-24 04:21:34.648828	9	2025-07-01 06:50:29.884428	
7252	gaadimech 	8766076220	2025-07-16 00:00:00	Feedback	Ertiga 4889 cash rk motors\r\n\r\nFeedback	2025-05-17 05:02:35.864898	9	2025-07-01 06:50:29.884428	RJ14UH1816
7277	gaadimech	9509415523	2025-07-16 00:00:00	Did Not Pick Up	Punch 3199\r\nCall cut\r\nNot interested 	2025-05-18 04:58:09.274796	9	2025-07-01 06:50:29.884428	
7320	gaadimech	9799097200	2025-07-16 00:00:00	Did Not Pick Up	Washing 350	2025-05-20 05:32:27.202853	9	2025-07-01 06:50:29.884428	
7328	gaadimech 	7877609761	2025-07-16 00:00:00	Did Not Pick Up	Not interested 	2025-05-20 09:11:17.350002	9	2025-07-01 06:50:29.884428	
7356	gaadimech 	7906894584	2025-07-16 00:00:00	Did Not Pick Up	Etios 3399\r\nAbhi plan nhi h	2025-05-21 06:54:28.781488	9	2025-07-01 06:50:29.884428	
7372	gaadimech 	9928800997	2025-07-16 00:00:00	Did Not Pick Up	Busy call u later \r\nNot interested \r\nTuv 300 	2025-05-22 04:47:45.721746	9	2025-07-01 06:50:29.884428	
7406	abhishek 	9694910304	2025-07-16 00:00:00	Feedback	Washing i20 \r\nRk motors 400 online	2025-05-23 05:29:19.729895	9	2025-07-01 06:50:29.884428	
7479	gaadimech	7737953626	2025-07-16 00:00:00	Did Not Pick Up	Not pick honda city\r\nSelf call back	2025-05-25 04:51:17.458271	9	2025-07-01 06:50:29.884428	
7548	gaadimech 	9772327853	2025-07-16 00:00:00	Did Not Pick Up	Busy call u later 	2025-05-28 11:55:03.190978	9	2025-07-01 06:50:29.884428	
7648	gaadimech 	9971445552	2025-07-16 00:00:00	Did Not Pick Up	Amaze 3199 not pick 	2025-05-31 10:59:47.213202	9	2025-07-01 06:50:29.884428	
3696	.	6376440223	2025-07-16 00:00:00	Did Not Pick Up	Alto service done other workshop 	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	\N
195	.	7728026330	2025-07-16 00:00:00	Needs Followup	No car \r\nNot pick	2024-11-24 11:43:13	9	2025-07-01 06:50:29.884428	
249	.	9783033840	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-11-25 08:17:00	9	2025-07-01 06:50:29.884428	
255	Rahul sir 	9829010490	2025-07-16 00:00:00	Needs Followup	What's app details share \r\nNot pick	2024-11-25 08:43:51	9	2025-07-01 06:50:29.884428	
265	Sanjeev 	7976201604	2025-07-16 00:00:00	Needs Followup	Eon RJ14cu8192 sarvice pack 1999 Monday ko Gadi drop kr denge sarvice ke liye	2024-11-25 10:18:53	9	2025-07-01 06:50:29.884428	
317	Jitendra sir	9602155999	2025-07-16 00:00:00	Needs Followup	Eon 1999 service package shared  abhi plan nhi hai  month end tak try karenge\r\nCall cut	2024-11-26 11:13:22	9	2025-07-01 06:50:29.884428	
350	.	9829937771	2025-07-16 00:00:00	Needs Followup	Not pick	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
399	.	9829057087	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
400	.	9829057087	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
402	.	9829015231	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
408	.	9414075539	2025-07-16 00:00:00	Needs Followup	Customer busy 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
414	.	9829028887	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
442	Harshvardhan sir 	9680399984	2025-07-16 00:00:00	Needs Followup	Hexa back tail light charge	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
762	..	7891097333	2025-07-16 00:00:00	Needs Followup	Aj khi Bahar hu ap 5 ko call kr lena	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
781	.....	9001147821	2025-07-16 00:00:00	Needs Followup	N.r 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
782	......	9351515177	2025-07-16 00:00:00	Needs Followup	Breeze h pr under warrunty	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
783	.....	9005050502	2025-07-16 00:00:00	Needs Followup	N.respons	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
784	.	9829052451	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
786	Mandeep singh 	9829117500	2025-07-16 00:00:00	Needs Followup	Mere parts ki shop h apke branch manager ke number dijiye	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
787	.	9829054201	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
788	.	7877333603	2025-07-16 00:00:00	Needs Followup	Call not pick \r\nCut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
789	.......	9828005652	2025-07-16 00:00:00	Needs Followup	Udaipur ke no	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
790	.....	9351202050	2025-07-16 00:00:00	Needs Followup	Hamre yha workshop h	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
791	.....	9351202050	2025-07-16 00:00:00	Needs Followup	Hamre yha workshop h	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
792	Vikaram ji	9660231100	2025-07-16 00:00:00	Needs Followup	Abhi next month me aayegi sarvice dzire h pack bhej diya h	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
793	.	9414187852	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
794	.	9167060908	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
795	.	9828059199	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
796	.	9950444055	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
797	.	9460124731	2025-07-16 00:00:00	Needs Followup	Only company service 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
798	Walid 	7014979519	2025-07-16 00:00:00	Needs Followup	Dzire h 10 din pahle hi sarvice hui h next sarvice apke yha se krwa lenge	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
799	......	9314071092	2025-07-16 00:00:00	Needs Followup	Nhi chahiye madam\r\nNot interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
800	.	9828511073	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
801	.	8949405241	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
802	........	9694008541	2025-07-16 00:00:00	Needs Followup	N response 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
803	.	9829500018	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
804	.........	9799384588	2025-07-16 00:00:00	Needs Followup	Abhi 2 mhine pahle sarvice hui h ap April  me call kr lena	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
805	Sikander 	8239211231	2025-07-16 00:00:00	Needs Followup	10 din pahle sarvice hui h	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
806	.	9001422118	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
807	......	9351719028	2025-07-16 00:00:00	Needs Followup	N.r 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
808	.......	9352383073	2025-07-16 00:00:00	Needs Followup	Call Kat diya sun ke	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
809	.	9829060136	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
810	........	8561868058	2025-07-16 00:00:00	Needs Followup	Abhi need nhi h	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
811	.	9602954396	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
812	.	9587865945	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
813	.	9828517700	2025-07-16 00:00:00	Needs Followup	Cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
814	.	8079086416	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
815	.......	8439561622	2025-07-16 00:00:00	Needs Followup	Switch off	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
816	...	9929957373	2025-07-16 00:00:00	Needs Followup	Madam meri dono gadi under warranty mujhe jrurat hogi to call kr lunga	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
817	.	9214434406	2025-07-16 00:00:00	Needs Followup	Cut a call	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
818	.	9785555559	2025-07-16 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
819	.	9950015114	2025-07-16 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
820	.	9829017354	2025-07-16 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
821	.	9783975609	2025-07-16 00:00:00	Needs Followup	Busy call u letter\r\nNot interested \r\nNot pick	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
822	...	7451011116	2025-07-16 00:00:00	Needs Followup	Fortune's h but mere pass tata ka protect h mujhe  eed nhi h\r\nNot interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
823	.	9352211111	2025-07-16 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
2615	Rohit	9929429938	2025-07-16 00:00:00	Needs Followup	Call cut	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2620	Poonam 	8005904470	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2642	Banne singh	9785206060	2025-07-16 00:00:00	Needs Followup	Baleno 2499\r\nCall cut	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2648	Mahesh	8432697457	2025-07-16 00:00:00	Needs Followup	Celerio dent paint \r\nCompany se 2000 me kam ho jayega  apka price jyada h	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2665	Customer	6350179329	2025-07-16 00:00:00	Needs Followup	Dousa se hai alto 2000  jaipur aana hua to contact krenhe	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2710	Mamta	9928757576	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2711	Ram singh	8237297547	2025-07-16 00:00:00	Needs Followup	Call cut	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2755	Customer	8740997985	2025-07-16 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick 	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2874	Customer	9950339555	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2909	Customer	9414097417	2025-07-16 00:00:00	Needs Followup	Dzire 2899 not required 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2914	Customer	8962420903	2025-07-16 00:00:00	Needs Followup	Call cut\r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2923	Customer	9829011003	2025-07-16 00:00:00	Needs Followup	Not interested \r\nCall cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2942	Customer	9610504968	2025-07-16 00:00:00	Needs Followup	Call back monday\r\nCall cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2945	Customer	7014188801	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2978	Customer	9929500500	2025-07-16 00:00:00	Needs Followup	Not pick 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
2990	Customer	9829547712	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nnot requirement 	2025-01-13 04:34:12.585813	9	2025-07-01 06:50:29.884428	
3008	Customer	9950442551	2025-07-16 00:00:00	Needs Followup	Not pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3012	Customer	9829547796	2025-07-16 00:00:00	Needs Followup	Alto 1999\r\nNot interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3070	Customer	8949640677	2025-07-16 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3123	Customer	8949881383	2025-07-16 00:00:00	Needs Followup	Tomorrow visit workshop\r\nAmeo nd ritz\r\nVisit for banipar after 2 daus	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3139	Customer	9829018465	2025-07-16 00:00:00	Needs Followup	Wagnor  2199\r\nCall cut	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	
3169	Customer	9414238304	2025-07-16 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3176	Customer	9829299956	2025-07-16 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3182	Customer	9571741565	2025-07-16 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3186	Customer	9314623117	2025-07-16 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3206	Customer	9467789997	2025-07-16 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3220	Customer 	9001523904	2025-07-16 00:00:00	Needs Followup	Not connect \r\nNot interested 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3230	Customer 	8619455495	2025-07-16 00:00:00	Needs Followup	Not pick \r\nNot pick 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3246	.	8307809915	2025-07-17 00:00:00	Needs Followup	Not interested 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3258	.	9873133731	2025-07-17 00:00:00	Needs Followup	Not interested \r\nNot pick	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3263	customer 	9799635000	2025-07-17 00:00:00	Needs Followup	Not pick	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3279	.	9828040135	2025-07-17 00:00:00	Needs Followup	Not interested 	2025-01-21 08:47:29.498491	9	2025-07-01 06:50:29.884428	
3282	yogi	9529890550	2025-07-17 00:00:00	Needs Followup	Switch off \r\nNot pick \r\nNot pick 	2025-01-21 08:47:29.498491	9	2025-07-01 06:50:29.884428	
3300	.	7412074127	2025-07-17 00:00:00	Needs Followup	Call cut	2025-01-21 10:55:25.845211	9	2025-07-01 06:50:29.884428	
3350	Customer 	9145955594	2025-07-17 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3357	customer 	9529979558	2025-07-17 00:00:00	Needs Followup	I 20 2699 call back sunday\r\nOut of jaipur call back after 3 to 4 days	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3375	Customer 	8290365653	2025-07-17 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3392	.	9001980000	2025-07-17 00:00:00	Needs Followup	Not pick 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3422	.	9958929279	2025-07-17 00:00:00	Needs Followup	Notpick	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3425	.	9680138795	2025-07-17 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3429	.	9866555556	2025-07-17 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3476	.	9887176465	2025-07-17 00:00:00	Needs Followup	Swift full dent paint 25000 \r\n15000 me gaadi dent paint ho rhi hai	2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	
4346	gaadimech	8233311775	2025-07-17 00:00:00	Needs Followup	jaguar service not pick 	2025-02-24 11:50:04.421277	9	2025-07-01 06:50:29.884428	
4430	hitesh Choudhary 9351825806	7073789967	2025-07-17 00:00:00	Needs Followup	Ertiga 2500 panel charge	2025-02-28 05:57:11.678588	9	2025-07-01 06:50:29.884428	
4871	gaadimech	9636311600	2025-07-17 00:00:00	Needs Followup	Creta 2500 panel	2025-03-20 04:46:04.37458	9	2025-07-01 06:50:29.884428	
375	Naveen soni	9828295556	2025-07-17 00:00:00	Did Not Pick Up	Not interested 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
513	.	9414870289	2025-07-17 00:00:00	Did Not Pick Up	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
537	Ashish sir 	9587703777	2025-07-17 00:00:00	Did Not Pick Up	No response\r\nNot pick	2024-11-28 12:42:48	9	2025-07-01 06:50:29.884428	
560	.....	9314525589	2025-07-17 00:00:00	Did Not Pick Up	2 gadi h but abhi need nhi h\r\nNot required 	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
772	.	9810061727	2025-07-17 00:00:00	Did Not Pick Up	Cut a call \r\nCall not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
1297	.	9928484878	2025-07-17 00:00:00	Did Not Pick Up	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1455	Sandeep sir	9928024391	2025-07-17 00:00:00	Did Not Pick Up	WhatsApp package shared \r\nNot pick	2024-12-08 08:15:33	9	2025-07-01 06:50:29.884428	
1478	.	7627059417	2025-07-17 00:00:00	Did Not Pick Up	Call not pick 	2024-12-08 09:50:19	9	2025-07-01 06:50:29.884428	
1480	.	9001274887	2025-07-17 00:00:00	Did Not Pick Up	Call not pick \r\nNot pick\r\nNot interested 	2024-12-08 09:50:19	9	2025-07-01 06:50:29.884428	
1488	.	9650767950	2025-07-17 00:00:00	Did Not Pick Up	Call not pick \r\nCall cut	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	
1615	Pawan Hatwal	9694011348	2025-07-17 00:00:00	Needs Followup	Ergita Car, he need full body dent paint with color change. \r\n40k to 50k estimate shared. cus near from chomu.\r\nchanging part estimate extra\r\nCall cut	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	
1793	.	9636042417	2025-07-17 00:00:00	Did Not Pick Up	Not interested & cut a call 	2024-12-14 04:46:30	9	2025-07-01 06:50:29.884428	
1807	.	9828722088	2025-07-17 00:00:00	Did Not Pick Up	Not requirement 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	
1812	.	8875001696	2025-07-17 00:00:00	Did Not Pick Up	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	
2669	Customer	7300448353	2025-07-17 00:00:00	Did Not Pick Up	Not pick 	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2678	Customer	9828330261	2025-07-17 00:00:00	Did Not Pick Up	Not pick\r\nNot pick\r\nServi done	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	
2848	Customer	8890016786	2025-07-17 00:00:00	Needs Followup	Busy call u letter \r\nNot pick\r\nBaleno service dine	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2852	Customer	9928722111	2025-07-17 00:00:00	Did Not Pick Up	Call cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2922	Customer	7015401161	2025-07-17 00:00:00	Did Not Pick Up	Service done	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
3009	Customer	7014727504	2025-07-17 00:00:00	Feedback	Service done\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3064	Customer	9413346024	2025-07-17 00:00:00	Did Not Pick Up	Ignis sharp motore dent paint \r\nSelf call karenge	2025-01-16 04:14:34.232859	9	2025-07-01 06:50:29.884428	
3148	Customer	8955555125	2025-07-17 00:00:00	Did Not Pick Up	Not pick\r\nCall cut	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	
3197	Customer	8769408442	2025-07-17 00:00:00	Did Not Pick Up	Not requirement 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3457	.	9972309185	2025-07-17 00:00:00	Did Not Pick Up	Not pick \r\nCall cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3620	.	9414207934	2025-07-17 00:00:00	Did Not Pick Up	Call cut	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3636	.	9829056753	2025-07-17 00:00:00	Did Not Pick Up	Not interested 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3674	.	9460071517	2025-07-17 00:00:00	Did Not Pick Up	Not pick 	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3744	.	7412005678	2025-07-17 00:00:00	Did Not Pick Up	Call cut	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3878	.	9782848284	2025-07-17 00:00:00	Did Not Pick Up	\r\nNot requirment 	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
3884	.	9910343294	2025-07-17 00:00:00	Did Not Pick Up	Not required \r\nCall cut	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
4058	.	8889299980	2025-07-17 00:00:00	Did Not Pick Up	Taigun dent paint \r\nCall cut	2025-02-15 10:32:33.139331	9	2025-07-01 06:50:29.884428	
4106	.	8745057347	2025-07-17 00:00:00	Did Not Pick Up	Not pick 	2025-02-16 10:26:24.994248	9	2025-07-01 06:50:29.884428	
4197	Nikhil	9828803668	2025-07-17 00:00:00	Feedback	Ciaz dent paint \r\nTotal payment 9060.\r\nFeedback on 24 feb\r\nDay 1 dent miner sa rah gya h baki kam sahi hai   \r\n	2025-02-18 11:37:46.862739	9	2025-07-01 06:50:29.884428	RJ14WC7485
4299	.	9812196781	2025-07-17 00:00:00	Did Not Pick Up	Switch off 	2025-02-22 11:28:50.656658	9	2025-07-01 06:50:29.884428	
4614	gaadimech 	8303463863	2025-07-17 00:00:00	Needs Followup	Mene koi inquiry nhi ki 	2025-03-09 04:46:02.025916	9	2025-07-01 06:50:29.884428	
4703	gaadimech	7891170501	2025-07-17 00:00:00	Did Not Pick Up	Busy call u later \r\nBy mistake click ho gya hoga koi inquiry nhi ki	2025-03-12 12:35:34.172677	9	2025-07-01 06:50:29.884428	
4729	.	9509173031	2025-07-17 00:00:00	Did Not Pick Up	Not pick\r\nCall cut	2025-03-13 11:10:38.662236	9	2025-07-01 06:50:29.884428	
5194	ajay ji	7300004548	2025-07-17 00:00:00	Feedback	Verito 2999\r\nTOTAL PAYMENT - 3000\r\nFeedback \r\n31/03/2025 kch issues h visit krenge \r\n9/04/2025 not pick 	2025-03-28 07:51:35.276443	9	2025-07-01 06:50:29.884428	RJ14CQ6314
5199	gaadimech 	9887263565	2025-07-17 00:00:00	Did Not Pick Up	Nexon 3699rk\r\nNot interested 	2025-03-28 08:05:19.374351	9	2025-07-01 06:50:29.884428	
5364	gaadimech 	9680307741	2025-07-17 00:00:00	Did Not Pick Up	Vitara Brezza 3399\r\nNot interested 	2025-03-31 08:12:02.487433	9	2025-07-01 06:50:29.884428	
5370	gaadimech	9887175471	2025-07-17 00:00:00	Did Not Pick Up	Dzire 2999	2025-03-31 12:35:58.496579	9	2025-07-01 06:50:29.884428	
5451	gaadimech 	8740080436	2025-07-17 00:00:00	Feedback	Honda elevate tail light  \r\nSharp motors 4000 cash 	2025-04-02 05:37:34.080738	9	2025-07-01 06:50:29.884428	
5570	gaadimech 	9799651073	2025-07-17 00:00:00	Did Not Pick Up	Not pick 	2025-04-07 08:32:19.939469	9	2025-07-01 06:50:29.884428	
5574	gaadimech	9351160100	2025-07-17 00:00:00	Did Not Pick Up	Swift 2799\r\nCall cut	2025-04-07 08:58:39.004238	9	2025-07-01 06:50:29.884428	
5903	gaadimech 	9982795375	2025-07-17 00:00:00	Did Not Pick Up	Swift 2799\r\nCall cut	2025-04-14 06:01:27.820892	9	2025-07-01 06:50:29.884428	
6645	gaadimech 	9462323170	2025-07-17 00:00:00	Did Not Pick Up	Not pick 	2025-04-25 09:38:24.984841	9	2025-07-01 06:50:29.884428	
6667	gaadimech 	9829369201	2025-07-17 00:00:00	Did Not Pick Up	Not interested 	2025-04-25 10:36:06.474231	9	2025-07-01 06:50:29.884428	
6725	customer 	8955555020	2025-07-17 00:00:00	Did Not Pick Up	Call cit	2025-04-26 10:27:32.812083	9	2025-07-01 06:50:29.884428	
6792	gaadimech 	9829066084	2025-07-17 00:00:00	Did Not Pick Up	Jaguar dent paint 3799\r\nNot pick 	2025-04-29 10:00:00.382965	9	2025-07-01 06:50:29.884428	
6984	gaadimech 	9783333790	2025-07-17 00:00:00	Did Not Pick Up	Nexon 3899\r\nNot pick	2025-05-08 05:00:55.398841	9	2025-07-01 06:50:29.884428	
7093	gaadimech 	8239988977	2025-07-17 00:00:00	Did Not Pick Up	Wognor 1800 panel charge	2025-05-11 05:51:49.201714	9	2025-07-01 06:50:29.884428	
7323	gaadimech	7851058909	2025-07-17 00:00:00	Did Not Pick Up	Alto 2399\r\nDrycleaning 1500\r\nCall cut	2025-05-20 06:09:54.27242	9	2025-07-01 06:50:29.884428	
7336	gaadimech	7011589513	2025-07-17 00:00:00	Did Not Pick Up	Magnite 3999\r\nService done 	2025-05-21 04:40:16.289429	9	2025-07-01 06:50:29.884428	
7337	gaadimech 	7790900264	2025-07-17 00:00:00	Did Not Pick Up	Dzire 2999\r\nCall cut	2025-05-21 04:43:41.834555	9	2025-07-01 06:50:29.884428	
7380	gaadimech 	9873700603	2025-07-17 00:00:00	Did Not Pick Up	Creta 4199 call cut	2025-05-22 05:23:12.301708	9	2025-07-01 06:50:29.884428	
7407	gaadimech 	8005830772	2025-07-17 00:00:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-05-23 05:29:46.688707	9	2025-07-01 06:50:29.884428	
7437	gaadimech 	8875527555	2025-07-17 00:00:00	Did Not Pick Up	Amaze 3199\r\n	2025-05-24 04:58:33.172772	9	2025-07-01 06:50:29.884428	
7554	gaadimech 	8529466546	2025-07-17 00:00:00	Did Not Pick Up	Not interested 	2025-05-28 12:10:04.27709	9	2025-07-01 06:50:29.884428	
7578	gaadimech	9602452320	2025-07-17 00:00:00	Did Not Pick Up	Dzire 2999 self call\r\nCompressor repairing 	2025-05-29 10:21:54.530688	9	2025-07-01 06:50:29.884428	
7584	gaadimech 	7737374243	2025-07-17 00:00:00	Needs Followup	Verna 3399 not interested 	2025-05-29 11:23:48.218975	9	2025-07-01 06:50:29.884428	
7598	gaadimech	8005668660	2025-07-17 00:00:00	Did Not Pick Up	Call back after 2 Not pick \r\nNot interested call cut\r\n	2025-05-30 05:00:02.158842	9	2025-07-01 06:50:29.884428	
197	.	9887792506	2025-07-17 00:00:00	Needs Followup	Number out of service 	2024-11-24 11:46:34	9	2025-07-01 06:50:29.884428	
824	......	9828021394	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
825	....	9928953967	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
826	.	8826621877	2025-07-17 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
827	.	9816232135	2025-07-17 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
828	....	9887038961	2025-07-17 00:00:00	Needs Followup	Nhi kuchh nhi chahiye 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
830	.	7073036073	2025-07-17 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
831	.	9829068443	2025-07-17 00:00:00	Needs Followup	Not interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
832	....	9829908800	2025-07-17 00:00:00	Needs Followup	Ap free me q de rhe ho mujhe nhi chahiye	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
833	......	9828021394	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
834	......	9828021394	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
835	.	9829055754	2025-07-17 00:00:00	Needs Followup	Call cut	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
836	.....	9887926952	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
837	.	9414076264	2025-07-17 00:00:00	Needs Followup	Call back 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
838	.....	9887926952	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
839	.....	9887926952	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
840	......	9887910242	2025-07-17 00:00:00	Needs Followup	N r	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
842	.	8696755169	2025-07-17 00:00:00	Needs Followup	Cut a call	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
844	.	9829460609	2025-07-17 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
845	.	9929384667	2025-07-17 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
846	.	9820924155	2025-07-17 00:00:00	Needs Followup	Call not pick 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	\N
855	.......	7568517545	2025-07-17 00:00:00	Needs Followup	M Maruti ke alwa khi sarvice nhi krwata\r\nNot interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
856	Krishna 	9983993336	2025-07-17 00:00:00	Needs Followup	Abhi pichhle mhine hui h sarvice abhi June se pahle nhi	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
857	......	9887501594	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
858	.....	9530274412	2025-07-17 00:00:00	Needs Followup	Ap dila do car	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
859	.....	9660623389	2025-07-17 00:00:00	Needs Followup	Call Kat diya	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
860	......	9667586176	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
861	Amrish	9982730434	2025-07-17 00:00:00	Needs Followup	Need nhi h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
862	Pratuesh sharma	7014459488	2025-07-17 00:00:00	Needs Followup	Next month dekhenge	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
863	Vedprkash  sharma	9828981841	2025-07-17 00:00:00	Needs Followup	Abhi 2000 k.m or chlegi uske bad krayenge alto h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
864	.........	8619076195	2025-07-17 00:00:00	Needs Followup	Nhi abhi jrurat nhi h sarvice ki	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
865	.......	9660829212	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
866	.	9782207581	2025-07-17 00:00:00	Needs Followup	Not interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
867	Mukesh ji	8005872625	2025-07-17 00:00:00	Needs Followup	Abhi pichhle mhine hi sarvice hui h March tk call kr lena	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
869	.	9414019548	2025-07-17 00:00:00	Needs Followup	Call not pick 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
870	........	9799088882	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
871	.......	9729908888	2025-07-17 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
877	......	9660100838	2025-07-17 00:00:00	Needs Followup	Busy	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
878	........	9785684816	2025-07-18 00:00:00	Needs Followup	N.r 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
879	.	9414179332	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nBusy call u later \r\nCall cut	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
880	.	9829827274	2025-07-18 00:00:00	Needs Followup	Not interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	
881	.	9829203437	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
882	.	8107477186	2025-07-18 00:00:00	Needs Followup	Call back 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
885	.....	9829064274	2025-07-18 00:00:00	Needs Followup	Busy 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
887	......	9851450621	2025-07-18 00:00:00	Needs Followup	Under warranty 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
888	......	9829263151	2025-07-18 00:00:00	Needs Followup	Ji abhi need nhi h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
890	.......	9829213541	2025-07-18 00:00:00	Needs Followup	4 mhine bad abhi hui h sarvice	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
891	.....	9829076867	2025-07-18 00:00:00	Needs Followup	Network isu	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
892	.	9660547872	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nService done	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
894	.	9834474529	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
897	.	9414044131	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
900	.	8209067878	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
906	Yogesh chudhray	9509075588	2025-07-18 00:00:00	Needs Followup	Kia ki sonet h ppf ke bare me Janna chah rhe the mine chetan sir ko refer kr di	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
907	.	9414783460	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
909	.......	7975535909	2025-07-18 00:00:00	Needs Followup	Call utha kr Kat diya	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
911	.	8003293599	2025-07-18 00:00:00	Needs Followup	Switch off 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
912	....	9829289080	2025-07-18 00:00:00	Needs Followup	Jan ke last me c.b 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
913	.	9828086586	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
915	.	9314966864	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
916	......	9928798090	2025-07-18 00:00:00	Needs Followup	Need nhi h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
917	.	9829328165	2025-07-18 00:00:00	Needs Followup	Cut a call & not interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
918	.....	9829191671	2025-07-18 00:00:00	Needs Followup	Busy	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
919	.	9694662999	2025-07-18 00:00:00	Needs Followup	Switch off 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
920	.....	9829643310	2025-07-18 00:00:00	Needs Followup	Bussy	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
921	.	9950019888	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
922	....	9929336200	2025-07-18 00:00:00	Needs Followup	Mine car bech di	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
925	Piyush jain 	7023310005	2025-07-18 00:00:00	Needs Followup	Need nhi h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
926	.......	9829066441	2025-07-18 00:00:00	Needs Followup	Abhi need nhi h	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
927	.....	8000866390	2025-07-18 00:00:00	Needs Followup	N.r	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
928	.	9711225055	2025-07-18 00:00:00	Needs Followup	Not interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
929	.	8860066149	2025-07-18 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-03 05:16:04	9	2025-07-01 06:50:29.884428	\N
932	.	9928333888	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
934	.	7737383976	2025-07-18 00:00:00	Needs Followup	Switch off 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
935	.	9414630955	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
936	....	9829757555	2025-07-18 00:00:00	Needs Followup	Call Kat diya	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
937	.	9928175300	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
938	......	9001985327	2025-07-18 00:00:00	Needs Followup	Abhi busy hu madam free hone ke bad m khud call kr lunga	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
939	.....	9929298501	2025-07-18 00:00:00	Needs Followup	N.r 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
940	.	9828100330	2025-07-18 00:00:00	Needs Followup	Not interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
941	...	9829483799	2025-07-18 00:00:00	Needs Followup	Busy	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
942	.	9829069664	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
943	....	9829082203	2025-07-18 00:00:00	Needs Followup	Busy	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
945	.	8220046755	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
946	.....	9624454668	2025-07-18 00:00:00	Needs Followup	Call Kat diye sun kr	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
947	.	9530409900	2025-07-18 00:00:00	Needs Followup	Not interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
948	.	9829053532	2025-07-18 00:00:00	Needs Followup	Call back \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
950	......	9828288209	2025-07-18 00:00:00	Needs Followup	Madam hmari sari gadiya campney me jati h call Kat do	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
952	.	9414073341	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
953	.....	8094215933	2025-07-18 00:00:00	Needs Followup	Call sun kr Kat diya	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
955	.	9314500350	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
956	Surendar ji 	6375439598	2025-07-18 00:00:00	Needs Followup	Abhi travele hu 13 ko call back	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
957	.	9828085299	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pik	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
959	....	9829108385	2025-07-18 00:00:00	Needs Followup	Call recorded forwerd	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
960	.	9351507655	2025-07-18 00:00:00	Needs Followup	Not intrested	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
961	.	8094460701	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
962	....	9829108385	2025-07-18 00:00:00	Needs Followup	Mujhe jb jrurat hogi m apko call kr lunga or usi waqt apko btaunga ki k9n si gadi h meri	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
964	.......	9079845463	2025-07-18 00:00:00	Needs Followup	Mere pass to loding\r\n switch off	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
965	.	9950387777	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
2696	Vishwa bhushan ji	9001896001	2025-07-18 00:00:00	Needs Followup	Not pick\r\nCall cut	2025-01-08 04:05:57.844174	9	2025-07-01 06:50:29.884428	\N
236	.	9939475121	2025-07-18 00:00:00	Needs Followup	Call not pick \r\n	2024-11-25 07:36:18	9	2025-07-01 06:50:29.884428	
259	.	9829314745	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-11-25 09:03:15	9	2025-07-01 06:50:29.884428	
261	Lokesh ji	9982945242	2025-07-18 00:00:00	Needs Followup	Alto RJ20CB0322 Ye aj Tonk Road jayenge visit pr dent pent h visit krenge  mine group me dal di h.\r\nFriday ko visit krenge\r\n\r\ncus not picked our calls	2024-11-25 09:29:52	9	2025-07-01 06:50:29.884428	
279	Bk Trivedi	9828021065	2025-07-18 00:00:00	Needs Followup	Dzire 2699Ac ges issue	2024-11-25 12:06:01	9	2025-07-01 06:50:29.884428	
305	.	9828455592	2025-07-18 00:00:00	Needs Followup	Call back \r\nVenue washing \r\nNot pick 	2024-11-26 10:15:16	9	2025-07-01 06:50:29.884428	
327	Jitender varma	9829576691	2025-07-18 00:00:00	Needs Followup	Aj meeting me busy hu Kal aaunga Ameo Gadi h ye 28 September ko Tonk Road pr visit bhi kr ke aaye the wga ke staff se satisfied nhi h Kal aayenge R.k pr\r\n\r\nNot pick	2024-11-26 11:28:49	9	2025-07-01 06:50:29.884428	
331	Prakhar sharma	9351321223	2025-07-18 00:00:00	Needs Followup	Mine abhi despad ka Kam nhi krwaya h m busy tha ap mujhe 30 ko call kr lena m aa jaunga pahle Estimate pta krunga fir Kam krwaunga\r\nDent paint 2500 per penal charge amount jyada hai	2024-11-26 11:39:56	9	2025-07-01 06:50:29.884428	
332	Manish sir 	8619266049	2025-07-18 00:00:00	Needs Followup	Swift service package 2699 shared 	2024-11-26 12:17:27	9	2025-07-01 06:50:29.884428	
333	Gunjan Ramawat Victor vissen	9001094449	2025-07-18 00:00:00	Needs Followup	Inki polo ki gadi h wolks wegain murlioura rahte h banipark ki location di hui h September se follup pr h inko Engine Oil oil Filter break oil A.c filter fenbelt 3 sparker chenj krane h ap iska Estimate do	2024-11-26 12:24:33	9	2025-07-01 06:50:29.884428	
357	.	9414073760	2025-07-18 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
364	.	9680433652	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
366	.	9258068160	2025-07-18 00:00:00	Needs Followup	Call not pick.\r\nCut a call 	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
376	.	9413337696	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nB\r\nNot pick	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
380	Aman ji 	8386832054	2025-07-18 00:00:00	Needs Followup	Abhi sarvice ho gai h next time c.b\r\nNot pick	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
385	.	9887300034	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
388	.	9314509730	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
390	Rohit	8769456797	2025-07-18 00:00:00	Needs Followup	August me sarvice ho gai h ab next time c.b	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
398	.	9829057087	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
433	Bhavik sir	8696711112	2025-07-18 00:00:00	Needs Followup	What's app details shared 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
652	Nrendra saxena	9785403000	2025-07-18 00:00:00	Needs Followup	Feb ke last me aayegi sarvice \r\n	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	
966	.	9649481000	2025-07-18 00:00:00	Needs Followup	Cut a call 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
967	.	9829434335	2025-07-18 00:00:00	Needs Followup	WhatsApp package shared \r\nNot interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
968	.	9460061819	2025-07-18 00:00:00	Needs Followup	Only company me service \r\nNot pick\r\nFree service due \r\n	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
969	.	9829061181	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nSwitch off\r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
970	.	9829343731	2025-07-18 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
971	.	9351315358	2025-07-18 00:00:00	Needs Followup	Don't have car	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
972	...   	9829054727	2025-07-18 00:00:00	Needs Followup	Busy	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
973	.	9413352986	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
975	.....	9829053092	2025-07-18 00:00:00	Needs Followup	Call sun kr Kat di\r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
976	...	9784050000	2025-07-18 00:00:00	Needs Followup	Busy	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
977	.	9829010782	2025-07-18 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
979	.	9414890094	2025-07-18 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
980	.....	9414045055	2025-07-18 00:00:00	Needs Followup	Muhhe jrurat nhi h 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
2627	Anuj	9414043964	2025-07-18 00:00:00	Needs Followup	Not interested \r\nNot pick 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2650	Charan singh	7222853878	2025-07-18 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick\r\nNot pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2653	Mayank	9829500464	2025-07-18 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2724	Customer	8209863684	2025-07-18 00:00:00	Needs Followup	Switch off \r\nDon't have car	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2760	Customer	9892785007	2025-07-18 00:00:00	Needs Followup	Call cut	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2791	Customer	9950662611	2025-07-18 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2025-01-09 12:05:45.647682	9	2025-07-01 06:50:29.884428	
2834	Customer	7425017549	2025-07-18 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
2858	Customer	7702925798	2025-07-18 00:00:00	Needs Followup	Not pick \r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2861	Customer	8005859886	2025-07-18 00:00:00	Needs Followup	Not connect \r\nNot pick\r\nNot pick 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2896	Customer	9929047869	2025-07-18 00:00:00	Needs Followup	Switch off \r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2908	Customer	9414097417	2025-07-18 00:00:00	Needs Followup	Dzire service done already	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2928	Customer	7742686966	2025-07-18 00:00:00	Needs Followup	Call cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2991	Customer	8302427969	2025-07-18 00:00:00	Needs Followup	Not requirement 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3005	Customer	9829496013	2025-07-18 00:00:00	Needs Followup	Call cut	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3011	Customer	9829019040	2025-07-18 00:00:00	Needs Followup	Call cut\r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3027	Customer	9829254466	2025-07-18 00:00:00	Needs Followup	Not interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3028	Customer	9540225000	2025-07-18 00:00:00	Needs Followup	Call back\r\nNot interested 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3034	Customer	8003437681	2025-07-18 00:00:00	Needs Followup	Swift rubbing polish\r\nNot pick\r\nNot pick\r\nNot pick \r\nNot pick	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3047	Customer	9929166717	2025-07-18 00:00:00	Needs Followup	Call cut	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3072	Customer	9928247777	2025-07-18 00:00:00	Needs Followup	Not pick\r\nNot pick	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3073	Customer	7665184490	2025-07-18 00:00:00	Needs Followup	Audi A4 service	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3075	Customer	9001941331	2025-07-19 00:00:00	Needs Followup	I10 1999 package share\r\nPpf 	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3137	Customer	9950227446	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-19 09:01:07.792367	9	2025-07-01 06:50:29.884428	
3151	Customer	9829050622	2025-07-19 00:00:00	Needs Followup	Not pick	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3155	Customer	9829082203	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3156	Customer	9829791219	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3157	Customer	9414441032	2025-07-19 00:00:00	Needs Followup	Not pick \r\nNot pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3166	Customer	9829733757	2025-07-19 00:00:00	Needs Followup	Honda city 2899	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3168	Customer	9928469066	2025-07-19 00:00:00	Needs Followup	Cresta 5999	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3174	Customer	9816433220	2025-07-19 00:00:00	Needs Followup	Not requirement 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3177	Customer	9636655777	2025-07-19 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3191	Customer	9928870370	2025-07-19 00:00:00	Needs Followup	Not interested \r\nCall cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3199	Customer	9828046970	2025-07-19 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3203	Customer	9724993746	2025-07-19 00:00:00	Needs Followup	Celerio next week 2399 package	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3215	Customer	9574003171	2025-07-19 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3235	customer 	9929098379	2025-07-19 00:00:00	Needs Followup	Not requirement \r\nOut of jaipur 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3242	customer 	9950116999	2025-07-19 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3249	.	9821958114	2025-07-19 00:00:00	Needs Followup	Not pick\r\nNot pick 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3260	customer 	9814992080	2025-07-19 00:00:00	Needs Followup	Not interested 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3265	customer 	9672675757	2025-07-19 00:00:00	Needs Followup	Not requirement mjhe koi jarurt nhi hai 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3275	ashok 	9828768886	2025-07-19 00:00:00	Needs Followup	I10 silencer problem \r\nNot pick 	2025-01-21 08:47:29.498491	9	2025-07-01 06:50:29.884428	
3278	.	9821580510	2025-07-19 00:00:00	Needs Followup	Not interested 	2025-01-21 08:47:29.498491	9	2025-07-01 06:50:29.884428	
3315	Customer 	9921266418	2025-07-19 00:00:00	Needs Followup	Not connect \r\nNot pick 	2025-01-22 05:25:41.038653	9	2025-07-01 06:50:29.884428	
3323	Customer 	8826890650	2025-07-19 00:00:00	Needs Followup	Nexon 3199 service package\r\nSelf visit krenge\r\nService done by other workshop 	2025-01-23 04:13:07.245769	9	2025-07-01 06:50:29.884428	
3353	customer 	8764241611	2025-07-19 00:00:00	Needs Followup	Not pick \r\nEon 1999 next week	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3374	Customer 	8302543446	2025-07-19 00:00:00	Needs Followup	Not connect \r\nNot pick	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3376	Customer 	8233147783	2025-07-19 00:00:00	Needs Followup	Scorpio dant paint \r\nNot requirement till time	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3384	.	8003333364	2025-07-19 00:00:00	Needs Followup	Not pick \r\nNot pick	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3386	.	9024699276	2025-07-19 00:00:00	Needs Followup	Dzire 2699 not requirement 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3387	dalraj	9929136462	2025-07-19 00:00:00	Needs Followup	Call cut not interested 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3431	.	7014642772	2025-07-19 00:00:00	Needs Followup		2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3433	.	7221911446	2025-07-19 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3435	.	8003070032	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3436	.	9829735935	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3444	.	8238017135	2025-07-19 00:00:00	Needs Followup	Not requirement 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3447	.	9829843013	2025-07-19 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3485	.	9462691501	2025-07-19 00:00:00	Needs Followup	Switch off 	2025-01-28 04:24:52.747688	9	2025-07-01 06:50:29.884428	
3489	.	9414057273	2025-07-19 00:00:00	Needs Followup	Honda city 2899	2025-01-28 04:58:56.197876	9	2025-07-01 06:50:29.884428	
3502	.	9649995773	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-28 06:07:51.486916	9	2025-07-01 06:50:29.884428	
3516	.	9982010820	2025-07-19 00:00:00	Needs Followup	Not requirement 	2025-01-29 08:32:50.939274	9	2025-07-01 06:50:29.884428	
3521	.	8003964315	2025-07-19 00:00:00	Needs Followup	Alto	2025-01-29 08:32:50.939274	9	2025-07-01 06:50:29.884428	
3542	.	9587000032	2025-07-19 00:00:00	Needs Followup	Not pick 	2025-01-31 04:20:51.980955	9	2025-07-01 06:50:29.884428	
3582	.	9982699999	2025-07-19 00:00:00	Needs Followup	Call cut	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3655	.	9829144426	2025-07-19 00:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
4055	.	9352531719	2025-07-19 00:00:00	Needs Followup	Audi A6 service nd suspension work \r\n2000 km due h	2025-02-15 10:17:53.114599	9	2025-07-01 06:50:29.884428	
4425	mahendra singh gaadimech 	9783912110	2025-07-19 00:00:00	Needs Followup	Beat  oil leackage issue\r\nCustomer visit kiye the engine work charge jyada h islye mana kr dia 	2025-02-27 08:39:22.56692	9	2025-07-01 06:50:29.884428	
4880	gaadimech	9950066469	2025-07-19 00:00:00	Needs Followup	Vento wiper blade nd power window check	2025-03-20 08:46:50.850769	9	2025-07-01 06:50:29.884428	
7165	gaadimech	9829050190	2025-07-19 00:00:00	Needs Followup	XUV 5OO 5199 tonk road	2025-05-14 05:45:46.964156	9	2025-07-01 06:50:29.884428	
7622	gaadimech	8279274201	2025-07-19 00:00:00	Needs Followup	Alto K10 2399 \r\n1000 km due \r\n	2025-05-30 12:37:41.84875	9	2025-07-01 06:50:29.884428	
7639	gaadimech 	9887767310	2025-07-19 00:00:00	Needs Followup	Exter 2999	2025-05-31 08:11:14.201196	9	2025-07-01 06:50:29.884428	
981	...	9829008048	2025-07-19 00:00:00	Needs Followup	Call sun ke Kat diya \r\nTomorrow call back	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
983	.	9829038006	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
984	.	9850979780	2025-07-19 00:00:00	Needs Followup	Switch off 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
987	......	9983473636	2025-07-19 00:00:00	Needs Followup	No thanku madam kuchh nhi chahiye	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
988	......	8005650377	2025-07-19 00:00:00	Needs Followup	Abhi shadi me hu 20 ko free ho jaunga tab bat krta hu	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
989	.	9982222847	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
990	.	8952843795	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
991	......	9829000017	2025-07-19 00:00:00	Needs Followup	Abhi busy hu	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
992	.	9829130105	2025-07-19 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
996	.....	9413323929	2025-07-19 00:00:00	Needs Followup	Mujhe gadi ka name pta nhi h or sister Bahar gai h\r\nMujhe gadi ka name pta nhi h or sister Bahar gai h\r\n	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
998	.....	9001391399	2025-07-19 00:00:00	Needs Followup	N.r. call back	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1000	......	9829057389	2025-07-19 00:00:00	Needs Followup	Call forwerdef\r\nSwitch off 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1001	.	9314390002	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1002	.	9649902102	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1004	.	8764241388	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1005	...	9829005631	2025-07-19 00:00:00	Needs Followup	N.r	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1006	...	9829005631	2025-07-19 00:00:00	Needs Followup	N.r	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1007	.	8764241388	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1008	.	9828122520	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1009	.	9251990649	2025-07-19 00:00:00	Needs Followup	Call back \r\nNot pick	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1010	.	9928912113	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1012	.	9829214542	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1013	.	8107716596	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1014	.	9414337070	2025-07-19 00:00:00	Needs Followup	Cut a call 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1015	.	9828150000	2025-07-19 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-03 08:19:22	9	2025-07-01 06:50:29.884428	\N
1016	.	9829203600	2025-07-19 00:00:00	Needs Followup	Call cut	2024-12-03 12:22:39	9	2025-07-01 06:50:29.884428	\N
1018	.	9251422222	2025-07-19 00:00:00	Needs Followup	Only company me service \r\nNot interested 	2024-12-03 12:22:39	9	2025-07-01 06:50:29.884428	\N
1019	.	9799173300	2025-07-19 00:00:00	Needs Followup	Cut a call 	2024-12-03 12:59:43	9	2025-07-01 06:50:29.884428	\N
1022	Ashish sir 	9251324244	2025-07-19 00:00:00	Needs Followup	WhatsApp package shared \r\n13 Dec. ko call back \r\nBrezza 3299\r\nFab end	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1023	.	9783078172	2025-07-19 00:00:00	Needs Followup	Call back \r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1024	.	9414245970	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1025	.	8302033020	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1026	.	9309288800	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1028	.	9602956909	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1029	.	9829051459	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1032	.	9829067752	2025-07-19 00:00:00	Needs Followup	Not interested \r\n	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1033	.	9983934650	2025-07-19 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1034	Dhiraj sir	9828153281	2025-07-19 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick\r\nNot pick\r\nTomorrow call 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1035	.	9799298375	2025-07-19 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1036	.	9828168554	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1037	.	9414070937	2025-07-19 00:00:00	Needs Followup	Switch off 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1039	.	9024333337	2025-07-19 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick\r\nNot call pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1041	.	8107130951	2025-07-19 00:00:00	Needs Followup	Amaze 2899\r\nBaleno 2599\r\nService packege \r\nservice done by other workshop but next time will contact 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1045	Manish sir 	8875666602	2025-07-19 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1047	.	9828804532	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1048	.	7891144008	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1049	.	9660050204	2025-07-19 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1050	Arvind Agarwal 	9414261612	2025-07-19 00:00:00	Needs Followup	Call cut	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1052	.	9784513332	2025-07-19 00:00:00	Needs Followup	Call back \r\nCall not pick \r\nBusy call u letter\r\nSwitch off 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1054	.	9001006999	2025-07-19 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1055	.	9929094716	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nSwitch off 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1057	.	9214591919	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1058	.	9314660286	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1059	.	7014464227	2025-07-19 00:00:00	Needs Followup	Call back 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1062	.	9828156027	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1064	.	9414068706	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1065	.	8871362812	2025-07-19 00:00:00	Needs Followup	Cut a call 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1067	Guru sir	9314294142	2025-07-19 00:00:00	Needs Followup	Not interested 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1068	.	8826611889	2025-07-19 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nHonda brv next month visit	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1069	.	9785842791	2025-07-19 00:00:00	Needs Followup	Cut a call 	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	\N
1082	.	9468964479	2025-07-19 00:00:00	Needs Followup	Not pick\r\nNot pick 	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1085	.	9166830836	2025-07-19 00:00:00	Needs Followup	Call not pick\r\nIn warranty period 	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1086	.	9829083087	2025-07-19 00:00:00	Needs Followup	Cut a call 	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1087	.	7737472113	2025-07-19 00:00:00	Needs Followup	Call not pick 	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1090	.	9414062308	2025-07-19 00:00:00	Needs Followup	Brezza 3299 package tyre change  call back half nd hour \r\nNot pick	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1092	.	7062999990	2025-07-19 00:00:00	Needs Followup	Call not pick \r\nNot interested amaze service done	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1093	.	9829214080	2025-07-19 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-04 11:58:59	9	2025-07-01 06:50:29.884428	\N
1098	.	9636270000	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1099	.	9001994440	2025-07-20 00:00:00	Needs Followup	Call cut	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1100	.	9784393194	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1101	.	9829012891	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1102	.	9414077341	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1103	.	9314564675	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1104	Manish sir 	9829581783	2025-07-20 00:00:00	Needs Followup	Busy 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1105	.	9950601688	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1106	.	8560872624	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1107	.	9555574141	2025-07-20 00:00:00	Needs Followup	WhatsApp package shared \r\nNot intrested	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1108	.	9667303348	2025-07-20 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1109	.	9460560706	2025-07-20 00:00:00	Needs Followup	Dent painting  tuesday visit\r\nOther workshop se low price me kaam ho gya	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1110	.	9414250288	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1111	.	9829117411	2025-07-20 00:00:00	Needs Followup	Cut a call \r\nDzire not requirement 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1112	.	9982408402	2025-07-20 00:00:00	Needs Followup	Not pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1113	.	9829053818	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1114	.	9828117705	2025-07-20 00:00:00	Needs Followup	Not interested \r\nCall cut\r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1115	.	8370008962	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1116	.	9413817299	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1117	.	9414036936	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1118	.	9413207535	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1119	.	8408809155	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1120	.	9672277227	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1121	.	9314935128	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1122	.	9414058448	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1123	.	9314594390	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1124	.	9553820412	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1125	.	9352222220	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	
1126	.	9672399900	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1127	.	9560664369	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 05:27:58	9	2025-07-01 06:50:29.884428	\N
1128	Ravi sir TUV	7976035980	2025-07-20 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1129	Ravi sir TUV	7976035980	2025-07-20 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1131	.	7737799953	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot pickbusy call u leter	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
7345	gaadimech 	9462698033	2025-07-20 00:00:00	Needs Followup	Spark clutch issue 	2025-05-21 05:54:51.927477	9	2025-07-01 06:50:29.884428	
266	.	9414074198	2025-07-20 00:00:00	Needs Followup	Busy 	2024-11-25 10:25:30	9	2025-07-01 06:50:29.884428	
308	R.K God 	7340660369	2025-07-20 00:00:00	Needs Followup	3 mhine pahle apke yha bhut Ganda respons tha m pahle apse aake milunga uske bad m gadi dunga apki jimedaeri pr next mont\r\nNot pick	2024-11-26 10:56:24	9	2025-07-01 06:50:29.884428	
311	Nishant ji	9924770499	2025-07-20 00:00:00	Needs Followup	2 December se pahle nhi aa sakta/ abhi out of Jaipur \r\nNot pick	2024-11-26 11:04:58	9	2025-07-01 06:50:29.884428	
314	Vedprkash ji	9828051516	2025-07-20 00:00:00	Needs Followup	M abhi Bahar hu 29 ko Jaipur aata hu tb dekhte h\r\nNot pick	2024-11-26 11:08:45	9	2025-07-01 06:50:29.884428	
330	Kamlesh ji	7665170104	2025-07-20 00:00:00	Needs Followup	Abhi Mera office ajmer h m Jaipur 5 Dec tk aa sakta hu ap 4 ko call kr lena\r\nNot pick	2024-11-26 11:37:26	9	2025-07-01 06:50:29.884428	
345	.	9414016356	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-11-26 12:43:14	9	2025-07-01 06:50:29.884428	
361	.	7014481810	2025-07-20 00:00:00	Needs Followup	Busy \r\nNot pick	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
365	.	9829240646	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
370	.	9521695829	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
391	.	7375064736	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
393	Dhanesh Sharma	8739809749	2025-07-20 00:00:00	Needs Followup	Call back January\r\nSwitch off \r\nService done by other workshop \r\nBusy call u later 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
565	.......	9314404260	2025-07-20 00:00:00	Needs Followup	N r	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
590	.	8824455285	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-11-30 08:40:31	9	2025-07-01 06:50:29.884428	
1132	.	9829071803	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nSeltos 5499. City 2999, swift 2699 package share\r\nNot pick\r\nNot pick	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1133	.	9829010809	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1134	.	9829084543	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1135	.	9829065531	2025-07-20 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1136	.	9782828272	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1137	.	9694067590	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1138	.	9950143038	2025-07-20 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1139	.	9636016718	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1140	.	9660025567	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1141	.	9929217966	2025-07-20 00:00:00	Needs Followup	Not pick\r\nNot pick	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1142	.	9314522098	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nWill let you know \r\nCity gi10	2024-12-06 07:53:15	9	2025-07-01 06:50:29.884428	\N
1143	.	9414268577	2025-07-20 00:00:00	Needs Followup	Out of range 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1144	.	9928072068	2025-07-20 00:00:00	Needs Followup	Call not pick\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1145	.	9212100339	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1147	.	9828570437	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1148	.	9799993966	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1149	.	9414075016	2025-07-20 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1151	.	9649015999	2025-07-20 00:00:00	Needs Followup	Switch off \r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1156	.	9928054075	2025-07-20 00:00:00	Needs Followup	Not pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1159	.	9001890240	2025-07-20 00:00:00	Needs Followup	Not pick\r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1161	.	9314930804	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1163	.	9829856401	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1164	.	7665013258	2025-07-20 00:00:00	Needs Followup	Not requirement 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1166	.	9829216800	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1167	.	9314420550	2025-07-20 00:00:00	Needs Followup	Call back \r\nFree service due 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1169	.	9829041730	2025-07-20 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1170	.	9314160346	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1171	.	9001590017	2025-07-20 00:00:00	Needs Followup	Switch off 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1172	.	9829392376	2025-07-20 00:00:00	Needs Followup	Customer busy call back 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1173	.	9829015220	2025-07-20 00:00:00	Needs Followup	Call back \r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1174	.	9829011675	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot intrested	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1175	.	9414077378	2025-07-20 00:00:00	Needs Followup	Not pick\r\nNot requirement 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1176	.	9414077378	2025-07-20 00:00:00	Needs Followup	Honda city 2999 package  	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1177	.	9929577782	2025-07-20 00:00:00	Needs Followup	Not requirement \r\nNot pick\r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1178	.	9413352842	2025-07-20 00:00:00	Needs Followup	Call back 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1179	.	9829162997	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1180	.	9982328371	2025-07-20 00:00:00	Needs Followup	Call back 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1181	.	9001966665	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1182	.	9829037137	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1183	.	9636813134	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1184	.	9829099426	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1185	.	9314853646	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1187	.	9829186899	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1189	.	9928100039	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1190	.	9982034389	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1191	.	9530620238	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1192	.	8077714949	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1193	.	8003776655	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1194	.	8504974258	2025-07-20 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1196	.	9414042587	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot interested call back 10 days	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	
1197	.	9929889589	2025-07-20 00:00:00	Needs Followup	800 1999 package call back after 4 to 5 days\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1199	.	9261283360	2025-07-20 00:00:00	Needs Followup	Car warranty me ha	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1200	.	9549650840	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nAmaze 2899. Service done by other workshop oct month	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1201	.	9829052491	2025-07-20 00:00:00	Needs Followup	Call back 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1204	.	9461261697	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1205	.	8890519889	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1206	.	9828114636	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1207	.	9001094841	2025-07-20 00:00:00	Needs Followup	Not pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1209	.	9352559495	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1210	.	9829065236	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1212	.	9982985867	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1213	.	9829250550	2025-07-20 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1214	.	9460060445	2025-07-20 00:00:00	Needs Followup	Not pick up\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1215	.	9783535659	2025-07-20 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1216	.	8890780789	2025-07-20 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1217	.	9829671653	2025-07-20 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1218	.	9828037500	2025-07-20 00:00:00	Needs Followup	Not requirement \r\nCall cut\r\nNot pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1219	.	9929658040	2025-07-20 00:00:00	Needs Followup	Call cut	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1220	.	9900649846	2025-07-20 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1221	.	7224003500	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1222	.	9829062294	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1223	.	9828041830	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1224	.	9414253124	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1226	.	9829223884	2025-07-21 00:00:00	Needs Followup	Not requirement 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1227	.	7877533450	2025-07-21 00:00:00	Needs Followup	Not requirement 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1228	.	8239301902	2025-07-21 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1230	Kapil sir 	9530401836	2025-07-21 00:00:00	Needs Followup	Not pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1231	.	9116114331	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
2630	Rajesh	9950400638	2025-07-21 00:00:00	Needs Followup	Service done by satnam auto	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2633	Ram narayan	9413114441	2025-07-21 00:00:00	Needs Followup	Service done by prem motors	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	\N
2879	Customer	9950333399	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nKwid service done 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2902	Customer	7073849047	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nWagnor service done	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
2915	Customer	8198971068	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nJaguar not interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	\N
3222	Customer 	8946894104	2025-07-21 00:00:00	Needs Followup	Service done bye other workshop 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	\N
3287	.	9887976150	2025-07-21 00:00:00	Needs Followup	Service done by other workshop 	2025-01-21 10:32:21.170778	9	2025-07-01 06:50:29.884428	\N
4796	SWIFT CX EXPRESS	8840554136	2025-07-21 00:00:00	Needs Followup	Swift follow up	2025-03-16 13:01:01.772156	9	2025-07-01 06:50:29.884428	
4916	Hanuman sahai	9829005552	2025-07-21 00:00:00	Needs Followup	Dzire tonk road	2025-03-21 06:25:13.879349	9	2025-07-01 06:50:29.884428	
7520	Cx2060	8003234288	2025-07-21 00:00:00	Needs Followup	Swift service 2899	2025-05-27 08:56:43.938503	9	2025-07-01 06:50:29.884428	
141	.	9460384906	2025-07-21 00:00:00	Needs Followup	I10 1999service package	2024-11-24 07:22:56	9	2025-07-01 06:50:29.884428	
392	.	8947940030	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
432	.	9982300422	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
1031	John sir	9887030435	2025-07-21 00:00:00	Needs Followup	WhatsApp package shared \r\nHonda City ka	2024-12-04 05:17:16	9	2025-07-01 06:50:29.884428	
1232	.	9829074700	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	
1233	.	9413916440	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1234	.	9001474755	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1235	.	7568150157	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick \r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1236	.	9414409223	2025-07-21 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1237	.	9887250990	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1238	.	9772265657	2025-07-21 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1239	.	8740027647	2025-07-21 00:00:00	Needs Followup	Warranty period 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1240	.	9414058445	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot intrested\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1241	.	9993027177	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1242	.	9828154905	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1243	.	9672222351	2025-07-21 00:00:00	Needs Followup	Cut a call\r\nNot interested 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1244	.	9314502876	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1246	.	9928405776	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-06 08:38:44	9	2025-07-01 06:50:29.884428	\N
1250	.	9413382340	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1251	.	9828077188	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1256	.	9811540460	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1257	.	9610009114	2025-07-21 00:00:00	Needs Followup	Call cut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1258	.	9918708348	2025-07-21 00:00:00	Needs Followup	Call cut\r\nNot pick\r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1259	.	9799558794	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1260	.	9314500368	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1261	Saurabh sir	9829015261	2025-07-21 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1262	.	9521890050	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1263	.	9829103459	2025-07-21 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1264	.	9828020022	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1266	.	8800533511	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1267	.	8800533511	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1268	.	9829976000	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1270	.	9785504599	2025-07-21 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1271	.	9829217353	2025-07-21 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1272	.	9785110006	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1273	.	9414717957	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1274	.	9414717957	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1275	.	8890075194	2025-07-21 00:00:00	Needs Followup	Call cut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1276	.	9414455977	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1277	.	9414035156	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1321	.	9887570366	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1322	.	9829056773	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1323	.	9982507891	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1325	.	7597510748	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1330	.	9414564106	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1332	.	7568024449	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1333	.	9785002880	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1334	.	9414021626	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1335	.	9829068555	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1337	.	9829060472	2025-07-21 00:00:00	Needs Followup	Honda city 2999 \r\n\r\n	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1342	.	9829924084	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1343	.	9602443444	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1349	.	9414042478	2025-07-21 00:00:00	Needs Followup	Not requirement \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1351	.	9916152120	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1353	.	7877393913	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1357	.	9414065665	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1358	.	9610020555	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1359	.....	9829063337	2025-07-21 00:00:00	Needs Followup	Need nhi h	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1360	.	8696901883	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1361	.......	9829008125	2025-07-21 00:00:00	Needs Followup	N.intrested\r\nNot pick up	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1362	.....	9829708446	2025-07-21 00:00:00	Needs Followup	Need nhi h	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1363	.....	9829708446	2025-07-21 00:00:00	Needs Followup	Need nhi h	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1364	.	9414046268	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1365	.....	9509102081	2025-07-21 00:00:00	Needs Followup	N.intrested	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1366	.	9694086602	2025-07-21 00:00:00	Needs Followup	Not requirement service done 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1367	.	9414030511	2025-07-21 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1372	....	7791072000	2025-07-21 00:00:00	Needs Followup	Breeza h but inke pass 5 year ka plan h	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1373	.......	9784958585	2025-07-21 00:00:00	Needs Followup	Ethos h but not intrested\r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1374	Ajay Singh 	9887032289	2025-07-21 00:00:00	Needs Followup	Alto ka pack bheja h 20 tk call back	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1375	.....	9829050752	2025-07-21 00:00:00	Needs Followup	Call kut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1376	.	9116157101	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1377	.....	9772232761	2025-07-21 00:00:00	Needs Followup	N.r	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1378	.	9015400167	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nDon't have cae	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1379	.....	9829061632	2025-07-21 00:00:00	Needs Followup	Bad me bat krenge ir call Kat diya	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1380	......	9829061484	2025-07-21 00:00:00	Needs Followup	Sunke call Kat diye	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1381	.	9999670533	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1382	.	7023005599	2025-07-21 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1383	Bharat	9829022005	2025-07-21 00:00:00	Needs Followup	Abhi to jrurat h nhi jb hogi call kr lunga	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1384	.	9269690000	2025-07-21 00:00:00	Needs Followup	Not interested 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1385	.	8851607742	2025-07-21 00:00:00	Needs Followup	Call back 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1386	Ram nivash	9887638918	2025-07-21 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	\N
1387	.	9610504968	2025-07-21 00:00:00	Needs Followup	Call not pick 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1388	.	9929669292	2025-07-21 00:00:00	Needs Followup	Not requirement 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1389	......	9829061484	2025-07-21 00:00:00	Needs Followup	Sunke call Kat diye	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1390	Rahul sharma	9828896001	2025-07-21 00:00:00	Needs Followup	Alto or Honda city dono ka pack bheja h	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1391	.	9643047246	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1392	.	9314508094	2025-07-21 00:00:00	Needs Followup	Busy \r\nNot pick\r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1393	.....	9829900036	2025-07-21 00:00:00	Needs Followup	N.r	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1397	.	8385829556	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	
1398	.  .	9784354566	2025-07-21 00:00:00	Needs Followup	Busy	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1399	.	9887252110	2025-07-21 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot interested 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1400	.	8560092512	2025-07-21 00:00:00	Needs Followup	Out of network 🛜 switch of\r\nNot connected\r\nNot pick\r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1401	.....	9829077004	2025-07-21 00:00:00	Needs Followup	Bat sun kr call Kat diya	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1402	.	9214323353	2025-07-21 00:00:00	Needs Followup	Cut a call 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	
1403	...	8385829556	2025-07-21 00:00:00	Needs Followup	Busy	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1404	.	8890426094	2025-07-21 00:00:00	Needs Followup	Cut a call\r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1405	......	7975120695	2025-07-21 00:00:00	Needs Followup	Switch off	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1406	.	8952876959	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1407	....	9828959380	2025-07-22 00:00:00	Needs Followup	Call forwarded $ voice mail	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1409	.	9828577789	2025-07-22 00:00:00	Needs Followup	Call not pick 9\r\nNot pick\r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
3561	.	9828899401	2025-07-22 00:00:00	Did Not Pick Up	I20  2599 service done	2025-01-31 08:47:45.318294	9	2025-07-01 06:50:29.884428	
4201	.	9636963892	2025-07-22 00:00:00	Did Not Pick Up	Service done already \r\nCall cut	2025-02-18 11:44:04.466294	9	2025-07-01 06:50:29.884428	
7662	Cx2093	9001007000	2025-07-22 00:00:00	Needs Followup	Ecosport bumper paint \r\nAbhi nahi karwi hai 	2025-06-01 05:08:14.228458	9	2025-07-01 06:50:29.884428	
247	.	8949982183	2025-07-22 00:00:00	Needs Followup	Alto 1999	2024-11-25 07:59:29	9	2025-07-01 06:50:29.884428	
379	Rakesh chudhray 	9828346944	2025-07-22 00:00:00	Needs Followup	Skoda superb h gear work h 2 ko call back\r\nCall back 5 to 10 days than visit krenge 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
394	.	9829054569	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nBusy call u later 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
435	.	9784808880	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
715	Nrendra Awasthi 	8696666099	2025-07-22 00:00:00	Needs Followup	Ap log 10000 k.m. ki sarvice ki guaranty lo baki campne guaranty leti h	2024-12-01 08:24:21	9	2025-07-01 06:50:29.884428	
1410	.	8740997985	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1411	.	9904415236	2025-07-22 00:00:00	Needs Followup	Not requirement \r\nNot requirement 	2024-12-07 11:39:13	9	2025-07-01 06:50:29.884428	\N
1412	.	9828227352	2025-07-22 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	\N
1418	.......	9829134235	2025-07-22 00:00:00	Needs Followup	N.r	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	\N
1452	....	9460765607	2025-07-22 00:00:00	Needs Followup	Gadi h pr m  her se intrested nhi b	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	\N
1489	Ishan sir	7877749401	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	\N
1490	.	9315274670	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	\N
1491	.	9610880119	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	\N
1492	.	9829380888	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	\N
1493	.	7023081175	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nSwitch off 	2024-12-08 10:41:33	9	2025-07-01 06:50:29.884428	\N
1494	.	9983529290	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-08 11:33:12	9	2025-07-01 06:50:29.884428	
1495	.	9983684902	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-08 11:33:12	9	2025-07-01 06:50:29.884428	\N
1496	.	9660246541	2025-07-22 00:00:00	Needs Followup	Call back 	2024-12-08 11:33:12	9	2025-07-01 06:50:29.884428	\N
1497	.	7718080325	2025-07-22 00:00:00	Needs Followup	Switch off 	2024-12-08 11:33:12	9	2025-07-01 06:50:29.884428	\N
1498	.	9828348101	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1499	.	7062714420	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1500	.	7014199192	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1503	.	9509197259	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1504	.	9899140066	2025-07-22 00:00:00	Needs Followup	Not interested \r\nCall cut	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1505	.	7742701190	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1506	.	7412005678	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1507	.	9887740392	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nCall cut\r\nCall cut	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1508	.	9414890125	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1510	.	9694400712	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1511	.	9874456323	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1512	.	8800648282	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	
1513	.	9694655912	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1514	.	9950345510	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1515	.	9414327771	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1516	.	9509007072	2025-07-22 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1517	.	7976371615	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nService done by other workshop 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1518	.	8386075201	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	
1519	.	8769861554	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	
1520	.	9468844043	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1521	.	9672031049	2025-07-22 00:00:00	Needs Followup	Call back \r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1522	.	9680221379	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1523	.	9468592718	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-08 12:10:57	9	2025-07-01 06:50:29.884428	\N
1524	Jay sir	9829167067	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared \r\nVerna 2999	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	
1525	.	9815872435	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1526	.	9829970557	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1529	.	7568609554	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1530	.	9667390483	2025-07-22 00:00:00	Needs Followup	Not interested \r\nScoty chalata hh	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1531	.	9929500500	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1532	.	9636993880	2025-07-22 00:00:00	Needs Followup	Not reachable \r\nNot pick \r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1533	.	9540889886	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1534	.	9458208202	2025-07-22 00:00:00	Needs Followup	Call back \r\nNot interested 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1535	.	9024702251	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1536	Pream singh 	9414720022	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1537	Rohan sir	7738117189	2025-07-22 00:00:00	Needs Followup	Whanot requirement tsApp package shared 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1538	.	9829547712	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1539	.	6350545859	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1540	.	6375308390	2025-07-22 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1541	.	9929235504	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1542	.	8233448679	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1543	.	9024577350	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1544	.	9024577350	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1545	.	9024577350	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1547	.	9828503804	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1548	.	8560833306	2025-07-22 00:00:00	Needs Followup	Not requirement 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1549	.	9910993556	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1550	.	9929395151	2025-07-22 00:00:00	Needs Followup	Call cut	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1551	.	9370701073	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1552	.	9649174000	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1553	.	8742041076	2025-07-22 00:00:00	Needs Followup	Call cut	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1554	.	9996017865	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1557	Manish Baral	9829344012	2025-07-22 00:00:00	Needs Followup	Call back 	2024-12-09 05:32:49	9	2025-07-01 06:50:29.884428	\N
1558	Ashish sir 	8432375632	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1559	Ashish sir 	8432375632	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1560	.	7340143530	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1561	Chirag sir	7877923823	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1562	.	9829300343	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nCallc ut	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1563	.	9413865463	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1564	Harshvardhan sir 	8690864607	2025-07-22 00:00:00	Needs Followup	Call back 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1565	.	7727821334	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1566	.	9829542639	2025-07-22 00:00:00	Needs Followup	Not requirement \r\nCall cut	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1567	Rakesh meeena	7014855547	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1568	.	9799153458	2025-07-22 00:00:00	Needs Followup	Not interested 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1569	.	8218384350	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1570	.	8886862628	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-09 08:42:30	9	2025-07-01 06:50:29.884428	\N
1571	.	9509061114	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-09 09:34:17	9	2025-07-01 06:50:29.884428	\N
1572	.	9509061114	2025-07-22 00:00:00	Needs Followup	Cut a call 	2024-12-09 09:34:17	9	2025-07-01 06:50:29.884428	\N
1573	Ajay sir 	9799492917	2025-07-22 00:00:00	Needs Followup	WhatsApp package shared \r\nCall cut	2024-12-09 09:34:17	9	2025-07-01 06:50:29.884428	\N
1574	.	7665601906	2025-07-22 00:00:00	Needs Followup	Not requirement 	2024-12-09 09:34:17	9	2025-07-01 06:50:29.884428	\N
1575	.	8003097623	2025-07-22 00:00:00	Needs Followup	Not requirement 	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1576	.	9676305290	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1577	.	8005949025	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1578	.	9873060456	2025-07-22 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1579	Manish sir 	9079777453	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1580	.	9784532569	2025-07-22 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1581	.	9660581180	2025-07-22 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1584	.	9785558866	2025-07-22 00:00:00	Needs Followup	Call back 	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1585	.	9785558886	2025-07-22 00:00:00	Needs Followup	Not pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1586	.	9891799313	2025-07-22 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-09 10:13:27	9	2025-07-01 06:50:29.884428	\N
1606	.	9643853437	2025-07-22 00:00:00	Needs Followup	Call not pick 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	
4592	gaadimech 	9887535382	2025-07-22 00:00:00	Needs Followup	I20 ac lickage	2025-03-08 05:39:05.076996	9	2025-07-01 06:50:29.884428	
3984	.	9119114730	2025-07-22 00:00:00	Did Not Pick Up	Nexon petrol 2899	2025-02-12 09:43:38.852174	9	2025-07-01 06:50:29.884428	
4095	.	9314518074	2025-07-22 00:00:00	Did Not Pick Up	Not pick \r\nNot Requirement  kch time pahle service done	2025-02-16 09:50:18.702163	9	2025-07-01 06:50:29.884428	
4230	.	8769913460	2025-07-22 00:00:00	Did Not Pick Up	Not requirement gaadi kahi se thk krwa li 	2025-02-19 05:09:56.855755	9	2025-07-01 06:50:29.884428	
4693	.	9072368991	2025-07-22 00:00:00	Did Not Pick Up	Not pick	2025-03-12 11:18:59.02626	9	2025-07-01 06:50:29.884428	
5128	gaadimech 	9001530876	2025-07-22 00:00:00	Did Not Pick Up	Call cut\r\nNot required 	2025-03-27 05:38:33.360248	9	2025-07-01 06:50:29.884428	
7325	gaadimech	7791801469	2025-07-22 00:00:00	Did Not Pick Up	Not by mistake inquiry ki hogi\r\n	2025-05-20 07:42:40.870663	9	2025-07-01 06:50:29.884428	
3706	.	9950887122	2025-07-22 00:00:00	Needs Followup	Service done by other workshop 	2025-02-04 11:08:27.673516	9	2025-07-01 06:50:29.884428	\N
310	Shiva	8209062123	2025-07-22 00:00:00	Needs Followup	Next month m aaunga Jaipur apko call kr dunga\r\nNot pick	2024-11-26 11:02:46	9	2025-07-01 06:50:29.884428	
319	Sanjiv ji 	9829198996	2025-07-22 00:00:00	Needs Followup	Abhi office ki wajah se nhi aa paya m Monday tk aaunga visit pr dent pent h/madam Kal aaunga\r\nNot pick	2024-11-26 11:13:26	9	2025-07-01 06:50:29.884428	
406	.	7733077777	2025-07-22 00:00:00	Needs Followup	Not interested & cut a call	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
428	.	9199369485	2025-07-23 00:00:00	Needs Followup	Cut a call	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
429	.	8527759101	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
436	.	9828022286	2025-07-23 00:00:00	Needs Followup	New car \r\nCallc ut	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
499	Arjun ji 	9929870575	2025-07-23 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick\r\nNot pick\r\nScorpio 4699\r\n	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
563	Yogesh ji 	9828011000	2025-07-23 00:00:00	Needs Followup	Dzire ka pack send kiya h but abhi need nhi h	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
583	.	9829133000	2025-07-23 00:00:00	Needs Followup	Not interested & cut a call\r\nNot pick	2024-11-30 07:06:42	9	2025-07-01 06:50:29.884428	
592	.	9414051460	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nCall back 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	
1587	.	9929511166	2025-07-23 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1588	.	9929511166	2025-07-23 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nNot pick	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1589	.	8003660547	2025-07-23 00:00:00	Needs Followup	Not interested 	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1590	.	7976053618	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1591	.	9024282878	2025-07-23 00:00:00	Needs Followup	Not pick\r\nNot pic\r\nNot pick	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1592	.	9636245746	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-09 11:22:21	9	2025-07-01 06:50:29.884428	\N
1593	.	7822012121	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-09 12:04:23	9	2025-07-01 06:50:29.884428	\N
1594	.	9983342628	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-09 12:04:23	9	2025-07-01 06:50:29.884428	\N
1595	.	8852884688	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-09 12:04:23	9	2025-07-01 06:50:29.884428	\N
1596	.	9828878408	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-09 12:04:23	9	2025-07-01 06:50:29.884428	\N
1597	.	7972752747	2025-07-23 00:00:00	Needs Followup	Cut a call 	2024-12-09 12:04:23	9	2025-07-01 06:50:29.884428	\N
1600	.	9929450624	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1616	.	8006671301	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1617	.	9416999802	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1619	.	8769930475	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1620	.	8561073404	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1622	.	8905958255	2025-07-23 00:00:00	Needs Followup	Cut a call\r\nSwitch off \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1623	.	7597122103	2025-07-23 00:00:00	Needs Followup	Not interested \r\nCall cut	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1624	.	7062715409	2025-07-23 00:00:00	Needs Followup	Cut a call 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1626	.	7690929619	2025-07-23 00:00:00	Needs Followup	Not requirement \r\nService done by other workshop 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1629	.	7375057600	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1630	.	9398247058	2025-07-23 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick\r\nNot connect \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1631	.	9461073186	2025-07-23 00:00:00	Needs Followup	Not interested 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1632	.	9001444456	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1633	.	7877060073	2025-07-23 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	
1634	.	9457153794	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1635	.	8441981161	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1637	.	8740008445	2025-07-23 00:00:00	Needs Followup	Don't have car	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	\N
1639	Desraj 	9001664353	2025-07-23 00:00:00	Needs Followup	Not interested & cut a call\r\nCall cut\r\nNot required 	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1640	.	8005904470	2025-07-23 00:00:00	Needs Followup	Not requirement \r\nNot pick	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1641	Govind sir	9261121299	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1642	Ramanand sir	9461551152	2025-07-23 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1643	BHAIRU sir	9982125968	2025-07-23 00:00:00	Needs Followup	Cut a call 	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1646	.	9414156405	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nCustomer tonk rahte h kabhi requirement hui to aayenge jaipur	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1647	.	9414003477	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot required 	2024-12-10 09:23:05	9	2025-07-01 06:50:29.884428	\N
1648	.	9414043964	2025-07-23 00:00:00	Needs Followup	Not requirement 	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1649	.	7014662020	2025-07-23 00:00:00	Needs Followup	Cut a call 	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1650	.	7726818144	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1652	.	8559995044	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1653	Mahaveer sir	9929090757	2025-07-23 00:00:00	Needs Followup	Glaze 2599 package share call back 3rd march	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1654	.	9001892178	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1655	.	9680004561	2025-07-23 00:00:00	Needs Followup	Call cut not requirement 	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1656	.	8114487087	2025-07-23 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nNot oick	2024-12-10 10:30:45	9	2025-07-01 06:50:29.884428	\N
1657	.	7891948142	2025-07-23 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-10 11:41:55	9	2025-07-01 06:50:29.884428	\N
1658	.	9414054966	2025-07-23 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nCall cut	2024-12-10 11:41:55	9	2025-07-01 06:50:29.884428	\N
1659	.	9785206060	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNexon 2999 package share requirment hogi to bta denge	2024-12-10 11:41:55	9	2025-07-01 06:50:29.884428	\N
1660	.	8107304398	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot interested 	2024-12-10 12:03:24	9	2025-07-01 06:50:29.884428	\N
1661	.	9828283639	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut	2024-12-10 12:03:24	9	2025-07-01 06:50:29.884428	\N
1662	.	9588901372	2025-07-23 00:00:00	Needs Followup	Bolero 4699 package service done by other worksop last month dec	2024-12-10 12:03:24	9	2025-07-01 06:50:29.884428	\N
1668	Diraj sir	9828153281	2025-07-23 00:00:00	Needs Followup	Call back 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1669	.	9001273636	2025-07-23 00:00:00	Needs Followup	Not interes\r\nnot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1670	.	7222853878	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1671	.	8503065529	2025-07-23 00:00:00	Needs Followup	Warranty me ha	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1672	.	9828233154	2025-07-23 00:00:00	Needs Followup	Not required 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1673	.	9829500464	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1674	.	9950667518	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1675	.	9829011375	2025-07-23 00:00:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1676	.	9785600448	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1678	.	9784905001	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nI20 2699	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1679	.	8114452851	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1680	.	8239297047	2025-07-23 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1682	.	9636670333	2025-07-23 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1683	.	9314505244	2025-07-23 00:00:00	Needs Followup	Not requirement \r\nNot pick\r\nNot pick\r\nNot interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1684	.	6377917006	2025-07-23 00:00:00	Needs Followup	Cut a call 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1685	.	8955225569	2025-07-23 00:00:00	Needs Followup	Warranty me ha	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1686	.	8237297547	2025-07-23 00:00:00	Needs Followup	Call back 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1687	.	9982174354	2025-07-23 00:00:00	Needs Followup	Call not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1688	.	9503104726	2025-07-23 00:00:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
3904	Cx273	9772543862	2025-07-23 00:00:00	Needs Followup	Beat suspension \r\nService 	2025-02-08 09:17:49.962802	9	2025-07-01 06:50:29.884428	
3917	Cx286	6377177761	2025-07-23 00:00:00	Needs Followup	Corolla 3999	2025-02-08 09:27:34.917235	9	2025-07-01 06:50:29.884428	
3926	Cx296	9928887684	2025-07-23 00:00:00	Needs Followup	Alto car service \r\nVoice call 	2025-02-08 09:36:06.674298	9	2025-07-01 06:50:29.884428	
3928	Cx298	9772543862	2025-07-23 00:00:00	Needs Followup	Beat suspension \r\nSharp 	2025-02-08 09:58:16.631815	9	2025-07-01 06:50:29.884428	
3929	Cx299	7877342787	2025-07-23 00:00:00	Needs Followup	Swift \r\nGeneral check up	2025-02-08 09:59:00.54169	9	2025-07-01 06:50:29.884428	
3932	Cx301	9667100531	2025-07-23 00:00:00	Needs Followup	Car service 	2025-02-09 10:54:16.853677	9	2025-07-01 06:50:29.884428	
3940	Cx308	8003776668	2025-07-23 00:00:00	Needs Followup	Call cut	2025-02-09 11:11:56.30093	9	2025-07-01 06:50:29.884428	
4157	Cx417	8209831080	2025-07-23 00:00:00	Needs Followup	Call cut 	2025-02-18 07:09:07.839011	9	2025-07-01 06:50:29.884428	
4164	Cx424	9602524427	2025-07-23 00:00:00	Needs Followup	i20\r\nService \r\nSuspension vki 	2025-02-18 07:13:47.762587	9	2025-07-01 06:50:29.884428	
4167	Cx426	9784137284	2025-07-23 00:00:00	Needs Followup	Carens 3199\r\nService 	2025-02-18 07:17:17.075129	9	2025-07-01 06:50:29.884428	
4178	Cx449	9214015127	2025-07-23 00:00:00	Needs Followup	Abhi nahi 	2025-02-18 10:01:37.649584	9	2025-07-01 06:50:29.884428	
4179	Cx448	6378873744	2025-07-23 00:00:00	Needs Followup	In coming nahi hai \r\nWhatsApp \r\nSkoda service  5999	2025-02-18 10:02:26.60882	9	2025-07-01 06:50:29.884428	
4181	Cx451	9928090627	2025-07-23 00:00:00	Needs Followup	Car rubbing 	2025-02-18 10:03:29.480595	9	2025-07-01 06:50:29.884428	
4189	Cx461	9252399596	2025-07-23 00:00:00	Needs Followup	Figo \r\nAc blur	2025-02-18 10:11:32.560107	9	2025-07-01 06:50:29.884428	
4253	Cx502	8800227430	2025-07-23 00:00:00	Needs Followup	Car service 	2025-02-21 10:44:27.040572	9	2025-07-01 06:50:29.884428	
4863	gaadimech	7568803802	2025-07-23 00:00:00	Needs Followup	Swift ac checkup 	2025-03-19 09:15:49.231296	9	2025-07-01 06:50:29.884428	
4981	Mohit 	7600075040	2025-07-23 00:00:00	Needs Followup	Didn't pick up the call \r\n	2025-03-24 07:34:51.128551	9	2025-07-01 06:50:29.884428	
4982	Rohit	9414443801	2025-07-23 00:00:00	Needs Followup	Don't have car	2025-03-24 07:36:30.938086	9	2025-07-01 06:50:29.884428	
4983	Customer 	7568815000	2025-07-23 00:00:00	Needs Followup	Disconnected 	2025-03-24 07:37:16.192938	9	2025-07-01 06:50:29.884428	
4984	Anil 	8562044310	2025-07-23 00:00:00	Needs Followup	Was driving at the moment so needs follow up Cb	2025-03-24 07:40:14.354022	9	2025-07-01 06:50:29.884428	
5004	Ronak 	8005751521	2025-07-23 00:00:00	Needs Followup	Seltos 3899	2025-03-24 09:04:00.835616	9	2025-07-01 06:50:29.884428	
5008	Nadeem 	9928163330	2025-07-23 00:00:00	Needs Followup	Not answered the phone call 	2025-03-24 09:08:07.923852	9	2025-07-01 06:50:29.884428	
66	Cx19	6376331255	2025-07-23 00:00:00	Needs Followup	Ciaz \r\nService aur Dent pent \r\nCall cut	2024-11-23 11:07:22	9	2025-07-01 06:50:29.884428	
95	Cx24 	9829202350	2025-07-23 00:00:00	Did Not Pick Up	Baleno \r\nBumper paint\r\nService \r\nNot pick \r\n 	2024-11-23 13:03:41	9	2025-07-01 06:50:29.884428	
198	Cx36	8681919507	2025-07-23 00:00:00	Did Not Pick Up	Skoda service \r\nCall cut 	2024-11-24 11:48:51	9	2025-07-01 06:50:29.884428	
203	CX38	9887184107	2025-07-23 00:00:00	Did Not Pick Up	Honda amaze \r\nService 2699\r\nCall cut	2024-11-24 11:57:58	9	2025-07-01 06:50:29.884428	
540	.	9414063682	2025-07-23 00:00:00	Did Not Pick Up	Not interested 	2024-11-28 12:42:48	9	2025-07-01 06:50:29.884428	
548	.........	9680193300	2025-07-23 00:00:00	Did Not Pick Up	Not intrested 	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
555	.......	7014294634	2025-07-23 00:00:00	Did Not Pick Up	N.intrest3d\r\nCall cut	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
577	.	9214691603	2025-07-23 00:00:00	Did Not Pick Up	Baleno 2499 service done	2024-11-30 06:34:08	9	2025-07-01 06:50:29.884428	
758	.. ..	9001041682	2025-07-23 00:00:00	Did Not Pick Up	Breeze ka pack send kiya h m soch kr btaungi/madam mere husband se abhi bat nhi ho pai\r\nNot interested 	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
1298	Customer	9928029414	2025-07-23 00:00:00	Did Not Pick Up	Kwid,service , gandhi path vaishali.\r\nCall ut	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1302	Customer	9929099132	2025-07-23 00:00:00	Did Not Pick Up	Hyundai exter, Tripoliya Bazzar. \r\nNot pick	2024-12-07 05:46:09	9	2025-07-01 06:50:29.884428	
1427	....	9929255583	2025-07-23 00:00:00	Did Not Pick Up	Not interested 	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	
1444	Paresh jain	7891175757	2025-07-23 00:00:00	Did Not Pick Up	WhatsApp package shared \r\nCall cut	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	
1449	.	9829248899	2025-07-23 00:00:00	Did Not Pick Up	Call back \r\nNot interested 	2024-12-08 05:58:11	9	2025-07-01 06:50:29.884428	
1472	.	9057203601	2025-07-23 00:00:00	Confirmed	Call not pick \r\nCall cut\r\nEtios 3199\r\nRequirement hogi to jarur call karenge	2024-12-08 08:15:33	9	2025-07-01 06:50:29.884428	
1627	Sallauddin	8619442743	2025-07-23 00:00:00	Did Not Pick Up	cus want call back in evening, right now cus not pickup my calls,\r\ncus want followup again\r\nCall cut	2024-12-10 05:43:58	9	2025-07-01 06:50:29.884428	
1782	.	9785189718	2025-07-23 00:00:00	Did Not Pick Up	Call not pick 	2024-12-13 11:43:31	9	2025-07-01 06:50:29.884428	
1789	.	9509796329	2025-07-23 00:00:00	Did Not Pick Up	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 12:47:07	9	2025-07-01 06:50:29.884428	
1796	.	8058301117	2025-07-23 00:00:00	Did Not Pick Up	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 06:02:14	9	2025-07-01 06:50:29.884428	
1799	.	7425886780	2025-07-24 00:00:00	Did Not Pick Up	Cut a call \r\nNot pick\r\nNot interested 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	
1804	.	9057596183	2025-07-24 00:00:00	Did Not Pick Up	Call not pick	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	
2589	Cx143	9983402076	2025-07-24 00:00:00	Did Not Pick Up	Swift 2699\r\nService done 	2025-01-06 11:15:01.167732	9	2025-07-01 06:50:29.884428	
2857	Customer	9549032584	2025-07-24 00:00:00	Did Not Pick Up	Call cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2865	Customer	9166003300	2025-07-24 00:00:00	Did Not Pick Up	Not pick\r\nRecent service done \r\nCall cut	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2999	Customer	9729420188	2025-07-24 00:00:00	Did Not Pick Up	Eon 1999 \r\n\r\nService done by other workshop\r\n	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3179	Customer	9829889716	2025-07-24 00:00:00	Did Not Pick Up	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3293	.	9829127111	2025-07-24 00:00:00	Did Not Pick Up	Call cut	2025-01-21 10:55:25.845211	9	2025-07-01 06:50:29.884428	
3428	.	7828849334	2025-07-24 00:00:00	Did Not Pick Up	Switch off 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3454	.	7976101600	2025-07-24 00:00:00	Did Not Pick Up	Switch off 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3581	.	9829077202	2025-07-24 00:00:00	Did Not Pick Up	Not pick 	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3694	.	9828212786	2025-07-24 00:00:00	Needs Followup	Wagnor service done\r\nVoice mail	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3771	.	9001798709	2025-07-24 00:00:00	Did Not Pick Up	Nit interested 	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
4049	.	9887704826	2025-07-24 00:00:00	Did Not Pick Up	Not pick 	2025-02-15 10:06:08.442826	9	2025-07-01 06:50:29.884428	
4102	.	9389163697	2025-07-24 00:00:00	Did Not Pick Up	Customers are staying up 	2025-02-16 10:17:02.201959	9	2025-07-01 06:50:29.884428	
4192	.	8000204717	2025-07-24 00:00:00	Did Not Pick Up	Innova stering work	2025-02-18 10:38:28.431275	9	2025-07-01 06:50:29.884428	
4305	customer 	9414045918	2025-07-24 00:00:00	Did Not Pick Up	Not interested 	2025-02-22 11:53:10.841539	9	2025-07-01 06:50:29.884428	
4343	gaadimech 	7877020103	2025-07-24 00:00:00	Did Not Pick Up	Bolero drycleaning \r\nBusy hu free hokr aaunga	2025-02-24 09:16:18.762096	9	2025-07-01 06:50:29.884428	
4451	customer 	9799397177	2025-07-24 00:00:00	Did Not Pick Up	Xcent dent paint nd ac issue	2025-03-01 09:13:35.536881	9	2025-07-01 06:50:29.884428	
4733	.	9829650566	2025-07-24 00:00:00	Did Not Pick Up	Call not connect \r\nNot interested 	2025-03-13 11:31:18.532001	9	2025-07-01 06:50:29.884428	
4818	gaadimech	9799343696	2025-07-24 00:00:00	Did Not Pick Up	April me dekhenge K10 ac issue	2025-03-18 04:59:40.21739	9	2025-07-01 06:50:29.884428	
4883	.	7737096760	2025-07-24 00:00:00	Needs Followup	I20 2699 package share 	2025-03-20 11:32:47.411557	9	2025-07-01 06:50:29.884428	
5021	gaadimech 	9929535748	2025-07-24 00:00:00	Did Not Pick Up	Wagnor 2399 next month Tak plan karenge	2025-03-25 04:45:36.687437	9	2025-07-01 06:50:29.884428	
5067	gaadimech 	9672081560	2025-07-24 00:00:00	Did Not Pick Up	I10 2299 chomu	2025-03-26 05:21:34.72009	9	2025-07-01 06:50:29.884428	
5069	gaadimech	7269077753	2025-07-24 00:00:00	Needs Followup	Polo 3699 call back after 4 month 	2025-03-26 05:33:18.879794	9	2025-07-01 06:50:29.884428	
5157	gaadimech	9829280947	2025-07-24 00:00:00	Did Not Pick Up	Busy call u later\r\nNot interested mene k\r\nCompany se service krwa li	2025-03-27 09:28:04.440054	9	2025-07-01 06:50:29.884428	
5446	gaadimech 	9257378926	2025-07-24 00:00:00	Did Not Pick Up	Ac check up tonk road \r\nNot interested 	2025-04-02 04:42:53.069968	9	2025-07-01 06:50:29.884428	
5452	gaadimech 	7050621080	2025-07-24 00:00:00	Did Not Pick Up	Service CS motors\r\nCall cut 	2025-04-02 05:51:01.993611	9	2025-07-01 06:50:29.884428	
5519	gaadimech 	7790927363	2025-07-24 00:00:00	Did Not Pick Up	Wagnor 2399\r\nNot interested 	2025-04-03 05:08:10.046111	9	2025-07-01 06:50:29.884428	
5881	gaadimech 	7737358740	2025-07-24 00:00:00	Did Not Pick Up	Alto 2299	2025-04-13 09:24:37.087905	9	2025-07-01 06:50:29.884428	
6093	gaadimech 	8094634626	2025-07-24 00:00:00	Did Not Pick Up	Alto ac work \r\nRamgarh mode se hi karwa lia kam	2025-04-16 05:16:58.713583	9	2025-07-01 06:50:29.884428	
6180	Customer 	9571136483	2025-07-24 00:00:00	Did Not Pick Up	Dnc	2025-04-17 07:57:16.607983	9	2025-07-01 06:50:29.884428	
6377	ankush sharma gaadimech 	9462866380	2025-07-24 00:00:00	Feedback	Swift done sharp motors 	2025-04-20 06:36:17.756929	9	2025-07-01 06:50:29.884428	GJ36J1183
6623	gaadimech 	8955217770	2025-07-24 00:00:00	Did Not Pick Up	Dzire 2999\r\nNit interested 	2025-04-24 04:57:07.447812	9	2025-07-01 06:50:29.884428	
6681	...	9829147339	2025-07-24 00:00:00	Did Not Pick Up	Not pick \r\nCall cut	2025-04-25 11:36:56.029063	9	2025-07-01 06:50:29.884428	
6726	customer 	8769906272	2025-07-24 00:00:00	Did Not Pick Up	Not required 	2025-04-26 10:29:48.616635	9	2025-07-01 06:50:29.884428	
6731	customer 	9672740717	2025-07-24 00:00:00	Did Not Pick Up	Call cut\r\nNot interested 	2025-04-26 11:36:31.60896	9	2025-07-01 06:50:29.884428	
6755	vivan 	8824722792	2025-07-24 00:00:00	Feedback	Dzire service done \r\n4739 Big Boss \r\nFeedback \r\n	2025-04-28 05:04:19.051428	9	2025-07-01 06:50:29.884428	RJ14XC5220
6774	gaadimech 	6375172974	2025-07-24 00:00:00	Did Not Pick Up	Tata zest 3599\r\nNot interested 	2025-04-28 09:22:28.443184	9	2025-07-01 06:50:29.884428	
6853	gaadimech 	9067584552	2025-07-24 00:00:00	Feedback	I10 service \r\nTotal payment 2400\r\nFeedback\r\nSatisfied customer 	2025-05-03 05:31:24.944668	9	2025-07-01 06:50:29.884428	RJ14CT1965
6870	gaadimech 	7849929290	2025-07-24 00:00:00	Feedback	Innova service clutch work \r\n33000 total payment \r\nFeedback\r\nSatisfied customer 	2025-05-03 08:29:32.29707	9	2025-07-01 06:50:29.884428	RJ14UF9295
6909	deepak gaadimech 	9910153930	2025-07-24 00:00:00	Feedback	Baleno 3779 cash\r\nSharp motors\r\nFeedback\r\n	2025-05-05 07:06:37.733972	9	2025-07-01 06:50:29.884428	DL10CM8110
6979	gaadimech 	7300268212	2025-07-24 00:00:00	Did Not Pick Up	Not interested 	2025-05-08 04:32:53.763866	9	2025-07-01 06:50:29.884428	
7095	gaadimech	9166527776	2025-07-24 00:00:00	Feedback	Baleno 3700 total payment online\r\nFeedback	2025-05-11 05:54:06.644117	9	2025-07-01 06:50:29.884428	
7203	gaadimech	8989838284	2025-07-24 00:00:00	Did Not Pick Up	Not pick	2025-05-15 10:31:12.597432	9	2025-07-01 06:50:29.884428	
7204	gaadimech	9782993674	2025-07-24 00:00:00	Did Not Pick Up	Voice Mail \r\nNot interested 	2025-05-15 10:32:21.301144	9	2025-07-01 06:50:29.884428	
7326	gaadimech	9079657106	2025-07-24 00:00:00	Did Not Pick Up	Figo freestyle 2799\r\nNot interested 	2025-05-20 09:10:22.624714	9	2025-07-01 06:50:29.884428	
7332	Gaadimech 	9829150294	2025-07-24 00:00:00	Did Not Pick Up	Ac service call cut\r\nCall cut 	2025-05-20 12:24:58.795737	9	2025-07-01 06:50:29.884428	
7377	gaadimech 	8239128561	2025-07-24 00:00:00	Did Not Pick Up	Not pick \r\n	2025-05-22 05:13:58.797116	9	2025-07-01 06:50:29.884428	
7417	gaadimech 	9166220489	2025-07-24 00:00:00	Did Not Pick Up	Not pick \r\nCall cut	2025-05-23 06:47:58.653871	9	2025-07-01 06:50:29.884428	
7455	gaadimech 	8740940796	2025-07-24 00:00:00	Did Not Pick Up	Celerio 2699 till time not required self call back karenge	2025-05-24 07:04:20.304401	9	2025-07-01 06:50:29.884428	
7475	gaadimech 	7220968228	2025-07-24 00:00:00	Did Not Pick Up	Kwid ac check Nit requirement self call back\r\n	2025-05-24 11:08:40.289234	9	2025-07-01 06:50:29.884428	
7536	gaadimech 	8824494260	2025-07-24 00:00:00	Did Not Pick Up	Not pick \r\nNot interested mene koi inquiry nahi ki	2025-05-28 06:28:27.136561	9	2025-07-01 06:50:29.884428	
7543	gaadimech 	9509084649	2025-07-24 00:00:00	Did Not Pick Up	Busy call u later \r\nSwift 2799 till time not required 	2025-05-28 10:15:48.303283	9	2025-07-01 06:50:29.884428	
7559	gaadimech 	9314114113	2025-07-24 00:00:00	Did Not Pick Up	Switch off \r\nNot interested 	2025-05-29 05:01:17.195616	9	2025-07-01 06:50:29.884428	
7573	gaadimech	9352105938	2025-07-24 00:00:00	Needs Followup	Dzire 3000 km due hai \r\nNext month me self call krenge 	2025-05-29 08:26:23.261865	9	2025-07-01 06:50:29.884428	
7593	gaadimech 	8233305430	2025-07-24 00:00:00	Did Not Pick Up	Not pick \r\nNot interested 	2025-05-30 04:37:01.429489	9	2025-07-01 06:50:29.884428	
7660	GaadiMech 	9828475543	2025-07-24 00:00:00	Did Not Pick Up	By mistak inquiry ki hai 	2025-06-01 05:06:08.338952	9	2025-07-01 06:50:29.884428	
270	.	9799885575	2025-07-24 00:00:00	Needs Followup	Busy \r\nNot pick	2024-11-25 11:02:09	9	2025-07-01 06:50:29.884428	
313	Coustmer	9782624585	2025-07-24 00:00:00	Needs Followup	Abhi Dehli hu Jaipur aake call kr lungi\r\nNot connect 	2024-11-26 11:07:04	9	2025-07-01 06:50:29.884428	
355	.	9314666667	2025-07-24 00:00:00	Needs Followup	Not interested cut a call \r\nCut a call 	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
536	.	9829007557	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-11-28 12:42:48	9	2025-07-01 06:50:29.884428	
579	.	9929094862	2025-07-24 00:00:00	Needs Followup	Not interested & cut a call	2024-11-30 07:06:42	9	2025-07-01 06:50:29.884428	
778	Farid khan	7014628700	2025-07-24 00:00:00	Needs Followup	Amaze 2899	2024-12-02 04:50:36	9	2025-07-01 06:50:29.884428	
1689	.	8826911077	2025-07-24 00:00:00	Needs Followup	Not pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1690	.	8949446297	2025-07-24 00:00:00	Needs Followup	Not requirement \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1691	.	7297920661	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1692	.	9982181581	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nBusy call u letter 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1694	.	7891032124	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1695	.	8268120084	2025-07-24 00:00:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1696	.	8264534767	2025-07-24 00:00:00	Needs Followup	Switch off 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1698	.	9828016661	2025-07-24 00:00:00	Needs Followup	Not pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1700	.	9829098450	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1701	.	9574003171	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1702	.	7413000019	2025-07-24 00:00:00	Needs Followup	Call not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	
1703	.	7742185499	2025-07-24 00:00:00	Needs Followup	Not interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1704	Amit jain	9887067337	2025-07-24 00:00:00	Needs Followup	Call cut	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1705	.	9879203171	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1706	.	9667877771	2025-07-24 00:00:00	Needs Followup	Not requirement 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1707	.	8208692691	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1708	.	8946894104	2025-07-24 00:00:00	Needs Followup	Not requirement 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1709	.	9017657000	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1710	.	7627021263	2025-07-24 00:00:00	Needs Followup	Switch off \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1711	.	9503841580	2025-07-24 00:00:00	Needs Followup	Not requirement 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1712	.	9785548698	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1713	.	7768052371	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut\r\nCall not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1714	.	8386050492	2025-07-24 00:00:00	Needs Followup	Not interested & cut a call \r\nCall cut\r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1715	.	9782892042	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1716	.	9555177765	2025-07-24 00:00:00	Needs Followup	Not requirement \r\nNot interested \r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1717	.	9251691172	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1725	.	9829843013	2025-07-24 00:00:00	Needs Followup	Not requirement 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1730	.	7665371760	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1731	Mohit sir	7742152759	2025-07-24 00:00:00	Needs Followup	Not requirement 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1736	.	7976101600	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1738	.	9664274561	2025-07-24 00:00:00	Needs Followup	Call not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1744	.	9983078166	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1746	.	9972309185	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1747	.	9694089015	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1748	.	8112240791	2025-07-24 00:00:00	Needs Followup	Not interested & cut a call \r\nNote interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1749	.	9414498283	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1751	.	9799654996	2025-07-24 00:00:00	Needs Followup	Call cut\r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1752	.	9828224987	2025-07-24 00:00:00	Needs Followup	Call not pick\r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1754	.	7665011150	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot interested 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1756	.	7499835374	2025-07-24 00:00:00	Needs Followup	Call not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1757	.	8979995959	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1759	.	7728809159	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1760	.	9887367303	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1761	.	9602998844	2025-07-24 00:00:00	Needs Followup	Not requirement \r\nNot pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1762	.	9414883100	2025-07-24 00:00:00	Needs Followup	Call not pick 	2024-12-13 04:40:11	9	2025-07-01 06:50:29.884428	\N
1764	.	9887172121	2025-07-24 00:00:00	Needs Followup	Not interested \r\nCall back after 20 days	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1765	.	9887172121	2025-07-24 00:00:00	Needs Followup	Not interested \r\nCall back after 20 dayes	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1766	.	7014373797	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1767	.	9910343294	2025-07-24 00:00:00	Needs Followup	Call not pick \r\nNot interested \r\n	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1769	.	9460789138	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1770	.	9829239892	2025-07-24 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1771	.	9252279720	2025-07-24 00:00:00	Needs Followup	Cut a call 	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1775	.	9024339500	2025-07-25 00:00:00	Needs Followup	Service done by company	2024-12-13 10:36:16	9	2025-07-01 06:50:29.884428	\N
1813	.	7414801010	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1814	.	9414252548	2025-07-25 00:00:00	Needs Followup	Not interested 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1815	.	9950278590	2025-07-25 00:00:00	Needs Followup	Not interested \r\nNot interested \r\nCall cut	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1816	.	9887594724	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1817	.	8696733082	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nService done by other workshop	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1818	.	8005878480	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1819	.	9982222590	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1820	.	9166284546	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot interested \r\nNot interested 	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1821	.	9351808743	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 07:02:01	9	2025-07-01 06:50:29.884428	\N
1823	Neni chand	9610600999	2025-07-25 00:00:00	Needs Followup	Dzire 2899 WhatsApp package shared  self call back	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1824	.	9950116999	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1825	.	7014840414	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1826	.	9829397170	2025-07-25 00:00:00	Needs Followup	Cut a call\r\nNot pick\r\nNot pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1829	.	8006829000	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1830	.	7976998854	2025-07-25 00:00:00	Needs Followup	Not pic\r\nnot pick\r\nNot pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	
1832	.	9829025698	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1833	.	7597457458	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1834	.	9784978006	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1835	.	8209103571	2025-07-25 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1836	.	7220090508	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1837	.	9901499883	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot requirement 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
2629	Ramesh	7726818144	2025-07-25 00:00:00	Needs Followup	Not pick	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2766	Customer	9829972087	2025-07-25 00:00:00	Needs Followup	Figo 2599 detail share kar do	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2836	Customer	9829017688	2025-07-25 00:00:00	Needs Followup	Switch off 	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
3183	Customer	9571741565	2025-07-25 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3193	Customer	7263086665	2025-07-25 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3262	customer 	8302055339	2025-07-25 00:00:00	Needs Followup	Not pick 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3348	Customer 	7065892524	2025-07-25 00:00:00	Needs Followup	Call cut\r\nDutson go dant pant tail light \r\nCall cut	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3359	customer 	9410967003	2025-07-25 00:00:00	Needs Followup	Switch off 	2025-01-24 04:17:20.62172	9	2025-07-01 06:50:29.884428	
3427	.	9929659423	2025-07-25 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3504	.	8505073123	2025-07-25 00:00:00	Needs Followup	Busy call u later 	2025-01-29 04:21:05.939388	9	2025-07-01 06:50:29.884428	
4985	Dinesh 	9509895971	2025-07-25 00:00:00	Needs Followup	Was busy 	2025-03-24 07:41:19.026532	9	2025-07-01 06:50:29.884428	
4986	Customer 	9413196645	2025-07-25 00:00:00	Needs Followup	Didn't pick up the call \r\n	2025-03-24 07:44:17.685337	9	2025-07-01 06:50:29.884428	
5001	Pradeep 	9968446487	2025-07-25 00:00:00	Needs Followup	Call back 	2025-03-24 08:57:05.598541	9	2025-07-01 06:50:29.884428	
5002	Surendra Kumar 	9252486575	2025-07-25 00:00:00	Needs Followup	Cx said that he is not using the cars	2025-03-24 08:59:32.900036	9	2025-07-01 06:50:29.884428	
5003	Shivam	8178730003	2025-07-25 00:00:00	Needs Followup	Not interested 	2025-03-24 09:00:40.986553	9	2025-07-01 06:50:29.884428	
5005	Mahipal Singh 	8837204131	2025-07-25 00:00:00	Needs Followup	Call back later 	2025-03-24 09:05:31.345174	9	2025-07-01 06:50:29.884428	
5006	Mahipal Singh 	8837204131	2025-07-25 00:00:00	Needs Followup	Call back later 	2025-03-24 09:05:33.522529	9	2025-07-01 06:50:29.884428	
5007	Mohit 	9829936112	2025-07-25 00:00:00	Needs Followup	Not interested 	2025-03-24 09:06:08.050856	9	2025-07-01 06:50:29.884428	
5047	Anuj	9799904150	2025-07-25 00:00:00	Needs Followup	Not interested 	2025-03-25 07:53:42.640923	9	2025-07-01 06:50:29.884428	
5095	gaadimech 	8306835666	2025-07-25 00:00:00	Needs Followup	Ciaz dent paint 2499	2025-03-26 09:17:36.787102	9	2025-07-01 06:50:29.884428	
1838	.	7015293411	2025-07-25 00:00:00	Needs Followup	Not requirement 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1839	.	9928354172	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot connect 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1840	.	9414371558	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1841	.	7905418206	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1842	.	9829067590	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot interested 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1843	.	9871954447	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1844	.	9694834401	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1845	.	9079015164	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1846	.	7615804152	2025-07-25 00:00:00	Needs Followup	Not reacheble \r\nNo need	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1847	.	9829288231	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1848	.	9314504161	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1849	.	9314504161	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nCall cut	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1850	.	9468691813	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1851	.	9829012007	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1852	.	9829077724	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1853	.	9716011220	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1854	.	9799573090	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nCall cut\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1855	.	7728824350	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1856	.	9982283338	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1857	.	7976462393	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1858	.	7689000555	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1860	.	9971591779	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1861	.	9910747817	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1862	.	7891772552	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	
1863	.	8107088857	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1864	.	7073631073	2025-07-25 00:00:00	Needs Followup	Not requirement 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1865	.	9351508086	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1866	.	8696574754	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	
1867	.	9783696600	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1868	.	9370529265	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nDon't have car 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1869	Mohit sir 	8692973000	2025-07-25 00:00:00	Needs Followup	Busy call u letter\r\nBusy call u letter \r\nCall back next week\r\n	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1870	.	9828148088	2025-07-25 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot connect \r\nDon't have car	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1871	.	9462585133	2025-07-25 00:00:00	Needs Followup	Not interested 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1872	.	9929935605	2025-07-25 00:00:00	Needs Followup	Not requirement 	2024-12-14 09:01:08	9	2025-07-01 06:50:29.884428	\N
1873	Bacchan sir	9784297799	2025-07-25 00:00:00	Needs Followup	Om toyata service par di h	2024-12-14 12:11:31	9	2025-07-01 06:50:29.884428	\N
1874	.	9414642749	2025-07-25 00:00:00	Needs Followup	Switch off \r\nSwitch off\r\nSwitch off 	2024-12-14 12:11:31	9	2025-07-01 06:50:29.884428	\N
1875	.	7073760165	2025-07-25 00:00:00	Needs Followup	Cut a call .not pick\r\nNot pick	2024-12-14 12:11:31	9	2025-07-01 06:50:29.884428	\N
1878	.	6377808020	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-14 12:39:55	9	2025-07-01 06:50:29.884428	\N
1879	.	8003494033	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-14 12:39:55	9	2025-07-01 06:50:29.884428	\N
1881	.	8740050505	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nCall back 4 oclock\r\nDzire 2699	2024-12-14 12:39:55	9	2025-07-01 06:50:29.884428	\N
1882	.	9873133731	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nCall cut\r\nNot pick	2024-12-14 12:39:55	9	2025-07-01 06:50:29.884428	\N
1888	.	9814992080	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1889	.	8302055339	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1891	.	9828166669	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1892	.	9466887876	2025-07-25 00:00:00	Needs Followup	Not interested & cut a call \r\nCall cut	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1893	.	9950999139	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot interested 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1894	.	7023388228	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nKushaq 5499	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1895	.	8005505242	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1897	.	6375174907	2025-07-25 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1898	.	8952015577	2025-07-25 00:00:00	Needs Followup	Call not pick\r\nS cross 5499 package share\r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1899	Sandeep sir Swift dzire 	9509443080	2025-07-25 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1900	.	9727579090	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1901	.	7793008902	2025-07-25 00:00:00	Needs Followup	Cut a call\r\nNot pick\r\nNot pick\r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1902	.	9785052261	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nCall cut	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1903	.	7737372824	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1904	.	7023933307	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1905	.	9636480937	2025-07-25 00:00:00	Needs Followup	Cut a call 	2024-12-15 04:52:15	9	2025-07-01 06:50:29.884428	\N
1906	.	9414045253	2025-07-25 00:00:00	Needs Followup	Not requirement 	2024-12-15 07:24:02	9	2025-07-01 06:50:29.884428	\N
1907	.	9414045253	2025-07-25 00:00:00	Needs Followup	Not pick\r\nNot requirement 	2024-12-15 07:24:02	9	2025-07-01 06:50:29.884428	\N
1908	.	7339770333	2025-07-25 00:00:00	Needs Followup	Not interested \r\nNot pick 	2024-12-15 07:24:02	9	2025-07-01 06:50:29.884428	\N
1909	.	9636810154	2025-07-25 00:00:00	Needs Followup	Xuv 300 package 3299\r\n	2024-12-15 07:24:02	9	2025-07-01 06:50:29.884428	\N
1910	.	7976161822	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-15 07:24:02	9	2025-07-01 06:50:29.884428	\N
1912	.	8209786382	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-15 08:12:05	9	2025-07-01 06:50:29.884428	\N
1913	.	8209786382	2025-07-25 00:00:00	Needs Followup	Call not pick 	2024-12-15 08:12:05	9	2025-07-01 06:50:29.884428	\N
1914	.	9269875555	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-15 08:12:05	9	2025-07-01 06:50:29.884428	\N
1915	Abdul sir	9636524340	2025-07-25 00:00:00	Needs Followup	Call back 	2024-12-15 08:36:05	9	2025-07-01 06:50:29.884428	\N
1916	.	7690934194	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-15 08:36:05	9	2025-07-01 06:50:29.884428	\N
1917	.	9928138601	2025-07-25 00:00:00	Needs Followup	Not requirement 	2024-12-15 09:48:48	9	2025-07-01 06:50:29.884428	\N
1918	.	9828708673	2025-07-25 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-15 09:48:48	9	2025-07-01 06:50:29.884428	\N
1919	.	9829075969	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-15 09:48:48	9	2025-07-01 06:50:29.884428	\N
1920	.	9828121319	2025-07-25 00:00:00	Needs Followup	Cut a call \r\nXuv 300 3699\r\nNot interested 	2024-12-15 09:48:48	9	2025-07-01 06:50:29.884428	\N
1921	.	7230039946	2025-07-25 00:00:00	Needs Followup	Not reachable \r\nNot pick\r\nNot pick	2024-12-15 10:29:25	9	2025-07-01 06:50:29.884428	\N
1922	.	7230039946	2025-07-25 00:00:00	Needs Followup	Not reachable \r\nNot pick\r\nNot pick	2024-12-15 10:29:25	9	2025-07-01 06:50:29.884428	\N
1924	.	8824041756	2025-07-25 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-15 10:29:25	9	2025-07-01 06:50:29.884428	\N
1925	Patiram	9261484094	2025-07-26 00:00:00	Needs Followup	WhatsApp package shared \r\n	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1926	.	9672934465	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	
1927	.	8561811556	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick \r\nNot pick	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1928	Daljit Kumar	9672349039	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1929	.	9414079397	2025-07-26 00:00:00	Needs Followup	Call back 	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1930	.	8952979833	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1931	.	9829055509	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1932	Sahil Khan	9001546472	2025-07-26 00:00:00	Needs Followup	 WhatsApp package shared 	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1933	.	9309370470	2025-07-26 00:00:00	Needs Followup	Service done by rk motirs	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1934	.	9602222054	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-15 11:32:37	9	2025-07-01 06:50:29.884428	\N
1935	.	9829054707	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1936	.	9829054707	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1937	.	9636295750	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	
1938	.	9413355006	2025-07-26 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1939	.	9414970325	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1940	.	9001033256	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1941	.	8800121643	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot requirement 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1942	.	9529872108	2025-07-26 00:00:00	Needs Followup	Cut a call & Not interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1943	.	9887005277	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1944	.	9509143523	2025-07-26 00:00:00	Needs Followup	Not requirement \r\nNot pick	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1945	.	9887666005	2025-07-26 00:00:00	Needs Followup	Not requirement \r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	
1946	.	9314934828	2025-07-26 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1947	.	9414123601	2025-07-26 00:00:00	Needs Followup	Not reachable \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1948	.	9950120122	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1949	.	9660090926	2025-07-26 00:00:00	Needs Followup	Cut a call & not interested \r\nVisit krenge  kia seltos 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1950	.	8529796625	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
287	.	8209471564	2025-07-26 00:00:00	Needs Followup	Call back \r\nNot pick 	2024-11-26 05:48:39	9	2025-07-01 06:50:29.884428	
291	Sanjay jain	9887881008	2025-07-26 00:00:00	Needs Followup	What's app details share \r\nAbe service ke requirement nahi hai\r\nnot pick	2024-11-26 08:05:43	9	2025-07-01 06:50:29.884428	
362	.	9828211400	2025-07-26 00:00:00	Needs Followup	Details share  kar do 	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
367	.	9829004555	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
369	.	9680598689	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
374	Yatindra	9649187794	2025-07-26 00:00:00	Needs Followup	Switch off	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
401	.	9829015231	2025-07-26 00:00:00	Needs Followup	Customer busy 	2024-11-27 11:01:48	9	2025-07-01 06:50:29.884428	
427	.	9667146760	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
461	.	8107300811	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
530	.	9799571579	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-11-28 06:03:20	9	2025-07-01 06:50:29.884428	
542	.	9352611671	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-11-28 12:42:48	9	2025-07-01 06:50:29.884428	
553	.........	9829058787	2025-07-26 00:00:00	Needs Followup	N.intrested	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
578	.	8005610651	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-11-30 06:34:08	9	2025-07-01 06:50:29.884428	
585	.	9314870395	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-11-30 07:06:42	9	2025-07-01 06:50:29.884428	
594	.	9314934552	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	
720	...	9929606380	2025-07-26 00:00:00	Needs Followup	Eco ka pack bheja h abhi 17 ko c.b	2024-12-01 10:44:45	9	2025-07-01 06:50:29.884428	
1951	.	9828024530	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1952	.	9828011851	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1953	.	9602897572	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1954	.	9929855292	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1955	.	9783833335	2025-07-26 00:00:00	Needs Followup	Not reachable \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	
1957	.	8005729081	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1958	.	9887777411	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1959	.	9829222334	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1960	.	9166898059	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1962	.	9571877835	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1963	.	9785505271	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1964	.	7792003239	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\n	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1965	.	9414030130	2025-07-26 00:00:00	Needs Followup	Out of network 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1966	Ankit Maheshwari	9314647148	2025-07-26 00:00:00	Needs Followup	Call back 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1967	.	9828751123	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1968	.	9928077544	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1969	.	9252571797	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1971	.	9414071334	2025-07-26 00:00:00	Needs Followup	Not reachable 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1972	.	9460003699	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1973	Sanjay Maheshwari	9414341765	2025-07-26 00:00:00	Needs Followup	Call back \r\nNot pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1975	.	8619329030	2025-07-26 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1976	.	9414056674	2025-07-26 00:00:00	Needs Followup	Only company service 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1978	.	7409083465	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot connect 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1979	.	9462671125	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1980	.	9667011111	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1981	.	9887417749	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1982	.	8058262187	2025-07-26 00:00:00	Needs Followup	Call back morning \r\nMercedes fortuner package share \r\nService done by other workshop \r\nNext time will contact you follow up date 7/1/2025\r\n\r\nCall cut	2024-12-16 05:29:02	9	2025-07-01 06:50:29.884428	\N
1983	.	7222864536	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1984	.	9610575554	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1985	.	9828922225	2025-07-26 00:00:00	Needs Followup	Call back \r\nCall cut	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1986	.	9950766665	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1987	.	9829010590	2025-07-26 00:00:00	Needs Followup	Not requirement \r\nNot interested 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1988	.	9799705879	2025-07-26 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1989	.	9782018799	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1990	.	9928356000	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nBusy call u letter \r\nNot pick	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1991	.	9784404040	2025-07-26 00:00:00	Needs Followup	Not interested 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1992	.	8619239813	2025-07-26 00:00:00	Needs Followup	Call not pick 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1993	.	9602519111	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1994	.	9414051122	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1995	.	9610018888	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1996	.	9829067084	2025-07-26 00:00:00	Needs Followup	Switch off \r\nNot interested \r\n	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1997	.	9414922886	2025-07-26 00:00:00	Needs Followup	Call back 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1998	.	9829288002	2025-07-26 00:00:00	Needs Followup	April tak visit krenge	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
1999	.	9887036065	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2000	.	9829326239	2025-07-26 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2001	.	8884377311	2025-07-26 00:00:00	Needs Followup	Not required 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2002	.	9986999626	2025-07-26 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nBusy cal u letter	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2003	.	9982933382	2025-07-26 00:00:00	Needs Followup	Not requirement 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2004	.	9214067543	2025-07-26 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2005	.	9314501712	2025-07-26 00:00:00	Needs Followup	Cut a call 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2006	.	7689987368	2025-07-26 00:00:00	Needs Followup	Call back 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2007	.	9829136028	2025-07-26 00:00:00	Needs Followup	Call back customer out of India 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2009	.	9352784439	2025-07-26 00:00:00	Needs Followup	Call cut	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2010	.	9828729035	2025-07-26 00:00:00	Needs Followup	Not reachable \r\nNot pick	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2616	Pooran singh	9815902473	2025-07-26 00:00:00	Needs Followup	Insurance Claim \r\nCall back 13 jan\r\nNot pick\r\nNot connect \r\nBanipar visist krenhe	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
4976	Customer 	9610789999	2025-07-26 00:00:00	Needs Followup	Not interested 	2025-03-24 07:15:11.923167	9	2025-07-01 06:50:29.884428	
4990	Harsh 	9829566032	2025-07-26 00:00:00	Needs Followup	Call back 	2025-03-24 08:13:09.183643	9	2025-07-01 06:50:29.884428	
4991	Amir Khan 	9875213333	2025-07-26 00:00:00	Needs Followup	Call back 	2025-03-24 08:14:02.434852	9	2025-07-01 06:50:29.884428	
4992	Kishan 	9928992988	2025-07-26 00:00:00	Needs Followup	Didn't pick up the call 	2025-03-24 08:15:06.359512	9	2025-07-01 06:50:29.884428	
5000	Tejpal singh 	9782180222	2025-07-26 00:00:00	Needs Followup	Not interested 	2025-03-24 08:56:29.382995	9	2025-07-01 06:50:29.884428	
5011	Anmol	7014298042	2025-07-26 00:00:00	Needs Followup	Disconnected 	2025-03-24 09:25:58.382428	9	2025-07-01 06:50:29.884428	
5012	Ck	9414826287	2025-07-26 00:00:00	Needs Followup	Not using four wheeler 	2025-03-24 09:33:14.139929	9	2025-07-01 06:50:29.884428	
5016	Yashdeep 	9799456000	2025-07-26 00:00:00	Needs Followup	Not required 	2025-03-24 10:49:14.791188	9	2025-07-01 06:50:29.884428	
5027	Rajesh Kumar sinha	9929184635	2025-07-26 00:00:00	Needs Followup	Disconnected \r\n	2025-03-25 06:12:14.376604	9	2025-07-01 06:50:29.884428	
5028	Dharmendra Sharma 	9929064700	2025-07-26 00:00:00	Needs Followup		2025-03-25 06:13:41.161979	9	2025-07-01 06:50:29.884428	
5029	Sanjay Kumar Goyal 	9928499737	2025-07-26 00:00:00	Needs Followup	Disconnected 	2025-03-25 06:19:03.017998	9	2025-07-01 06:50:29.884428	
5030	Rajesh Kumar Sharma 	9928499216	2025-07-26 00:00:00	Needs Followup		2025-03-25 06:19:46.340737	9	2025-07-01 06:50:29.884428	
5031	Ram pal kumawat 	9928371388	2025-07-26 00:00:00	Needs Followup	Disconnected 	2025-03-25 06:27:14.545095	9	2025-07-01 06:50:29.884428	
5032	DS chouhan 	9928363655	2025-07-26 00:00:00	Needs Followup		2025-03-25 06:30:05.692739	9	2025-07-01 06:50:29.884428	
5038	Daya shanker 	9899436663	2025-07-26 00:00:00	Needs Followup	Disconnected 	2025-03-25 07:05:04.299138	9	2025-07-01 06:50:29.884428	
5039	Anuj sood	9899137346	2025-07-26 00:00:00	Needs Followup	Disconnected 	2025-03-25 07:09:18.768104	9	2025-07-01 06:50:29.884428	
5042	Mukesh Choudhary 	9413072297	2025-07-26 00:00:00	Needs Followup		2025-03-25 07:15:56.690861	9	2025-07-01 06:50:29.884428	
5044	Surendra g	8290057009	2025-07-26 00:00:00	Needs Followup	Cx said that she is busy asked to call back later 	2025-03-25 07:20:27.350274	9	2025-07-01 06:50:29.884428	
5045	Customer 	7737144445	2025-07-26 00:00:00	Needs Followup	Cx was from jodhpur 	2025-03-25 07:33:27.992179	9	2025-07-01 06:50:29.884428	
5046	Customer 	9924076529	2025-07-27 00:00:00	Needs Followup	Jodhpur se hai	2025-03-25 07:36:03.821669	9	2025-07-01 06:50:29.884428	
5048	Jitendra 	9664360116	2025-07-27 00:00:00	Needs Followup	Car owner was not available \r\n	2025-03-25 09:02:26.340075	9	2025-07-01 06:50:29.884428	
5050	Ashish 	9828029918	2025-07-27 00:00:00	Needs Followup	Cx himself was not available \r\n	2025-03-25 09:13:41.739153	9	2025-07-01 06:50:29.884428	
5053	Suresh ji 	9829236820	2025-07-27 00:00:00	Needs Followup	Not interested for now 	2025-03-25 11:24:42.007256	9	2025-07-01 06:50:29.884428	
5054	Customer 	9785439439	2025-07-27 00:00:00	Needs Followup		2025-03-25 11:25:50.367099	9	2025-07-01 06:50:29.884428	
5056	Pawan Kumar 	9828768488	2025-07-27 00:00:00	Needs Followup	Not interested \r\n	2025-03-25 11:28:14.846563	9	2025-07-01 06:50:29.884428	
5059	Customer 	7820971999	2025-07-27 00:00:00	Needs Followup		2025-03-25 11:31:33.874465	9	2025-07-01 06:50:29.884428	
5060	Customer 	9636675857	2025-07-27 00:00:00	Needs Followup		2025-03-25 11:32:03.508106	9	2025-07-01 06:50:29.884428	
5061	Customer 	9694144420	2025-07-27 00:00:00	Needs Followup	Gi10 2699	2025-03-25 12:09:43.202239	9	2025-07-01 06:50:29.884428	
5153	Customer 	9602468426	2025-07-27 00:00:00	Needs Followup		2025-03-27 07:20:49.727413	9	2025-07-01 06:50:29.884428	
224	Dr.naim	9251670095	2025-07-27 00:00:00	Needs Followup	3399 sarvice pack but ye pahle visit krenge Hyundai venu/abhi Mera beta bimar h 4 ya 5 din bad m khud call krunga/ uske thik hote hi/n.r\r\nNot pick	2024-11-25 07:00:05	9	2025-07-01 06:50:29.884428	
240	Dharmendra 	9829110022	2025-07-27 00:00:00	Needs Followup	Baleno dent pent diggi 3500 	2024-11-25 07:47:14	9	2025-07-01 06:50:29.884428	
322	Abhi jain	9929457666	2025-07-27 00:00:00	Needs Followup	Inko mine Honda city or grand i10 ka pack bhej rakha h but ye bol rhe h ap pise jyada le rhe ho\r\nNot pick	2024-11-26 11:18:40	9	2025-07-01 06:50:29.884428	
324	Ravi vilash ji	9587904490	2025-07-27 00:00:00	Needs Followup	Abhi udaipur hu m 29 ko udaipur se aaunga ap dophar ke bad call kr lena	2024-11-26 11:21:23	9	2025-07-01 06:50:29.884428	
381	.	7600021337	2025-07-27 00:00:00	Needs Followup	Not pick	2024-11-27 07:21:40	9	2025-07-01 06:50:29.884428	
557	....	9829053742	2025-07-27 00:00:00	Needs Followup	N r 	2024-11-29 07:12:53	9	2025-07-01 06:50:29.884428	
573	Ashok sir	9829115533	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-11-30 05:56:38	9	2025-07-01 06:50:29.884428	
575	Sohanlal ji	9887308997	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick	2024-11-30 05:56:38	9	2025-07-01 06:50:29.884428	
589	.	9251023568	2025-07-27 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-11-30 08:40:31	9	2025-07-01 06:50:29.884428	
611	Shivraj Gurjar	9116436812	2025-07-27 00:00:00	Needs Followup	Full body dent pent h	2024-11-30 09:37:30	9	2025-07-01 06:50:29.884428	
2011	.	7073565444	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2013	.	7878984525	2025-07-27 00:00:00	Needs Followup	Switch off 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2014	.	9660974454	2025-07-27 00:00:00	Needs Followup	Not interested \r\nNot pick 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2015	.	8003325999	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2016	.	9351833251	2025-07-27 00:00:00	Needs Followup	Call back out of Jaipur \r\nNot requirement 	2024-12-16 08:42:22	9	2025-07-01 06:50:29.884428	\N
2017	.	9413395179	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nOut of jaipur	2024-12-16 10:42:16	9	2025-07-01 06:50:29.884428	\N
2019	.	8005707098	2025-07-27 00:00:00	Needs Followup	Scorpio 4699 package share call back fab mid week	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	
2020	.	7726005858	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick\r\nNot pick	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2021	.	9829605518	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2022	.	8949663476	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2023	.	9967110003	2025-07-27 00:00:00	Needs Followup	Call cut\r\nNot pick	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2024	.	9214466316	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2025	.	9950353538	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2026	.	9314733777	2025-07-27 00:00:00	Needs Followup	Cut a call 	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2027	Abhishek pareek 	9785060606	2025-07-27 00:00:00	Needs Followup	Call not pick	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2028	.	9891496800	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nLast month service done	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2030	.	8094158390	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick\r\nNot ick	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2031	Nilesh Sharma	7230018309	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-16 11:12:10	9	2025-07-01 06:50:29.884428	\N
2033	.	7014993036	2025-07-27 00:00:00	Needs Followup	Not requirement \r\nNot pick 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2034	.	7014993034	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nDon't have car\r\nNot pick 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2035	.	9460148221	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nCall in evening 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2036	.	8118831648	2025-07-27 00:00:00	Needs Followup	Not requirement \r\nNot interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2037	.	7790871219	2025-07-27 00:00:00	Needs Followup	Call not pick\r\nNot interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2038	.	9636963625	2025-07-27 00:00:00	Needs Followup	Switch off \r\nSwitch off 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2039	.	9166467678	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2041	.	9928304265	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2042	.	9649977770	2025-07-27 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2044	.	9829004047	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2045	.	9829004343	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2046	Sandeep Choudhary 	8963053450	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared call back January \r\nNot pick 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2047	.	9636419806	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2048	.	9829004103	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2049	.	9829072772	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2050	.	9829072772	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2051	.	9887070556	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 04:46:57.631691	9	2025-07-01 06:50:29.884428	\N
2052	Piyush sir vento	9829004606	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2053	.	9887977233	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2054	.	9828021848	2025-07-27 00:00:00	Needs Followup	Only company me service \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2056	.	9982030006	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2058	.	8130400511	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2059	.	9166873801	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2060	.	9413445008	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2061	.	9414070007	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2062	.	9983301949	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2063	Jaikant sir	7737503497	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick\r\n\r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2064	.	8560092222	2025-07-27 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2065	.	9549776364	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2066	.	9828530724	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2068	.	9785981557	2025-07-27 00:00:00	Needs Followup	Cut a call 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2070	.	9414042590	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nDon't have car	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	
2072	B.s meena 	9001199233	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2073	.	9413631844	2025-07-27 00:00:00	Needs Followup	Not interested \r\nNot pick\r\nBusy call u letter\r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2074	.	9928736993	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2075	.	8826250006	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2076	.	9660100767	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2077	.	9001033456	2025-07-27 00:00:00	Needs Followup	Switch off 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2078	.	9829013355	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2079	.	9871116712	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nWagnor service done 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2080	.	8875611110	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2081	.	9610030036	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2082	.	7742674444	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2083	.	9414312768	2025-07-27 00:00:00	Needs Followup	Cut a call 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2084	.	9928766033	2025-07-27 00:00:00	Needs Followup	Switch off 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2085	.	9828031718	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2086	.	9829056676	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2087	.	9928222228	2025-07-27 00:00:00	Needs Followup	Cut a call 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2088	.	9413285378	2025-07-27 00:00:00	Needs Followup	Tata tiyago2799\r\n	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2089	.	9828505858	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2090	.	8561024179	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut\r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2091	.	9414061527	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2092	.	9571404001	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2093	.	9680846021	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2095	.	9829287512	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2097	.	7073131999	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2098	.	9413804099	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot Requirement \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2099	.	9829544944	2025-07-27 00:00:00	Needs Followup	Cut a call 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2100	Manish Singhania 	9314500836	2025-07-27 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2101	.	9828133334	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot picknot requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2102	.	9694913313	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick \r\nNot pick	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2103	.	9829021033	2025-07-27 00:00:00	Needs Followup	Call not pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2104	.	9785090319	2025-07-27 00:00:00	Needs Followup	Not interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2105	.	9928023690	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2106	.	9001821286	2025-07-27 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2107	.	7568904507	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nCall cut	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2108	.	9829104526	2025-07-27 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2109	.	9829004775	2025-07-27 00:00:00	Needs Followup	Not requirement 	2024-12-17 07:03:37.548744	9	2025-07-01 06:50:29.884428	\N
2617	Gourang 	9829927370	2025-07-27 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNo need	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2647	Aakash	9929751301	2025-07-27 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick\r\nNot pick 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2656	Sakhawat ullah	9314832091	2025-07-27 00:00:00	Needs Followup	Not interested 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2657	Sakhawat ullah	8955142813	2025-07-27 00:00:00	Needs Followup	TRIBER 2999 \r\nDrycleaning 1500\r\nSame package mjhe reno 2199 ka deta hai 	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
2729	Raj	9414743390	2025-07-27 00:00:00	Needs Followup	Not connect 	2025-01-08 11:00:12.657946	9	2025-07-01 06:50:29.884428	
2738	Customer	6367980802	2025-07-27 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 04:06:43.856234	9	2025-07-01 06:50:29.884428	
2761	Customer	7891175757	2025-07-27 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2785	Customer	9887626552	2025-07-27 00:00:00	Needs Followup	Call cut	2025-01-09 08:07:34.075518	9	2025-07-01 06:50:29.884428	
2818	Cx170	8764069111	2025-07-27 00:00:00	Needs Followup	i20 \r\nExcel repair	2025-01-11 04:14:05.019885	9	2025-07-01 06:50:29.884428	
2899	Customer	9887878234	2025-07-27 00:00:00	Needs Followup	Not pick \r\nNot interested 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2911	Customer	7727017777	2025-07-28 00:00:00	Needs Followup	Not pick\r\nSwitch off \r\nNot pick	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2933	Customer	9571612222	2025-07-28 00:00:00	Needs Followup	Not requirement 	2025-01-12 04:36:11.819946	9	2025-07-01 06:50:29.884428	
2993	Customer	8529579110	2025-07-28 00:00:00	Needs Followup	Not pick\r\nNot pick\r\nNot pick 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3004	Customer	9414294459	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3031	Customer	9928900546	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3033	Customer	9828079341	2025-07-28 00:00:00	Needs Followup	Not required 	2025-01-13 09:02:24.989067	9	2025-07-01 06:50:29.884428	
3079	Customer	9024896569	2025-07-28 00:00:00	Needs Followup	Switch off \r\nNot connect 	2025-01-16 05:05:21.020106	9	2025-07-01 06:50:29.884428	
3101	Customer	7340464790	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3105	Customer	8875486351	2025-07-28 00:00:00	Needs Followup	Not pick\r\nNot pick \r\nNot interested 	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3120	Customer	9351757430	2025-07-28 00:00:00	Needs Followup	Kwid dant paint 22000	2025-01-18 04:23:45.326649	9	2025-07-01 06:50:29.884428	
3153	Customer	8209154365	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3171	Customer	9928469066	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3184	Customer	9829070593	2025-07-28 00:00:00	Needs Followup	Not pick \r\nNot pick	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3201	Customer	9928330766	2025-07-28 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3205	Customer	9799904150	2025-07-28 00:00:00	Needs Followup	Not interested 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3227	Customer 	7768052371	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3233	customer 	9694057690	2025-07-28 00:00:00	Needs Followup	Call cut\r\nAbhi koi requirement nhi hai	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3237	customer 	9009575650	2025-07-28 00:00:00	Needs Followup	Switch off 	2025-01-20 04:31:19.397625	9	2025-07-01 06:50:29.884428	
3266	.	9950358333	2025-07-28 00:00:00	Needs Followup	Not pick \r\nNot pick 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3267	customer 	9828501494	2025-07-28 00:00:00	Needs Followup	Not pick \r\nNot interested 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3274	customer 	9819837292	2025-07-28 00:00:00	Needs Followup	Not interested 	2025-01-20 12:02:14.345371	9	2025-07-01 06:50:29.884428	
3301	.	9314500581	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-21 10:55:25.845211	9	2025-07-01 06:50:29.884428	
3391	.	9983000075	2025-07-28 00:00:00	Needs Followup	Not interested 	2025-01-25 04:07:13.578442	9	2025-07-01 06:50:29.884428	
3456	.	9983078166	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-01-26 09:16:05.01535	9	2025-07-01 06:50:29.884428	
3468	.	9079610234	2025-07-28 00:00:00	Needs Followup		2025-01-27 04:07:45.870122	9	2025-07-01 06:50:29.884428	
3486	.	6376154830	2025-07-28 00:00:00	Needs Followup	Figo full dent paint 28000 \r\nPer penal 2400\r\nAbhi koi plan nhi h sirf inquiry ki h	2025-01-28 04:24:52.747688	9	2025-07-01 06:50:29.884428	
3496	gaadimech 	9785903504	2025-07-28 00:00:00	Needs Followup	Magnet dent paint per penal 2500\r\nNot pick	2025-01-28 06:07:51.486916	9	2025-07-01 06:50:29.884428	
3498	.	9772791501	2025-07-28 00:00:00	Needs Followup	Xuv 500 dent paint visit today	2025-01-28 06:07:51.486916	9	2025-07-01 06:50:29.884428	
3514	.	9129313745	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-01-29 08:32:50.939274	9	2025-07-01 06:50:29.884428	
3570	.	9829029190	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3574	.	9928191900	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3578	.	9829069648	2025-07-28 00:00:00	Needs Followup	Not interested 	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3580	.	9829057766	2025-07-28 00:00:00	Needs Followup	Call cut	2025-01-31 11:39:32.99819	9	2025-07-01 06:50:29.884428	
3623	.	9829019889	2025-07-28 00:00:00	Needs Followup	Not pick	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3625	.	9829011188	2025-07-28 00:00:00	Needs Followup	Switch off 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3633	.	9001093010	2025-07-28 00:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3635	.	9829052155	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3654	.	9314033669	2025-07-28 00:00:00	Needs Followup	Don't have car 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3683	.	9694096944	2025-07-28 00:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3687	.	9943720959	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3691	.	8764590591	2025-07-28 00:00:00	Needs Followup	Not valid no	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3732	.	9727579090	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-02-05 08:03:10.877726	9	2025-07-01 06:50:29.884428	
3802	.	9024671337	2025-07-28 00:00:00	Needs Followup	Not pick 	2025-02-07 04:30:18.562584	9	2025-07-01 06:50:29.884428	
3920	Cx290	8696329270	2025-07-28 00:00:00	Needs Followup	Xuv 4999	2025-02-08 09:29:45.833161	9	2025-07-01 06:50:29.884428	
3931	Cx301	7674892681	2025-07-28 00:00:00	Needs Followup	Car service aur dent paint 	2025-02-08 10:04:16.891459	9	2025-07-01 06:50:29.884428	
3941	Cx309	7073000520	2025-07-28 00:00:00	Needs Followup	Service 	2025-02-09 11:12:23.29799	9	2025-07-01 06:50:29.884428	
3967	.	9829016903	2025-07-28 00:00:00	Needs Followup	Don't have car 	2025-02-12 08:18:39.780812	9	2025-07-01 06:50:29.884428	
3972	.	8000018823	2025-07-28 00:00:00	Needs Followup	Don't have car 	2025-02-12 08:58:53.726053	9	2025-07-01 06:50:29.884428	
4137	Cx303	9588082879	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 06:24:33.786858	9	2025-07-01 06:50:29.884428	
4147	Cx409	9999369933	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 06:57:36.004599	9	2025-07-01 06:50:29.884428	
4154	Cx415	8209675581	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 07:04:53.373379	9	2025-07-01 06:50:29.884428	
4158	Cx418	7665819814	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 07:09:41.725535	9	2025-07-01 06:50:29.884428	
4161	Cx421	9414991973	2025-07-28 00:00:00	Needs Followup	i20 bumper\r\nPaint 	2025-02-18 07:11:27.732345	9	2025-07-01 06:50:29.884428	
4165	Cx425	6376769897	2025-07-28 00:00:00	Needs Followup	Call cut 	2025-02-18 07:14:28.61063	9	2025-07-01 06:50:29.884428	
4168	Cx427	8003691200	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 07:18:50.395387	9	2025-07-01 06:50:29.884428	
4170	Cx427	9413737700	2025-07-28 00:00:00	Needs Followup	Dzire \r\nBumper new \r\nPaint 2200	2025-02-18 07:21:35.888578	9	2025-07-01 06:50:29.884428	
4172	Cx429	8505029629	2025-07-28 00:00:00	Needs Followup	Dent paint 	2025-02-18 07:22:55.119938	9	2025-07-01 06:50:29.884428	
4180	Cx450	9829506037	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-18 10:02:53.144586	9	2025-07-01 06:50:29.884428	
4215	.	8875699641	2025-07-28 00:00:00	Needs Followup	Don't have car 	2025-02-18 12:06:21.021266	9	2025-07-01 06:50:29.884428	
4236	Cx449	7202850082	2025-07-28 00:00:00	Needs Followup	Call cut	2025-02-19 07:58:10.428598	9	2025-07-01 06:50:29.884428	
4237	Cx450	7023849084	2025-07-28 00:00:00	Needs Followup	Alto ac problem 	2025-02-19 07:59:48.444663	9	2025-07-01 06:50:29.884428	
4256	Cx504	6350353310	2025-07-28 00:00:00	Needs Followup	No answer 	2025-02-21 11:09:13.999866	9	2025-07-01 06:50:29.884428	
4259	Cx510	8302719014	2025-07-28 00:00:00	Needs Followup	Dent paint 	2025-02-21 11:39:22.918105	9	2025-07-01 06:50:29.884428	
4260	CX  511	9928333373	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-21 11:46:43.281991	9	2025-07-01 06:50:29.884428	
4264	Cx515	8951650584	2025-07-28 00:00:00	Needs Followup	Ac gas 	2025-02-21 12:28:28.608285	9	2025-07-01 06:50:29.884428	
4289	Cx514	7597665376	2025-07-28 00:00:00	Needs Followup	Wr service 2199	2025-02-22 08:45:37.473025	9	2025-07-01 06:50:29.884428	
4290	Cx514	9664382894	2025-07-28 00:00:00	Needs Followup	Service 	2025-02-22 08:47:05.115676	9	2025-07-01 06:50:29.884428	
4310	Cx520	7976011237	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-23 11:47:21.503704	9	2025-07-01 06:50:29.884428	
4311	Cx521	8696792966	2025-07-28 00:00:00	Needs Followup	Kwid \r\nDent paint 	2025-02-23 11:49:05.61816	9	2025-07-01 06:50:29.884428	
4312	Cx521	9636387396	2025-07-28 00:00:00	Needs Followup	Service 	2025-02-23 12:48:31.580765	9	2025-07-01 06:50:29.884428	
4313	Cx522	9887048723	2025-07-28 00:00:00	Needs Followup	Ac gas service \r\n	2025-02-23 12:49:36.226189	9	2025-07-01 06:50:29.884428	
4315	Cx528	9813575274	2025-07-28 00:00:00	Needs Followup	Dent paint 	2025-02-23 12:51:15.791223	9	2025-07-01 06:50:29.884428	
4317	Cx528	7410866867	2025-07-28 00:00:00	Needs Followup	In coming nahi \r\nVoice call 	2025-02-23 13:04:04.425901	9	2025-07-01 06:50:29.884428	
4318	Cx 530	9829924028	2025-07-28 00:00:00	Needs Followup	i10 ac service \r\nSharp motors 	2025-02-23 13:05:57.354728	9	2025-07-01 06:50:29.884428	
4319	Cx530	9509239761	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-23 13:07:11.98259	9	2025-07-01 06:50:29.884428	
4321	Cx532	9116445549	2025-07-28 00:00:00	Needs Followup	Swift Dzire \r\nDent paint 	2025-02-23 13:09:44.034452	9	2025-07-01 06:50:29.884428	
4322	Cx534	8094946654	2025-07-28 00:00:00	Needs Followup	Polo \r\nDent paint 	2025-02-23 13:10:21.363883	9	2025-07-01 06:50:29.884428	
4324	Cx535	8875700666	2025-07-28 00:00:00	Needs Followup	Car service \r\nNo answer 	2025-02-23 13:12:54.64834	9	2025-07-01 06:50:29.884428	
4325	Cx540	8580796699	2025-07-28 00:00:00	Needs Followup	Car service \r\nHoli ke baad	2025-02-23 13:13:52.635991	9	2025-07-01 06:50:29.884428	
4326	CX532	9414077509	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-23 13:14:52.496996	9	2025-07-01 06:50:29.884428	
4327	Cx531	9460386739	2025-07-28 00:00:00	Needs Followup	Baleno \r\nDent paint 	2025-02-23 13:15:38.947275	9	2025-07-01 06:50:29.884428	
4328	Cx532	9928950000	2025-07-28 00:00:00	Needs Followup	Sunny \r\nDent paint 	2025-02-23 13:16:36.506474	9	2025-07-01 06:50:29.884428	
4330	Cx540	9929028068	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-23 13:23:17.699039	9	2025-07-01 06:50:29.884428	
4331	Cx542	7737487747	2025-07-28 00:00:00	Needs Followup	Car service 	2025-02-23 13:23:44.782115	9	2025-07-01 06:50:29.884428	
4360	Cx534	7023965996	2025-07-28 00:00:00	Needs Followup	Skoda 3599	2025-02-25 08:25:08.146719	9	2025-07-01 06:50:29.884428	
4361	Cx534	8302468480	2025-07-28 00:00:00	Needs Followup	Car service \r\n	2025-02-25 08:26:02.92721	9	2025-07-01 06:50:29.884428	
4362	Cx535	8233531993	2025-07-28 00:00:00	Needs Followup	Audi car service 	2025-02-25 08:27:01.614355	9	2025-07-01 06:50:29.884428	
4363	Cx537	7339745594	2025-07-28 00:00:00	Needs Followup	Skoda service 	2025-02-25 08:27:37.708714	9	2025-07-01 06:50:29.884428	
4365	Cx539	8112246446	2025-07-28 00:00:00	Needs Followup	Creta \r\nDent paint 	2025-02-25 09:04:34.362643	9	2025-07-01 06:50:29.884428	
4403	Cx561	8306643903	2025-07-28 00:00:00	Needs Followup	Tata punch 3199	2025-02-26 08:21:05.067302	9	2025-07-01 06:50:29.884428	
4404	Cx562	9808424008	2025-07-28 00:00:00	Needs Followup	Honda city \r\nCar service aur ac	2025-02-26 08:24:37.190822	9	2025-07-01 06:50:29.884428	
4406	Cx563	9929944244	2025-07-28 00:00:00	Needs Followup	Bumper paint  \r\nAjmer se 	2025-02-26 09:00:33.841424	9	2025-07-01 06:50:29.884428	
4420	Wr 2199	7792072687	2025-07-28 00:00:00	Needs Followup	Wr service \r\n2199	2025-02-27 05:16:11.262957	9	2025-07-01 06:50:29.884428	
4423	Cx5564	7611066682	2025-07-28 00:00:00	Needs Followup	Drycleaning 	2025-02-27 06:38:08.163467	9	2025-07-01 06:50:29.884428	
358	.	9660260264	2025-07-28 00:00:00	Did Not Pick Up	Service alredy done repid skoda	2024-11-27 05:30:57	9	2025-07-01 06:50:29.884428	
3876	.	8058593934	2025-07-28 00:00:00	Did Not Pick Up	Not required already service done 	2025-02-07 10:20:37.99656	9	2025-07-01 06:50:29.884428	
4333	gaadimech 	8769298511	2025-07-28 00:00:00	Did Not Pick Up	Not pick \r\nNear by workshop se service karwa li 	2025-02-24 04:51:20.507087	9	2025-07-01 06:50:29.884428	
4978	Customer 	8619390490	2025-07-28 00:00:00	Needs Followup	Already done 	2025-03-24 07:21:42.888971	9	2025-07-01 06:50:29.884428	
4979	Customer 	9529599088	2025-07-28 00:00:00	Needs Followup	Already done 	2025-03-24 07:33:41.821285	9	2025-07-01 06:50:29.884428	
2111	.	9887583738	2025-07-28 00:00:00	Needs Followup	Call not pick \r\nNote interested 	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2112	.	8283833949	2025-07-28 00:00:00	Needs Followup	Switch off \r\nNot pick	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2113	.	9829373531	2025-07-28 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2114	.	9414016920	2025-07-28 00:00:00	Needs Followup	Call not pick \r\nHonda city 2999\r\nJarurat hui to contact karenge	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	
2115	.	7503013153	2025-07-28 00:00:00	Needs Followup	Call not pick 	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2116	.	7503013153	2025-07-28 00:00:00	Needs Followup	Call not pick 	2024-12-17 11:10:05.840506	9	2025-07-01 06:50:29.884428	\N
2121	.	9214628490	2025-07-28 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2122	.	7891022499	2025-07-28 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2123	.	8005926622	2025-07-28 00:00:00	Needs Followup	Not interested & cut a call \r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2124	.	9413344494	2025-07-28 00:00:00	Needs Followup	Honda city claim	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2125	.	9314630524	2025-07-28 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot interested 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2126	.	9602519110	2025-07-28 00:00:00	Needs Followup	Not interested 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2127	.	9829391371	2025-07-28 00:00:00	Needs Followup	Not requirement \r\nCall cut\r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2128	.	9782767165	2025-07-28 00:00:00	Needs Followup	Call not pick 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2129	.	9549350382	2025-07-28 00:00:00	Needs Followup	Not requirement \r\nNot requirement 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2131	.	7791956532	2025-07-28 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nCall cut\r\nCall cut	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2132	.	8696943943	2025-07-28 00:00:00	Needs Followup	Cut a call 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2133	.	9414778799	2025-07-29 00:00:00	Needs Followup	Not interested \r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2134	.	9983402111	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2136	.	9829115443	2025-07-29 00:00:00	Needs Followup	Not requirement 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2137	.	9900557889	2025-07-29 00:00:00	Needs Followup	Cut a \r\nNot pick\r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2138	.	9828922226	2025-07-29 00:00:00	Needs Followup	Not interested & cut a call \r\nCall cut\r\nBusy hu next week call back\r\n	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2139	.	7506739030	2025-07-29 00:00:00	Needs Followup	Not requirement 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2140	.	9829061018	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2141	.	9828556634	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	
2142	.	9828556634	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2143	.	7737017595	2025-07-29 00:00:00	Needs Followup	Not interested \r\nWagnor dant paint 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2144	.	9414075337	2025-07-29 00:00:00	Needs Followup	Busy \r\nCall cut	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2145	.	9460913337	2025-07-29 00:00:00	Needs Followup	Call back 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2147	Sanjay i10	9829246123	2025-07-29 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2148	.	8826250007	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nnot connect\r\nCall cut	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2149	Aslam ji	9414060805	2025-07-29 00:00:00	Needs Followup	Quanto 3399 package today pick up  quanto return car	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	
2151	.	9462659359	2025-07-29 00:00:00	Needs Followup	Cut a call \r\nNot pick 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2152	.	9988998855	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2153	.	7230007203	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2154	.	9414242038	2025-07-29 00:00:00	Needs Followup	Cut a call 	2024-12-19 04:39:58.362265	9	2025-07-01 06:50:29.884428	\N
2155	.	9557626100	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot requirement 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2156	.	9828088389	2025-07-29 00:00:00	Needs Followup	Cut a call \r\nNot interested 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2157	.	9829174194	2025-07-29 00:00:00	Needs Followup	Not interested \r\nCall cut	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2158	.	9460360006	2025-07-29 00:00:00	Needs Followup	Not interested 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2159	.	8700401398	2025-07-29 00:00:00	Needs Followup	Switch off 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2160	.	9799117500	2025-07-29 00:00:00	Needs Followup	Not interested \r\nNot pick\r\n	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2161	.	9650821822	2025-07-29 00:00:00	Needs Followup	Cut a call 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2162	.	9983727863	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2163	.	7427896425	2025-07-29 00:00:00	Needs Followup	Switch off \r\nNot pick 	2024-12-19 08:18:54.336777	9	2025-07-01 06:50:29.884428	\N
2164	.	8349303419	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2165	.	9414795757	2025-07-29 00:00:00	Needs Followup	Brezza 3199\r\nNot requirement 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2166	.	9509584581	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
4431	Cx570	8005632905	2025-07-29 00:00:00	Needs Followup	Ertiga 2999 service 	2025-02-28 07:52:56.38816	9	2025-07-01 06:50:29.884428	
4432	Cx571	8192000079	2025-07-29 00:00:00	Needs Followup	Duster 5999\r\nService 	2025-02-28 07:54:32.670949	9	2025-07-01 06:50:29.884428	
4434	Cx574	8005801532	2025-07-29 00:00:00	Needs Followup	Wr dent paint 	2025-02-28 07:56:49.291845	9	2025-07-01 06:50:29.884428	
4436	Cx575	9828445815	2025-07-29 00:00:00	Needs Followup	Swift Dent paint \r\n24000	2025-02-28 07:59:43.397417	9	2025-07-01 06:50:29.884428	
4439	CX,578	8824012152	2025-07-29 00:00:00	Needs Followup	Car service 	2025-02-28 08:01:43.918835	9	2025-07-01 06:50:29.884428	
4445	Cx582	9571142186	2025-07-29 00:00:00	Needs Followup	Micra 2499\r\nService 	2025-03-01 05:19:23.687176	9	2025-07-01 06:50:29.884428	
4458	Cx585	9784219547	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-02 06:08:53.493514	9	2025-07-01 06:50:29.884428	
4461	Cx587	9462404505	2025-07-29 00:00:00	Needs Followup	Call cut 	2025-03-02 06:12:27.843514	9	2025-07-01 06:50:29.884428	
4482	Cx894	9119133447	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-03 05:58:54.640455	9	2025-07-01 06:50:29.884428	
4485	Cx896	6378815952	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-03 06:01:14.433867	9	2025-07-01 06:50:29.884428	
4491	Cx90	9672484950	2025-07-29 00:00:00	Needs Followup	Verna \r\nDent paint 	2025-03-03 06:22:58.672284	9	2025-07-01 06:50:29.884428	
4495	Cx906	7357319906	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-03 08:24:09.202616	9	2025-07-01 06:50:29.884428	
4496	Cx907	9719946199	2025-07-29 00:00:00	Needs Followup	Honda amaze 24000\r\nDelhi se	2025-03-03 11:25:52.062724	9	2025-07-01 06:50:29.884428	
4499	CX 911	8094969914	2025-07-29 00:00:00	Needs Followup	Eon service \r\n1999\r\nBani park 	2025-03-03 13:33:14.240916	9	2025-07-01 06:50:29.884428	
4500	Cx910	8952068748	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-04 04:47:52.711853	9	2025-07-01 06:50:29.884428	
4502	Cx913	7384433246	2025-07-29 00:00:00	Needs Followup	In coming nahi hai \r\nVoice call 	2025-03-04 04:50:59.761742	9	2025-07-01 06:50:29.884428	
4507	Eon bani park	9784809746	2025-07-29 00:00:00	Needs Followup	Eon dent paint \r\nBani park \r\n\r\n	2025-03-04 04:57:15.730793	9	2025-07-01 06:50:29.884428	
4508	Cx916	8690060039	2025-07-29 00:00:00	Needs Followup	i20 service 2699	2025-03-04 05:06:17.667077	9	2025-07-01 06:50:29.884428	
4514	Cx919	7023142008	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-04 07:31:54.072734	9	2025-07-01 06:50:29.884428	
4517	Etios 2699	8963812575	2025-07-29 00:00:00	Needs Followup	Etios 2699	2025-03-04 08:12:20.711894	9	2025-07-01 06:50:29.884428	
4518	Tata tiago service 	8209571029	2025-07-29 00:00:00	Needs Followup	Tata tiago service 2999\r\nAjmer road 	2025-03-04 08:16:50.00941	9	2025-07-01 06:50:29.884428	
4522	Cx920	9433095959	2025-07-29 00:00:00	Needs Followup	Wr 2199	2025-03-04 10:35:03.913126	9	2025-07-01 06:50:29.884428	
4523	Alto k10	7568871909	2025-07-29 00:00:00	Needs Followup	Alto k10	2025-03-04 11:02:51.248374	9	2025-07-01 06:50:29.884428	
4525	Cx923	7426894753	2025-07-29 00:00:00	Needs Followup	Alto \r\nAc service 	2025-03-04 11:50:31.657318	9	2025-07-01 06:50:29.884428	
4533	Cx925	7976926959	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-05 08:50:49.628973	9	2025-07-01 06:50:29.884428	
4536	Cx931	6377785028	2025-07-29 00:00:00	Needs Followup	Dent paint 	2025-03-05 08:53:03.519309	9	2025-07-01 06:50:29.884428	
4538	Cx934	6350506794	2025-07-29 00:00:00	Needs Followup	Horan aur ac\r\nSharp motors 	2025-03-05 08:55:42.185056	9	2025-07-01 06:50:29.884428	
4539	Cx934	9829122781	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-05 08:56:33.604239	9	2025-07-01 06:50:29.884428	
4540	CX 936	8619248820	2025-07-29 00:00:00	Needs Followup	Ac \r\nAmaze \r\nAjmer road 	2025-03-05 08:58:18.826451	9	2025-07-01 06:50:29.884428	
4541	Cx935	9462823655	2025-07-29 00:00:00	Needs Followup	Insurance work	2025-03-05 09:10:17.856226	9	2025-07-01 06:50:29.884428	
4547	Cx939	9414714947	2025-07-29 00:00:00	Needs Followup	Dzire Dent paint 	2025-03-05 09:54:05.411272	9	2025-07-01 06:50:29.884428	
4549	Cx941	9256600106	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-05 09:57:33.012319	9	2025-07-01 06:50:29.884428	
4562	Cx934	9829215143	2025-07-29 00:00:00	Needs Followup	Corolla 3999 \r\nDent paint  28 se 29	2025-03-07 09:24:59.128479	9	2025-07-01 06:50:29.884428	
4563	Cx940	9119288365	2025-07-29 00:00:00	Needs Followup	Call cut 	2025-03-07 09:30:47.142128	9	2025-07-01 06:50:29.884428	
4564	Cx942	7742441155	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-07 09:32:48.03474	9	2025-07-01 06:50:29.884428	
4565	Cx944	7742441155	2025-07-29 00:00:00	Needs Followup	Nexon \r\nRubbing aur Dent paint 	2025-03-07 09:51:42.376442	9	2025-07-01 06:50:29.884428	
4568	Cx944	7357389238	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-07 10:01:11.42425	9	2025-07-01 06:50:29.884428	
4569	CX 946	9680615311	2025-07-29 00:00:00	Needs Followup	Car service 	2025-03-07 10:02:28.406903	9	2025-07-01 06:50:29.884428	
4914	Tarun 	9214015127	2025-07-29 00:00:00	Needs Followup	XUV EXPRESS-5699	2025-03-21 06:12:37.117804	9	2025-07-01 06:50:29.884428	Xuv
4939	gaadimech	9649834260	2025-07-29 00:00:00	Needs Followup	Audi drycleaning nd dent paint 	2025-03-22 10:25:25.371996	9	2025-07-01 06:50:29.884428	
4977	Arpit 	9352862628	2025-07-29 00:00:00	Needs Followup		2025-03-24 07:19:14.541465	9	2025-07-01 06:50:29.884428	
5013	Ivr	9414784427	2025-07-29 00:00:00	Needs Followup	Amaze 3199\r\nWRV 3399	2025-03-24 09:52:59.89889	9	2025-07-01 06:50:29.884428	
5035	Devendra Kumar Sharma 	9928362765	2025-07-29 00:00:00	Needs Followup	Cx said that his location is far away from our all the service centers\r\nApprox 25 km \r\nLalchandpura\r\n	2025-03-25 06:39:06.460683	9	2025-07-01 06:50:29.884428	
5058	Sapna	9999031980	2025-07-29 00:00:00	Needs Followup	Not interested 	2025-03-25 11:29:21.565839	9	2025-07-01 06:50:29.884428	
5076	Dilip g	8947946184	2025-07-29 00:00:00	Needs Followup		2025-03-26 06:10:26.538289	9	2025-07-01 06:50:29.884428	
5082	Sunil 	9312242982	2025-07-29 00:00:00	Needs Followup		2025-03-26 07:03:27.052307	9	2025-07-01 06:50:29.884428	
5084	Abu ansari 	9545736662	2025-07-29 00:00:00	Needs Followup		2025-03-26 07:16:35.558126	9	2025-07-01 06:50:29.884428	
5089	Customer 	9910027991	2025-07-29 00:00:00	Needs Followup		2025-03-26 08:46:22.928335	9	2025-07-01 06:50:29.884428	
5093	Asif	8003758042	2025-07-29 00:00:00	Needs Followup		2025-03-26 09:11:04.360698	9	2025-07-01 06:50:29.884428	
5098	Customer 	7023634064	2025-07-29 00:00:00	Needs Followup		2025-03-26 09:26:12.966808	9	2025-07-01 06:50:29.884428	
5104	Bhaskar 	9980966637	2025-07-29 00:00:00	Needs Followup		2025-03-26 10:03:36.104594	9	2025-07-01 06:50:29.884428	
7696	Cc3080	7374801404	2025-07-29 00:00:00	Needs Followup	Dent paint \r\n	2025-06-28 05:59:03.661513	9	2025-07-01 06:50:29.884428	
2167	.	9887496693	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2168	.	7014873770	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2169	.	9414071583	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick\r\nNot connected	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2171	.	7014340045	2025-07-29 00:00:00	Needs Followup	Not interested \r\nNot interested 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2172	Abhishek sir 	9414459451	2025-07-29 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2173	.	7568166645	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2175	.	9460050614	2025-07-29 00:00:00	Needs Followup	Not requirement 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2176	.	9057777677	2025-07-29 00:00:00	Needs Followup	Cut a call \r\nNot pick	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2177	.	9783650470	2025-07-29 00:00:00	Needs Followup	Call back \r\nNot interested 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2178	.	9829355548	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2179	.	9876543232	2025-07-29 00:00:00	Needs Followup	Not interested 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2180	.	7665095000	2025-07-29 00:00:00	Needs Followup	New car warranty period me 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2181	.	9828024041	2025-07-29 00:00:00	Needs Followup	Not requirement 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2182	.	9314077500	2025-07-29 00:00:00	Needs Followup	Not interested 	2024-12-19 09:37:50.020539	9	2025-07-01 06:50:29.884428	\N
2183	Diljit sir 	9660397451	2025-07-29 00:00:00	Needs Followup	WhatsApp package shared 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2185	.	9829251615	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2186	.	9214489899	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2187	.	9460069917	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2188	.	7976786884	2025-07-29 00:00:00	Needs Followup	Not interested 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2189	.	9414617444	2025-07-29 00:00:00	Needs Followup	Switch off \r\nBmw 320d service 12000	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2190	.	9314083000	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2191	.	9314510026	2025-07-29 00:00:00	Needs Followup	Call back \r\nNot pick\r\nNot requirement 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2192	.	8562862365	2025-07-29 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2193	.	9867530176	2025-07-29 00:00:00	Needs Followup	Call not pick 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2194	.	9314517630	2025-07-29 00:00:00	Needs Followup		2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2195	.	9829329341	2025-07-29 00:00:00	Needs Followup	Not requirement 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2196	.	9828128789	2025-07-29 00:00:00	Needs Followup	Cut a call 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2197	.	8946942194	2025-07-29 00:00:00	Needs Followup	Cut a call 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2198	.	7060725535	2025-07-29 00:00:00	Needs Followup	Switch off 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	
2200	.	9414035358	2025-07-29 00:00:00	Needs Followup	Not interested 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	
2201	Mansingh	9414084729	2025-07-29 00:00:00	Needs Followup	Customer ke 4 time bolne ki baad bhi alignment nahi Kara \r\nCustomer ne bola meri seat ke screw tight kar do vo bhi nahi Kare	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2202	Dharmveer	9782746360	2025-07-30 00:00:00	Needs Followup	Feedback call\r\nShampoo ache se nhi kara thode spot raha gaye & all is good 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2203	.	8890858994	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	
2204	.	9536896701	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-19 11:15:07.123752	9	2025-07-01 06:50:29.884428	\N
2205	.	9413990080	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2209	.	8171248484	2025-07-30 00:00:00	Needs Followup	Cut a call \r\nNot pick\r\nNot pick 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2210	.	9680432009	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2211	.	6378285760	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2212	.	9828922224	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2213	.	9829143370	2025-07-30 00:00:00	Needs Followup	Not interested & cut a call 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2214	.	9819592245	2025-07-30 00:00:00	Needs Followup	Not requirement 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2215	.	9928036040	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2216	Sumit sir	9351261002	2025-07-30 00:00:00	Needs Followup	WhatsApp package shared 23 ko call back\r\nMaruti  se service karwa li 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2217	.	9549433666	2025-07-30 00:00:00	Needs Followup	Call not pick \r\nNot pick	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2218	.	9251156893	2025-07-30 00:00:00	Needs Followup	Call not pick \r\nNot interested 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2219	.	9799386900	2025-07-30 00:00:00	Needs Followup	Call not pick \r\n	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2220	.	9413240301	2025-07-30 00:00:00	Needs Followup	Not requirement 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2221	.	9414729854	2025-07-30 00:00:00	Needs Followup	Call not pick \r\nNot pick 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
2222	.	9414869787	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-20 04:42:01.100851	9	2025-07-01 06:50:29.884428	\N
3996	. Dholpur	8696593900	2025-07-30 00:00:00	Needs Followup	Dholpur	2025-02-12 10:30:10.848687	9	2025-07-01 06:50:29.884428	
4025	.	7901733883	2025-07-30 00:00:00	Needs Followup	Panjab se	2025-02-15 07:41:43.910921	9	2025-07-01 06:50:29.884428	
4039	.	9549080999	2025-07-30 00:00:00	Needs Followup	Switch off	2025-02-15 08:35:09.402231	9	2025-07-01 06:50:29.884428	
4418	gaadimech	7017036029	2025-07-30 00:00:00	Needs Followup	Ertiga 2899 Delhi se	2025-02-27 05:09:04.318146	9	2025-07-01 06:50:29.884428	
4591	gaadimech 	7742206924	2025-07-30 00:00:00	Needs Followup	\r\nBikaner se hai	2025-03-08 05:28:45.258929	9	2025-07-01 06:50:29.884428	
4868	gaadimech 	7976329640	2025-07-30 00:00:00	Needs Followup	I20 ac checkup \r\nNahi aana 	2025-03-20 04:32:04.353533	9	2025-07-01 06:50:29.884428	
5925	Customer 	9928505000	2025-07-30 00:00:00	Needs Followup	Wegnor 2399	2025-04-14 11:12:46.343764	9	2025-07-01 06:50:29.884428	
7711	Honda City bonnet Dent paint 	7903286743	2025-07-30 00:00:00	Open	Vki \r\nDent paint 	2025-06-28 06:28:11.799424	9	2025-07-01 06:50:29.884428	
7718	Marazzo	9636798623	2025-07-30 00:00:00	Open	Vki \r\nAc gas 	2025-06-28 08:10:08.33299	9	2025-07-01 06:50:29.884428	
3605	.	9436022235	2025-07-30 00:00:00	Needs Followup	Not pick 	2025-02-02 08:44:54.392846	9	2025-07-01 06:50:29.884428	
3640	.	9829062155	2025-07-30 00:00:00	Needs Followup	Call cut	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3651	.	9414689665	2025-07-30 00:00:00	Needs Followup	Not pick 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3686	.	9950555552	2025-07-30 00:00:00	Needs Followup	Call cut	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3692	.	9910476478	2025-07-30 00:00:00	Needs Followup	Ciaz 2999 month end call back 	2025-02-04 08:21:25.650869	9	2025-07-01 06:50:29.884428	
3734	.	9829307733	2025-07-30 00:00:00	Needs Followup	Not pick \r\nCall cut 	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3754	.	8386075201	2025-07-30 00:00:00	Needs Followup	Not requirement 	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
3954	.	8058808380	2025-07-30 00:00:00	Needs Followup	Grand vitara 2500 penal \r\n1500 rubbing polishing 	2025-02-12 04:48:46.102329	9	2025-07-01 06:50:29.884428	
3974	.	7222022292	2025-07-30 00:00:00	Needs Followup	Creta 2999 2000km due h	2025-02-12 09:11:45.808996	9	2025-07-01 06:50:29.884428	
3980	.	9887200009	2025-07-30 00:00:00	Needs Followup	I don't have time right now, I will call you myself when I am free 	2025-02-12 09:31:37.196041	9	2025-07-01 06:50:29.884428	
2300	.	7737168961	2025-07-30 00:00:00	Needs Followup	Car nahi hai 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
4108	.	8955113563	2025-07-30 00:00:00	Needs Followup	Car sell kar di 	2025-02-16 10:35:12.434976	9	2025-07-01 06:50:29.884428	
4228	.	6375702080	2025-07-30 00:00:00	Needs Followup	Aaj ya kal 	2025-02-19 05:07:03.548153	9	2025-07-01 06:50:29.884428	
7694	Ramesh Pawar	9001436050	2025-07-30 00:00:00	Needs Followup		2025-06-28 05:40:36.315907	9	2025-07-01 06:50:29.884428	
2265	.	8766687664	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 08:28:57.743192	9	2025-07-01 06:50:29.884428	
2266	.	9694544434	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 08:28:57.743192	9	2025-07-01 06:50:29.884428	\N
2267	.	9314021600	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 08:28:57.743192	9	2025-07-01 06:50:29.884428	
2269	.	9636898500	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 08:28:57.743192	9	2025-07-01 06:50:29.884428	\N
2271	.	8696917922	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-20 08:28:57.743192	9	2025-07-01 06:50:29.884428	\N
2272	.	9560288998	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2273	.	8742808291	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2274	.	8441910379	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2275	.	9829034358	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2280	.	9928222273	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2281	.	7057576817	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2282	.	9950022222	2025-07-30 00:00:00	Needs Followup	Not interested 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2283	.	7618187967	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2284	.	7976788113	2025-07-30 00:00:00	Needs Followup	Not requirement 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2285	.	9950687911	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2286	.	9829279662	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2287	.	9521786770	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2289	.	9950222267	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2290	.	9818441261	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2291	.	9829063486	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2292	.	9314968651	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2293	Ravinder sir	8114410546	2025-07-30 00:00:00	Needs Followup	WhatsApp package shared \r\nNot pick 	2024-12-21 06:02:55.801736	9	2025-07-01 06:50:29.884428	\N
2378	.	9672606060	2025-07-30 00:00:00	Needs Followup	Car nahi hai mere pass call mat karna 	2024-12-22 09:44:02.370203	9	2025-07-01 06:50:29.884428	
2381	.	9314938675	2025-07-30 00:00:00	Needs Followup	Amanya hai no 	2024-12-22 11:18:43.642026	9	2025-07-01 06:50:29.884428	
3653	.	9829099469	2025-07-30 00:00:00	Needs Followup	Personal work shop hai 	2025-02-02 10:46:12.681522	9	2025-07-01 06:50:29.884428	
3733	.	9024907375	2025-07-30 00:00:00	Needs Followup	Jodhpur se hu 	2025-02-05 08:55:58.705632	9	2025-07-01 06:50:29.884428	
2295	.	9314515012	2025-07-30 00:00:00	Needs Followup	Call cut 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2304	.	9828225521	2025-07-30 00:00:00	Needs Followup	Cut a call 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2306	.	9829050355	2025-07-30 00:00:00	Needs Followup	Car service 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2307	.	9351288101	2025-07-30 00:00:00	Needs Followup	Cut 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2308	.	9829052269	2025-07-30 00:00:00	Needs Followup	No answer 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2311	.	9413344057	2025-07-30 00:00:00	Needs Followup	Call not pick 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2316	.	9549654171	2025-07-30 00:00:00	Needs Followup	Out off network 	2024-12-21 08:31:22.208151	9	2025-07-01 06:50:29.884428	
2370	.	9413565059	2025-07-30 00:00:00	Needs Followup	No answer 	2024-12-22 08:06:41.389566	9	2025-07-01 06:50:29.884428	
2371	.	9829052133	2025-07-30 00:00:00	Needs Followup	Switch off hai 	2024-12-22 08:06:41.389566	9	2025-07-01 06:50:29.884428	
2380	.	9829036189	2025-07-30 00:00:00	Needs Followup	No answer 	2024-12-22 09:44:02.370203	9	2025-07-01 06:50:29.884428	
2384	.	9829049410	2025-07-30 00:00:00	Needs Followup	Switch off 	2024-12-22 11:59:29.710349	9	2025-07-01 06:50:29.884428	
2385	.	9829018822	2025-07-30 00:00:00	Needs Followup	No answer 	2024-12-22 11:59:29.710349	9	2025-07-01 06:50:29.884428	
2393	.	9314509853	2025-07-30 00:00:00	Needs Followup	Call cut 	2024-12-23 04:37:08.828595	9	2025-07-01 06:50:29.884428	
2572	Cx138	9829340504	2025-07-30 00:00:00	Did Not Pick Up	Car Pickup-i20-2699\r\nService done \r\nNot interested 	2025-01-02 12:06:04.008231	9	2025-07-01 06:50:29.884428	
2646	Babu lal	9588901372	2025-07-30 00:00:00	Needs Followup	Car service \r\nNo answer \r\n	2025-01-07 04:42:15.913695	9	2025-07-01 06:50:29.884428	
3158	Customer	9829232401	2025-07-30 00:00:00	Needs Followup	No answer 	2025-01-19 10:35:57.536291	9	2025-07-01 06:50:29.884428	
3296	.	9808516393	2025-07-30 00:00:00	Needs Followup	Switch off hai 	2025-01-21 10:55:25.845211	9	2025-07-01 06:50:29.884428	
3728	.	7023388228	2025-07-30 00:00:00	Needs Followup	Not pick 	2025-02-05 08:03:10.877726	9	2025-07-01 06:50:29.884428	
3989	.	9414255968	2025-07-30 00:00:00	Needs Followup	No answer 	2025-02-12 10:15:37.894711	9	2025-07-01 06:50:29.884428	
4282	.	9351602901	2025-07-30 00:00:00	Needs Followup	No answer 	2025-02-22 06:01:39.327939	9	2025-07-01 06:50:29.884428	
4527	customer	7014116854	2025-07-30 00:00:00	Needs Followup	WRV DENT PAINT 	2025-03-04 12:07:13.616835	9	2025-07-01 06:50:29.884428	
4581	gaadimech 	8875193913	2025-07-30 00:00:00	Needs Followup	Celerio engine work\r\nOut of service 	2025-03-08 04:36:34.820164	9	2025-07-01 06:50:29.884428	
4839	.	9799899143	2025-07-30 00:00:00	Needs Followup	No answer 	2025-03-18 11:57:10.41323	9	2025-07-01 06:50:29.884428	
4867	gaadimech	9351767705	2025-07-30 00:00:00	Needs Followup	Alto K10 drycleaning 1200\r\nNo answer 	2025-03-19 11:33:03.752166	9	2025-07-01 06:50:29.884428	
7695	gaadimech 	7043327787	2025-07-30 00:00:00	Did Not Pick Up	Not pick	2025-06-28 05:44:09.515642	9	2025-07-01 06:50:29.884428	
7698	gaadimech 	7597276364	2025-07-30 00:00:00	Did Not Pick Up	Celerio dent paint 	2025-06-28 05:59:34.520972	9	2025-07-01 06:50:29.884428	
7706	gaadinech	9314243770	2025-07-30 00:00:00	Needs Followup	Brezza 2200 panel charge	2025-06-28 06:06:20.652662	9	2025-07-01 06:50:29.884428	
7712	Cx3083	7689859166	2025-07-30 00:00:00	Needs Followup	Service \r\nCall end 	2025-06-28 06:28:48.285559	9	2025-07-01 06:50:29.884428	
7716	gaadimech 	9680925253	2025-07-30 00:00:00	Did Not Pick Up	Aura 2799 service 	2025-06-28 06:37:30.977684	9	2025-07-01 06:50:29.884428	
7725	gaadimech	9982276508	2025-07-30 00:00:00	Needs Followup	Ciaz 4199 call back after 6 pm	2025-06-28 12:00:51.5882	9	2025-07-01 06:50:29.884428	
7727	Wr ac gas 	7737387788	2025-07-30 00:00:00	Needs Followup	Ac service wr	2025-06-28 12:09:04.245337	9	2025-07-01 06:50:29.884428	
7740	Cx3087	8949527846	2025-07-30 00:00:00	Needs Followup	Wr ac service 	2025-06-29 05:27:42.018178	9	2025-07-01 06:50:29.884428	
7741	Cx3088	9351464729	2025-07-30 00:00:00	Needs Followup	Car service \r\nCall cut 	2025-06-29 05:28:06.856958	9	2025-07-01 06:50:29.884428	
7742	Cx3090	9772334853	2025-07-30 00:00:00	Needs Followup	Scorpio ac\r\nJagatpura	2025-06-29 05:28:40.61197	9	2025-07-01 06:50:29.884428	
7765	gaadimech	8005785056	2025-07-30 00:00:00	Needs Followup	Scorpio 5199 	2025-06-30 04:53:17.552217	9	2025-07-01 06:50:29.884428	
7766	gaadiench	7357155799	2025-07-30 00:00:00	Did Not Pick Up	Not pick	2025-06-30 04:58:39.47726	9	2025-07-01 06:50:29.884428	
7767	gaadimech 	9782680325	2025-07-30 00:00:00	Did Not Pick Up	Call cut	2025-06-30 05:00:12.078053	9	2025-07-01 06:50:29.884428	
7771	gaadimech	9828096571	2025-07-30 00:00:00	Did Not Pick Up	Busy call u later 	2025-06-30 05:21:20.40944	9	2025-07-01 06:50:29.884428	
7773	gaadimech	9950653233	2025-07-30 00:00:00	Did Not Pick Up	Call cut	2025-06-30 05:34:15.258482	9	2025-07-01 06:50:29.884428	
7775	gaadiemch	7053714051	2025-07-30 00:00:00	Did Not Pick Up	Not pick 	2025-06-30 06:05:55.010822	9	2025-07-01 06:50:29.884428	
7776	gaadimech 	9649401502	2025-07-30 00:00:00	Did Not Pick Up		2025-06-30 06:07:48.150031	9	2025-07-01 06:50:29.884428	
7777	gaadimech 	8949222378	2025-07-30 00:00:00	Did Not Pick Up		2025-06-30 06:10:07.510028	9	2025-07-01 06:50:29.884428	
7778	gaadimech 	8005773638	2025-07-30 00:00:00	Did Not Pick Up		2025-06-30 06:57:42.024868	9	2025-07-01 06:50:29.884428	
7779	gaadimech 	7891346028	2025-07-30 00:00:00	Did Not Pick Up	Not pick	2025-06-30 07:01:51.156703	9	2025-07-01 06:50:29.884428	
7781	Dzire ac service 	8279209581	2025-07-30 00:00:00	Needs Followup	Evening Tak 	2025-06-30 08:09:32.061261	9	2025-07-01 06:50:29.884428	
7788	Vki ac 	9929502597	2025-07-30 00:00:00	Needs Followup	Vki ac 	2025-07-01 04:53:21.73099	9	2025-07-01 06:50:29.884428	
\.


--
-- Data for Name: push_subscription; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.push_subscription (id, user_id, endpoint, p256dh_key, auth_key, user_agent, created_at, is_active) FROM stdin;
1	5	https://fcm.googleapis.com/fcm/send/clUn-K5yGss:APA91bHePCGfxG_vlB3KKAmL4Ep7AUoDD61V01P26gQxFb3zISHFrtmZZhbuoLqe1Uw6Gp_gk-M9ZdQ8LYwGhdq8aqGGvTWPKFkFDrSeDyMHchdCigWS7RP8ihnnMxhC4eg3ofdlx5YS	BCowM1KaUa9D7wStzHks0SDNQy_F38RQNj303zRIhRF6mJg8KEAX8n0N0fOpKMOLhbitTQxmw78F5pupf2BuOBg	oDoPRc1UJTh8LZ55LnGyDA	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36	2025-07-05 11:35:05.165029	f
2	5	https://fcm.googleapis.com/fcm/send/f_Ojnpzwnvg:APA91bG-RuqoQ7rIiCzo0Axlr1ikUnzuwszQ42SIcFK2htQ4ScB9Hh1fRFJ96INNunUierFamq--16MDgs7Pe2C8kzR7FzM8JtrAZPtZXG9k6LQinsCGQ9sABICl_y8Kz44sKUJqfo9T	BDYdVvdHtluRmMcfyTki6Ndfm0EEESE9ldCB6qH-J4fTVGVKulzyU5ODi0BhpvH_wifZ_HXoHOgq1rX4OCV42Q8	_7cRTO__VOACt18i0KTuaQ	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 11:38:41.512543	f
3	5	https://fcm.googleapis.com/fcm/send/etRMVnLrWNM:APA91bGc_-yheiSZeFYm7GOOsJVhZfkUvOOJgVG4Ucn1zkBS6NPA9hi2tFdfKwaUK2v_2MoqHtOO3u6R8fO2c0nSIbOgbB2ewe6-E-EJts6W-kUF25jngyzs9pB0bYFgZwvgWUhPwuNi	BP0tQ-TZ6dMc1NZU7xhcfSwgHvqsYK2Ca0jqQjoaVCE_f7_8beaDT0tb1Lzf7blBaWk7UaXlJ2pu7M-i_HIqBYI	StMdPnbLza9OIFNC9aS7dg	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36	2025-07-05 11:45:48.125818	f
5	5	https://fcm.googleapis.com/fcm/send/cp13f8FyvAg:APA91bGZVkaKhEkeLnwxPiKbFriDRkPAfhChMKUXt8ywQEGdqTRcdK8fokQatcuEjjGK-KTF8TwF-hpfevELYYpCkdKEv1klLYT7Zu67ZvZxmRO990Vdw7ef-d0dTydPQLcwHux8CUrq	BGqNqkQo7gky5mSR5EfoROdC5jvRkKvvi4PuE4e_I1UNiFUsITgAkARQS7ENcGgpiMEYPRyEmK3SsTe9vnH_8iQ	ww79GO_iSaema8Qq4C_DKw	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 11:49:03.626534	t
6	5	https://fcm.googleapis.com/fcm/send/eq1qzcNeUnQ:APA91bHIbrAa2v9XSlgp4Q45smcpe25fCmm_bhQYPpH5zIey-4SXpv42hFRy6p_sJzlQZZI9cDQ2_5a68DN5u1MIeMOYs1svB9VIYrXBQByCyf6_rHsL2VrPaVW5caXBpLWUoNB3zXbx	BGT17HxvdZmEXWYh8Pncg_qmK8shwdM2Bz8dEK7ukjDJAUxlfSeigjoxKbZA_itqWqCYRR5ZGfHetw7tjc0DKkE	POu98lF-f18BsxqIstAD-Q	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36	2025-07-05 20:30:25.350463	t
7	5	https://fcm.googleapis.com/fcm/send/cG-RFl2ZbCk:APA91bHhrvDmWD0DyssrtgvsSQZ4aWbxlWGdjDwVL5Q9YYNp-37nrHimTCg0auLVsrTxItn_sOwQtATQT5iRU0EIt_bEsR7Y_HISe1UzF6Ip-CLHNen5Hu2RB7nuO2vUySuZe8C4xHOO	BLMBwcUnOgyqWO8_1soMrg7ayHMWLYblMsJ9EUKlh4YWUSzB5s886-eVWMgv_DszuqOI3oDKHSrK6CCLjFzpixM	OZRu0eydNgl_Bb4kRE9J4w	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36	2025-07-05 20:30:42.581971	t
8	5	https://fcm.googleapis.com/fcm/send/cqPPx4sp1XA:APA91bEuj7-0wda_6OCiquoZm1xbWpvJJ6B9Vh2SE8Bdjgeh1WOGkA50bX0PcQnqaxip7LZKO2SM1Ec7U8fZ_Bt5Nu99_B6mLrZM-qgDo6Y5c96PdVL2R2xHzPXEywkVDKAoQ1XWErFb	BBbnNVajT2E5gSJp-kvFB13pJobXN4L75N7hvrIFBgYgmy7LOYvnbRy5oi-y1Q6TRK6wohx238heSEvpUDtVKZA	_cVV88wCpddL_xnYy5w_cQ	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36	2025-07-05 20:41:23.312944	t
9	5	https://updates.push.services.mozilla.com/wpush/v2/gAAAAABoaY8ajZ1gQL2in0zvYozJsgrvPaHlgnqy5qletCyXAYxInUzrCHRBfQeoXiEqhisOgyBfkBpJM55AgMZ-9GlBi_tlgl953gjkbgGen6hVoICncF4dhMSVpeTkB2ndlgYcCXJ9ZVafW8PZOu5P8TkD_U-wMMftqDdpjTfFRry2J0cQy7o	BHscrIFRAO9f8FynInR6VKuIHiTlX2_eO3gKECN05RWy1M6AbQw9b1hLZASv8-qk_RB1KNxhbF4tcFyzzmKN9Ac	SR7pmCJCgIlzQc59n3shag	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0	2025-07-05 20:46:18.856703	f
10	5	https://updates.push.services.mozilla.com/wpush/v2/gAAAAABoaZoTRd724pEXloxc3Gc2zGxGFfkMxoYL4397V0KLFkSryM8QwsJS22dy85mbBFfKubx7juwzbxa3QQCuI4vDtiALqM1UCk6nV0uMzW-p3cvGnigMnMeV1blIPBxYS2EkGb4NuQm772bhV0rEv5g_kIYTMwYYOzNB_o9IUwhKQaHre6g	BM3b4LTjLgwSotoh0DqxrOcEOZ5sdhKfQU_w-0uPlNDhFaHTWgKwWQj0wDM_LjsOb4TcXHG_O8cgxyshsubccNo	vhr51nE4xXC5dW8LSGzGHg	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0	2025-07-05 21:33:07.784386	t
11	5	https://updates.push.services.mozilla.com/wpush/v2/gAAAAABoaZuYr-ZZNAGaaqOFEWNx7T4m2qx3oW2IPW9XDEjczUMHdGXORc73pkjKV6E9va6FcRREnDlZ4QKgCHf5Xadz6JjjZJcJSO1oFLore04HGYzoIaawItIO7JhVlVRHUP1Wr_sd6ASR2UuaDgVv4I5zF5Ps1YmGrMIvJ5b51PM4VVf6_ds	BLKbPIZJ-Ig89AdBHEqOuasVsGkbJX1uTx05loe3Oegi-Q0kbTtsDMWsmNrIa7mNg9Ef44hXD7ywa5WrM-XT0Js	8wroMmSc9--Mwl5w0gCURQ	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0	2025-07-05 21:39:37.228006	t
12	5	https://updates.push.services.mozilla.com/wpush/v2/gAAAAABoaaLDlIDg_azMklM8nflhUT9sqHoca86Q2pXLZLpxXT7IZcs6hN82fnP0TDbU7aGVsE2di1pkwyJxdT3vR1jCgXSpkkwGN4VM6wFW_r2PSfWmZfLMgX69ka2IOkvo9eKZo8C2vNXRKv7ceMAt3yaycOWsq8_it_3i72QrGKJkUoXeKEU	BCBVkG0X2CFDApPK4rxyxYaDDdEuFJiXLIu2CEAZRWuIrOKMc0oTz_qJgj-mV6KDdIwK4NL95x1eHe8TrkPkfIE	1d-O6Ry4TlzZxb1CJqWgaQ	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:140.0) Gecko/20100101 Firefox/140.0	2025-07-05 22:10:12.217094	t
13	1	https://fcm.googleapis.com/fcm/send/cbyIgdxVsMQ:APA91bEihbcyvqCtMhI56MpLK6h3tlMI-7Mu89Ac5uSb013RMWSq1UesISLJKZyrjjsklnf89A_RdIcsLNIUrhLSOOuj2GN43yZuH_6mQCztSdBcyy5pUjy6QFPI7V-ddUEbljXvgYnT	BIK9sHdsIyGv7DR46yFvTnqCQFlxaJVI6dWwtW5NfxRvrnZkEgjvpC-9TvMZkuVhhnMDeha6acDGuxuyG-nP3Y0	EH2xAArDOmr6EhhedKdoYg	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 22:38:57.426848	t
14	1	https://fcm.googleapis.com/fcm/send/cZ6gB8lMKQQ:APA91bFcDua2ig3kM0JJssZ9evISzPHJXs2-OCKiRKTBwqFVPHCke1s4gKb2_u7yTUNJO7p8NFO_cgaDKVbVLC5on27lJm9hRC73TCUWCEt7Yt60fB2yrSpZCcGLpJ7FVEDuOOgOkkcH	BH2OzQPkK03-BTUotGMZIklManAWsQCC0ve54Cr0oWpH1sxYtoIDGuWeF1shVtQmZYTT1WglVwDyqxXM24NW2yc	kJi-u_1uMFR6mvP7_b5m0Q	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 22:38:57.78051	t
15	1	https://fcm.googleapis.com/fcm/send/duIX6CAobYg:APA91bHdDSm_NolVHDcMnzHVPjFFtPHtLDLxw9bAxV8ED99tW6VrAJ5Y6VZfj_OE7HYgODMOvJvRKTqA242D3vpYkE4FA3sI5hz9cmC3dRLzkY9f1Cb-dPgLO6m2Ht5lAsPEla03_rqF	BOLrMfmS8XS0UHjTTI4CMC655sa3hNb9NBBrtHHHEcFp-Zg2zNSJBqdg5D9s7QKCHm1eKV-hemmbLTwOC_wuw7M	1Xd4HqCjn3ceX88vYcdWIQ	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 22:58:16.587352	t
16	1	https://fcm.googleapis.com/fcm/send/fpdecVbx8Pk:APA91bHn9vRkut_RMqXeVTPOoF576IMWA7-TVjwSR-2Ezl-7v36PgiSDWsbuTzSGWo9gpBFAvFX5HsH83S6AevjFJqKk2l1-9sCMvE_FItTCXQURM5PO6CQYdncbu0JD_PG1ylgmEx3a	BL7IojmaA3xViG1vbLFvG0Pn9n2bMlaz8gwNl1e9WWZF8UnusqD5H1-CrU9RU0VC5PQ5gFZyruXJSh5nhpeAp0g	cTNx6PZVrp_7oM7-vTyQ6A	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 22:58:17.09755	t
17	1	https://fcm.googleapis.com/fcm/send/fn5V9wBRgCw:APA91bFlBz8eU2V2VES3FjOUNnM18xmWnebYPUo5aHVg26GKt7a-GhbUy3kzSsD7qWBbqr5j-XRSmsv6LR8urOTbvBcMBWyoebzN_iRm_hWdiYh5jsWDZ15U1BYS7Ir7WBXRRq-xI5gM	BN34fOIVrCsI_BW9B5sqHWFwfjDEIUqnDOn84IfI3-kM9KOnl5xejmDUmlbv3OCIrNR3qc5UPpe1XaVtvhvsT1w	_6fwd2-9G7VwQJPC6IT2PA	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 23:22:44.820193	t
18	1	https://fcm.googleapis.com/fcm/send/enXAcT62roA:APA91bF-1YeIFdW8L2Ome96gCrxBlY1DEY7EudVbuPoSLVcv0opbwLcAfBSw1jTpNqscSryUJbE8vM8pmBr32Yd-0ScwB-vZFGciYZvliasLMWxBN3WEmeut1Ix8ZQHeSIMYKaMN9N6f	BNu4rSRNCOaLfjs4tSY1HpHJJbOSiN2ChUtYNaHggCeVPxmDnTz9q9yqgE6qDOCuAeo1Yp68sgNafOxEgxGwVBk	rIkD9mSC8vs9wOGkea0PqQ	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	2025-07-05 23:22:45.28765	f
\.


--
-- Data for Name: team_assignment; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.team_assignment (id, unassigned_lead_id, assigned_to_user_id, assigned_date, assigned_at, assigned_by, status, processed_at, added_to_crm) FROM stdin;
1	1	5	2025-07-05	2025-07-05 08:01:30.804462	1	Added to CRM	2025-07-05 08:03:59.938344	t
2	5	5	2025-07-05	2025-07-05 08:26:51.294756	1	Added to CRM	2025-07-05 08:27:17.741006	t
3	7	5	2025-07-05	2025-07-05 08:45:31.3647	1	Added to CRM	2025-07-05 08:46:06.806591	t
4	6	2	2025-07-05	2025-07-05 08:55:42.355202	1	Added to CRM	2025-07-05 08:57:47.397769	t
5	8	9	2025-07-05	2025-07-05 09:34:30.828031	1	Added to CRM	2025-07-05 09:35:23.418168	t
6	9	9	2025-07-05	2025-07-05 09:39:43.212343	1	Assigned	\N	f
8	11	5	2025-07-05	2025-07-05 10:22:25.312786	1	Assigned	\N	f
7	10	9	2025-07-05	2025-07-05 09:54:27.75115	1	Added to CRM	2025-07-05 10:43:11.057712	t
9	12	4	2025-07-05	2025-07-05 11:36:59.247168	1	Added to CRM	2025-07-05 12:02:32.129776	t
10	13	5	2025-07-06	2025-07-05 20:31:34.350011	1	Assigned	\N	f
11	14	5	2025-07-06	2025-07-05 20:33:10.348149	1	Assigned	\N	f
12	15	5	2025-07-06	2025-07-05 20:35:59.364457	1	Assigned	\N	f
13	16	5	2025-07-06	2025-07-05 20:42:16.745097	1	Assigned	\N	f
14	17	5	2025-07-06	2025-07-05 20:42:49.839692	1	Assigned	\N	f
15	18	5	2025-07-06	2025-07-05 20:46:52.259384	1	Assigned	\N	f
16	19	5	2025-07-06	2025-07-05 21:33:13.641959	1	Assigned	\N	f
17	20	5	2025-07-06	2025-07-05 22:11:59.433785	1	Assigned	\N	f
18	21	5	2025-07-06	2025-07-05 22:13:11.059231	1	Assigned	\N	f
19	22	5	2025-07-06	2025-07-05 22:20:40.44963	1	Assigned	\N	f
21	24	9	2025-07-06	2025-07-06 04:55:46.163357	1	Assigned	\N	f
22	25	9	2025-07-06	2025-07-06 04:56:05.700154	1	Assigned	\N	f
23	26	9	2025-07-06	2025-07-06 04:58:04.880695	1	Assigned	\N	f
24	27	9	2025-07-06	2025-07-06 04:58:23.542674	1	Assigned	\N	f
25	28	9	2025-07-06	2025-07-06 04:59:04.159815	1	Assigned	\N	f
20	23	9	2025-07-06	2025-07-06 04:53:48.540224	1	Added to CRM	2025-07-06 05:13:58.682792	t
26	29	9	2025-07-06	2025-07-06 06:24:37.194343	1	Assigned	\N	f
27	30	9	2025-07-06	2025-07-06 08:08:02.49557	1	Assigned	\N	f
\.


--
-- Data for Name: unassigned_lead; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.unassigned_lead (id, mobile, customer_name, car_manufacturer, car_model, pickup_type, service_type, scheduled_date, source, remarks, created_at, created_by) FROM stdin;
1	+919001436050	Surakshit Soni	Honda	Amaze	Pickup	Express Car Service	2025-07-04 18:30:00	Website		2025-07-05 08:01:30.766015	1
3	+919024600503	\N	\N	\N	\N	Express Car Service	\N	\N	+91 90246 00503‬\r\nCar service	2025-07-05 08:25:33.556718	1
4	+919257011045	Pavan Pratihast	Maruti	Ciaz	Self Walkin	Express Car Service	2025-07-05 18:30:00	\N	Pavan Pratihast (+919257011045)\r\nCar ManufacturerMaruti\r\nCar Model: Ciaz\r\nCity: Jaipur\r\nFuel Type: Petrol/CNG\r\nPnD or Walkin: Self Walk-in\r\nService Type: Express Car Service\r\nServiceDate: Tomorrow\r\nTimeSlot: 12 PM - 3 PM\r\nWorkshop Chosen: Jagatpura	2025-07-05 08:25:54.709704	1
5	+919257011045	Pavan Pratihast	Maruti	Ciaz	Self Walkin	Express Car Service	2025-07-05 18:30:00	\N	Pavan Pratihast (+919257011045)\r\nCar ManufacturerMaruti\r\nCar Model: Ciaz\r\nCity: Jaipur\r\nFuel Type: Petrol/CNG\r\nPnD or Walkin: Self Walk-in\r\nService Type: Express Car Service\r\nServiceDate: Tomorrow\r\nTimeSlot: 12 PM - 3 PM\r\nWorkshop Chosen: Jagatpur	2025-07-05 08:26:51.259125	1
7	919944274679	\N	Tata	Altroz	\N	\N	\N	\N	710\r\nFriday, July 4, 2025 at 9:19 PM\r\n9944274679\r\n-\t-\t\r\nTata\r\nAltroz\r\npetrol\r\n3,199	2025-07-05 08:45:31.327101	1
6	919944274679	\N	Tata	Altroz	\N	\N	\N	\N	Friday, July 4, 2025 at 9:19 PM\r\n9944274679\r\n-\t-\t\r\nTata\r\nAltroz\r\npetrol\r\n3,199	2025-07-05 08:44:37.459884	1
8	917874379027	\N	\N	\N	\N	Express Car Service	\N	Website	Wednesday, July 2, 2025 at 1:49 PM\r\nपपु\r\nहोंडा\r\n7874379027\r\nWednesday, July 2, 2025\r\nGeneral Service	2025-07-05 09:34:30.825029	1
9	8279255585	\N	\N	\N	\N	Dent Paint	\N	Website	+91 82792 55585	2025-07-05 09:38:57.000341	1
10	917014493301	Sameer	Maruti	Baleno	Self Walkin	Express Car Service	2025-07-04 18:30:00	Website	Maruti\r\nBaleno\r\nPetrol\r\nSameer\r\n7014493301\r\nExpress Service\r\nSelf Walk-in (You bring the car to our center)\r\nToday\r\n1:00 PM - 3:00 PM\r\nSaturday, July 5, 2025 at 11:15 AM	2025-07-05 09:54:27.747913	1
11	919001050181	\N	\N	\N	\N	Express Car Service	\N	Website	Saturday, July 5, 2025 at 1:15 PM\r\nVikas Kumar\r\n2012\r\n9001050181\r\nThursday, July 10, 2025\r\nGeneral Service	2025-07-05 10:22:25.273392	1
12	919983331646	\N	\N	\N	\N	Express Car Service	\N	Website	Saturday, July 5, 2025 at 2:16 PM\r\nRAMESH KUMAR\r\nBolero Di 2014\r\n9983331646\r\nThursday, July 10, 2025\r\nCar AC Servic	2025-07-05 11:36:59.244111	1
13	919828636754	\N	\N	\N	\N	Dent Paint	\N	Website	98286 36754\r\ndent and paint	2025-07-05 20:31:34.347363	1
14	919001436050	Surakshit Soni	\N	\N	\N	Dent Paint	\N	Website	Surakshit Soni\r\n9001436050\r\ndent paint	2025-07-05 20:33:10.34679	1
15	919999988888	Surakshit Soni Test	\N	\N	\N	Express Car Service	\N	Website	Surakshit Soni Test\r\n9999988888\r\nCar Service	2025-07-05 20:35:59.363016	1
16	919001432029	Surakshit Test Notification	\N	\N	\N	\N	\N	Website	Surakshit Test Notification\r\n9001432029	2025-07-05 20:42:16.743684	1
17	919001436050	Another Test	\N	\N	\N	\N	\N	Website	Another Test\r\n9001436050	2025-07-05 20:42:49.838238	1
18	919001436050	Surakshit Test	\N	\N	\N	\N	\N	Website	Surakshit Test\r\n9001436050	2025-07-05 20:46:52.25812	1
19	919001436050	Surakshit Test	\N	\N	\N	\N	\N	Website	Surakshit Test 123\r\n9001436050	2025-07-05 21:33:13.639642	1
20	919001436050	Check Check	\N	\N	\N	\N	\N	Website	Check Check\r\n9001436050	2025-07-05 22:11:59.430691	1
21	919001436050	Check Check	\N	\N	\N	\N	\N	Website	Check Check 2\r\n9001436050	2025-07-05 22:13:11.018497	1
22	919001436050	Test Test	\N	\N	\N	\N	\N	Website	test test\r\n9001436050	2025-07-05 22:20:40.409219	1
23	918108111475	Anil Jeet Jhala	\N	\N	\N	\N	\N	Website	Anil Jeet Jhala (+918108111475)	2025-07-06 04:53:48.536528	1
24	919310300104	Digital	\N	\N	\N	\N	\N	Website	aj Dalwani - wtf.digital (+919310300104)\r\nVKI	2025-07-06 04:55:46.161472	1
25	919887600400	Ravi Chauhan	\N	\N	\N	\N	\N	Website	Ravi Chauhan (+919887600400)	2025-07-06 04:56:05.697974	1
26	919116391760	\N	\N	\N	\N	Express Car Service	\N	Website	Sunday, July 6, 2025 at 6:51 AM\r\n9116391760\r\nJaipur\r\n-\t-\t\r\nGeneral Interest\r\n-\t\r\nPublished	2025-07-06 04:58:04.878604	1
27	916377465552	\N	\N	\N	\N	Express Car Service	\N	Website	72\r\nSunday, July 6, 2025 at 3:06 AM\r\n6377465552\r\nJaipur\r\n-\t-\t\r\nExpress Service\r\n-\t\r\nPublished	2025-07-06 04:58:23.541082	1
28	919944274679	\N	Tata	Altroz	\N	\N	\N	Website	10\r\nFriday, July 4, 2025 at 9:19 PM\r\n9944274679\r\n-\t-\t\r\nTata\r\nAltroz\r\npetrol\r\n3,199	2025-07-06 04:59:04.157817	1
29	918108111475	Anil Jeet Jhala	\N	\N	\N	\N	\N	Website	Anil Jeet Jhala (+918108111475)	2025-07-06 06:24:37.19156	1
30	918766666096	\N	\N	\N	\N	\N	\N	Website	+91 87666 66096	2025-07-06 08:08:02.492579	1
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public."user" (id, username, password_hash, name, is_admin) FROM stdin;
4	hemlata	hemlata	Hemlata	f
1	admin	admin123	Admin User	t
5	chetan	chetan123	Chetan	f
6	sneha	sneha123	Sneha	f
3	manisha	manisha123	Manisha	f
2	mamta	mamta123	Mamta	f
7	sarvesh	sarvesh123	Sarvesh	t
8	aprajita	aprajita1234	Aprajita	f
9	shivam	shivam123	Shivam	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.users (id, username, name, password_hash, is_admin, created_at) FROM stdin;
1	admin	Administrator	240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9	t	2025-07-01 06:25:14.34631
2	surakshit	Surakshit Soni	354bb57e4ecc17c73a7caeaaefdf633418ed1f8ef0ac7cf9644a0851e0ffb49f	f	2025-07-01 06:25:14.34631
3	shivam	Shivam	shivam123	f	2025-07-01 06:25:14.34631
\.


--
-- Data for Name: worked_lead; Type: TABLE DATA; Schema: public; Owner: crmadmin
--

COPY public.worked_lead (id, lead_id, user_id, work_date, old_followup_date, new_followup_date, worked_at) FROM stdin;
1	7922	1	2025-07-06	2025-07-05 18:30:00	2025-07-06 18:30:00	2025-07-06 10:14:30.962682
2	5405	6	2025-07-06	2025-07-06 10:00:00	2025-07-06 18:30:00	2025-07-06 10:15:44.620287
\.


--
-- Name: daily_followup_count_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.daily_followup_count_id_seq', 123, true);


--
-- Name: lead_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.lead_id_seq', 7926, true);


--
-- Name: push_subscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.push_subscription_id_seq', 18, true);


--
-- Name: team_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.team_assignment_id_seq', 27, true);


--
-- Name: unassigned_lead_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.unassigned_lead_id_seq', 30, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: worked_lead_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crmadmin
--

SELECT pg_catalog.setval('public.worked_lead_id_seq', 2, true);


--
-- Name: alembic_version alembic_version_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkey PRIMARY KEY (version_num);


--
-- Name: daily_followup_count daily_followup_count_date_user_id_key; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.daily_followup_count
    ADD CONSTRAINT daily_followup_count_date_user_id_key UNIQUE (date, user_id);


--
-- Name: daily_followup_count daily_followup_count_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.daily_followup_count
    ADD CONSTRAINT daily_followup_count_pkey PRIMARY KEY (id);


--
-- Name: lead lead_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.lead
    ADD CONSTRAINT lead_pkey PRIMARY KEY (id);


--
-- Name: push_subscription push_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.push_subscription
    ADD CONSTRAINT push_subscription_pkey PRIMARY KEY (id);


--
-- Name: team_assignment team_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.team_assignment
    ADD CONSTRAINT team_assignment_pkey PRIMARY KEY (id);


--
-- Name: unassigned_lead unassigned_lead_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.unassigned_lead
    ADD CONSTRAINT unassigned_lead_pkey PRIMARY KEY (id);


--
-- Name: push_subscription unique_user_endpoint; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.push_subscription
    ADD CONSTRAINT unique_user_endpoint UNIQUE (user_id, endpoint);


--
-- Name: worked_lead unique_worked_lead_per_day; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.worked_lead
    ADD CONSTRAINT unique_worked_lead_per_day UNIQUE (lead_id, user_id, work_date);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: worked_lead worked_lead_pkey; Type: CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.worked_lead
    ADD CONSTRAINT worked_lead_pkey PRIMARY KEY (id);


--
-- Name: daily_followup_count daily_followup_count_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.daily_followup_count
    ADD CONSTRAINT daily_followup_count_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: push_subscription push_subscription_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.push_subscription
    ADD CONSTRAINT push_subscription_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: team_assignment team_assignment_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.team_assignment
    ADD CONSTRAINT team_assignment_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public."user"(id);


--
-- Name: team_assignment team_assignment_assigned_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.team_assignment
    ADD CONSTRAINT team_assignment_assigned_to_user_id_fkey FOREIGN KEY (assigned_to_user_id) REFERENCES public."user"(id);


--
-- Name: team_assignment team_assignment_unassigned_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.team_assignment
    ADD CONSTRAINT team_assignment_unassigned_lead_id_fkey FOREIGN KEY (unassigned_lead_id) REFERENCES public.unassigned_lead(id);


--
-- Name: unassigned_lead unassigned_lead_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.unassigned_lead
    ADD CONSTRAINT unassigned_lead_created_by_fkey FOREIGN KEY (created_by) REFERENCES public."user"(id);


--
-- Name: worked_lead worked_lead_lead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.worked_lead
    ADD CONSTRAINT worked_lead_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES public.lead(id);


--
-- Name: worked_lead worked_lead_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: crmadmin
--

ALTER TABLE ONLY public.worked_lead
    ADD CONSTRAINT worked_lead_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

