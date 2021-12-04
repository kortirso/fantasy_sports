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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fantasy_leagues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_leagues (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    leagueable_id integer,
    leagueable_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    season_id integer
);


--
-- Name: fantasy_leagues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_leagues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_leagues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_leagues_id_seq OWNED BY public.fantasy_leagues.id;


--
-- Name: fantasy_leagues_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_leagues_teams (
    id bigint NOT NULL,
    fantasy_league_id integer,
    fantasy_team_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fantasy_leagues_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_leagues_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_leagues_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_leagues_teams_id_seq OWNED BY public.fantasy_leagues_teams.id;


--
-- Name: fantasy_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_teams (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    user_id integer,
    name character varying DEFAULT ''::character varying NOT NULL,
    sport_kind integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    budget_cents integer DEFAULT 10000 NOT NULL,
    free_transfers integer DEFAULT 0 NOT NULL
);


--
-- Name: fantasy_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_teams_id_seq OWNED BY public.fantasy_teams.id;


--
-- Name: fantasy_teams_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_teams_players (
    id bigint NOT NULL,
    fantasy_team_id integer,
    teams_player_id integer
);


--
-- Name: fantasy_teams_players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_teams_players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_teams_players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_teams_players_id_seq OWNED BY public.fantasy_teams_players.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    week_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    home_season_team_id integer,
    visitor_season_team_id integer
);


--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: games_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games_players (
    id bigint NOT NULL,
    game_id integer,
    teams_player_id integer,
    position_kind integer DEFAULT 0 NOT NULL,
    statistic jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    points integer
);


--
-- Name: games_players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.games_players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.games_players_id_seq OWNED BY public.games_players.id;


--
-- Name: leagues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leagues (
    id bigint NOT NULL,
    sport_kind integer DEFAULT 0 NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: leagues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leagues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leagues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leagues_id_seq OWNED BY public.leagues.id;


--
-- Name: lineups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lineups (
    id bigint NOT NULL,
    fantasy_team_id integer,
    week_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    points integer DEFAULT 0 NOT NULL
);


--
-- Name: lineups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lineups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lineups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lineups_id_seq OWNED BY public.lineups.id;


--
-- Name: lineups_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lineups_players (
    id bigint NOT NULL,
    lineup_id integer,
    teams_player_id integer,
    active boolean DEFAULT false NOT NULL,
    change_order integer DEFAULT 0 NOT NULL,
    points integer
);


--
-- Name: lineups_players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lineups_players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lineups_players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lineups_players_id_seq OWNED BY public.lineups_players.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    position_kind integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id bigint NOT NULL,
    league_id integer,
    name character varying DEFAULT ''::character varying NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid NOT NULL
);


--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: seasons_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons_teams (
    id bigint NOT NULL,
    season_id integer,
    team_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: seasons_teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_teams_id_seq OWNED BY public.seasons_teams.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: teams_players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams_players (
    id bigint NOT NULL,
    seasons_team_id integer,
    player_id integer,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    price_cents integer DEFAULT 0 NOT NULL
);


--
-- Name: teams_players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_players_id_seq OWNED BY public.teams_players.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    password_digest character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    role integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeks (
    id bigint NOT NULL,
    season_id integer,
    "position" integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL
);


--
-- Name: weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weeks_id_seq OWNED BY public.weeks.id;


--
-- Name: fantasy_leagues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_leagues ALTER COLUMN id SET DEFAULT nextval('public.fantasy_leagues_id_seq'::regclass);


--
-- Name: fantasy_leagues_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_leagues_teams ALTER COLUMN id SET DEFAULT nextval('public.fantasy_leagues_teams_id_seq'::regclass);


--
-- Name: fantasy_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams ALTER COLUMN id SET DEFAULT nextval('public.fantasy_teams_id_seq'::regclass);


--
-- Name: fantasy_teams_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams_players ALTER COLUMN id SET DEFAULT nextval('public.fantasy_teams_players_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: games_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games_players ALTER COLUMN id SET DEFAULT nextval('public.games_players_id_seq'::regclass);


--
-- Name: leagues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leagues ALTER COLUMN id SET DEFAULT nextval('public.leagues_id_seq'::regclass);


--
-- Name: lineups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups ALTER COLUMN id SET DEFAULT nextval('public.lineups_id_seq'::regclass);


--
-- Name: lineups_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups_players ALTER COLUMN id SET DEFAULT nextval('public.lineups_players_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: seasons_teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons_teams ALTER COLUMN id SET DEFAULT nextval('public.seasons_teams_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: teams_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_players ALTER COLUMN id SET DEFAULT nextval('public.teams_players_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks ALTER COLUMN id SET DEFAULT nextval('public.weeks_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: fantasy_leagues fantasy_leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_leagues
    ADD CONSTRAINT fantasy_leagues_pkey PRIMARY KEY (id);


--
-- Name: fantasy_leagues_teams fantasy_leagues_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_leagues_teams
    ADD CONSTRAINT fantasy_leagues_teams_pkey PRIMARY KEY (id);


--
-- Name: fantasy_teams fantasy_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams
    ADD CONSTRAINT fantasy_teams_pkey PRIMARY KEY (id);


--
-- Name: fantasy_teams_players fantasy_teams_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams_players
    ADD CONSTRAINT fantasy_teams_players_pkey PRIMARY KEY (id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: games_players games_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games_players
    ADD CONSTRAINT games_players_pkey PRIMARY KEY (id);


--
-- Name: leagues leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_pkey PRIMARY KEY (id);


--
-- Name: lineups lineups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups
    ADD CONSTRAINT lineups_pkey PRIMARY KEY (id);


--
-- Name: lineups_players lineups_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups_players
    ADD CONSTRAINT lineups_players_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: seasons_teams seasons_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons_teams
    ADD CONSTRAINT seasons_teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams_players teams_players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams_players
    ADD CONSTRAINT teams_players_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weeks weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT weeks_pkey PRIMARY KEY (id);


--
-- Name: fantasy_team_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fantasy_team_index ON public.fantasy_leagues_teams USING btree (fantasy_league_id, fantasy_team_id);


--
-- Name: fantasy_teams_and_players_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fantasy_teams_and_players_index ON public.fantasy_teams_players USING btree (fantasy_team_id, teams_player_id);


--
-- Name: index_fantasy_leagues_on_leagueable_id_and_leagueable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_leagues_on_leagueable_id_and_leagueable_type ON public.fantasy_leagues USING btree (leagueable_id, leagueable_type);


--
-- Name: index_fantasy_leagues_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_leagues_on_season_id ON public.fantasy_leagues USING btree (season_id);


--
-- Name: index_fantasy_teams_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_teams_on_user_id ON public.fantasy_teams USING btree (user_id);


--
-- Name: index_fantasy_teams_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_teams_on_uuid ON public.fantasy_teams USING btree (uuid);


--
-- Name: index_games_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_week_id ON public.games USING btree (week_id);


--
-- Name: index_games_players_on_game_id_and_teams_player_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_games_players_on_game_id_and_teams_player_id ON public.games_players USING btree (game_id, teams_player_id);


--
-- Name: index_lineups_on_fantasy_team_id_and_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lineups_on_fantasy_team_id_and_week_id ON public.lineups USING btree (fantasy_team_id, week_id);


--
-- Name: index_seasons_on_league_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seasons_on_league_id ON public.seasons USING btree (league_id);


--
-- Name: index_seasons_teams_on_season_id_and_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_seasons_teams_on_season_id_and_team_id ON public.seasons_teams USING btree (season_id, team_id);


--
-- Name: index_teams_players_on_seasons_team_id_and_player_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_players_on_seasons_team_id_and_player_id ON public.teams_players USING btree (seasons_team_id, player_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_weeks_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_season_id ON public.weeks USING btree (season_id);


--
-- Name: lineup_player_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lineup_player_index ON public.lineups_players USING btree (lineup_id, teams_player_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20211101190000'),
('20211101190250'),
('20211103182015'),
('20211107102501'),
('20211107185742'),
('20211110190942'),
('20211110192129'),
('20211111182627'),
('20211111192625'),
('20211112185530'),
('20211113170404'),
('20211113172635'),
('20211113185715'),
('20211114192023'),
('20211115161032'),
('20211115185128'),
('20211115190546'),
('20211116183814'),
('20211116191813'),
('20211119150305'),
('20211119191040'),
('20211125182342'),
('20211127112751'),
('20211127113709'),
('20211127175217'),
('20211129074409'),
('20211129075659'),
('20211203095529');


