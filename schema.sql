--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Homebrew)
-- Dumped by pg_dump version 15.13 (Homebrew)

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
-- Name: DayOfWeek; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."DayOfWeek" AS ENUM (
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);


ALTER TYPE public."DayOfWeek" OWNER TO maratron;

--
-- Name: Device; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."Device" AS ENUM (
    'Garmin',
    'Polar',
    'Suunto',
    'Fitbit',
    'Apple Watch',
    'Samsung Galaxy Watch',
    'Coros',
    'Other'
);


ALTER TYPE public."Device" OWNER TO maratron;

--
-- Name: DistanceUnit; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."DistanceUnit" AS ENUM (
    'miles',
    'kilometers'
);


ALTER TYPE public."DistanceUnit" OWNER TO maratron;

--
-- Name: Gender; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."Gender" AS ENUM (
    'Male',
    'Female',
    'Other'
);


ALTER TYPE public."Gender" OWNER TO maratron;

--
-- Name: TrainingEnvironment; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."TrainingEnvironment" AS ENUM (
    'outdoor',
    'treadmill',
    'indoor',
    'mixed'
);


ALTER TYPE public."TrainingEnvironment" OWNER TO maratron;

--
-- Name: TrainingLevel; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."TrainingLevel" AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);


ALTER TYPE public."TrainingLevel" OWNER TO maratron;

--
-- Name: elevationGainUnit; Type: TYPE; Schema: public; Owner: maratron
--

CREATE TYPE public."elevationGainUnit" AS ENUM (
    'miles',
    'kilometers',
    'meters',
    'feet'
);


ALTER TYPE public."elevationGainUnit" OWNER TO maratron;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Comment; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Comment" (
    id text NOT NULL,
    "postId" text NOT NULL,
    "socialProfileId" text NOT NULL,
    text text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Comment" OWNER TO maratron;

--
-- Name: Follow; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Follow" (
    id text NOT NULL,
    "followerId" text NOT NULL,
    "followingId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Follow" OWNER TO maratron;

--
-- Name: Like; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Like" (
    id text NOT NULL,
    "postId" text NOT NULL,
    "socialProfileId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Like" OWNER TO maratron;

--
-- Name: RunGroup; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."RunGroup" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    private boolean DEFAULT false NOT NULL,
    "ownerId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "imageUrl" text,
    password text
);


ALTER TABLE public."RunGroup" OWNER TO maratron;

--
-- Name: RunGroupMember; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."RunGroupMember" (
    "groupId" text NOT NULL,
    "socialProfileId" text NOT NULL,
    "joinedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."RunGroupMember" OWNER TO maratron;

--
-- Name: RunPost; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."RunPost" (
    id text NOT NULL,
    "socialProfileId" text NOT NULL,
    distance double precision NOT NULL,
    "time" text NOT NULL,
    caption text,
    "photoUrl" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "groupId" text
);


ALTER TABLE public."RunPost" OWNER TO maratron;

--
-- Name: RunningPlans; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."RunningPlans" (
    id text NOT NULL,
    "userId" text NOT NULL,
    name text NOT NULL,
    weeks integer NOT NULL,
    "planData" jsonb NOT NULL,
    "startDate" timestamp(3) without time zone,
    "endDate" timestamp(3) without time zone,
    active boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RunningPlans" OWNER TO maratron;

--
-- Name: Runs; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Runs" (
    id text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    duration text NOT NULL,
    distance double precision NOT NULL,
    "distanceUnit" public."DistanceUnit" NOT NULL,
    "trainingEnvironment" public."TrainingEnvironment",
    name text,
    pace text,
    "paceUnit" public."DistanceUnit",
    "elevationGain" double precision,
    "elevationGainUnit" public."elevationGainUnit",
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    "shoeId" text
);


ALTER TABLE public."Runs" OWNER TO maratron;

--
-- Name: Shoes; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Shoes" (
    id text NOT NULL,
    name text NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "currentDistance" double precision DEFAULT 0 NOT NULL,
    "distanceUnit" public."DistanceUnit" NOT NULL,
    "maxDistance" double precision NOT NULL,
    retired boolean DEFAULT false NOT NULL,
    "userId" text NOT NULL
);


ALTER TABLE public."Shoes" OWNER TO maratron;

--
-- Name: SocialProfile; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."SocialProfile" (
    id text NOT NULL,
    "userId" text NOT NULL,
    username text NOT NULL,
    bio text,
    "profilePhoto" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."SocialProfile" OWNER TO maratron;

--
-- Name: Users; Type: TABLE; Schema: public; Owner: maratron
--

CREATE TABLE public."Users" (
    id text NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    age integer,
    gender public."Gender",
    "trainingLevel" public."TrainingLevel",
    goals text[],
    "avatarUrl" text,
    "yearsRunning" integer,
    "weeklyMileage" integer,
    height integer,
    weight integer,
    "injuryHistory" text,
    "preferredTrainingDays" public."DayOfWeek"[],
    "preferredTrainingEnvironment" public."TrainingEnvironment",
    device public."Device",
    "defaultDistanceUnit" public."DistanceUnit" DEFAULT 'miles'::public."DistanceUnit",
    "defaultElevationUnit" public."elevationGainUnit" DEFAULT 'feet'::public."elevationGainUnit",
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "defaultShoeId" text,
    "VDOT" integer
);


ALTER TABLE public."Users" OWNER TO maratron;

--
-- Name: Comment Comment_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_pkey" PRIMARY KEY (id);


--
-- Name: Follow Follow_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Follow"
    ADD CONSTRAINT "Follow_pkey" PRIMARY KEY (id);


--
-- Name: Like Like_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Like"
    ADD CONSTRAINT "Like_pkey" PRIMARY KEY (id);


--
-- Name: RunGroupMember RunGroupMember_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunGroupMember"
    ADD CONSTRAINT "RunGroupMember_pkey" PRIMARY KEY ("groupId", "socialProfileId");


--
-- Name: RunGroup RunGroup_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunGroup"
    ADD CONSTRAINT "RunGroup_pkey" PRIMARY KEY (id);


--
-- Name: RunPost RunPost_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunPost"
    ADD CONSTRAINT "RunPost_pkey" PRIMARY KEY (id);


--
-- Name: RunningPlans RunningPlans_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunningPlans"
    ADD CONSTRAINT "RunningPlans_pkey" PRIMARY KEY (id);


--
-- Name: Runs Runs_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Runs"
    ADD CONSTRAINT "Runs_pkey" PRIMARY KEY (id);


--
-- Name: Shoes Shoes_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Shoes"
    ADD CONSTRAINT "Shoes_pkey" PRIMARY KEY (id);


--
-- Name: SocialProfile SocialProfile_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."SocialProfile"
    ADD CONSTRAINT "SocialProfile_pkey" PRIMARY KEY (id);


--
-- Name: Users Users_pkey; Type: CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY (id);


--
-- Name: Follow_followerId_followingId_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "Follow_followerId_followingId_key" ON public."Follow" USING btree ("followerId", "followingId");


--
-- Name: Like_postId_socialProfileId_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "Like_postId_socialProfileId_key" ON public."Like" USING btree ("postId", "socialProfileId");


--
-- Name: SocialProfile_userId_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "SocialProfile_userId_key" ON public."SocialProfile" USING btree ("userId");


--
-- Name: SocialProfile_username_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "SocialProfile_username_key" ON public."SocialProfile" USING btree (username);


--
-- Name: Users_defaultShoeId_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "Users_defaultShoeId_key" ON public."Users" USING btree ("defaultShoeId");


--
-- Name: Users_email_key; Type: INDEX; Schema: public; Owner: maratron
--

CREATE UNIQUE INDEX "Users_email_key" ON public."Users" USING btree (email);


--
-- Name: Comment Comment_postId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_postId_fkey" FOREIGN KEY ("postId") REFERENCES public."RunPost"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Comment Comment_socialProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Comment"
    ADD CONSTRAINT "Comment_socialProfileId_fkey" FOREIGN KEY ("socialProfileId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Follow Follow_followerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Follow"
    ADD CONSTRAINT "Follow_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Follow Follow_followingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Follow"
    ADD CONSTRAINT "Follow_followingId_fkey" FOREIGN KEY ("followingId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Like Like_postId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Like"
    ADD CONSTRAINT "Like_postId_fkey" FOREIGN KEY ("postId") REFERENCES public."RunPost"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Like Like_socialProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Like"
    ADD CONSTRAINT "Like_socialProfileId_fkey" FOREIGN KEY ("socialProfileId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RunGroupMember RunGroupMember_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunGroupMember"
    ADD CONSTRAINT "RunGroupMember_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."RunGroup"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RunGroupMember RunGroupMember_socialProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunGroupMember"
    ADD CONSTRAINT "RunGroupMember_socialProfileId_fkey" FOREIGN KEY ("socialProfileId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RunGroup RunGroup_ownerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunGroup"
    ADD CONSTRAINT "RunGroup_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RunPost RunPost_groupId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunPost"
    ADD CONSTRAINT "RunPost_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES public."RunGroup"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RunPost RunPost_socialProfileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunPost"
    ADD CONSTRAINT "RunPost_socialProfileId_fkey" FOREIGN KEY ("socialProfileId") REFERENCES public."SocialProfile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RunningPlans RunningPlans_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."RunningPlans"
    ADD CONSTRAINT "RunningPlans_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Runs Runs_shoeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Runs"
    ADD CONSTRAINT "Runs_shoeId_fkey" FOREIGN KEY ("shoeId") REFERENCES public."Shoes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Runs Runs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Runs"
    ADD CONSTRAINT "Runs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Shoes Shoes_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Shoes"
    ADD CONSTRAINT "Shoes_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SocialProfile SocialProfile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."SocialProfile"
    ADD CONSTRAINT "SocialProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Users Users_defaultShoeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: maratron
--

ALTER TABLE ONLY public."Users"
    ADD CONSTRAINT "Users_defaultShoeId_fkey" FOREIGN KEY ("defaultShoeId") REFERENCES public."Shoes"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO maratron;


--
-- PostgreSQL database dump complete
--

