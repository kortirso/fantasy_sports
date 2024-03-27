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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: banned_emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banned_emails (
    id bigint NOT NULL,
    value character varying,
    reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: banned_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.banned_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banned_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.banned_emails_id_seq OWNED BY public.banned_emails.id;


--
-- Name: cups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    league_id bigint NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cups_id_seq OWNED BY public.cups.id;


--
-- Name: cups_pairs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cups_pairs (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    cups_round_id bigint NOT NULL,
    home_name jsonb,
    visitor_name jsonb,
    start_at timestamp(6) without time zone,
    points integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    elimination_kind integer DEFAULT 0 NOT NULL,
    required_wins integer
);


--
-- Name: cups_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cups_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cups_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cups_pairs_id_seq OWNED BY public.cups_pairs.id;


--
-- Name: cups_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cups_rounds (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    cup_id bigint NOT NULL,
    name character varying NOT NULL,
    "position" integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cups_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cups_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cups_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cups_rounds_id_seq OWNED BY public.cups_rounds.id;


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
-- Name: fantasy_cups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_cups (
    id bigint NOT NULL,
    fantasy_league_id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid NOT NULL
);


--
-- Name: fantasy_cups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_cups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_cups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_cups_id_seq OWNED BY public.fantasy_cups.id;


--
-- Name: fantasy_cups_pairs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_cups_pairs (
    id bigint NOT NULL,
    cups_round_id bigint NOT NULL,
    home_lineup_id bigint,
    visitor_lineup_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fantasy_cups_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_cups_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_cups_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_cups_pairs_id_seq OWNED BY public.fantasy_cups_pairs.id;


--
-- Name: fantasy_cups_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_cups_rounds (
    id bigint NOT NULL,
    cup_id bigint NOT NULL,
    week_id bigint NOT NULL,
    name character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fantasy_cups_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_cups_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_cups_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_cups_rounds_id_seq OWNED BY public.fantasy_cups_rounds.id;


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
    invite_code character varying,
    fantasy_leagues_teams_count integer DEFAULT 0 NOT NULL
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
    pointable_type character varying NOT NULL,
    current_place integer DEFAULT 1 NOT NULL
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
    available_chips jsonb DEFAULT '{}'::jsonb NOT NULL,
    season_id bigint NOT NULL
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
-- Name: fantasy_teams_watches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fantasy_teams_watches (
    id bigint NOT NULL,
    fantasy_team_id bigint NOT NULL,
    players_season_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fantasy_teams_watches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fantasy_teams_watches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fantasy_teams_watches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fantasy_teams_watches_id_seq OWNED BY public.fantasy_teams_watches.id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying,
    description text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_id_seq OWNED BY public.feedbacks.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games (
    id bigint NOT NULL,
    week_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    home_season_team_id bigint NOT NULL,
    visitor_season_team_id bigint NOT NULL,
    source integer,
    external_id character varying,
    start_at timestamp(6) without time zone,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    points integer[] DEFAULT '{}'::integer[] NOT NULL,
    difficulty integer[] DEFAULT '{3,3}'::integer[] NOT NULL,
    season_id bigint
);


--
-- Name: COLUMN games.difficulty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.games.difficulty IS 'Game difficulty for teams';


--
-- Name: games_external_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.games_external_sources (
    id bigint NOT NULL,
    game_id bigint NOT NULL,
    source integer NOT NULL,
    external_id character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN games_external_sources.source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.games_external_sources.source IS 'External source name';


--
-- Name: COLUMN games_external_sources.external_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.games_external_sources.external_id IS 'External ID';


--
-- Name: games_external_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.games_external_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_external_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.games_external_sources_id_seq OWNED BY public.games_external_sources.id;


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
-- Name: identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identities (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    uid character varying NOT NULL,
    provider integer DEFAULT 0 NOT NULL,
    login character varying,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.identities_id_seq OWNED BY public.identities.id;


--
-- Name: injuries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.injuries (
    id bigint NOT NULL,
    players_season_id bigint NOT NULL,
    reason jsonb DEFAULT '{}'::jsonb NOT NULL,
    return_at timestamp(6) without time zone,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN injuries.reason; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.injuries.reason IS 'Description of injury';


--
-- Name: COLUMN injuries.return_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.injuries.return_at IS 'Potential return date';


--
-- Name: COLUMN injuries.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.injuries.status IS 'Chance of playing from 0 to 100';


--
-- Name: injuries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.injuries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: injuries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.injuries_id_seq OWNED BY public.injuries.id;


--
-- Name: kudos_achievement_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_achievement_groups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    parent_id bigint,
    "position" integer DEFAULT 0 NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_achievement_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_achievement_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_achievement_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_achievement_groups_id_seq OWNED BY public.kudos_achievement_groups.id;


--
-- Name: kudos_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_achievements (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    award_name character varying NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    kudos_achievement_group_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_achievements_id_seq OWNED BY public.kudos_achievements.id;


--
-- Name: kudos_users_achievements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kudos_users_achievements (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    kudos_achievement_id bigint NOT NULL,
    notified boolean DEFAULT false NOT NULL,
    rank integer,
    points integer,
    title jsonb DEFAULT '{}'::jsonb NOT NULL,
    description jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kudos_users_achievements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kudos_users_achievements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kudos_users_achievements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kudos_users_achievements_id_seq OWNED BY public.kudos_users_achievements.id;


--
-- Name: leagues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leagues (
    id bigint NOT NULL,
    sport_kind integer DEFAULT 0 NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    points_system jsonb DEFAULT '{}'::jsonb NOT NULL,
    slug character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: COLUMN leagues.points_system; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.leagues.points_system IS 'Team points for game result in tournament';


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
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.likes (
    id bigint NOT NULL,
    likeable_id bigint NOT NULL,
    likeable_type character varying NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.likes_id_seq OWNED BY public.likes.id;


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
    active_chips character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    final_points boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN lineups.final_points; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.lineups.final_points IS 'Flag shows that points is completely calculated, no more changes';


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
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    notifyable_id bigint NOT NULL,
    notifyable_type character varying NOT NULL,
    notification_type integer NOT NULL,
    target integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oracul_leagues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oracul_leagues (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    oracul_place_id bigint NOT NULL,
    leagueable_id bigint,
    leagueable_type character varying,
    name character varying NOT NULL,
    invite_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    oracul_leagues_members_count integer DEFAULT 0 NOT NULL
);


--
-- Name: oracul_leagues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oracul_leagues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oracul_leagues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oracul_leagues_id_seq OWNED BY public.oracul_leagues.id;


--
-- Name: oracul_leagues_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oracul_leagues_members (
    id bigint NOT NULL,
    oracul_league_id bigint NOT NULL,
    oracul_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    current_place integer DEFAULT 1 NOT NULL
);


--
-- Name: oracul_leagues_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oracul_leagues_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oracul_leagues_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oracul_leagues_members_id_seq OWNED BY public.oracul_leagues_members.id;


--
-- Name: oracul_places; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oracul_places (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    placeable_id bigint,
    placeable_type character varying,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oracul_places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oracul_places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oracul_places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oracul_places_id_seq OWNED BY public.oracul_places.id;


--
-- Name: oraculs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oraculs (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    name character varying,
    user_id bigint NOT NULL,
    oracul_place_id bigint NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN oraculs.points; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.oraculs.points IS 'Total points of oracul in place';


--
-- Name: oraculs_forecasts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oraculs_forecasts (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    oraculs_lineup_id bigint NOT NULL,
    forecastable_id bigint NOT NULL,
    forecastable_type character varying NOT NULL,
    value integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oraculs_forecasts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oraculs_forecasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oraculs_forecasts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oraculs_forecasts_id_seq OWNED BY public.oraculs_forecasts.id;


--
-- Name: oraculs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oraculs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oraculs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oraculs_id_seq OWNED BY public.oraculs.id;


--
-- Name: oraculs_lineups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oraculs_lineups (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    oracul_id bigint NOT NULL,
    periodable_id bigint NOT NULL,
    periodable_type character varying NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oraculs_lineups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oraculs_lineups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oraculs_lineups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oraculs_lineups_id_seq OWNED BY public.oraculs_lineups.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    id bigint NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    position_kind integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    first_name jsonb DEFAULT '{}'::jsonb NOT NULL,
    last_name jsonb DEFAULT '{}'::jsonb NOT NULL,
    nickname jsonb DEFAULT '{}'::jsonb NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid NOT NULL,
    average_points numeric(8,2) DEFAULT 0.0 NOT NULL,
    form numeric(8,2) DEFAULT 0.0 NOT NULL,
    selected_by_teams_ratio integer DEFAULT 0 NOT NULL
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
    uuid uuid NOT NULL,
    start_at timestamp(6) without time zone,
    members_count integer DEFAULT 1 NOT NULL,
    main_external_source character varying,
    maintenance boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN seasons.members_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.seasons.members_count IS 'Amount of teams in tournament';


--
-- Name: COLUMN seasons.main_external_source; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.seasons.main_external_source IS 'Main external source at the moment';


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
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    shirt_number_string character varying,
    players_season_id bigint NOT NULL
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
    restore_token character varying,
    locale character varying DEFAULT 'en'::character varying NOT NULL,
    reset_password_sent_at timestamp(6) without time zone,
    banned_at timestamp(6) without time zone
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
-- Name: banned_emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banned_emails ALTER COLUMN id SET DEFAULT nextval('public.banned_emails_id_seq'::regclass);


--
-- Name: cups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups ALTER COLUMN id SET DEFAULT nextval('public.cups_id_seq'::regclass);


--
-- Name: cups_pairs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups_pairs ALTER COLUMN id SET DEFAULT nextval('public.cups_pairs_id_seq'::regclass);


--
-- Name: cups_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups_rounds ALTER COLUMN id SET DEFAULT nextval('public.cups_rounds_id_seq'::regclass);


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
-- Name: fantasy_cups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups ALTER COLUMN id SET DEFAULT nextval('public.fantasy_cups_id_seq'::regclass);


--
-- Name: fantasy_cups_pairs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups_pairs ALTER COLUMN id SET DEFAULT nextval('public.fantasy_cups_pairs_id_seq'::regclass);


--
-- Name: fantasy_cups_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups_rounds ALTER COLUMN id SET DEFAULT nextval('public.fantasy_cups_rounds_id_seq'::regclass);


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
-- Name: fantasy_teams_watches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams_watches ALTER COLUMN id SET DEFAULT nextval('public.fantasy_teams_watches_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN id SET DEFAULT nextval('public.feedbacks_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: games_external_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games_external_sources ALTER COLUMN id SET DEFAULT nextval('public.games_external_sources_id_seq'::regclass);


--
-- Name: games_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games_players ALTER COLUMN id SET DEFAULT nextval('public.games_players_id_seq'::regclass);


--
-- Name: identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities ALTER COLUMN id SET DEFAULT nextval('public.identities_id_seq'::regclass);


--
-- Name: injuries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries ALTER COLUMN id SET DEFAULT nextval('public.injuries_id_seq'::regclass);


--
-- Name: kudos_achievement_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievement_groups ALTER COLUMN id SET DEFAULT nextval('public.kudos_achievement_groups_id_seq'::regclass);


--
-- Name: kudos_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements ALTER COLUMN id SET DEFAULT nextval('public.kudos_achievements_id_seq'::regclass);


--
-- Name: kudos_users_achievements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements ALTER COLUMN id SET DEFAULT nextval('public.kudos_users_achievements_id_seq'::regclass);


--
-- Name: leagues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leagues ALTER COLUMN id SET DEFAULT nextval('public.leagues_id_seq'::regclass);


--
-- Name: likes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes ALTER COLUMN id SET DEFAULT nextval('public.likes_id_seq'::regclass);


--
-- Name: lineups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups ALTER COLUMN id SET DEFAULT nextval('public.lineups_id_seq'::regclass);


--
-- Name: lineups_players id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lineups_players ALTER COLUMN id SET DEFAULT nextval('public.lineups_players_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oracul_leagues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_leagues ALTER COLUMN id SET DEFAULT nextval('public.oracul_leagues_id_seq'::regclass);


--
-- Name: oracul_leagues_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_leagues_members ALTER COLUMN id SET DEFAULT nextval('public.oracul_leagues_members_id_seq'::regclass);


--
-- Name: oracul_places id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_places ALTER COLUMN id SET DEFAULT nextval('public.oracul_places_id_seq'::regclass);


--
-- Name: oraculs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs ALTER COLUMN id SET DEFAULT nextval('public.oraculs_id_seq'::regclass);


--
-- Name: oraculs_forecasts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs_forecasts ALTER COLUMN id SET DEFAULT nextval('public.oraculs_forecasts_id_seq'::regclass);


--
-- Name: oraculs_lineups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs_lineups ALTER COLUMN id SET DEFAULT nextval('public.oraculs_lineups_id_seq'::regclass);


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
-- Name: users_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_sessions ALTER COLUMN id SET DEFAULT nextval('public.users_sessions_id_seq'::regclass);


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
-- Name: banned_emails banned_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banned_emails
    ADD CONSTRAINT banned_emails_pkey PRIMARY KEY (id);


--
-- Name: cups_pairs cups_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups_pairs
    ADD CONSTRAINT cups_pairs_pkey PRIMARY KEY (id);


--
-- Name: cups cups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups
    ADD CONSTRAINT cups_pkey PRIMARY KEY (id);


--
-- Name: cups_rounds cups_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cups_rounds
    ADD CONSTRAINT cups_rounds_pkey PRIMARY KEY (id);


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
-- Name: fantasy_cups_pairs fantasy_cups_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups_pairs
    ADD CONSTRAINT fantasy_cups_pairs_pkey PRIMARY KEY (id);


--
-- Name: fantasy_cups fantasy_cups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups
    ADD CONSTRAINT fantasy_cups_pkey PRIMARY KEY (id);


--
-- Name: fantasy_cups_rounds fantasy_cups_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_cups_rounds
    ADD CONSTRAINT fantasy_cups_rounds_pkey PRIMARY KEY (id);


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
-- Name: fantasy_teams_watches fantasy_teams_watches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fantasy_teams_watches
    ADD CONSTRAINT fantasy_teams_watches_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: games_external_sources games_external_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.games_external_sources
    ADD CONSTRAINT games_external_sources_pkey PRIMARY KEY (id);


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
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: injuries injuries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.injuries
    ADD CONSTRAINT injuries_pkey PRIMARY KEY (id);


--
-- Name: kudos_achievement_groups kudos_achievement_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievement_groups
    ADD CONSTRAINT kudos_achievement_groups_pkey PRIMARY KEY (id);


--
-- Name: kudos_achievements kudos_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements
    ADD CONSTRAINT kudos_achievements_pkey PRIMARY KEY (id);


--
-- Name: kudos_users_achievements kudos_users_achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT kudos_users_achievements_pkey PRIMARY KEY (id);


--
-- Name: leagues leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


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
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oracul_leagues_members oracul_leagues_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_leagues_members
    ADD CONSTRAINT oracul_leagues_members_pkey PRIMARY KEY (id);


--
-- Name: oracul_leagues oracul_leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_leagues
    ADD CONSTRAINT oracul_leagues_pkey PRIMARY KEY (id);


--
-- Name: oracul_places oracul_places_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oracul_places
    ADD CONSTRAINT oracul_places_pkey PRIMARY KEY (id);


--
-- Name: oraculs_forecasts oraculs_forecasts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs_forecasts
    ADD CONSTRAINT oraculs_forecasts_pkey PRIMARY KEY (id);


--
-- Name: oraculs_lineups oraculs_lineups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs_lineups
    ADD CONSTRAINT oraculs_lineups_pkey PRIMARY KEY (id);


--
-- Name: oraculs oraculs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oraculs
    ADD CONSTRAINT oraculs_pkey PRIMARY KEY (id);


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
-- Name: idx_on_fantasy_team_id_players_season_id_46f81fc3f4; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_fantasy_team_id_players_season_id_46f81fc3f4 ON public.fantasy_teams_watches USING btree (fantasy_team_id, players_season_id);


--
-- Name: idx_on_notifyable_id_notifyable_type_notification_t_a2f7d79115; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_notifyable_id_notifyable_type_notification_t_a2f7d79115 ON public.notifications USING btree (notifyable_id, notifyable_type, notification_type, target);


--
-- Name: index_banned_emails_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_banned_emails_on_value ON public.banned_emails USING btree (value);


--
-- Name: index_cups_on_league_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_on_league_id ON public.cups USING btree (league_id);


--
-- Name: index_cups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_on_uuid ON public.cups USING btree (uuid);


--
-- Name: index_cups_pairs_on_cups_round_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_pairs_on_cups_round_id ON public.cups_pairs USING btree (cups_round_id);


--
-- Name: index_cups_pairs_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_pairs_on_uuid ON public.cups_pairs USING btree (uuid);


--
-- Name: index_cups_rounds_on_cup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_rounds_on_cup_id ON public.cups_rounds USING btree (cup_id);


--
-- Name: index_cups_rounds_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cups_rounds_on_uuid ON public.cups_rounds USING btree (uuid);


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
-- Name: index_fantasy_cups_on_fantasy_league_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_on_fantasy_league_id ON public.fantasy_cups USING btree (fantasy_league_id);


--
-- Name: index_fantasy_cups_pairs_on_cups_round_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_pairs_on_cups_round_id ON public.fantasy_cups_pairs USING btree (cups_round_id);


--
-- Name: index_fantasy_cups_pairs_on_home_lineup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_pairs_on_home_lineup_id ON public.fantasy_cups_pairs USING btree (home_lineup_id);


--
-- Name: index_fantasy_cups_pairs_on_visitor_lineup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_pairs_on_visitor_lineup_id ON public.fantasy_cups_pairs USING btree (visitor_lineup_id);


--
-- Name: index_fantasy_cups_rounds_on_cup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_rounds_on_cup_id ON public.fantasy_cups_rounds USING btree (cup_id);


--
-- Name: index_fantasy_cups_rounds_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fantasy_cups_rounds_on_week_id ON public.fantasy_cups_rounds USING btree (week_id);


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
-- Name: index_feedbacks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_feedbacks_on_user_id ON public.feedbacks USING btree (user_id);


--
-- Name: index_games_external_sources_on_game_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_external_sources_on_game_id ON public.games_external_sources USING btree (game_id);


--
-- Name: index_games_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_season_id ON public.games USING btree (season_id);


--
-- Name: index_games_on_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_games_on_week_id ON public.games USING btree (week_id);


--
-- Name: index_games_players_on_game_id_and_teams_player_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_games_players_on_game_id_and_teams_player_id ON public.games_players USING btree (game_id, teams_player_id);


--
-- Name: index_identities_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_identities_on_uid_and_provider ON public.identities USING btree (uid, provider);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_identities_on_user_id ON public.identities USING btree (user_id);


--
-- Name: index_injuries_on_players_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_injuries_on_players_season_id ON public.injuries USING btree (players_season_id);


--
-- Name: index_kudos_achievement_groups_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievement_groups_on_parent_id ON public.kudos_achievement_groups USING btree (parent_id);


--
-- Name: index_kudos_achievement_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kudos_achievement_groups_on_uuid ON public.kudos_achievement_groups USING btree (uuid);


--
-- Name: index_kudos_achievements_on_award_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievements_on_award_name ON public.kudos_achievements USING btree (award_name);


--
-- Name: index_kudos_achievements_on_kudos_achievement_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_achievements_on_kudos_achievement_group_id ON public.kudos_achievements USING btree (kudos_achievement_group_id);


--
-- Name: index_kudos_achievements_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kudos_achievements_on_uuid ON public.kudos_achievements USING btree (uuid);


--
-- Name: index_kudos_users_achievements_on_kudos_achievement_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_users_achievements_on_kudos_achievement_id ON public.kudos_users_achievements USING btree (kudos_achievement_id);


--
-- Name: index_kudos_users_achievements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kudos_users_achievements_on_user_id ON public.kudos_users_achievements USING btree (user_id);


--
-- Name: index_likes_on_user_id_and_likeable_id_and_likeable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_likes_on_user_id_and_likeable_id_and_likeable_type ON public.likes USING btree (user_id, likeable_id, likeable_type);


--
-- Name: index_lineups_on_fantasy_team_id_and_week_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lineups_on_fantasy_team_id_and_week_id ON public.lineups USING btree (fantasy_team_id, week_id);


--
-- Name: index_oracul_leagues_members_on_oracul_league_id_and_oracul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oracul_leagues_members_on_oracul_league_id_and_oracul_id ON public.oracul_leagues_members USING btree (oracul_league_id, oracul_id);


--
-- Name: index_oracul_leagues_on_invite_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_leagues_on_invite_code ON public.oracul_leagues USING btree (invite_code);


--
-- Name: index_oracul_leagues_on_leagueable_id_and_leagueable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_leagues_on_leagueable_id_and_leagueable_type ON public.oracul_leagues USING btree (leagueable_id, leagueable_type);


--
-- Name: index_oracul_leagues_on_oracul_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_leagues_on_oracul_place_id ON public.oracul_leagues USING btree (oracul_place_id);


--
-- Name: index_oracul_leagues_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_leagues_on_uuid ON public.oracul_leagues USING btree (uuid);


--
-- Name: index_oracul_places_on_placeable_id_and_placeable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_places_on_placeable_id_and_placeable_type ON public.oracul_places USING btree (placeable_id, placeable_type);


--
-- Name: index_oracul_places_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oracul_places_on_uuid ON public.oracul_places USING btree (uuid);


--
-- Name: index_oraculs_forecasts_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oraculs_forecasts_on_uuid ON public.oraculs_forecasts USING btree (uuid);


--
-- Name: index_oraculs_lineups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oraculs_lineups_on_uuid ON public.oraculs_lineups USING btree (uuid);


--
-- Name: index_oraculs_on_oracul_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oraculs_on_oracul_place_id ON public.oraculs USING btree (oracul_place_id);


--
-- Name: index_oraculs_on_user_id_and_oracul_place_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oraculs_on_user_id_and_oracul_place_id ON public.oraculs USING btree (user_id, oracul_place_id);


--
-- Name: index_oraculs_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oraculs_on_uuid ON public.oraculs USING btree (uuid);


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
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_sessions_on_user_id ON public.users_sessions USING btree (user_id);


--
-- Name: index_users_sessions_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_sessions_on_uuid ON public.users_sessions USING btree (uuid);


--
-- Name: index_weeks_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_weeks_on_season_id ON public.weeks USING btree (season_id);


--
-- Name: kudos_users_achievements_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX kudos_users_achievements_unique_index ON public.kudos_users_achievements USING btree (user_id, kudos_achievement_id);


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
-- Name: unique_oraculs_forecasts_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_oraculs_forecasts_index ON public.oraculs_forecasts USING btree (oraculs_lineup_id, forecastable_id, forecastable_type);


--
-- Name: unique_oraculs_lineups_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_oraculs_lineups_index ON public.oraculs_lineups USING btree (oracul_id, periodable_id, periodable_type);


--
-- Name: que_jobs que_job_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_job_notify AFTER INSERT ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_job_notify();


--
-- Name: que_jobs que_state_notify; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER que_state_notify AFTER INSERT OR DELETE OR UPDATE ON public.que_jobs FOR EACH ROW WHEN ((NOT (COALESCE(current_setting('que.skip_notify'::text, true), ''::text) = 'true'::text))) EXECUTE FUNCTION public.que_state_notify();


--
-- Name: kudos_users_achievements fk_rails_4621adbc67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT fk_rails_4621adbc67 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: kudos_users_achievements fk_rails_db98df5998; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_users_achievements
    ADD CONSTRAINT fk_rails_db98df5998 FOREIGN KEY (kudos_achievement_id) REFERENCES public.kudos_achievements(id);


--
-- Name: kudos_achievements fk_rails_e8b9da81fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kudos_achievements
    ADD CONSTRAINT fk_rails_e8b9da81fe FOREIGN KEY (kudos_achievement_group_id) REFERENCES public.kudos_achievement_groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240327093404'),
('20240327061925'),
('20240322135806'),
('20240228183340'),
('20240228162958'),
('20240228160732'),
('20240228155258'),
('20240227151458'),
('20240226160940'),
('20240226155550'),
('20240226113330'),
('20240226110142'),
('20240226104528'),
('20240226091134'),
('20240226072155'),
('20240226070753'),
('20240202104609'),
('20240202102420'),
('20240131085828'),
('20240131082218'),
('20231229085758'),
('20231218114627'),
('20231218081640'),
('20231215052917'),
('20231206105837'),
('20231122115612'),
('20231119135501'),
('20231118141932'),
('20231116182940'),
('20231116182358'),
('20231111130838'),
('20231110155626'),
('20231104141458'),
('20231029174712'),
('20231028174302'),
('20231028150107'),
('20231028144736'),
('20231027124827'),
('20231021133617'),
('20231008190606'),
('20230928164428'),
('20221226171032'),
('20221208151825'),
('20221201161232'),
('20221129163136'),
('20221125182904'),
('20221125141937'),
('20221124191706'),
('20221115163454'),
('20221112161902'),
('20221112152958'),
('20221108144820'),
('20221104162149'),
('20221026162239'),
('20221023112647'),
('20221020193541'),
('20221019180812'),
('20221019155516'),
('20221013182131'),
('20221009184632'),
('20221009183354'),
('20221009181657'),
('20221009180348'),
('20220817183402'),
('20220530191703'),
('20220528200221'),
('20220522171114'),
('20220516190525'),
('20220514192459'),
('20220514185814'),
('20220502115026'),
('20220415183204'),
('20220413193123'),
('20220110184922'),
('20220110183050'),
('20211224184836'),
('20211219120512'),
('20211215174418'),
('20211214153104'),
('20211208164726'),
('20211203095529'),
('20211129075659'),
('20211129074409'),
('20211127175217'),
('20211127113709'),
('20211127112751'),
('20211125182342'),
('20211119191040'),
('20211119150305'),
('20211116191813'),
('20211116183814'),
('20211115190546'),
('20211115185128'),
('20211115161032'),
('20211114192023'),
('20211113185715'),
('20211113172635'),
('20211113170404'),
('20211112185530'),
('20211111192625'),
('20211111182627'),
('20211110192129'),
('20211110190942'),
('20211107185742'),
('20211107102501'),
('20211103182015'),
('20211101190250'),
('20211101190000');

