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


--
-- Name: que_validate_tags(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    job_class text NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error_message text,
    queue text DEFAULT 'default'::text NOT NULL,
    last_error_backtrace text,
    finished_at timestamp with time zone,
    expired_at timestamp with time zone,
    args jsonb DEFAULT '[]'::jsonb NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    job_schema_version integer NOT NULL,
    kwargs jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT error_length CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),
    CONSTRAINT job_class_length CHECK ((char_length(
CASE job_class
    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
    ELSE job_class
END) <= 200)),
    CONSTRAINT queue_length CHECK ((char_length(queue) <= 100)),
    CONSTRAINT valid_args CHECK ((jsonb_typeof(args) = 'array'::text)),
    CONSTRAINT valid_data CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.que_jobs IS '7';


--
-- Name: que_determine_job_state(public.que_jobs); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;


--
-- Name: que_job_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > now() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE
            listening AND
            queues @> ARRAY[NEW.queue] AND
            ql.job_schema_version = NEW.job_schema_version
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;


--
-- Name: que_state_notify(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(now()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;


--
-- Name: achievement_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.achievement_groups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    parent_id bigint,
    "position" integer DEFAULT 0 NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: achievement_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.achievement_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievement_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.achievement_groups_id_seq OWNED BY public.achievement_groups.id;


--
-- Name: achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.achievements (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    award_name character varying NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    achievement_group_id bigint NOT NULL
);


--
-- Name: achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.achievements_id_seq OWNED BY public.achievements.id;


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
-- Name: emailbutler_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emailbutler_messages (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    mailer character varying NOT NULL,
    action character varying NOT NULL,
    params jsonb DEFAULT '{}'::jsonb NOT NULL,
    send_to character varying[],
    status integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp(6) without time zone,
    lock_version integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: emailbutler_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emailbutler_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emailbutler_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emailbutler_messages_id_seq OWNED BY public.emailbutler_messages.id;


--
-- Name: event_store_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events (
    id bigint NOT NULL,
    event_id uuid NOT NULL,
    event_type character varying NOT NULL,
    metadata bytea,
    data bytea NOT NULL,
    created_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone
);


--
-- Name: event_store_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_store_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_store_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_store_events_id_seq OWNED BY public.event_store_events.id;


--
-- Name: event_store_events_in_streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events_in_streams (
    id bigint NOT NULL,
    stream character varying NOT NULL,
    "position" integer,
    event_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_store_events_in_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_store_events_in_streams_id_seq OWNED BY public.event_store_events_in_streams.id;


--
-- Name: fantasy_leagues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_leagues (
    id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    leagueable_id bigint NOT NULL,
    leagueable_type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    season_id bigint NOT NULL,
    global boolean DEFAULT true NOT NULL,
    uuid uuid NOT NULL,
    invite_code character varying
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
    fantasy_league_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pointable_id bigint NOT NULL,
    pointable_type character varying NOT NULL
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
    user_id bigint NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    sport_kind integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    budget_cents integer DEFAULT 10000 NOT NULL,
    points numeric(8,2) DEFAULT 0 NOT NULL,
    available_chips jsonb DEFAULT '{}'::jsonb NOT NULL
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
    fantasy_team_id bigint NOT NULL,
    teams_player_id bigint NOT NULL
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
    week_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    home_season_team_id bigint NOT NULL,
    visitor_season_team_id bigint NOT NULL,
    source integer,
    external_id character varying,
    start_at timestamp(6) without time zone,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    points integer[] DEFAULT '{}'::integer[] NOT NULL
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
    game_id bigint NOT NULL,
    teams_player_id bigint NOT NULL,
    position_kind integer DEFAULT 0 NOT NULL,
    statistic jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    points numeric(8,2),
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    seasons_team_id bigint NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL,
    maintenance boolean DEFAULT false NOT NULL
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
    fantasy_team_id bigint NOT NULL,
    week_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    points numeric(8,2) DEFAULT 0 NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    free_transfers_amount integer DEFAULT 0 NOT NULL,
    transfers_limited boolean DEFAULT true,
    penalty_points integer DEFAULT 0 NOT NULL,
    active_chips character varying[] DEFAULT '{}'::character varying[] NOT NULL
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
    lineup_id bigint NOT NULL,
    teams_player_id bigint NOT NULL,
    change_order integer DEFAULT 0 NOT NULL,
    points numeric(8,2),
    status integer DEFAULT 0 NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    statistic jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL,
    points numeric(8,2) DEFAULT 0 NOT NULL,
    statistic jsonb DEFAULT '{}'::jsonb NOT NULL
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
-- Name: players_seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players_seasons (
    id bigint NOT NULL,
    player_id bigint NOT NULL,
    season_id bigint NOT NULL,
    points numeric(8,2) DEFAULT 0 NOT NULL,
    statistic jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: players_seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.players_seasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: players_seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.players_seasons_id_seq OWNED BY public.players_seasons.id;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.que_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.que_jobs_id_seq OWNED BY public.que_jobs.id;


--
-- Name: que_lockers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.que_lockers (
    pid integer NOT NULL,
    worker_count integer NOT NULL,
    worker_priorities integer[] NOT NULL,
    ruby_pid integer NOT NULL,
    ruby_hostname text NOT NULL,
    queues text[] NOT NULL,
    listening boolean NOT NULL,
    job_schema_version integer DEFAULT 1,
    CONSTRAINT valid_queues CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),
    CONSTRAINT valid_worker_priorities CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);


--
-- Name: que_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.que_values (
    key text NOT NULL,
    value jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_value CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');


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
    league_id bigint NOT NULL,
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
    season_id bigint NOT NULL,
    team_id bigint NOT NULL,
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
    updated_at timestamp(6) without time zone NOT NULL,
    short_name character varying,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL
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
    seasons_team_id bigint NOT NULL,
    player_id bigint NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    price_cents integer DEFAULT 0 NOT NULL,
    shirt_number integer,
    form double precision DEFAULT 0.0 NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL
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
-- Name: transfers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transfers (
    id bigint NOT NULL,
    teams_player_id bigint NOT NULL,
    direction integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lineup_id bigint NOT NULL
);


--
-- Name: transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transfers_id_seq OWNED BY public.transfers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    password_digest character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    restore_token character varying
);


--
-- Name: users_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_achievements (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    achievement_id bigint NOT NULL,
    notified boolean DEFAULT false NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_achievements_id_seq OWNED BY public.users_achievements.id;


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
-- Name: users_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_sessions (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_sessions_id_seq OWNED BY public.users_sessions.id;


--
-- Name: weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weeks (
    id bigint NOT NULL,
    season_id bigint NOT NULL,
    "position" integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    deadline_at timestamp(6) without time zone,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL
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
-- Name: achievement_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievement_groups ALTER COLUMN id SET DEFAULT nextval('public.achievement_groups_id_seq'::regclass);


--
-- Name: achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements ALTER COLUMN id SET DEFAULT nextval('public.achievements_id_seq'::regclass);


--
-- Name: emailbutler_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emailbutler_messages ALTER COLUMN id SET DEFAULT nextval('public.emailbutler_messages_id_seq'::regclass);


--
-- Name: event_store_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_id_seq'::regclass);


--
-- Name: event_store_events_in_streams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_in_streams_id_seq'::regclass);


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
-- Name: players_seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players_seasons ALTER COLUMN id SET DEFAULT nextval('public.players_seasons_id_seq'::regclass);


--
-- Name: que_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs ALTER COLUMN id SET DEFAULT nextval('public.que_jobs_id_seq'::regclass);


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
-- Name: transfers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transfers ALTER COLUMN id SET DEFAULT nextval('public.transfers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_achievements ALTER COLUMN id SET DEFAULT nextval('public.users_achievements_id_seq'::regclass);


--
-- Name: users_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions ALTER COLUMN id SET DEFAULT nextval('public.users_sessions_id_seq'::regclass);


--
-- Name: weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks ALTER COLUMN id SET DEFAULT nextval('public.weeks_id_seq'::regclass);


--
-- Name: achievement_groups achievement_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievement_groups
    ADD CONSTRAINT achievement_groups_pkey PRIMARY KEY (id);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: emailbutler_messages emailbutler_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emailbutler_messages
    ADD CONSTRAINT emailbutler_messages_pkey PRIMARY KEY (id);


--
-- Name: event_store_events_in_streams event_store_events_in_streams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams
    ADD CONSTRAINT event_store_events_in_streams_pkey PRIMARY KEY (id);


--
-- Name: event_store_events event_store_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events
    ADD CONSTRAINT event_store_events_pkey PRIMARY KEY (id);


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
-- Name: players_seasons players_seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players_seasons
    ADD CONSTRAINT players_seasons_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (id);


--
-- Name: que_lockers que_lockers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_lockers
    ADD CONSTRAINT que_lockers_pkey PRIMARY KEY (pid);


--
-- Name: que_values que_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.que_values
    ADD CONSTRAINT que_values_pkey PRIMARY KEY (key);


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
-- Name: transfers transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- Name: users_achievements users_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_achievements
    ADD CONSTRAINT users_achievements_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_sessions users_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions
    ADD CONSTRAINT users_sessions_pkey PRIMARY KEY (id);


--
-- Name: weeks weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weeks
    ADD CONSTRAINT weeks_pkey PRIMARY KEY (id);


--
-- Name: fantasy_teams_and_players_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fantasy_teams_and_players_index ON public.fantasy_teams_players USING btree (fantasy_team_id, teams_player_id);


--
-- Name: index_achievement_groups_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_achievement_groups_on_parent_id ON public.achievement_groups USING btree (parent_id);


--
-- Name: index_achievement_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_achievement_groups_on_uuid ON public.achievement_groups USING btree (uuid);


--
-- Name: index_achievements_on_award_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_achievements_on_award_name ON public.achievements USING btree (award_name);


--
-- Name: index_achievements_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_achievements_on_uuid ON public.achievements USING btree (uuid);


--
-- Name: index_emailbutler_messages_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emailbutler_messages_on_uuid ON public.emailbutler_messages USING btree (uuid);


--
-- Name: index_event_store_events_in_streams_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_in_streams_on_created_at ON public.event_store_events_in_streams USING btree (created_at);


--
-- Name: index_event_store_events_in_streams_on_stream_and_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_event_id ON public.event_store_events_in_streams USING btree (stream, event_id);


--
-- Name: index_event_store_events_in_streams_on_stream_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_position ON public.event_store_events_in_streams USING btree (stream, "position");


--
-- Name: index_event_store_events_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_created_at ON public.event_store_events USING btree (created_at);


--
-- Name: index_event_store_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_on_event_id ON public.event_store_events USING btree (event_id);


--
-- Name: index_event_store_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_event_type ON public.event_store_events USING btree (event_type);


--
-- Name: index_event_store_events_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_valid_at ON public.event_store_events USING btree (valid_at);


--
-- Name: index_fantasy_leagues_on_leagueable_id_and_leagueable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_leagues_on_leagueable_id_and_leagueable_type ON public.fantasy_leagues USING btree (leagueable_id, leagueable_type);


--
-- Name: index_fantasy_leagues_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_leagues_on_season_id ON public.fantasy_leagues USING btree (season_id);


--
-- Name: index_fantasy_leagues_teams_on_pointable_id_and_pointable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_leagues_teams_on_pointable_id_and_pointable_type ON public.fantasy_leagues_teams USING btree (pointable_id, pointable_type);


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
-- Name: index_players_seasons_on_player_id_and_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_players_seasons_on_player_id_and_season_id ON public.players_seasons USING btree (player_id, season_id);


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
-- Name: index_transfers_on_teams_player_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transfers_on_teams_player_id ON public.transfers USING btree (teams_player_id);


--
-- Name: index_users_achievements_on_user_id_and_achievement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_achievements_on_user_id_and_achievement_id ON public.users_achievements USING btree (user_id, achievement_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_user_id ON public.users_sessions USING btree (user_id);


--
-- Name: index_users_sessions_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_uuid ON public.users_sessions USING btree (uuid);


--
-- Name: index_weeks_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_season_id ON public.weeks USING btree (season_id);


--
-- Name: lineup_player_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX lineup_player_index ON public.lineups_players USING btree (lineup_id, teams_player_id);


--
-- Name: que_jobs_args_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_args_gin_idx ON public.que_jobs USING gin (args jsonb_path_ops);


--
-- Name: que_jobs_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_data_gin_idx ON public.que_jobs USING gin (data jsonb_path_ops);


--
-- Name: que_jobs_kwargs_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_jobs_kwargs_gin_idx ON public.que_jobs USING gin (kwargs jsonb_path_ops);


--
-- Name: que_poll_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX que_poll_idx ON public.que_jobs USING btree (job_schema_version, queue, priority, run_at, id) WHERE ((finished_at IS NULL) AND (expired_at IS NULL));


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_state_notify();


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
('20211203095529'),
('20211208164726'),
('20211214153104'),
('20211215174418'),
('20211219120512'),
('20211224184836'),
('20220110183050'),
('20220110184922'),
('20220413193123'),
('20220415183204'),
('20220502115026'),
('20220514185814'),
('20220514192459'),
('20220516190525'),
('20220522171114'),
('20220528200221'),
('20220530191703'),
('20220817183402'),
('20221009180348'),
('20221009181657'),
('20221009183354'),
('20221009184632'),
('20221013182131'),
('20221019155516'),
('20221019180812'),
('20221020193541'),
('20221023112647'),
('20221026162239'),
('20221104162149'),
('20221108144820'),
('20221112152958'),
('20221112161902'),
('20221115163454'),
('20221123171450'),
('20221124191706'),
('20221125141937'),
('20221125182904'),
('20221127160704'),
('20221127172427'),
('20221129163136');


