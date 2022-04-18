--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2 (Debian 14.2-1.pgdg110+1)
-- Dumped by pg_dump version 14.2

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
-- Name: reddit; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE reddit WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE reddit OWNER TO postgres;

\connect reddit

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
-- Name: DATABASE reddit; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE reddit IS 'default administrative connection database';


--
-- Name: trigger_append_score_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_append_score_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.score_updated_at = array_append(NEW.score_updated_at, NOW());
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trigger_append_score_timestamp() OWNER TO postgres;

--
-- Name: trigger_set_parent_comment_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_set_parent_comment_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.parent_comment_id IS NULL
    THEN
        IF NEW.parent_id IS NOT NULL AND substring(NEW.parent_id, 1, 3) = 't1_' AND exists(
            SELECT id
            FROM comments
            WHERE comments.id = substring(NEW.parent_id, 4)
        )
        THEN
            NEW.parent_comment_id = substring(NEW.parent_id, 4);
        END IF;
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.trigger_set_parent_comment_id() OWNER TO postgres;

--
-- Name: trigger_set_submission_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_set_submission_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.submission_id IS NULL
    THEN
        IF NEW.link_id IS NOT NULL AND substring(NEW.link_id, 1, 3) = 't3_' AND exists(
            SELECT id
            FROM submissions
            WHERE submissions.id = substring(NEW.link_id, 4)
        )
        THEN
            NEW.submission_id = substring(NEW.link_id, 4);
        END IF;
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.trigger_set_submission_id() OWNER TO postgres;

--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = (now() at time zone 'utc');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trigger_set_timestamp() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    author_id character varying,
    body text,
    created_utc timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    id character varying NOT NULL,
    link_id character varying,
    parent_id character varying,
    parent_comment_id character varying,
    permalink text,
    score integer DEFAULT 0,
    score_history integer[] DEFAULT ARRAY[]::integer[],
    score_updated_at timestamp without time zone[] DEFAULT ARRAY[]::timestamp without time zone[],
    submission_id character varying,
    subreddit_id character varying,
    updated_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text)
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: COLUMN comments.author_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.author_id IS 'The ID of the Redditor.';


--
-- Name: COLUMN comments.body; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.body IS 'The body of the comment, as Markdown.';


--
-- Name: COLUMN comments.created_utc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.created_utc IS 'Time the comment was created, represented in Unix Time.';


--
-- Name: COLUMN comments.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.id IS 'The ID of the comment.';


--
-- Name: COLUMN comments.link_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.link_id IS 'The submission id that the comment belongs to.';


--
-- Name: COLUMN comments.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.parent_id IS 'The ID of the parent comment.';


--
-- Name: COLUMN comments.parent_comment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.parent_comment_id IS 'The comment parent id within this table.';


--
-- Name: COLUMN comments.permalink; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.permalink IS 'A permalink for the comment.';


--
-- Name: COLUMN comments.score; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.score IS 'The most recent score of this comment.';


--
-- Name: COLUMN comments.score_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.score_history IS 'The comment score over time.';


--
-- Name: COLUMN comments.score_updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.score_updated_at IS 'Timestamps of score column updates.';


--
-- Name: COLUMN comments.submission_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.submission_id IS 'The submission ID that the comment belongs within the submissions table.';


--
-- Name: COLUMN comments.subreddit_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.comments.subreddit_id IS 'The subreddit ID that the comment belongs to.';


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.submissions (
    author_id character varying,
    created_utc timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    downs integer[] DEFAULT ARRAY[]::integer[],
    id character varying NOT NULL,
    permalink text,
    score integer DEFAULT 0,
    score_history integer[] DEFAULT ARRAY[]::integer[],
    score_updated_at timestamp without time zone[] DEFAULT ARRAY[]::timestamp without time zone[],
    selftext text,
    subreddit_id character varying,
    title text,
    updated_at timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    ups integer[] DEFAULT ARRAY[]::integer[],
    url text
);


ALTER TABLE public.submissions OWNER TO postgres;

--
-- Name: COLUMN submissions.author_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.author_id IS 'The ID of the Redditor.';


--
-- Name: COLUMN submissions.created_utc; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.created_utc IS 'Time the submission was created, represented in Unix Time.';


--
-- Name: COLUMN submissions.downs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.downs IS 'The number of downvotes for the submission over time.';


--
-- Name: COLUMN submissions.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.id IS 'ID of the submission.';


--
-- Name: COLUMN submissions.permalink; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.permalink IS 'A permalink for the submission.';


--
-- Name: COLUMN submissions.score; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.score IS 'The most recent score of this submission.';


--
-- Name: COLUMN submissions.score_history; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.score_history IS 'The submission score history over time.';


--
-- Name: COLUMN submissions.score_updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.score_updated_at IS 'Timestamps of score column updates.';


--
-- Name: COLUMN submissions.selftext; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.selftext IS 'The submissions’ selftext - an empty string if a link post.';


--
-- Name: COLUMN submissions.subreddit_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.subreddit_id IS 'ID of the subreddit.';


--
-- Name: COLUMN submissions.title; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.title IS 'The title of the submission.';


--
-- Name: COLUMN submissions.ups; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.ups IS 'The number of current upvotes for the submission over time.';


--
-- Name: COLUMN submissions.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.submissions.url IS 'The URL the submission links to, or the permalink if a selfpost.';


--
-- Name: comments comments_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pk PRIMARY KEY (id);


--
-- Name: submissions submissions_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.submissions
    ADD CONSTRAINT submissions_pk PRIMARY KEY (id);


--
-- Name: comments_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX comments_id_uindex ON public.comments USING btree (id);


--
-- Name: submissions_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX submissions_id_uindex ON public.submissions USING btree (id);


--
-- Name: comments append_score_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER append_score_timestamp BEFORE UPDATE OF score ON public.comments FOR EACH ROW EXECUTE FUNCTION public.trigger_append_score_timestamp();


--
-- Name: submissions append_score_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER append_score_timestamp BEFORE UPDATE OF score ON public.submissions FOR EACH ROW EXECUTE FUNCTION public.trigger_append_score_timestamp();


--
-- Name: comments set_parent_comment_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_parent_comment_id BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.trigger_set_parent_comment_id();


--
-- Name: comments set_submission_id; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_submission_id BEFORE INSERT OR UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.trigger_set_submission_id();


--
-- Name: comments set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: submissions set_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.submissions FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();


--
-- Name: comments comments_comments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_comments_id_fk FOREIGN KEY (parent_comment_id) REFERENCES public.comments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comments comments_submissions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_submissions_id_fk FOREIGN KEY (submission_id) REFERENCES public.submissions(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

