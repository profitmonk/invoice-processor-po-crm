--
-- PostgreSQL database dump
--

\restrict pd2j71mfwM15zdXqaRffjEd11lWlyeKEvAeBDUfJHyJaFnjeB0Hf7PlMQ28rGWe

-- Dumped from database version 15.14 (Homebrew)
-- Dumped by pg_dump version 15.14 (Homebrew)

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
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- Name: AccountType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AccountType" AS ENUM (
    'ASSET',
    'LIABILITY',
    'EQUITY',
    'REVENUE',
    'EXPENSE'
);


ALTER TYPE public."AccountType" OWNER TO postgres;

--
-- Name: ApprovalStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ApprovalStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'SKIPPED'
);


ALTER TYPE public."ApprovalStatus" OWNER TO postgres;

--
-- Name: InvoiceStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."InvoiceStatus" AS ENUM (
    'UPLOADED',
    'PAYMENT_REQUIRED',
    'QUEUED',
    'PROCESSING_OCR',
    'PROCESSING_LLM',
    'COMPLETED',
    'FAILED'
);


ALTER TYPE public."InvoiceStatus" OWNER TO postgres;

--
-- Name: JobStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."JobStatus" AS ENUM (
    'PENDING',
    'RUNNING',
    'COMPLETED',
    'FAILED',
    'RETRYING'
);


ALTER TYPE public."JobStatus" OWNER TO postgres;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."NotificationType" AS ENUM (
    'PO_APPROVAL_NEEDED',
    'PO_APPROVED',
    'PO_REJECTED',
    'PO_CANCELLED',
    'INVOICE_PO_MISMATCH',
    'USER_INVITED',
    'ROLE_CHANGED'
);


ALTER TYPE public."NotificationType" OWNER TO postgres;

--
-- Name: POStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."POStatus" AS ENUM (
    'DRAFT',
    'PENDING_APPROVAL',
    'APPROVED',
    'REJECTED',
    'CANCELLED',
    'INVOICED'
);


ALTER TYPE public."POStatus" OWNER TO postgres;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserRole" AS ENUM (
    'USER',
    'PROPERTY_MANAGER',
    'ACCOUNTING',
    'CORPORATE',
    'ADMIN'
);


ALTER TYPE public."UserRole" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: ApprovalAction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ApprovalAction" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    "purchaseOrderId" text NOT NULL,
    "stepNumber" integer NOT NULL,
    action text NOT NULL,
    comment text,
    "ipAddress" text,
    "userAgent" text
);


ALTER TABLE public."ApprovalAction" OWNER TO postgres;

--
-- Name: ApprovalStep; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ApprovalStep" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "purchaseOrderId" text NOT NULL,
    "stepNumber" integer NOT NULL,
    "stepName" text NOT NULL,
    "requiredRole" public."UserRole" NOT NULL,
    status public."ApprovalStatus" DEFAULT 'PENDING'::public."ApprovalStatus" NOT NULL,
    "approvedById" text,
    "approvedAt" timestamp(3) without time zone,
    comment text,
    "notificationSentAt" timestamp(3) without time zone
);


ALTER TABLE public."ApprovalStep" OWNER TO postgres;

--
-- Name: Auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Auth" (
    id text NOT NULL,
    "userId" text
);


ALTER TABLE public."Auth" OWNER TO postgres;

--
-- Name: AuthIdentity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AuthIdentity" (
    "providerName" text NOT NULL,
    "providerUserId" text NOT NULL,
    "providerData" text DEFAULT '{}'::text NOT NULL,
    "authId" text NOT NULL
);


ALTER TABLE public."AuthIdentity" OWNER TO postgres;

--
-- Name: ContactFormMessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactFormMessage" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    content text NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "repliedAt" timestamp(3) without time zone
);


ALTER TABLE public."ContactFormMessage" OWNER TO postgres;

--
-- Name: DailyStats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DailyStats" (
    id integer NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "totalViews" integer DEFAULT 0 NOT NULL,
    "prevDayViewsChangePercent" text DEFAULT '0'::text NOT NULL,
    "userCount" integer DEFAULT 0 NOT NULL,
    "paidUserCount" integer DEFAULT 0 NOT NULL,
    "userDelta" integer DEFAULT 0 NOT NULL,
    "paidUserDelta" integer DEFAULT 0 NOT NULL,
    "totalRevenue" double precision DEFAULT 0 NOT NULL,
    "totalProfit" double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public."DailyStats" OWNER TO postgres;

--
-- Name: DailyStats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DailyStats_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."DailyStats_id_seq" OWNER TO postgres;

--
-- Name: DailyStats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DailyStats_id_seq" OWNED BY public."DailyStats".id;


--
-- Name: ExpenseType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ExpenseType" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public."ExpenseType" OWNER TO postgres;

--
-- Name: File; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."File" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    key text NOT NULL,
    "uploadUrl" text NOT NULL
);


ALTER TABLE public."File" OWNER TO postgres;

--
-- Name: GLAccount; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GLAccount" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" text NOT NULL,
    "accountNumber" text NOT NULL,
    name text NOT NULL,
    "accountType" public."AccountType" NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "annualBudget" double precision
);


ALTER TABLE public."GLAccount" OWNER TO postgres;

--
-- Name: GptResponse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GptResponse" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    content text NOT NULL
);


ALTER TABLE public."GptResponse" OWNER TO postgres;

--
-- Name: Invoice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Invoice" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    "fileName" text NOT NULL,
    "fileSize" integer NOT NULL,
    "fileUrl" text NOT NULL,
    "mimeType" text NOT NULL,
    status public."InvoiceStatus" DEFAULT 'UPLOADED'::public."InvoiceStatus" NOT NULL,
    "ocrText" text,
    "ocrConfidence" double precision,
    "ocrProcessedAt" timestamp(3) without time zone,
    "structuredData" jsonb,
    "llmProcessedAt" timestamp(3) without time zone,
    "vendorName" text,
    "invoiceNumber" text,
    "invoiceDate" timestamp(3) without time zone,
    "totalAmount" double precision,
    currency text DEFAULT 'USD'::text,
    "errorMessage" text,
    "failedAt" timestamp(3) without time zone
);


ALTER TABLE public."Invoice" OWNER TO postgres;

--
-- Name: InvoiceLineItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."InvoiceLineItem" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "invoiceId" text NOT NULL,
    description text NOT NULL,
    quantity double precision,
    "unitPrice" double precision,
    amount double precision,
    "taxAmount" double precision,
    category text,
    "lineNumber" integer
);


ALTER TABLE public."InvoiceLineItem" OWNER TO postgres;

--
-- Name: Logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Logs" (
    id integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    message text NOT NULL,
    level text NOT NULL
);


ALTER TABLE public."Logs" OWNER TO postgres;

--
-- Name: Logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Logs_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Logs_id_seq" OWNER TO postgres;

--
-- Name: Logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Logs_id_seq" OWNED BY public."Logs".id;


--
-- Name: Notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Notification" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    type public."NotificationType" NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    "actionUrl" text,
    "purchaseOrderId" text,
    "invoiceId" text,
    read boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "emailSent" boolean DEFAULT false NOT NULL,
    "emailSentAt" timestamp(3) without time zone,
    "smsSent" boolean DEFAULT false NOT NULL,
    "smsSentAt" timestamp(3) without time zone
);


ALTER TABLE public."Notification" OWNER TO postgres;

--
-- Name: Organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Organization" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    "poApprovalThreshold" double precision DEFAULT 500 NOT NULL
);


ALTER TABLE public."Organization" OWNER TO postgres;

--
-- Name: POLineItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."POLineItem" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "purchaseOrderId" text NOT NULL,
    "lineNumber" integer NOT NULL,
    description text NOT NULL,
    "propertyId" text NOT NULL,
    "glAccountId" text NOT NULL,
    quantity double precision DEFAULT 1 NOT NULL,
    "unitPrice" double precision NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    "totalAmount" double precision NOT NULL
);


ALTER TABLE public."POLineItem" OWNER TO postgres;

--
-- Name: PageViewSource; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PageViewSource" (
    name text NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dailyStatsId" integer,
    visitors integer NOT NULL
);


ALTER TABLE public."PageViewSource" OWNER TO postgres;

--
-- Name: ProcessingJob; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProcessingJob" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "invoiceId" text NOT NULL,
    status public."JobStatus" DEFAULT 'PENDING'::public."JobStatus" NOT NULL,
    "currentStep" text,
    attempts integer DEFAULT 0 NOT NULL,
    "maxAttempts" integer DEFAULT 3 NOT NULL,
    "startedAt" timestamp(3) without time zone,
    "completedAt" timestamp(3) without time zone,
    "errorLog" text,
    "lastError" text
);


ALTER TABLE public."ProcessingJob" OWNER TO postgres;

--
-- Name: Property; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Property" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" text NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    address text,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public."Property" OWNER TO postgres;

--
-- Name: PurchaseOrder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PurchaseOrder" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "organizationId" text NOT NULL,
    "createdById" text NOT NULL,
    "poNumber" text NOT NULL,
    vendor text NOT NULL,
    description text NOT NULL,
    "expenseTypeId" text NOT NULL,
    "poDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status public."POStatus" DEFAULT 'DRAFT'::public."POStatus" NOT NULL,
    subtotal double precision DEFAULT 0 NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    "totalAmount" double precision DEFAULT 0 NOT NULL,
    "isTemplate" boolean DEFAULT false NOT NULL,
    "templateName" text,
    "requiresApproval" boolean DEFAULT false NOT NULL,
    "currentApprovalStep" integer,
    "linkedInvoiceId" text
);


ALTER TABLE public."PurchaseOrder" OWNER TO postgres;

--
-- Name: Session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Session" (
    id text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL
);


ALTER TABLE public."Session" OWNER TO postgres;

--
-- Name: Task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Task" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    description text NOT NULL,
    "time" text DEFAULT '1'::text NOT NULL,
    "isDone" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Task" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    email text,
    username text,
    "organizationId" text,
    role public."UserRole" DEFAULT 'USER'::public."UserRole" NOT NULL,
    "isAdmin" boolean DEFAULT false NOT NULL,
    "hasCompletedOnboarding" boolean DEFAULT false NOT NULL,
    "invitedById" text,
    "invitationToken" text,
    "invitationExpiresAt" timestamp(3) without time zone,
    "phoneNumber" text,
    "paymentProcessorUserId" text,
    "lemonSqueezyCustomerPortalUrl" text,
    "subscriptionStatus" text,
    "subscriptionPlan" text,
    "datePaid" timestamp(3) without time zone,
    credits integer DEFAULT 3 NOT NULL
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: DailyStats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DailyStats" ALTER COLUMN id SET DEFAULT nextval('public."DailyStats_id_seq"'::regclass);


--
-- Name: Logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs" ALTER COLUMN id SET DEFAULT nextval('public."Logs_id_seq"'::regclass);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
71f71f60-4dac-4e3f-b4a7-b1fab12ce327	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 00:41:01.817832-05	\N	\N	2025-10-12 05:41:00	00:15:00	2025-10-12 00:40:02.817832-05	\N	2025-10-12 00:42:01.817832-05	f	\N	2025-10-12 00:52:05.129809-05
68f45bef-3df3-4d79-903a-5fce2bd9095d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:29:55.566977-05	2025-10-12 00:29:55.570068-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:29:55.566977-05	2025-10-12 00:29:55.601238-05	2025-10-12 00:37:55.566977-05	f	\N	2025-10-12 12:30:56.101268-05
6827a667-41a0-400b-8e33-24ac8c8d1037	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:29:55.601571-05	2025-10-12 00:29:59.594685-05	\N	2025-10-12 05:29:00	00:15:00	2025-10-12 00:29:55.601571-05	2025-10-12 00:29:59.600799-05	2025-10-12 00:30:55.601571-05	f	\N	2025-10-12 12:30:56.101268-05
054e96e6-d54b-4a1a-a718-f0d3157702cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:30:01.60019-05	2025-10-12 00:30:03.596041-05	\N	2025-10-12 05:30:00	00:15:00	2025-10-12 00:29:59.60019-05	2025-10-12 00:30:03.606209-05	2025-10-12 00:31:01.60019-05	f	\N	2025-10-12 12:30:56.101268-05
9dfabc2e-a925-41b1-8b1e-39c48ebc4fad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:23:35.05358-05	2025-10-12 23:24:35.042335-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:21:35.05358-05	2025-10-12 23:24:35.049577-05	2025-10-12 23:31:35.05358-05	f	\N	2025-10-13 12:42:16.717855-05
70dd3dd9-552e-45d2-b8be-c6c40c7884c8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:27:01.091777-05	2025-10-12 23:27:03.107715-05	\N	2025-10-13 04:27:00	00:15:00	2025-10-12 23:26:03.091777-05	2025-10-12 23:27:03.116113-05	2025-10-12 23:28:01.091777-05	f	\N	2025-10-13 12:42:16.717855-05
075c7b61-6645-4bc2-92f6-7c72e0b57b0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:20:01.57412-05	2025-10-13 00:20:04.596698-05	\N	2025-10-13 05:20:00	00:15:00	2025-10-13 00:19:04.57412-05	2025-10-13 00:20:04.605019-05	2025-10-13 00:21:01.57412-05	f	\N	2025-10-13 12:42:16.717855-05
358d921d-b5e0-41b1-89e0-e07ed5a2f282	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:28:01.114711-05	2025-10-12 23:28:03.131047-05	\N	2025-10-13 04:28:00	00:15:00	2025-10-12 23:27:03.114711-05	2025-10-12 23:28:03.142799-05	2025-10-12 23:29:01.114711-05	f	\N	2025-10-13 12:42:16.717855-05
702013df-a6ca-43ca-af94-3de73a9666cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:22:01.634748-05	2025-10-13 00:22:04.643097-05	\N	2025-10-13 05:22:00	00:15:00	2025-10-13 00:21:04.634748-05	2025-10-13 00:22:04.651583-05	2025-10-13 00:23:01.634748-05	f	\N	2025-10-13 12:42:16.717855-05
3a7c303b-14ad-413b-9a8b-c9434112e806	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:29:01.141148-05	2025-10-12 23:29:03.15871-05	\N	2025-10-13 04:29:00	00:15:00	2025-10-12 23:28:03.141148-05	2025-10-12 23:29:03.164676-05	2025-10-12 23:30:01.141148-05	f	\N	2025-10-13 12:42:16.717855-05
14332de3-7c2c-48a2-874a-6cccadd6eda9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:30:01.163961-05	2025-10-12 23:30:03.180407-05	\N	2025-10-13 04:30:00	00:15:00	2025-10-12 23:29:03.163961-05	2025-10-12 23:30:03.188768-05	2025-10-12 23:31:01.163961-05	f	\N	2025-10-13 12:42:16.717855-05
d73c5d4a-6a46-4a89-8b5c-ef72a94c6ace	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:29:35.059016-05	2025-10-12 23:30:35.050547-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:27:35.059016-05	2025-10-12 23:30:35.057393-05	2025-10-12 23:37:35.059016-05	f	\N	2025-10-13 12:42:16.717855-05
132fec86-ce12-4dfd-a319-826cd637a84c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:32:01.217701-05	2025-10-12 23:32:03.237632-05	\N	2025-10-13 04:32:00	00:15:00	2025-10-12 23:31:03.217701-05	2025-10-12 23:32:03.245854-05	2025-10-12 23:33:01.217701-05	f	\N	2025-10-13 12:42:16.717855-05
4d57e1a2-a1c4-4df5-a2d3-2c4a86a269ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:33:01.244696-05	2025-10-12 23:33:03.264507-05	\N	2025-10-13 04:33:00	00:15:00	2025-10-12 23:32:03.244696-05	2025-10-12 23:33:03.275267-05	2025-10-12 23:34:01.244696-05	f	\N	2025-10-13 12:42:16.717855-05
558074c8-2d3f-4b77-b30b-7c32a138122e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:32:35.05877-05	2025-10-12 23:33:35.05378-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:30:35.05877-05	2025-10-12 23:33:35.062774-05	2025-10-12 23:40:35.05877-05	f	\N	2025-10-13 12:42:16.717855-05
18b21b8a-12eb-4349-9feb-2215c76d3fef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:34:01.273766-05	2025-10-12 23:34:03.295793-05	\N	2025-10-13 04:34:00	00:15:00	2025-10-12 23:33:03.273766-05	2025-10-12 23:34:03.306364-05	2025-10-12 23:35:01.273766-05	f	\N	2025-10-13 12:42:16.717855-05
a4c150b4-cadd-41d2-be20-192eff69b23a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:35:01.304841-05	2025-10-12 23:35:03.324889-05	\N	2025-10-13 04:35:00	00:15:00	2025-10-12 23:34:03.304841-05	2025-10-12 23:35:03.336014-05	2025-10-12 23:36:01.304841-05	f	\N	2025-10-13 12:42:16.717855-05
295ba5e3-e5ef-4f45-9521-14cbc5e1e173	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:35:35.064845-05	2025-10-12 23:35:35.08435-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:33:35.064845-05	2025-10-12 23:35:35.090554-05	2025-10-12 23:43:35.064845-05	f	\N	2025-10-13 12:42:16.717855-05
0c3af5bb-4161-48f1-8f32-cecf0362d629	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:36:01.334436-05	2025-10-12 23:36:03.386365-05	\N	2025-10-13 04:36:00	00:15:00	2025-10-12 23:35:03.334436-05	2025-10-12 23:36:03.410331-05	2025-10-12 23:37:01.334436-05	f	\N	2025-10-13 12:42:16.717855-05
a993fbf1-37ab-4c4c-8ad3-e18e904fd3d8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:37:01.394961-05	2025-10-12 23:37:03.416695-05	\N	2025-10-13 04:37:00	00:15:00	2025-10-12 23:36:03.394961-05	2025-10-12 23:37:03.42669-05	2025-10-12 23:38:01.394961-05	f	\N	2025-10-13 12:42:16.717855-05
c81c1e8f-05b3-484a-b865-7aac7ac4ef2f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:39:35.102989-05	2025-10-12 23:40:35.101297-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:37:35.102989-05	2025-10-12 23:40:35.109221-05	2025-10-12 23:47:35.102989-05	f	\N	2025-10-13 12:42:16.717855-05
14dea25d-8810-4d63-9bad-36dafc9e25df	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:45:01.615523-05	2025-10-12 23:45:03.636934-05	\N	2025-10-13 04:45:00	00:15:00	2025-10-12 23:44:03.615523-05	2025-10-12 23:45:03.646111-05	2025-10-12 23:46:01.615523-05	f	\N	2025-10-13 12:42:16.717855-05
071430be-9a0d-4de2-85e5-2231fac5ee0c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:49:01.729043-05	2025-10-12 23:49:03.743962-05	\N	2025-10-13 04:49:00	00:15:00	2025-10-12 23:48:03.729043-05	2025-10-12 23:49:03.7546-05	2025-10-12 23:50:01.729043-05	f	\N	2025-10-13 12:42:16.717855-05
92c06979-e06c-4c06-90e0-67b3f9b41144	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:50:01.753229-05	2025-10-12 23:50:03.771868-05	\N	2025-10-13 04:50:00	00:15:00	2025-10-12 23:49:03.753229-05	2025-10-12 23:50:03.783653-05	2025-10-12 23:51:01.753229-05	f	\N	2025-10-13 12:42:16.717855-05
ef7bcf89-1e3a-4a00-9e46-51c26cbe96e7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:51:35.127296-05	2025-10-12 23:52:35.125451-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:49:35.127296-05	2025-10-12 23:52:35.131592-05	2025-10-12 23:59:35.127296-05	f	\N	2025-10-13 12:42:16.717855-05
005120c7-726d-4bc9-8f18-8bfe3cc437da	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:56:01.907556-05	2025-10-12 23:56:03.929769-05	\N	2025-10-13 04:56:00	00:15:00	2025-10-12 23:55:03.907556-05	2025-10-12 23:56:03.940008-05	2025-10-12 23:57:01.907556-05	f	\N	2025-10-13 12:42:16.717855-05
5aae7e2a-6d6a-435a-be72-4102183a17ad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:58:01.960603-05	2025-10-12 23:58:03.973689-05	\N	2025-10-13 04:58:00	00:15:00	2025-10-12 23:57:03.960603-05	2025-10-12 23:58:03.986189-05	2025-10-12 23:59:01.960603-05	f	\N	2025-10-13 12:42:16.717855-05
d293b1c0-226b-4c35-830d-bb790bc1769d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:57:35.143084-05	2025-10-12 23:58:35.137235-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:55:35.143084-05	2025-10-12 23:58:35.141331-05	2025-10-13 00:05:35.143084-05	f	\N	2025-10-13 12:42:16.717855-05
30aa5455-d843-4211-8849-120be577e60e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:59:01.984732-05	2025-10-12 23:59:04.007142-05	\N	2025-10-13 04:59:00	00:15:00	2025-10-12 23:58:03.984732-05	2025-10-12 23:59:04.018498-05	2025-10-13 00:00:01.984732-05	f	\N	2025-10-13 12:42:16.717855-05
5be67475-9180-43f2-9f91-a6b9711103ee	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:00:01.016947-05	2025-10-13 00:00:04.035881-05	\N	2025-10-13 05:00:00	00:15:00	2025-10-12 23:59:04.016947-05	2025-10-13 00:00:04.04474-05	2025-10-13 00:01:01.016947-05	f	\N	2025-10-13 12:42:16.717855-05
5b1964e8-f455-45e7-80ad-f0db040e4007	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 00:00:04.0397-05	2025-10-13 00:00:08.037765-05	dailyStatsJob	2025-10-13 05:00:00	00:15:00	2025-10-13 00:00:04.0397-05	2025-10-13 00:00:08.041262-05	2025-10-27 00:00:04.0397-05	f	\N	2025-10-13 12:42:16.717855-05
50fcbaee-367f-4822-96b6-d61630a1018e	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 00:00:08.039823-05	2025-10-13 00:00:08.115255-05	\N	\N	00:15:00	2025-10-13 00:00:08.039823-05	2025-10-13 00:00:08.320792-05	2025-10-27 00:00:08.039823-05	f	\N	2025-10-13 12:42:16.717855-05
764032a7-5bd0-42f1-b541-0b9523e550fb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:01:01.043346-05	2025-10-13 00:01:04.058424-05	\N	2025-10-13 05:01:00	00:15:00	2025-10-13 00:00:04.043346-05	2025-10-13 00:01:04.063422-05	2025-10-13 00:02:01.043346-05	f	\N	2025-10-13 12:42:16.717855-05
529d66b4-bf1c-446b-83e8-b1c61fa25ecc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:00:35.142626-05	2025-10-13 00:01:35.1514-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:58:35.142626-05	2025-10-13 00:01:35.155608-05	2025-10-13 00:08:35.142626-05	f	\N	2025-10-13 12:42:16.717855-05
09944570-1d9e-4a1b-afd1-1b175becae07	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:02:01.062434-05	2025-10-13 00:02:04.09487-05	\N	2025-10-13 05:02:00	00:15:00	2025-10-13 00:01:04.062434-05	2025-10-13 00:02:04.10187-05	2025-10-13 00:03:01.062434-05	f	\N	2025-10-13 12:42:16.717855-05
5b203f25-63a9-4dda-a6fa-9699b058431f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:03:35.156574-05	2025-10-13 00:03:35.157244-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:01:35.156574-05	2025-10-13 00:03:35.164896-05	2025-10-13 00:11:35.156574-05	f	\N	2025-10-13 12:42:16.717855-05
0e900e19-c409-4f89-a565-27328e09e6b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:04:01.131722-05	2025-10-13 00:04:04.150781-05	\N	2025-10-13 05:04:00	00:15:00	2025-10-13 00:03:04.131722-05	2025-10-13 00:04:04.160407-05	2025-10-13 00:05:01.131722-05	f	\N	2025-10-13 12:42:16.717855-05
0526da5b-01a5-4d42-96c7-58c5514fbee2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:07:01.213618-05	2025-10-13 00:07:04.231635-05	\N	2025-10-13 05:07:00	00:15:00	2025-10-13 00:06:04.213618-05	2025-10-13 00:07:04.240623-05	2025-10-13 00:08:01.213618-05	f	\N	2025-10-13 12:42:16.717855-05
788177d4-e537-4270-82f8-98504437ae68	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:09:01.26994-05	2025-10-13 00:09:04.289617-05	\N	2025-10-13 05:09:00	00:15:00	2025-10-13 00:08:04.26994-05	2025-10-13 00:09:04.299455-05	2025-10-13 00:10:01.26994-05	f	\N	2025-10-13 12:42:16.717855-05
c35ae3f0-0f1e-4e3b-b740-e7550f2ed6a7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:08:35.170922-05	2025-10-13 00:09:35.165838-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:06:35.170922-05	2025-10-13 00:09:35.173624-05	2025-10-13 00:16:35.170922-05	f	\N	2025-10-13 12:42:16.717855-05
7368b0dd-2150-4820-bb1b-51f50c2389c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:11:01.327738-05	2025-10-13 00:11:04.347949-05	\N	2025-10-13 05:11:00	00:15:00	2025-10-13 00:10:04.327738-05	2025-10-13 00:11:04.357432-05	2025-10-13 00:12:01.327738-05	f	\N	2025-10-13 12:42:16.717855-05
a8f2a85e-d9ab-4ac0-80ee-8cdc01183e44	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:12:01.356118-05	2025-10-13 00:12:04.375435-05	\N	2025-10-13 05:12:00	00:15:00	2025-10-13 00:11:04.356118-05	2025-10-13 00:12:04.381842-05	2025-10-13 00:13:01.356118-05	f	\N	2025-10-13 12:42:16.717855-05
48bd0416-c7cd-4ed5-ace3-4d34618a3523	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:11:35.175192-05	2025-10-13 00:12:35.171102-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:09:35.175192-05	2025-10-13 00:12:35.179771-05	2025-10-13 00:19:35.175192-05	f	\N	2025-10-13 12:42:16.717855-05
537c93e9-6683-4a93-ad2c-7263307083dc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:15:01.440769-05	2025-10-13 00:15:04.455181-05	\N	2025-10-13 05:15:00	00:15:00	2025-10-13 00:14:04.440769-05	2025-10-13 00:15:04.459373-05	2025-10-13 00:16:01.440769-05	f	\N	2025-10-13 12:42:16.717855-05
bda1bc4e-9ff3-4b4a-a5dd-f57a01742b82	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 00:53:01.156008-05	\N	\N	2025-10-12 05:53:00	00:15:00	2025-10-12 00:52:09.156008-05	\N	2025-10-12 00:54:01.156008-05	f	\N	2025-10-12 00:55:21.72027-05
a4529e57-da10-43dc-b61b-ab04a2c18d46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:31:01.605352-05	2025-10-12 00:31:03.608425-05	\N	2025-10-12 05:31:00	00:15:00	2025-10-12 00:30:03.605352-05	2025-10-12 00:31:03.620054-05	2025-10-12 00:32:01.605352-05	f	\N	2025-10-12 12:35:31.987243-05
4ec523b1-98b0-47ee-a5d9-4706f9dabc86	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:32:01.619312-05	2025-10-12 00:32:03.6233-05	\N	2025-10-12 05:32:00	00:15:00	2025-10-12 00:31:03.619312-05	2025-10-12 00:32:03.638078-05	2025-10-12 00:33:01.619312-05	f	\N	2025-10-12 12:35:31.987243-05
222f48bb-4f3f-4eaa-919a-68eb293d0f63	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:31:55.601795-05	2025-10-12 00:32:55.574766-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:29:55.601795-05	2025-10-12 00:32:55.585429-05	2025-10-12 00:39:55.601795-05	f	\N	2025-10-12 12:35:31.987243-05
74fd81e1-83db-4258-ad9d-9ad0d9c79d64	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:33:01.636342-05	2025-10-12 00:33:03.634068-05	\N	2025-10-12 05:33:00	00:15:00	2025-10-12 00:32:03.636342-05	2025-10-12 00:33:03.648076-05	2025-10-12 00:34:01.636342-05	f	\N	2025-10-12 12:35:31.987243-05
5f5d0fb4-ac44-444d-b576-0e5ad9da3495	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:34:01.646554-05	2025-10-12 00:34:03.649984-05	\N	2025-10-12 05:34:00	00:15:00	2025-10-12 00:33:03.646554-05	2025-10-12 00:34:03.663083-05	2025-10-12 00:35:01.646554-05	f	\N	2025-10-12 12:35:31.987243-05
96d1cd5f-5e58-422a-985e-d16aabc42401	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:35:01.661998-05	2025-10-12 00:35:03.663479-05	\N	2025-10-12 05:35:00	00:15:00	2025-10-12 00:34:03.661998-05	2025-10-12 00:35:03.678438-05	2025-10-12 00:36:01.661998-05	f	\N	2025-10-12 12:35:31.987243-05
a53a10ae-4acb-463b-a99f-5106d181399f	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 12:32:01.116199-05	\N	\N	2025-10-12 17:32:00	00:15:00	2025-10-12 12:31:04.116199-05	\N	2025-10-12 12:33:01.116199-05	f	\N	2025-10-12 12:35:31.987243-05
0ba1aa54-8d4f-4a56-a654-07c61cb542e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:14:35.181589-05	2025-10-13 00:15:35.176868-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:12:35.181589-05	2025-10-13 00:15:35.181634-05	2025-10-13 00:22:35.181589-05	f	\N	2025-10-13 12:42:16.717855-05
5781fa1f-de1b-44a5-b706-e331a1ec7c4b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:16:01.458638-05	2025-10-13 00:16:04.483397-05	\N	2025-10-13 05:16:00	00:15:00	2025-10-13 00:15:04.458638-05	2025-10-13 00:16:04.488894-05	2025-10-13 00:17:01.458638-05	f	\N	2025-10-13 12:42:16.717855-05
805959c7-83ad-48ab-aad1-9a4d6b653406	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:18:01.521211-05	2025-10-13 00:18:04.540628-05	\N	2025-10-13 05:18:00	00:15:00	2025-10-13 00:17:04.521211-05	2025-10-13 00:18:04.548949-05	2025-10-13 00:19:01.521211-05	f	\N	2025-10-13 12:42:16.717855-05
76133a5e-fc7d-4c10-b861-3fd789767756	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:17:35.183094-05	2025-10-13 00:18:35.183086-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:15:35.183094-05	2025-10-13 00:18:35.187-05	2025-10-13 00:25:35.183094-05	f	\N	2025-10-13 12:42:16.717855-05
910a285d-b6bf-42d1-9a0d-c00337b0f68f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:19:01.547682-05	2025-10-13 00:19:04.564896-05	\N	2025-10-13 05:19:00	00:15:00	2025-10-13 00:18:04.547682-05	2025-10-13 00:19:04.576007-05	2025-10-13 00:20:01.547682-05	f	\N	2025-10-13 12:42:16.717855-05
8b8c5649-d0fa-4ac8-aeef-8acbe7f6de3e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:31:01.187442-05	2025-10-12 23:31:03.210287-05	\N	2025-10-13 04:31:00	00:15:00	2025-10-12 23:30:03.187442-05	2025-10-12 23:31:03.218914-05	2025-10-12 23:32:01.187442-05	f	\N	2025-10-13 12:42:16.717855-05
e512d5b5-3855-4de5-b902-e80d76f9d2cb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:20:35.188136-05	2025-10-13 00:20:35.188914-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:18:35.188136-05	2025-10-13 00:20:35.196912-05	2025-10-13 00:28:35.188136-05	f	\N	2025-10-13 12:42:16.717855-05
8ba5eedb-d06d-48c0-b278-e0f80831f9f5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:37:35.092132-05	2025-10-12 23:37:35.095782-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:35:35.092132-05	2025-10-12 23:37:35.10166-05	2025-10-12 23:45:35.092132-05	f	\N	2025-10-13 12:42:16.717855-05
803c0c01-510d-4772-805c-581e22be8b3a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:38:01.425483-05	2025-10-12 23:38:03.443417-05	\N	2025-10-13 04:38:00	00:15:00	2025-10-12 23:37:03.425483-05	2025-10-12 23:38:03.452172-05	2025-10-12 23:39:01.425483-05	f	\N	2025-10-13 12:42:16.717855-05
41c91c4c-a3ef-4e65-ac07-9535622dfb38	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:51:01.782009-05	2025-10-12 23:51:03.795067-05	\N	2025-10-13 04:51:00	00:15:00	2025-10-12 23:50:03.782009-05	2025-10-12 23:51:03.803682-05	2025-10-12 23:52:01.782009-05	f	\N	2025-10-13 12:42:16.717855-05
729e4be7-d8b9-425e-b1ca-ebc5ee8592d2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:23:01.650504-05	2025-10-13 00:23:04.671268-05	\N	2025-10-13 05:23:00	00:15:00	2025-10-13 00:22:04.650504-05	2025-10-13 00:23:04.680851-05	2025-10-13 00:24:01.650504-05	f	\N	2025-10-13 12:42:16.717855-05
5347278b-7c63-4e12-8c1a-d83d962de7a7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:22:35.198586-05	2025-10-13 00:23:35.196498-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:20:35.198586-05	2025-10-13 00:23:35.205769-05	2025-10-13 00:30:35.198586-05	f	\N	2025-10-13 12:42:16.717855-05
96644135-852b-41d3-89b2-18a4fecf4a70	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:53:01.829713-05	2025-10-12 23:53:03.847111-05	\N	2025-10-13 04:53:00	00:15:00	2025-10-12 23:52:03.829713-05	2025-10-12 23:53:03.860226-05	2025-10-12 23:54:01.829713-05	f	\N	2025-10-13 12:42:16.717855-05
f8aa8366-ceb9-435c-a1db-ea3daafc80b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:26:01.732745-05	2025-10-13 00:26:04.751521-05	\N	2025-10-13 05:26:00	00:15:00	2025-10-13 00:25:04.732745-05	2025-10-13 00:26:04.759627-05	2025-10-13 00:27:01.732745-05	f	\N	2025-10-13 12:42:16.717855-05
11222f1e-0388-43c3-9629-9062137d2ed4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:54:01.857927-05	2025-10-12 23:54:03.875554-05	\N	2025-10-13 04:54:00	00:15:00	2025-10-12 23:53:03.857927-05	2025-10-12 23:54:03.886397-05	2025-10-12 23:55:01.857927-05	f	\N	2025-10-13 12:42:16.717855-05
acb7ff06-f720-4abd-8691-c0565add1def	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:55:01.88532-05	2025-10-12 23:55:03.901951-05	\N	2025-10-13 04:55:00	00:15:00	2025-10-12 23:54:03.88532-05	2025-10-12 23:55:03.908649-05	2025-10-12 23:56:01.88532-05	f	\N	2025-10-13 12:42:16.717855-05
cb1c993a-66d3-49b7-854a-9aae869df73c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:25:35.207776-05	2025-10-13 00:26:35.20292-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:23:35.207776-05	2025-10-13 00:26:35.209977-05	2025-10-13 00:33:35.207776-05	f	\N	2025-10-13 12:42:16.717855-05
573a525a-a44a-46e5-990a-625a8afc1af9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:54:35.13298-05	2025-10-12 23:55:35.132923-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:52:35.13298-05	2025-10-12 23:55:35.141174-05	2025-10-13 00:02:35.13298-05	f	\N	2025-10-13 12:42:16.717855-05
228fd314-34dd-4358-aad6-edb8ed76a43f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:27:01.758323-05	2025-10-13 00:27:04.780282-05	\N	2025-10-13 05:27:00	00:15:00	2025-10-13 00:26:04.758323-05	2025-10-13 00:27:04.787703-05	2025-10-13 00:28:01.758323-05	f	\N	2025-10-13 12:42:16.717855-05
d5e97350-adac-4791-a8f4-1067a02fd8cc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:28:35.211328-05	2025-10-13 00:29:35.206852-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:26:35.211328-05	2025-10-13 00:29:35.215095-05	2025-10-13 00:36:35.211328-05	f	\N	2025-10-13 12:42:16.717855-05
c3b3bd00-f260-4b7a-b7b6-7a2fad70a51d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:57:01.938625-05	2025-10-12 23:57:03.948811-05	\N	2025-10-13 04:57:00	00:15:00	2025-10-12 23:56:03.938625-05	2025-10-12 23:57:03.962194-05	2025-10-12 23:58:01.938625-05	f	\N	2025-10-13 12:42:16.717855-05
af26998b-12bd-45b4-a9fe-f27be5df8a0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:32:01.91091-05	2025-10-13 00:32:04.936102-05	\N	2025-10-13 05:32:00	00:15:00	2025-10-13 00:31:04.91091-05	2025-10-13 00:32:04.945307-05	2025-10-13 00:33:01.91091-05	f	\N	2025-10-13 12:42:16.717855-05
3e3929c6-351b-4c92-bf97-6e45f2aa6371	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:03:01.100728-05	2025-10-13 00:03:04.12388-05	\N	2025-10-13 05:03:00	00:15:00	2025-10-13 00:02:04.100728-05	2025-10-13 00:03:04.133335-05	2025-10-13 00:04:01.100728-05	f	\N	2025-10-13 12:42:16.717855-05
4fb95839-d8ae-4d3d-981d-b3ce6b0c3fe4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:31:35.216764-05	2025-10-13 00:32:35.213376-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:29:35.216764-05	2025-10-13 00:32:35.220709-05	2025-10-13 00:39:35.216764-05	f	\N	2025-10-13 12:42:16.717855-05
9fa002ee-17fd-4548-8b5b-c735d2432cd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:33:01.943642-05	2025-10-13 00:33:04.959973-05	\N	2025-10-13 05:33:00	00:15:00	2025-10-13 00:32:04.943642-05	2025-10-13 00:33:04.970729-05	2025-10-13 00:34:01.943642-05	f	\N	2025-10-13 12:42:16.717855-05
b76d5e12-5629-45e6-850d-158bc1695109	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:05:01.158197-05	2025-10-13 00:05:04.177802-05	\N	2025-10-13 05:05:00	00:15:00	2025-10-13 00:04:04.158197-05	2025-10-13 00:05:04.18795-05	2025-10-13 00:06:01.158197-05	f	\N	2025-10-13 12:42:16.717855-05
b7b15878-ad17-405e-8908-bfd2da349d7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:34:01.968923-05	2025-10-13 00:34:04.992482-05	\N	2025-10-13 05:34:00	00:15:00	2025-10-13 00:33:04.968923-05	2025-10-13 00:34:05.003155-05	2025-10-13 00:35:01.968923-05	f	\N	2025-10-13 12:42:16.717855-05
98658d83-7575-44f2-8025-9e6d621ae40e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:06:01.186521-05	2025-10-13 00:06:04.205524-05	\N	2025-10-13 05:06:00	00:15:00	2025-10-13 00:05:04.186521-05	2025-10-13 00:06:04.215331-05	2025-10-13 00:07:01.186521-05	f	\N	2025-10-13 12:42:16.717855-05
77a206d3-74c8-4fc6-9e34-de9727c08676	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:34:35.222407-05	2025-10-13 00:35:35.218279-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:32:35.222407-05	2025-10-13 00:35:35.225316-05	2025-10-13 00:42:35.222407-05	f	\N	2025-10-13 12:42:16.717855-05
8f88fb87-8f18-4b5e-8912-b22ab5bca4a6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:05:35.166739-05	2025-10-13 00:06:35.161835-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:03:35.166739-05	2025-10-13 00:06:35.169165-05	2025-10-13 00:13:35.166739-05	f	\N	2025-10-13 12:42:16.717855-05
b8c94825-3d7b-4a21-a178-feb5287f09ba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:08:01.239553-05	2025-10-13 00:08:04.261808-05	\N	2025-10-13 05:08:00	00:15:00	2025-10-13 00:07:04.239553-05	2025-10-13 00:08:04.271393-05	2025-10-13 00:09:01.239553-05	f	\N	2025-10-13 12:42:16.717855-05
6f2e1216-ef14-4551-869a-3d6532eb97aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:38:01.089166-05	2025-10-13 00:38:01.10949-05	\N	2025-10-13 05:38:00	00:15:00	2025-10-13 00:37:01.089166-05	2025-10-13 00:38:01.121778-05	2025-10-13 00:39:01.089166-05	f	\N	2025-10-13 12:42:16.717855-05
89da7d12-1965-44a6-94de-ec5980bfe0e2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:37:35.226637-05	2025-10-13 00:38:35.225091-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:35:35.226637-05	2025-10-13 00:38:35.231719-05	2025-10-13 00:45:35.226637-05	f	\N	2025-10-13 12:42:16.717855-05
84684779-5650-4fcb-9e05-07d315cfefd4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:10:01.297923-05	2025-10-13 00:10:04.319871-05	\N	2025-10-13 05:10:00	00:15:00	2025-10-13 00:09:04.297923-05	2025-10-13 00:10:04.328932-05	2025-10-13 00:11:01.297923-05	f	\N	2025-10-13 12:42:16.717855-05
e255b84d-ee24-428f-8e0a-6ab78aa7d5e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:40:01.144761-05	2025-10-13 00:40:01.165912-05	\N	2025-10-13 05:40:00	00:15:00	2025-10-13 00:39:01.144761-05	2025-10-13 00:40:01.174417-05	2025-10-13 00:41:01.144761-05	f	\N	2025-10-13 12:42:16.717855-05
55e4a9f7-7d38-4aff-a5ac-ae3a0a125f3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:13:01.380885-05	2025-10-13 00:13:04.400789-05	\N	2025-10-13 05:13:00	00:15:00	2025-10-13 00:12:04.380885-05	2025-10-13 00:13:04.411873-05	2025-10-13 00:14:01.380885-05	f	\N	2025-10-13 12:42:16.717855-05
9b1fe9d8-c5bc-4f3b-8e84-a52f72aa6b26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:14:01.410172-05	2025-10-13 00:14:04.432439-05	\N	2025-10-13 05:14:00	00:15:00	2025-10-13 00:13:04.410172-05	2025-10-13 00:14:04.44251-05	2025-10-13 00:15:01.410172-05	f	\N	2025-10-13 12:42:16.717855-05
113d50e0-136e-4307-b894-a86141b6e878	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 01:19:01.791988-05	\N	\N	2025-10-12 06:19:00	00:15:00	2025-10-12 01:18:03.791988-05	\N	2025-10-12 01:20:01.791988-05	f	\N	2025-10-12 08:18:11.964301-05
cad774cc-aa13-494d-ad70-e6cbcc494e7a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:34:55.587305-05	2025-10-12 00:35:55.580683-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:32:55.587305-05	2025-10-12 00:35:55.592685-05	2025-10-12 00:42:55.587305-05	f	\N	2025-10-12 12:38:31.99013-05
ae7da4b4-0283-457a-b9e7-800556bf02bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:36:01.677136-05	2025-10-12 00:36:03.675891-05	\N	2025-10-12 05:36:00	00:15:00	2025-10-12 00:35:03.677136-05	2025-10-12 00:36:03.6909-05	2025-10-12 00:37:01.677136-05	f	\N	2025-10-12 12:38:31.99013-05
21e04ad9-e03a-40ac-98a8-ad089714fd37	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:37:22.760005-05	2025-10-12 00:37:22.761588-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:37:22.760005-05	2025-10-12 00:37:22.766495-05	2025-10-12 00:45:22.760005-05	f	\N	2025-10-12 12:38:31.99013-05
31275da2-67fa-4f84-a4e7-dda2a35e7202	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:37:01.689353-05	2025-10-12 00:37:22.764759-05	\N	2025-10-12 05:37:00	00:15:00	2025-10-12 00:36:03.689353-05	2025-10-12 00:37:22.76802-05	2025-10-12 00:38:01.689353-05	f	\N	2025-10-12 12:38:31.99013-05
cf9525a0-27e7-4f55-81c1-b5432579ef47	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:38:01.770512-05	2025-10-12 00:38:02.77632-05	\N	2025-10-12 05:38:00	00:15:00	2025-10-12 00:37:22.770512-05	2025-10-12 00:38:02.800504-05	2025-10-12 00:39:01.770512-05	f	\N	2025-10-12 12:38:31.99013-05
61b99ce7-e21d-49e9-bda9-e1871fbc2240	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:42:01.201219-05	2025-10-13 00:42:01.222027-05	\N	2025-10-13 05:42:00	00:15:00	2025-10-13 00:41:01.201219-05	2025-10-13 00:42:01.23405-05	2025-10-13 00:43:01.201219-05	f	\N	2025-10-13 12:42:16.717855-05
3f1a4de5-671a-4694-b690-f9448047d049	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:17:01.487986-05	2025-10-13 00:17:04.514536-05	\N	2025-10-13 05:17:00	00:15:00	2025-10-13 00:16:04.487986-05	2025-10-13 00:17:04.522347-05	2025-10-13 00:18:01.487986-05	f	\N	2025-10-13 12:42:16.717855-05
5653d126-0c1a-44ac-9742-edd8c3d80915	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:21:01.603741-05	2025-10-13 00:21:04.627651-05	\N	2025-10-13 05:21:00	00:15:00	2025-10-13 00:20:04.603741-05	2025-10-13 00:21:04.636008-05	2025-10-13 00:22:01.603741-05	f	\N	2025-10-13 12:42:16.717855-05
03ba4474-4cb8-4233-92c6-ddf07e726acd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:24:01.679705-05	2025-10-13 00:24:04.697785-05	\N	2025-10-13 05:24:00	00:15:00	2025-10-13 00:23:04.679705-05	2025-10-13 00:24:04.707202-05	2025-10-13 00:25:01.679705-05	f	\N	2025-10-13 12:42:16.717855-05
936d589d-2ebb-49b5-9b7b-56029e6f8064	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:25:01.705862-05	2025-10-13 00:25:04.724585-05	\N	2025-10-13 05:25:00	00:15:00	2025-10-13 00:24:04.705862-05	2025-10-13 00:25:04.733863-05	2025-10-13 00:26:01.705862-05	f	\N	2025-10-13 12:42:16.717855-05
85198812-32c2-47f9-9c8d-904e5a5f5796	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:28:01.786573-05	2025-10-13 00:28:04.812681-05	\N	2025-10-13 05:28:00	00:15:00	2025-10-13 00:27:04.786573-05	2025-10-13 00:28:04.819618-05	2025-10-13 00:29:01.786573-05	f	\N	2025-10-13 12:42:16.717855-05
d27e19fe-e494-492c-8a82-a4719f08e4c0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:29:01.818564-05	2025-10-13 00:29:04.844868-05	\N	2025-10-13 05:29:00	00:15:00	2025-10-13 00:28:04.818564-05	2025-10-13 00:29:04.85647-05	2025-10-13 00:30:01.818564-05	f	\N	2025-10-13 12:42:16.717855-05
b34eec00-ac49-4aec-84fe-e7a89086d94f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:30:01.854458-05	2025-10-13 00:30:04.873412-05	\N	2025-10-13 05:30:00	00:15:00	2025-10-13 00:29:04.854458-05	2025-10-13 00:30:04.886122-05	2025-10-13 00:31:01.854458-05	f	\N	2025-10-13 12:42:16.717855-05
f2e908b0-80ce-4811-9357-86dae4a06001	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:31:01.88445-05	2025-10-13 00:31:04.902273-05	\N	2025-10-13 05:31:00	00:15:00	2025-10-13 00:30:04.88445-05	2025-10-13 00:31:04.912097-05	2025-10-13 00:32:01.88445-05	f	\N	2025-10-13 12:42:16.717855-05
708a5144-48e5-4505-96a7-7bed3ea5c2ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:35:01.001716-05	2025-10-13 00:35:01.017599-05	\N	2025-10-13 05:35:00	00:15:00	2025-10-13 00:34:05.001716-05	2025-10-13 00:35:01.026705-05	2025-10-13 00:36:01.001716-05	f	\N	2025-10-13 12:42:16.717855-05
1f8259b2-4a50-474d-8722-a0f1888ad006	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:36:01.025315-05	2025-10-13 00:36:01.04721-05	\N	2025-10-13 05:36:00	00:15:00	2025-10-13 00:35:01.025315-05	2025-10-13 00:36:01.057717-05	2025-10-13 00:37:01.025315-05	f	\N	2025-10-13 12:42:16.717855-05
1d1bc40d-83e6-4c6a-868f-694e4301dfe2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:37:01.056519-05	2025-10-13 00:37:01.078158-05	\N	2025-10-13 05:37:00	00:15:00	2025-10-13 00:36:01.056519-05	2025-10-13 00:37:01.090856-05	2025-10-13 00:38:01.056519-05	f	\N	2025-10-13 12:42:16.717855-05
d4acf536-4ac6-414e-ad92-8c14514a8ef0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:39:01.120186-05	2025-10-13 00:39:01.135093-05	\N	2025-10-13 05:39:00	00:15:00	2025-10-13 00:38:01.120186-05	2025-10-13 00:39:01.146318-05	2025-10-13 00:40:01.120186-05	f	\N	2025-10-13 12:42:16.717855-05
0e1b7257-7455-4250-97b4-922658f4fb8c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:41:01.173141-05	2025-10-13 00:41:01.193248-05	\N	2025-10-13 05:41:00	00:15:00	2025-10-13 00:40:01.173141-05	2025-10-13 00:41:01.202442-05	2025-10-13 00:42:01.173141-05	f	\N	2025-10-13 12:42:16.717855-05
985648c7-f2db-4b20-965b-5f84439f5094	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:40:35.233636-05	2025-10-13 00:41:35.232457-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:38:35.233636-05	2025-10-13 00:41:35.241074-05	2025-10-13 00:48:35.233636-05	f	\N	2025-10-13 12:42:16.717855-05
b822f7d3-ad22-4ad3-a060-f1bec3361d51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:36:01.88297-05	2025-10-12 19:36:04.899939-05	\N	2025-10-13 00:36:00	00:15:00	2025-10-12 19:35:04.88297-05	2025-10-12 19:36:04.913821-05	2025-10-12 19:37:01.88297-05	f	\N	2025-10-13 12:42:16.717855-05
e8da40bb-1ef2-4603-9b0e-4995d1522293	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:38:01.595161-05	2025-10-12 20:38:02.608828-05	\N	2025-10-13 01:38:00	00:15:00	2025-10-12 20:37:02.595161-05	2025-10-12 20:38:02.621874-05	2025-10-12 20:39:01.595161-05	f	\N	2025-10-13 12:42:16.717855-05
c911173c-341e-4e6f-a568-7ad4d3836b21	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:37:34.937762-05	2025-10-12 21:38:34.935158-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:35:34.937762-05	2025-10-12 21:38:34.942488-05	2025-10-12 21:45:34.937762-05	f	\N	2025-10-13 12:42:16.717855-05
252fc5a3-48e5-4555-80f4-7e28640068fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:37:01.912064-05	2025-10-12 19:37:04.930512-05	\N	2025-10-13 00:37:00	00:15:00	2025-10-12 19:36:04.912064-05	2025-10-12 19:37:04.940443-05	2025-10-12 19:38:01.912064-05	f	\N	2025-10-13 12:42:16.717855-05
850b4f30-0cec-4df7-b942-ddab34a21f42	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:38:01.939045-05	2025-10-12 19:38:04.959482-05	\N	2025-10-13 00:38:00	00:15:00	2025-10-12 19:37:04.939045-05	2025-10-12 19:38:04.969166-05	2025-10-12 19:39:01.939045-05	f	\N	2025-10-13 12:42:16.717855-05
46cf01db-25e8-49db-b80d-a79832fff403	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:37:34.730724-05	2025-10-12 19:38:34.728983-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:35:34.730724-05	2025-10-12 19:38:34.734921-05	2025-10-12 19:45:34.730724-05	f	\N	2025-10-13 12:42:16.717855-05
e92455b1-b224-4e72-b7a4-0c1575883f98	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:39:01.967936-05	2025-10-12 19:39:04.987933-05	\N	2025-10-13 00:39:00	00:15:00	2025-10-12 19:38:04.967936-05	2025-10-12 19:39:04.997158-05	2025-10-12 19:40:01.967936-05	f	\N	2025-10-13 12:42:16.717855-05
19cfd319-0142-4b43-98e8-fc77b057702e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:40:01.995907-05	2025-10-12 19:40:05.017372-05	\N	2025-10-13 00:40:00	00:15:00	2025-10-12 19:39:04.995907-05	2025-10-12 19:40:05.02879-05	2025-10-12 19:41:01.995907-05	f	\N	2025-10-13 12:42:16.717855-05
cfc5fd11-ef23-48f7-9632-c56b964cc557	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:41:01.027458-05	2025-10-12 19:41:01.027706-05	\N	2025-10-13 00:41:00	00:15:00	2025-10-12 19:40:05.027458-05	2025-10-12 19:41:01.035013-05	2025-10-12 19:42:01.027458-05	f	\N	2025-10-13 12:42:16.717855-05
2b1a8b14-054a-4860-b706-3b69653880c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:55:01.763558-05	2025-10-12 18:55:03.779063-05	\N	2025-10-12 23:55:00	00:15:00	2025-10-12 18:54:03.763558-05	2025-10-12 18:55:03.793294-05	2025-10-12 18:56:01.763558-05	f	\N	2025-10-13 12:42:16.717855-05
bd9f4e71-e2fd-4e4a-b653-88adfe0c37be	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:40:34.736491-05	2025-10-12 19:41:34.7186-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:38:34.736491-05	2025-10-12 19:41:34.727286-05	2025-10-12 19:48:34.736491-05	f	\N	2025-10-13 12:42:16.717855-05
320fdcc4-8f02-4f73-95d7-7ef5177f67f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:56:01.791734-05	2025-10-12 18:56:03.805535-05	\N	2025-10-12 23:56:00	00:15:00	2025-10-12 18:55:03.791734-05	2025-10-12 18:56:03.820135-05	2025-10-12 18:57:01.791734-05	f	\N	2025-10-13 12:42:16.717855-05
0dc4956b-75e4-4f4f-81ab-6518d0cbb7c6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:57:01.818289-05	2025-10-12 18:57:03.833332-05	\N	2025-10-12 23:57:00	00:15:00	2025-10-12 18:56:03.818289-05	2025-10-12 18:57:03.84908-05	2025-10-12 18:58:01.818289-05	f	\N	2025-10-13 12:42:16.717855-05
3b22f839-c5c5-4d03-b871-79da5da7e58b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:46:01.141476-05	2025-10-12 19:46:01.163718-05	\N	2025-10-13 00:46:00	00:15:00	2025-10-12 19:45:01.141476-05	2025-10-12 19:46:01.173184-05	2025-10-12 19:47:01.141476-05	f	\N	2025-10-13 12:42:16.717855-05
235f52c0-df42-4d20-936b-8df9d9e33beb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:47:01.171895-05	2025-10-12 19:47:01.18898-05	\N	2025-10-13 00:47:00	00:15:00	2025-10-12 19:46:01.171895-05	2025-10-12 19:47:01.201371-05	2025-10-12 19:48:01.171895-05	f	\N	2025-10-13 12:42:16.717855-05
3838b754-234b-4de6-81a8-6c9607c89ece	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:46:34.730236-05	2025-10-12 19:47:34.729365-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:44:34.730236-05	2025-10-12 19:47:34.735219-05	2025-10-12 19:54:34.730236-05	f	\N	2025-10-13 12:42:16.717855-05
29e00ec5-ffcb-4970-a37b-4e1e72e67264	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:50:01.255848-05	2025-10-12 19:50:01.27881-05	\N	2025-10-13 00:50:00	00:15:00	2025-10-12 19:49:01.255848-05	2025-10-12 19:50:01.288515-05	2025-10-12 19:51:01.255848-05	f	\N	2025-10-13 12:42:16.717855-05
6774f497-4894-4a4e-849f-ea37913c0695	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:49:34.73631-05	2025-10-12 19:50:34.733533-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:47:34.73631-05	2025-10-12 19:50:34.741983-05	2025-10-12 19:57:34.73631-05	f	\N	2025-10-13 12:42:16.717855-05
f3a06392-a054-4cb9-81d3-7f7d45ebe1ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:51:01.287321-05	2025-10-12 19:51:01.310337-05	\N	2025-10-13 00:51:00	00:15:00	2025-10-12 19:50:01.287321-05	2025-10-12 19:51:01.321082-05	2025-10-12 19:52:01.287321-05	f	\N	2025-10-13 12:42:16.717855-05
05e27dcc-da16-4f64-b4d0-796045557226	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:52:01.319743-05	2025-10-12 19:52:01.336634-05	\N	2025-10-13 00:52:00	00:15:00	2025-10-12 19:51:01.319743-05	2025-10-12 19:52:01.350412-05	2025-10-12 19:53:01.319743-05	f	\N	2025-10-13 12:42:16.717855-05
05c54b19-e942-4edd-81a5-4ea2e8788c87	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:53:01.34919-05	2025-10-12 19:53:01.364498-05	\N	2025-10-13 00:53:00	00:15:00	2025-10-12 19:52:01.34919-05	2025-10-12 19:53:01.375-05	2025-10-12 19:54:01.34919-05	f	\N	2025-10-13 12:42:16.717855-05
59cae43d-891f-4125-b185-e424942d0e44	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:52:34.744129-05	2025-10-12 19:53:34.739783-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:50:34.744129-05	2025-10-12 19:53:34.744353-05	2025-10-12 20:00:34.744129-05	f	\N	2025-10-13 12:42:16.717855-05
402353ed-9535-445f-a65f-fd8059809896	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:54:01.373724-05	2025-10-12 19:54:01.390662-05	\N	2025-10-13 00:54:00	00:15:00	2025-10-12 19:53:01.373724-05	2025-10-12 19:54:01.400452-05	2025-10-12 19:55:01.373724-05	f	\N	2025-10-13 12:42:16.717855-05
fcac3c34-7240-4029-914c-391a05fc8230	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:56:01.428156-05	2025-10-12 19:56:01.438663-05	\N	2025-10-13 00:56:00	00:15:00	2025-10-12 19:55:01.428156-05	2025-10-12 19:56:01.448239-05	2025-10-12 19:57:01.428156-05	f	\N	2025-10-13 12:42:16.717855-05
8572788e-e379-4de1-a9d5-24ba2293e47e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:58:01.474796-05	2025-10-12 19:58:01.495421-05	\N	2025-10-13 00:58:00	00:15:00	2025-10-12 19:57:01.474796-05	2025-10-12 19:58:01.507508-05	2025-10-12 19:59:01.474796-05	f	\N	2025-10-13 12:42:16.717855-05
0ab38b27-f63a-4e91-9c0d-1c20140a2e82	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 08:49:01.818037-05	\N	\N	2025-10-12 13:49:00	00:15:00	2025-10-12 08:48:02.818037-05	\N	2025-10-12 08:50:01.818037-05	f	\N	2025-10-12 10:17:35.764652-05
ccf51232-ab82-4c63-8f48-7e5beaf947ec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:40:01.819471-05	2025-10-12 00:40:02.806536-05	\N	2025-10-12 05:40:00	00:15:00	2025-10-12 00:39:02.819471-05	2025-10-12 00:40:02.819116-05	2025-10-12 00:41:01.819471-05	f	\N	2025-10-12 12:48:52.6417-05
d77bf764-a336-4205-8afe-a099647ee64f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:39:01.799218-05	2025-10-12 00:39:02.789995-05	\N	2025-10-12 05:39:00	00:15:00	2025-10-12 00:38:02.799218-05	2025-10-12 00:39:02.821129-05	2025-10-12 00:40:01.799218-05	f	\N	2025-10-12 12:48:52.6417-05
a61d964c-9c7e-4fa5-ab66-325cbb7f17de	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 12:41:01.093249-05	\N	\N	2025-10-12 17:41:00	00:15:00	2025-10-12 12:40:04.093249-05	\N	2025-10-12 12:42:01.093249-05	f	\N	2025-10-12 12:48:52.6417-05
e61da2c7-3c22-4548-a77b-9ba151e1f6e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:59:01.505859-05	2025-10-12 19:59:01.519194-05	\N	2025-10-13 00:59:00	00:15:00	2025-10-12 19:58:01.505859-05	2025-10-12 19:59:01.526988-05	2025-10-12 20:00:01.505859-05	f	\N	2025-10-13 12:42:16.717855-05
7c169dbe-b33b-4a0f-a9aa-2b0d582c5fc5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:00:01.52574-05	2025-10-12 20:00:01.545097-05	\N	2025-10-13 01:00:00	00:15:00	2025-10-12 19:59:01.52574-05	2025-10-12 20:00:01.553064-05	2025-10-12 20:01:01.52574-05	f	\N	2025-10-13 12:42:16.717855-05
3ae5e72d-80fe-4b38-8287-c5f1cb7e36b4	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 20:00:01.549012-05	2025-10-12 20:00:05.544761-05	dailyStatsJob	2025-10-13 01:00:00	00:15:00	2025-10-12 20:00:01.549012-05	2025-10-12 20:00:05.547035-05	2025-10-26 20:00:01.549012-05	f	\N	2025-10-13 12:42:16.717855-05
bf1fe6e3-83a9-4b25-b144-6b7980878dd7	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 20:00:05.546201-05	2025-10-12 20:00:06.647356-05	\N	\N	00:15:00	2025-10-12 20:00:05.546201-05	2025-10-12 20:00:06.817111-05	2025-10-26 20:00:05.546201-05	f	\N	2025-10-13 12:42:16.717855-05
4d9bb340-f30e-48da-8242-7ed2dc400b66	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:01:01.551875-05	2025-10-12 20:01:01.568682-05	\N	2025-10-13 01:01:00	00:15:00	2025-10-12 20:00:01.551875-05	2025-10-12 20:01:01.574042-05	2025-10-12 20:02:01.551875-05	f	\N	2025-10-13 12:42:16.717855-05
99885fc3-7703-4034-9e53-b1ceadf0d0cd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:02:01.573382-05	2025-10-12 20:02:01.603269-05	\N	2025-10-13 01:02:00	00:15:00	2025-10-12 20:01:01.573382-05	2025-10-12 20:02:01.612202-05	2025-10-12 20:03:01.573382-05	f	\N	2025-10-13 12:42:16.717855-05
63bfbc86-7224-409c-94db-c2e22cefbaf6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:05:01.655986-05	2025-10-12 20:05:01.684317-05	\N	2025-10-13 01:05:00	00:15:00	2025-10-12 20:04:01.655986-05	2025-10-12 20:05:01.695013-05	2025-10-12 20:06:01.655986-05	f	\N	2025-10-13 12:42:16.717855-05
9a98102e-f706-4fad-9621-ac1428a5fbae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:06:01.693186-05	2025-10-12 20:06:01.718312-05	\N	2025-10-13 01:06:00	00:15:00	2025-10-12 20:05:01.693186-05	2025-10-12 20:06:01.72813-05	2025-10-12 20:07:01.693186-05	f	\N	2025-10-13 12:42:16.717855-05
2fdd99c2-6c54-48b5-9e1f-a7db18d9586f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:08:01.750153-05	2025-10-12 20:08:01.775081-05	\N	2025-10-13 01:08:00	00:15:00	2025-10-12 20:07:01.750153-05	2025-10-12 20:08:01.783293-05	2025-10-12 20:09:01.750153-05	f	\N	2025-10-13 12:42:16.717855-05
acca7d5b-3b8a-4bb5-b546-4c49be08f5ba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:09:01.782121-05	2025-10-12 20:09:01.796814-05	\N	2025-10-13 01:09:00	00:15:00	2025-10-12 20:08:01.782121-05	2025-10-12 20:09:01.808212-05	2025-10-12 20:10:01.782121-05	f	\N	2025-10-13 12:42:16.717855-05
cd68f579-c61e-4608-a63c-132b70d11031	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:11:01.834706-05	2025-10-12 20:11:01.850605-05	\N	2025-10-13 01:11:00	00:15:00	2025-10-12 20:10:01.834706-05	2025-10-12 20:11:01.860152-05	2025-10-12 20:12:01.834706-05	f	\N	2025-10-13 12:42:16.717855-05
0d314417-2e28-4865-b632-741e07549a6b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:10:34.786443-05	2025-10-12 20:11:34.783627-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:08:34.786443-05	2025-10-12 20:11:34.792058-05	2025-10-12 20:18:34.786443-05	f	\N	2025-10-13 12:42:16.717855-05
ea18298e-3704-4d32-8777-4526ed29a79d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:14:01.912054-05	2025-10-12 20:14:01.941087-05	\N	2025-10-13 01:14:00	00:15:00	2025-10-12 20:13:01.912054-05	2025-10-12 20:14:01.947576-05	2025-10-12 20:15:01.912054-05	f	\N	2025-10-13 12:42:16.717855-05
a27a4af8-4df3-435d-9565-8d4cf369bf72	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:17:01.00042-05	2025-10-12 20:17:02.01995-05	\N	2025-10-13 01:17:00	00:15:00	2025-10-12 20:16:02.00042-05	2025-10-12 20:17:02.028464-05	2025-10-12 20:18:01.00042-05	f	\N	2025-10-13 12:42:16.717855-05
9c592837-fc6b-4bcf-8a01-47da50edabda	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:19:34.804009-05	2025-10-12 20:20:34.802537-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:17:34.804009-05	2025-10-12 20:20:34.810035-05	2025-10-12 20:27:34.804009-05	f	\N	2025-10-13 12:42:16.717855-05
edc7e33d-9ebf-446c-82c4-c5f60bd15ada	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:54:34.632913-05	2025-10-12 18:55:34.630552-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:52:34.632913-05	2025-10-12 18:55:34.638189-05	2025-10-12 19:02:34.632913-05	f	\N	2025-10-13 12:42:16.717855-05
c9386aeb-0f5d-4a1f-9c2d-47e39cb30971	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:58:01.846834-05	2025-10-12 18:58:03.857365-05	\N	2025-10-12 23:58:00	00:15:00	2025-10-12 18:57:03.846834-05	2025-10-12 18:58:03.867851-05	2025-10-12 18:59:01.846834-05	f	\N	2025-10-13 12:42:16.717855-05
399c6d27-fddc-4f64-8714-4e0f69b990b8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:57:34.640118-05	2025-10-12 18:58:34.637393-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:55:34.640118-05	2025-10-12 18:58:34.644688-05	2025-10-12 19:05:34.640118-05	f	\N	2025-10-13 12:42:16.717855-05
1e90f885-e369-4d53-9f98-722ef632911b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:59:01.866364-05	2025-10-12 18:59:03.878354-05	\N	2025-10-12 23:59:00	00:15:00	2025-10-12 18:58:03.866364-05	2025-10-12 18:59:03.893418-05	2025-10-12 19:00:01.866364-05	f	\N	2025-10-13 12:42:16.717855-05
4342e12a-75e5-4bff-b4e1-fa9dbcd0694f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:00:01.891284-05	2025-10-12 19:00:03.907127-05	\N	2025-10-13 00:00:00	00:15:00	2025-10-12 18:59:03.891284-05	2025-10-12 19:00:03.919026-05	2025-10-12 19:01:01.891284-05	f	\N	2025-10-13 12:42:16.717855-05
5f2864db-b685-4140-ae5b-b0288fb2102f	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 19:00:03.912633-05	2025-10-12 19:00:07.908935-05	dailyStatsJob	2025-10-13 00:00:00	00:15:00	2025-10-12 19:00:03.912633-05	2025-10-12 19:00:07.913707-05	2025-10-26 19:00:03.912633-05	f	\N	2025-10-13 12:42:16.717855-05
cf34b910-6306-4077-8758-0a12bd298ee6	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 19:00:07.911829-05	2025-10-12 19:00:09.374994-05	\N	\N	00:15:00	2025-10-12 19:00:07.911829-05	2025-10-12 19:00:09.559551-05	2025-10-26 19:00:07.911829-05	f	\N	2025-10-13 12:42:16.717855-05
9ef9084b-1536-413e-a8b2-b9e8abaa71a7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:01:01.917154-05	2025-10-12 19:01:03.935732-05	\N	2025-10-13 00:01:00	00:15:00	2025-10-12 19:00:03.917154-05	2025-10-12 19:01:03.945129-05	2025-10-12 19:02:01.917154-05	f	\N	2025-10-13 12:42:16.717855-05
6eceddd9-2cf3-4a89-9d7a-420590f78e56	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:00:34.646281-05	2025-10-12 19:01:34.644204-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:58:34.646281-05	2025-10-12 19:01:34.652747-05	2025-10-12 19:08:34.646281-05	f	\N	2025-10-13 12:42:16.717855-05
111dd7c6-9cae-489a-8bad-0c84f829d5cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:02:01.943734-05	2025-10-12 19:02:03.96622-05	\N	2025-10-13 00:02:00	00:15:00	2025-10-12 19:01:03.943734-05	2025-10-12 19:02:03.976726-05	2025-10-12 19:03:01.943734-05	f	\N	2025-10-13 12:42:16.717855-05
8d3bd917-08d4-46ea-ade6-a1cfc7ba1dbe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:03:01.97503-05	2025-10-12 19:03:03.995936-05	\N	2025-10-13 00:03:00	00:15:00	2025-10-12 19:02:03.97503-05	2025-10-12 19:03:04.005842-05	2025-10-12 19:04:01.97503-05	f	\N	2025-10-13 12:42:16.717855-05
028e22cd-5146-458e-b0fb-6ffa2480379a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:04:01.004281-05	2025-10-12 19:04:04.022134-05	\N	2025-10-13 00:04:00	00:15:00	2025-10-12 19:03:04.004281-05	2025-10-12 19:04:04.029524-05	2025-10-12 19:05:01.004281-05	f	\N	2025-10-13 12:42:16.717855-05
1b4e29c1-76b6-447a-88d7-147639a40fdb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:03:34.654897-05	2025-10-12 19:04:34.648851-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:01:34.654897-05	2025-10-12 19:04:34.654645-05	2025-10-12 19:11:34.654897-05	f	\N	2025-10-13 12:42:16.717855-05
03b411cb-9d4e-4e73-bb8c-c57eccd5409b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:05:01.028115-05	2025-10-12 19:05:04.04878-05	\N	2025-10-13 00:05:00	00:15:00	2025-10-12 19:04:04.028115-05	2025-10-12 19:05:04.06102-05	2025-10-12 19:06:01.028115-05	f	\N	2025-10-13 12:42:16.717855-05
54caef9f-2c2b-46e6-9f59-cf05259c30c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:06:01.059103-05	2025-10-12 19:06:04.076257-05	\N	2025-10-13 00:06:00	00:15:00	2025-10-12 19:05:04.059103-05	2025-10-12 19:06:04.087582-05	2025-10-12 19:07:01.059103-05	f	\N	2025-10-13 12:42:16.717855-05
5b9d2eda-1e1a-462c-ba1a-73fb06abee82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:07:01.085799-05	2025-10-12 19:07:04.106444-05	\N	2025-10-13 00:07:00	00:15:00	2025-10-12 19:06:04.085799-05	2025-10-12 19:07:04.113876-05	2025-10-12 19:08:01.085799-05	f	\N	2025-10-13 12:42:16.717855-05
c6487219-12fc-4d20-b16d-3d87953297db	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:06:34.656155-05	2025-10-12 19:07:34.655151-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:04:34.656155-05	2025-10-12 19:07:34.662283-05	2025-10-12 19:14:34.656155-05	f	\N	2025-10-13 12:42:16.717855-05
dcfea9ac-2c14-4b90-991c-c635d2ac3efa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:08:01.112747-05	2025-10-12 19:08:04.133642-05	\N	2025-10-13 00:08:00	00:15:00	2025-10-12 19:07:04.112747-05	2025-10-12 19:08:04.143825-05	2025-10-12 19:09:01.112747-05	f	\N	2025-10-13 12:42:16.717855-05
74a49902-9b68-45f0-baf0-76223da3245b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:09:01.142112-05	2025-10-12 19:09:04.15879-05	\N	2025-10-13 00:09:00	00:15:00	2025-10-12 19:08:04.142112-05	2025-10-12 19:09:04.169751-05	2025-10-12 19:10:01.142112-05	f	\N	2025-10-13 12:42:16.717855-05
28b5811b-99aa-4702-a900-a63bd6725277	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:10:01.16797-05	2025-10-12 19:10:04.187194-05	\N	2025-10-13 00:10:00	00:15:00	2025-10-12 19:09:04.16797-05	2025-10-12 19:10:04.197772-05	2025-10-12 19:11:01.16797-05	f	\N	2025-10-13 12:42:16.717855-05
dd436b16-6180-4d6c-879f-8a4f10520d2b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:09:34.66396-05	2025-10-12 19:10:34.659233-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:07:34.66396-05	2025-10-12 19:10:34.664443-05	2025-10-12 19:17:34.66396-05	f	\N	2025-10-13 12:42:16.717855-05
a9dd8478-8111-4154-a3bd-b25315285124	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:11:01.196207-05	2025-10-12 19:11:04.215912-05	\N	2025-10-13 00:11:00	00:15:00	2025-10-12 19:10:04.196207-05	2025-10-12 19:11:04.227346-05	2025-10-12 19:12:01.196207-05	f	\N	2025-10-13 12:42:16.717855-05
34ec61e5-60b1-43a0-8419-64a4a4fa12ef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:12:01.225611-05	2025-10-12 19:12:04.243113-05	\N	2025-10-13 00:12:00	00:15:00	2025-10-12 19:11:04.225611-05	2025-10-12 19:12:04.246893-05	2025-10-12 19:13:01.225611-05	f	\N	2025-10-13 12:42:16.717855-05
3783c67d-c0e9-40dc-a93e-78cc54ddb42f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:13:01.246273-05	2025-10-12 19:13:04.271612-05	\N	2025-10-13 00:13:00	00:15:00	2025-10-12 19:12:04.246273-05	2025-10-12 19:13:04.280586-05	2025-10-12 19:14:01.246273-05	f	\N	2025-10-13 12:42:16.717855-05
b186f99e-f81c-4fa1-ad0d-bc64cea0eb71	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:12:34.66543-05	2025-10-12 19:13:34.665508-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:10:34.66543-05	2025-10-12 19:13:34.671583-05	2025-10-12 19:20:34.66543-05	f	\N	2025-10-13 12:42:16.717855-05
3b1c34be-2656-4f60-aa80-ed20a4d991f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:52:05.137166-05	2025-10-12 00:52:09.132804-05	\N	2025-10-12 05:52:00	00:15:00	2025-10-12 00:52:05.137166-05	2025-10-12 00:52:09.157468-05	2025-10-12 00:53:05.137166-05	f	\N	2025-10-12 12:52:29.995089-05
a930b71e-9d4a-4eba-a44b-27c5ac84c40b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:52:05.122016-05	2025-10-12 00:52:05.124795-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:52:05.122016-05	2025-10-12 00:52:05.133338-05	2025-10-12 01:00:05.122016-05	f	\N	2025-10-12 12:52:29.995089-05
ae6c1abd-d557-45d6-a026-67ed49372c25	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:14:01.279219-05	2025-10-12 19:14:04.295057-05	\N	2025-10-13 00:14:00	00:15:00	2025-10-12 19:13:04.279219-05	2025-10-12 19:14:04.306453-05	2025-10-12 19:15:01.279219-05	f	\N	2025-10-13 12:42:16.717855-05
f2cea425-b262-4ea0-9bea-6828ea3193d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:15:01.304944-05	2025-10-12 19:15:04.332376-05	\N	2025-10-13 00:15:00	00:15:00	2025-10-12 19:14:04.304944-05	2025-10-12 19:15:04.339373-05	2025-10-12 19:16:01.304944-05	f	\N	2025-10-13 12:42:16.717855-05
dd07f2d4-0168-4187-917e-dff21540cc7c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:15:34.673154-05	2025-10-12 19:15:34.683248-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:13:34.673154-05	2025-10-12 19:15:34.69169-05	2025-10-12 19:23:34.673154-05	f	\N	2025-10-13 12:42:16.717855-05
aa9af224-95d3-42b5-8bab-cd683a33cc63	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:16:01.338488-05	2025-10-12 19:16:04.356502-05	\N	2025-10-13 00:16:00	00:15:00	2025-10-12 19:15:04.338488-05	2025-10-12 19:16:04.367854-05	2025-10-12 19:17:01.338488-05	f	\N	2025-10-13 12:42:16.717855-05
6546cad3-c98c-41a3-ad83-2eadf8c161d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:17:01.366179-05	2025-10-12 19:17:04.386037-05	\N	2025-10-13 00:17:00	00:15:00	2025-10-12 19:16:04.366179-05	2025-10-12 19:17:04.394229-05	2025-10-12 19:18:01.366179-05	f	\N	2025-10-13 12:42:16.717855-05
8ab2ca86-af87-4018-b922-c0a8f3916c89	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:18:01.392765-05	2025-10-12 19:18:04.415896-05	\N	2025-10-13 00:18:00	00:15:00	2025-10-12 19:17:04.392765-05	2025-10-12 19:18:04.421913-05	2025-10-12 19:19:01.392765-05	f	\N	2025-10-13 12:42:16.717855-05
648ff9ca-2c29-4e1a-b158-fad063f3436e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:17:34.693798-05	2025-10-12 19:18:34.688457-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:15:34.693798-05	2025-10-12 19:18:34.692567-05	2025-10-12 19:25:34.693798-05	f	\N	2025-10-13 12:42:16.717855-05
29ae2375-fdb3-4994-b919-e4c7116fb291	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:19:01.420774-05	2025-10-12 19:19:04.441354-05	\N	2025-10-13 00:19:00	00:15:00	2025-10-12 19:18:04.420774-05	2025-10-12 19:19:04.456383-05	2025-10-12 19:20:01.420774-05	f	\N	2025-10-13 12:42:16.717855-05
402d39ee-affa-43a4-9f9c-9c6d74c9cb15	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:20:01.454688-05	2025-10-12 19:20:04.469708-05	\N	2025-10-13 00:20:00	00:15:00	2025-10-12 19:19:04.454688-05	2025-10-12 19:20:04.481835-05	2025-10-12 19:21:01.454688-05	f	\N	2025-10-13 12:42:16.717855-05
9a078064-beb1-4c39-9b21-b30f0a3191d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:21:01.48027-05	2025-10-12 19:21:04.499052-05	\N	2025-10-13 00:21:00	00:15:00	2025-10-12 19:20:04.48027-05	2025-10-12 19:21:04.512189-05	2025-10-12 19:22:01.48027-05	f	\N	2025-10-13 12:42:16.717855-05
91852f50-36cd-4ed9-aaca-a0fcaea95bac	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:20:34.69383-05	2025-10-12 19:21:34.696398-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:18:34.69383-05	2025-10-12 19:21:34.708535-05	2025-10-12 19:28:34.69383-05	f	\N	2025-10-13 12:42:16.717855-05
c122dad4-6ab6-4133-9cbd-eaa3e471969a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:23:34.710585-05	2025-10-12 19:24:34.702756-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:21:34.710585-05	2025-10-12 19:24:34.713296-05	2025-10-12 19:31:34.710585-05	f	\N	2025-10-13 12:42:16.717855-05
d83e420a-a94e-4e7d-81c3-48f462d7329a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:22:01.510646-05	2025-10-12 19:22:04.526623-05	\N	2025-10-13 00:22:00	00:15:00	2025-10-12 19:21:04.510646-05	2025-10-12 19:22:04.534648-05	2025-10-12 19:23:01.510646-05	f	\N	2025-10-13 12:42:16.717855-05
16b14c8e-8e5d-45d3-89d2-c384d7c3fe01	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:39:01.620113-05	2025-10-12 20:39:02.636956-05	\N	2025-10-13 01:39:00	00:15:00	2025-10-12 20:38:02.620113-05	2025-10-12 20:39:02.649127-05	2025-10-12 20:40:01.620113-05	f	\N	2025-10-13 12:42:16.717855-05
f1a8194f-945e-4334-b83e-cf4c45e462c6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:23:01.5335-05	2025-10-12 19:23:04.554373-05	\N	2025-10-13 00:23:00	00:15:00	2025-10-12 19:22:04.5335-05	2025-10-12 19:23:04.569005-05	2025-10-12 19:24:01.5335-05	f	\N	2025-10-13 12:42:16.717855-05
7ea0b072-1f16-42d7-b8ce-dcaeb6d64cc4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:35:01.857208-05	2025-10-12 19:35:04.873524-05	\N	2025-10-13 00:35:00	00:15:00	2025-10-12 19:34:04.857208-05	2025-10-12 19:35:04.884537-05	2025-10-12 19:36:01.857208-05	f	\N	2025-10-13 12:42:16.717855-05
e952d63d-f0fd-4d21-97e8-f54c2523e353	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:24:01.567155-05	2025-10-12 19:24:04.583868-05	\N	2025-10-13 00:24:00	00:15:00	2025-10-12 19:23:04.567155-05	2025-10-12 19:24:04.599071-05	2025-10-12 19:25:01.567155-05	f	\N	2025-10-13 12:42:16.717855-05
67d34ebd-2f74-4349-83e1-cfd2d5f06ef4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:34:34.72426-05	2025-10-12 19:35:34.723348-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:32:34.72426-05	2025-10-12 19:35:34.728984-05	2025-10-12 19:42:34.72426-05	f	\N	2025-10-13 12:42:16.717855-05
cfd3fb83-394e-458a-8c90-cad402e6964b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:25:01.597118-05	2025-10-12 19:25:04.608832-05	\N	2025-10-13 00:25:00	00:15:00	2025-10-12 19:24:04.597118-05	2025-10-12 19:25:04.618909-05	2025-10-12 19:26:01.597118-05	f	\N	2025-10-13 12:42:16.717855-05
681b63cf-2479-40dd-a687-4872e4c1bca8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:42:01.03417-05	2025-10-12 19:42:01.050811-05	\N	2025-10-13 00:42:00	00:15:00	2025-10-12 19:41:01.03417-05	2025-10-12 19:42:01.062327-05	2025-10-12 19:43:01.03417-05	f	\N	2025-10-13 12:42:16.717855-05
73e0caf8-871e-4ff1-8ce6-28e31e5871bd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:26:01.617599-05	2025-10-12 19:26:04.633291-05	\N	2025-10-13 00:26:00	00:15:00	2025-10-12 19:25:04.617599-05	2025-10-12 19:26:04.649251-05	2025-10-12 19:27:01.617599-05	f	\N	2025-10-13 12:42:16.717855-05
cea1cbfa-f812-47ca-adce-1b91a6af4858	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:43:01.06078-05	2025-10-12 19:43:01.078531-05	\N	2025-10-13 00:43:00	00:15:00	2025-10-12 19:42:01.06078-05	2025-10-12 19:43:01.088311-05	2025-10-12 19:44:01.06078-05	f	\N	2025-10-13 12:42:16.717855-05
1e08e16a-a35b-400b-be0f-31396b9f7de0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:27:01.647161-05	2025-10-12 19:27:04.656826-05	\N	2025-10-13 00:27:00	00:15:00	2025-10-12 19:26:04.647161-05	2025-10-12 19:27:04.666073-05	2025-10-12 19:28:01.647161-05	f	\N	2025-10-13 12:42:16.717855-05
a1f8a999-6824-4e15-b254-60470eafe115	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:26:34.715322-05	2025-10-12 19:27:34.707615-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:24:34.715322-05	2025-10-12 19:27:34.716482-05	2025-10-12 19:34:34.715322-05	f	\N	2025-10-13 12:42:16.717855-05
ef35b47b-d873-4f0d-9cb0-938cba818b29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:44:01.08693-05	2025-10-12 19:44:01.1061-05	\N	2025-10-13 00:44:00	00:15:00	2025-10-12 19:43:01.08693-05	2025-10-12 19:44:01.119045-05	2025-10-12 19:45:01.08693-05	f	\N	2025-10-13 12:42:16.717855-05
38555167-173e-434b-879e-c74663855ec1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:28:01.664823-05	2025-10-12 19:28:04.686094-05	\N	2025-10-13 00:28:00	00:15:00	2025-10-12 19:27:04.664823-05	2025-10-12 19:28:04.696796-05	2025-10-12 19:29:01.664823-05	f	\N	2025-10-13 12:42:16.717855-05
feb4e73a-b628-442a-9a35-df147b4ec1fc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:43:34.728844-05	2025-10-12 19:44:34.723757-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:41:34.728844-05	2025-10-12 19:44:34.728892-05	2025-10-12 19:51:34.728844-05	f	\N	2025-10-13 12:42:16.717855-05
874672e0-13be-4a53-8c11-61ad3ad8206a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:29:01.694996-05	2025-10-12 19:29:04.709102-05	\N	2025-10-13 00:29:00	00:15:00	2025-10-12 19:28:04.694996-05	2025-10-12 19:29:04.720272-05	2025-10-12 19:30:01.694996-05	f	\N	2025-10-13 12:42:16.717855-05
366e8d19-7b48-476c-87e1-732037b47370	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:45:01.11731-05	2025-10-12 19:45:01.133784-05	\N	2025-10-13 00:45:00	00:15:00	2025-10-12 19:44:01.11731-05	2025-10-12 19:45:01.142462-05	2025-10-12 19:46:01.11731-05	f	\N	2025-10-13 12:42:16.717855-05
6fc1b5b3-245b-45d0-944a-b47f75932a20	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:29:34.717555-05	2025-10-12 19:29:34.79301-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:27:34.717555-05	2025-10-12 19:29:34.798318-05	2025-10-12 19:37:34.717555-05	f	\N	2025-10-13 12:42:16.717855-05
4ba2086c-10d8-4fc6-a1a7-ff088fc37e44	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:30:01.719152-05	2025-10-12 19:30:04.731012-05	\N	2025-10-13 00:30:00	00:15:00	2025-10-12 19:29:04.719152-05	2025-10-12 19:30:04.740188-05	2025-10-12 19:31:01.719152-05	f	\N	2025-10-13 12:42:16.717855-05
5c499f00-859a-410d-8b98-c221d6563de6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:48:01.199774-05	2025-10-12 19:48:01.216867-05	\N	2025-10-13 00:48:00	00:15:00	2025-10-12 19:47:01.199774-05	2025-10-12 19:48:01.227394-05	2025-10-12 19:49:01.199774-05	f	\N	2025-10-13 12:42:16.717855-05
3977a9ff-6031-49b5-8821-6bd133470f3f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:31:01.738896-05	2025-10-12 19:31:04.762335-05	\N	2025-10-13 00:31:00	00:15:00	2025-10-12 19:30:04.738896-05	2025-10-12 19:31:04.769353-05	2025-10-12 19:32:01.738896-05	f	\N	2025-10-13 12:42:16.717855-05
48dfbd3b-2c28-47d1-ba26-659b2f9bfb70	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:49:01.225941-05	2025-10-12 19:49:01.247317-05	\N	2025-10-13 00:49:00	00:15:00	2025-10-12 19:48:01.225941-05	2025-10-12 19:49:01.257355-05	2025-10-12 19:50:01.225941-05	f	\N	2025-10-13 12:42:16.717855-05
a1234ff8-bfc7-4292-a4ae-8b94766ea8c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:32:01.768263-05	2025-10-12 19:32:04.788865-05	\N	2025-10-13 00:32:00	00:15:00	2025-10-12 19:31:04.768263-05	2025-10-12 19:32:04.797842-05	2025-10-12 19:33:01.768263-05	f	\N	2025-10-13 12:42:16.717855-05
49bbfd38-e64c-4493-b7ce-1707991fc116	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:31:34.799207-05	2025-10-12 19:32:34.717975-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:29:34.799207-05	2025-10-12 19:32:34.723166-05	2025-10-12 19:39:34.799207-05	f	\N	2025-10-13 12:42:16.717855-05
1695994f-ecdf-419e-be10-31552276f12e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:55:01.399132-05	2025-10-12 19:55:01.418078-05	\N	2025-10-13 00:55:00	00:15:00	2025-10-12 19:54:01.399132-05	2025-10-12 19:55:01.429547-05	2025-10-12 19:56:01.399132-05	f	\N	2025-10-13 12:42:16.717855-05
d9d5414b-a5a3-4d89-af46-acc0161b86f8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:33:01.796503-05	2025-10-12 19:33:04.823294-05	\N	2025-10-13 00:33:00	00:15:00	2025-10-12 19:32:04.796503-05	2025-10-12 19:33:04.835932-05	2025-10-12 19:34:01.796503-05	f	\N	2025-10-13 12:42:16.717855-05
45dcd535-4494-4f98-b719-ad25b0a64448	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:34:01.834284-05	2025-10-12 19:34:04.846847-05	\N	2025-10-13 00:34:00	00:15:00	2025-10-12 19:33:04.834284-05	2025-10-12 19:34:04.85887-05	2025-10-12 19:35:01.834284-05	f	\N	2025-10-13 12:42:16.717855-05
6cd1d3ba-5928-44f1-9ed1-ebfa9b8b35cc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:55:34.7455-05	2025-10-12 19:56:34.746182-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:53:34.7455-05	2025-10-12 19:56:34.754718-05	2025-10-12 20:03:34.7455-05	f	\N	2025-10-13 12:42:16.717855-05
c319542f-bf33-4dd1-86fd-41ebde2799b6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 19:57:01.446917-05	2025-10-12 19:57:01.466761-05	\N	2025-10-13 00:57:00	00:15:00	2025-10-12 19:56:01.446917-05	2025-10-12 19:57:01.475989-05	2025-10-12 19:58:01.446917-05	f	\N	2025-10-13 12:42:16.717855-05
5f275d7e-ae62-49df-aed6-ba7ac7eb2e96	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 19:58:34.756789-05	2025-10-12 19:59:34.752071-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:56:34.756789-05	2025-10-12 19:59:34.757175-05	2025-10-12 20:06:34.756789-05	f	\N	2025-10-13 12:42:16.717855-05
6fb49885-2391-43b8-85e2-fcc94d2db419	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:01:34.758135-05	2025-10-12 20:02:34.755878-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 19:59:34.758135-05	2025-10-12 20:02:34.764481-05	2025-10-12 20:09:34.758135-05	f	\N	2025-10-13 12:42:16.717855-05
03866dc6-d7f7-461d-b4d6-83d426dd6bd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:55:21.72741-05	2025-10-12 00:55:25.722596-05	\N	2025-10-12 05:55:00	00:15:00	2025-10-12 00:55:21.72741-05	2025-10-12 00:55:25.747849-05	2025-10-12 00:56:21.72741-05	f	\N	2025-10-12 12:55:45.570711-05
88660a6b-f53e-4143-b593-8be9ed0e0ce0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:55:21.712773-05	2025-10-12 00:55:21.715205-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:55:21.712773-05	2025-10-12 00:55:21.723264-05	2025-10-12 01:03:21.712773-05	f	\N	2025-10-12 12:55:45.570711-05
711d58a2-ac59-4923-8c84-39698012f7c5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:03:01.610693-05	2025-10-12 20:03:01.623376-05	\N	2025-10-13 01:03:00	00:15:00	2025-10-12 20:02:01.610693-05	2025-10-12 20:03:01.629823-05	2025-10-12 20:04:01.610693-05	f	\N	2025-10-13 12:42:16.717855-05
4dd63e87-bc07-4fd8-ba36-fc03e8927517	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:04:01.628771-05	2025-10-12 20:04:01.652205-05	\N	2025-10-13 01:04:00	00:15:00	2025-10-12 20:03:01.628771-05	2025-10-12 20:04:01.656662-05	2025-10-12 20:05:01.628771-05	f	\N	2025-10-13 12:42:16.717855-05
f551b735-c9a4-48e8-909a-b597d8206fcf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:04:34.766707-05	2025-10-12 20:05:34.771278-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:02:34.766707-05	2025-10-12 20:05:34.779612-05	2025-10-12 20:12:34.766707-05	f	\N	2025-10-13 12:42:16.717855-05
34d11442-e3da-4a1c-a811-1d468d396bf8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:07:01.726677-05	2025-10-12 20:07:01.746489-05	\N	2025-10-13 01:07:00	00:15:00	2025-10-12 20:06:01.726677-05	2025-10-12 20:07:01.750927-05	2025-10-12 20:08:01.726677-05	f	\N	2025-10-13 12:42:16.717855-05
0966fcb2-2725-4256-961e-31e191ab941c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:07:34.78153-05	2025-10-12 20:08:34.77892-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:05:34.78153-05	2025-10-12 20:08:34.785046-05	2025-10-12 20:15:34.78153-05	f	\N	2025-10-13 12:42:16.717855-05
b7bd8bfc-c9fc-4575-9645-43f8484641a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:10:01.806398-05	2025-10-12 20:10:01.825125-05	\N	2025-10-13 01:10:00	00:15:00	2025-10-12 20:09:01.806398-05	2025-10-12 20:10:01.836527-05	2025-10-12 20:11:01.806398-05	f	\N	2025-10-13 12:42:16.717855-05
2d1509e0-b042-4104-96f1-4f835765dfe9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:12:01.85829-05	2025-10-12 20:12:01.879284-05	\N	2025-10-13 01:12:00	00:15:00	2025-10-12 20:11:01.85829-05	2025-10-12 20:12:01.890902-05	2025-10-12 20:13:01.85829-05	f	\N	2025-10-13 12:42:16.717855-05
7f4da0a4-15dc-4e37-b040-6dcbae192763	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:13:01.889022-05	2025-10-12 20:13:01.906985-05	\N	2025-10-13 01:13:00	00:15:00	2025-10-12 20:12:01.889022-05	2025-10-12 20:13:01.913131-05	2025-10-12 20:14:01.889022-05	f	\N	2025-10-13 12:42:16.717855-05
87c6eceb-8df7-4a23-becc-1b6c9fe4f208	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:13:34.793994-05	2025-10-12 20:14:34.789978-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:11:34.793994-05	2025-10-12 20:14:34.794796-05	2025-10-12 20:21:34.793994-05	f	\N	2025-10-13 12:42:16.717855-05
b4f8d0a0-0ddf-4939-8106-bff64fd8d5ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:15:01.946588-05	2025-10-12 20:15:01.967656-05	\N	2025-10-13 01:15:00	00:15:00	2025-10-12 20:14:01.946588-05	2025-10-12 20:15:01.976867-05	2025-10-12 20:16:01.946588-05	f	\N	2025-10-13 12:42:16.717855-05
0083e4a5-6b94-4327-83a4-d354164ae08e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:16:01.97519-05	2025-10-12 20:16:01.99524-05	\N	2025-10-13 01:16:00	00:15:00	2025-10-12 20:15:01.97519-05	2025-10-12 20:16:02.001343-05	2025-10-12 20:17:01.97519-05	f	\N	2025-10-13 12:42:16.717855-05
ffd793e4-f965-4546-b420-9c4fbab551ca	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:16:34.795593-05	2025-10-12 20:17:34.795848-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:14:34.795593-05	2025-10-12 20:17:34.802432-05	2025-10-12 20:24:34.795593-05	f	\N	2025-10-13 12:42:16.717855-05
8329e896-3ca6-4097-b4ee-edc91a09c54e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:18:01.026952-05	2025-10-12 20:18:02.047535-05	\N	2025-10-13 01:18:00	00:15:00	2025-10-12 20:17:02.026952-05	2025-10-12 20:18:02.058479-05	2025-10-12 20:19:01.026952-05	f	\N	2025-10-13 12:42:16.717855-05
734df7e4-6607-41ad-b8eb-a37e33957965	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:19:01.056889-05	2025-10-12 20:19:02.075386-05	\N	2025-10-13 01:19:00	00:15:00	2025-10-12 20:18:02.056889-05	2025-10-12 20:19:02.087413-05	2025-10-12 20:20:01.056889-05	f	\N	2025-10-13 12:42:16.717855-05
9e8383b6-a5af-43ac-966e-3912b90a1c37	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:22:01.142843-05	2025-10-12 20:22:02.16179-05	\N	2025-10-13 01:22:00	00:15:00	2025-10-12 20:21:02.142843-05	2025-10-12 20:22:02.171316-05	2025-10-12 20:23:01.142843-05	f	\N	2025-10-13 12:42:16.717855-05
2a3df4d3-9388-494c-a610-eb7653ced0f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:20:01.085748-05	2025-10-12 20:20:02.105076-05	\N	2025-10-13 01:20:00	00:15:00	2025-10-12 20:19:02.085748-05	2025-10-12 20:20:02.115588-05	2025-10-12 20:21:01.085748-05	f	\N	2025-10-13 12:42:16.717855-05
b496cd7a-a032-408f-91da-39f1795152e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:40:01.830147-05	2025-10-12 22:40:01.852114-05	\N	2025-10-13 03:40:00	00:15:00	2025-10-12 22:39:01.830147-05	2025-10-12 22:40:01.859691-05	2025-10-12 22:41:01.830147-05	f	\N	2025-10-13 12:42:16.717855-05
308c92a4-63cf-48b1-9fea-42f16978cb08	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:40:01.647348-05	2025-10-12 20:40:02.657998-05	\N	2025-10-13 01:40:00	00:15:00	2025-10-12 20:39:02.647348-05	2025-10-12 20:40:02.665741-05	2025-10-12 20:41:01.647348-05	f	\N	2025-10-13 12:42:16.717855-05
e30f71cb-03a0-46e4-8219-64839e9b5f3a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:23:01.169877-05	2025-10-12 20:23:02.19214-05	\N	2025-10-13 01:23:00	00:15:00	2025-10-12 20:22:02.169877-05	2025-10-12 20:23:02.201113-05	2025-10-12 20:24:01.169877-05	f	\N	2025-10-13 12:42:16.717855-05
6f9258dd-0c13-41e9-8a77-6b8e1512e0b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:41:01.28113-05	2025-10-12 21:41:04.302601-05	\N	2025-10-13 02:41:00	00:15:00	2025-10-12 21:40:04.28113-05	2025-10-12 21:41:04.315125-05	2025-10-12 21:42:01.28113-05	f	\N	2025-10-13 12:42:16.717855-05
85f4f68a-288a-4d93-996a-9992f16c8c6f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:22:34.811359-05	2025-10-12 20:23:34.807441-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:20:34.811359-05	2025-10-12 20:23:34.815717-05	2025-10-12 20:30:34.811359-05	f	\N	2025-10-13 12:42:16.717855-05
81a0f143-a9c5-4fad-8534-32f6761290e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:41:01.664975-05	2025-10-12 20:41:02.6899-05	\N	2025-10-13 01:41:00	00:15:00	2025-10-12 20:40:02.664975-05	2025-10-12 20:41:02.69965-05	2025-10-12 20:42:01.664975-05	f	\N	2025-10-13 12:42:16.717855-05
cadb9fac-6d90-4103-ad4a-2618aca88d97	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:24:01.199863-05	2025-10-12 20:24:02.218428-05	\N	2025-10-13 01:24:00	00:15:00	2025-10-12 20:23:02.199863-05	2025-10-12 20:24:02.22805-05	2025-10-12 20:25:01.199863-05	f	\N	2025-10-13 12:42:16.717855-05
ee0090eb-35a4-4146-a571-5788406b2e63	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:40:34.846549-05	2025-10-12 20:41:34.839619-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:38:34.846549-05	2025-10-12 20:41:34.846087-05	2025-10-12 20:48:34.846549-05	f	\N	2025-10-13 12:42:16.717855-05
2e3eae72-4c96-4501-8edd-ec85517d6aa3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:40:34.944126-05	2025-10-12 21:41:34.939257-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:38:34.944126-05	2025-10-12 21:41:34.949104-05	2025-10-12 21:48:34.944126-05	f	\N	2025-10-13 12:42:16.717855-05
e02d6e7a-73d0-4751-b92d-b45bf6c81c73	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:25:01.226732-05	2025-10-12 20:25:02.245616-05	\N	2025-10-13 01:25:00	00:15:00	2025-10-12 20:24:02.226732-05	2025-10-12 20:25:02.258248-05	2025-10-12 20:26:01.226732-05	f	\N	2025-10-13 12:42:16.717855-05
ff4eb938-0218-44b9-bd63-36e6e5ead4fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:26:01.256362-05	2025-10-12 20:26:02.269048-05	\N	2025-10-13 01:26:00	00:15:00	2025-10-12 20:25:02.256362-05	2025-10-12 20:26:02.278283-05	2025-10-12 20:27:01.256362-05	f	\N	2025-10-13 12:42:16.717855-05
d78cb4de-0fcf-4ab4-84bd-04826f8dc091	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:42:01.698166-05	2025-10-12 20:42:02.714942-05	\N	2025-10-13 01:42:00	00:15:00	2025-10-12 20:41:02.698166-05	2025-10-12 20:42:02.727938-05	2025-10-12 20:43:01.698166-05	f	\N	2025-10-13 12:42:16.717855-05
91166c32-7261-494d-adde-4bb17b1eccbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:42:01.313492-05	2025-10-12 21:42:04.333887-05	\N	2025-10-13 02:42:00	00:15:00	2025-10-12 21:41:04.313492-05	2025-10-12 21:42:04.345708-05	2025-10-12 21:43:01.313492-05	f	\N	2025-10-13 12:42:16.717855-05
f996e33b-8ccd-4379-b0bc-29a6b4dc9f15	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:27:01.276829-05	2025-10-12 20:27:02.299609-05	\N	2025-10-13 01:27:00	00:15:00	2025-10-12 20:26:02.276829-05	2025-10-12 20:27:02.310892-05	2025-10-12 20:28:01.276829-05	f	\N	2025-10-13 12:42:16.717855-05
6077eedc-3d5e-45e4-80f2-65b676fe80cf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:28:34.825021-05	2025-10-12 20:29:34.820099-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:26:34.825021-05	2025-10-12 20:29:34.827092-05	2025-10-12 20:36:34.825021-05	f	\N	2025-10-13 12:42:16.717855-05
4480a77f-1c97-4059-b31d-4dabc6af07de	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:43:01.726109-05	2025-10-12 20:43:02.745065-05	\N	2025-10-13 01:43:00	00:15:00	2025-10-12 20:42:02.726109-05	2025-10-12 20:43:02.754608-05	2025-10-12 20:44:01.726109-05	f	\N	2025-10-13 12:42:16.717855-05
17381cce-a121-46f5-8853-a0988f636f6d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:43:34.950954-05	2025-10-12 21:44:34.946473-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:41:34.950954-05	2025-10-12 21:44:34.954201-05	2025-10-12 21:51:34.950954-05	f	\N	2025-10-13 12:42:16.717855-05
ebdb8416-20e1-4da0-b06d-4c3aa511a248	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:44:01.753204-05	2025-10-12 20:44:02.775103-05	\N	2025-10-13 01:44:00	00:15:00	2025-10-12 20:43:02.753204-05	2025-10-12 20:44:02.791491-05	2025-10-12 20:45:01.753204-05	f	\N	2025-10-13 12:42:16.717855-05
314037fd-c1e6-43f1-b26e-5a6eb5e664cb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:43:34.847289-05	2025-10-12 20:44:34.845231-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:41:34.847289-05	2025-10-12 20:44:34.851257-05	2025-10-12 20:51:34.847289-05	f	\N	2025-10-13 12:42:16.717855-05
e3d14d8a-37f8-43e0-b18d-43832f9aa982	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:46:01.425418-05	2025-10-12 21:46:04.442559-05	\N	2025-10-13 02:46:00	00:15:00	2025-10-12 21:45:04.425418-05	2025-10-12 21:46:04.452751-05	2025-10-12 21:47:01.425418-05	f	\N	2025-10-13 12:42:16.717855-05
cc9a95a2-af02-4811-85b5-2672ec65140c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:46:01.80738-05	2025-10-12 20:46:02.824212-05	\N	2025-10-13 01:46:00	00:15:00	2025-10-12 20:45:02.80738-05	2025-10-12 20:46:02.833668-05	2025-10-12 20:47:01.80738-05	f	\N	2025-10-13 12:42:16.717855-05
c58dcf28-63d6-4cb7-bb46-d1ee9d1e1075	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:46:34.955985-05	2025-10-12 21:47:34.952408-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:44:34.955985-05	2025-10-12 21:47:34.959209-05	2025-10-12 21:54:34.955985-05	f	\N	2025-10-13 12:42:16.717855-05
5f329ed5-5a47-4c60-b2ff-0fb0e26ddda6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:47:01.832596-05	2025-10-12 20:47:02.852153-05	\N	2025-10-13 01:47:00	00:15:00	2025-10-12 20:46:02.832596-05	2025-10-12 20:47:02.860709-05	2025-10-12 20:48:01.832596-05	f	\N	2025-10-13 12:42:16.717855-05
48e78eab-2986-4506-929f-34477f319aaf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:46:34.852524-05	2025-10-12 20:47:34.850395-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:44:34.852524-05	2025-10-12 20:47:34.858571-05	2025-10-12 20:54:34.852524-05	f	\N	2025-10-13 12:42:16.717855-05
bb3587c9-03f9-4cf0-82ff-8ccf1c323f3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:50:01.471638-05	2025-10-12 21:50:04.490445-05	\N	2025-10-13 02:50:00	00:15:00	2025-10-12 21:49:04.471638-05	2025-10-12 21:50:04.501414-05	2025-10-12 21:51:01.471638-05	f	\N	2025-10-13 12:42:16.717855-05
e763cb1a-e59a-4e1c-a7c0-66bd33d6cd5a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:49:01.88534-05	2025-10-12 20:49:02.900394-05	\N	2025-10-13 01:49:00	00:15:00	2025-10-12 20:48:02.88534-05	2025-10-12 20:49:02.909429-05	2025-10-12 20:50:01.88534-05	f	\N	2025-10-13 12:42:16.717855-05
169a2819-8804-4439-9b89-b8c2e45cff27	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:49:34.860562-05	2025-10-12 20:50:34.856002-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:47:34.860562-05	2025-10-12 20:50:34.860801-05	2025-10-12 20:57:34.860562-05	f	\N	2025-10-13 12:42:16.717855-05
10e8fa05-776b-4661-879a-ef85bd714508	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:56:01.746524-05	2025-10-12 00:56:05.732793-05	\N	2025-10-12 05:56:00	00:15:00	2025-10-12 00:55:25.746524-05	2025-10-12 00:56:05.750092-05	2025-10-12 00:57:01.746524-05	f	\N	2025-10-12 13:00:34.199077-05
89da47a9-3b8d-4058-b93a-738f98bcbf70	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:58:01.762191-05	2025-10-12 00:58:01.767842-05	\N	2025-10-12 05:58:00	00:15:00	2025-10-12 00:57:05.762191-05	2025-10-12 00:58:01.784087-05	2025-10-12 00:59:01.762191-05	f	\N	2025-10-12 13:00:34.199077-05
91ad5749-2296-4454-bd8b-bb405a894774	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 00:58:31.480943-05	2025-10-12 00:58:31.483829-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:58:31.480943-05	2025-10-12 00:58:31.490682-05	2025-10-12 01:06:31.480943-05	f	\N	2025-10-12 13:00:34.199077-05
f573d8eb-ae35-4f5e-b0ca-03dacc68d6f0	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T05:58:31.506Z"}	completed	0	0	0	f	2025-10-12 01:00:03.52227-05	2025-10-12 01:00:07.516161-05	dailyStatsJob	2025-10-12 06:00:00	00:15:00	2025-10-12 01:00:03.52227-05	2025-10-12 01:00:07.520726-05	2025-10-26 01:00:03.52227-05	f	\N	2025-10-12 13:00:34.199077-05
646bcc16-84ba-409c-835a-a2e184f0e11a	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 01:00:07.518956-05	2025-10-12 01:00:07.55719-05	\N	\N	00:15:00	2025-10-12 01:00:07.518956-05	2025-10-12 01:00:07.794659-05	2025-10-26 01:00:07.518956-05	f	\N	2025-10-12 13:00:34.199077-05
eae725cf-437d-4211-b443-32c6f509c0a4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:57:01.748554-05	2025-10-12 00:57:05.748279-05	\N	2025-10-12 05:57:00	00:15:00	2025-10-12 00:56:05.748554-05	2025-10-12 00:57:05.76333-05	2025-10-12 00:58:01.748554-05	f	\N	2025-10-12 13:00:34.199077-05
9f7705a8-eedd-42b5-a81c-7610e0a73519	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 00:59:01.783074-05	2025-10-12 00:59:03.498693-05	\N	2025-10-12 05:59:00	00:15:00	2025-10-12 00:58:01.783074-05	2025-10-12 00:59:03.527023-05	2025-10-12 01:00:01.783074-05	f	\N	2025-10-12 13:00:34.199077-05
e2710ac2-b665-4323-9d25-650ae19caf58	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:00:01.525869-05	2025-10-12 01:00:03.514594-05	\N	2025-10-12 06:00:00	00:15:00	2025-10-12 00:59:03.525869-05	2025-10-12 01:00:03.529512-05	2025-10-12 01:01:01.525869-05	f	\N	2025-10-12 13:00:34.199077-05
9cb841d8-6062-4ac8-8f3b-6a15d8d60b6c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:52:34.905556-05	2025-10-12 21:53:34.896675-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:50:34.905556-05	2025-10-12 21:53:34.903817-05	2025-10-12 22:00:34.905556-05	f	\N	2025-10-13 12:42:16.717855-05
34e44e32-9e0e-46c1-a0b4-2fa1f12245ea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:52:34.861977-05	2025-10-12 20:53:34.861897-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:50:34.861977-05	2025-10-12 20:53:34.868488-05	2025-10-12 21:00:34.861977-05	f	\N	2025-10-13 12:42:16.717855-05
fcec562d-e8b7-47db-80d2-6bb1f4db38e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:54:01.568994-05	2025-10-12 21:54:04.588377-05	\N	2025-10-13 02:54:00	00:15:00	2025-10-12 21:53:04.568994-05	2025-10-12 21:54:04.60164-05	2025-10-12 21:55:01.568994-05	f	\N	2025-10-13 12:42:16.717855-05
98d71865-fec0-4889-87b6-fe464c157f2c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:54:01.018018-05	2025-10-12 20:54:03.035507-05	\N	2025-10-13 01:54:00	00:15:00	2025-10-12 20:53:03.018018-05	2025-10-12 20:54:03.048966-05	2025-10-12 20:55:01.018018-05	f	\N	2025-10-13 12:42:16.717855-05
5d1833a5-449f-4db5-90a2-71f0ce4285e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:56:01.627814-05	2025-10-12 21:56:04.64088-05	\N	2025-10-13 02:56:00	00:15:00	2025-10-12 21:55:04.627814-05	2025-10-12 21:56:04.651555-05	2025-10-12 21:57:01.627814-05	f	\N	2025-10-13 12:42:16.717855-05
9fb8054f-d7a0-4778-a86c-89f1fb19fbc6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:56:01.071141-05	2025-10-12 20:56:03.093165-05	\N	2025-10-13 01:56:00	00:15:00	2025-10-12 20:55:03.071141-05	2025-10-12 20:56:03.106677-05	2025-10-12 20:57:01.071141-05	f	\N	2025-10-13 12:42:16.717855-05
2d1fe50d-ebef-4680-834c-411a618711dc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:55:34.869989-05	2025-10-12 20:56:34.866042-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:53:34.869989-05	2025-10-12 20:56:34.877353-05	2025-10-12 21:03:34.869989-05	f	\N	2025-10-13 12:42:16.717855-05
e6e70f80-f18f-4760-9067-d56cb7f2a62f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:55:34.905315-05	2025-10-12 21:56:34.899562-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:53:34.905315-05	2025-10-12 21:56:34.906266-05	2025-10-12 22:03:34.905315-05	f	\N	2025-10-13 12:42:16.717855-05
36b446fb-44b1-4e81-93bb-ca4c4f15adbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:57:01.104973-05	2025-10-12 20:57:03.116041-05	\N	2025-10-13 01:57:00	00:15:00	2025-10-12 20:56:03.104973-05	2025-10-12 20:57:03.129322-05	2025-10-12 20:58:01.104973-05	f	\N	2025-10-13 12:42:16.717855-05
eef7f4bb-df92-4e4b-a74d-fda24c5430d9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:00:01.177571-05	2025-10-12 21:00:03.19594-05	\N	2025-10-13 02:00:00	00:15:00	2025-10-12 20:59:03.177571-05	2025-10-12 21:00:03.20701-05	2025-10-12 21:01:01.177571-05	f	\N	2025-10-13 12:42:16.717855-05
3502c80a-22aa-415a-9a37-0286ca6b64bd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:01:34.877127-05	2025-10-12 21:02:34.875394-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:59:34.877127-05	2025-10-12 21:02:34.879576-05	2025-10-12 21:09:34.877127-05	f	\N	2025-10-13 12:42:16.717855-05
47d76aa5-7526-48bc-97f4-f53842c678e7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:16:01.61574-05	2025-10-12 21:16:03.632775-05	\N	2025-10-13 02:16:00	00:15:00	2025-10-12 21:15:03.61574-05	2025-10-12 21:16:03.644146-05	2025-10-12 21:17:01.61574-05	f	\N	2025-10-13 12:42:16.717855-05
0a6c2ac3-fab7-4268-9422-649ee91142ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:18:01.672959-05	2025-10-12 21:18:03.691357-05	\N	2025-10-13 02:18:00	00:15:00	2025-10-12 21:17:03.672959-05	2025-10-12 21:18:03.702574-05	2025-10-12 21:19:01.672959-05	f	\N	2025-10-13 12:42:16.717855-05
ab4fb1d1-2b96-43ab-b298-add48121ae29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:19:01.700796-05	2025-10-12 21:19:03.711665-05	\N	2025-10-13 02:19:00	00:15:00	2025-10-12 21:18:03.700796-05	2025-10-12 21:19:03.722923-05	2025-10-12 21:20:01.700796-05	f	\N	2025-10-13 12:42:16.717855-05
5170a375-8307-4bb6-8b5b-bcb18f58ffcf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:21:01.747852-05	2025-10-12 21:21:03.768121-05	\N	2025-10-13 02:21:00	00:15:00	2025-10-12 21:20:03.747852-05	2025-10-12 21:21:03.777074-05	2025-10-12 21:22:01.747852-05	f	\N	2025-10-13 12:42:16.717855-05
f221658d-e4b3-482b-a478-58d16438b412	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:23:01.803986-05	2025-10-12 21:23:03.820534-05	\N	2025-10-13 02:23:00	00:15:00	2025-10-12 21:22:03.803986-05	2025-10-12 21:23:03.82838-05	2025-10-12 21:24:01.803986-05	f	\N	2025-10-13 12:42:16.717855-05
af9bf28c-3e87-4097-8bc4-7fa415b959c6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:22:34.916175-05	2025-10-12 21:23:34.914655-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:20:34.916175-05	2025-10-12 21:23:34.922863-05	2025-10-12 21:30:34.916175-05	f	\N	2025-10-13 12:42:16.717855-05
350dfe12-d2d7-46f3-9013-7d3e52b2f70f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:26:01.88411-05	2025-10-12 21:26:03.903574-05	\N	2025-10-13 02:26:00	00:15:00	2025-10-12 21:25:03.88411-05	2025-10-12 21:26:03.915564-05	2025-10-12 21:27:01.88411-05	f	\N	2025-10-13 12:42:16.717855-05
2d4505cd-5e60-47b4-9ecc-abf810faa22c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:21:01.114136-05	2025-10-12 20:21:02.132297-05	\N	2025-10-13 01:21:00	00:15:00	2025-10-12 20:20:02.114136-05	2025-10-12 20:21:02.144705-05	2025-10-12 20:22:01.114136-05	f	\N	2025-10-13 12:42:16.717855-05
70fcc587-7aa4-43d8-b76a-959f744904b3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:33:01.447178-05	2025-10-12 20:33:02.465248-05	\N	2025-10-13 01:33:00	00:15:00	2025-10-12 20:32:02.447178-05	2025-10-12 20:33:02.474289-05	2025-10-12 20:34:01.447178-05	f	\N	2025-10-13 12:42:16.717855-05
26713c64-7547-42f2-a564-c214935c18cf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:25:34.81724-05	2025-10-12 20:26:34.813956-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:23:34.81724-05	2025-10-12 20:26:34.823124-05	2025-10-12 20:33:34.81724-05	f	\N	2025-10-13 12:42:16.717855-05
f4ffd2d4-240a-4970-9362-8217f3f9ca7e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:30:01.984385-05	2025-10-12 21:30:04.006969-05	\N	2025-10-13 02:30:00	00:15:00	2025-10-12 21:29:03.984385-05	2025-10-12 21:30:04.016251-05	2025-10-12 21:31:01.984385-05	f	\N	2025-10-13 12:42:16.717855-05
3078df8f-d06e-4d2a-9d07-4c55ba7028d5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:34:34.830772-05	2025-10-12 20:35:34.830144-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:32:34.830772-05	2025-10-12 20:35:34.841581-05	2025-10-12 20:42:34.830772-05	f	\N	2025-10-13 12:42:16.717855-05
148a48d9-0817-4b6b-b994-676e03a10c13	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:39:01.450621-05	2025-10-12 23:39:03.471284-05	\N	2025-10-13 04:39:00	00:15:00	2025-10-12 23:38:03.450621-05	2025-10-12 23:39:03.482879-05	2025-10-12 23:40:01.450621-05	f	\N	2025-10-13 12:42:16.717855-05
f25b2507-0464-46f8-a3f8-dbd64b60346d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:28:01.30921-05	2025-10-12 20:28:02.331615-05	\N	2025-10-13 01:28:00	00:15:00	2025-10-12 20:27:02.30921-05	2025-10-12 20:28:02.343034-05	2025-10-12 20:29:01.30921-05	f	\N	2025-10-13 12:42:16.717855-05
8fe2c0de-482c-4270-8c07-6cae7b81388e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:31:34.925636-05	2025-10-12 21:32:34.924367-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:29:34.925636-05	2025-10-12 21:32:34.930521-05	2025-10-12 21:39:34.925636-05	f	\N	2025-10-13 12:42:16.717855-05
996a6298-2574-471a-a966-bfc2642c9ffd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:45:01.789349-05	2025-10-12 20:45:02.799731-05	\N	2025-10-13 01:45:00	00:15:00	2025-10-12 20:44:02.789349-05	2025-10-12 20:45:02.808636-05	2025-10-12 20:46:01.789349-05	f	\N	2025-10-13 12:42:16.717855-05
0e764909-7799-48f9-abc1-2374bef71295	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:29:01.341379-05	2025-10-12 20:29:02.35858-05	\N	2025-10-13 01:29:00	00:15:00	2025-10-12 20:28:02.341379-05	2025-10-12 20:29:02.370332-05	2025-10-12 20:30:01.341379-05	f	\N	2025-10-13 12:42:16.717855-05
3ba155a6-4580-4c74-a0c3-1414c5199cf4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:47:01.451474-05	2025-10-12 21:47:04.471947-05	\N	2025-10-13 02:47:00	00:15:00	2025-10-12 21:46:04.451474-05	2025-10-12 21:47:04.478854-05	2025-10-12 21:48:01.451474-05	f	\N	2025-10-13 12:42:16.717855-05
cb30afc0-30a4-4578-af77-876b89529461	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:48:01.859458-05	2025-10-12 20:48:02.87772-05	\N	2025-10-13 01:48:00	00:15:00	2025-10-12 20:47:02.859458-05	2025-10-12 20:48:02.886823-05	2025-10-12 20:49:01.859458-05	f	\N	2025-10-13 12:42:16.717855-05
6a5485b4-ba46-4e27-aa93-69dc24d6b84b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:30:01.36884-05	2025-10-12 20:30:02.38016-05	\N	2025-10-13 01:30:00	00:15:00	2025-10-12 20:29:02.36884-05	2025-10-12 20:30:02.388746-05	2025-10-12 20:31:01.36884-05	f	\N	2025-10-13 12:42:16.717855-05
2c2701ba-7abe-4b13-bf16-766b6dd16f55	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:31:01.387308-05	2025-10-12 20:31:02.413599-05	\N	2025-10-13 01:31:00	00:15:00	2025-10-12 20:30:02.387308-05	2025-10-12 20:31:02.42021-05	2025-10-12 20:32:01.387308-05	f	\N	2025-10-13 12:42:16.717855-05
b3bc6bb7-70e3-4964-94cc-8ef155633f25	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:49:01.505656-05	2025-10-12 21:49:04.461491-05	\N	2025-10-13 02:49:00	00:15:00	2025-10-12 21:48:04.505656-05	2025-10-12 21:49:04.473149-05	2025-10-12 21:50:01.505656-05	f	\N	2025-10-13 12:42:16.717855-05
adf6e7ba-f86b-4df6-962f-7ab117f1de56	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:32:01.419647-05	2025-10-12 20:32:02.4398-05	\N	2025-10-13 01:32:00	00:15:00	2025-10-12 20:31:02.419647-05	2025-10-12 20:32:02.448644-05	2025-10-12 20:33:01.419647-05	f	\N	2025-10-13 12:42:16.717855-05
83849ef1-8c07-4a48-8b89-685e5b78252b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:50:01.908118-05	2025-10-12 20:50:02.934081-05	\N	2025-10-13 01:50:00	00:15:00	2025-10-12 20:49:02.908118-05	2025-10-12 20:50:02.969783-05	2025-10-12 20:51:01.908118-05	f	\N	2025-10-13 12:42:16.717855-05
5fd942e0-1e02-4f6f-8856-bd4b8cf4c7c6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:31:34.828451-05	2025-10-12 20:32:34.822852-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:29:34.828451-05	2025-10-12 20:32:34.829354-05	2025-10-12 20:39:34.828451-05	f	\N	2025-10-13 12:42:16.717855-05
1c552507-5642-4341-8598-952ca90c528a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:01:01.527565-05	2025-10-12 01:01:03.533283-05	\N	2025-10-12 06:01:00	00:15:00	2025-10-12 01:00:03.527565-05	2025-10-12 01:01:03.545645-05	2025-10-12 01:02:01.527565-05	f	\N	2025-10-12 13:16:11.915527-05
f52af642-64f4-4186-a3f3-7b75f914bc32	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:00:31.491631-05	2025-10-12 01:01:31.487913-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 00:58:31.491631-05	2025-10-12 01:01:31.49881-05	2025-10-12 01:08:31.491631-05	f	\N	2025-10-12 13:16:11.915527-05
9dee4b04-f578-40bf-aa2f-3c391926b7eb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:02:01.544138-05	2025-10-12 01:02:03.551951-05	\N	2025-10-12 06:02:00	00:15:00	2025-10-12 01:01:03.544138-05	2025-10-12 01:02:03.566394-05	2025-10-12 01:03:01.544138-05	f	\N	2025-10-12 13:16:11.915527-05
723bb15d-bd17-4789-aab9-a27c4e382e70	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:05:01.593531-05	2025-10-12 01:05:03.599605-05	\N	2025-10-12 06:05:00	00:15:00	2025-10-12 01:04:03.593531-05	2025-10-12 01:05:03.613153-05	2025-10-12 01:06:01.593531-05	f	\N	2025-10-12 13:16:11.915527-05
aba5dbf9-b26c-42cb-85da-c4ae060a4a16	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:06:01.61163-05	2025-10-12 01:06:03.616739-05	\N	2025-10-12 06:06:00	00:15:00	2025-10-12 01:05:03.61163-05	2025-10-12 01:06:03.628252-05	2025-10-12 01:07:01.61163-05	f	\N	2025-10-12 13:16:11.915527-05
73676890-f234-4d37-ad22-125848375ccd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:07:01.626722-05	2025-10-12 01:07:03.631201-05	\N	2025-10-12 06:07:00	00:15:00	2025-10-12 01:06:03.626722-05	2025-10-12 01:07:03.640454-05	2025-10-12 01:08:01.626722-05	f	\N	2025-10-12 13:16:11.915527-05
4a8f2b36-e8f8-4ea0-936b-17bbc921d20d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:06:31.506229-05	2025-10-12 01:07:31.496921-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 01:04:31.506229-05	2025-10-12 01:07:31.505838-05	2025-10-12 01:14:31.506229-05	f	\N	2025-10-12 13:16:11.915527-05
dc49f11d-b031-4deb-8e9f-d5aef15ee9aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:10:01.672817-05	2025-10-12 01:10:03.674499-05	\N	2025-10-12 06:10:00	00:15:00	2025-10-12 01:09:03.672817-05	2025-10-12 01:10:03.685963-05	2025-10-12 01:11:01.672817-05	f	\N	2025-10-12 13:16:11.915527-05
67d7e1b6-de79-4f06-96d6-7c5eff819a45	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:14:01.722661-05	2025-10-12 01:14:03.726505-05	\N	2025-10-12 06:14:00	00:15:00	2025-10-12 01:13:03.722661-05	2025-10-12 01:14:03.733812-05	2025-10-12 01:15:01.722661-05	f	\N	2025-10-12 13:16:11.915527-05
270ba034-4792-484c-8f31-af2f5ef62b91	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:16:01.754291-05	2025-10-12 01:16:03.760326-05	\N	2025-10-12 06:16:00	00:15:00	2025-10-12 01:15:03.754291-05	2025-10-12 01:16:03.771002-05	2025-10-12 01:17:01.754291-05	f	\N	2025-10-12 13:16:11.915527-05
d9535d21-9fa4-4da1-a170-495a7658c288	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:03:01.564662-05	2025-10-12 01:03:03.566963-05	\N	2025-10-12 06:03:00	00:15:00	2025-10-12 01:02:03.564662-05	2025-10-12 01:03:03.579378-05	2025-10-12 01:04:01.564662-05	f	\N	2025-10-12 13:16:11.915527-05
b97e32d5-9436-44f4-9682-b37e96f16959	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:04:01.577998-05	2025-10-12 01:04:03.583929-05	\N	2025-10-12 06:04:00	00:15:00	2025-10-12 01:03:03.577998-05	2025-10-12 01:04:03.594617-05	2025-10-12 01:05:01.577998-05	f	\N	2025-10-12 13:16:11.915527-05
1912a4ac-8442-4862-b2f2-c9af1d7de9db	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:03:31.500758-05	2025-10-12 01:04:31.491455-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 01:01:31.500758-05	2025-10-12 01:04:31.503591-05	2025-10-12 01:11:31.500758-05	f	\N	2025-10-12 13:16:11.915527-05
5fa22b61-b5f8-4fbc-ad71-852aa1522f8d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:08:01.639514-05	2025-10-12 01:08:03.646945-05	\N	2025-10-12 06:08:00	00:15:00	2025-10-12 01:07:03.639514-05	2025-10-12 01:08:03.658409-05	2025-10-12 01:09:01.639514-05	f	\N	2025-10-12 13:16:11.915527-05
1a631d03-8847-4ecd-b879-34baf1e4ed66	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:09:01.657564-05	2025-10-12 01:09:03.661516-05	\N	2025-10-12 06:09:00	00:15:00	2025-10-12 01:08:03.657564-05	2025-10-12 01:09:03.674404-05	2025-10-12 01:10:01.657564-05	f	\N	2025-10-12 13:16:11.915527-05
4d7e7de0-f405-4af5-a2ed-2cc2035e4a28	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:09:31.50821-05	2025-10-12 01:10:31.500536-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 01:07:31.50821-05	2025-10-12 01:10:31.507144-05	2025-10-12 01:17:31.50821-05	f	\N	2025-10-12 13:16:11.915527-05
76d99239-1c70-41a7-8d2a-199131b71aac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:11:01.684264-05	2025-10-12 01:11:03.690468-05	\N	2025-10-12 06:11:00	00:15:00	2025-10-12 01:10:03.684264-05	2025-10-12 01:11:03.703956-05	2025-10-12 01:12:01.684264-05	f	\N	2025-10-12 13:16:11.915527-05
c54071dc-2a0b-42cb-97d4-83b3e9fdde70	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:12:01.70221-05	2025-10-12 01:12:03.705188-05	\N	2025-10-12 06:12:00	00:15:00	2025-10-12 01:11:03.70221-05	2025-10-12 01:12:03.717155-05	2025-10-12 01:13:01.70221-05	f	\N	2025-10-12 13:16:11.915527-05
351d0a7f-e30f-485c-9bd2-e27daec27219	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:13:01.715839-05	2025-10-12 01:13:03.713214-05	\N	2025-10-12 06:13:00	00:15:00	2025-10-12 01:12:03.715839-05	2025-10-12 01:13:03.724096-05	2025-10-12 01:14:01.715839-05	f	\N	2025-10-12 13:16:11.915527-05
87019e36-a0d7-46f0-999f-5811a367cd0b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:12:31.508768-05	2025-10-12 01:13:31.49618-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 01:10:31.508768-05	2025-10-12 01:13:31.500185-05	2025-10-12 01:20:31.508768-05	f	\N	2025-10-12 13:16:11.915527-05
babba8a6-0fe0-4f6e-9a76-47c50693d5f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:15:01.733177-05	2025-10-12 01:15:03.745882-05	\N	2025-10-12 06:15:00	00:15:00	2025-10-12 01:14:03.733177-05	2025-10-12 01:15:03.755759-05	2025-10-12 01:16:01.733177-05	f	\N	2025-10-12 13:16:11.915527-05
52e5c6f0-2104-4cac-9648-6c66fe416094	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:49:34.960686-05	2025-10-12 21:50:34.895882-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:47:34.960686-05	2025-10-12 21:50:34.903595-05	2025-10-12 21:57:34.960686-05	f	\N	2025-10-13 12:42:16.717855-05
6876952e-7dad-411a-88c7-539138929983	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:51:01.968092-05	2025-10-12 20:51:02.955098-05	\N	2025-10-13 01:51:00	00:15:00	2025-10-12 20:50:02.968092-05	2025-10-12 20:51:02.965882-05	2025-10-12 20:52:01.968092-05	f	\N	2025-10-13 12:42:16.717855-05
747e4814-a7dc-4b13-b517-1fa1635ae2d8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:51:01.499905-05	2025-10-12 21:51:04.515281-05	\N	2025-10-13 02:51:00	00:15:00	2025-10-12 21:50:04.499905-05	2025-10-12 21:51:04.52187-05	2025-10-12 21:52:01.499905-05	f	\N	2025-10-13 12:42:16.717855-05
fcd3f32c-bf9d-4203-b681-b0161eee8788	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:52:01.96432-05	2025-10-12 20:52:02.978379-05	\N	2025-10-13 01:52:00	00:15:00	2025-10-12 20:51:02.96432-05	2025-10-12 20:52:02.987195-05	2025-10-12 20:53:01.96432-05	f	\N	2025-10-13 12:42:16.717855-05
e67d3a19-4f6d-4fca-a861-4f77f8ab5bdb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:53:01.986027-05	2025-10-12 20:53:03.010193-05	\N	2025-10-13 01:53:00	00:15:00	2025-10-12 20:52:02.986027-05	2025-10-12 20:53:03.019296-05	2025-10-12 20:54:01.986027-05	f	\N	2025-10-13 12:42:16.717855-05
a89e55bd-83d6-49ae-894e-4b3e92a25a77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:52:01.520902-05	2025-10-12 21:52:04.539754-05	\N	2025-10-13 02:52:00	00:15:00	2025-10-12 21:51:04.520902-05	2025-10-12 21:52:04.549447-05	2025-10-12 21:53:01.520902-05	f	\N	2025-10-13 12:42:16.717855-05
4a10593b-3958-454b-bfed-7ab5fa7469fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:55:01.047179-05	2025-10-12 20:55:03.06288-05	\N	2025-10-13 01:55:00	00:15:00	2025-10-12 20:54:03.047179-05	2025-10-12 20:55:03.072451-05	2025-10-12 20:56:01.047179-05	f	\N	2025-10-13 12:42:16.717855-05
3c3833ed-352f-4420-9650-471faeb9488f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:53:01.54801-05	2025-10-12 21:53:04.562307-05	\N	2025-10-13 02:53:00	00:15:00	2025-10-12 21:52:04.54801-05	2025-10-12 21:53:04.570161-05	2025-10-12 21:54:01.54801-05	f	\N	2025-10-13 12:42:16.717855-05
40091251-8a57-4260-8354-e0f7fed5f674	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:58:01.127607-05	2025-10-12 20:58:03.144994-05	\N	2025-10-13 01:58:00	00:15:00	2025-10-12 20:57:03.127607-05	2025-10-12 20:58:03.154804-05	2025-10-12 20:59:01.127607-05	f	\N	2025-10-13 12:42:16.717855-05
6034f91a-da36-40ee-9b73-6ba8ab4bb54d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:55:01.599784-05	2025-10-12 21:55:04.616541-05	\N	2025-10-13 02:55:00	00:15:00	2025-10-12 21:54:04.599784-05	2025-10-12 21:55:04.629446-05	2025-10-12 21:56:01.599784-05	f	\N	2025-10-13 12:42:16.717855-05
e232dc92-8374-4ac7-b597-678bde2a98ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:59:01.153449-05	2025-10-12 20:59:03.168846-05	\N	2025-10-13 01:59:00	00:15:00	2025-10-12 20:58:03.153449-05	2025-10-12 20:59:03.178926-05	2025-10-12 21:00:01.153449-05	f	\N	2025-10-13 12:42:16.717855-05
0668eff3-c4aa-4cd1-aa62-640b85ad271a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:58:34.879065-05	2025-10-12 20:59:34.871132-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:56:34.879065-05	2025-10-12 20:59:34.875909-05	2025-10-12 21:06:34.879065-05	f	\N	2025-10-13 12:42:16.717855-05
54b6490d-66b3-4788-a5e0-d0ef546706ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:28:01.929571-05	2025-10-12 21:28:03.946885-05	\N	2025-10-13 02:28:00	00:15:00	2025-10-12 21:27:03.929571-05	2025-10-12 21:28:03.953781-05	2025-10-12 21:29:01.929571-05	f	\N	2025-10-13 12:42:16.717855-05
73b016d3-02f7-4b4c-966b-7a0ce6a6a99a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:57:01.650244-05	2025-10-12 21:57:04.666437-05	\N	2025-10-13 02:57:00	00:15:00	2025-10-12 21:56:04.650244-05	2025-10-12 21:57:04.67571-05	2025-10-12 21:58:01.650244-05	f	\N	2025-10-13 12:42:16.717855-05
3295ef39-d5e5-4cc9-b6f9-5c5938e61c93	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:28:34.92114-05	2025-10-12 21:29:34.917842-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:26:34.92114-05	2025-10-12 21:29:34.924148-05	2025-10-12 21:36:34.92114-05	f	\N	2025-10-13 12:42:16.717855-05
9f9fddb2-798a-41c6-b441-f5692d2f90f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:58:01.674243-05	2025-10-12 21:58:04.691672-05	\N	2025-10-13 02:58:00	00:15:00	2025-10-12 21:57:04.674243-05	2025-10-12 21:58:04.704808-05	2025-10-12 21:59:01.674243-05	f	\N	2025-10-13 12:42:16.717855-05
ac504f94-9a7e-4a11-b6f4-aa90bd180c09	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:59:01.702951-05	2025-10-12 21:59:04.719452-05	\N	2025-10-13 02:59:00	00:15:00	2025-10-12 21:58:04.702951-05	2025-10-12 21:59:04.726167-05	2025-10-12 22:00:01.702951-05	f	\N	2025-10-13 12:42:16.717855-05
66635f73-64d6-4ab9-93e4-f6f95a87a60e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:58:34.908216-05	2025-10-12 21:59:34.902455-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:56:34.908216-05	2025-10-12 21:59:34.906553-05	2025-10-12 22:06:34.908216-05	f	\N	2025-10-13 12:42:16.717855-05
10d1b613-6c90-424e-937e-1a42cc4351ca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:00:01.725221-05	2025-10-12 22:00:04.743424-05	\N	2025-10-13 03:00:00	00:15:00	2025-10-12 21:59:04.725221-05	2025-10-12 22:00:04.755062-05	2025-10-12 22:01:01.725221-05	f	\N	2025-10-13 12:42:16.717855-05
7ef425d3-c46c-4975-9aa3-1da21bac6f27	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 22:00:04.748902-05	2025-10-12 22:00:08.745019-05	dailyStatsJob	2025-10-13 03:00:00	00:15:00	2025-10-12 22:00:04.748902-05	2025-10-12 22:00:08.747109-05	2025-10-26 22:00:04.748902-05	f	\N	2025-10-13 12:42:16.717855-05
f05cc558-dd89-4a3c-a23d-156be1e85bb6	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 22:00:08.746369-05	2025-10-12 22:00:09.375445-05	\N	\N	00:15:00	2025-10-12 22:00:08.746369-05	2025-10-12 22:00:09.54557-05	2025-10-26 22:00:08.746369-05	f	\N	2025-10-13 12:42:16.717855-05
0f90e800-4645-493f-8afd-925b16af4e59	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:01:01.753569-05	2025-10-12 22:01:04.766874-05	\N	2025-10-13 03:01:00	00:15:00	2025-10-12 22:00:04.753569-05	2025-10-12 22:01:04.774916-05	2025-10-12 22:02:01.753569-05	f	\N	2025-10-13 12:42:16.717855-05
691c7adb-86b1-4130-903a-5b3a9d07a103	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:02:01.773613-05	2025-10-12 22:02:04.787083-05	\N	2025-10-13 03:02:00	00:15:00	2025-10-12 22:01:04.773613-05	2025-10-12 22:02:04.794549-05	2025-10-12 22:03:01.773613-05	f	\N	2025-10-13 12:42:16.717855-05
1375362e-f0fd-4672-88f7-804690b4887e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:18:01.779116-05	2025-10-12 01:18:03.784008-05	\N	2025-10-12 06:18:00	00:15:00	2025-10-12 01:17:03.779116-05	2025-10-12 01:18:03.792755-05	2025-10-12 01:19:01.779116-05	f	\N	2025-10-12 13:34:05.609901-05
d58d19f3-2556-4e57-951a-2efe6bced685	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 01:15:31.501398-05	2025-10-12 01:16:31.497796-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 01:13:31.501398-05	2025-10-12 01:16:31.505532-05	2025-10-12 01:23:31.501398-05	f	\N	2025-10-12 13:34:05.609901-05
0d0f7d25-dcc0-449b-8a47-c71ca14fff58	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 01:17:01.769486-05	2025-10-12 01:17:03.772227-05	\N	2025-10-12 06:17:00	00:15:00	2025-10-12 01:16:03.769486-05	2025-10-12 01:17:03.780146-05	2025-10-12 01:18:01.769486-05	f	\N	2025-10-12 13:34:05.609901-05
9be6b44c-0b90-4ecf-b7cb-f25ede745e01	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:01:34.907735-05	2025-10-12 22:02:34.904756-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:59:34.907735-05	2025-10-12 22:02:34.911552-05	2025-10-12 22:09:34.907735-05	f	\N	2025-10-13 12:42:16.717855-05
bc1d863d-a67f-4abf-a44d-886ba6104fa5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:03:01.793013-05	2025-10-12 22:03:04.814614-05	\N	2025-10-13 03:03:00	00:15:00	2025-10-12 22:02:04.793013-05	2025-10-12 22:03:04.821735-05	2025-10-12 22:04:01.793013-05	f	\N	2025-10-13 12:42:16.717855-05
567414c1-63f1-4272-8c3d-d75285a3eafb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:04:01.820648-05	2025-10-12 22:04:04.841343-05	\N	2025-10-13 03:04:00	00:15:00	2025-10-12 22:03:04.820648-05	2025-10-12 22:04:04.84859-05	2025-10-12 22:05:01.820648-05	f	\N	2025-10-13 12:42:16.717855-05
5e14d3b3-7a46-40d0-8eda-901810d25be3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:04:34.913002-05	2025-10-12 22:05:34.908286-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:02:34.913002-05	2025-10-12 22:05:34.91622-05	2025-10-12 22:12:34.913002-05	f	\N	2025-10-13 12:42:16.717855-05
2bba86cf-9f2f-4058-a7f0-baa9a7392a7e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:05:01.847393-05	2025-10-12 22:05:04.873904-05	\N	2025-10-13 03:05:00	00:15:00	2025-10-12 22:04:04.847393-05	2025-10-12 22:05:04.882574-05	2025-10-12 22:06:01.847393-05	f	\N	2025-10-13 12:42:16.717855-05
8e258e2e-4e45-42bf-aea7-a752eadd7ba9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:39:34.979971-05	2025-10-12 22:40:34.974586-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:37:34.979971-05	2025-10-12 22:40:34.983983-05	2025-10-12 22:47:34.979971-05	f	\N	2025-10-13 12:42:16.717855-05
8fb25f5e-c069-45de-8685-a29a1f03b548	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:08:01.94068-05	2025-10-12 22:08:04.956072-05	\N	2025-10-13 03:08:00	00:15:00	2025-10-12 22:07:04.94068-05	2025-10-12 22:08:04.964467-05	2025-10-12 22:09:01.94068-05	f	\N	2025-10-13 12:42:16.717855-05
11217578-d53c-4181-b2b9-c61e350694e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:40:01.481423-05	2025-10-12 23:40:03.499673-05	\N	2025-10-13 04:40:00	00:15:00	2025-10-12 23:39:03.481423-05	2025-10-12 23:40:03.509724-05	2025-10-12 23:41:01.481423-05	f	\N	2025-10-13 12:42:16.717855-05
ceafa433-6ef5-4445-b1cd-e77e9821addc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:07:34.918072-05	2025-10-12 22:08:34.910573-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:05:34.918072-05	2025-10-12 22:08:34.917515-05	2025-10-12 22:15:34.918072-05	f	\N	2025-10-13 12:42:16.717855-05
a34d498f-8735-4227-9a87-51e99fa7868c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:41:01.858525-05	2025-10-12 22:41:01.877414-05	\N	2025-10-13 03:41:00	00:15:00	2025-10-12 22:40:01.858525-05	2025-10-12 22:41:01.886034-05	2025-10-12 22:42:01.858525-05	f	\N	2025-10-13 12:42:16.717855-05
9e5fb64e-177e-44af-9bac-2ff7df708921	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:09:01.963068-05	2025-10-12 22:09:04.986261-05	\N	2025-10-13 03:09:00	00:15:00	2025-10-12 22:08:04.963068-05	2025-10-12 22:09:04.995643-05	2025-10-12 22:10:01.963068-05	f	\N	2025-10-13 12:42:16.717855-05
f7428f48-b8fc-4137-b754-c0996d99b77c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:42:01.884829-05	2025-10-12 22:42:01.915662-05	\N	2025-10-13 03:42:00	00:15:00	2025-10-12 22:41:01.884829-05	2025-10-12 22:42:01.923433-05	2025-10-12 22:43:01.884829-05	f	\N	2025-10-13 12:42:16.717855-05
e9cb742d-8a94-4d3a-8c35-94934e69f60c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:41:01.508156-05	2025-10-12 23:41:03.528306-05	\N	2025-10-13 04:41:00	00:15:00	2025-10-12 23:40:03.508156-05	2025-10-12 23:41:03.534347-05	2025-10-12 23:42:01.508156-05	f	\N	2025-10-13 12:42:16.717855-05
58af5efa-274b-4999-99e3-548f10106494	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:10:01.994485-05	2025-10-12 22:10:05.015206-05	\N	2025-10-13 03:10:00	00:15:00	2025-10-12 22:09:04.994485-05	2025-10-12 22:10:05.025493-05	2025-10-12 22:11:01.994485-05	f	\N	2025-10-13 12:42:16.717855-05
41d33bc1-1f1a-44a8-ba24-f54e8a7977e5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:42:34.986091-05	2025-10-12 22:42:34.995126-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:40:34.986091-05	2025-10-12 22:42:35.002901-05	2025-10-12 22:50:34.986091-05	f	\N	2025-10-13 12:42:16.717855-05
d684633f-495f-49ad-87e6-a543c5cf3b47	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:11:01.02395-05	2025-10-12 22:11:01.037457-05	\N	2025-10-13 03:11:00	00:15:00	2025-10-12 22:10:05.02395-05	2025-10-12 22:11:01.04481-05	2025-10-12 22:12:01.02395-05	f	\N	2025-10-13 12:42:16.717855-05
56fe9a59-ec3f-4327-b310-83925743ef3b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:10:34.919136-05	2025-10-12 22:11:34.91338-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:08:34.919136-05	2025-10-12 22:11:34.91948-05	2025-10-12 22:18:34.919136-05	f	\N	2025-10-13 12:42:16.717855-05
93c04ea8-d84e-4953-afdf-7a7bd65868e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:42:01.533076-05	2025-10-12 23:42:03.555911-05	\N	2025-10-13 04:42:00	00:15:00	2025-10-12 23:41:03.533076-05	2025-10-12 23:42:03.568094-05	2025-10-12 23:43:01.533076-05	f	\N	2025-10-13 12:42:16.717855-05
fabc7690-4ab7-4aa8-bd70-586319eb3eee	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:43:01.922344-05	2025-10-12 22:43:01.943099-05	\N	2025-10-13 03:43:00	00:15:00	2025-10-12 22:42:01.922344-05	2025-10-12 22:43:01.956041-05	2025-10-12 22:44:01.922344-05	f	\N	2025-10-13 12:42:16.717855-05
3a6b2523-f9ca-4fd6-9879-594717ab8290	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:13:01.071737-05	2025-10-12 22:13:01.091198-05	\N	2025-10-13 03:13:00	00:15:00	2025-10-12 22:12:01.071737-05	2025-10-12 22:13:01.099342-05	2025-10-12 22:14:01.071737-05	f	\N	2025-10-13 12:42:16.717855-05
5f02c9aa-f104-4482-910f-18769bddbcaa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:42:35.110848-05	2025-10-12 23:43:35.106902-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:40:35.110848-05	2025-10-12 23:43:35.11286-05	2025-10-12 23:50:35.110848-05	f	\N	2025-10-13 12:42:16.717855-05
1c518877-0d64-477d-9c44-5c740c5051ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:14:01.09815-05	2025-10-12 22:14:01.121765-05	\N	2025-10-13 03:14:00	00:15:00	2025-10-12 22:13:01.09815-05	2025-10-12 22:14:01.128539-05	2025-10-12 22:15:01.09815-05	f	\N	2025-10-13 12:42:16.717855-05
d2d5ddd4-f866-4385-bb0e-ebd455645f77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:44:01.954253-05	2025-10-12 22:44:01.973165-05	\N	2025-10-13 03:44:00	00:15:00	2025-10-12 22:43:01.954253-05	2025-10-12 22:44:01.982336-05	2025-10-12 22:45:01.954253-05	f	\N	2025-10-13 12:42:16.717855-05
03dc5e55-3aa4-4830-af5c-8f6fc02e1e95	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:13:34.920885-05	2025-10-12 22:14:34.919533-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:11:34.920885-05	2025-10-12 22:14:34.926152-05	2025-10-12 22:21:34.920885-05	f	\N	2025-10-13 12:42:16.717855-05
72a378f9-3af0-43b9-98d5-f2eb52b7c037	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:18:01.234839-05	2025-10-12 22:18:01.250238-05	\N	2025-10-13 03:18:00	00:15:00	2025-10-12 22:17:01.234839-05	2025-10-12 22:18:01.260334-05	2025-10-12 22:19:01.234839-05	f	\N	2025-10-13 12:42:16.717855-05
2af26514-beb3-41e4-8b88-0c6e321072bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:45:01.980971-05	2025-10-12 22:45:02.004412-05	\N	2025-10-13 03:45:00	00:15:00	2025-10-12 22:44:01.980971-05	2025-10-12 22:45:02.010476-05	2025-10-12 22:46:01.980971-05	f	\N	2025-10-13 12:42:16.717855-05
335d0bd5-0a02-4e10-a8f8-c67324dddd93	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:20:01.282551-05	2025-10-12 22:20:01.302254-05	\N	2025-10-13 03:20:00	00:15:00	2025-10-12 22:19:01.282551-05	2025-10-12 22:20:01.313357-05	2025-10-12 22:21:01.282551-05	f	\N	2025-10-13 12:42:16.717855-05
473a1592-04c5-42c0-950b-f292700c3282	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:44:35.004342-05	2025-10-12 22:45:35.001298-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:42:35.004342-05	2025-10-12 22:45:35.009221-05	2025-10-12 22:52:35.004342-05	f	\N	2025-10-13 12:42:16.717855-05
baa86f67-9017-4df1-b0e7-e09e613a5885	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:44:01.597833-05	2025-10-12 23:44:03.607394-05	\N	2025-10-13 04:44:00	00:15:00	2025-10-12 23:43:03.597833-05	2025-10-12 23:44:03.616755-05	2025-10-12 23:45:01.597833-05	f	\N	2025-10-13 12:42:16.717855-05
26edbb9d-feaa-4902-8e3b-47227a027fef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:23:01.367189-05	2025-10-12 22:23:01.388271-05	\N	2025-10-13 03:23:00	00:15:00	2025-10-12 22:22:01.367189-05	2025-10-12 22:23:01.395151-05	2025-10-12 22:24:01.367189-05	f	\N	2025-10-13 12:42:16.717855-05
97eebed3-1d62-4a2a-89fe-5c31a504163b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:46:01.009497-05	2025-10-12 22:46:02.032168-05	\N	2025-10-13 03:46:00	00:15:00	2025-10-12 22:45:02.009497-05	2025-10-12 22:46:02.041814-05	2025-10-12 22:47:01.009497-05	f	\N	2025-10-13 12:42:16.717855-05
92ca639e-fc55-476c-a8e4-84ffca88abf3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:24:01.394032-05	2025-10-12 22:24:01.413692-05	\N	2025-10-13 03:24:00	00:15:00	2025-10-12 22:23:01.394032-05	2025-10-12 22:24:01.423389-05	2025-10-12 22:25:01.394032-05	f	\N	2025-10-13 12:42:16.717855-05
e54da9ac-cf27-47e1-b4cd-ae30dc1f07ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:47:01.040362-05	2025-10-12 22:47:02.062928-05	\N	2025-10-13 03:47:00	00:15:00	2025-10-12 22:46:02.040362-05	2025-10-12 22:47:02.070864-05	2025-10-12 22:48:01.040362-05	f	\N	2025-10-13 12:42:16.717855-05
64de328e-6e54-4fd6-a910-d7c50fed6325	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:46:01.644819-05	2025-10-12 23:46:03.658791-05	\N	2025-10-13 04:46:00	00:15:00	2025-10-12 23:45:03.644819-05	2025-10-12 23:46:03.670223-05	2025-10-12 23:47:01.644819-05	f	\N	2025-10-13 12:42:16.717855-05
6794d3cf-e26c-4898-8889-37e3392c5359	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:50:01.117846-05	2025-10-12 22:50:02.136293-05	\N	2025-10-13 03:50:00	00:15:00	2025-10-12 22:49:02.117846-05	2025-10-12 22:50:02.145963-05	2025-10-12 22:51:01.117846-05	f	\N	2025-10-13 12:42:16.717855-05
79dfbb5b-edb0-4922-890b-41622f73f0ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:45:35.114114-05	2025-10-12 23:46:35.114738-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:43:35.114114-05	2025-10-12 23:46:35.123704-05	2025-10-12 23:53:35.114114-05	f	\N	2025-10-13 12:42:16.717855-05
6e4e53c8-fe2d-4c7f-8855-59949c6664fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:51:01.144742-05	2025-10-12 22:51:02.165199-05	\N	2025-10-13 03:51:00	00:15:00	2025-10-12 22:50:02.144742-05	2025-10-12 22:51:02.177739-05	2025-10-12 22:52:01.144742-05	f	\N	2025-10-13 12:42:16.717855-05
6f57f421-14cc-4132-8a7d-b0d4e459015c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:53:01.197961-05	2025-10-12 22:53:02.220249-05	\N	2025-10-13 03:53:00	00:15:00	2025-10-12 22:52:02.197961-05	2025-10-12 22:53:02.232909-05	2025-10-12 22:54:01.197961-05	f	\N	2025-10-13 12:42:16.717855-05
e600a403-fd5e-4649-9963-3962e0a9c97f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:53:35.016277-05	2025-10-12 22:54:35.014795-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:51:35.016277-05	2025-10-12 22:54:35.021947-05	2025-10-12 23:01:35.016277-05	f	\N	2025-10-13 12:42:16.717855-05
74cd973e-67df-413f-8127-042113aa7969	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:55:01.260651-05	2025-10-12 22:55:02.282104-05	\N	2025-10-13 03:55:00	00:15:00	2025-10-12 22:54:02.260651-05	2025-10-12 22:55:02.294466-05	2025-10-12 22:56:01.260651-05	f	\N	2025-10-13 12:42:16.717855-05
15962e85-40bc-4839-a951-8e9e7e024bae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:57:01.310906-05	2025-10-12 22:57:02.333205-05	\N	2025-10-13 03:57:00	00:15:00	2025-10-12 22:56:02.310906-05	2025-10-12 22:57:02.342827-05	2025-10-12 22:58:01.310906-05	f	\N	2025-10-13 12:42:16.717855-05
86bec8df-48fa-4d6d-bd92-e29775ebf3ee	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:58:01.341458-05	2025-10-12 22:58:02.357074-05	\N	2025-10-13 03:58:00	00:15:00	2025-10-12 22:57:02.341458-05	2025-10-12 22:58:02.367043-05	2025-10-12 22:59:01.341458-05	f	\N	2025-10-13 12:42:16.717855-05
b1f62411-65e8-48b1-a253-6e8e17917d31	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-12 16:17:01.922216-05	\N	\N	2025-10-12 21:17:00	00:15:00	2025-10-12 16:16:03.922216-05	\N	2025-10-12 16:18:01.922216-05	f	\N	2025-10-12 16:19:30.912434-05
fbbc5a00-6020-424a-81b0-759e91952f8c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:59:01.365758-05	2025-10-12 22:59:02.382072-05	\N	2025-10-13 03:59:00	00:15:00	2025-10-12 22:58:02.365758-05	2025-10-12 22:59:02.395156-05	2025-10-12 23:00:01.365758-05	f	\N	2025-10-13 12:42:16.717855-05
0d3d3ec7-d480-4cff-9fd2-06ad6a637632	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:02:01.446923-05	2025-10-12 23:02:02.460549-05	\N	2025-10-13 04:02:00	00:15:00	2025-10-12 23:01:02.446923-05	2025-10-12 23:02:02.470763-05	2025-10-12 23:03:01.446923-05	f	\N	2025-10-13 12:42:16.717855-05
8551947c-523e-4940-a581-5e6ab20f69ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:03:01.468922-05	2025-10-12 23:03:02.482451-05	\N	2025-10-13 04:03:00	00:15:00	2025-10-12 23:02:02.468922-05	2025-10-12 23:03:02.487937-05	2025-10-12 23:04:01.468922-05	f	\N	2025-10-13 12:42:16.717855-05
6f860e41-f49f-4f6d-be5b-bd123a23caa5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:05:01.517683-05	2025-10-12 23:05:02.542482-05	\N	2025-10-13 04:05:00	00:15:00	2025-10-12 23:04:02.517683-05	2025-10-12 23:05:02.550009-05	2025-10-12 23:06:01.517683-05	f	\N	2025-10-13 12:42:16.717855-05
d59dae20-5e9a-4c8f-a494-11f42ae503fb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:06:01.548844-05	2025-10-12 23:06:02.570777-05	\N	2025-10-13 04:06:00	00:15:00	2025-10-12 23:05:02.548844-05	2025-10-12 23:06:02.577464-05	2025-10-12 23:07:01.548844-05	f	\N	2025-10-13 12:42:16.717855-05
3b9ff017-a60c-42e7-866a-e9be54368e23	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:05:35.032849-05	2025-10-12 23:06:35.032615-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:03:35.032849-05	2025-10-12 23:06:35.040423-05	2025-10-12 23:13:35.032849-05	f	\N	2025-10-13 12:42:16.717855-05
ae329c27-db9b-46cb-9520-ff2789d5fbb3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:10:01.640204-05	2025-10-12 23:10:02.660436-05	\N	2025-10-13 04:10:00	00:15:00	2025-10-12 23:09:02.640204-05	2025-10-12 23:10:02.668004-05	2025-10-12 23:11:01.640204-05	f	\N	2025-10-13 12:42:16.717855-05
9e72fd3b-b31f-40bf-a62c-1cec92527f54	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:11:35.030592-05	2025-10-12 23:12:35.027175-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:09:35.030592-05	2025-10-12 23:12:35.034701-05	2025-10-12 23:19:35.030592-05	f	\N	2025-10-13 12:42:16.717855-05
55bbeeb8-e6b0-4ae5-98ca-afa4ef70543e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:35:01.692216-05	2025-10-12 22:35:01.712522-05	\N	2025-10-13 03:35:00	00:15:00	2025-10-12 22:34:01.692216-05	2025-10-12 22:35:01.720755-05	2025-10-12 22:36:01.692216-05	f	\N	2025-10-13 12:42:16.717855-05
3d7080c2-eee2-4143-bd92-a836fbc6294c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:06:01.881444-05	2025-10-12 22:06:04.902736-05	\N	2025-10-13 03:06:00	00:15:00	2025-10-12 22:05:04.881444-05	2025-10-12 22:06:04.913992-05	2025-10-12 22:07:01.881444-05	f	\N	2025-10-13 12:42:16.717855-05
029d81cd-7208-4d63-bcd9-a776d640849a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:26:35.051302-05	2025-10-12 23:27:35.045411-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:24:35.051302-05	2025-10-12 23:27:35.056951-05	2025-10-12 23:34:35.051302-05	f	\N	2025-10-13 12:42:16.717855-05
5dc811b7-65dd-4fa3-af76-685de19c2f39	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:07:01.912416-05	2025-10-12 22:07:04.931611-05	\N	2025-10-13 03:07:00	00:15:00	2025-10-12 22:06:04.912416-05	2025-10-12 22:07:04.942309-05	2025-10-12 22:08:01.912416-05	f	\N	2025-10-13 12:42:16.717855-05
8d2ee88e-4d27-488e-a0d3-9ffe37dc458b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:36:34.974338-05	2025-10-12 22:37:34.970852-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:34:34.974338-05	2025-10-12 22:37:34.978273-05	2025-10-12 22:44:34.974338-05	f	\N	2025-10-13 12:42:16.717855-05
9c5ba19e-d854-4965-8825-e8842f6f0c1b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:12:01.043651-05	2025-10-12 22:12:01.062971-05	\N	2025-10-13 03:12:00	00:15:00	2025-10-12 22:11:01.043651-05	2025-10-12 22:12:01.07329-05	2025-10-12 22:13:01.043651-05	f	\N	2025-10-13 12:42:16.717855-05
89859245-5a50-43f5-b293-417d7b2ffbdb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:49:01.097586-05	2025-10-12 22:49:02.110504-05	\N	2025-10-13 03:49:00	00:15:00	2025-10-12 22:48:02.097586-05	2025-10-12 22:49:02.119342-05	2025-10-12 22:50:01.097586-05	f	\N	2025-10-13 12:42:16.717855-05
5af758ff-1984-4169-b503-4ffc3b84c637	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:43:01.566333-05	2025-10-12 23:43:03.587046-05	\N	2025-10-13 04:43:00	00:15:00	2025-10-12 23:42:03.566333-05	2025-10-12 23:43:03.599366-05	2025-10-12 23:44:01.566333-05	f	\N	2025-10-13 12:42:16.717855-05
a0bdf936-54df-4c10-a9b8-22abecd392a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:15:01.127153-05	2025-10-12 22:15:01.171036-05	\N	2025-10-13 03:15:00	00:15:00	2025-10-12 22:14:01.127153-05	2025-10-12 22:15:01.180817-05	2025-10-12 22:16:01.127153-05	f	\N	2025-10-13 12:42:16.717855-05
2665c6d3-c814-4904-b326-af97c8841540	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:11:01.6667-05	2025-10-12 23:11:02.683328-05	\N	2025-10-13 04:11:00	00:15:00	2025-10-12 23:10:02.6667-05	2025-10-12 23:11:02.693428-05	2025-10-12 23:12:01.6667-05	f	\N	2025-10-13 12:42:16.717855-05
35dba5fa-27d8-4be4-ad5c-4ab735337bb1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:16:01.17933-05	2025-10-12 22:16:01.204182-05	\N	2025-10-13 03:16:00	00:15:00	2025-10-12 22:15:01.17933-05	2025-10-12 22:16:01.213934-05	2025-10-12 22:17:01.17933-05	f	\N	2025-10-13 12:42:16.717855-05
7f7dd6e6-e7e4-44b9-99e0-9ed3f40c628f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:16:34.927712-05	2025-10-12 22:16:34.946709-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:14:34.927712-05	2025-10-12 22:16:34.953354-05	2025-10-12 22:24:34.927712-05	f	\N	2025-10-13 12:42:16.717855-05
a6f94d6e-6c46-4efb-8dd6-954356487db1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:14:01.738932-05	2025-10-12 23:14:02.75593-05	\N	2025-10-13 04:14:00	00:15:00	2025-10-12 23:13:02.738932-05	2025-10-12 23:14:02.761241-05	2025-10-12 23:15:01.738932-05	f	\N	2025-10-13 12:42:16.717855-05
5ae8fc41-23dd-4054-a5ac-7bc340c75e1a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:17:01.212603-05	2025-10-12 22:17:01.22579-05	\N	2025-10-13 03:17:00	00:15:00	2025-10-12 22:16:01.212603-05	2025-10-12 22:17:01.236383-05	2025-10-12 22:18:01.212603-05	f	\N	2025-10-13 12:42:16.717855-05
d39fe3b3-d2d3-463a-82b1-658bee9fdac4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:47:01.668593-05	2025-10-12 23:47:03.689677-05	\N	2025-10-13 04:47:00	00:15:00	2025-10-12 23:46:03.668593-05	2025-10-12 23:47:03.70068-05	2025-10-12 23:48:01.668593-05	f	\N	2025-10-13 12:42:16.717855-05
fc536cc2-98b9-435c-a8cd-ca8e8793314f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:19:01.258812-05	2025-10-12 22:19:01.276474-05	\N	2025-10-13 03:19:00	00:15:00	2025-10-12 22:18:01.258812-05	2025-10-12 22:19:01.283756-05	2025-10-12 22:20:01.258812-05	f	\N	2025-10-13 12:42:16.717855-05
5771282d-12de-49fb-a1b7-d8075a3f6551	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:14:35.036196-05	2025-10-12 23:15:35.02938-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:12:35.036196-05	2025-10-12 23:15:35.038217-05	2025-10-12 23:22:35.036196-05	f	\N	2025-10-13 12:42:16.717855-05
198ca906-f0f2-4fd8-9697-8bc5a62ab4ce	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:18:34.955214-05	2025-10-12 22:19:34.951021-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:16:34.955214-05	2025-10-12 22:19:34.958045-05	2025-10-12 22:26:34.955214-05	f	\N	2025-10-13 12:42:16.717855-05
ca513cbc-b7ca-43bd-b57e-d3f58beac038	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:48:01.699517-05	2025-10-12 23:48:03.720011-05	\N	2025-10-13 04:48:00	00:15:00	2025-10-12 23:47:03.699517-05	2025-10-12 23:48:03.730212-05	2025-10-12 23:49:01.699517-05	f	\N	2025-10-13 12:42:16.717855-05
2f15a38a-e247-403d-a3c4-49697c516ef0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:16:01.789544-05	2025-10-12 23:16:02.807089-05	\N	2025-10-13 04:16:00	00:15:00	2025-10-12 23:15:02.789544-05	2025-10-12 23:16:02.816039-05	2025-10-12 23:17:01.789544-05	f	\N	2025-10-13 12:42:16.717855-05
dc70fa48-31e0-41b2-a13c-45356dbf0ec7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:48:35.125576-05	2025-10-12 23:49:35.119213-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:46:35.125576-05	2025-10-12 23:49:35.125835-05	2025-10-12 23:56:35.125576-05	f	\N	2025-10-13 12:42:16.717855-05
61718190-28d3-46b2-bb53-1c5834fa7c29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:21:01.311732-05	2025-10-12 22:21:01.331914-05	\N	2025-10-13 03:21:00	00:15:00	2025-10-12 22:20:01.311732-05	2025-10-12 22:21:01.340874-05	2025-10-12 22:22:01.311732-05	f	\N	2025-10-13 12:42:16.717855-05
01360f61-265a-4e2d-ac97-efa7d6a48b8a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:22:01.339695-05	2025-10-12 22:22:01.358601-05	\N	2025-10-13 03:22:00	00:15:00	2025-10-12 22:21:01.339695-05	2025-10-12 22:22:01.368699-05	2025-10-12 22:23:01.339695-05	f	\N	2025-10-13 12:42:16.717855-05
ca8a5152-091e-4665-9305-9c09ec5de91c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:17:35.040256-05	2025-10-12 23:18:35.033581-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:15:35.040256-05	2025-10-12 23:18:35.041531-05	2025-10-12 23:25:35.040256-05	f	\N	2025-10-13 12:42:16.717855-05
8e7f04d0-1a03-400f-8b62-16d96917e1e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:21:34.95953-05	2025-10-12 22:22:34.955039-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:19:34.95953-05	2025-10-12 22:22:34.962155-05	2025-10-12 22:29:34.95953-05	f	\N	2025-10-13 12:42:16.717855-05
f1fd84b9-933e-4522-b62a-d49a4033bdf1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:19:01.873874-05	2025-10-12 23:19:02.890459-05	\N	2025-10-13 04:19:00	00:15:00	2025-10-12 23:18:02.873874-05	2025-10-12 23:19:02.901037-05	2025-10-12 23:20:01.873874-05	f	\N	2025-10-13 12:42:16.717855-05
39f02b51-afc6-4c16-86e7-50f7ad3e8268	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:25:01.421722-05	2025-10-12 22:25:01.442637-05	\N	2025-10-13 03:25:00	00:15:00	2025-10-12 22:24:01.421722-05	2025-10-12 22:25:01.45294-05	2025-10-12 22:26:01.421722-05	f	\N	2025-10-13 12:42:16.717855-05
75193498-b265-4161-801c-02d6ec44795b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:52:01.8025-05	2025-10-12 23:52:03.823158-05	\N	2025-10-13 04:52:00	00:15:00	2025-10-12 23:51:03.8025-05	2025-10-12 23:52:03.830691-05	2025-10-12 23:53:01.8025-05	f	\N	2025-10-13 12:42:16.717855-05
b7f7451b-8691-472d-97b6-323ce48823f3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:24:34.963857-05	2025-10-12 22:25:34.959787-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:22:34.963857-05	2025-10-12 22:25:34.968903-05	2025-10-12 22:32:34.963857-05	f	\N	2025-10-13 12:42:16.717855-05
72b8e674-81be-47c3-9420-87ee5ed4fbec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:20:01.899316-05	2025-10-12 23:20:02.918124-05	\N	2025-10-13 04:20:00	00:15:00	2025-10-12 23:19:02.899316-05	2025-10-12 23:20:02.929436-05	2025-10-12 23:21:01.899316-05	f	\N	2025-10-13 12:42:16.717855-05
e7970bbd-af18-436c-a2b8-ee951ec7cf82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:26:01.451226-05	2025-10-12 22:26:01.470325-05	\N	2025-10-13 03:26:00	00:15:00	2025-10-12 22:25:01.451226-05	2025-10-12 22:26:01.48162-05	2025-10-12 22:27:01.451226-05	f	\N	2025-10-13 12:42:16.717855-05
7cae0b2e-1c4d-4531-b54c-409b3cc5c43f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:21:01.927652-05	2025-10-12 23:21:02.948136-05	\N	2025-10-13 04:21:00	00:15:00	2025-10-12 23:20:02.927652-05	2025-10-12 23:21:02.959594-05	2025-10-12 23:22:01.927652-05	f	\N	2025-10-13 12:42:16.717855-05
3153399f-de41-4203-9083-6ef8798f95c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:27:01.480063-05	2025-10-12 22:27:01.496484-05	\N	2025-10-13 03:27:00	00:15:00	2025-10-12 22:26:01.480063-05	2025-10-12 22:27:01.504236-05	2025-10-12 22:28:01.480063-05	f	\N	2025-10-13 12:42:16.717855-05
5c433bd5-f499-43c9-ad37-82b1cd7de035	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:20:35.043225-05	2025-10-12 23:21:35.039597-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:18:35.043225-05	2025-10-12 23:21:35.051567-05	2025-10-12 23:28:35.043225-05	f	\N	2025-10-13 12:42:16.717855-05
9186a23c-a6f3-42cb-8b31-7a98b9c99da8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:28:01.503142-05	2025-10-12 22:28:01.528342-05	\N	2025-10-13 03:28:00	00:15:00	2025-10-12 22:27:01.503142-05	2025-10-12 22:28:01.536526-05	2025-10-12 22:29:01.503142-05	f	\N	2025-10-13 12:42:16.717855-05
31a5e2ff-e867-4137-aa04-6982b535f3ee	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:27:34.970726-05	2025-10-12 22:28:34.964513-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:25:34.970726-05	2025-10-12 22:28:34.972192-05	2025-10-12 22:35:34.970726-05	f	\N	2025-10-13 12:42:16.717855-05
31d70dce-a84f-46cc-8be3-67d47d485ef1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:18:11.975314-05	2025-10-12 08:18:15.966243-05	\N	2025-10-12 13:18:00	00:15:00	2025-10-12 08:18:11.975314-05	2025-10-12 08:18:15.971821-05	2025-10-12 08:19:11.975314-05	f	\N	2025-10-12 20:20:34.806288-05
b56d0c2a-1387-4919-b346-d5a56e7481d5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:19:01.971304-05	2025-10-12 08:19:03.978731-05	\N	2025-10-12 13:19:00	00:15:00	2025-10-12 08:18:15.971304-05	2025-10-12 08:19:03.990653-05	2025-10-12 08:20:01.971304-05	f	\N	2025-10-12 20:20:34.806288-05
51e47e12-9523-4a3e-b26f-254c24687a29	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:18:11.958115-05	2025-10-12 08:18:11.960944-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:18:11.958115-05	2025-10-12 08:18:11.969805-05	2025-10-12 08:26:11.958115-05	f	\N	2025-10-12 20:20:34.806288-05
6d973698-7f60-4fb5-8dcc-6309180c31ec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:20:01.989282-05	2025-10-12 08:20:03.991585-05	\N	2025-10-12 13:20:00	00:15:00	2025-10-12 08:19:03.989282-05	2025-10-12 08:20:04.00362-05	2025-10-12 08:21:01.989282-05	f	\N	2025-10-12 20:20:34.806288-05
431aaae4-ccaa-4dd7-b753-e7c8d9b3a0d1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:25:01.011865-05	2025-10-12 08:25:01.012582-05	\N	2025-10-12 13:25:00	00:15:00	2025-10-12 08:24:05.011865-05	2025-10-12 08:25:01.025604-05	2025-10-12 08:26:01.011865-05	f	\N	2025-10-12 20:26:34.81855-05
270b85cb-e4f9-4b52-9da7-3d57cbc7ffb7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:26:01.024624-05	2025-10-12 08:26:01.031072-05	\N	2025-10-12 13:26:00	00:15:00	2025-10-12 08:25:01.024624-05	2025-10-12 08:26:01.045893-05	2025-10-12 08:27:01.024624-05	f	\N	2025-10-12 20:26:34.81855-05
cc132a78-4ebe-4e49-856c-0f728c42827d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:24:01.009333-05	2025-10-12 08:24:05.002173-05	\N	2025-10-12 13:24:00	00:15:00	2025-10-12 08:23:05.009333-05	2025-10-12 08:24:05.012875-05	2025-10-12 08:25:01.009333-05	f	\N	2025-10-12 20:26:34.81855-05
c7680833-fae5-4591-8d1a-3f2640b0dc9c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:24:32.984232-05	2025-10-12 08:25:32.975873-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:22:32.984232-05	2025-10-12 08:25:32.981469-05	2025-10-12 08:32:32.984232-05	f	\N	2025-10-12 20:26:34.81855-05
0f3e9323-8805-4064-8fa2-0e73b43d30b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:23:01.983941-05	2025-10-12 23:23:02.996613-05	\N	2025-10-13 04:23:00	00:15:00	2025-10-12 23:22:02.983941-05	2025-10-12 23:23:03.005481-05	2025-10-12 23:24:01.983941-05	f	\N	2025-10-13 12:42:16.717855-05
4d112fed-2054-43b1-a7d4-c1e661b5d886	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:29:01.535311-05	2025-10-12 22:29:01.554939-05	\N	2025-10-13 03:29:00	00:15:00	2025-10-12 22:28:01.535311-05	2025-10-12 22:29:01.564085-05	2025-10-12 22:30:01.535311-05	f	\N	2025-10-13 12:42:16.717855-05
66c8bbe4-5d7c-41e0-9c82-3ed988455c4b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:24:01.00428-05	2025-10-12 23:24:03.027169-05	\N	2025-10-13 04:24:00	00:15:00	2025-10-12 23:23:03.00428-05	2025-10-12 23:24:03.034869-05	2025-10-12 23:25:01.00428-05	f	\N	2025-10-13 12:42:16.717855-05
e119ccd5-1b9f-4f4c-9871-484ddb58a4ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:30:01.562684-05	2025-10-12 22:30:01.583282-05	\N	2025-10-13 03:30:00	00:15:00	2025-10-12 22:29:01.562684-05	2025-10-12 22:30:01.594571-05	2025-10-12 22:31:01.562684-05	f	\N	2025-10-13 12:42:16.717855-05
b0c3d357-5efc-4ed8-88db-77edac7dd09f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:31:01.592931-05	2025-10-12 22:31:01.612428-05	\N	2025-10-13 03:31:00	00:15:00	2025-10-12 22:30:01.592931-05	2025-10-12 22:31:01.616185-05	2025-10-12 22:32:01.592931-05	f	\N	2025-10-13 12:42:16.717855-05
4c21d715-ad47-4b8d-99a2-79af4ad670a4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:30:34.973821-05	2025-10-12 22:31:34.9662-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:28:34.973821-05	2025-10-12 22:31:34.975103-05	2025-10-12 22:38:34.973821-05	f	\N	2025-10-13 12:42:16.717855-05
60a720e5-38f2-49ef-a736-d5ba4f279180	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:32:01.615726-05	2025-10-12 22:32:01.637505-05	\N	2025-10-13 03:32:00	00:15:00	2025-10-12 22:31:01.615726-05	2025-10-12 22:32:01.645558-05	2025-10-12 22:33:01.615726-05	f	\N	2025-10-13 12:42:16.717855-05
bd19e8ee-2ef5-4a77-a14f-5fd47ed7d284	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:33:01.644704-05	2025-10-12 22:33:01.662549-05	\N	2025-10-13 03:33:00	00:15:00	2025-10-12 22:32:01.644704-05	2025-10-12 22:33:01.674452-05	2025-10-12 22:34:01.644704-05	f	\N	2025-10-13 12:42:16.717855-05
c809ac4d-7f33-404b-ace6-fa2c7badd213	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:34:01.672928-05	2025-10-12 22:34:01.687107-05	\N	2025-10-13 03:34:00	00:15:00	2025-10-12 22:33:01.672928-05	2025-10-12 22:34:01.692992-05	2025-10-12 22:35:01.672928-05	f	\N	2025-10-13 12:42:16.717855-05
2ac8cb37-c73f-447d-be60-74e549f2a1c8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:33:34.976867-05	2025-10-12 22:34:34.965603-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:31:34.976867-05	2025-10-12 22:34:34.972955-05	2025-10-12 22:41:34.976867-05	f	\N	2025-10-13 12:42:16.717855-05
0bbed312-3d68-42f2-bdfa-a7bf3f90527c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:13:01.306307-05	2025-10-13 03:13:01.325215-05	\N	2025-10-13 08:13:00	00:15:00	2025-10-13 03:12:01.306307-05	2025-10-13 03:13:01.331908-05	2025-10-13 03:14:01.306307-05	f	\N	2025-10-13 15:15:44.300693-05
5d9c0340-b864-473e-ad71-909a0c398de2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:12:35.432744-05	2025-10-13 03:13:35.429879-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:10:35.432744-05	2025-10-13 03:13:35.436158-05	2025-10-13 03:20:35.432744-05	f	\N	2025-10-13 15:15:44.300693-05
657ccc1a-a831-426a-9949-4b57a232eda1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:14:01.330837-05	2025-10-13 03:14:01.351747-05	\N	2025-10-13 08:14:00	00:15:00	2025-10-13 03:13:01.330837-05	2025-10-13 03:14:01.360006-05	2025-10-13 03:15:01.330837-05	f	\N	2025-10-13 15:15:44.300693-05
c9297dd0-b1c6-4193-91f6-1342cff32dc7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:15:01.358412-05	2025-10-13 03:15:01.380751-05	\N	2025-10-13 08:15:00	00:15:00	2025-10-13 03:14:01.358412-05	2025-10-13 03:15:01.388259-05	2025-10-13 03:16:01.358412-05	f	\N	2025-10-13 15:15:44.300693-05
9b8a71df-59b7-4f1b-b481-7e23bf6f8026	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:16:01.387013-05	2025-10-13 03:16:01.403821-05	\N	2025-10-13 08:16:00	00:15:00	2025-10-13 03:15:01.387013-05	2025-10-13 03:16:01.415196-05	2025-10-13 03:17:01.387013-05	f	\N	2025-10-13 15:18:44.301375-05
570fba1c-c946-4395-bb2a-ae0c0e2dd8d1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:15:35.437529-05	2025-10-13 03:16:35.436115-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:13:35.437529-05	2025-10-13 03:16:35.445098-05	2025-10-13 03:23:35.437529-05	f	\N	2025-10-13 15:18:44.301375-05
eb851a55-f7a8-433c-a5ce-559d5ae0a7c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:17:01.413438-05	2025-10-13 03:17:01.431845-05	\N	2025-10-13 08:17:00	00:15:00	2025-10-13 03:16:01.413438-05	2025-10-13 03:17:01.442914-05	2025-10-13 03:18:01.413438-05	f	\N	2025-10-13 15:18:44.301375-05
dd9214fb-ff06-4197-8a48-a9b9a03791ed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:18:01.44113-05	2025-10-13 03:18:01.45843-05	\N	2025-10-13 08:18:00	00:15:00	2025-10-13 03:17:01.44113-05	2025-10-13 03:18:01.469025-05	2025-10-13 03:19:01.44113-05	f	\N	2025-10-13 15:18:44.301375-05
fe2496ab-1900-4afd-8d49-70d55f18738a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:19:01.467287-05	2025-10-13 03:19:01.488632-05	\N	2025-10-13 08:19:00	00:15:00	2025-10-13 03:18:01.467287-05	2025-10-13 03:19:01.495727-05	2025-10-13 03:20:01.467287-05	f	\N	2025-10-13 15:21:44.304294-05
c5fbfa8b-c016-4848-9544-15b602685b4b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:18:35.447123-05	2025-10-13 03:19:35.440655-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:16:35.447123-05	2025-10-13 03:19:35.446668-05	2025-10-13 03:26:35.447123-05	f	\N	2025-10-13 15:21:44.304294-05
e510b803-d138-4f03-9f17-5bcda81b1c0a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:20:01.494558-05	2025-10-13 03:20:01.515616-05	\N	2025-10-13 08:20:00	00:15:00	2025-10-13 03:19:01.494558-05	2025-10-13 03:20:01.524001-05	2025-10-13 03:21:01.494558-05	f	\N	2025-10-13 15:21:44.304294-05
dc520678-511d-422e-859e-552f1dc6a038	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:21:01.522744-05	2025-10-13 03:21:01.544868-05	\N	2025-10-13 08:21:00	00:15:00	2025-10-13 03:20:01.522744-05	2025-10-13 03:21:01.556082-05	2025-10-13 03:22:01.522744-05	f	\N	2025-10-13 15:21:44.304294-05
9fd70a31-a62d-4c8a-a04f-e81b4e8cd04c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:23:01.033964-05	2025-10-12 08:23:04.989794-05	\N	2025-10-12 13:23:00	00:15:00	2025-10-12 08:22:04.033964-05	2025-10-12 08:23:05.010751-05	2025-10-12 08:24:01.033964-05	f	\N	2025-10-12 20:23:34.812013-05
331d39e1-c6a5-4ccb-96b2-a9e49440bc3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:21:01.001795-05	2025-10-12 08:21:04.007544-05	\N	2025-10-12 13:21:00	00:15:00	2025-10-12 08:20:04.001795-05	2025-10-12 08:21:04.011417-05	2025-10-12 08:22:01.001795-05	f	\N	2025-10-12 20:23:34.812013-05
5ea8e40c-0e3c-4ebf-bf8b-414874e1a156	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:22:01.010906-05	2025-10-12 08:22:04.020809-05	\N	2025-10-12 13:22:00	00:15:00	2025-10-12 08:21:04.010906-05	2025-10-12 08:22:04.03564-05	2025-10-12 08:23:01.010906-05	f	\N	2025-10-12 20:23:34.812013-05
d8772090-b897-4bab-86a0-1b55defd0d4e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:22:32.973217-05	2025-10-12 08:22:32.97569-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:22:32.973217-05	2025-10-12 08:22:32.982949-05	2025-10-12 08:30:32.973217-05	f	\N	2025-10-12 20:23:34.812013-05
37a8682c-2c70-4711-b9c4-d5495611c1af	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:20:11.971142-05	2025-10-12 08:21:11.961567-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:18:11.971142-05	2025-10-12 08:21:11.966569-05	2025-10-12 08:28:11.971142-05	f	\N	2025-10-12 20:23:34.812013-05
cd8083d1-c36a-4508-9380-bec8c522c20a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:27:01.04465-05	2025-10-12 08:27:01.04926-05	\N	2025-10-12 13:27:00	00:15:00	2025-10-12 08:26:01.04465-05	2025-10-12 08:27:01.06507-05	2025-10-12 08:28:01.04465-05	f	\N	2025-10-12 20:29:34.82382-05
ee820493-5185-4f2e-9673-b68e707392c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:28:01.063333-05	2025-10-12 08:28:05.06295-05	\N	2025-10-12 13:28:00	00:15:00	2025-10-12 08:27:01.063333-05	2025-10-12 08:28:05.067664-05	2025-10-12 08:29:01.063333-05	f	\N	2025-10-12 20:29:34.82382-05
dbb58d2d-6da3-40af-ba51-64d145017000	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:27:32.983145-05	2025-10-12 08:28:32.977083-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:25:32.983145-05	2025-10-12 08:28:32.983814-05	2025-10-12 08:35:32.983145-05	f	\N	2025-10-12 20:29:34.82382-05
fe8f166b-05b6-4b11-8486-f3886c3c951c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:29:01.067111-05	2025-10-12 08:29:01.072797-05	\N	2025-10-12 13:29:00	00:15:00	2025-10-12 08:28:05.067111-05	2025-10-12 08:29:01.079274-05	2025-10-12 08:30:01.067111-05	f	\N	2025-10-12 20:29:34.82382-05
dfacc70b-a120-4c5c-ad4c-8db764c5b8a0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:30:23.365111-05	2025-10-12 08:30:23.366709-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:30:23.365111-05	2025-10-12 08:30:23.370997-05	2025-10-12 08:38:23.365111-05	f	\N	2025-10-12 20:32:34.826353-05
b4757284-4a88-4cf8-bde0-947eeb57ead8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:32:01.257543-05	2025-10-12 08:32:01.262586-05	\N	2025-10-12 13:32:00	00:15:00	2025-10-12 08:31:01.257543-05	2025-10-12 08:32:01.285244-05	2025-10-12 08:33:01.257543-05	f	\N	2025-10-12 20:32:34.826353-05
1bbbf02f-4112-416f-9b87-46195280ded7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:30:01.078231-05	2025-10-12 08:30:01.089478-05	\N	2025-10-12 13:30:00	00:15:00	2025-10-12 08:29:01.078231-05	2025-10-12 08:30:01.10492-05	2025-10-12 08:31:01.078231-05	f	\N	2025-10-12 20:32:34.826353-05
d05de007-ccd2-4e4d-a962-e6d395b822f4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:30:37.237919-05	2025-10-12 08:30:37.24017-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:30:37.237919-05	2025-10-12 08:30:37.247038-05	2025-10-12 08:38:37.237919-05	f	\N	2025-10-12 20:32:34.826353-05
248de2ba-3b47-4380-b5f2-fe8f28388727	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:31:01.103391-05	2025-10-12 08:31:01.249349-05	\N	2025-10-12 13:31:00	00:15:00	2025-10-12 08:30:01.103391-05	2025-10-12 08:31:01.258882-05	2025-10-12 08:32:01.103391-05	f	\N	2025-10-12 20:32:34.826353-05
72db3ec4-9597-4a89-bea2-22340cc1259e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:37:01.343016-05	2025-10-12 08:37:01.34708-05	\N	2025-10-12 13:37:00	00:15:00	2025-10-12 08:36:05.343016-05	2025-10-12 08:37:01.363334-05	2025-10-12 08:38:01.343016-05	f	\N	2025-10-12 20:38:34.840494-05
bf7ffdfb-bb0c-44cc-85cc-52b17de2a14c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:38:01.361909-05	2025-10-12 08:38:04.352066-05	\N	2025-10-12 13:38:00	00:15:00	2025-10-12 08:37:01.361909-05	2025-10-12 08:38:04.368487-05	2025-10-12 08:39:01.361909-05	f	\N	2025-10-12 20:38:34.840494-05
1dc26dd3-b01c-4af6-97cf-31e850f25279	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:36:01.331358-05	2025-10-12 08:36:05.330539-05	\N	2025-10-12 13:36:00	00:15:00	2025-10-12 08:35:01.331358-05	2025-10-12 08:36:05.344363-05	2025-10-12 08:37:01.331358-05	f	\N	2025-10-12 20:38:34.840494-05
2da505aa-47de-47c2-b6d8-01949cad30c1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:35:37.253738-05	2025-10-12 08:36:37.240879-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:33:37.253738-05	2025-10-12 08:36:37.251901-05	2025-10-12 08:43:37.253738-05	f	\N	2025-10-12 20:38:34.840494-05
df844516-ee9a-4208-bf75-83f732da06a9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:38:00.345382-05	2025-10-12 08:38:00.346822-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:38:00.345382-05	2025-10-12 08:38:00.353617-05	2025-10-12 08:46:00.345382-05	f	\N	2025-10-12 20:38:34.840494-05
876513db-c996-43b3-9df1-fb37db348016	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:38:07.938792-05	2025-10-12 08:38:07.940456-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:38:07.938792-05	2025-10-12 08:38:07.945644-05	2025-10-12 08:46:07.938792-05	f	\N	2025-10-12 20:38:34.840494-05
a9a2e7c9-7180-4189-afad-9b14d03b20bd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:43:01.232363-05	2025-10-13 00:43:05.195447-05	\N	2025-10-13 05:43:00	00:15:00	2025-10-13 00:42:01.232363-05	2025-10-13 00:43:05.204841-05	2025-10-13 00:44:01.232363-05	f	\N	2025-10-13 12:45:16.721483-05
47c51905-3ae0-4de8-8c90-ab19fb4c2e55	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:43:35.242969-05	2025-10-13 00:44:35.178508-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:41:35.242969-05	2025-10-13 00:44:35.183456-05	2025-10-13 00:51:35.242969-05	f	\N	2025-10-13 12:45:16.721483-05
6cb64ed0-f416-401a-8a11-4eb0862e57bb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:44:01.203389-05	2025-10-13 00:44:01.222052-05	\N	2025-10-13 05:44:00	00:15:00	2025-10-13 00:43:05.203389-05	2025-10-13 00:44:01.232398-05	2025-10-13 00:45:01.203389-05	f	\N	2025-10-13 12:45:16.721483-05
1087d0a0-3f83-4996-9998-a49e30468cfa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:45:01.231281-05	2025-10-13 00:45:01.251049-05	\N	2025-10-13 05:45:00	00:15:00	2025-10-13 00:44:01.231281-05	2025-10-13 00:45:01.257204-05	2025-10-13 00:46:01.231281-05	f	\N	2025-10-13 12:45:16.721483-05
2e6209dd-a2e2-427e-9d16-fe9da8ca0267	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:23:01.574036-05	2025-10-13 03:23:01.590926-05	\N	2025-10-13 08:23:00	00:15:00	2025-10-13 03:22:01.574036-05	2025-10-13 03:23:01.598539-05	2025-10-13 03:24:01.574036-05	f	\N	2025-10-13 15:24:44.307634-05
390b98d7-373f-4518-a35d-9ad0c562d3ec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:22:01.554476-05	2025-10-13 03:22:01.567815-05	\N	2025-10-13 08:22:00	00:15:00	2025-10-13 03:21:01.554476-05	2025-10-13 03:22:01.575164-05	2025-10-13 03:23:01.554476-05	f	\N	2025-10-13 15:24:44.307634-05
4ff32918-57ea-4cf8-b7b6-299e4bdab884	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:21:35.448037-05	2025-10-13 03:22:35.446594-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:19:35.448037-05	2025-10-13 03:22:35.452381-05	2025-10-13 03:29:35.448037-05	f	\N	2025-10-13 15:24:44.307634-05
3256eada-955e-43f9-9d12-46491563fca8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:24:01.597336-05	2025-10-13 03:24:01.625073-05	\N	2025-10-13 08:24:00	00:15:00	2025-10-13 03:23:01.597336-05	2025-10-13 03:24:01.631448-05	2025-10-13 03:25:01.597336-05	f	\N	2025-10-13 15:24:44.307634-05
9e937d46-73bc-4a8d-bfa2-7b6368522882	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:34:01.29225-05	2025-10-12 08:34:01.294057-05	\N	2025-10-12 13:34:00	00:15:00	2025-10-12 08:33:05.29225-05	2025-10-12 08:34:01.308548-05	2025-10-12 08:35:01.29225-05	f	\N	2025-10-12 20:35:34.836405-05
8a6ba14b-3702-4498-bb21-15ea0a02b792	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:33:01.283383-05	2025-10-12 08:33:05.277307-05	\N	2025-10-12 13:33:00	00:15:00	2025-10-12 08:32:01.283383-05	2025-10-12 08:33:05.293859-05	2025-10-12 08:34:01.283383-05	f	\N	2025-10-12 20:35:34.836405-05
e266fb8c-3e0b-4a36-92b1-040dfe4a77d4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:32:37.248666-05	2025-10-12 08:33:37.23931-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:30:37.248666-05	2025-10-12 08:33:37.251325-05	2025-10-12 08:40:37.248666-05	f	\N	2025-10-12 20:35:34.836405-05
ee6df55d-b6f2-4f28-b45d-ec47fd31656f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:35:01.30765-05	2025-10-12 08:35:01.312865-05	\N	2025-10-12 13:35:00	00:15:00	2025-10-12 08:34:01.30765-05	2025-10-12 08:35:01.332787-05	2025-10-12 08:36:01.30765-05	f	\N	2025-10-12 20:35:34.836405-05
54b1e64b-89f8-4509-9c86-63e6420f9a0a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:46:01.256261-05	2025-10-13 00:46:01.277605-05	\N	2025-10-13 05:46:00	00:15:00	2025-10-13 00:45:01.256261-05	2025-10-13 00:46:01.288799-05	2025-10-13 00:47:01.256261-05	f	\N	2025-10-13 12:48:16.721504-05
3d7dcbd0-6e44-48ed-bb12-ba3719a60649	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:47:01.287122-05	2025-10-13 00:47:01.307141-05	\N	2025-10-13 05:47:00	00:15:00	2025-10-13 00:46:01.287122-05	2025-10-13 00:47:01.314084-05	2025-10-13 00:48:01.287122-05	f	\N	2025-10-13 12:48:16.721504-05
143e3dc2-2044-4659-80bc-5b3c7aa51ca2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:46:35.184382-05	2025-10-13 00:47:35.18125-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:44:35.184382-05	2025-10-13 00:47:35.187457-05	2025-10-13 00:54:35.184382-05	f	\N	2025-10-13 12:48:16.721504-05
4264693b-9bb2-440c-a813-c7e176f8a3aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:48:01.313257-05	2025-10-13 00:48:01.336604-05	\N	2025-10-13 05:48:00	00:15:00	2025-10-13 00:47:01.313257-05	2025-10-13 00:48:01.343881-05	2025-10-13 00:49:01.313257-05	f	\N	2025-10-13 12:48:16.721504-05
b8700080-ba36-4909-b525-ed0cf3af256b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:25:01.630489-05	2025-10-13 03:25:01.653959-05	\N	2025-10-13 08:25:00	00:15:00	2025-10-13 03:24:01.630489-05	2025-10-13 03:25:01.665108-05	2025-10-13 03:26:01.630489-05	f	\N	2025-10-13 15:42:46.246989-05
ec90b7a1-6cca-487c-b9f6-230fb4370403	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:24:35.453762-05	2025-10-13 03:25:35.451582-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:22:35.453762-05	2025-10-13 03:25:35.45741-05	2025-10-13 03:32:35.453762-05	f	\N	2025-10-13 15:42:46.246989-05
47ed8081-3b0a-448e-bbc5-25e494aca3e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:26:01.663447-05	2025-10-13 03:26:01.684524-05	\N	2025-10-13 08:26:00	00:15:00	2025-10-13 03:25:01.663447-05	2025-10-13 03:26:01.693622-05	2025-10-13 03:27:01.663447-05	f	\N	2025-10-13 15:42:46.246989-05
08369246-d351-4061-9a1b-89d4811853e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:27:01.692367-05	2025-10-13 03:27:01.70341-05	\N	2025-10-13 08:27:00	00:15:00	2025-10-13 03:26:01.692367-05	2025-10-13 03:27:01.709814-05	2025-10-13 03:28:01.692367-05	f	\N	2025-10-13 15:42:46.246989-05
b84b2575-92c5-4c8b-9e1d-02f917d749cd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:29:01.734801-05	2025-10-13 03:29:01.753014-05	\N	2025-10-13 08:29:00	00:15:00	2025-10-13 03:28:01.734801-05	2025-10-13 03:29:01.762065-05	2025-10-13 03:30:01.734801-05	f	\N	2025-10-13 15:42:46.246989-05
0d22ec9e-a9f5-4da1-8fa6-db9fb34638e5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:30:35.467695-05	2025-10-13 03:31:35.462786-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:28:35.467695-05	2025-10-13 03:31:35.469911-05	2025-10-13 03:38:35.467695-05	f	\N	2025-10-13 15:42:46.246989-05
8f418d9c-91e6-4f37-9089-d7fdc6bbd325	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:28:01.708812-05	2025-10-13 03:28:01.729601-05	\N	2025-10-13 08:28:00	00:15:00	2025-10-13 03:27:01.708812-05	2025-10-13 03:28:01.735932-05	2025-10-13 03:29:01.708812-05	f	\N	2025-10-13 15:42:46.246989-05
abfcf2db-b6c8-4b2e-8f31-f214df5eb294	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:27:35.458798-05	2025-10-13 03:28:35.457225-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:25:35.458798-05	2025-10-13 03:28:35.46572-05	2025-10-13 03:35:35.458798-05	f	\N	2025-10-13 15:42:46.246989-05
c33bfa6a-295b-41a2-8674-2be0e2831a14	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:30:01.760147-05	2025-10-13 03:30:01.78068-05	\N	2025-10-13 08:30:00	00:15:00	2025-10-13 03:29:01.760147-05	2025-10-13 03:30:01.793131-05	2025-10-13 03:31:01.760147-05	f	\N	2025-10-13 15:42:46.246989-05
4bfd8d81-9dcc-4f21-bc0d-9521d2d63aab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:31:01.791523-05	2025-10-13 03:31:01.811272-05	\N	2025-10-13 08:31:00	00:15:00	2025-10-13 03:30:01.791523-05	2025-10-13 03:31:01.820666-05	2025-10-13 03:32:01.791523-05	f	\N	2025-10-13 15:42:46.246989-05
b04c6d8e-76dd-429d-a76b-018baec469e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:32:01.819268-05	2025-10-13 03:32:01.834274-05	\N	2025-10-13 08:32:00	00:15:00	2025-10-13 03:31:01.819268-05	2025-10-13 03:32:01.843844-05	2025-10-13 03:33:01.819268-05	f	\N	2025-10-13 15:42:46.246989-05
fd6ce0ea-f893-4968-b352-2c7187f4817f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:33:01.842442-05	2025-10-13 03:33:01.864386-05	\N	2025-10-13 08:33:00	00:15:00	2025-10-13 03:32:01.842442-05	2025-10-13 03:33:01.870686-05	2025-10-13 03:34:01.842442-05	f	\N	2025-10-13 15:42:46.246989-05
5bba4517-9ebe-4308-9d74-7513243d092b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:34:01.86963-05	2025-10-13 03:34:01.893684-05	\N	2025-10-13 08:34:00	00:15:00	2025-10-13 03:33:01.86963-05	2025-10-13 03:34:01.901757-05	2025-10-13 03:35:01.86963-05	f	\N	2025-10-13 15:42:46.246989-05
66cb91cc-8317-49ec-9279-ee1c03a11145	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:33:35.471421-05	2025-10-13 03:34:35.468609-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:31:35.471421-05	2025-10-13 03:34:35.475688-05	2025-10-13 03:41:35.471421-05	f	\N	2025-10-13 15:42:46.246989-05
9ba54478-6efb-457e-a015-4fba7907eefb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:35:01.90055-05	2025-10-13 03:35:01.91664-05	\N	2025-10-13 08:35:00	00:15:00	2025-10-13 03:34:01.90055-05	2025-10-13 03:35:01.927102-05	2025-10-13 03:36:01.90055-05	f	\N	2025-10-13 15:42:46.246989-05
ba4efc28-915e-490e-b31d-acd55a9eb054	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:36:01.925753-05	2025-10-13 03:36:01.936526-05	\N	2025-10-13 08:36:00	00:15:00	2025-10-13 03:35:01.925753-05	2025-10-13 03:36:01.945056-05	2025-10-13 03:37:01.925753-05	f	\N	2025-10-13 15:42:46.246989-05
5e6a571b-b68e-42ab-8782-94de366e72ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:37:01.943763-05	2025-10-13 03:37:01.966316-05	\N	2025-10-13 08:37:00	00:15:00	2025-10-13 03:36:01.943763-05	2025-10-13 03:37:01.978005-05	2025-10-13 03:38:01.943763-05	f	\N	2025-10-13 15:42:46.246989-05
cd3d8168-8956-478d-9e24-2d0cc210b6ce	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:36:35.477284-05	2025-10-13 03:37:35.473837-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:34:35.477284-05	2025-10-13 03:37:35.480301-05	2025-10-13 03:44:35.477284-05	f	\N	2025-10-13 15:42:46.246989-05
df353271-4b73-4acc-874d-119ac8067b9b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:38:01.976313-05	2025-10-13 03:38:01.992685-05	\N	2025-10-13 08:38:00	00:15:00	2025-10-13 03:37:01.976313-05	2025-10-13 03:38:02.002357-05	2025-10-13 03:39:01.976313-05	f	\N	2025-10-13 15:42:46.246989-05
feea4dff-35aa-40b4-8b64-8a926f0127b8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:39:01.000723-05	2025-10-13 03:39:02.023968-05	\N	2025-10-13 08:39:00	00:15:00	2025-10-13 03:38:02.000723-05	2025-10-13 03:39:02.03083-05	2025-10-13 03:40:01.000723-05	f	\N	2025-10-13 15:42:46.246989-05
c984d829-6ceb-4d80-9d43-98c1f4ed2c9f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:40:01.030044-05	2025-10-13 03:40:02.051746-05	\N	2025-10-13 08:40:00	00:15:00	2025-10-13 03:39:02.030044-05	2025-10-13 03:40:02.060671-05	2025-10-13 03:41:01.030044-05	f	\N	2025-10-13 15:42:46.246989-05
e169ab03-b526-4a47-80a2-98e522f3c214	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:39:35.481652-05	2025-10-13 03:40:35.476321-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:37:35.481652-05	2025-10-13 03:40:35.485238-05	2025-10-13 03:47:35.481652-05	f	\N	2025-10-13 15:42:46.246989-05
88ea1cc7-05ff-414d-8944-b6b244b75949	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:41:01.059291-05	2025-10-13 03:41:02.079497-05	\N	2025-10-13 08:41:00	00:15:00	2025-10-13 03:40:02.059291-05	2025-10-13 03:41:02.087745-05	2025-10-13 03:42:01.059291-05	f	\N	2025-10-13 15:42:46.246989-05
3544eef5-9992-4507-b5d9-7c09b47f6252	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:42:01.086535-05	2025-10-13 03:42:02.111161-05	\N	2025-10-13 08:42:00	00:15:00	2025-10-13 03:41:02.086535-05	2025-10-13 03:42:02.122816-05	2025-10-13 03:43:01.086535-05	f	\N	2025-10-13 15:42:46.246989-05
f614bb12-1c6f-48ac-9e2e-1b7ffd3fa8fd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:39:01.357063-05	2025-10-12 08:39:03.956508-05	\N	2025-10-12 13:39:00	00:15:00	2025-10-12 08:38:00.357063-05	2025-10-12 08:39:03.965496-05	2025-10-12 08:40:01.357063-05	f	\N	2025-10-12 20:41:34.843187-05
81b966c1-a197-4df9-8203-d2f1282e2473	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:40:01.964943-05	2025-10-12 08:40:03.973207-05	\N	2025-10-12 13:40:00	00:15:00	2025-10-12 08:39:03.964943-05	2025-10-12 08:40:03.993021-05	2025-10-12 08:41:01.964943-05	f	\N	2025-10-12 20:41:34.843187-05
84fdc162-92ef-4702-a283-e0e7ff722cc8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:41:01.991455-05	2025-10-12 08:41:04.000248-05	\N	2025-10-12 13:41:00	00:15:00	2025-10-12 08:40:03.991455-05	2025-10-12 08:41:04.01367-05	2025-10-12 08:42:01.991455-05	f	\N	2025-10-12 20:41:34.843187-05
b6f31e6f-0a46-49cb-923f-05d248bdc646	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:40:07.946472-05	2025-10-12 08:41:07.955903-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:38:07.946472-05	2025-10-12 08:41:07.966044-05	2025-10-12 08:48:07.946472-05	f	\N	2025-10-12 20:41:34.843187-05
3e8d2d4e-5cdc-422e-8d4a-734edfe8d439	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:43:01.040396-05	2025-10-12 08:43:03.258768-05	\N	2025-10-12 13:43:00	00:15:00	2025-10-12 08:42:04.040396-05	2025-10-12 08:43:03.265891-05	2025-10-12 08:44:01.040396-05	f	\N	2025-10-12 20:44:34.848328-05
b9d112ee-514b-4550-9b83-c8308c9618c3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:42:59.253279-05	2025-10-12 08:42:59.254692-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:42:59.253279-05	2025-10-12 08:42:59.259177-05	2025-10-12 08:50:59.253279-05	f	\N	2025-10-12 20:44:34.848328-05
7fb2c361-07aa-455f-83b4-55f778d5264a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:42:01.012711-05	2025-10-12 08:42:04.026649-05	\N	2025-10-12 13:42:00	00:15:00	2025-10-12 08:41:04.012711-05	2025-10-12 08:42:04.041456-05	2025-10-12 08:43:01.012711-05	f	\N	2025-10-12 20:44:34.848328-05
dd6c082a-bddc-433f-be52-a0fc2a397288	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:42:09.123172-05	2025-10-12 08:42:09.125276-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:42:09.123172-05	2025-10-12 08:42:09.133041-05	2025-10-12 08:50:09.123172-05	f	\N	2025-10-12 20:44:34.848328-05
e8d0500b-9e91-4d96-bbf4-68ed003cd27b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:43:05.837491-05	2025-10-12 08:43:05.83911-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:43:05.837491-05	2025-10-12 08:43:05.848014-05	2025-10-12 08:51:05.837491-05	f	\N	2025-10-12 20:44:34.848328-05
e8988c1b-a30f-4d57-b47d-a6d08bf29761	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:42:12.118544-05	2025-10-12 08:42:12.120223-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:42:12.118544-05	2025-10-12 08:42:12.125844-05	2025-10-12 08:50:12.118544-05	f	\N	2025-10-12 20:44:34.848328-05
600ae3b9-79bf-40aa-acb7-204c0eadf590	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:43:10.721752-05	2025-10-12 08:43:10.723516-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:43:10.721752-05	2025-10-12 08:43:10.728425-05	2025-10-12 08:51:10.721752-05	f	\N	2025-10-12 20:44:34.848328-05
36478360-b963-4516-8d22-c319f5c9419c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:43:10.795272-05	2025-10-12 08:43:10.796828-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:43:10.795272-05	2025-10-12 08:43:10.801648-05	2025-10-12 08:51:10.795272-05	f	\N	2025-10-12 20:44:34.848328-05
79699114-d84a-4e92-8495-814893c93aa9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:43:10.88729-05	2025-10-12 08:43:10.888888-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:43:10.88729-05	2025-10-12 08:43:10.894011-05	2025-10-12 08:51:10.88729-05	f	\N	2025-10-12 20:44:34.848328-05
0d03144c-59af-4154-a26b-8ebaa759a8b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:44:01.265232-05	2025-10-12 08:44:02.741576-05	\N	2025-10-12 13:44:00	00:15:00	2025-10-12 08:43:03.265232-05	2025-10-12 08:44:02.764168-05	2025-10-12 08:45:01.265232-05	f	\N	2025-10-12 20:44:34.848328-05
1d742a69-c453-406a-852b-166837c5cd29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:45:01.762446-05	2025-10-12 08:45:02.757407-05	\N	2025-10-12 13:45:00	00:15:00	2025-10-12 08:44:02.762446-05	2025-10-12 08:45:02.772233-05	2025-10-12 08:46:01.762446-05	f	\N	2025-10-12 20:47:34.854868-05
cb7c7b83-ec18-42cf-a109-8e8120501150	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:46:01.771025-05	2025-10-12 08:46:02.770192-05	\N	2025-10-12 13:46:00	00:15:00	2025-10-12 08:45:02.771025-05	2025-10-12 08:46:02.777813-05	2025-10-12 08:47:01.771025-05	f	\N	2025-10-12 20:47:34.854868-05
af487ac8-27dd-417b-8bfb-37b5ef96b644	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 08:45:10.89509-05	2025-10-12 08:46:10.727814-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 08:43:10.89509-05	2025-10-12 08:46:10.733059-05	2025-10-12 08:53:10.89509-05	f	\N	2025-10-12 20:47:34.854868-05
72e92ccb-9299-4ec7-b546-bcfa42bac4f0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:47:01.776519-05	2025-10-12 08:47:02.790555-05	\N	2025-10-12 13:47:00	00:15:00	2025-10-12 08:46:02.776519-05	2025-10-12 08:47:02.799988-05	2025-10-12 08:48:01.776519-05	f	\N	2025-10-12 20:47:34.854868-05
676d8b31-d260-420b-9a03-3cbad456a957	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 08:48:01.799128-05	2025-10-12 08:48:02.806803-05	\N	2025-10-12 13:48:00	00:15:00	2025-10-12 08:47:02.799128-05	2025-10-12 08:48:02.818948-05	2025-10-12 08:49:01.799128-05	f	\N	2025-10-12 20:50:34.85846-05
2ffe6910-74e4-46c0-93ff-e08ed51d7226	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:49:01.342737-05	2025-10-13 00:49:01.358162-05	\N	2025-10-13 05:49:00	00:15:00	2025-10-13 00:48:01.342737-05	2025-10-13 00:49:01.369133-05	2025-10-13 00:50:01.342737-05	f	\N	2025-10-13 12:51:34.999307-05
b4cf9e75-0b5e-4b93-b5b7-765c46c0433e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:50:01.367624-05	2025-10-13 00:50:01.384916-05	\N	2025-10-13 05:50:00	00:15:00	2025-10-13 00:49:01.367624-05	2025-10-13 00:50:01.390954-05	2025-10-13 00:51:01.367624-05	f	\N	2025-10-13 12:51:34.999307-05
85964392-2e02-4754-95c8-9e6d92c3285b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:49:35.188733-05	2025-10-13 00:50:35.186156-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:47:35.188733-05	2025-10-13 00:50:35.192631-05	2025-10-13 00:57:35.188733-05	f	\N	2025-10-13 12:51:34.999307-05
ed288a92-51de-4639-aa56-e20804780234	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:51:01.390034-05	2025-10-13 00:51:01.408274-05	\N	2025-10-13 05:51:00	00:15:00	2025-10-13 00:50:01.390034-05	2025-10-13 00:51:01.417433-05	2025-10-13 00:52:01.390034-05	f	\N	2025-10-13 12:51:34.999307-05
09879e38-de8c-41be-907d-f1d23d838bc5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:52:35.193944-05	2025-10-13 00:53:35.189399-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:50:35.193944-05	2025-10-13 00:53:35.196107-05	2025-10-13 01:00:35.193944-05	f	\N	2025-10-13 12:55:35.038013-05
379ff9a6-f5f9-4fb7-a2a4-2ed20a41c5e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:54:01.469635-05	2025-10-13 00:54:01.495112-05	\N	2025-10-13 05:54:00	00:15:00	2025-10-13 00:53:01.469635-05	2025-10-13 00:54:01.504693-05	2025-10-13 00:55:01.469635-05	f	\N	2025-10-13 12:55:35.038013-05
ce777789-665f-429d-8660-e8f26f94bbea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:55:01.503179-05	2025-10-13 00:55:01.521537-05	\N	2025-10-13 05:55:00	00:15:00	2025-10-13 00:54:01.503179-05	2025-10-13 00:55:01.526434-05	2025-10-13 00:56:01.503179-05	f	\N	2025-10-13 12:55:35.038013-05
dc24403b-704e-4a88-84ba-9e3f14606c97	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:57:01.51702-05	2025-10-13 03:57:02.533255-05	\N	2025-10-13 08:57:00	00:15:00	2025-10-13 03:56:02.51702-05	2025-10-13 03:57:02.542328-05	2025-10-13 03:58:01.51702-05	f	\N	2025-10-13 16:00:01.716034-05
60c778b5-b516-4a28-a9e6-5bb15e0bf0de	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:59:01.555106-05	2025-10-13 03:59:02.569347-05	\N	2025-10-13 08:59:00	00:15:00	2025-10-13 03:58:02.555106-05	2025-10-13 03:59:02.578488-05	2025-10-13 04:00:01.555106-05	f	\N	2025-10-13 16:00:01.716034-05
90bf746a-a9af-45c5-ae8a-f2ef917d778c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:58:01.540928-05	2025-10-13 03:58:02.547695-05	\N	2025-10-13 08:58:00	00:15:00	2025-10-13 03:57:02.540928-05	2025-10-13 03:58:02.556229-05	2025-10-13 03:59:01.540928-05	f	\N	2025-10-13 16:00:01.716034-05
b125f501-6af2-4cdf-b4f2-4a2797029c66	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:56:01.492065-05	2025-10-13 03:56:02.511023-05	\N	2025-10-13 08:56:00	00:15:00	2025-10-13 03:55:02.492065-05	2025-10-13 03:56:02.518211-05	2025-10-13 03:57:01.492065-05	f	\N	2025-10-13 16:00:01.716034-05
87da3c73-3c8f-4e89-8daf-dec0b715df63	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:57:35.507029-05	2025-10-13 03:58:35.50622-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:55:35.507029-05	2025-10-13 03:58:35.513474-05	2025-10-13 04:05:35.507029-05	f	\N	2025-10-13 16:00:01.716034-05
ee568de5-9f91-4e00-a254-f50ba23f9019	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:43:01.121184-05	2025-10-13 03:43:02.141546-05	\N	2025-10-13 08:43:00	00:15:00	2025-10-13 03:42:02.121184-05	2025-10-13 03:43:02.150165-05	2025-10-13 03:44:01.121184-05	f	\N	2025-10-13 16:00:01.716034-05
d37e6567-4517-4f72-9cae-b43bbfbc856d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:42:35.486868-05	2025-10-13 03:43:35.481287-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:40:35.486868-05	2025-10-13 03:43:35.48716-05	2025-10-13 03:50:35.486868-05	f	\N	2025-10-13 16:00:01.716034-05
9532f649-9e80-47f5-b919-02dd47ca8eb8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:44:01.148763-05	2025-10-13 03:44:02.170197-05	\N	2025-10-13 08:44:00	00:15:00	2025-10-13 03:43:02.148763-05	2025-10-13 03:44:02.177693-05	2025-10-13 03:45:01.148763-05	f	\N	2025-10-13 16:00:01.716034-05
1d44cb61-198b-4d3b-9a32-737f7a858862	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:45:01.176489-05	2025-10-13 03:45:02.200952-05	\N	2025-10-13 08:45:00	00:15:00	2025-10-13 03:44:02.176489-05	2025-10-13 03:45:02.213271-05	2025-10-13 03:46:01.176489-05	f	\N	2025-10-13 16:00:01.716034-05
c462b2da-2b11-48ee-abc0-c0349b3a2fe7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:46:01.211477-05	2025-10-13 03:46:02.23068-05	\N	2025-10-13 08:46:00	00:15:00	2025-10-13 03:45:02.211477-05	2025-10-13 03:46:02.242713-05	2025-10-13 03:47:01.211477-05	f	\N	2025-10-13 16:00:01.716034-05
7e4b5540-6987-4d82-9aea-7fd7984dd684	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:45:35.488396-05	2025-10-13 03:46:35.486582-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:43:35.488396-05	2025-10-13 03:46:35.494985-05	2025-10-13 03:53:35.488396-05	f	\N	2025-10-13 16:00:01.716034-05
db5f4294-ac77-4069-92a5-6b6d7e1fdfab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:47:01.241096-05	2025-10-13 03:47:02.259656-05	\N	2025-10-13 08:47:00	00:15:00	2025-10-13 03:46:02.241096-05	2025-10-13 03:47:02.267971-05	2025-10-13 03:48:01.241096-05	f	\N	2025-10-13 16:00:01.716034-05
3e95caaf-9736-440e-825b-c48969e97240	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:48:01.266852-05	2025-10-13 03:48:02.288632-05	\N	2025-10-13 08:48:00	00:15:00	2025-10-13 03:47:02.266852-05	2025-10-13 03:48:02.301847-05	2025-10-13 03:49:01.266852-05	f	\N	2025-10-13 16:00:01.716034-05
948dd281-3d10-4679-ba5b-1ae53fcf42ba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:49:01.300089-05	2025-10-13 03:49:02.319533-05	\N	2025-10-13 08:49:00	00:15:00	2025-10-13 03:48:02.300089-05	2025-10-13 03:49:02.326488-05	2025-10-13 03:50:01.300089-05	f	\N	2025-10-13 16:00:01.716034-05
610a60a1-57df-431b-ba36-d631189499f6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:48:35.496832-05	2025-10-13 03:49:35.49189-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:46:35.496832-05	2025-10-13 03:49:35.497103-05	2025-10-13 03:56:35.496832-05	f	\N	2025-10-13 16:00:01.716034-05
0a236db3-78b6-4927-b5d2-1c9306c41d5f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:50:01.325477-05	2025-10-13 03:50:02.344053-05	\N	2025-10-13 08:50:00	00:15:00	2025-10-13 03:49:02.325477-05	2025-10-13 03:50:02.350797-05	2025-10-13 03:51:01.325477-05	f	\N	2025-10-13 16:00:01.716034-05
6cdfc80e-664f-4705-bee7-4919709bf1b0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:51:01.350176-05	2025-10-13 03:51:02.373092-05	\N	2025-10-13 08:51:00	00:15:00	2025-10-13 03:50:02.350176-05	2025-10-13 03:51:02.383187-05	2025-10-13 03:52:01.350176-05	f	\N	2025-10-13 16:00:01.716034-05
e5cfb838-ab31-4c14-aac6-3d04ce585fd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:52:01.381804-05	2025-10-13 03:52:02.396025-05	\N	2025-10-13 08:52:00	00:15:00	2025-10-13 03:51:02.381804-05	2025-10-13 03:52:02.406576-05	2025-10-13 03:53:01.381804-05	f	\N	2025-10-13 16:00:01.716034-05
3a7c3e25-50c6-416f-9e92-1779fccbaf39	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:51:35.498079-05	2025-10-13 03:52:35.496764-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:49:35.498079-05	2025-10-13 03:52:35.506154-05	2025-10-13 03:59:35.498079-05	f	\N	2025-10-13 16:00:01.716034-05
2cda532a-c0c0-4ef5-98a7-031be8606c24	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:17:35.746166-05	2025-10-12 10:17:35.753988-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:17:35.746166-05	2025-10-12 10:17:35.778098-05	2025-10-12 10:25:35.746166-05	f	\N	2025-10-12 22:19:34.955197-05
98f5e1f6-dc47-4dfa-b899-898752f87ebc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:17:35.791291-05	2025-10-12 10:17:39.772836-05	\N	2025-10-12 15:17:00	00:15:00	2025-10-12 10:17:35.791291-05	2025-10-12 10:17:39.794982-05	2025-10-12 10:18:35.791291-05	f	\N	2025-10-12 22:19:34.955197-05
a1852341-6ea3-45db-8480-df2cd037436e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:18:01.793377-05	2025-10-12 10:18:03.777958-05	\N	2025-10-12 15:18:00	00:15:00	2025-10-12 10:17:39.793377-05	2025-10-12 10:18:03.791665-05	2025-10-12 10:19:01.793377-05	f	\N	2025-10-12 22:19:34.955197-05
05f328d9-92ef-4407-9ecc-8d894582b670	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:19:01.79015-05	2025-10-12 10:19:03.789925-05	\N	2025-10-12 15:19:00	00:15:00	2025-10-12 10:18:03.79015-05	2025-10-12 10:19:03.799107-05	2025-10-12 10:20:01.79015-05	f	\N	2025-10-12 22:19:34.955197-05
733d39b4-94e4-4645-b9ed-e5feaea40fb1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:20:01.797545-05	2025-10-12 10:20:03.806691-05	\N	2025-10-12 15:20:00	00:15:00	2025-10-12 10:19:03.797545-05	2025-10-12 10:20:03.821165-05	2025-10-12 10:21:01.797545-05	f	\N	2025-10-12 22:22:34.958929-05
ba333f97-a4d6-4947-a355-ae23873a30e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:19:35.782012-05	2025-10-12 10:20:35.758019-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:17:35.782012-05	2025-10-12 10:20:35.767544-05	2025-10-12 10:27:35.782012-05	f	\N	2025-10-12 22:22:34.958929-05
20e78ab6-0465-48ca-b22a-ad7a1b3dbf68	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:21:01.819937-05	2025-10-12 10:21:03.820531-05	\N	2025-10-12 15:21:00	00:15:00	2025-10-12 10:20:03.819937-05	2025-10-12 10:21:03.835263-05	2025-10-12 10:22:01.819937-05	f	\N	2025-10-12 22:22:34.958929-05
ebd7d9ce-5417-4031-9858-6816ed42cf9f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:22:01.833176-05	2025-10-12 10:22:03.836674-05	\N	2025-10-12 15:22:00	00:15:00	2025-10-12 10:21:03.833176-05	2025-10-12 10:22:03.849069-05	2025-10-12 10:23:01.833176-05	f	\N	2025-10-12 22:22:34.958929-05
d7b3140d-ce8a-4e91-b051-25d1299ccdca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:53:01.441935-05	2025-10-13 00:53:01.463771-05	\N	2025-10-13 05:53:00	00:15:00	2025-10-13 00:52:01.441935-05	2025-10-13 00:53:01.470586-05	2025-10-13 00:54:01.441935-05	f	\N	2025-10-13 12:53:35.020087-05
408ac5c6-5dc3-4d21-bb31-060362a59bf4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:52:01.41629-05	2025-10-13 00:52:01.435769-05	\N	2025-10-13 05:52:00	00:15:00	2025-10-13 00:51:01.41629-05	2025-10-13 00:52:01.442873-05	2025-10-13 00:53:01.41629-05	f	\N	2025-10-13 12:53:35.020087-05
d4e4a1d3-af16-4a05-8e3b-a646d2a7e210	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:53:01.405027-05	2025-10-13 03:53:02.428014-05	\N	2025-10-13 08:53:00	00:15:00	2025-10-13 03:52:02.405027-05	2025-10-13 03:53:02.437624-05	2025-10-13 03:54:01.405027-05	f	\N	2025-10-13 16:00:01.716034-05
3e68ed26-7f72-4cd5-bf1c-17de11482cff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:54:01.4363-05	2025-10-13 03:54:02.457385-05	\N	2025-10-13 08:54:00	00:15:00	2025-10-13 03:53:02.4363-05	2025-10-13 03:54:02.463262-05	2025-10-13 03:55:01.4363-05	f	\N	2025-10-13 16:00:01.716034-05
762eb9e9-93aa-46c3-bedf-07c5349f221a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:55:01.462718-05	2025-10-13 03:55:02.484483-05	\N	2025-10-13 08:55:00	00:15:00	2025-10-13 03:54:02.462718-05	2025-10-13 03:55:02.493433-05	2025-10-13 03:56:01.462718-05	f	\N	2025-10-13 16:00:01.716034-05
10714c4d-2bcb-42c6-a5ae-e3fc42b41abd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:54:35.508171-05	2025-10-13 03:55:35.501281-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:52:35.508171-05	2025-10-13 03:55:35.505808-05	2025-10-13 04:02:35.508171-05	f	\N	2025-10-13 16:00:01.716034-05
f8c3212d-6767-4834-a62a-173edbbc8718	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:23:01.847689-05	2025-10-12 10:23:03.854825-05	\N	2025-10-12 15:23:00	00:15:00	2025-10-12 10:22:03.847689-05	2025-10-12 10:23:03.869429-05	2025-10-12 10:24:01.847689-05	f	\N	2025-10-12 22:25:34.964196-05
ec76dd97-2187-404a-bbe1-91b0089946ea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:22:35.769182-05	2025-10-12 10:23:35.76477-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:20:35.769182-05	2025-10-12 10:23:35.772676-05	2025-10-12 10:30:35.769182-05	f	\N	2025-10-12 22:25:34.964196-05
c81ffab5-bd0f-49c2-9af4-dab01b96680b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:24:01.868037-05	2025-10-12 10:24:03.885362-05	\N	2025-10-12 15:24:00	00:15:00	2025-10-12 10:23:03.868037-05	2025-10-12 10:24:03.896793-05	2025-10-12 10:25:01.868037-05	f	\N	2025-10-12 22:25:34.964196-05
d14bc6c8-76ad-40c5-a6e5-a04439007f1f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:25:01.895467-05	2025-10-12 10:25:03.91132-05	\N	2025-10-12 15:25:00	00:15:00	2025-10-12 10:24:03.895467-05	2025-10-12 10:25:03.928127-05	2025-10-12 10:26:01.895467-05	f	\N	2025-10-12 22:25:34.964196-05
1d5d5814-92ee-4736-8cf3-6e4a0536bc4c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:26:01.925545-05	2025-10-12 10:26:03.941707-05	\N	2025-10-12 15:26:00	00:15:00	2025-10-12 10:25:03.925545-05	2025-10-12 10:26:03.953062-05	2025-10-12 10:27:01.925545-05	f	\N	2025-10-12 22:28:34.968671-05
9fa6dd55-f2b0-47ee-81cb-a0a236b0b69a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:25:35.774205-05	2025-10-12 10:26:35.770422-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:23:35.774205-05	2025-10-12 10:26:35.780135-05	2025-10-12 10:33:35.774205-05	f	\N	2025-10-12 22:28:34.968671-05
a181f559-dd19-463e-b94a-6b566fb7d1ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:27:01.951734-05	2025-10-12 10:27:03.95865-05	\N	2025-10-12 15:27:00	00:15:00	2025-10-12 10:26:03.951734-05	2025-10-12 10:27:03.968101-05	2025-10-12 10:28:01.951734-05	f	\N	2025-10-12 22:28:34.968671-05
6c4193c0-d086-4434-9bd5-82ba4cb1b72d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:28:01.966909-05	2025-10-12 10:28:03.972044-05	\N	2025-10-12 15:28:00	00:15:00	2025-10-12 10:27:03.966909-05	2025-10-12 10:28:03.97727-05	2025-10-12 10:29:01.966909-05	f	\N	2025-10-12 22:28:34.968671-05
f1cb6850-3378-4a18-81c6-f03fb80b7444	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:35:01.0651-05	2025-10-12 10:35:04.073627-05	\N	2025-10-12 15:35:00	00:15:00	2025-10-12 10:34:04.0651-05	2025-10-12 10:35:04.081738-05	2025-10-12 10:36:01.0651-05	f	\N	2025-10-12 22:37:34.975091-05
669717c7-a9bb-4c5c-84ce-f12d32c533ab	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:34:35.784375-05	2025-10-12 10:35:35.779991-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:32:35.784375-05	2025-10-12 10:35:35.785553-05	2025-10-12 10:42:35.784375-05	f	\N	2025-10-12 22:37:34.975091-05
c70bd70c-31a0-4973-875c-e420ab5775f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:36:01.080869-05	2025-10-12 10:36:04.08609-05	\N	2025-10-12 15:36:00	00:15:00	2025-10-12 10:35:04.080869-05	2025-10-12 10:36:04.096841-05	2025-10-12 10:37:01.080869-05	f	\N	2025-10-12 22:37:34.975091-05
73bb0ca6-666d-43c7-a20f-092165df8387	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:37:01.095255-05	2025-10-12 10:37:04.10186-05	\N	2025-10-12 15:37:00	00:15:00	2025-10-12 10:36:04.095255-05	2025-10-12 10:37:04.108742-05	2025-10-12 10:38:01.095255-05	f	\N	2025-10-12 22:37:34.975091-05
cb68c27b-2c68-4b18-b981-f9407c51beed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:39:01.122684-05	2025-10-12 10:39:04.128587-05	\N	2025-10-12 15:39:00	00:15:00	2025-10-12 10:38:04.122684-05	2025-10-12 10:39:04.141157-05	2025-10-12 10:40:01.122684-05	f	\N	2025-10-12 22:40:34.979791-05
8077d453-3e09-4e34-8afd-d269c9945ede	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:38:01.108064-05	2025-10-12 10:38:04.115661-05	\N	2025-10-12 15:38:00	00:15:00	2025-10-12 10:37:04.108064-05	2025-10-12 10:38:04.123976-05	2025-10-12 10:39:01.108064-05	f	\N	2025-10-12 22:40:34.979791-05
35257904-baed-434f-8fd8-0c768cadb6a1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:37:35.787291-05	2025-10-12 10:38:35.782161-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:35:35.787291-05	2025-10-12 10:38:35.78535-05	2025-10-12 10:45:35.787291-05	f	\N	2025-10-12 22:40:34.979791-05
4f13ce27-959c-465a-ae36-5fe2580ba8e7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:40:01.139038-05	2025-10-12 10:40:04.144892-05	\N	2025-10-12 15:40:00	00:15:00	2025-10-12 10:39:04.139038-05	2025-10-12 10:40:04.155969-05	2025-10-12 10:41:01.139038-05	f	\N	2025-10-12 22:40:34.979791-05
6db87e10-bb1f-49ce-96c3-2a48135f225c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:41:01.154675-05	2025-10-12 10:41:04.158288-05	\N	2025-10-12 15:41:00	00:15:00	2025-10-12 10:40:04.154675-05	2025-10-12 10:41:04.167113-05	2025-10-12 10:42:01.154675-05	f	\N	2025-10-12 22:42:34.99956-05
5f297e3b-edc9-4df8-9626-13739d445340	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:40:35.786264-05	2025-10-12 10:41:35.785691-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:38:35.786264-05	2025-10-12 10:41:35.792281-05	2025-10-12 10:48:35.786264-05	f	\N	2025-10-12 22:42:34.99956-05
7a1d36ad-21a3-4a01-9adc-91e9b01db0f4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:42:01.166048-05	2025-10-12 10:42:04.178155-05	\N	2025-10-12 15:42:00	00:15:00	2025-10-12 10:41:04.166048-05	2025-10-12 10:42:04.187844-05	2025-10-12 10:43:01.166048-05	f	\N	2025-10-12 22:42:34.99956-05
1ad116da-717c-4000-a4f0-d0c50bbdc3e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:49:01.340689-05	2025-10-12 10:49:04.358499-05	\N	2025-10-12 15:49:00	00:15:00	2025-10-12 10:48:04.340689-05	2025-10-12 10:49:04.367373-05	2025-10-12 10:50:01.340689-05	f	\N	2025-10-12 22:51:35.012469-05
081f7e33-2bbc-4f10-b6b5-6c9f196d7eda	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:50:01.366305-05	2025-10-12 10:50:04.384337-05	\N	2025-10-12 15:50:00	00:15:00	2025-10-12 10:49:04.366305-05	2025-10-12 10:50:04.39237-05	2025-10-12 10:51:01.366305-05	f	\N	2025-10-12 22:51:35.012469-05
e6a1d5e9-d874-45e9-b079-9157218b4666	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:49:35.809941-05	2025-10-12 10:50:35.804017-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:47:35.809941-05	2025-10-12 10:50:35.811932-05	2025-10-12 10:57:35.809941-05	f	\N	2025-10-12 22:51:35.012469-05
aacbda0e-9047-41cc-b006-8daa056dade1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:51:01.391379-05	2025-10-12 10:51:04.40287-05	\N	2025-10-12 15:51:00	00:15:00	2025-10-12 10:50:04.391379-05	2025-10-12 10:51:04.413079-05	2025-10-12 10:52:01.391379-05	f	\N	2025-10-12 22:51:35.012469-05
f5dd9627-0dcd-48a6-bc60-f59f02a8223c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:02:26.69053-05	2025-10-12 11:02:26.692123-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:02:26.69053-05	2025-10-12 11:02:26.696973-05	2025-10-12 11:10:26.69053-05	f	\N	2025-10-12 23:03:35.030219-05
13b8d844-807f-49b1-a71f-2323e0c90d4e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:02:01.614587-05	2025-10-12 11:02:03.751632-05	\N	2025-10-12 16:02:00	00:15:00	2025-10-12 11:01:04.614587-05	2025-10-12 11:02:03.770798-05	2025-10-12 11:03:01.614587-05	f	\N	2025-10-12 23:03:35.030219-05
f1bfad8e-6037-48c6-93cb-49681f003abe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:03:01.769637-05	2025-10-12 11:03:02.702482-05	\N	2025-10-12 16:03:00	00:15:00	2025-10-12 11:02:03.769637-05	2025-10-12 11:03:02.723764-05	2025-10-12 11:04:01.769637-05	f	\N	2025-10-12 23:03:35.030219-05
7421dc68-bd0e-44a5-ac13-f54600d2ef50	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:01:01.611371-05	2025-10-12 11:01:04.608837-05	\N	2025-10-12 16:01:00	00:15:00	2025-10-12 11:00:04.611371-05	2025-10-12 11:01:04.615624-05	2025-10-12 11:02:01.611371-05	f	\N	2025-10-12 23:03:35.030219-05
bbade202-99c7-4c1b-a830-1cbbb3288893	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:01:15.73072-05	2025-10-12 11:01:15.73324-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:01:15.73072-05	2025-10-12 11:01:15.739129-05	2025-10-12 11:09:15.73072-05	f	\N	2025-10-12 23:03:35.030219-05
ece9f4f4-d7a6-4bc9-b430-8360b525c144	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:08:01.776081-05	2025-10-12 11:08:02.781864-05	\N	2025-10-12 16:08:00	00:15:00	2025-10-12 11:07:02.776081-05	2025-10-12 11:08:02.791289-05	2025-10-12 11:09:01.776081-05	f	\N	2025-10-12 23:09:35.026338-05
2eb31290-d37e-4709-a15a-dcb356eb45bd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:07:01.762082-05	2025-10-12 11:07:02.764601-05	\N	2025-10-12 16:07:00	00:15:00	2025-10-12 11:06:02.762082-05	2025-10-12 11:07:02.777281-05	2025-10-12 11:08:01.762082-05	f	\N	2025-10-12 23:09:35.026338-05
5457c599-19c7-495a-9ce0-684e02006b48	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:07:26.708184-05	2025-10-12 11:08:26.696355-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:05:26.708184-05	2025-10-12 11:08:26.701938-05	2025-10-12 11:15:26.708184-05	f	\N	2025-10-12 23:09:35.026338-05
aea7e65b-8af2-4e22-81d0-cd6753e814e8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:09:01.790298-05	2025-10-12 11:09:02.795976-05	\N	2025-10-12 16:09:00	00:15:00	2025-10-12 11:08:02.790298-05	2025-10-12 11:09:02.813401-05	2025-10-12 11:10:01.790298-05	f	\N	2025-10-12 23:09:35.026338-05
d7e35b92-b1a8-410b-acf1-d37c58b61e21	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:55:35.197384-05	2025-10-13 00:56:35.191844-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:53:35.197384-05	2025-10-13 00:56:35.197722-05	2025-10-13 01:03:35.197384-05	f	\N	2025-10-13 12:58:35.042497-05
9012cb98-c11d-467f-8fe4-681ad9736569	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:58:01.58819-05	2025-10-13 00:58:01.608449-05	\N	2025-10-13 05:58:00	00:15:00	2025-10-13 00:57:01.58819-05	2025-10-13 00:58:01.620634-05	2025-10-13 00:59:01.58819-05	f	\N	2025-10-13 12:58:35.042497-05
6f128eac-439c-4a2b-bfb2-2395307dc89d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:56:01.525751-05	2025-10-13 00:56:01.554489-05	\N	2025-10-13 05:56:00	00:15:00	2025-10-13 00:55:01.525751-05	2025-10-13 00:56:01.568036-05	2025-10-13 00:57:01.525751-05	f	\N	2025-10-13 12:58:35.042497-05
76dbdd55-0b90-4614-8062-bd3a63694d46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:57:01.566428-05	2025-10-13 00:57:01.58028-05	\N	2025-10-13 05:57:00	00:15:00	2025-10-13 00:56:01.566428-05	2025-10-13 00:57:01.589551-05	2025-10-13 00:58:01.566428-05	f	\N	2025-10-13 12:58:35.042497-05
364cedea-a0a5-427b-bbb5-f20b7701a100	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 00:59:01.618949-05	2025-10-13 00:59:01.633793-05	\N	2025-10-13 05:59:00	00:15:00	2025-10-13 00:58:01.618949-05	2025-10-13 00:59:01.642501-05	2025-10-13 01:00:01.618949-05	f	\N	2025-10-13 13:01:35.040505-05
e03ddb4b-c917-44de-af7c-e2919350c104	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 00:58:35.199075-05	2025-10-13 00:59:35.197461-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:56:35.199075-05	2025-10-13 00:59:35.199757-05	2025-10-13 01:06:35.199075-05	f	\N	2025-10-13 13:01:35.040505-05
2497fe29-9dcb-43ab-b08a-442c80417329	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:00:01.64142-05	2025-10-13 01:00:01.661113-05	\N	2025-10-13 06:00:00	00:15:00	2025-10-13 00:59:01.64142-05	2025-10-13 01:00:01.671518-05	2025-10-13 01:01:01.64142-05	f	\N	2025-10-13 13:01:35.040505-05
e2a35d6c-9a8a-4b72-af45-c1ec4deb1644	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 01:00:01.665613-05	2025-10-13 01:00:05.661721-05	dailyStatsJob	2025-10-13 06:00:00	00:15:00	2025-10-13 01:00:01.665613-05	2025-10-13 01:00:05.664665-05	2025-10-27 01:00:01.665613-05	f	\N	2025-10-13 13:01:35.040505-05
436992df-33f6-4707-8b6a-915e0b75603d	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 01:00:05.66342-05	2025-10-13 01:00:07.455766-05	\N	\N	00:15:00	2025-10-13 01:00:05.66342-05	2025-10-13 01:00:07.619523-05	2025-10-27 01:00:05.66342-05	f	\N	2025-10-13 13:01:35.040505-05
28c22838-fb26-4187-b808-3a6a38d0b3a6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:01:01.669756-05	2025-10-13 01:01:01.690926-05	\N	2025-10-13 06:01:00	00:15:00	2025-10-13 01:00:01.669756-05	2025-10-13 01:01:01.698451-05	2025-10-13 01:02:01.669756-05	f	\N	2025-10-13 13:01:35.040505-05
89eb8118-6a43-4881-a3f7-aaaf1584f537	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:01:01.611124-05	2025-10-13 04:01:02.624084-05	\N	2025-10-13 09:01:00	00:15:00	2025-10-13 04:00:02.611124-05	2025-10-13 04:01:02.63255-05	2025-10-13 04:02:01.611124-05	f	\N	2025-10-13 16:04:58.303979-05
de92f338-1d6c-4b3d-8a3b-bd4cef353a13	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:00:01.577212-05	2025-10-13 04:00:02.600371-05	\N	2025-10-13 09:00:00	00:15:00	2025-10-13 03:59:02.577212-05	2025-10-13 04:00:02.612682-05	2025-10-13 04:01:01.577212-05	f	\N	2025-10-13 16:04:58.303979-05
8f3553c9-9136-4411-862f-cc5f801c6c65	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:29:01.976651-05	2025-10-12 10:29:03.982866-05	\N	2025-10-12 15:29:00	00:15:00	2025-10-12 10:28:03.976651-05	2025-10-12 10:29:03.995305-05	2025-10-12 10:30:01.976651-05	f	\N	2025-10-12 22:31:34.970926-05
3822d5fb-8135-4fb1-b7fe-ddf430d1f20e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:28:35.781773-05	2025-10-12 10:29:35.773845-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:26:35.781773-05	2025-10-12 10:29:35.779675-05	2025-10-12 10:36:35.781773-05	f	\N	2025-10-12 22:31:34.970926-05
fcc6c23e-cfb5-43a7-8b2e-a19ee25aac1a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:30:01.991708-05	2025-10-12 10:30:03.996564-05	\N	2025-10-12 15:30:00	00:15:00	2025-10-12 10:29:03.991708-05	2025-10-12 10:30:04.002573-05	2025-10-12 10:31:01.991708-05	f	\N	2025-10-12 22:31:34.970926-05
377f55a4-4b26-4e62-a124-aa73f85243a4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:31:01.001774-05	2025-10-12 10:31:04.015837-05	\N	2025-10-12 15:31:00	00:15:00	2025-10-12 10:30:04.001774-05	2025-10-12 10:31:04.026175-05	2025-10-12 10:32:01.001774-05	f	\N	2025-10-12 22:31:34.970926-05
dbb8e119-5a01-4a13-81b8-2fa1e09b34f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:33:01.054171-05	2025-10-12 10:33:04.048174-05	\N	2025-10-12 15:33:00	00:15:00	2025-10-12 10:32:04.054171-05	2025-10-12 10:33:04.058016-05	2025-10-12 10:34:01.054171-05	f	\N	2025-10-12 22:34:34.970265-05
1ae615d9-9820-4553-a2ff-a082ac3d2dc6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:34:01.05654-05	2025-10-12 10:34:04.055647-05	\N	2025-10-12 15:34:00	00:15:00	2025-10-12 10:33:04.05654-05	2025-10-12 10:34:04.066404-05	2025-10-12 10:35:01.05654-05	f	\N	2025-10-12 22:34:34.970265-05
69da58c9-d1a2-416a-a807-aeb3752f9234	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:32:01.024866-05	2025-10-12 10:32:04.034237-05	\N	2025-10-12 15:32:00	00:15:00	2025-10-12 10:31:04.024866-05	2025-10-12 10:32:04.058076-05	2025-10-12 10:33:01.024866-05	f	\N	2025-10-12 22:34:34.970265-05
729fdf9c-a030-44c9-a8c4-441b6a97eb0e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:31:35.781356-05	2025-10-12 10:32:35.776768-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:29:35.781356-05	2025-10-12 10:32:35.782533-05	2025-10-12 10:39:35.781356-05	f	\N	2025-10-12 22:34:34.970265-05
f6bde8bb-4f1c-44d0-8042-e88d6e3be5a3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:43:01.186537-05	2025-10-12 10:43:04.200538-05	\N	2025-10-12 15:43:00	00:15:00	2025-10-12 10:42:04.186537-05	2025-10-12 10:43:04.212206-05	2025-10-12 10:44:01.186537-05	f	\N	2025-10-12 22:45:35.005347-05
b825192b-75ef-4703-a024-973745c6535d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:43:35.793816-05	2025-10-12 10:44:35.790797-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:41:35.793816-05	2025-10-12 10:44:35.796066-05	2025-10-12 10:51:35.793816-05	f	\N	2025-10-12 22:45:35.005347-05
244740ac-50e8-4160-b74a-8b91a8ce89d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:44:01.210438-05	2025-10-12 10:44:04.229302-05	\N	2025-10-12 15:44:00	00:15:00	2025-10-12 10:43:04.210438-05	2025-10-12 10:44:04.240553-05	2025-10-12 10:45:01.210438-05	f	\N	2025-10-12 22:45:35.005347-05
8682e4ca-6a0c-4a81-a5c1-285afc6e28f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:45:01.23919-05	2025-10-12 10:45:04.250298-05	\N	2025-10-12 15:45:00	00:15:00	2025-10-12 10:44:04.23919-05	2025-10-12 10:45:04.260305-05	2025-10-12 10:46:01.23919-05	f	\N	2025-10-12 22:45:35.005347-05
e4a66184-218a-4424-b076-ce69ea61eeae	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:01:35.200378-05	2025-10-13 01:01:35.200608-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 00:59:35.200378-05	2025-10-13 01:01:35.207245-05	2025-10-13 01:09:35.200378-05	f	\N	2025-10-13 13:03:49.869166-05
1ebcbd12-a979-48ae-8b51-538e8e548d62	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:02:01.697171-05	2025-10-13 01:02:01.717462-05	\N	2025-10-13 06:02:00	00:15:00	2025-10-13 01:01:01.697171-05	2025-10-13 01:02:01.728803-05	2025-10-13 01:03:01.697171-05	f	\N	2025-10-13 13:03:49.869166-05
6236d759-a41f-4b03-924d-5683c4b3161e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:03:01.72671-05	2025-10-13 01:03:01.744675-05	\N	2025-10-13 06:03:00	00:15:00	2025-10-13 01:02:01.72671-05	2025-10-13 01:03:01.751398-05	2025-10-13 01:04:01.72671-05	f	\N	2025-10-13 13:03:49.869166-05
34c14f21-bf99-4110-9988-a56c112ae313	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:00:35.514838-05	2025-10-13 04:01:35.511187-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:58:35.514838-05	2025-10-13 04:01:35.51737-05	2025-10-13 04:08:35.514838-05	f	\N	2025-10-13 16:04:58.303979-05
a1cad1d8-ecaf-4b6e-ab2c-a1971badab5a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:03:35.519156-05	2025-10-13 04:04:35.51728-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:01:35.519156-05	2025-10-13 04:04:35.52337-05	2025-10-13 04:11:35.519156-05	f	\N	2025-10-13 16:04:58.303979-05
2e6d18e6-8d08-4866-9486-1272157fa65d	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 04:00:06.603533-05	2025-10-13 04:00:07.386425-05	\N	\N	00:15:00	2025-10-13 04:00:06.603533-05	2025-10-13 04:00:07.555636-05	2025-10-27 04:00:06.603533-05	f	\N	2025-10-13 16:04:58.303979-05
7a557dee-4967-4c42-bef6-17811708e683	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 04:00:02.605313-05	2025-10-13 04:00:06.601037-05	dailyStatsJob	2025-10-13 09:00:00	00:15:00	2025-10-13 04:00:02.605313-05	2025-10-13 04:00:06.605233-05	2025-10-27 04:00:02.605313-05	f	\N	2025-10-13 16:04:58.303979-05
03134dd8-f412-4332-9261-ff2ed3304c5c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:02:01.631215-05	2025-10-13 04:02:02.654431-05	\N	2025-10-13 09:02:00	00:15:00	2025-10-13 04:01:02.631215-05	2025-10-13 04:02:02.665601-05	2025-10-13 04:03:01.631215-05	f	\N	2025-10-13 16:04:58.303979-05
748cc9ea-a487-4938-8fad-6003abb638aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:03:01.663689-05	2025-10-13 04:03:02.683078-05	\N	2025-10-13 09:03:00	00:15:00	2025-10-13 04:02:02.663689-05	2025-10-13 04:03:02.687365-05	2025-10-13 04:04:01.663689-05	f	\N	2025-10-13 16:04:58.303979-05
d15df010-36fb-41a8-b5e7-024f4ce3d1f8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:04:01.686689-05	2025-10-13 04:04:02.712049-05	\N	2025-10-13 09:04:00	00:15:00	2025-10-13 04:03:02.686689-05	2025-10-13 04:04:02.722067-05	2025-10-13 04:05:01.686689-05	f	\N	2025-10-13 16:04:58.303979-05
a6222daf-03dc-44cf-b679-85badd4cdc91	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:46:01.259082-05	2025-10-12 10:46:04.277438-05	\N	2025-10-12 15:46:00	00:15:00	2025-10-12 10:45:04.259082-05	2025-10-12 10:46:04.28743-05	2025-10-12 10:47:01.259082-05	f	\N	2025-10-12 22:48:35.008396-05
b3f8eb4c-4d4d-4f8b-8683-38757e223146	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:47:01.286077-05	2025-10-12 10:47:04.303653-05	\N	2025-10-12 15:47:00	00:15:00	2025-10-12 10:46:04.286077-05	2025-10-12 10:47:04.31555-05	2025-10-12 10:48:01.286077-05	f	\N	2025-10-12 22:48:35.008396-05
8e124a30-ac7f-41f5-aee0-57070e07bd34	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:46:35.797417-05	2025-10-12 10:47:35.798497-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:44:35.797417-05	2025-10-12 10:47:35.808302-05	2025-10-12 10:54:35.797417-05	f	\N	2025-10-12 22:48:35.008396-05
ebaf9f23-d443-4e7c-8ca0-860f1bbe4d45	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:48:01.314161-05	2025-10-12 10:48:04.331701-05	\N	2025-10-12 15:48:00	00:15:00	2025-10-12 10:47:04.314161-05	2025-10-12 10:48:04.341954-05	2025-10-12 10:49:01.314161-05	f	\N	2025-10-12 22:48:35.008396-05
a8dfa097-31ab-49b6-83ec-ea8b4812c6f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:52:01.412312-05	2025-10-12 10:52:04.419194-05	\N	2025-10-12 15:52:00	00:15:00	2025-10-12 10:51:04.412312-05	2025-10-12 10:52:04.428157-05	2025-10-12 10:53:01.412312-05	f	\N	2025-10-12 22:54:35.018189-05
85d3ad2e-db8b-4fdc-ae13-f6d75b2639af	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:53:01.427103-05	2025-10-12 10:53:04.433507-05	\N	2025-10-12 15:53:00	00:15:00	2025-10-12 10:52:04.427103-05	2025-10-12 10:53:04.438763-05	2025-10-12 10:54:01.427103-05	f	\N	2025-10-12 22:54:35.018189-05
538797ca-b6b3-4564-bbaf-00d211903f15	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:52:35.814018-05	2025-10-12 10:53:35.807066-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:50:35.814018-05	2025-10-12 10:53:35.813428-05	2025-10-12 11:00:35.814018-05	f	\N	2025-10-12 22:54:35.018189-05
423dd7bf-1976-4370-b668-54240bccb0d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:54:01.43825-05	2025-10-12 10:54:04.448792-05	\N	2025-10-12 15:54:00	00:15:00	2025-10-12 10:53:04.43825-05	2025-10-12 10:54:04.459279-05	2025-10-12 10:55:01.43825-05	f	\N	2025-10-12 22:54:35.018189-05
6e360d93-b2fe-4078-bb90-04c7ef703429	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:55:01.45801-05	2025-10-12 10:55:04.47333-05	\N	2025-10-12 15:55:00	00:15:00	2025-10-12 10:54:04.45801-05	2025-10-12 10:55:04.481902-05	2025-10-12 10:56:01.45801-05	f	\N	2025-10-12 22:57:35.022435-05
a95c8f43-a796-4ebb-98a7-95387f248b80	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:56:01.480774-05	2025-10-12 10:56:04.492108-05	\N	2025-10-12 15:56:00	00:15:00	2025-10-12 10:55:04.480774-05	2025-10-12 10:56:04.509885-05	2025-10-12 10:57:01.480774-05	f	\N	2025-10-12 22:57:35.022435-05
7304b47d-3e31-4782-98b7-223c62242961	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:55:35.814795-05	2025-10-12 10:56:35.810548-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:53:35.814795-05	2025-10-12 10:56:35.816233-05	2025-10-12 11:03:35.814795-05	f	\N	2025-10-12 22:57:35.022435-05
30097176-f263-4015-9fdd-010077c3920b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:57:01.50729-05	2025-10-12 10:57:04.520114-05	\N	2025-10-12 15:57:00	00:15:00	2025-10-12 10:56:04.50729-05	2025-10-12 10:57:04.526854-05	2025-10-12 10:58:01.50729-05	f	\N	2025-10-12 22:57:35.022435-05
059ab3d8-117a-43e6-b5d8-acdc2177feda	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:58:01.526125-05	2025-10-12 10:58:04.547603-05	\N	2025-10-12 15:58:00	00:15:00	2025-10-12 10:57:04.526125-05	2025-10-12 10:58:04.556371-05	2025-10-12 10:59:01.526125-05	f	\N	2025-10-12 23:00:35.02671-05
9cc0752f-e398-4cfd-a813-c60fd5ccedfa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 10:59:01.555284-05	2025-10-12 10:59:04.575569-05	\N	2025-10-12 15:59:00	00:15:00	2025-10-12 10:58:04.555284-05	2025-10-12 10:59:04.586195-05	2025-10-12 11:00:01.555284-05	f	\N	2025-10-12 23:00:35.02671-05
5de9923d-12ac-4f57-9818-6ef34ac6c47e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 10:58:35.817487-05	2025-10-12 10:59:35.82035-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 10:56:35.817487-05	2025-10-12 10:59:35.827612-05	2025-10-12 11:06:35.817487-05	f	\N	2025-10-12 23:00:35.02671-05
4e09cd5e-0c23-495f-98c1-48ca902d627c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:00:01.585371-05	2025-10-12 11:00:04.603396-05	\N	2025-10-12 16:00:00	00:15:00	2025-10-12 10:59:04.585371-05	2025-10-12 11:00:04.61266-05	2025-10-12 11:01:01.585371-05	f	\N	2025-10-12 23:00:35.02671-05
ecdb355e-d659-4f31-8a4a-183fc27e8f88	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T15:17:35.819Z"}	completed	0	0	0	f	2025-10-12 11:00:04.607478-05	2025-10-12 11:00:08.60583-05	dailyStatsJob	2025-10-12 16:00:00	00:15:00	2025-10-12 11:00:04.607478-05	2025-10-12 11:00:08.610105-05	2025-10-26 11:00:04.607478-05	f	\N	2025-10-12 23:00:35.02671-05
17d4d6b3-51c0-45a7-bf1b-9aaf2dc16803	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 11:00:08.608518-05	2025-10-12 11:00:09.57624-05	\N	\N	00:15:00	2025-10-12 11:00:08.608518-05	2025-10-12 11:00:09.874662-05	2025-10-26 11:00:08.608518-05	f	\N	2025-10-12 23:00:35.02671-05
9e2f9525-d658-4ae2-9afc-b44830c76d33	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:04:26.697829-05	2025-10-12 11:05:26.696353-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:02:26.697829-05	2025-10-12 11:05:26.70613-05	2025-10-12 11:12:26.697829-05	f	\N	2025-10-12 23:06:35.036612-05
9d78ca91-8663-4972-bfbc-c952e2ebaf93	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:04:01.722174-05	2025-10-12 11:04:02.719419-05	\N	2025-10-12 16:04:00	00:15:00	2025-10-12 11:03:02.722174-05	2025-10-12 11:04:02.726113-05	2025-10-12 11:05:01.722174-05	f	\N	2025-10-12 23:06:35.036612-05
11dd89d8-57b5-442f-ab77-e1d5609b3bb2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:05:01.724809-05	2025-10-12 11:05:02.738093-05	\N	2025-10-12 16:05:00	00:15:00	2025-10-12 11:04:02.724809-05	2025-10-12 11:05:02.753175-05	2025-10-12 11:06:01.724809-05	f	\N	2025-10-12 23:06:35.036612-05
b04cfd4b-f89b-43dd-a1eb-cdf1b35f03ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:06:01.750216-05	2025-10-12 11:06:02.751652-05	\N	2025-10-12 16:06:00	00:15:00	2025-10-12 11:05:02.750216-05	2025-10-12 11:06:02.762935-05	2025-10-12 11:07:01.750216-05	f	\N	2025-10-12 23:06:35.036612-05
dbfbabca-af2a-4ae3-98a4-b0260ad36e82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:04:01.750527-05	2025-10-13 01:04:01.770517-05	\N	2025-10-13 06:04:00	00:15:00	2025-10-13 01:03:01.750527-05	2025-10-13 01:04:01.778639-05	2025-10-13 01:05:01.750527-05	f	\N	2025-10-13 13:14:25.82339-05
a0ebf773-d531-453d-8ca6-b9019f02c1fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:03:35.208644-05	2025-10-13 01:04:35.204036-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:01:35.208644-05	2025-10-13 01:04:35.210981-05	2025-10-13 01:11:35.208644-05	f	\N	2025-10-13 13:14:25.82339-05
a93b0f68-5ab6-427c-9032-432eb8d4d000	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:05:01.777474-05	2025-10-13 01:05:01.820525-05	\N	2025-10-13 06:05:00	00:15:00	2025-10-13 01:04:01.777474-05	2025-10-13 01:05:01.830718-05	2025-10-13 01:06:01.777474-05	f	\N	2025-10-13 13:14:25.82339-05
a567ab57-2650-44dd-9d0f-b2bcbc9cef29	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:06:35.212507-05	2025-10-13 01:06:35.241697-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:04:35.212507-05	2025-10-13 01:06:35.245812-05	2025-10-13 01:14:35.212507-05	f	\N	2025-10-13 13:14:25.82339-05
b7acf83c-6666-447c-a738-2ca95dbc6317	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:07:01.866108-05	2025-10-13 01:07:01.878168-05	\N	2025-10-13 06:07:00	00:15:00	2025-10-13 01:06:01.866108-05	2025-10-13 01:07:01.883612-05	2025-10-13 01:08:01.866108-05	f	\N	2025-10-13 13:14:25.82339-05
6255cfb5-6385-4bdd-aabc-df7952820792	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-13 13:13:01.663748-05	\N	\N	2025-10-13 18:13:00	00:15:00	2025-10-13 13:12:05.663748-05	\N	2025-10-13 13:14:01.663748-05	f	\N	2025-10-13 13:14:25.82339-05
5378fadf-3bed-48df-b170-1803515bb494	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:06:01.829122-05	2025-10-13 01:06:01.858923-05	\N	2025-10-13 06:06:00	00:15:00	2025-10-13 01:05:01.829122-05	2025-10-13 01:06:01.867498-05	2025-10-13 01:07:01.829122-05	f	\N	2025-10-13 13:14:25.82339-05
ada6ddc8-af31-4246-93e5-d1824e7ab279	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:08:01.88257-05	2025-10-13 01:08:01.90204-05	\N	2025-10-13 06:08:00	00:15:00	2025-10-13 01:07:01.88257-05	2025-10-13 01:08:01.912359-05	2025-10-13 01:09:01.88257-05	f	\N	2025-10-13 13:14:25.82339-05
279ca3ec-4118-4216-9fe3-2c2c6bafef7f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:09:01.911209-05	2025-10-13 01:09:01.927027-05	\N	2025-10-13 06:09:00	00:15:00	2025-10-13 01:08:01.911209-05	2025-10-13 01:09:01.938565-05	2025-10-13 01:10:01.911209-05	f	\N	2025-10-13 13:14:25.82339-05
2b7cf7d5-a09c-4ef9-bf22-bf81ff995af4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:08:35.24684-05	2025-10-13 01:09:35.245353-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:06:35.24684-05	2025-10-13 01:09:35.253238-05	2025-10-13 01:16:35.24684-05	f	\N	2025-10-13 13:14:25.82339-05
48a82267-511c-41c0-a33a-22650c502d9f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:10:01.936898-05	2025-10-13 01:10:01.947365-05	\N	2025-10-13 06:10:00	00:15:00	2025-10-13 01:09:01.936898-05	2025-10-13 01:10:01.958389-05	2025-10-13 01:11:01.936898-05	f	\N	2025-10-13 13:14:25.82339-05
d0a8967d-6f9d-4a54-8702-46e4b7273e96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:11:01.956584-05	2025-10-13 01:11:01.973659-05	\N	2025-10-13 06:11:00	00:15:00	2025-10-13 01:10:01.956584-05	2025-10-13 01:11:01.980274-05	2025-10-13 01:12:01.956584-05	f	\N	2025-10-13 13:14:25.82339-05
57f2bf79-d2c5-4475-9d5c-c6e15f8489b3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:12:01.979166-05	2025-10-13 01:12:01.998879-05	\N	2025-10-13 06:12:00	00:15:00	2025-10-13 01:11:01.979166-05	2025-10-13 01:12:02.00517-05	2025-10-13 01:13:01.979166-05	f	\N	2025-10-13 13:14:25.82339-05
2e908a81-8860-4e5c-a03f-c3ecc0eade3c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:11:35.254581-05	2025-10-13 01:12:35.249897-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:09:35.254581-05	2025-10-13 01:12:35.260847-05	2025-10-13 01:19:35.254581-05	f	\N	2025-10-13 13:14:25.82339-05
5958ee88-ce22-4505-95ba-21cc674a0f4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:13:01.004115-05	2025-10-13 01:13:02.026404-05	\N	2025-10-13 06:13:00	00:15:00	2025-10-13 01:12:02.004115-05	2025-10-13 01:13:02.033705-05	2025-10-13 01:14:01.004115-05	f	\N	2025-10-13 13:14:25.82339-05
24fc27fe-7782-4d70-a84d-a465b2a980d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:14:01.032496-05	2025-10-13 01:14:02.05128-05	\N	2025-10-13 06:14:00	00:15:00	2025-10-13 01:13:02.032496-05	2025-10-13 01:14:02.057821-05	2025-10-13 01:15:01.032496-05	f	\N	2025-10-13 13:14:25.82339-05
808cc3a2-ba01-4bef-8cdb-b9cf33f99641	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:16:01.014161-05	2025-10-13 04:16:03.032956-05	\N	2025-10-13 09:16:00	00:15:00	2025-10-13 04:15:03.014161-05	2025-10-13 04:16:03.043444-05	2025-10-13 04:17:01.014161-05	f	\N	2025-10-13 16:34:28.528717-05
8c54adb9-8151-420b-8a77-fbdaae8cbc4c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:17:01.041622-05	2025-10-13 04:17:03.060553-05	\N	2025-10-13 09:17:00	00:15:00	2025-10-13 04:16:03.041622-05	2025-10-13 04:17:03.071888-05	2025-10-13 04:18:01.041622-05	f	\N	2025-10-13 16:34:28.528717-05
d2cb3a73-c83f-471f-b5f0-70a994cc1c93	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:19:01.097981-05	2025-10-13 04:19:03.114552-05	\N	2025-10-13 09:19:00	00:15:00	2025-10-13 04:18:03.097981-05	2025-10-13 04:19:03.121391-05	2025-10-13 04:20:01.097981-05	f	\N	2025-10-13 16:34:28.528717-05
d49f9eed-8785-487a-b235-48e667ad39c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:20:01.120358-05	2025-10-13 04:20:03.14422-05	\N	2025-10-13 09:20:00	00:15:00	2025-10-13 04:19:03.120358-05	2025-10-13 04:20:03.151716-05	2025-10-13 04:21:01.120358-05	f	\N	2025-10-13 16:34:28.528717-05
667874c9-2847-47e0-8173-7ea5d5a01540	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:21:01.150595-05	2025-10-13 04:21:03.173998-05	\N	2025-10-13 09:21:00	00:15:00	2025-10-13 04:20:03.150595-05	2025-10-13 04:21:03.183188-05	2025-10-13 04:22:01.150595-05	f	\N	2025-10-13 16:34:28.528717-05
da1e39af-012a-47ed-b790-063efd911ee7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:22:01.182011-05	2025-10-13 04:22:03.201922-05	\N	2025-10-13 09:22:00	00:15:00	2025-10-13 04:21:03.182011-05	2025-10-13 04:22:03.208802-05	2025-10-13 04:23:01.182011-05	f	\N	2025-10-13 16:34:28.528717-05
49f90dd8-c196-4ec7-9877-aa8435b3eb1d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:11:01.815666-05	2025-10-12 11:11:02.82663-05	\N	2025-10-12 16:11:00	00:15:00	2025-10-12 11:10:02.815666-05	2025-10-12 11:11:02.839543-05	2025-10-12 11:12:01.815666-05	f	\N	2025-10-12 23:12:35.030601-05
ed481d38-af93-4ea5-8850-17d96e20b1a7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:10:26.703692-05	2025-10-12 11:11:26.698366-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:08:26.703692-05	2025-10-12 11:11:26.704619-05	2025-10-12 11:18:26.703692-05	f	\N	2025-10-12 23:12:35.030601-05
fa0375a2-4922-4486-93d2-5bd3c8595258	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:12:01.838395-05	2025-10-12 11:12:02.841302-05	\N	2025-10-12 16:12:00	00:15:00	2025-10-12 11:11:02.838395-05	2025-10-12 11:12:02.85519-05	2025-10-12 11:13:01.838395-05	f	\N	2025-10-12 23:12:35.030601-05
efca03ec-b4d3-4002-8f68-dbb4f4b4bb40	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:10:01.811788-05	2025-10-12 11:10:02.807753-05	\N	2025-10-12 16:10:00	00:15:00	2025-10-12 11:09:02.811788-05	2025-10-12 11:10:02.8172-05	2025-10-12 11:11:01.811788-05	f	\N	2025-10-12 23:12:35.030601-05
865fac32-09f5-4c8e-8d71-44c3f8732bf7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:13:01.854179-05	2025-10-12 11:13:02.856474-05	\N	2025-10-12 16:13:00	00:15:00	2025-10-12 11:12:02.854179-05	2025-10-12 11:13:02.868547-05	2025-10-12 11:14:01.854179-05	f	\N	2025-10-12 23:15:35.034116-05
58edf63c-0c67-45b3-ab16-67791a9f443f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:14:01.866954-05	2025-10-12 11:14:02.870567-05	\N	2025-10-12 16:14:00	00:15:00	2025-10-12 11:13:02.866954-05	2025-10-12 11:14:02.881461-05	2025-10-12 11:15:01.866954-05	f	\N	2025-10-12 23:15:35.034116-05
c10dc676-376a-4f3c-a1fd-deab209dcfea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:13:26.706368-05	2025-10-12 11:14:26.701962-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:11:26.706368-05	2025-10-12 11:14:26.706569-05	2025-10-12 11:21:26.706368-05	f	\N	2025-10-12 23:15:35.034116-05
ac265740-2300-432e-b6a5-940028fe5d40	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:15:01.88039-05	2025-10-12 11:15:02.883714-05	\N	2025-10-12 16:15:00	00:15:00	2025-10-12 11:14:02.88039-05	2025-10-12 11:15:02.891749-05	2025-10-12 11:16:01.88039-05	f	\N	2025-10-12 23:15:35.034116-05
9b8be811-1789-4c63-9b23-4c5b6581636d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:16:01.890373-05	2025-10-12 11:16:02.89725-05	\N	2025-10-12 16:16:00	00:15:00	2025-10-12 11:15:02.890373-05	2025-10-12 11:16:02.908173-05	2025-10-12 11:17:01.890373-05	f	\N	2025-10-12 23:18:35.037784-05
20a90c11-5f36-4bf0-af78-ead36afaa64c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:17:01.906814-05	2025-10-12 11:17:02.914802-05	\N	2025-10-12 16:17:00	00:15:00	2025-10-12 11:16:02.906814-05	2025-10-12 11:17:02.926313-05	2025-10-12 11:18:01.906814-05	f	\N	2025-10-12 23:18:35.037784-05
861c7563-45fe-4c56-bb2d-3afd6786cf26	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:16:26.707758-05	2025-10-12 11:17:26.704819-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:14:26.707758-05	2025-10-12 11:17:26.710542-05	2025-10-12 11:24:26.707758-05	f	\N	2025-10-12 23:18:35.037784-05
e0b29e7d-8255-4632-8f9e-df1cc72344b0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:18:01.925074-05	2025-10-12 11:18:02.928-05	\N	2025-10-12 16:18:00	00:15:00	2025-10-12 11:17:02.925074-05	2025-10-12 11:18:02.936967-05	2025-10-12 11:19:01.925074-05	f	\N	2025-10-12 23:18:35.037784-05
cef50e8b-fbfa-4ef8-8a59-d11ae5613fc5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:21:01.986071-05	2025-10-12 11:32:09.73131-05	\N	2025-10-12 16:21:00	00:15:00	2025-10-12 11:20:02.986071-05	2025-10-12 11:32:09.770176-05	2025-10-12 11:22:01.986071-05	f	\N	2025-10-12 23:33:35.058598-05
f4d94ca6-227f-4093-86de-b8e91755bc6c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:32:09.768639-05	2025-10-12 11:32:13.717974-05	\N	2025-10-12 16:32:00	00:15:00	2025-10-12 11:32:09.768639-05	2025-10-12 11:32:13.730868-05	2025-10-12 11:33:09.768639-05	f	\N	2025-10-12 23:33:35.058598-05
7a50fafc-0f0c-4277-8788-ffc2b2d8c067	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:33:01.729246-05	2025-10-12 11:43:14.029309-05	\N	2025-10-12 16:33:00	00:15:00	2025-10-12 11:32:13.729246-05	2025-10-12 11:43:14.03515-05	2025-10-12 11:34:01.729246-05	f	\N	2025-10-12 23:43:35.110104-05
7769cdb1-90e2-4fbb-9a2e-f9dfb7afc4b7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:43:14.034318-05	2025-10-12 11:43:18.025287-05	\N	2025-10-12 16:43:00	00:15:00	2025-10-12 11:43:14.034318-05	2025-10-12 11:43:18.031981-05	2025-10-12 11:44:14.034318-05	f	\N	2025-10-12 23:43:35.110104-05
2cdcac23-a8db-463d-916b-1b0aaa9bc89a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:46:59.163019-05	2025-10-12 11:47:59.154089-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:44:59.163019-05	2025-10-12 11:47:59.165506-05	2025-10-12 11:54:59.163019-05	f	\N	2025-10-12 23:49:35.122348-05
f9816320-aa50-4c74-ac54-d2c47163ec9d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:48:01.200268-05	2025-10-12 11:48:03.212825-05	\N	2025-10-12 16:48:00	00:15:00	2025-10-12 11:47:03.200268-05	2025-10-12 11:48:03.225845-05	2025-10-12 11:49:01.200268-05	f	\N	2025-10-12 23:49:35.122348-05
b308763f-44ef-4b2a-ba8f-5d38b4203bf1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:49:01.224414-05	2025-10-12 11:49:03.240832-05	\N	2025-10-12 16:49:00	00:15:00	2025-10-12 11:48:03.224414-05	2025-10-12 11:49:03.255011-05	2025-10-12 11:50:01.224414-05	f	\N	2025-10-12 23:49:35.122348-05
04cc1317-3063-4b86-a500-e34e04470696	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:47:01.194948-05	2025-10-12 11:47:03.192634-05	\N	2025-10-12 16:47:00	00:15:00	2025-10-12 11:46:03.194948-05	2025-10-12 11:47:03.201223-05	2025-10-12 11:48:01.194948-05	f	\N	2025-10-12 23:49:35.122348-05
7a038258-bdd2-410e-9eaf-44f3669840a9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:53:01.304523-05	2025-10-12 11:53:03.309238-05	\N	2025-10-12 16:53:00	00:15:00	2025-10-12 11:52:03.304523-05	2025-10-12 11:53:03.326417-05	2025-10-12 11:54:01.304523-05	f	\N	2025-10-12 23:55:35.137436-05
9c541a8c-1a21-407c-8fdb-15103393d41c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:52:59.16376-05	2025-10-12 11:53:59.157698-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:50:59.16376-05	2025-10-12 11:53:59.161864-05	2025-10-12 12:00:59.16376-05	f	\N	2025-10-12 23:55:35.137436-05
c2301710-28f0-4aa6-8bb0-60dc2de03eaa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:54:01.324604-05	2025-10-12 11:54:03.324563-05	\N	2025-10-12 16:54:00	00:15:00	2025-10-12 11:53:03.324604-05	2025-10-12 11:54:03.340119-05	2025-10-12 11:55:01.324604-05	f	\N	2025-10-12 23:55:35.137436-05
c7bf0b0f-11e7-4668-8b04-e8200b416432	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:55:01.336956-05	2025-10-12 11:55:03.341885-05	\N	2025-10-12 16:55:00	00:15:00	2025-10-12 11:54:03.336956-05	2025-10-12 11:55:03.356382-05	2025-10-12 11:56:01.336956-05	f	\N	2025-10-12 23:55:35.137436-05
b0dbef4d-35d8-4ca3-ba62-6735937efb6e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:02:01.432875-05	2025-10-12 12:02:03.434081-05	\N	2025-10-12 17:02:00	00:15:00	2025-10-12 12:01:03.432875-05	2025-10-12 12:02:03.443869-05	2025-10-12 12:03:01.432875-05	f	\N	2025-10-13 00:03:35.161372-05
3d4af6cc-1aeb-440c-a76b-bd4fcb701be4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:01:59.170312-05	2025-10-12 12:02:59.160671-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:59:59.170312-05	2025-10-12 12:02:59.168385-05	2025-10-12 12:09:59.170312-05	f	\N	2025-10-13 00:03:35.161372-05
fa61a061-ab2b-48d9-8733-5cc64d09b64e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:03:01.443066-05	2025-10-12 12:03:03.449847-05	\N	2025-10-12 17:03:00	00:15:00	2025-10-12 12:02:03.443066-05	2025-10-12 12:03:03.457399-05	2025-10-12 12:04:01.443066-05	f	\N	2025-10-13 00:03:35.161372-05
714dfb7c-4574-4c98-a4ac-c2e5ef60e631	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:16:01.658971-05	2025-10-12 12:16:03.664964-05	\N	2025-10-12 17:16:00	00:15:00	2025-10-12 12:15:03.658971-05	2025-10-12 12:16:03.673957-05	2025-10-12 12:17:01.658971-05	f	\N	2025-10-13 00:18:35.185211-05
75fb8e1c-60c5-4be6-ac42-96f818d61711	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:15:59.205669-05	2025-10-12 12:16:59.198531-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:13:59.205669-05	2025-10-12 12:16:59.205942-05	2025-10-12 12:23:59.205669-05	f	\N	2025-10-13 00:18:35.185211-05
990a39e4-deae-4377-bb83-e9b43ed83fd0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:17:01.673081-05	2025-10-12 12:17:03.679822-05	\N	2025-10-12 17:17:00	00:15:00	2025-10-12 12:16:03.673081-05	2025-10-12 12:17:03.687297-05	2025-10-12 12:18:01.673081-05	f	\N	2025-10-13 00:18:35.185211-05
0ec43f77-6ad2-49bc-8f0a-5d619ba4352f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:18:01.686629-05	2025-10-12 12:18:03.691735-05	\N	2025-10-12 17:18:00	00:15:00	2025-10-12 12:17:03.686629-05	2025-10-12 12:18:03.698425-05	2025-10-12 12:19:01.686629-05	f	\N	2025-10-13 00:18:35.185211-05
d81a85e9-50c6-4425-84a6-df090304d36e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:20:01.200391-05	2025-10-13 01:20:02.222688-05	\N	2025-10-13 06:20:00	00:15:00	2025-10-13 01:19:02.200391-05	2025-10-13 01:20:02.234526-05	2025-10-13 01:21:01.200391-05	f	\N	2025-10-13 13:20:23.481409-05
faf1e8bb-c2d9-457c-b842-a554efd0514f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:19:01.173426-05	2025-10-13 01:19:02.190934-05	\N	2025-10-13 06:19:00	00:15:00	2025-10-13 01:18:02.173426-05	2025-10-13 01:19:02.20225-05	2025-10-13 01:20:01.173426-05	f	\N	2025-10-13 13:20:23.481409-05
98a1414f-5f89-46d3-8e3e-6520a580fd23	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:15:01.056832-05	2025-10-13 01:15:02.079037-05	\N	2025-10-13 06:15:00	00:15:00	2025-10-13 01:14:02.056832-05	2025-10-13 01:15:02.086826-05	2025-10-13 01:16:01.056832-05	f	\N	2025-10-13 13:20:23.481409-05
bb80f9db-f0da-418b-a5ab-713d0064be9c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:14:35.262828-05	2025-10-13 01:15:35.254369-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:12:35.262828-05	2025-10-13 01:15:35.262377-05	2025-10-13 01:22:35.262828-05	f	\N	2025-10-13 13:20:23.481409-05
52243443-faf3-4f7b-8cef-baee6e73172a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:16:01.085715-05	2025-10-13 01:16:02.106101-05	\N	2025-10-13 06:16:00	00:15:00	2025-10-13 01:15:02.085715-05	2025-10-13 01:16:02.114385-05	2025-10-13 01:17:01.085715-05	f	\N	2025-10-13 13:20:23.481409-05
c9dbd0e7-f268-4b0b-8d98-91bac562281b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:17:01.112903-05	2025-10-13 01:17:02.135139-05	\N	2025-10-13 06:17:00	00:15:00	2025-10-13 01:16:02.112903-05	2025-10-13 01:17:02.143573-05	2025-10-13 01:18:01.112903-05	f	\N	2025-10-13 13:20:23.481409-05
d96aa036-cc9d-424f-b3fc-2cd0ff35dd20	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:18:01.142266-05	2025-10-13 01:18:02.163898-05	\N	2025-10-13 06:18:00	00:15:00	2025-10-13 01:17:02.142266-05	2025-10-13 01:18:02.17517-05	2025-10-13 01:19:01.142266-05	f	\N	2025-10-13 13:20:23.481409-05
1c6935ef-77ca-4f45-ad01-b0218ee74ba1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:17:35.264004-05	2025-10-13 01:18:35.260019-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:15:35.264004-05	2025-10-13 01:18:35.267192-05	2025-10-13 01:25:35.264004-05	f	\N	2025-10-13 13:20:23.481409-05
1ed1a995-d3a0-4dbc-b4d7-254972ea3aa6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:21:35.529209-05	2025-10-13 04:22:35.526748-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:19:35.529209-05	2025-10-13 04:22:35.533578-05	2025-10-13 04:29:35.529209-05	f	\N	2025-10-13 16:34:28.528717-05
33baa470-c222-4d7d-a264-5fc658ae22cb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:24:01.237783-05	2025-10-13 04:24:03.25487-05	\N	2025-10-13 09:24:00	00:15:00	2025-10-13 04:23:03.237783-05	2025-10-13 04:24:03.260601-05	2025-10-13 04:25:01.237783-05	f	\N	2025-10-13 16:34:28.528717-05
30af765b-898b-4fb8-86ce-cbd5e7295f5a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:23:01.207572-05	2025-10-13 04:23:03.22828-05	\N	2025-10-13 09:23:00	00:15:00	2025-10-13 04:22:03.207572-05	2025-10-13 04:23:03.239266-05	2025-10-13 04:24:01.207572-05	f	\N	2025-10-13 16:34:28.528717-05
708215e6-8759-4ca2-9aa6-6c930149a800	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:25:01.259493-05	2025-10-13 04:25:03.283572-05	\N	2025-10-13 09:25:00	00:15:00	2025-10-13 04:24:03.259493-05	2025-10-13 04:25:03.292556-05	2025-10-13 04:26:01.259493-05	f	\N	2025-10-13 16:34:28.528717-05
5fa6eb68-7d1a-4a60-9bb2-69d3e571de0b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:28:01.333458-05	2025-10-13 04:28:03.361815-05	\N	2025-10-13 09:28:00	00:15:00	2025-10-13 04:27:03.333458-05	2025-10-13 04:28:03.37106-05	2025-10-13 04:29:01.333458-05	f	\N	2025-10-13 16:34:28.528717-05
011b3ba2-7e4a-4383-a8fb-49c5625a4a5e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:29:01.369858-05	2025-10-13 04:29:03.387743-05	\N	2025-10-13 09:29:00	00:15:00	2025-10-13 04:28:03.369858-05	2025-10-13 04:29:03.397838-05	2025-10-13 04:30:01.369858-05	f	\N	2025-10-13 16:34:28.528717-05
dd97f2c7-fea6-43b0-8fad-abda30a5c56c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:31:01.422883-05	2025-10-13 04:31:03.4422-05	\N	2025-10-13 09:31:00	00:15:00	2025-10-13 04:30:03.422883-05	2025-10-13 04:31:03.451435-05	2025-10-13 04:32:01.422883-05	f	\N	2025-10-13 16:34:28.528717-05
4dd6c63d-d93d-4b6a-9a31-576a7c4106f4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:19:01.935643-05	2025-10-12 11:19:02.956211-05	\N	2025-10-12 16:19:00	00:15:00	2025-10-12 11:18:02.935643-05	2025-10-12 11:19:02.96296-05	2025-10-12 11:20:01.935643-05	f	\N	2025-10-12 23:21:35.046277-05
2d29e10c-1b7a-430e-9981-9ce3bc628a6f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:20:01.961585-05	2025-10-12 11:20:02.978595-05	\N	2025-10-12 16:20:00	00:15:00	2025-10-12 11:19:02.961585-05	2025-10-12 11:20:02.987007-05	2025-10-12 11:21:01.961585-05	f	\N	2025-10-12 23:21:35.046277-05
ad4e076d-ff9e-4454-a88b-65d76cae8b01	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:21:01.23255-05	2025-10-13 01:21:02.251926-05	\N	2025-10-13 06:21:00	00:15:00	2025-10-13 01:20:02.23255-05	2025-10-13 01:21:02.263592-05	2025-10-13 01:22:01.23255-05	f	\N	2025-10-13 13:30:36.267932-05
bdf0f442-4c50-4250-9466-580bc205db82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:22:01.261826-05	2025-10-13 01:22:02.28023-05	\N	2025-10-13 06:22:00	00:15:00	2025-10-13 01:21:02.261826-05	2025-10-13 01:22:02.28882-05	2025-10-13 01:23:01.261826-05	f	\N	2025-10-13 13:30:36.267932-05
a6843528-cce5-4765-b7c2-2b3494be9cd1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:23:01.28753-05	2025-10-13 01:23:02.314027-05	\N	2025-10-13 06:23:00	00:15:00	2025-10-13 01:22:02.28753-05	2025-10-13 01:23:02.327465-05	2025-10-13 01:24:01.28753-05	f	\N	2025-10-13 13:30:36.267932-05
7486be7a-c62a-4bc2-ac54-3c0ca0e72d97	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:24:01.324274-05	2025-10-13 01:24:02.342299-05	\N	2025-10-13 06:24:00	00:15:00	2025-10-13 01:23:02.324274-05	2025-10-13 01:24:02.353844-05	2025-10-13 01:25:01.324274-05	f	\N	2025-10-13 13:30:36.267932-05
bb423776-e072-4049-8472-a923bca2b3f8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:23:35.271538-05	2025-10-13 01:24:35.269321-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:21:35.271538-05	2025-10-13 01:24:35.275704-05	2025-10-13 01:31:35.271538-05	f	\N	2025-10-13 13:30:36.267932-05
041722f2-fe78-415c-9b1b-c101588980e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:25:01.352296-05	2025-10-13 01:25:02.373981-05	\N	2025-10-13 06:25:00	00:15:00	2025-10-13 01:24:02.352296-05	2025-10-13 01:25:02.38591-05	2025-10-13 01:26:01.352296-05	f	\N	2025-10-13 13:30:36.267932-05
ead48b9c-d0cd-4b27-9f45-b99e65a74103	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:26:01.383988-05	2025-10-13 01:26:02.400808-05	\N	2025-10-13 06:26:00	00:15:00	2025-10-13 01:25:02.383988-05	2025-10-13 01:26:02.409782-05	2025-10-13 01:27:01.383988-05	f	\N	2025-10-13 13:30:36.267932-05
a64fb34e-74df-4193-af75-66ca4d476dd5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:26:35.277273-05	2025-10-13 01:27:35.272843-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:24:35.277273-05	2025-10-13 01:27:35.276653-05	2025-10-13 01:34:35.277273-05	f	\N	2025-10-13 13:30:36.267932-05
48004b28-9594-4424-b89b-f8a089459804	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:30:01.489805-05	2025-10-13 01:30:02.513544-05	\N	2025-10-13 06:30:00	00:15:00	2025-10-13 01:29:02.489805-05	2025-10-13 01:30:02.524047-05	2025-10-13 01:31:01.489805-05	f	\N	2025-10-13 13:30:36.267932-05
bc03b83c-0dba-4250-a79e-83e65f2d4765	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:27:01.408333-05	2025-10-13 01:27:02.4315-05	\N	2025-10-13 06:27:00	00:15:00	2025-10-13 01:26:02.408333-05	2025-10-13 01:27:02.440586-05	2025-10-13 01:28:01.408333-05	f	\N	2025-10-13 13:30:36.267932-05
c34b0ecc-02d8-4e2f-a4e7-da299640ac2d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:28:01.439044-05	2025-10-13 01:28:02.458973-05	\N	2025-10-13 06:28:00	00:15:00	2025-10-13 01:27:02.439044-05	2025-10-13 01:28:02.466736-05	2025-10-13 01:29:01.439044-05	f	\N	2025-10-13 13:30:36.267932-05
f8270d6b-638d-4889-bbf7-4bd0c5c694d2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:29:01.465499-05	2025-10-13 01:29:02.486556-05	\N	2025-10-13 06:29:00	00:15:00	2025-10-13 01:28:02.465499-05	2025-10-13 01:29:02.49036-05	2025-10-13 01:30:01.465499-05	f	\N	2025-10-13 13:30:36.267932-05
eb71a471-e58d-40a5-b371-458ff727daf9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:29:35.277657-05	2025-10-13 01:30:35.251064-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:27:35.277657-05	2025-10-13 01:30:35.259208-05	2025-10-13 01:37:35.277657-05	f	\N	2025-10-13 13:30:36.267932-05
442e9dd9-655d-4125-b5de-a1348cdf624c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:20:35.268652-05	2025-10-13 01:21:35.264446-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:18:35.268652-05	2025-10-13 01:21:35.270131-05	2025-10-13 01:28:35.268652-05	f	\N	2025-10-13 13:30:36.267932-05
ae1d1938-f030-4724-8c96-a1cbf2e34ca0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:30:35.540263-05	2025-10-13 04:31:35.526889-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:28:35.540263-05	2025-10-13 04:31:35.531078-05	2025-10-13 04:38:35.540263-05	f	\N	2025-10-13 16:34:28.528717-05
a55b6252-c430-4f2c-89b1-8160131b4f4a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:32:01.450451-05	2025-10-13 04:32:03.469611-05	\N	2025-10-13 09:32:00	00:15:00	2025-10-13 04:31:03.450451-05	2025-10-13 04:32:03.476662-05	2025-10-13 04:33:01.450451-05	f	\N	2025-10-13 16:34:28.528717-05
62c056f1-f588-40cc-92b0-bf8a5f5e00b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:33:01.475694-05	2025-10-13 04:33:03.497013-05	\N	2025-10-13 09:33:00	00:15:00	2025-10-13 04:32:03.475694-05	2025-10-13 04:33:03.507398-05	2025-10-13 04:34:01.475694-05	f	\N	2025-10-13 16:34:28.528717-05
25402ccd-6534-4a04-9d0e-eaa1e41152a0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:34:01.505666-05	2025-10-13 04:34:03.525539-05	\N	2025-10-13 09:34:00	00:15:00	2025-10-13 04:33:03.505666-05	2025-10-13 04:34:03.537329-05	2025-10-13 04:35:01.505666-05	f	\N	2025-10-13 16:34:28.528717-05
b444ebc7-7e5d-4d03-ad4a-14f3526175f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:05:01.720523-05	2025-10-13 04:05:02.726562-05	\N	2025-10-13 09:05:00	00:15:00	2025-10-13 04:04:02.720523-05	2025-10-13 04:05:02.734934-05	2025-10-13 04:06:01.720523-05	f	\N	2025-10-13 16:34:28.528717-05
f2a70622-4df4-47db-bd70-a11cb8861965	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:06:35.524833-05	2025-10-13 04:07:35.504429-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:04:35.524833-05	2025-10-13 04:07:35.512152-05	2025-10-13 04:14:35.524833-05	f	\N	2025-10-13 16:34:28.528717-05
68306e5a-b35a-4300-89ba-72858a414c15	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:10:01.84547-05	2025-10-13 04:10:02.86901-05	\N	2025-10-13 09:10:00	00:15:00	2025-10-13 04:09:02.84547-05	2025-10-13 04:10:02.877363-05	2025-10-13 04:11:01.84547-05	f	\N	2025-10-13 16:34:28.528717-05
32057967-5731-4676-8e4f-a5109c1d4591	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:09:35.513805-05	2025-10-13 04:10:35.510312-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:07:35.513805-05	2025-10-13 04:10:35.517911-05	2025-10-13 04:17:35.513805-05	f	\N	2025-10-13 16:34:28.528717-05
415cbebe-15d9-4be4-9fc5-8cfcbcb6fab8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:12:01.902929-05	2025-10-13 04:12:02.923406-05	\N	2025-10-13 09:12:00	00:15:00	2025-10-13 04:11:02.902929-05	2025-10-13 04:12:02.933515-05	2025-10-13 04:13:01.902929-05	f	\N	2025-10-13 16:34:28.528717-05
f6976a4b-eb64-48b5-b762-e5d6fabe505b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:14:01.958024-05	2025-10-13 04:14:02.981659-05	\N	2025-10-13 09:14:00	00:15:00	2025-10-13 04:13:02.958024-05	2025-10-13 04:14:02.991522-05	2025-10-13 04:15:01.958024-05	f	\N	2025-10-13 16:34:28.528717-05
f4760efb-d5c0-4456-b0fb-ae0945237ee2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:15:01.989859-05	2025-10-13 04:15:03.008465-05	\N	2025-10-13 09:15:00	00:15:00	2025-10-13 04:14:02.989859-05	2025-10-13 04:15:03.015144-05	2025-10-13 04:16:01.989859-05	f	\N	2025-10-13 16:34:28.528717-05
50de9879-f30c-430a-909f-e50f9cd15e86	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:15:35.521805-05	2025-10-13 04:16:35.516347-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:13:35.521805-05	2025-10-13 04:16:35.524857-05	2025-10-13 04:23:35.521805-05	f	\N	2025-10-13 16:34:28.528717-05
7af05d39-9b72-4e59-85d7-59e3cdd3af20	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:18:01.070187-05	2025-10-13 04:18:03.08993-05	\N	2025-10-13 09:18:00	00:15:00	2025-10-13 04:17:03.070187-05	2025-10-13 04:18:03.099234-05	2025-10-13 04:19:01.070187-05	f	\N	2025-10-13 16:34:28.528717-05
b385e312-05b9-4d23-a94d-35d1c1c53278	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:18:35.526738-05	2025-10-13 04:19:35.520509-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:16:35.526738-05	2025-10-13 04:19:35.527559-05	2025-10-13 04:26:35.526738-05	f	\N	2025-10-13 16:34:28.528717-05
d6e2f016-1266-4eed-9abf-4d6a5df6478e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:24:35.534806-05	2025-10-13 04:25:35.529798-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:22:35.534806-05	2025-10-13 04:25:35.534117-05	2025-10-13 04:32:35.534806-05	f	\N	2025-10-13 16:34:28.528717-05
c0d6cefb-6a43-43b9-96f1-3a34fbcd74cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:26:01.291361-05	2025-10-13 04:26:03.308163-05	\N	2025-10-13 09:26:00	00:15:00	2025-10-13 04:25:03.291361-05	2025-10-13 04:26:03.319168-05	2025-10-13 04:27:01.291361-05	f	\N	2025-10-13 16:34:28.528717-05
a1f8bcf0-591b-4c16-9cee-e6d0ceb7438c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:27:01.317527-05	2025-10-13 04:27:03.328867-05	\N	2025-10-13 09:27:00	00:15:00	2025-10-13 04:26:03.317527-05	2025-10-13 04:27:03.334294-05	2025-10-13 04:28:01.317527-05	f	\N	2025-10-13 16:34:28.528717-05
0eae11af-7667-4646-89cd-6f129993109d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:27:35.535398-05	2025-10-13 04:28:35.530964-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:25:35.535398-05	2025-10-13 04:28:35.538286-05	2025-10-13 04:35:35.535398-05	f	\N	2025-10-13 16:34:28.528717-05
c5983902-c0e1-41ca-b2c3-d91fdb8536a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:30:01.396519-05	2025-10-13 04:30:03.416321-05	\N	2025-10-13 09:30:00	00:15:00	2025-10-13 04:29:03.396519-05	2025-10-13 04:30:03.424089-05	2025-10-13 04:31:01.396519-05	f	\N	2025-10-13 16:34:28.528717-05
06556bf6-e4c1-4137-8a7a-a32829b3cf6c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:06:01.733732-05	2025-10-13 04:06:02.748294-05	\N	2025-10-13 09:06:00	00:15:00	2025-10-13 04:05:02.733732-05	2025-10-13 04:06:02.758961-05	2025-10-13 04:07:01.733732-05	f	\N	2025-10-13 16:34:28.528717-05
4a2867a3-28e8-4031-b65c-b66b7caaeef4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:07:01.757217-05	2025-10-13 04:07:02.777233-05	\N	2025-10-13 09:07:00	00:15:00	2025-10-13 04:06:02.757217-05	2025-10-13 04:07:02.786988-05	2025-10-13 04:08:01.757217-05	f	\N	2025-10-13 16:34:28.528717-05
7c19e56c-5fc2-464a-92c0-9b6e96ec0e46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:08:01.785106-05	2025-10-13 04:08:02.807218-05	\N	2025-10-13 09:08:00	00:15:00	2025-10-13 04:07:02.785106-05	2025-10-13 04:08:02.815327-05	2025-10-13 04:09:01.785106-05	f	\N	2025-10-13 16:34:28.528717-05
60661d87-f890-4032-9630-07b85cde8005	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:09:01.814061-05	2025-10-13 04:09:02.838825-05	\N	2025-10-13 09:09:00	00:15:00	2025-10-13 04:08:02.814061-05	2025-10-13 04:09:02.846547-05	2025-10-13 04:10:01.814061-05	f	\N	2025-10-13 16:34:28.528717-05
387935a4-64ef-460a-8d32-5046514aec82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:11:01.876116-05	2025-10-13 04:11:02.894912-05	\N	2025-10-13 09:11:00	00:15:00	2025-10-13 04:10:02.876116-05	2025-10-13 04:11:02.904159-05	2025-10-13 04:12:01.876116-05	f	\N	2025-10-13 16:34:28.528717-05
ce6a599f-745c-40b9-93e8-1ff908066ffd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:13:01.931657-05	2025-10-13 04:13:02.950449-05	\N	2025-10-13 09:13:00	00:15:00	2025-10-13 04:12:02.931657-05	2025-10-13 04:13:02.959183-05	2025-10-13 04:14:01.931657-05	f	\N	2025-10-13 16:34:28.528717-05
ca10db8e-9114-42a9-9dd2-b26b3fd624e3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:12:35.519569-05	2025-10-13 04:13:35.513312-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:10:35.519569-05	2025-10-13 04:13:35.520409-05	2025-10-13 04:20:35.519569-05	f	\N	2025-10-13 16:34:28.528717-05
882f0e7f-f54b-40ea-a078-fab4be717a9c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:44:01.031369-05	2025-10-12 11:44:02.035202-05	\N	2025-10-12 16:44:00	00:15:00	2025-10-12 11:43:18.031369-05	2025-10-12 11:44:02.043584-05	2025-10-12 11:45:01.031369-05	f	\N	2025-10-12 23:46:35.119485-05
eb12f254-9df1-445b-891a-bb2ac4946699	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:43:14.078316-05	2025-10-12 11:44:14.024743-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:43:14.078316-05	2025-10-12 11:44:14.032356-05	2025-10-12 11:51:14.078316-05	f	\N	2025-10-12 23:46:35.119485-05
018daad7-a183-42a7-b534-8fef3830c64a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:44:59.151332-05	2025-10-12 11:44:59.154245-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:44:59.151332-05	2025-10-12 11:44:59.161807-05	2025-10-12 11:52:59.151332-05	f	\N	2025-10-12 23:46:35.119485-05
53e5aab0-75ab-4566-b96c-cfc028864a3b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:46:01.184712-05	2025-10-12 11:46:03.180231-05	\N	2025-10-12 16:46:00	00:15:00	2025-10-12 11:45:03.184712-05	2025-10-12 11:46:03.197273-05	2025-10-12 11:47:01.184712-05	f	\N	2025-10-12 23:46:35.119485-05
79f86079-9fb9-4775-b278-8b5b53ceaf8d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:45:01.042253-05	2025-10-12 11:45:03.162636-05	\N	2025-10-12 16:45:00	00:15:00	2025-10-12 11:44:02.042253-05	2025-10-12 11:45:03.185597-05	2025-10-12 11:46:01.042253-05	f	\N	2025-10-12 23:46:35.119485-05
1f59b0ea-5881-4908-a8ad-f9f1e88143f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:50:01.253787-05	2025-10-12 11:50:03.267648-05	\N	2025-10-12 16:50:00	00:15:00	2025-10-12 11:49:03.253787-05	2025-10-12 11:50:03.282625-05	2025-10-12 11:51:01.253787-05	f	\N	2025-10-12 23:52:35.129118-05
cfa5ef89-b902-4ddf-8961-1c578d2c35a9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:52:01.292418-05	2025-10-12 11:52:03.292905-05	\N	2025-10-12 16:52:00	00:15:00	2025-10-12 11:51:03.292418-05	2025-10-12 11:52:03.305509-05	2025-10-12 11:53:01.292418-05	f	\N	2025-10-12 23:52:35.129118-05
e1f92aa0-f0a1-42da-b417-b179b176966e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:49:59.167425-05	2025-10-12 11:50:59.157329-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:47:59.167425-05	2025-10-12 11:50:59.162239-05	2025-10-12 11:57:59.167425-05	f	\N	2025-10-12 23:52:35.129118-05
7c26aa99-eb9a-4178-9f9f-83264a833b53	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:51:01.280612-05	2025-10-12 11:51:03.280844-05	\N	2025-10-12 16:51:00	00:15:00	2025-10-12 11:50:03.280612-05	2025-10-12 11:51:03.29303-05	2025-10-12 11:52:01.280612-05	f	\N	2025-10-12 23:52:35.129118-05
0f75ea8b-37de-4737-8699-c3efcd367223	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:31:01.522483-05	2025-10-13 01:31:02.507695-05	\N	2025-10-13 06:31:00	00:15:00	2025-10-13 01:30:02.522483-05	2025-10-13 01:31:02.5142-05	2025-10-13 01:32:01.522483-05	f	\N	2025-10-13 13:31:36.234184-05
3b58a6c1-cdbc-4c4f-9e8e-88cd15a3bd13	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:33:35.532133-05	2025-10-13 04:34:35.529741-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:31:35.532133-05	2025-10-13 04:34:35.536945-05	2025-10-13 04:41:35.532133-05	f	\N	2025-10-13 16:40:19.621382-05
846e0e23-8348-441d-bf51-88aaa4b7bc30	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:35:01.53585-05	2025-10-13 04:35:03.552167-05	\N	2025-10-13 09:35:00	00:15:00	2025-10-13 04:34:03.53585-05	2025-10-13 04:35:03.562849-05	2025-10-13 04:36:01.53585-05	f	\N	2025-10-13 16:40:19.621382-05
e756752d-3748-4a5d-80d5-6efb86a946eb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:36:35.538293-05	2025-10-13 04:37:35.53226-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:34:35.538293-05	2025-10-13 04:37:35.540223-05	2025-10-13 04:44:35.538293-05	f	\N	2025-10-13 16:40:19.621382-05
7a5794b3-f4a8-4388-82fd-2282d10a7faa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:36:01.561033-05	2025-10-13 04:36:03.579502-05	\N	2025-10-13 09:36:00	00:15:00	2025-10-13 04:35:03.561033-05	2025-10-13 04:36:03.585939-05	2025-10-13 04:37:01.561033-05	f	\N	2025-10-13 16:40:19.621382-05
70c39214-49cd-45d1-bb71-5e47b8a89d32	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:37:01.584837-05	2025-10-13 04:37:03.600378-05	\N	2025-10-13 09:37:00	00:15:00	2025-10-13 04:36:03.584837-05	2025-10-13 04:37:03.608687-05	2025-10-13 04:38:01.584837-05	f	\N	2025-10-13 16:40:19.621382-05
07f51c59-17e0-42c1-94d3-b42aba286479	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:38:01.607437-05	2025-10-13 04:38:03.623728-05	\N	2025-10-13 09:38:00	00:15:00	2025-10-13 04:37:03.607437-05	2025-10-13 04:38:03.635577-05	2025-10-13 04:39:01.607437-05	f	\N	2025-10-13 16:40:19.621382-05
3bf9f656-8ffd-4270-9199-2287fde6d291	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:39:01.633948-05	2025-10-13 04:39:03.649787-05	\N	2025-10-13 09:39:00	00:15:00	2025-10-13 04:38:03.633948-05	2025-10-13 04:39:03.661092-05	2025-10-13 04:40:01.633948-05	f	\N	2025-10-13 16:40:19.621382-05
e5aaf88d-bbbd-457e-b436-854f5224a10c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:40:01.659551-05	2025-10-13 04:40:03.675733-05	\N	2025-10-13 09:40:00	00:15:00	2025-10-13 04:39:03.659551-05	2025-10-13 04:40:03.687001-05	2025-10-13 04:41:01.659551-05	f	\N	2025-10-13 16:40:19.621382-05
d237943c-0616-4fe6-aa88-bbb8ec7a853e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:56:01.355115-05	2025-10-12 11:56:03.356867-05	\N	2025-10-12 16:56:00	00:15:00	2025-10-12 11:55:03.355115-05	2025-10-12 11:56:03.369253-05	2025-10-12 11:57:01.355115-05	f	\N	2025-10-12 23:58:35.139433-05
36923a9c-71a8-4a06-8e44-9b2e6a246e83	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:55:59.163262-05	2025-10-12 11:56:59.158776-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:53:59.163262-05	2025-10-12 11:56:59.164799-05	2025-10-12 12:03:59.163262-05	f	\N	2025-10-12 23:58:35.139433-05
f5547102-b00f-4d9a-98e9-410a4fa8d54e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:57:01.368412-05	2025-10-12 11:57:03.369925-05	\N	2025-10-12 16:57:00	00:15:00	2025-10-12 11:56:03.368412-05	2025-10-12 11:57:03.383056-05	2025-10-12 11:58:01.368412-05	f	\N	2025-10-12 23:58:35.139433-05
cb58efb0-c5a6-4394-b31f-186001c86203	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:58:01.381858-05	2025-10-12 11:58:03.382134-05	\N	2025-10-12 16:58:00	00:15:00	2025-10-12 11:57:03.381858-05	2025-10-12 11:58:03.397075-05	2025-10-12 11:59:01.381858-05	f	\N	2025-10-12 23:58:35.139433-05
f362e151-707f-4da4-aef1-061cff8e1f91	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 11:58:59.166465-05	2025-10-12 11:59:59.161044-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 11:56:59.166465-05	2025-10-12 11:59:59.168806-05	2025-10-12 12:06:59.166465-05	f	\N	2025-10-13 00:01:35.153708-05
59b999a0-69fe-4ff8-a919-09dafda3bbbb	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 12:00:07.409433-05	2025-10-12 12:00:07.716021-05	\N	\N	00:15:00	2025-10-12 12:00:07.409433-05	2025-10-12 12:00:08.124931-05	2025-10-26 12:00:07.409433-05	f	\N	2025-10-13 00:01:35.153708-05
2d4077c9-e97c-4f2a-a614-e10836716d63	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 11:59:01.395813-05	2025-10-12 11:59:03.392812-05	\N	2025-10-12 16:59:00	00:15:00	2025-10-12 11:58:03.395813-05	2025-10-12 11:59:03.404692-05	2025-10-12 12:00:01.395813-05	f	\N	2025-10-13 00:01:35.153708-05
5368f617-91de-4ed6-a1ee-75208097046e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:00:01.403839-05	2025-10-12 12:00:03.406671-05	\N	2025-10-12 17:00:00	00:15:00	2025-10-12 11:59:03.403839-05	2025-10-12 12:00:03.415449-05	2025-10-12 12:01:01.403839-05	f	\N	2025-10-13 00:01:35.153708-05
dbc01491-c763-487a-b58d-2cc9fe10d1f8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:01:01.414051-05	2025-10-12 12:01:03.421909-05	\N	2025-10-12 17:01:00	00:15:00	2025-10-12 12:00:03.414051-05	2025-10-12 12:01:03.435522-05	2025-10-12 12:02:01.414051-05	f	\N	2025-10-13 00:01:35.153708-05
ce90b44b-7d78-4853-bf10-85f77bb75680	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T16:44:59.179Z"}	completed	0	0	0	f	2025-10-12 12:00:03.410734-05	2025-10-12 12:00:07.406732-05	dailyStatsJob	2025-10-12 17:00:00	00:15:00	2025-10-12 12:00:03.410734-05	2025-10-12 12:00:07.411004-05	2025-10-26 12:00:03.410734-05	f	\N	2025-10-13 00:01:35.153708-05
c00c400a-7721-4b9f-aba0-daeb7c9b7973	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:04:59.170295-05	2025-10-12 12:05:59.181236-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:02:59.170295-05	2025-10-12 12:05:59.186439-05	2025-10-12 12:12:59.170295-05	f	\N	2025-10-13 00:06:35.165814-05
afbef8ee-62d8-4d63-93ab-a8aef72dde77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:04:01.45616-05	2025-10-12 12:04:03.462873-05	\N	2025-10-12 17:04:00	00:15:00	2025-10-12 12:03:03.45616-05	2025-10-12 12:04:03.470722-05	2025-10-12 12:05:01.45616-05	f	\N	2025-10-13 00:06:35.165814-05
d84fd4a4-cd81-438f-a234-9f121312da07	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:05:01.46952-05	2025-10-12 12:05:03.475176-05	\N	2025-10-12 17:05:00	00:15:00	2025-10-12 12:04:03.46952-05	2025-10-12 12:05:03.482902-05	2025-10-12 12:06:01.46952-05	f	\N	2025-10-13 00:06:35.165814-05
f1534f94-360b-4d85-9640-1d2fc640abb8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:06:01.481949-05	2025-10-12 12:06:03.510027-05	\N	2025-10-12 17:06:00	00:15:00	2025-10-12 12:05:03.481949-05	2025-10-12 12:06:03.518716-05	2025-10-12 12:07:01.481949-05	f	\N	2025-10-13 00:06:35.165814-05
9782b112-5765-4a4f-bf89-cc8a90b0ca96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:07:01.517472-05	2025-10-12 12:07:03.532211-05	\N	2025-10-12 17:07:00	00:15:00	2025-10-12 12:06:03.517472-05	2025-10-12 12:07:03.540329-05	2025-10-12 12:08:01.517472-05	f	\N	2025-10-13 00:09:35.170173-05
317c77d3-6b99-4b10-9acb-1ef743f243fe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:07:59.188025-05	2025-10-12 12:07:59.193807-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:05:59.188025-05	2025-10-12 12:07:59.200901-05	2025-10-12 12:15:59.188025-05	f	\N	2025-10-13 00:09:35.170173-05
b2956c71-89c1-4e16-8800-7b5823546a86	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:08:01.539411-05	2025-10-12 12:08:03.545208-05	\N	2025-10-12 17:08:00	00:15:00	2025-10-12 12:07:03.539411-05	2025-10-12 12:08:03.553765-05	2025-10-12 12:09:01.539411-05	f	\N	2025-10-13 00:09:35.170173-05
e5615900-8f15-4b4b-8949-e5bff079ea82	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:09:01.552958-05	2025-10-12 12:09:03.56211-05	\N	2025-10-12 17:09:00	00:15:00	2025-10-12 12:08:03.552958-05	2025-10-12 12:09:03.572644-05	2025-10-12 12:10:01.552958-05	f	\N	2025-10-13 00:09:35.170173-05
e57927f4-b442-4a49-99f2-a4fd85a3fef3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:10:01.571353-05	2025-10-12 12:10:03.580907-05	\N	2025-10-12 17:10:00	00:15:00	2025-10-12 12:09:03.571353-05	2025-10-12 12:10:03.587138-05	2025-10-12 12:11:01.571353-05	f	\N	2025-10-13 00:12:35.175916-05
13a40e25-d2d9-4226-9baa-e27aa34831ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:12:01.608438-05	2025-10-12 12:12:03.609375-05	\N	2025-10-12 17:12:00	00:15:00	2025-10-12 12:11:03.608438-05	2025-10-12 12:12:03.621992-05	2025-10-12 12:13:01.608438-05	f	\N	2025-10-13 00:12:35.175916-05
8269ba12-b745-42de-b3b8-26b17ad475ba	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:09:59.202803-05	2025-10-12 12:10:59.195102-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:07:59.202803-05	2025-10-12 12:10:59.201736-05	2025-10-12 12:17:59.202803-05	f	\N	2025-10-13 00:12:35.175916-05
d3b3e9d2-1ce4-428f-a5df-9f8d720a43b8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:11:01.585814-05	2025-10-12 12:11:03.59537-05	\N	2025-10-12 17:11:00	00:15:00	2025-10-12 12:10:03.585814-05	2025-10-12 12:11:03.609676-05	2025-10-12 12:12:01.585814-05	f	\N	2025-10-13 00:12:35.175916-05
04ea4461-4bac-46b3-8ac1-f6bf8483e783	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:13:01.620588-05	2025-10-12 12:13:03.620955-05	\N	2025-10-12 17:13:00	00:15:00	2025-10-12 12:12:03.620588-05	2025-10-12 12:13:03.628048-05	2025-10-12 12:14:01.620588-05	f	\N	2025-10-13 00:15:35.179251-05
e7a14f5f-0bed-4573-8a7f-db4531f9498f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:14:01.627073-05	2025-10-12 12:14:03.634829-05	\N	2025-10-12 17:14:00	00:15:00	2025-10-12 12:13:03.627073-05	2025-10-12 12:14:03.643561-05	2025-10-12 12:15:01.627073-05	f	\N	2025-10-13 00:15:35.179251-05
f6e68f54-d2e2-41be-8210-3e172cb7ac51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:15:01.642851-05	2025-10-12 12:15:03.652083-05	\N	2025-10-12 17:15:00	00:15:00	2025-10-12 12:14:03.642851-05	2025-10-12 12:15:03.660144-05	2025-10-12 12:16:01.642851-05	f	\N	2025-10-13 00:15:35.179251-05
dda45b99-b859-4f0e-ab40-b69a5f985ae7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:12:59.203526-05	2025-10-12 12:13:59.197776-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:10:59.203526-05	2025-10-12 12:13:59.204203-05	2025-10-12 12:20:59.203526-05	f	\N	2025-10-13 00:15:35.179251-05
752795f3-8382-4b2e-b1a4-09864c313ebe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:19:01.697845-05	2025-10-12 12:19:04.08995-05	\N	2025-10-12 17:19:00	00:15:00	2025-10-12 12:18:03.697845-05	2025-10-12 12:19:04.116918-05	2025-10-12 12:20:01.697845-05	f	\N	2025-10-13 00:20:35.193425-05
dd61c833-644e-4436-b366-72357fbe1f83	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:18:36.072893-05	2025-10-12 12:18:36.076806-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:18:36.072893-05	2025-10-12 12:18:36.08157-05	2025-10-12 12:26:36.072893-05	f	\N	2025-10-13 00:20:35.193425-05
8820b07c-e930-44cd-b942-45c2477a2fad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:20:01.115178-05	2025-10-12 12:20:04.104905-05	\N	2025-10-12 17:20:00	00:15:00	2025-10-12 12:19:04.115178-05	2025-10-12 12:20:04.118432-05	2025-10-12 12:21:01.115178-05	f	\N	2025-10-13 00:20:35.193425-05
4abcefcf-113b-4234-b7ba-e723d337fd87	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:21:01.116723-05	2025-10-12 12:21:04.119627-05	\N	2025-10-12 17:21:00	00:15:00	2025-10-12 12:20:04.116723-05	2025-10-12 12:21:04.128416-05	2025-10-12 12:22:01.116723-05	f	\N	2025-10-13 00:23:35.201495-05
5d2ed727-ea41-4383-a4d5-13c0ecd7a675	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:20:36.082575-05	2025-10-12 12:21:36.080358-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:18:36.082575-05	2025-10-12 12:21:36.085431-05	2025-10-12 12:28:36.082575-05	f	\N	2025-10-13 00:23:35.201495-05
8dba34dd-29cc-4766-8851-828bf444e892	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:22:01.127461-05	2025-10-12 12:22:04.134086-05	\N	2025-10-12 17:22:00	00:15:00	2025-10-12 12:21:04.127461-05	2025-10-12 12:22:04.14836-05	2025-10-12 12:23:01.127461-05	f	\N	2025-10-13 00:23:35.201495-05
a7f0ad96-5b5a-4627-b25d-8ac36b20c3d2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:23:01.147531-05	2025-10-12 12:23:04.148517-05	\N	2025-10-12 17:23:00	00:15:00	2025-10-12 12:22:04.147531-05	2025-10-12 12:23:04.162341-05	2025-10-12 12:24:01.147531-05	f	\N	2025-10-13 00:23:35.201495-05
0bc6a783-d179-4668-9969-f2f80ae3b0e0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:33:01.539344-05	2025-10-13 01:33:02.560476-05	\N	2025-10-13 06:33:00	00:15:00	2025-10-13 01:32:02.539344-05	2025-10-13 01:33:02.568325-05	2025-10-13 01:34:01.539344-05	f	\N	2025-10-13 13:49:37.173678-05
e79aac32-bd9a-4702-9c27-68749523a84e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:32:35.26123-05	2025-10-13 01:33:35.250569-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:30:35.26123-05	2025-10-13 01:33:35.255149-05	2025-10-13 01:40:35.26123-05	f	\N	2025-10-13 13:49:37.173678-05
b23540c6-2b16-4e2f-bea0-ace4674497f2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:35:35.256419-05	2025-10-13 01:36:35.255853-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:33:35.256419-05	2025-10-13 01:36:35.262177-05	2025-10-13 01:43:35.256419-05	f	\N	2025-10-13 13:49:37.173678-05
1e644a66-5eda-43d2-aa5d-affa99031bf9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:39:01.717396-05	2025-10-13 01:39:02.736015-05	\N	2025-10-13 06:39:00	00:15:00	2025-10-13 01:38:02.717396-05	2025-10-13 01:39:02.747983-05	2025-10-13 01:40:01.717396-05	f	\N	2025-10-13 13:49:37.173678-05
a0ef1631-9743-4721-a7d3-cf0d75c8092b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:32:01.51319-05	2025-10-13 01:32:02.534023-05	\N	2025-10-13 06:32:00	00:15:00	2025-10-13 01:31:02.51319-05	2025-10-13 01:32:02.540561-05	2025-10-13 01:33:01.51319-05	f	\N	2025-10-13 13:49:37.173678-05
0b9061c4-5e6f-4c60-8b30-0a4953e4e753	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:35:01.595083-05	2025-10-13 01:35:02.609312-05	\N	2025-10-13 06:35:00	00:15:00	2025-10-13 01:34:02.595083-05	2025-10-13 01:35:02.618484-05	2025-10-13 01:36:01.595083-05	f	\N	2025-10-13 13:49:37.173678-05
8660412c-8295-46a6-a9c2-18981909824b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:34:01.567418-05	2025-10-13 01:34:02.587796-05	\N	2025-10-13 06:34:00	00:15:00	2025-10-13 01:33:02.567418-05	2025-10-13 01:34:02.596901-05	2025-10-13 01:35:01.567418-05	f	\N	2025-10-13 13:49:37.173678-05
a96db382-7295-4d5c-bf29-7408f5090b13	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:36:01.617143-05	2025-10-13 01:36:02.640201-05	\N	2025-10-13 06:36:00	00:15:00	2025-10-13 01:35:02.617143-05	2025-10-13 01:36:02.649119-05	2025-10-13 01:37:01.617143-05	f	\N	2025-10-13 13:49:37.173678-05
5872c8f0-5fe8-4b96-8f0e-a0bafecaf3cc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:37:01.64775-05	2025-10-13 01:37:02.676251-05	\N	2025-10-13 06:37:00	00:15:00	2025-10-13 01:36:02.64775-05	2025-10-13 01:37:02.688178-05	2025-10-13 01:38:01.64775-05	f	\N	2025-10-13 13:49:37.173678-05
b08807a6-e8ee-48c2-90d6-720fcd62784c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:38:01.686577-05	2025-10-13 01:38:02.706995-05	\N	2025-10-13 06:38:00	00:15:00	2025-10-13 01:37:02.686577-05	2025-10-13 01:38:02.719212-05	2025-10-13 01:39:01.686577-05	f	\N	2025-10-13 13:49:37.173678-05
35cc5686-51cb-4ef6-913a-a7fa0eae1f93	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:38:35.263518-05	2025-10-13 01:39:35.258158-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:36:35.263518-05	2025-10-13 01:39:35.26441-05	2025-10-13 01:46:35.263518-05	f	\N	2025-10-13 13:49:37.173678-05
bfc3b266-5d26-4c70-88a7-b55b28d915e0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:24:01.160965-05	2025-10-12 12:24:04.172873-05	\N	2025-10-12 17:24:00	00:15:00	2025-10-12 12:23:04.160965-05	2025-10-12 12:24:04.185107-05	2025-10-12 12:25:01.160965-05	f	\N	2025-10-13 00:26:35.206683-05
88b366e0-0061-4b2b-b743-da8e8b67af4c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:23:36.086918-05	2025-10-12 12:24:36.083899-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:21:36.086918-05	2025-10-12 12:24:36.094019-05	2025-10-12 12:31:36.086918-05	f	\N	2025-10-13 00:26:35.206683-05
d0fa8b64-c916-47ee-92c8-e952e04e75bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:25:01.183716-05	2025-10-12 12:25:04.187416-05	\N	2025-10-12 17:25:00	00:15:00	2025-10-12 12:24:04.183716-05	2025-10-12 12:25:04.201141-05	2025-10-12 12:26:01.183716-05	f	\N	2025-10-13 00:26:35.206683-05
35f5ea87-c80b-4d9d-83cc-bc3591c2b1ed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:26:01.199753-05	2025-10-12 12:26:04.205419-05	\N	2025-10-12 17:26:00	00:15:00	2025-10-12 12:25:04.199753-05	2025-10-12 12:26:04.218973-05	2025-10-12 12:27:01.199753-05	f	\N	2025-10-13 00:26:35.206683-05
47aae7ec-cbd1-4902-9e83-9323f66fd4e1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:29:22.879043-05	2025-10-12 12:29:22.881801-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:29:22.879043-05	2025-10-12 12:29:22.889258-05	2025-10-12 12:37:22.879043-05	f	\N	2025-10-13 00:29:35.211637-05
397de0a8-fb9c-4ddb-b11e-132c3a3a8811	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:29:01.236331-05	2025-10-12 12:29:04.245882-05	\N	2025-10-12 17:29:00	00:15:00	2025-10-12 12:28:04.236331-05	2025-10-12 12:29:04.263436-05	2025-10-12 12:30:01.236331-05	f	\N	2025-10-13 00:29:35.211637-05
277d3ddd-421f-4380-961d-52fa0a425e3c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:27:01.218157-05	2025-10-12 12:27:04.219841-05	\N	2025-10-12 17:27:00	00:15:00	2025-10-12 12:26:04.218157-05	2025-10-12 12:27:04.234096-05	2025-10-12 12:28:01.218157-05	f	\N	2025-10-13 00:29:35.211637-05
4dce3762-6c25-4cff-8fc8-f2311a415ac6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:26:36.09578-05	2025-10-12 12:27:36.088642-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:24:36.09578-05	2025-10-12 12:27:36.097336-05	2025-10-12 12:34:36.09578-05	f	\N	2025-10-13 00:29:35.211637-05
0177ee80-1e94-40db-828a-c9e810e3cac3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:28:01.232367-05	2025-10-12 12:28:04.231858-05	\N	2025-10-12 17:28:00	00:15:00	2025-10-12 12:27:04.232367-05	2025-10-12 12:28:04.237442-05	2025-10-12 12:29:01.232367-05	f	\N	2025-10-13 00:29:35.211637-05
f6219e3a-79c3-4a37-ba5b-4593fc1d1994	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:30:01.261529-05	2025-10-12 12:30:02.898122-05	\N	2025-10-12 17:30:00	00:15:00	2025-10-12 12:29:04.261529-05	2025-10-12 12:30:02.920668-05	2025-10-12 12:31:01.261529-05	f	\N	2025-10-13 00:32:35.217492-05
8a1bfb9f-e3ec-4454-b138-3077b80b62aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:31:01.91932-05	2025-10-12 12:31:04.104776-05	\N	2025-10-12 17:31:00	00:15:00	2025-10-12 12:30:02.91932-05	2025-10-12 12:31:04.117837-05	2025-10-12 12:32:01.91932-05	f	\N	2025-10-13 00:32:35.217492-05
137f109f-e2a4-42c5-be2a-8e1b3278bd79	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:30:56.094584-05	2025-10-12 12:30:56.096876-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:30:56.094584-05	2025-10-12 12:30:56.104829-05	2025-10-12 12:38:56.094584-05	f	\N	2025-10-13 00:32:35.217492-05
8812982b-c2f8-4802-9008-7810bc3935e3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:35:31.977243-05	2025-10-12 12:35:31.983071-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:35:31.977243-05	2025-10-12 12:35:31.989879-05	2025-10-12 12:43:31.977243-05	f	\N	2025-10-13 00:35:35.222946-05
95e28291-0d73-4790-a30c-ddb6956f47ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:39:01.04615-05	2025-10-12 12:39:04.053566-05	\N	2025-10-12 17:39:00	00:15:00	2025-10-12 12:38:04.04615-05	2025-10-12 12:39:04.07412-05	2025-10-12 12:40:01.04615-05	f	\N	2025-10-13 00:41:35.237436-05
c5b2e763-f6e3-4131-91f8-cd45558d575f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:40:01.072612-05	2025-10-12 12:40:04.081553-05	\N	2025-10-12 17:40:00	00:15:00	2025-10-12 12:39:04.072612-05	2025-10-12 12:40:04.094868-05	2025-10-12 12:41:01.072612-05	f	\N	2025-10-13 00:41:35.237436-05
44a8a242-e504-48b1-914b-1aaa90c1ac04	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:50:01.992387-05	2025-10-12 12:50:03.731136-05	\N	2025-10-12 17:50:00	00:15:00	2025-10-12 12:49:18.992387-05	2025-10-12 12:50:03.75148-05	2025-10-12 12:51:01.992387-05	f	\N	2025-10-13 00:50:35.189648-05
dff72414-2c2a-432c-9642-6794f20c4391	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:40:31.996532-05	2025-10-12 12:48:52.634433-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:38:31.996532-05	2025-10-12 12:48:52.646789-05	2025-10-12 12:48:31.996532-05	f	\N	2025-10-13 00:50:35.189648-05
8ed4fa52-a3da-4a59-a12b-e8df39de721e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:48:52.644721-05	2025-10-12 12:48:52.646608-05	\N	2025-10-12 17:48:00	00:15:00	2025-10-12 12:48:52.644721-05	2025-10-12 12:48:52.665985-05	2025-10-12 12:49:52.644721-05	f	\N	2025-10-13 00:50:35.189648-05
73db04a4-e70c-4daa-9c57-422aaf23af86	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:49:01.664405-05	2025-10-12 12:49:18.977132-05	\N	2025-10-12 17:49:00	00:15:00	2025-10-12 12:48:52.664405-05	2025-10-12 12:49:18.993543-05	2025-10-12 12:50:01.664405-05	f	\N	2025-10-13 00:50:35.189648-05
61ff6bba-776a-4741-adba-dd98963ac843	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:50:52.648374-05	2025-10-12 12:52:29.988711-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:48:52.648374-05	2025-10-12 12:52:29.99863-05	2025-10-12 12:58:52.648374-05	f	\N	2025-10-13 00:53:35.193504-05
18e22d5a-4b4b-41f0-a228-93c7430ed300	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:51:01.749519-05	2025-10-12 12:52:29.97504-05	\N	2025-10-12 17:51:00	00:15:00	2025-10-12 12:50:03.749519-05	2025-10-12 12:52:29.988025-05	2025-10-12 12:52:01.749519-05	f	\N	2025-10-13 00:53:35.193504-05
6bea4ed4-f87c-418f-b23e-7842ee251963	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:52:29.986698-05	2025-10-12 12:52:33.97843-05	\N	2025-10-12 17:52:00	00:15:00	2025-10-12 12:52:29.986698-05	2025-10-12 12:52:33.991005-05	2025-10-12 12:53:29.986698-05	f	\N	2025-10-13 00:53:35.193504-05
93b6f37f-6958-4aa3-b9df-c12282af1e48	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:53:01.989317-05	2025-10-12 12:55:45.552043-05	\N	2025-10-12 17:53:00	00:15:00	2025-10-12 12:52:33.989317-05	2025-10-12 12:55:45.565356-05	2025-10-12 12:54:01.989317-05	f	\N	2025-10-13 00:56:35.195023-05
2c2801b1-ce01-4244-937e-16afea651247	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:54:30.000178-05	2025-10-12 12:55:45.563362-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:52:30.000178-05	2025-10-12 12:55:45.573403-05	2025-10-12 13:02:30.000178-05	f	\N	2025-10-13 00:56:35.195023-05
4c578c05-64ae-4296-9b8f-f31106609f4a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:55:45.563108-05	2025-10-12 12:55:49.558696-05	\N	2025-10-12 17:55:00	00:15:00	2025-10-12 12:55:45.563108-05	2025-10-12 12:55:49.571631-05	2025-10-12 12:56:45.563108-05	f	\N	2025-10-13 00:56:35.195023-05
6e6b3f68-ff0a-4038-bca5-1ef7de153451	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:56:01.569732-05	2025-10-12 12:56:01.574642-05	\N	2025-10-12 17:56:00	00:15:00	2025-10-12 12:55:49.569732-05	2025-10-12 12:56:01.587627-05	2025-10-12 12:57:01.569732-05	f	\N	2025-10-13 00:56:35.195023-05
08422ede-229f-4917-9e42-bfb490085edf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:57:01.586365-05	2025-10-12 13:00:34.179637-05	\N	2025-10-12 17:57:00	00:15:00	2025-10-12 12:56:01.586365-05	2025-10-12 13:00:34.18904-05	2025-10-12 12:58:01.586365-05	f	\N	2025-10-13 01:01:35.204213-05
c5ddcc63-c433-40c5-8a5f-152165595bbd	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T17:35:32.006Z"}	completed	0	0	0	f	2025-10-12 13:00:34.184704-05	2025-10-12 13:00:38.181546-05	dailyStatsJob	2025-10-12 18:00:00	00:15:00	2025-10-12 13:00:34.184704-05	2025-10-12 13:00:38.189303-05	2025-10-26 13:00:34.184704-05	f	\N	2025-10-13 01:01:35.204213-05
22acc7ee-81ac-46ab-96f8-7b2249b52a3b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:00:34.187107-05	2025-10-12 13:00:38.181909-05	\N	2025-10-12 18:00:00	00:15:00	2025-10-12 13:00:34.187107-05	2025-10-12 13:00:38.201676-05	2025-10-12 13:01:34.187107-05	f	\N	2025-10-13 01:01:35.204213-05
846bc005-a7cd-414e-935d-450c1767d5ef	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 13:00:38.187366-05	2025-10-12 13:00:40.185524-05	\N	\N	00:15:00	2025-10-12 13:00:38.187366-05	2025-10-12 13:00:40.433021-05	2025-10-26 13:00:38.187366-05	f	\N	2025-10-13 01:01:35.204213-05
715af56d-4a24-4edb-aac0-97e919123b3c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:40:01.746517-05	2025-10-13 01:40:02.763505-05	\N	2025-10-13 06:40:00	00:15:00	2025-10-13 01:39:02.746517-05	2025-10-13 01:40:02.775977-05	2025-10-13 01:41:01.746517-05	f	\N	2025-10-13 13:49:37.173678-05
a74bc8c5-d6ff-4614-98f1-6c849d3b72f6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:41:01.774198-05	2025-10-13 01:41:02.792487-05	\N	2025-10-13 06:41:00	00:15:00	2025-10-13 01:40:02.774198-05	2025-10-13 01:41:02.803928-05	2025-10-13 01:42:01.774198-05	f	\N	2025-10-13 13:49:37.173678-05
98a7cf36-1f7a-45fa-a0ee-e83c32014f36	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:42:01.802326-05	2025-10-13 01:42:02.81616-05	\N	2025-10-13 06:42:00	00:15:00	2025-10-13 01:41:02.802326-05	2025-10-13 01:42:02.825021-05	2025-10-13 01:43:01.802326-05	f	\N	2025-10-13 13:49:37.173678-05
06db92fb-fe22-441c-b4b2-91aaf46d338b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:41:35.265769-05	2025-10-13 01:42:35.26154-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:39:35.265769-05	2025-10-13 01:42:35.267603-05	2025-10-13 01:49:35.265769-05	f	\N	2025-10-13 13:49:37.173678-05
d619acf2-e906-4321-9dd7-8e6b91eb8636	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:43:01.823922-05	2025-10-13 01:43:02.839936-05	\N	2025-10-13 06:43:00	00:15:00	2025-10-13 01:42:02.823922-05	2025-10-13 01:43:02.848534-05	2025-10-13 01:44:01.823922-05	f	\N	2025-10-13 13:49:37.173678-05
3e42175a-f8d2-4d3e-8208-668c23f0c709	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:44:01.847402-05	2025-10-13 01:44:02.866604-05	\N	2025-10-13 06:44:00	00:15:00	2025-10-13 01:43:02.847402-05	2025-10-13 01:44:02.875121-05	2025-10-13 01:45:01.847402-05	f	\N	2025-10-13 13:49:37.173678-05
cb0e5c19-a10f-4975-b66c-9e3c636bb1b0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:45:01.873809-05	2025-10-13 01:45:02.889655-05	\N	2025-10-13 06:45:00	00:15:00	2025-10-13 01:44:02.873809-05	2025-10-13 01:45:02.901997-05	2025-10-13 01:46:01.873809-05	f	\N	2025-10-13 13:49:37.173678-05
ddda0cf0-77fb-420f-80b9-04ce5a980a0a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:44:35.269141-05	2025-10-13 01:45:35.265118-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:42:35.269141-05	2025-10-13 01:45:35.271706-05	2025-10-13 01:52:35.269141-05	f	\N	2025-10-13 13:49:37.173678-05
c9145fe2-6b07-4520-8c70-fac5468f6314	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:46:01.900354-05	2025-10-13 01:46:02.917903-05	\N	2025-10-13 06:46:00	00:15:00	2025-10-13 01:45:02.900354-05	2025-10-13 01:46:02.927212-05	2025-10-13 01:47:01.900354-05	f	\N	2025-10-13 13:49:37.173678-05
c7a4a083-000c-4caf-9267-14e104fb5420	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:47:01.925901-05	2025-10-13 01:47:02.944398-05	\N	2025-10-13 06:47:00	00:15:00	2025-10-13 01:46:02.925901-05	2025-10-13 01:47:02.955458-05	2025-10-13 01:48:01.925901-05	f	\N	2025-10-13 13:49:37.173678-05
40308ecb-b9ba-4bc0-858e-26aa624c01a0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:48:01.954063-05	2025-10-13 01:48:02.972253-05	\N	2025-10-13 06:48:00	00:15:00	2025-10-13 01:47:02.954063-05	2025-10-13 01:48:02.985645-05	2025-10-13 01:49:01.954063-05	f	\N	2025-10-13 13:49:37.173678-05
1301b1ee-34c7-4f1a-9d6d-25f22385fbe6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:47:35.273528-05	2025-10-13 01:48:35.267427-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:45:35.273528-05	2025-10-13 01:48:35.275542-05	2025-10-13 01:55:35.273528-05	f	\N	2025-10-13 13:49:37.173678-05
c0c0f2a9-dc58-4607-b626-f072d6fd2d26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:49:01.984318-05	2025-10-13 01:49:03.003098-05	\N	2025-10-13 06:49:00	00:15:00	2025-10-13 01:48:02.984318-05	2025-10-13 01:49:03.015869-05	2025-10-13 01:50:01.984318-05	f	\N	2025-10-13 13:49:37.173678-05
644d3214-508f-46c1-88f3-b3251567544c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:41:01.685341-05	2025-10-13 04:41:03.695421-05	\N	2025-10-13 09:41:00	00:15:00	2025-10-13 04:40:03.685341-05	2025-10-13 04:41:03.706691-05	2025-10-13 04:42:01.685341-05	f	\N	2025-10-13 16:42:01.700953-05
8cbcdfa8-175e-463e-9884-e9c614849ad5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:38:01.02006-05	2025-10-12 12:38:04.023748-05	\N	2025-10-12 17:38:00	00:15:00	2025-10-12 12:37:04.02006-05	2025-10-12 12:38:04.050481-05	2025-10-12 12:39:01.02006-05	f	\N	2025-10-13 00:38:35.227733-05
2d7e319c-9e0e-41b4-bd4e-b8fff802ea6f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 12:37:31.991319-05	2025-10-12 12:38:31.985097-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 12:35:31.991319-05	2025-10-12 12:38:31.994517-05	2025-10-12 12:45:31.991319-05	f	\N	2025-10-13 00:38:35.227733-05
d350a62e-6ead-4e77-ad89-97c0c432b277	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:35:31.993072-05	2025-10-12 12:35:35.99139-05	\N	2025-10-12 17:35:00	00:15:00	2025-10-12 12:35:31.993072-05	2025-10-12 12:35:36.019246-05	2025-10-12 12:36:31.993072-05	f	\N	2025-10-13 00:38:35.227733-05
c0e8449b-f745-4d8b-81f1-7096acfb0bde	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:37:01.007569-05	2025-10-12 12:37:04.007748-05	\N	2025-10-12 17:37:00	00:15:00	2025-10-12 12:36:04.007569-05	2025-10-12 12:37:04.021363-05	2025-10-12 12:38:01.007569-05	f	\N	2025-10-13 00:38:35.227733-05
bcbb1438-80ab-4220-b766-37872d59c349	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 12:36:01.017482-05	2025-10-12 12:36:03.99449-05	\N	2025-10-12 17:36:00	00:15:00	2025-10-12 12:35:36.017482-05	2025-10-12 12:36:04.008983-05	2025-10-12 12:37:01.017482-05	f	\N	2025-10-13 00:38:35.227733-05
57e94b33-0d3b-409d-8fbe-0a81410aa61d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:50:01.01427-05	2025-10-13 01:50:03.029537-05	\N	2025-10-13 06:50:00	00:15:00	2025-10-13 01:49:03.01427-05	2025-10-13 01:50:03.036881-05	2025-10-13 01:51:01.01427-05	f	\N	2025-10-13 13:54:44.833248-05
8cbd30ba-bbcc-4a5a-9571-4fc03e1f0600	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:51:01.035821-05	2025-10-13 01:51:03.060525-05	\N	2025-10-13 06:51:00	00:15:00	2025-10-13 01:50:03.035821-05	2025-10-13 01:51:03.068039-05	2025-10-13 01:52:01.035821-05	f	\N	2025-10-13 13:54:44.833248-05
979d33c9-9be4-49fd-bb5b-eaf4e9619fd4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:50:35.277423-05	2025-10-13 01:51:35.27115-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:48:35.277423-05	2025-10-13 01:51:35.277693-05	2025-10-13 01:58:35.277423-05	f	\N	2025-10-13 13:54:44.833248-05
d107f2e4-05a1-4bee-9c2f-6946f298036b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:52:01.067074-05	2025-10-13 01:52:03.086625-05	\N	2025-10-13 06:52:00	00:15:00	2025-10-13 01:51:03.067074-05	2025-10-13 01:52:03.095323-05	2025-10-13 01:53:01.067074-05	f	\N	2025-10-13 13:54:44.833248-05
9bfee163-8339-4fc0-aec4-df3d39fd1bf8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:53:01.094116-05	2025-10-13 01:53:03.113042-05	\N	2025-10-13 06:53:00	00:15:00	2025-10-13 01:52:03.094116-05	2025-10-13 01:53:03.126156-05	2025-10-13 01:54:01.094116-05	f	\N	2025-10-13 13:54:44.833248-05
b2d71c29-e8ea-4a8e-9c3c-b6bb3668c0c5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:54:01.12435-05	2025-10-13 01:54:03.134625-05	\N	2025-10-13 06:54:00	00:15:00	2025-10-13 01:53:03.12435-05	2025-10-13 01:54:03.143182-05	2025-10-13 01:55:01.12435-05	f	\N	2025-10-13 13:54:44.833248-05
8601640b-4ca2-44ed-931e-9834fddad403	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:53:35.279043-05	2025-10-13 01:54:35.274856-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:51:35.279043-05	2025-10-13 01:54:35.282631-05	2025-10-13 02:01:35.279043-05	f	\N	2025-10-13 13:54:44.833248-05
cdcf0b79-5f30-40c2-98cc-b9e11bb152fa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:39:35.541865-05	2025-10-13 04:40:35.538042-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:37:35.541865-05	2025-10-13 04:40:35.544826-05	2025-10-13 04:47:35.541865-05	f	\N	2025-10-13 16:42:01.700953-05
e8335963-4f33-4412-a71d-c27b26eb8773	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:16:11.90518-05	2025-10-12 13:16:15.869592-05	\N	2025-10-12 18:16:00	00:15:00	2025-10-12 13:16:11.90518-05	2025-10-12 13:16:15.88194-05	2025-10-12 13:17:11.90518-05	f	\N	2025-10-13 01:18:35.263832-05
b458c916-a488-4f6f-84a5-4a9c5f138cbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:01:01.199841-05	2025-10-12 13:16:11.878638-05	\N	2025-10-12 18:01:00	00:15:00	2025-10-12 13:00:38.199841-05	2025-10-12 13:16:11.910475-05	2025-10-12 13:02:01.199841-05	f	\N	2025-10-13 01:18:35.263832-05
27e28869-7479-4802-af7f-c0a4157c964b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:43:42.244071-05	2025-10-12 13:43:46.233182-05	\N	2025-10-12 18:43:00	00:15:00	2025-10-12 13:43:42.244071-05	2025-10-12 13:43:46.242466-05	2025-10-12 13:44:42.244071-05	f	\N	2025-10-13 01:45:35.268345-05
750daa72-825c-4ba1-8507-79ee8b741b0a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:34:05.601325-05	2025-10-12 13:43:42.23207-05	\N	2025-10-12 18:34:00	00:15:00	2025-10-12 13:34:05.601325-05	2025-10-12 13:43:42.342045-05	2025-10-12 13:35:05.601325-05	f	\N	2025-10-13 01:45:35.268345-05
d924c67d-81dc-403e-8a48-5e379c50821f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:44:01.339066-05	2025-10-12 13:50:21.556582-05	\N	2025-10-12 18:44:00	00:15:00	2025-10-12 13:43:42.339066-05	2025-10-12 13:50:21.568853-05	2025-10-12 13:45:01.339066-05	f	\N	2025-10-13 01:51:35.274637-05
28d44ad0-6e0b-4a55-b010-1a1e26342db6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:50:21.566039-05	2025-10-12 13:50:25.536079-05	\N	2025-10-12 18:50:00	00:15:00	2025-10-12 13:50:21.566039-05	2025-10-12 13:50:25.548994-05	2025-10-12 13:51:21.566039-05	f	\N	2025-10-13 01:51:35.274637-05
d6edd76a-9f19-4d9e-a7f6-178392bbb1c8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:51:01.567948-05	2025-10-12 14:02:25.156237-05	\N	2025-10-12 18:51:00	00:15:00	2025-10-12 13:50:21.567948-05	2025-10-12 14:02:25.164297-05	2025-10-12 13:52:01.567948-05	f	\N	2025-10-13 02:03:35.286351-05
808aaeae-4c2e-4d24-979c-a0ed6a931c6c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:02:25.163281-05	2025-10-12 14:02:29.157767-05	\N	2025-10-12 19:02:00	00:15:00	2025-10-12 14:02:25.163281-05	2025-10-12 14:02:29.16981-05	2025-10-12 14:03:25.163281-05	f	\N	2025-10-13 02:03:35.286351-05
116fe9fb-7e99-454d-897a-fea911d7730b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:11:01.510439-05	2025-10-12 14:13:09.447765-05	\N	2025-10-12 19:11:00	00:15:00	2025-10-12 14:10:20.510439-05	2025-10-12 14:13:09.457855-05	2025-10-12 14:12:01.510439-05	f	\N	2025-10-13 02:15:35.302642-05
a73fafa5-d5b8-40c7-9cbc-b26ca897e6a1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:13:09.454272-05	2025-10-12 14:13:13.449393-05	\N	2025-10-12 19:13:00	00:15:00	2025-10-12 14:13:09.454272-05	2025-10-12 14:13:13.46419-05	2025-10-12 14:14:09.454272-05	f	\N	2025-10-13 02:15:35.302642-05
fee8354f-6e98-47ab-b208-933c767baf4e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 14:12:16.520474-05	2025-10-12 14:13:09.458579-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 14:10:16.520474-05	2025-10-12 14:13:09.470909-05	2025-10-12 14:20:16.520474-05	f	\N	2025-10-13 02:15:35.302642-05
bc374bde-0441-4b4a-9fb0-c632b6e17274	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:55:01.141964-05	2025-10-13 01:55:03.164198-05	\N	2025-10-13 06:55:00	00:15:00	2025-10-13 01:54:03.141964-05	2025-10-13 01:55:03.177362-05	2025-10-13 01:56:01.141964-05	f	\N	2025-10-13 14:09:11.021513-05
80fa1581-242a-4e9d-92ed-b4d7d6619675	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:56:01.175286-05	2025-10-13 01:56:03.186798-05	\N	2025-10-13 06:56:00	00:15:00	2025-10-13 01:55:03.175286-05	2025-10-13 01:56:03.197381-05	2025-10-13 01:57:01.175286-05	f	\N	2025-10-13 14:09:11.021513-05
7b38ccb3-fc83-45de-ac00-314a641e9c11	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:57:01.195886-05	2025-10-13 01:57:03.214819-05	\N	2025-10-13 06:57:00	00:15:00	2025-10-13 01:56:03.195886-05	2025-10-13 01:57:03.227575-05	2025-10-13 01:58:01.195886-05	f	\N	2025-10-13 14:09:11.021513-05
dfc2bd36-2610-4f56-90d2-d8849e22e6c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:58:01.226007-05	2025-10-13 01:58:03.241916-05	\N	2025-10-13 06:58:00	00:15:00	2025-10-13 01:57:03.226007-05	2025-10-13 01:58:03.2487-05	2025-10-13 01:59:01.226007-05	f	\N	2025-10-13 14:09:11.021513-05
9f2fd8a1-212e-4d69-a927-459df2b9ca8a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:56:35.284564-05	2025-10-13 01:57:35.276968-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:54:35.284564-05	2025-10-13 01:57:35.283158-05	2025-10-13 02:04:35.284564-05	f	\N	2025-10-13 14:09:11.021513-05
6f8621a2-f098-467a-af2e-5832aa4a19a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 01:59:01.247721-05	2025-10-13 01:59:03.27144-05	\N	2025-10-13 06:59:00	00:15:00	2025-10-13 01:58:03.247721-05	2025-10-13 01:59:03.283182-05	2025-10-13 02:00:01.247721-05	f	\N	2025-10-13 14:09:11.021513-05
348aa945-df70-4be3-9a6a-c38f15f4d26e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:00:01.281485-05	2025-10-13 02:00:03.300974-05	\N	2025-10-13 07:00:00	00:15:00	2025-10-13 01:59:03.281485-05	2025-10-13 02:00:03.308491-05	2025-10-13 02:01:01.281485-05	f	\N	2025-10-13 14:09:11.021513-05
6316e42f-2a74-4d1b-b7fb-5250ceb98e03	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 01:59:35.284226-05	2025-10-13 02:00:35.279245-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 01:57:35.284226-05	2025-10-13 02:00:35.286035-05	2025-10-13 02:07:35.284226-05	f	\N	2025-10-13 14:09:11.021513-05
992b16fd-6222-4c59-9d05-7a7bcb187644	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:02:01.333913-05	2025-10-13 02:02:03.351645-05	\N	2025-10-13 07:02:00	00:15:00	2025-10-13 02:01:03.333913-05	2025-10-13 02:02:03.36182-05	2025-10-13 02:03:01.333913-05	f	\N	2025-10-13 14:09:11.021513-05
918f5a6b-8f4c-4f4e-95aa-3c1d4294e0dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:03:01.360281-05	2025-10-13 02:03:03.376184-05	\N	2025-10-13 07:03:00	00:15:00	2025-10-13 02:02:03.360281-05	2025-10-13 02:03:03.383113-05	2025-10-13 02:04:01.360281-05	f	\N	2025-10-13 14:09:11.021513-05
5beaac50-5e2f-4ec0-8bf1-b2e7c81e6184	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:05:35.289952-05	2025-10-13 02:06:35.288095-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:03:35.289952-05	2025-10-13 02:06:35.293434-05	2025-10-13 02:13:35.289952-05	f	\N	2025-10-13 14:09:11.021513-05
320a775b-3e02-421b-8cb3-1358d79a22ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:08:01.486879-05	2025-10-13 02:08:03.500772-05	\N	2025-10-13 07:08:00	00:15:00	2025-10-13 02:07:03.486879-05	2025-10-13 02:08:03.510992-05	2025-10-13 02:09:01.486879-05	f	\N	2025-10-13 14:09:11.021513-05
4989077f-0f53-4cd0-becd-32a1025df87a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:09:01.509428-05	2025-10-13 02:09:03.530646-05	\N	2025-10-13 07:09:00	00:15:00	2025-10-13 02:08:03.509428-05	2025-10-13 02:09:03.535861-05	2025-10-13 02:10:01.509428-05	f	\N	2025-10-13 14:09:11.021513-05
23cc9699-c3ac-46d4-b3c0-2ac12859d4c8	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 02:00:03.30462-05	2025-10-13 02:00:07.302501-05	dailyStatsJob	2025-10-13 07:00:00	00:15:00	2025-10-13 02:00:03.30462-05	2025-10-13 02:00:07.307109-05	2025-10-27 02:00:03.30462-05	f	\N	2025-10-13 14:09:11.021513-05
6e07d337-10ee-4a0a-948d-e0f43f6fe402	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 02:00:07.305237-05	2025-10-13 02:00:08.79606-05	\N	\N	00:15:00	2025-10-13 02:00:07.305237-05	2025-10-13 02:00:08.963709-05	2025-10-27 02:00:07.305237-05	f	\N	2025-10-13 14:09:11.021513-05
77308977-4220-42da-b42e-2680ad8b8bf7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:01:01.307349-05	2025-10-13 02:01:03.326062-05	\N	2025-10-13 07:01:00	00:15:00	2025-10-13 02:00:03.307349-05	2025-10-13 02:01:03.335637-05	2025-10-13 02:02:01.307349-05	f	\N	2025-10-13 14:09:11.021513-05
fbe18a8f-6487-4c16-b2a3-744793bf6d6e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:02:35.287459-05	2025-10-13 02:03:35.28363-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:00:35.287459-05	2025-10-13 02:03:35.288465-05	2025-10-13 02:10:35.287459-05	f	\N	2025-10-13 14:09:11.021513-05
f2f6f8fa-b012-4d2c-85c6-b6dc175dcf2d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:04:01.381787-05	2025-10-13 02:04:03.399427-05	\N	2025-10-13 07:04:00	00:15:00	2025-10-13 02:03:03.381787-05	2025-10-13 02:04:03.40741-05	2025-10-13 02:05:01.381787-05	f	\N	2025-10-13 14:09:11.021513-05
5bf9bf40-79f2-4763-8546-f06d2f5df22b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:05:01.406111-05	2025-10-13 02:05:03.428424-05	\N	2025-10-13 07:05:00	00:15:00	2025-10-13 02:04:03.406111-05	2025-10-13 02:05:03.434102-05	2025-10-13 02:06:01.406111-05	f	\N	2025-10-13 14:09:11.021513-05
2160d04d-a16b-44e3-8814-9beecb669d5f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:06:01.433128-05	2025-10-13 02:06:03.455145-05	\N	2025-10-13 07:06:00	00:15:00	2025-10-13 02:05:03.433128-05	2025-10-13 02:06:03.463469-05	2025-10-13 02:07:01.433128-05	f	\N	2025-10-13 14:09:11.021513-05
cdb3382f-ee9c-4a6c-ae43-19392051ef46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:07:01.462137-05	2025-10-13 02:07:03.480361-05	\N	2025-10-13 07:07:00	00:15:00	2025-10-13 02:06:03.462137-05	2025-10-13 02:07:03.488262-05	2025-10-13 02:08:01.462137-05	f	\N	2025-10-13 14:09:11.021513-05
a4e27e98-22f9-4c38-94c6-52a619fbc3cd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:43:01.738184-05	2025-10-13 04:43:03.75097-05	\N	2025-10-13 09:43:00	00:15:00	2025-10-13 04:42:03.738184-05	2025-10-13 04:43:03.761301-05	2025-10-13 04:44:01.738184-05	f	\N	2025-10-13 16:46:53.444606-05
84505593-8c75-4331-bb18-db33b668daa7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:44:01.76004-05	2025-10-13 04:44:03.776416-05	\N	2025-10-13 09:44:00	00:15:00	2025-10-13 04:43:03.76004-05	2025-10-13 04:44:03.786835-05	2025-10-13 04:45:01.76004-05	f	\N	2025-10-13 16:46:53.444606-05
74754640-e409-41f3-8241-60cd6ead4e57	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:42:01.704971-05	2025-10-13 04:42:03.725484-05	\N	2025-10-13 09:42:00	00:15:00	2025-10-13 04:41:03.704971-05	2025-10-13 04:42:03.740182-05	2025-10-13 04:43:01.704971-05	f	\N	2025-10-13 16:46:53.444606-05
ddd54bad-8a22-4ed0-a62e-1391ec60e8b8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:42:35.546301-05	2025-10-13 04:43:35.540709-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:40:35.546301-05	2025-10-13 04:43:35.549878-05	2025-10-13 04:50:35.546301-05	f	\N	2025-10-13 16:46:53.444606-05
26e0dcaf-cf0d-4e28-81ca-025e9586f2d5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:45:01.785406-05	2025-10-13 04:45:03.798751-05	\N	2025-10-13 09:45:00	00:15:00	2025-10-13 04:44:03.785406-05	2025-10-13 04:45:03.806559-05	2025-10-13 04:46:01.785406-05	f	\N	2025-10-13 16:46:53.444606-05
7355a8ac-2078-40a8-b996-b6b1a351e8c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:46:01.805627-05	2025-10-13 04:46:03.825076-05	\N	2025-10-13 09:46:00	00:15:00	2025-10-13 04:45:03.805627-05	2025-10-13 04:46:03.833526-05	2025-10-13 04:47:01.805627-05	f	\N	2025-10-13 16:46:53.444606-05
13286add-8636-47b8-948a-20fc7cdc4fe5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:45:35.552155-05	2025-10-13 04:46:35.543986-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:43:35.552155-05	2025-10-13 04:46:35.553061-05	2025-10-13 04:53:35.552155-05	f	\N	2025-10-13 16:46:53.444606-05
8aec7151-6e01-4bf5-8515-698ac9817d7e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 13:17:01.880494-05	2025-10-12 13:34:05.585268-05	\N	2025-10-12 18:17:00	00:15:00	2025-10-12 13:16:15.880494-05	2025-10-12 13:34:05.604922-05	2025-10-12 13:18:01.880494-05	f	\N	2025-10-13 01:36:35.258873-05
52f942cc-3f46-49a1-a34d-518685a4ac32	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:05:41.98821-05	2025-10-12 14:05:45.979311-05	\N	2025-10-12 19:05:00	00:15:00	2025-10-12 14:05:41.98821-05	2025-10-12 14:05:45.988119-05	2025-10-12 14:06:41.98821-05	f	\N	2025-10-13 02:06:35.290899-05
1591742d-4615-4710-8ba2-fd452f39014d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:06:01.986458-05	2025-10-12 14:06:14.674598-05	\N	2025-10-12 19:06:00	00:15:00	2025-10-12 14:05:45.986458-05	2025-10-12 14:06:14.685751-05	2025-10-12 14:07:01.986458-05	f	\N	2025-10-13 02:06:35.290899-05
4e0f75c4-6486-42f8-a55b-bf08ca908e88	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 14:02:25.170146-05	2025-10-12 14:05:41.991956-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 14:02:25.170146-05	2025-10-12 14:05:42.002604-05	2025-10-12 14:10:25.170146-05	f	\N	2025-10-13 02:06:35.290899-05
e3263352-b241-4214-bb96-5878a7351155	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:03:01.168254-05	2025-10-12 14:05:41.98227-05	\N	2025-10-12 19:03:00	00:15:00	2025-10-12 14:02:29.168254-05	2025-10-12 14:05:41.989879-05	2025-10-12 14:04:01.168254-05	f	\N	2025-10-13 02:06:35.290899-05
ebe26136-69a5-463b-abf1-cb4dcf28eee8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:07:01.684278-05	2025-10-12 14:10:16.501542-05	\N	2025-10-12 19:07:00	00:15:00	2025-10-12 14:06:14.684278-05	2025-10-12 14:10:16.509835-05	2025-10-12 14:08:01.684278-05	f	\N	2025-10-13 02:12:35.298309-05
90188b7c-ca9f-4e3d-b3d3-07775e979a19	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 14:07:42.004201-05	2025-10-12 14:10:16.510535-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 14:05:42.004201-05	2025-10-12 14:10:16.519238-05	2025-10-12 14:15:42.004201-05	f	\N	2025-10-13 02:12:35.298309-05
7669da06-4ae5-43fc-923a-53f7f1e11caf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:10:16.507672-05	2025-10-12 14:10:20.502765-05	\N	2025-10-12 19:10:00	00:15:00	2025-10-12 14:10:16.507672-05	2025-10-12 14:10:20.511829-05	2025-10-12 14:11:16.507672-05	f	\N	2025-10-13 02:12:35.298309-05
8b93626e-84c1-43cf-8c4e-e6d3105fdf4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:14:01.462659-05	2025-10-12 14:29:50.951999-05	\N	2025-10-12 19:14:00	00:15:00	2025-10-12 14:13:13.462659-05	2025-10-12 14:29:50.965164-05	2025-10-12 14:15:01.462659-05	f	\N	2025-10-13 02:32:35.354692-05
29637970-72a3-48fb-af33-b51cb22c99f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:29:50.963477-05	2025-10-12 14:31:35.300881-05	\N	2025-10-12 19:29:00	00:15:00	2025-10-12 14:29:50.963477-05	2025-10-12 14:31:35.317176-05	2025-10-12 14:30:50.963477-05	f	\N	2025-10-13 02:32:35.354692-05
56776adf-4ce2-46aa-8f78-54d723619452	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:31:35.315614-05	2025-10-12 14:31:39.298083-05	\N	2025-10-12 19:31:00	00:15:00	2025-10-12 14:31:35.315614-05	2025-10-12 14:31:39.31032-05	2025-10-12 14:32:35.315614-05	f	\N	2025-10-13 02:32:35.354692-05
761f6a9b-985e-445b-92d1-5e6961c98ef3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:32:01.308846-05	2025-10-12 14:32:18.103775-05	\N	2025-10-12 19:32:00	00:15:00	2025-10-12 14:31:39.308846-05	2025-10-12 14:32:18.119168-05	2025-10-12 14:33:01.308846-05	f	\N	2025-10-13 02:32:35.354692-05
86585fe6-8b14-4e64-a08c-f34047019985	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 14:29:50.972127-05	2025-10-12 14:31:35.316429-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 14:29:50.972127-05	2025-10-12 14:31:35.328401-05	2025-10-12 14:37:50.972127-05	f	\N	2025-10-13 02:32:35.354692-05
0cbdb8d2-fc2c-4570-b81b-3f1ced4543f8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 14:33:35.329739-05	2025-10-12 14:34:14.791144-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 14:31:35.329739-05	2025-10-12 14:34:14.802425-05	2025-10-12 14:41:35.329739-05	f	\N	2025-10-13 02:35:35.359117-05
80702f15-979a-4c20-bb8b-6f769094c52b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:33:01.116914-05	2025-10-12 14:34:14.781367-05	\N	2025-10-12 19:33:00	00:15:00	2025-10-12 14:32:18.116914-05	2025-10-12 14:34:14.789129-05	2025-10-12 14:34:01.116914-05	f	\N	2025-10-13 02:35:35.359117-05
7af6faca-cc6f-4941-901f-e8d2cae9c459	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:34:14.787633-05	2025-10-12 14:34:18.780984-05	\N	2025-10-12 19:34:00	00:15:00	2025-10-12 14:34:14.787633-05	2025-10-12 14:34:18.803188-05	2025-10-12 14:35:14.787633-05	f	\N	2025-10-13 02:35:35.359117-05
db265df6-debe-4135-be8d-ce656da092af	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:35:01.801025-05	2025-10-12 14:39:06.202816-05	\N	2025-10-12 19:35:00	00:15:00	2025-10-12 14:34:18.801025-05	2025-10-12 14:39:06.361089-05	2025-10-12 14:36:01.801025-05	f	\N	2025-10-13 02:41:35.368414-05
4eb2a5d5-667e-482e-a414-2bc22543d2d2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:39:06.212272-05	2025-10-12 14:39:10.181734-05	\N	2025-10-12 19:39:00	00:15:00	2025-10-12 14:39:06.212272-05	2025-10-12 14:39:10.188864-05	2025-10-12 14:40:06.212272-05	f	\N	2025-10-13 02:41:35.368414-05
7af4f132-5b83-4b26-bf2a-6b913bb39bfe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:11:01.560272-05	2025-10-13 02:11:03.576879-05	\N	2025-10-13 07:11:00	00:15:00	2025-10-13 02:10:03.560272-05	2025-10-13 02:11:03.583161-05	2025-10-13 02:12:01.560272-05	f	\N	2025-10-13 14:11:20.386966-05
54e8254a-23d2-42bc-803b-aae46602b40d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:08:35.294783-05	2025-10-13 02:09:35.291387-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:06:35.294783-05	2025-10-13 02:09:35.298449-05	2025-10-13 02:16:35.294783-05	f	\N	2025-10-13 14:11:20.386966-05
85e72c9b-69af-4517-a9e0-04d1b1439e48	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:10:01.535262-05	2025-10-13 02:10:03.555994-05	\N	2025-10-13 07:10:00	00:15:00	2025-10-13 02:09:03.535262-05	2025-10-13 02:10:03.561134-05	2025-10-13 02:11:01.535262-05	f	\N	2025-10-13 14:11:20.386966-05
9067d946-dabe-4355-897e-cc1dcf0e5a8f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:47:01.832226-05	2025-10-13 04:47:03.854247-05	\N	2025-10-13 09:47:00	00:15:00	2025-10-13 04:46:03.832226-05	2025-10-13 04:47:03.865021-05	2025-10-13 04:48:01.832226-05	f	\N	2025-10-13 16:48:00.282375-05
4ae7ab4f-2512-47e9-a1f5-196795c5f40a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:40:01.36035-05	2025-10-12 14:55:44.457983-05	\N	2025-10-12 19:40:00	00:15:00	2025-10-12 14:39:06.36035-05	2025-10-12 14:55:44.466589-05	2025-10-12 14:41:01.36035-05	f	\N	2025-10-13 02:58:35.404693-05
75085b6f-a4db-45cd-a8c4-9690ba939c9b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:55:44.465371-05	2025-10-12 14:55:48.458645-05	\N	2025-10-12 19:55:00	00:15:00	2025-10-12 14:55:44.465371-05	2025-10-12 14:55:48.471167-05	2025-10-12 14:56:44.465371-05	f	\N	2025-10-13 02:58:35.404693-05
caf915c1-a78c-46f7-8b7d-58d9cb9319f0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 14:56:01.46956-05	2025-10-12 15:12:09.589768-05	\N	2025-10-12 19:56:00	00:15:00	2025-10-12 14:55:48.46956-05	2025-10-12 15:12:09.601408-05	2025-10-12 14:57:01.46956-05	f	\N	2025-10-13 03:13:35.433109-05
69e08254-e420-4419-9af2-3391c97bdea6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:12:09.598073-05	2025-10-12 15:12:13.589546-05	\N	2025-10-12 20:12:00	00:15:00	2025-10-12 15:12:09.598073-05	2025-10-12 15:12:13.600123-05	2025-10-12 15:13:09.598073-05	f	\N	2025-10-13 03:13:35.433109-05
31e89fa5-e188-4778-a213-75fcbcfeed6d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:13:01.599021-05	2025-10-12 15:29:48.857794-05	\N	2025-10-12 20:13:00	00:15:00	2025-10-12 15:12:13.599021-05	2025-10-12 15:29:48.866833-05	2025-10-12 15:14:01.599021-05	f	\N	2025-10-13 03:31:35.466617-05
7dd2adcc-4c88-4cc5-b9d2-3b25ab19673f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:29:48.865312-05	2025-10-12 15:29:52.853744-05	\N	2025-10-12 20:29:00	00:15:00	2025-10-12 15:29:48.865312-05	2025-10-12 15:29:52.870992-05	2025-10-12 15:30:48.865312-05	f	\N	2025-10-13 03:31:35.466617-05
3db32562-992e-424f-9471-9c4e439d705a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:31:55.333305-05	2025-10-12 15:31:59.325858-05	\N	2025-10-12 20:31:00	00:15:00	2025-10-12 15:31:55.333305-05	2025-10-12 15:31:59.336044-05	2025-10-12 15:32:55.333305-05	f	\N	2025-10-13 03:34:35.472204-05
b0fa8720-a4b4-44f0-a76e-0ad90460ff06	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:30:01.867997-05	2025-10-12 15:31:55.322906-05	\N	2025-10-12 20:30:00	00:15:00	2025-10-12 15:29:52.867997-05	2025-10-12 15:31:55.335434-05	2025-10-12 15:31:01.867997-05	f	\N	2025-10-13 03:34:35.472204-05
0f3934ea-d643-43d7-914e-743f9fe443fa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 15:29:48.876502-05	2025-10-12 15:31:55.334322-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 15:29:48.876502-05	2025-10-12 15:31:55.341795-05	2025-10-12 15:37:48.876502-05	f	\N	2025-10-13 03:34:35.472204-05
f3b0f3b3-a07c-4550-839d-fe872c7b274e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:13:01.61255-05	2025-10-13 02:13:03.630463-05	\N	2025-10-13 07:13:00	00:15:00	2025-10-13 02:12:03.61255-05	2025-10-13 02:13:03.639788-05	2025-10-13 02:14:01.61255-05	f	\N	2025-10-13 14:14:23.982533-05
c2b31d1b-1a24-4b13-b01a-37ec5e8f5c7e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:12:01.582133-05	2025-10-13 02:12:03.604139-05	\N	2025-10-13 07:12:00	00:15:00	2025-10-13 02:11:03.582133-05	2025-10-13 02:12:03.613888-05	2025-10-13 02:13:01.582133-05	f	\N	2025-10-13 14:14:23.982533-05
ed9be633-1f5f-47c4-b309-9fd56932b203	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:11:35.299993-05	2025-10-13 02:12:35.295161-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:09:35.299993-05	2025-10-13 02:12:35.3013-05	2025-10-13 02:19:35.299993-05	f	\N	2025-10-13 14:14:23.982533-05
54dbde55-017a-444c-baf4-1a656c8144d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:14:01.638298-05	2025-10-13 02:14:03.654748-05	\N	2025-10-13 07:14:00	00:15:00	2025-10-13 02:13:03.638298-05	2025-10-13 02:14:03.660671-05	2025-10-13 02:15:01.638298-05	f	\N	2025-10-13 14:14:23.982533-05
419ca212-936b-4794-b967-a3f33a0848db	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:48:01.863766-05	2025-10-13 04:48:03.881389-05	\N	2025-10-13 09:48:00	00:15:00	2025-10-13 04:47:03.863766-05	2025-10-13 04:48:03.892062-05	2025-10-13 04:49:01.863766-05	f	\N	2025-10-13 16:59:15.975072-05
dac62681-6e7e-4c23-b366-e0e9cbf55b8d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:49:01.890958-05	2025-10-13 04:49:03.907107-05	\N	2025-10-13 09:49:00	00:15:00	2025-10-13 04:48:03.890958-05	2025-10-13 04:49:03.913733-05	2025-10-13 04:50:01.890958-05	f	\N	2025-10-13 16:59:15.975072-05
f1557f45-b60a-42d2-abd6-734be95459d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:50:01.912989-05	2025-10-13 04:50:03.937322-05	\N	2025-10-13 09:50:00	00:15:00	2025-10-13 04:49:03.912989-05	2025-10-13 04:50:03.947566-05	2025-10-13 04:51:01.912989-05	f	\N	2025-10-13 16:59:15.975072-05
6e1bce1d-00ae-4fe3-b881-2c7171278b5b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:51:35.553547-05	2025-10-13 04:52:35.550549-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:49:35.553547-05	2025-10-13 04:52:35.557057-05	2025-10-13 04:59:35.553547-05	f	\N	2025-10-13 16:59:15.975072-05
6cda14d0-daf0-4cd0-a6c9-c0a0c018d0e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:56:01.075443-05	2025-10-13 04:56:04.094877-05	\N	2025-10-13 09:56:00	00:15:00	2025-10-13 04:55:04.075443-05	2025-10-13 04:56:04.10756-05	2025-10-13 04:57:01.075443-05	f	\N	2025-10-13 16:59:15.975072-05
01e6842a-be87-4ea3-87c0-fcd7189346cd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:57:01.105805-05	2025-10-13 04:57:04.12728-05	\N	2025-10-13 09:57:00	00:15:00	2025-10-13 04:56:04.105805-05	2025-10-13 04:57:04.139113-05	2025-10-13 04:58:01.105805-05	f	\N	2025-10-13 16:59:15.975072-05
5a6aef15-b097-47c4-ba5a-6cec47728f2c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:58:01.137755-05	2025-10-13 04:58:04.158659-05	\N	2025-10-13 09:58:00	00:15:00	2025-10-13 04:57:04.137755-05	2025-10-13 04:58:04.168787-05	2025-10-13 04:59:01.137755-05	f	\N	2025-10-13 16:59:15.975072-05
042de6ec-432b-47c3-99ae-ef39a5fc0b46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:59:01.167483-05	2025-10-13 04:59:04.187607-05	\N	2025-10-13 09:59:00	00:15:00	2025-10-13 04:58:04.167483-05	2025-10-13 04:59:04.198419-05	2025-10-13 05:00:01.167483-05	f	\N	2025-10-13 16:59:15.975072-05
53924d73-70f4-4cb9-be4e-c637ec907385	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:48:35.554916-05	2025-10-13 04:49:35.545658-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:46:35.554916-05	2025-10-13 04:49:35.552405-05	2025-10-13 04:56:35.554916-05	f	\N	2025-10-13 16:59:15.975072-05
b0a2d0d9-bc8d-4f66-bf9a-084aab06dfa9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:51:01.946419-05	2025-10-13 04:51:03.963552-05	\N	2025-10-13 09:51:00	00:15:00	2025-10-13 04:50:03.946419-05	2025-10-13 04:51:03.972326-05	2025-10-13 04:52:01.946419-05	f	\N	2025-10-13 16:59:15.975072-05
5d2b1c27-9b01-493a-a109-aa654c184ef0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:52:01.971045-05	2025-10-13 04:52:03.985652-05	\N	2025-10-13 09:52:00	00:15:00	2025-10-13 04:51:03.971045-05	2025-10-13 04:52:03.994729-05	2025-10-13 04:53:01.971045-05	f	\N	2025-10-13 16:59:15.975072-05
915eba05-c491-4545-b31c-546352b783eb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:53:01.993317-05	2025-10-13 04:53:04.015811-05	\N	2025-10-13 09:53:00	00:15:00	2025-10-13 04:52:03.993317-05	2025-10-13 04:53:04.024193-05	2025-10-13 04:54:01.993317-05	f	\N	2025-10-13 16:59:15.975072-05
6d226953-8b61-4b87-a069-2a4cf5456552	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:54:01.022862-05	2025-10-13 04:54:04.041841-05	\N	2025-10-13 09:54:00	00:15:00	2025-10-13 04:53:04.022862-05	2025-10-13 04:54:04.052838-05	2025-10-13 04:55:01.022862-05	f	\N	2025-10-13 16:59:15.975072-05
718eabd0-78e1-4528-a9ec-23e5c84c75c8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 04:55:01.051447-05	2025-10-13 04:55:04.066952-05	\N	2025-10-13 09:55:00	00:15:00	2025-10-13 04:54:04.051447-05	2025-10-13 04:55:04.076757-05	2025-10-13 04:56:01.051447-05	f	\N	2025-10-13 16:59:15.975072-05
19e12ab1-1f25-4b35-b482-6c085df64d47	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:54:35.55862-05	2025-10-13 04:55:35.554371-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:52:35.55862-05	2025-10-13 04:55:35.56279-05	2025-10-13 05:02:35.55862-05	f	\N	2025-10-13 16:59:15.975072-05
f1b0a48b-cb33-4b22-a739-61183791455e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 04:57:35.564498-05	2025-10-13 04:58:35.558883-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:55:35.564498-05	2025-10-13 04:58:35.567652-05	2025-10-13 05:05:35.564498-05	f	\N	2025-10-13 16:59:15.975072-05
dc7080e6-fdd4-48f1-a0a0-a18ab7cff258	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:32:01.33465-05	2025-10-12 15:40:06.177977-05	\N	2025-10-12 20:32:00	00:15:00	2025-10-12 15:31:59.33465-05	2025-10-12 15:40:06.324912-05	2025-10-12 15:33:01.33465-05	f	\N	2025-10-13 03:40:35.481429-05
ae151d19-a703-4c9e-84bf-29ff49bf9b3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:40:06.184717-05	2025-10-12 15:40:10.138837-05	\N	2025-10-12 20:40:00	00:15:00	2025-10-12 15:40:06.184717-05	2025-10-12 15:40:10.14784-05	2025-10-12 15:41:06.184717-05	f	\N	2025-10-13 03:40:35.481429-05
8dfa28c6-6d04-4bed-8ed4-1e5029d8f798	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:45:01.796097-05	2025-10-12 15:45:29.247508-05	\N	2025-10-12 20:45:00	00:15:00	2025-10-12 15:44:55.796097-05	2025-10-12 15:45:29.25847-05	2025-10-12 15:46:01.796097-05	f	\N	2025-10-13 03:46:35.491233-05
5d6bab5b-474e-483b-8df6-f74f2c7e511f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:41:01.323007-05	2025-10-12 15:44:51.782606-05	\N	2025-10-12 20:41:00	00:15:00	2025-10-12 15:40:06.323007-05	2025-10-12 15:44:51.794072-05	2025-10-12 15:42:01.323007-05	f	\N	2025-10-13 03:46:35.491233-05
672796bd-01ba-40de-93eb-685cde69ba52	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:44:51.793266-05	2025-10-12 15:44:55.784554-05	\N	2025-10-12 20:44:00	00:15:00	2025-10-12 15:44:51.793266-05	2025-10-12 15:44:55.798149-05	2025-10-12 15:45:51.793266-05	f	\N	2025-10-13 03:46:35.491233-05
457d5351-77a0-4d77-aa28-4f990d43aca1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 15:44:51.795803-05	2025-10-12 15:46:26.901882-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 15:44:51.795803-05	2025-10-12 15:46:26.910223-05	2025-10-12 15:52:51.795803-05	f	\N	2025-10-13 03:46:35.491233-05
9356cb85-9633-4d59-8d8c-c7a2e3deea01	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:46:01.257076-05	2025-10-12 15:46:26.910506-05	\N	2025-10-12 20:46:00	00:15:00	2025-10-12 15:45:29.257076-05	2025-10-12 15:46:26.923974-05	2025-10-12 15:47:01.257076-05	f	\N	2025-10-13 03:46:35.491233-05
53def086-4e12-48bd-95e5-7a43a7627429	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:15:01.659773-05	2025-10-13 02:15:03.684124-05	\N	2025-10-13 07:15:00	00:15:00	2025-10-13 02:14:03.659773-05	2025-10-13 02:15:03.689514-05	2025-10-13 02:16:01.659773-05	f	\N	2025-10-13 14:17:05.829662-05
39a14f2a-96d5-4347-9923-9ee4efdc511f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:14:35.30262-05	2025-10-13 02:15:35.299152-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:12:35.30262-05	2025-10-13 02:15:35.305027-05	2025-10-13 02:22:35.30262-05	f	\N	2025-10-13 14:17:05.829662-05
4f7efe6c-3b81-45e1-9e13-66918ac6cef0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:16:01.688491-05	2025-10-13 02:16:03.710144-05	\N	2025-10-13 07:16:00	00:15:00	2025-10-13 02:15:03.688491-05	2025-10-13 02:16:03.718653-05	2025-10-13 02:17:01.688491-05	f	\N	2025-10-13 14:17:05.829662-05
cfee083c-eb40-4082-9379-3e8a65aadc5e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:17:01.717379-05	2025-10-13 02:17:03.736418-05	\N	2025-10-13 07:17:00	00:15:00	2025-10-13 02:16:03.717379-05	2025-10-13 02:17:03.744494-05	2025-10-13 02:18:01.717379-05	f	\N	2025-10-13 14:17:05.829662-05
0b75fc10-466b-49f6-92e2-7858e83acbaa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:00:35.569461-05	2025-10-13 05:01:35.562512-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 04:58:35.569461-05	2025-10-13 05:01:35.573938-05	2025-10-13 05:08:35.569461-05	f	\N	2025-10-13 17:05:52.831237-05
34a96d20-82a5-4d33-b66d-76f4836a11d3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:03:35.575869-05	2025-10-13 05:04:35.567061-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:01:35.575869-05	2025-10-13 05:04:35.57056-05	2025-10-13 05:11:35.575869-05	f	\N	2025-10-13 17:05:52.831237-05
40d9d992-303f-4bfc-bddf-52ca2b915f9b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:03:01.275366-05	2025-10-13 05:03:04.294001-05	\N	2025-10-13 10:03:00	00:15:00	2025-10-13 05:02:04.275366-05	2025-10-13 05:03:04.303568-05	2025-10-13 05:04:01.275366-05	f	\N	2025-10-13 17:05:52.831237-05
60b7156f-3f78-4254-b928-4b3d9b422b58	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:04:01.30197-05	2025-10-13 05:04:04.321609-05	\N	2025-10-13 10:04:00	00:15:00	2025-10-13 05:03:04.30197-05	2025-10-13 05:04:04.326924-05	2025-10-13 05:05:01.30197-05	f	\N	2025-10-13 17:05:52.831237-05
31081bd4-3ab3-44e1-ba12-b5081d7017c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:05:01.326022-05	2025-10-13 05:05:04.346281-05	\N	2025-10-13 10:05:00	00:15:00	2025-10-13 05:04:04.326022-05	2025-10-13 05:05:04.353546-05	2025-10-13 05:06:01.326022-05	f	\N	2025-10-13 17:05:52.831237-05
b3fde350-733d-40e0-80b1-b2553f32146e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:00:01.197144-05	2025-10-13 05:00:04.214548-05	\N	2025-10-13 10:00:00	00:15:00	2025-10-13 04:59:04.197144-05	2025-10-13 05:00:04.222661-05	2025-10-13 05:01:01.197144-05	f	\N	2025-10-13 17:05:52.831237-05
e292eef3-6b9f-4e85-946d-94891a65547e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:02:01.250975-05	2025-10-13 05:02:04.26963-05	\N	2025-10-13 10:02:00	00:15:00	2025-10-13 05:01:04.250975-05	2025-10-13 05:02:04.276595-05	2025-10-13 05:03:01.250975-05	f	\N	2025-10-13 17:05:52.831237-05
e18a1372-068d-45e3-af85-9e20627b3018	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 05:00:04.217976-05	2025-10-13 05:00:08.217794-05	dailyStatsJob	2025-10-13 10:00:00	00:15:00	2025-10-13 05:00:04.217976-05	2025-10-13 05:00:08.221163-05	2025-10-27 05:00:04.217976-05	f	\N	2025-10-13 17:05:52.831237-05
b9a670ae-2888-4a03-a432-867d68df65a5	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 05:00:08.21981-05	2025-10-13 05:00:08.718105-05	\N	\N	00:15:00	2025-10-13 05:00:08.21981-05	2025-10-13 05:00:08.877628-05	2025-10-27 05:00:08.21981-05	f	\N	2025-10-13 17:05:52.831237-05
e0299b4c-643f-4f64-a91a-da9f691cc744	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:01:01.221611-05	2025-10-13 05:01:04.243156-05	\N	2025-10-13 10:01:00	00:15:00	2025-10-13 05:00:04.221611-05	2025-10-13 05:01:04.25205-05	2025-10-13 05:02:01.221611-05	f	\N	2025-10-13 17:05:52.831237-05
57633c9d-94cf-44e4-966f-d4bd9847b410	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:47:01.922887-05	2025-10-12 15:47:34.649267-05	\N	2025-10-12 20:47:00	00:15:00	2025-10-12 15:46:26.922887-05	2025-10-12 15:47:34.661868-05	2025-10-12 15:48:01.922887-05	f	\N	2025-10-13 03:49:35.494691-05
5532c3a3-9303-4cbe-b4b5-562ef4f7f486	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:36:01.26085-05	2025-10-13 02:36:04.286851-05	\N	2025-10-13 07:36:00	00:15:00	2025-10-13 02:35:04.26085-05	2025-10-13 02:36:04.297497-05	2025-10-13 02:37:01.26085-05	f	\N	2025-10-13 14:41:11.709379-05
6134fc9f-cdc2-4bfb-99ab-5f7c45579961	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:37:01.296289-05	2025-10-13 02:37:04.312928-05	\N	2025-10-13 07:37:00	00:15:00	2025-10-13 02:36:04.296289-05	2025-10-13 02:37:04.320557-05	2025-10-13 02:38:01.296289-05	f	\N	2025-10-13 14:41:11.709379-05
33375ae0-a548-4be3-85d1-83dbdfac63b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:38:01.319596-05	2025-10-13 02:38:04.33852-05	\N	2025-10-13 07:38:00	00:15:00	2025-10-13 02:37:04.319596-05	2025-10-13 02:38:04.349966-05	2025-10-13 02:39:01.319596-05	f	\N	2025-10-13 14:41:11.709379-05
71663d6b-0a77-4332-96b6-178ac0d53a1b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:37:35.364289-05	2025-10-13 02:38:35.361506-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:35:35.364289-05	2025-10-13 02:38:35.369625-05	2025-10-13 02:45:35.364289-05	f	\N	2025-10-13 14:41:11.709379-05
8f03488a-eb6b-4fb7-b1ff-477079f3e25b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:39:01.348468-05	2025-10-13 02:39:04.364408-05	\N	2025-10-13 07:39:00	00:15:00	2025-10-13 02:38:04.348468-05	2025-10-13 02:39:04.368439-05	2025-10-13 02:40:01.348468-05	f	\N	2025-10-13 14:41:11.709379-05
fbd7010b-6b95-4dc4-bbcc-fef8c599d962	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:40:01.367834-05	2025-10-13 02:40:04.390296-05	\N	2025-10-13 07:40:00	00:15:00	2025-10-13 02:39:04.367834-05	2025-10-13 02:40:04.400576-05	2025-10-13 02:41:01.367834-05	f	\N	2025-10-13 14:41:11.709379-05
ceb733db-4e87-4f28-94ad-cc19efff7e44	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:41:01.399299-05	2025-10-13 02:41:04.41541-05	\N	2025-10-13 07:41:00	00:15:00	2025-10-13 02:40:04.399299-05	2025-10-13 02:41:04.425077-05	2025-10-13 02:42:01.399299-05	f	\N	2025-10-13 14:41:11.709379-05
d9d1756b-a491-4e0d-8650-3ed66c72ebbd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:18:01.74339-05	2025-10-13 02:18:03.757562-05	\N	2025-10-13 07:18:00	00:15:00	2025-10-13 02:17:03.74339-05	2025-10-13 02:18:03.768937-05	2025-10-13 02:19:01.74339-05	f	\N	2025-10-13 14:41:11.709379-05
eeb4ed41-2648-4ccf-8c25-06035d8a5c7d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:17:35.306399-05	2025-10-13 02:18:35.303413-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:15:35.306399-05	2025-10-13 02:18:35.311003-05	2025-10-13 02:25:35.306399-05	f	\N	2025-10-13 14:41:11.709379-05
668e3d67-1dcf-4716-8fd5-4395c9278a4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:35:01.234495-05	2025-10-13 02:35:04.25464-05	\N	2025-10-13 07:35:00	00:15:00	2025-10-13 02:34:04.234495-05	2025-10-13 02:35:04.26197-05	2025-10-13 02:36:01.234495-05	f	\N	2025-10-13 14:41:11.709379-05
69cfae8d-10e9-4d08-92da-39d077f76f23	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:34:35.361348-05	2025-10-13 02:35:35.355478-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:32:35.361348-05	2025-10-13 02:35:35.362616-05	2025-10-13 02:42:35.361348-05	f	\N	2025-10-13 14:41:11.709379-05
4a2d069a-f22a-4e42-a7e7-eeede2bcf1dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:19:01.767584-05	2025-10-13 02:19:03.784231-05	\N	2025-10-13 07:19:00	00:15:00	2025-10-13 02:18:03.767584-05	2025-10-13 02:19:03.793351-05	2025-10-13 02:20:01.767584-05	f	\N	2025-10-13 14:41:11.709379-05
2a15d370-70d3-4eed-9c3d-edfad1047f22	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:20:01.792042-05	2025-10-13 02:20:03.832471-05	\N	2025-10-13 07:20:00	00:15:00	2025-10-13 02:19:03.792042-05	2025-10-13 02:20:03.840392-05	2025-10-13 02:21:01.792042-05	f	\N	2025-10-13 14:41:11.709379-05
614d8495-61d5-4314-9317-78178c7e22e0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:20:35.312132-05	2025-10-13 02:20:35.330894-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:18:35.312132-05	2025-10-13 02:20:35.334881-05	2025-10-13 02:28:35.312132-05	f	\N	2025-10-13 14:41:11.709379-05
b82d4dd7-10f1-42d9-a163-102bebfd464f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:21:01.839131-05	2025-10-13 02:21:03.864291-05	\N	2025-10-13 07:21:00	00:15:00	2025-10-13 02:20:03.839131-05	2025-10-13 02:21:03.875794-05	2025-10-13 02:22:01.839131-05	f	\N	2025-10-13 14:41:11.709379-05
2c3e57cb-14fd-44a3-a18f-f97808112b90	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:22:01.874112-05	2025-10-13 02:22:03.894403-05	\N	2025-10-13 07:22:00	00:15:00	2025-10-13 02:21:03.874112-05	2025-10-13 02:22:03.902801-05	2025-10-13 02:23:01.874112-05	f	\N	2025-10-13 14:41:11.709379-05
4fb0402d-0706-4ba0-a49c-4618ad029eff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:23:01.901642-05	2025-10-13 02:23:03.920941-05	\N	2025-10-13 07:23:00	00:15:00	2025-10-13 02:22:03.901642-05	2025-10-13 02:23:03.928841-05	2025-10-13 02:24:01.901642-05	f	\N	2025-10-13 14:41:11.709379-05
27282d1f-d83f-446a-8652-0772eece9627	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:22:35.335843-05	2025-10-13 02:23:35.334358-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:20:35.335843-05	2025-10-13 02:23:35.33884-05	2025-10-13 02:30:35.335843-05	f	\N	2025-10-13 14:41:11.709379-05
ba6d81a6-49d4-4919-b357-00ea6e5a0f4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:24:01.927624-05	2025-10-13 02:24:03.942937-05	\N	2025-10-13 07:24:00	00:15:00	2025-10-13 02:23:03.927624-05	2025-10-13 02:24:03.949995-05	2025-10-13 02:25:01.927624-05	f	\N	2025-10-13 14:41:11.709379-05
0799e2fc-1208-40be-8f39-a9f9b88de5b8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:25:01.948983-05	2025-10-13 02:25:03.968695-05	\N	2025-10-13 07:25:00	00:15:00	2025-10-13 02:24:03.948983-05	2025-10-13 02:25:03.977983-05	2025-10-13 02:26:01.948983-05	f	\N	2025-10-13 14:41:11.709379-05
05cf1b02-a518-4f0d-8cb3-b99bf32c58ac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:26:01.976884-05	2025-10-13 02:26:03.998113-05	\N	2025-10-13 07:26:00	00:15:00	2025-10-13 02:25:03.976884-05	2025-10-13 02:26:04.007987-05	2025-10-13 02:27:01.976884-05	f	\N	2025-10-13 14:41:11.709379-05
135634f0-cda4-4353-b76c-d29e7b41360f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:25:35.340387-05	2025-10-13 02:26:35.339535-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:23:35.340387-05	2025-10-13 02:26:35.346831-05	2025-10-13 02:33:35.340387-05	f	\N	2025-10-13 14:41:11.709379-05
0b694b41-0082-404f-b583-f630d6dfdb17	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:27:01.00648-05	2025-10-13 02:27:04.025717-05	\N	2025-10-13 07:27:00	00:15:00	2025-10-13 02:26:04.00648-05	2025-10-13 02:27:04.0311-05	2025-10-13 02:28:01.00648-05	f	\N	2025-10-13 14:41:11.709379-05
57a84907-4ea0-4132-95a2-48f784bf5f38	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:28:01.030472-05	2025-10-13 02:28:04.054718-05	\N	2025-10-13 07:28:00	00:15:00	2025-10-13 02:27:04.030472-05	2025-10-13 02:28:04.065139-05	2025-10-13 02:29:01.030472-05	f	\N	2025-10-13 14:41:11.709379-05
fddc04bd-7d31-4848-bba1-42ece82def69	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:29:01.063672-05	2025-10-13 02:29:04.079932-05	\N	2025-10-13 07:29:00	00:15:00	2025-10-13 02:28:04.063672-05	2025-10-13 02:29:04.085796-05	2025-10-13 02:30:01.063672-05	f	\N	2025-10-13 14:41:11.709379-05
05798d59-66e5-4f6d-9200-b524d22ecaba	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:28:35.348623-05	2025-10-13 02:29:35.344827-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:26:35.348623-05	2025-10-13 02:29:35.351856-05	2025-10-13 02:36:35.348623-05	f	\N	2025-10-13 14:41:11.709379-05
00f68d29-0b7f-49c2-92a8-ffca4c762f46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:30:01.085082-05	2025-10-13 02:30:04.113041-05	\N	2025-10-13 07:30:00	00:15:00	2025-10-13 02:29:04.085082-05	2025-10-13 02:30:04.124536-05	2025-10-13 02:31:01.085082-05	f	\N	2025-10-13 14:41:11.709379-05
5623117d-3f83-44f6-bf8d-0b70d30ca8e7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:31:01.122819-05	2025-10-13 02:31:04.140526-05	\N	2025-10-13 07:31:00	00:15:00	2025-10-13 02:30:04.122819-05	2025-10-13 02:31:04.150284-05	2025-10-13 02:32:01.122819-05	f	\N	2025-10-13 14:41:11.709379-05
a625ed7f-d7b8-428d-b554-5dbf6dea359e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:32:01.148989-05	2025-10-13 02:32:04.16938-05	\N	2025-10-13 07:32:00	00:15:00	2025-10-13 02:31:04.148989-05	2025-10-13 02:32:04.180114-05	2025-10-13 02:33:01.148989-05	f	\N	2025-10-13 14:41:11.709379-05
638666bc-bb78-4c4a-abcb-121406b8667c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:31:35.353531-05	2025-10-13 02:32:35.349873-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:29:35.353531-05	2025-10-13 02:32:35.359335-05	2025-10-13 02:39:35.353531-05	f	\N	2025-10-13 14:41:11.709379-05
413de979-56eb-4a72-8407-261b7f1b8863	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:33:01.178569-05	2025-10-13 02:33:04.199111-05	\N	2025-10-13 07:33:00	00:15:00	2025-10-13 02:32:04.178569-05	2025-10-13 02:33:04.208583-05	2025-10-13 02:34:01.178569-05	f	\N	2025-10-13 14:41:11.709379-05
e37e2055-59db-4754-a711-85c73d5aecc4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:34:01.207497-05	2025-10-13 02:34:04.225649-05	\N	2025-10-13 07:34:00	00:15:00	2025-10-13 02:33:04.207497-05	2025-10-13 02:34:04.236179-05	2025-10-13 02:35:01.207497-05	f	\N	2025-10-13 14:41:11.709379-05
f5503c5a-e18f-4673-951a-6b7b4c18b61c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:06:35.571464-05	2025-10-13 05:07:35.572281-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:04:35.571464-05	2025-10-13 05:07:35.578423-05	2025-10-13 05:14:35.571464-05	f	\N	2025-10-13 17:08:52.823937-05
f7f99dbf-8e61-4a10-ad54-7e0eaa8c18f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:06:01.352443-05	2025-10-13 05:06:04.374354-05	\N	2025-10-13 10:06:00	00:15:00	2025-10-13 05:05:04.352443-05	2025-10-13 05:06:04.382738-05	2025-10-13 05:07:01.352443-05	f	\N	2025-10-13 17:08:52.823937-05
62ae41c1-a4cb-4fdc-b7b5-250468d50c15	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:07:01.381324-05	2025-10-13 05:07:04.405672-05	\N	2025-10-13 10:07:00	00:15:00	2025-10-13 05:06:04.381324-05	2025-10-13 05:07:04.415828-05	2025-10-13 05:08:01.381324-05	f	\N	2025-10-13 17:08:52.823937-05
0ea3eb31-6b89-46bb-afd3-de17dc9ed36b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:08:01.41406-05	2025-10-13 05:08:04.432413-05	\N	2025-10-13 10:08:00	00:15:00	2025-10-13 05:07:04.41406-05	2025-10-13 05:08:04.442529-05	2025-10-13 05:09:01.41406-05	f	\N	2025-10-13 17:08:52.823937-05
59972ffd-aff7-4f91-bafe-3231d3e2f024	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:16:01.6654-05	2025-10-13 05:16:04.685289-05	\N	2025-10-13 10:16:00	00:15:00	2025-10-13 05:15:04.6654-05	2025-10-13 05:16:04.695418-05	2025-10-13 05:17:01.6654-05	f	\N	2025-10-13 17:17:52.827369-05
0ef71d05-20a7-4dbc-b261-09114287140e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:15:01.634403-05	2025-10-13 05:15:04.655554-05	\N	2025-10-13 10:15:00	00:15:00	2025-10-13 05:14:04.634403-05	2025-10-13 05:15:04.667326-05	2025-10-13 05:16:01.634403-05	f	\N	2025-10-13 17:17:52.827369-05
ba429f37-98ff-4516-b257-39c653ef7b05	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:14:35.619733-05	2025-10-13 05:15:35.616791-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:12:35.619733-05	2025-10-13 05:15:35.625819-05	2025-10-13 05:22:35.619733-05	f	\N	2025-10-13 17:17:52.827369-05
8d9c69b9-b0aa-415e-a1d4-4f244132b92a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:17:01.693854-05	2025-10-13 05:17:04.712227-05	\N	2025-10-13 10:17:00	00:15:00	2025-10-13 05:16:04.693854-05	2025-10-13 05:17:04.718295-05	2025-10-13 05:18:01.693854-05	f	\N	2025-10-13 17:17:52.827369-05
1141997e-666d-46c5-9385-d635c658a235	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:07:01.782633-05	2025-10-12 16:07:03.785788-05	\N	2025-10-12 21:07:00	00:15:00	2025-10-12 16:06:07.782633-05	2025-10-12 16:07:03.796739-05	2025-10-12 16:08:01.782633-05	f	\N	2025-10-13 04:07:35.508709-05
32f93a0e-eb70-4533-839f-8441d05b1f22	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 15:48:01.660528-05	2025-10-12 16:05:22.286908-05	\N	2025-10-12 20:48:00	00:15:00	2025-10-12 15:47:34.660528-05	2025-10-12 16:05:22.291668-05	2025-10-12 15:49:01.660528-05	f	\N	2025-10-13 04:07:35.508709-05
7d4621f0-db10-48bd-8d1d-b34926ee880b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:05:22.290812-05	2025-10-12 16:05:26.277223-05	\N	2025-10-12 21:05:00	00:15:00	2025-10-12 16:05:22.290812-05	2025-10-12 16:05:26.289252-05	2025-10-12 16:06:22.290812-05	f	\N	2025-10-13 04:07:35.508709-05
bd154f1c-0b1c-4159-873c-481b082aa446	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:06:01.287946-05	2025-10-12 16:06:07.768506-05	\N	2025-10-12 21:06:00	00:15:00	2025-10-12 16:05:26.287946-05	2025-10-12 16:06:07.783944-05	2025-10-12 16:07:01.287946-05	f	\N	2025-10-13 04:07:35.508709-05
e2e49053-0e69-4689-b2bd-58d2202a27de	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:05:22.298816-05	2025-10-12 16:06:22.278636-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:05:22.298816-05	2025-10-12 16:06:22.285294-05	2025-10-12 16:13:22.298816-05	f	\N	2025-10-13 04:07:35.508709-05
da2c16a0-c20c-4389-968f-8fe6c7698a49	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:13:01.858455-05	2025-10-12 16:13:03.867256-05	\N	2025-10-12 21:13:00	00:15:00	2025-10-12 16:12:03.858455-05	2025-10-12 16:13:03.8744-05	2025-10-12 16:14:01.858455-05	f	\N	2025-10-13 04:13:35.517192-05
f757f8f7-3a49-4a18-b80f-4e4b9d37c53e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:11:01.837834-05	2025-10-12 16:11:03.840155-05	\N	2025-10-12 21:11:00	00:15:00	2025-10-12 16:10:03.837834-05	2025-10-12 16:11:03.852206-05	2025-10-12 16:12:01.837834-05	f	\N	2025-10-13 04:13:35.517192-05
0502595d-3e1f-4d27-be13-4f1db00bddfe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:11:22.287544-05	2025-10-12 16:12:22.284011-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:09:22.287544-05	2025-10-12 16:12:22.294248-05	2025-10-12 16:19:22.287544-05	f	\N	2025-10-13 04:13:35.517192-05
929856f8-3e76-4111-b64b-8087f308257f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:12:01.85097-05	2025-10-12 16:12:03.852384-05	\N	2025-10-12 21:12:00	00:15:00	2025-10-12 16:11:03.85097-05	2025-10-12 16:12:03.859664-05	2025-10-12 16:13:01.85097-05	f	\N	2025-10-13 04:13:35.517192-05
cf865cd4-1d6b-4364-81fc-dc28bb3a6eb6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:14:01.87339-05	2025-10-12 16:14:03.884605-05	\N	2025-10-12 21:14:00	00:15:00	2025-10-12 16:13:03.87339-05	2025-10-12 16:14:03.893652-05	2025-10-12 16:15:01.87339-05	f	\N	2025-10-13 04:16:35.520867-05
bbda0e5e-1eb5-4227-a99d-708d50c600c8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:15:01.892179-05	2025-10-12 16:15:03.90016-05	\N	2025-10-12 21:15:00	00:15:00	2025-10-12 16:14:03.892179-05	2025-10-12 16:15:03.908744-05	2025-10-12 16:16:01.892179-05	f	\N	2025-10-13 04:16:35.520867-05
c9fb79c7-6847-4014-8d78-ce98c68d843b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:14:22.296238-05	2025-10-12 16:15:22.281853-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:12:22.296238-05	2025-10-12 16:15:22.284065-05	2025-10-12 16:22:22.296238-05	f	\N	2025-10-13 04:16:35.520867-05
300d551d-e2ec-4903-9ad7-7b5252b48f4b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:16:01.907483-05	2025-10-12 16:16:03.913321-05	\N	2025-10-12 21:16:00	00:15:00	2025-10-12 16:15:03.907483-05	2025-10-12 16:16:03.923537-05	2025-10-12 16:17:01.907483-05	f	\N	2025-10-13 04:16:35.520867-05
83ba5784-6705-4429-a1f4-9f29616de7a2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:21:30.915442-05	2025-10-12 16:22:30.910346-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:19:30.915442-05	2025-10-12 16:22:30.91905-05	2025-10-12 16:29:30.915442-05	f	\N	2025-10-13 04:22:35.530876-05
8f62a08c-52ae-423d-ba98-f1f156f123aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:20:01.933323-05	2025-10-12 16:20:02.924728-05	\N	2025-10-12 21:20:00	00:15:00	2025-10-12 16:19:34.933323-05	2025-10-12 16:20:02.935972-05	2025-10-12 16:21:01.933323-05	f	\N	2025-10-13 04:22:35.530876-05
6780182c-8ca2-40c0-9a91-b87b6d108acf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:21:01.934325-05	2025-10-12 16:21:02.939465-05	\N	2025-10-12 21:21:00	00:15:00	2025-10-12 16:20:02.934325-05	2025-10-12 16:21:02.950565-05	2025-10-12 16:22:01.934325-05	f	\N	2025-10-13 04:22:35.530876-05
50ae59a8-d661-46f6-99a1-4b17d1816268	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:22:01.949414-05	2025-10-12 16:22:02.952178-05	\N	2025-10-12 21:22:00	00:15:00	2025-10-12 16:21:02.949414-05	2025-10-12 16:22:02.967863-05	2025-10-12 16:23:01.949414-05	f	\N	2025-10-13 04:22:35.530876-05
c53cc21f-9c8b-4da2-92cc-9c02cb2ce2c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:24:01.971407-05	2025-10-12 16:24:02.977608-05	\N	2025-10-12 21:24:00	00:15:00	2025-10-12 16:23:02.971407-05	2025-10-12 16:24:02.987067-05	2025-10-12 16:25:01.971407-05	f	\N	2025-10-13 04:25:35.532024-05
932a2307-8f2f-4966-bc60-895f4e6b2ac0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:25:01.985568-05	2025-10-12 16:25:02.995581-05	\N	2025-10-12 21:25:00	00:15:00	2025-10-12 16:24:02.985568-05	2025-10-12 16:25:03.011789-05	2025-10-12 16:26:01.985568-05	f	\N	2025-10-13 04:25:35.532024-05
8626419d-f329-4404-94ed-8bb6b12ec640	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:23:01.96642-05	2025-10-12 16:23:02.964509-05	\N	2025-10-12 21:23:00	00:15:00	2025-10-12 16:22:02.96642-05	2025-10-12 16:23:02.972349-05	2025-10-12 16:24:01.96642-05	f	\N	2025-10-13 04:25:35.532024-05
31445e53-0178-48c1-b236-ddf3802624f5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:24:30.921115-05	2025-10-12 16:25:30.912277-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:22:30.921115-05	2025-10-12 16:25:30.922819-05	2025-10-12 16:32:30.921115-05	f	\N	2025-10-13 04:25:35.532024-05
104bbfc5-be18-4a41-a710-4051b7567674	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:32:01.09824-05	2025-10-12 16:32:03.101419-05	\N	2025-10-12 21:32:00	00:15:00	2025-10-12 16:31:03.09824-05	2025-10-12 16:32:03.113016-05	2025-10-12 16:33:01.09824-05	f	\N	2025-10-13 04:34:35.534098-05
548a561a-3a7b-4c62-8433-c24634db417a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:33:01.111813-05	2025-10-12 16:33:03.114836-05	\N	2025-10-12 21:33:00	00:15:00	2025-10-12 16:32:03.111813-05	2025-10-12 16:33:03.122465-05	2025-10-12 16:34:01.111813-05	f	\N	2025-10-13 04:34:35.534098-05
0699b094-6e02-4ae2-9729-b16369e9327b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:34:01.121251-05	2025-10-12 16:34:03.125857-05	\N	2025-10-12 21:34:00	00:15:00	2025-10-12 16:33:03.121251-05	2025-10-12 16:34:03.138421-05	2025-10-12 16:35:01.121251-05	f	\N	2025-10-13 04:34:35.534098-05
a18266ad-0af8-4f3a-a2c5-3a40e304c1ed	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:33:30.923817-05	2025-10-12 16:34:30.924412-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:31:30.923817-05	2025-10-12 16:34:30.930789-05	2025-10-12 16:41:30.923817-05	f	\N	2025-10-13 04:34:35.534098-05
12380cfe-aa95-4a23-8cb5-f26799f72e8e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:38:01.188022-05	2025-10-12 16:38:03.197727-05	\N	2025-10-12 21:38:00	00:15:00	2025-10-12 16:37:03.188022-05	2025-10-12 16:38:03.208603-05	2025-10-12 16:39:01.188022-05	f	\N	2025-10-13 04:40:35.542059-05
f60366f6-efa8-42b2-a66e-f0bd5f69d5a2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:40:01.220376-05	2025-10-12 16:40:03.228358-05	\N	2025-10-12 21:40:00	00:15:00	2025-10-12 16:39:03.220376-05	2025-10-12 16:40:03.23902-05	2025-10-12 16:41:01.220376-05	f	\N	2025-10-13 04:40:35.542059-05
cc2abfe2-2cef-4b16-9baf-aa9c8805d7b5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:39:30.934218-05	2025-10-12 16:40:30.931524-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:37:30.934218-05	2025-10-12 16:40:30.936816-05	2025-10-12 16:47:30.934218-05	f	\N	2025-10-13 04:40:35.542059-05
0ea5060f-3d4b-4ad5-8a27-37a91f1c0d57	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:39:01.207791-05	2025-10-12 16:39:03.211379-05	\N	2025-10-12 21:39:00	00:15:00	2025-10-12 16:38:03.207791-05	2025-10-12 16:39:03.221591-05	2025-10-12 16:40:01.207791-05	f	\N	2025-10-13 04:40:35.542059-05
c069dba5-782d-4e94-9bfb-508c9d6a6e84	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:42:01.423712-05	2025-10-13 02:42:04.445199-05	\N	2025-10-13 07:42:00	00:15:00	2025-10-13 02:41:04.423712-05	2025-10-13 02:42:04.455374-05	2025-10-13 02:43:01.423712-05	f	\N	2025-10-13 14:49:13.402004-05
47100625-a98e-46e1-bb16-2cee3219f60d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:40:35.371665-05	2025-10-13 02:41:35.364931-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:38:35.371665-05	2025-10-13 02:41:35.371125-05	2025-10-13 02:48:35.371665-05	f	\N	2025-10-13 14:49:13.402004-05
63372613-798e-4d65-b478-21583db75566	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:43:01.454008-05	2025-10-13 02:43:04.472708-05	\N	2025-10-13 07:43:00	00:15:00	2025-10-13 02:42:04.454008-05	2025-10-13 02:43:04.484239-05	2025-10-13 02:44:01.454008-05	f	\N	2025-10-13 14:49:13.402004-05
bf16e395-6a0c-44d1-ac2d-46b99b9b52da	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:44:01.48258-05	2025-10-13 02:44:04.49604-05	\N	2025-10-13 07:44:00	00:15:00	2025-10-13 02:43:04.48258-05	2025-10-13 02:44:04.507152-05	2025-10-13 02:45:01.48258-05	f	\N	2025-10-13 14:49:13.402004-05
8590e31d-2197-4d47-884a-d163db17d7cd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:43:35.372566-05	2025-10-13 02:44:35.368188-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:41:35.372566-05	2025-10-13 02:44:35.375886-05	2025-10-13 02:51:35.372566-05	f	\N	2025-10-13 14:49:13.402004-05
c403a01d-0e97-4610-b1d5-ecdbc8b0ecf2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:45:01.505734-05	2025-10-13 02:45:04.522936-05	\N	2025-10-13 07:45:00	00:15:00	2025-10-13 02:44:04.505734-05	2025-10-13 02:45:04.534147-05	2025-10-13 02:46:01.505734-05	f	\N	2025-10-13 14:49:13.402004-05
c0cfc064-6130-4ddb-8a6e-fcfcd2d23ff0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:46:01.532575-05	2025-10-13 02:46:04.563431-05	\N	2025-10-13 07:46:00	00:15:00	2025-10-13 02:45:04.532575-05	2025-10-13 02:46:04.57505-05	2025-10-13 02:47:01.532575-05	f	\N	2025-10-13 14:49:13.402004-05
970438e6-297b-4e18-94cc-7b932b653729	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:46:35.377749-05	2025-10-13 02:46:35.380207-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:44:35.377749-05	2025-10-13 02:46:35.386342-05	2025-10-13 02:54:35.377749-05	f	\N	2025-10-13 14:49:13.402004-05
060f9273-7d4e-4f18-8798-852121b9b362	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:47:01.57348-05	2025-10-13 02:47:04.595581-05	\N	2025-10-13 07:47:00	00:15:00	2025-10-13 02:46:04.57348-05	2025-10-13 02:47:04.602482-05	2025-10-13 02:48:01.57348-05	f	\N	2025-10-13 14:49:13.402004-05
6bd81c32-e1be-49ca-8399-3e3ba011ec60	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:49:01.631382-05	2025-10-13 02:49:04.653742-05	\N	2025-10-13 07:49:00	00:15:00	2025-10-13 02:48:04.631382-05	2025-10-13 02:49:04.668676-05	2025-10-13 02:50:01.631382-05	f	\N	2025-10-13 14:49:13.402004-05
8990818f-eeb6-4a0d-adb3-b6e70fdd715b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:48:01.60144-05	2025-10-13 02:48:04.622481-05	\N	2025-10-13 07:48:00	00:15:00	2025-10-13 02:47:04.60144-05	2025-10-13 02:48:04.632665-05	2025-10-13 02:49:01.60144-05	f	\N	2025-10-13 14:49:13.402004-05
7c2e8896-b242-4f37-b4e3-ef4b9f5c3719	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:10:01.469437-05	2025-10-13 05:10:04.489531-05	\N	2025-10-13 10:10:00	00:15:00	2025-10-13 05:09:04.469437-05	2025-10-13 05:10:04.498476-05	2025-10-13 05:11:01.469437-05	f	\N	2025-10-13 17:11:52.828503-05
d33efd52-8bc7-4d30-8d96-d204626bb795	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:09:01.441132-05	2025-10-13 05:09:04.459499-05	\N	2025-10-13 10:09:00	00:15:00	2025-10-13 05:08:04.441132-05	2025-10-13 05:09:04.471084-05	2025-10-13 05:10:01.441132-05	f	\N	2025-10-13 17:11:52.828503-05
f31297ed-6836-46ee-8a42-bf9f8881c7e8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:09:35.579155-05	2025-10-13 05:10:35.576541-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:07:35.579155-05	2025-10-13 05:10:35.581868-05	2025-10-13 05:17:35.579155-05	f	\N	2025-10-13 17:11:52.828503-05
f31cefe8-8238-450e-bb03-c49438276a0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:11:01.497104-05	2025-10-13 05:11:04.51716-05	\N	2025-10-13 10:11:00	00:15:00	2025-10-13 05:10:04.497104-05	2025-10-13 05:11:04.52584-05	2025-10-13 05:12:01.497104-05	f	\N	2025-10-13 17:11:52.828503-05
f7cba806-324f-4065-9ee6-fa320ea12b90	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:12:35.582629-05	2025-10-13 05:12:35.611492-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:10:35.582629-05	2025-10-13 05:12:35.61837-05	2025-10-13 05:20:35.582629-05	f	\N	2025-10-13 17:14:52.825451-05
03fcae6e-1a4c-41fb-a96e-0008f572dac3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:08:22.286389-05	2025-10-12 16:09:22.281259-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:06:22.286389-05	2025-10-12 16:09:22.28654-05	2025-10-12 16:16:22.286389-05	f	\N	2025-10-13 04:10:35.514173-05
8e32d9a4-7e4d-45ab-9e81-2264777dcca2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:08:01.79554-05	2025-10-12 16:08:03.801079-05	\N	2025-10-12 21:08:00	00:15:00	2025-10-12 16:07:03.79554-05	2025-10-12 16:08:03.806823-05	2025-10-12 16:09:01.79554-05	f	\N	2025-10-13 04:10:35.514173-05
2f0a776c-05b4-4074-835c-3d00b1628a0e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:10:01.824342-05	2025-10-12 16:10:03.830571-05	\N	2025-10-12 21:10:00	00:15:00	2025-10-12 16:09:03.824342-05	2025-10-12 16:10:03.839611-05	2025-10-12 16:11:01.824342-05	f	\N	2025-10-13 04:10:35.514173-05
387784ec-be66-427c-a6b0-654c6adb805f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:09:01.805806-05	2025-10-12 16:09:03.816021-05	\N	2025-10-12 21:09:00	00:15:00	2025-10-12 16:08:03.805806-05	2025-10-12 16:09:03.825718-05	2025-10-12 16:10:01.805806-05	f	\N	2025-10-13 04:10:35.514173-05
d284a366-252e-48fa-9c01-87e9e0447f1a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:19:30.906757-05	2025-10-12 16:19:30.908992-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:19:30.906757-05	2025-10-12 16:19:30.914487-05	2025-10-12 16:27:30.906757-05	f	\N	2025-10-13 04:19:35.524431-05
2b4bb4b1-c0e5-4fcf-8b61-74c689ab06ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:19:30.916667-05	2025-10-12 16:19:34.91631-05	\N	2025-10-12 21:19:00	00:15:00	2025-10-12 16:19:30.916667-05	2025-10-12 16:19:34.93438-05	2025-10-12 16:20:30.916667-05	f	\N	2025-10-13 04:19:35.524431-05
4e301d28-86ac-4126-8a93-47c89ebe1f6b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:27:01.019081-05	2025-10-12 16:27:03.029095-05	\N	2025-10-12 21:27:00	00:15:00	2025-10-12 16:26:03.019081-05	2025-10-12 16:27:03.042275-05	2025-10-12 16:28:01.019081-05	f	\N	2025-10-13 04:28:35.534366-05
03b34c84-045c-4508-a4e2-c6d44630e896	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:26:01.01003-05	2025-10-12 16:26:03.012026-05	\N	2025-10-12 21:26:00	00:15:00	2025-10-12 16:25:03.01003-05	2025-10-12 16:26:03.020094-05	2025-10-12 16:27:01.01003-05	f	\N	2025-10-13 04:28:35.534366-05
cc3d840d-8aaa-4929-9480-38d1688b230e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:27:30.924687-05	2025-10-12 16:28:30.912927-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:25:30.924687-05	2025-10-12 16:28:30.921464-05	2025-10-12 16:35:30.924687-05	f	\N	2025-10-13 04:28:35.534366-05
5baa426c-ce5d-4ed2-80e7-c60876c2a34c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:28:01.040849-05	2025-10-12 16:28:03.046701-05	\N	2025-10-12 21:28:00	00:15:00	2025-10-12 16:27:03.040849-05	2025-10-12 16:28:03.060723-05	2025-10-12 16:29:01.040849-05	f	\N	2025-10-13 04:28:35.534366-05
cf130aaf-3c0b-4f6d-b1d2-d04984184875	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:31:01.079107-05	2025-10-12 16:31:03.087543-05	\N	2025-10-12 21:31:00	00:15:00	2025-10-12 16:30:03.079107-05	2025-10-12 16:31:03.099611-05	2025-10-12 16:32:01.079107-05	f	\N	2025-10-13 04:31:35.529232-05
ca097212-ea55-4c73-a17c-009fa0fc9d17	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:30:30.9231-05	2025-10-12 16:31:30.917718-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:28:30.9231-05	2025-10-12 16:31:30.922336-05	2025-10-12 16:38:30.9231-05	f	\N	2025-10-13 04:31:35.529232-05
234bc7c6-fc76-4e0d-a202-4ac9ae6970f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:29:01.059186-05	2025-10-12 16:29:03.057303-05	\N	2025-10-12 21:29:00	00:15:00	2025-10-12 16:28:03.059186-05	2025-10-12 16:29:03.068811-05	2025-10-12 16:30:01.059186-05	f	\N	2025-10-13 04:31:35.529232-05
920f7265-47c0-4a31-99d2-fd1305366d4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:30:01.067415-05	2025-10-12 16:30:03.069889-05	\N	2025-10-12 21:30:00	00:15:00	2025-10-12 16:29:03.067415-05	2025-10-12 16:30:03.080572-05	2025-10-12 16:31:01.067415-05	f	\N	2025-10-13 04:31:35.529232-05
baf3bf93-0d77-4473-b5b2-45ee111c1b08	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:35:01.137111-05	2025-10-12 16:35:03.149021-05	\N	2025-10-12 21:35:00	00:15:00	2025-10-12 16:34:03.137111-05	2025-10-12 16:35:03.160694-05	2025-10-12 16:36:01.137111-05	f	\N	2025-10-13 04:37:35.536699-05
bcf559b0-eeae-4744-ae57-616f27f2bc0a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:36:30.931939-05	2025-10-12 16:37:30.928567-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:34:30.931939-05	2025-10-12 16:37:30.932805-05	2025-10-12 16:44:30.931939-05	f	\N	2025-10-13 04:37:35.536699-05
7fce41aa-0654-4c72-b167-0ef66c9220fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:36:01.159393-05	2025-10-12 16:36:03.166512-05	\N	2025-10-12 21:36:00	00:15:00	2025-10-12 16:35:03.159393-05	2025-10-12 16:36:03.179655-05	2025-10-12 16:37:01.159393-05	f	\N	2025-10-13 04:37:35.536699-05
8bccb122-0546-47c1-9880-f179039a1fa8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:37:01.178752-05	2025-10-12 16:37:03.183762-05	\N	2025-10-12 21:37:00	00:15:00	2025-10-12 16:36:03.178752-05	2025-10-12 16:37:03.188618-05	2025-10-12 16:38:01.178752-05	f	\N	2025-10-13 04:37:35.536699-05
b04b47f7-9de5-4b7a-b57a-e430bf3b08e3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:48:35.387904-05	2025-10-13 02:49:35.387795-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:46:35.387904-05	2025-10-13 02:49:35.395622-05	2025-10-13 02:56:35.387904-05	f	\N	2025-10-13 14:55:58.386166-05
a38fedd8-2cbc-4539-96e6-b51c9c14f055	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:50:01.666543-05	2025-10-13 02:50:04.678494-05	\N	2025-10-13 07:50:00	00:15:00	2025-10-13 02:49:04.666543-05	2025-10-13 02:50:04.689978-05	2025-10-13 02:51:01.666543-05	f	\N	2025-10-13 14:55:58.386166-05
aaf54519-2ffb-4c6d-927e-d9a17fcfb2e5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:52:01.719109-05	2025-10-13 02:52:04.737283-05	\N	2025-10-13 07:52:00	00:15:00	2025-10-13 02:51:04.719109-05	2025-10-13 02:52:04.749057-05	2025-10-13 02:53:01.719109-05	f	\N	2025-10-13 14:55:58.386166-05
a41efc60-b741-4ceb-9629-7abea1add0cb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:51:01.68826-05	2025-10-13 02:51:04.707957-05	\N	2025-10-13 07:51:00	00:15:00	2025-10-13 02:50:04.68826-05	2025-10-13 02:51:04.720701-05	2025-10-13 02:52:01.68826-05	f	\N	2025-10-13 14:55:58.386166-05
d83cc33d-4a4e-4cd6-96f9-f0381786b138	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:51:35.397414-05	2025-10-13 02:52:35.392704-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:49:35.397414-05	2025-10-13 02:52:35.401729-05	2025-10-13 02:59:35.397414-05	f	\N	2025-10-13 14:55:58.386166-05
604f99e8-df66-4923-9cf2-934fcded9ae3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:53:01.747584-05	2025-10-13 02:53:04.764981-05	\N	2025-10-13 07:53:00	00:15:00	2025-10-13 02:52:04.747584-05	2025-10-13 02:53:04.773196-05	2025-10-13 02:54:01.747584-05	f	\N	2025-10-13 14:55:58.386166-05
6d3e3e78-e63a-4ed4-8c05-e2dc0b59fea0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:54:01.772128-05	2025-10-13 02:54:04.793421-05	\N	2025-10-13 07:54:00	00:15:00	2025-10-13 02:53:04.772128-05	2025-10-13 02:54:04.805182-05	2025-10-13 02:55:01.772128-05	f	\N	2025-10-13 14:55:58.386166-05
68d016f4-c013-4667-aab1-16d6bfb8dbc7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:54:35.40337-05	2025-10-13 02:55:35.397382-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:52:35.40337-05	2025-10-13 02:55:35.405365-05	2025-10-13 03:02:35.40337-05	f	\N	2025-10-13 14:55:58.386166-05
f4b690a1-6f6b-4898-aca8-450badb35344	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:55:01.803612-05	2025-10-13 02:55:04.819422-05	\N	2025-10-13 07:55:00	00:15:00	2025-10-13 02:54:04.803612-05	2025-10-13 02:55:04.833454-05	2025-10-13 02:56:01.803612-05	f	\N	2025-10-13 14:55:58.386166-05
a400fe0d-582a-47cd-9440-fb72e8965eef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:13:01.58005-05	2025-10-13 05:13:04.600273-05	\N	2025-10-13 10:13:00	00:15:00	2025-10-13 05:12:04.58005-05	2025-10-13 05:13:04.607679-05	2025-10-13 05:14:01.58005-05	f	\N	2025-10-13 17:14:52.825451-05
40f40bdc-fb24-43b8-ac38-802e32bc71df	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:12:01.524528-05	2025-10-13 05:12:04.570807-05	\N	2025-10-13 10:12:00	00:15:00	2025-10-13 05:11:04.524528-05	2025-10-13 05:12:04.582999-05	2025-10-13 05:13:01.524528-05	f	\N	2025-10-13 17:14:52.825451-05
50449dff-1d6e-40c7-911b-c43a953972fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:14:01.606491-05	2025-10-13 05:14:04.625467-05	\N	2025-10-13 10:14:00	00:15:00	2025-10-13 05:13:04.606491-05	2025-10-13 05:14:04.636221-05	2025-10-13 05:15:01.606491-05	f	\N	2025-10-13 17:14:52.825451-05
431657c6-7263-4ba4-844b-9f0f0254b314	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:18:01.716992-05	2025-10-13 05:18:04.736237-05	\N	2025-10-13 10:18:00	00:15:00	2025-10-13 05:17:04.716992-05	2025-10-13 05:18:04.740119-05	2025-10-13 05:19:01.716992-05	f	\N	2025-10-13 17:20:52.823805-05
8bb8d254-dcf6-4e0a-9f60-6e5811b768a3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:17:35.627715-05	2025-10-13 05:18:35.622963-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:15:35.627715-05	2025-10-13 05:18:35.632063-05	2025-10-13 05:25:35.627715-05	f	\N	2025-10-13 17:20:52.823805-05
4ad133f6-d35e-41df-9b2a-4db1fa51a6ca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:19:01.739306-05	2025-10-13 05:19:04.763388-05	\N	2025-10-13 10:19:00	00:15:00	2025-10-13 05:18:04.739306-05	2025-10-13 05:19:04.770902-05	2025-10-13 05:20:01.739306-05	f	\N	2025-10-13 17:20:52.823805-05
b824d628-c14f-447d-9b29-7096e1ae2a96	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:20:35.633949-05	2025-10-13 05:20:35.640339-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:18:35.633949-05	2025-10-13 05:20:35.648608-05	2025-10-13 05:28:35.633949-05	f	\N	2025-10-13 17:20:52.823805-05
ce517a69-80bf-4f4a-8508-b3fbbaff5196	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:20:01.769793-05	2025-10-13 05:20:05.455615-05	\N	2025-10-13 10:20:00	00:15:00	2025-10-13 05:19:04.769793-05	2025-10-13 05:20:05.466162-05	2025-10-13 05:21:01.769793-05	f	\N	2025-10-13 17:20:52.823805-05
df76d807-5080-4167-aa8c-5de282a9cb2b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:22:01.492828-05	2025-10-13 05:22:01.51403-05	\N	2025-10-13 10:22:00	00:15:00	2025-10-13 05:21:01.492828-05	2025-10-13 05:22:01.524459-05	2025-10-13 05:23:01.492828-05	f	\N	2025-10-13 17:23:52.825351-05
5792d1ff-9228-4e11-8c16-38e8227066f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:21:01.464472-05	2025-10-13 05:21:01.4842-05	\N	2025-10-13 10:21:00	00:15:00	2025-10-13 05:20:05.464472-05	2025-10-13 05:21:01.494348-05	2025-10-13 05:22:01.464472-05	f	\N	2025-10-13 17:23:52.825351-05
7837464b-3985-4f10-8858-76045e8b9bae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:41:01.237672-05	2025-10-12 16:41:03.24537-05	\N	2025-10-12 21:41:00	00:15:00	2025-10-12 16:40:03.237672-05	2025-10-12 16:41:03.261933-05	2025-10-12 16:42:01.237672-05	f	\N	2025-10-13 04:43:35.54431-05
2bbe897d-ccfd-4e41-8c87-3259e9f42dfc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:42:01.26072-05	2025-10-12 16:42:03.260078-05	\N	2025-10-12 21:42:00	00:15:00	2025-10-12 16:41:03.26072-05	2025-10-12 16:42:03.273694-05	2025-10-12 16:43:01.26072-05	f	\N	2025-10-13 04:43:35.54431-05
4a42b5a9-1824-4464-aecc-5db4856e8247	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:43:01.272491-05	2025-10-12 16:43:03.2788-05	\N	2025-10-12 21:43:00	00:15:00	2025-10-12 16:42:03.272491-05	2025-10-12 16:43:03.288762-05	2025-10-12 16:44:01.272491-05	f	\N	2025-10-13 04:43:35.54431-05
b91e3880-4bfa-4159-aebb-505bd94e5af1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:42:30.938742-05	2025-10-12 16:43:30.933203-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:40:30.938742-05	2025-10-12 16:43:30.936875-05	2025-10-12 16:50:30.938742-05	f	\N	2025-10-13 04:43:35.54431-05
6bc20083-7c63-41a7-83cd-82961e3cb319	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:44:01.28806-05	2025-10-12 16:44:03.290442-05	\N	2025-10-12 21:44:00	00:15:00	2025-10-12 16:43:03.28806-05	2025-10-12 16:44:03.302152-05	2025-10-12 16:45:01.28806-05	f	\N	2025-10-13 04:46:35.549104-05
fbb1e6c5-edce-409b-bf3f-ff4d7997c02f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:45:30.937682-05	2025-10-12 16:46:30.936586-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:43:30.937682-05	2025-10-12 16:46:30.943364-05	2025-10-12 16:53:30.937682-05	f	\N	2025-10-13 04:46:35.549104-05
c68860eb-2672-443b-981b-d9176682eaa9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:45:01.300567-05	2025-10-12 16:45:03.303033-05	\N	2025-10-12 21:45:00	00:15:00	2025-10-12 16:44:03.300567-05	2025-10-12 16:45:03.314536-05	2025-10-12 16:46:01.300567-05	f	\N	2025-10-13 04:46:35.549104-05
0b475d13-412a-49f6-b29f-ed940f70f9f8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:46:01.313411-05	2025-10-12 16:46:03.316836-05	\N	2025-10-12 21:46:00	00:15:00	2025-10-12 16:45:03.313411-05	2025-10-12 16:46:03.32667-05	2025-10-12 16:47:01.313411-05	f	\N	2025-10-13 04:46:35.549104-05
a9470665-8e31-418c-b4f9-4b40acf1635a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:51:01.392554-05	2025-10-12 16:51:03.393223-05	\N	2025-10-12 21:51:00	00:15:00	2025-10-12 16:50:03.392554-05	2025-10-12 16:51:03.403113-05	2025-10-12 16:52:01.392554-05	f	\N	2025-10-13 04:52:35.554621-05
f21ecc52-0293-4f27-8b4b-62aa53d916ed	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:51:30.944005-05	2025-10-12 16:52:30.940782-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:49:30.944005-05	2025-10-12 16:52:30.951122-05	2025-10-12 16:59:30.944005-05	f	\N	2025-10-13 04:52:35.554621-05
6b640b5a-fc67-4fd6-b845-9612f193e213	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:50:01.368585-05	2025-10-12 16:50:03.378711-05	\N	2025-10-12 21:50:00	00:15:00	2025-10-12 16:49:03.368585-05	2025-10-12 16:50:03.394082-05	2025-10-12 16:51:01.368585-05	f	\N	2025-10-13 04:52:35.554621-05
c1d88baa-b5b4-4813-89f2-cec75ca7377e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:52:01.401559-05	2025-10-12 16:52:03.410305-05	\N	2025-10-12 21:52:00	00:15:00	2025-10-12 16:51:03.401559-05	2025-10-12 16:52:03.422887-05	2025-10-12 16:53:01.401559-05	f	\N	2025-10-13 04:52:35.554621-05
90b025ac-ef51-4aa0-9993-495d0c227bc1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:53:01.421594-05	2025-10-12 16:53:03.424894-05	\N	2025-10-12 21:53:00	00:15:00	2025-10-12 16:52:03.421594-05	2025-10-12 16:53:03.440006-05	2025-10-12 16:54:01.421594-05	f	\N	2025-10-13 04:55:35.559059-05
62eeae2f-c86b-4d22-8ddf-5cd606eb2a8e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:54:01.438241-05	2025-10-12 16:54:03.441026-05	\N	2025-10-12 21:54:00	00:15:00	2025-10-12 16:53:03.438241-05	2025-10-12 16:54:03.447392-05	2025-10-12 16:55:01.438241-05	f	\N	2025-10-13 04:55:35.559059-05
d25ade3c-1ab5-424a-a770-aacfb0062e2d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:55:03.331592-05	2025-10-12 16:55:03.33359-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:55:03.331592-05	2025-10-12 16:55:03.340759-05	2025-10-12 17:03:03.331592-05	f	\N	2025-10-13 04:55:35.559059-05
03c49167-650e-4285-ac7e-2ef1a088ed2c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:55:01.446738-05	2025-10-12 16:55:03.338854-05	\N	2025-10-12 21:55:00	00:15:00	2025-10-12 16:54:03.446738-05	2025-10-12 16:55:03.3434-05	2025-10-12 16:56:01.446738-05	f	\N	2025-10-13 04:55:35.559059-05
22371e9f-f9bb-40db-91c1-3dd06941e4ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:58:01.383168-05	2025-10-12 16:58:03.384257-05	\N	2025-10-12 21:58:00	00:15:00	2025-10-12 16:57:03.383168-05	2025-10-12 16:58:03.396348-05	2025-10-12 16:59:01.383168-05	f	\N	2025-10-13 04:58:35.563899-05
fd26ddef-0dfa-4aa0-ba53-90612a8fc78a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:56:01.348671-05	2025-10-12 16:56:03.353116-05	\N	2025-10-12 21:56:00	00:15:00	2025-10-12 16:55:03.348671-05	2025-10-12 16:56:03.389011-05	2025-10-12 16:57:01.348671-05	f	\N	2025-10-13 04:58:35.563899-05
a698ae3d-2c20-4f50-b2eb-88ecee2bd434	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:57:03.342454-05	2025-10-12 16:58:03.335798-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:55:03.342454-05	2025-10-12 16:58:03.34588-05	2025-10-12 17:05:03.342454-05	f	\N	2025-10-13 04:58:35.563899-05
11170988-1422-49fa-909f-862c717787c4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:57:01.37495-05	2025-10-12 16:57:03.370463-05	\N	2025-10-12 21:57:00	00:15:00	2025-10-12 16:56:03.37495-05	2025-10-12 16:57:03.384687-05	2025-10-12 16:58:01.37495-05	f	\N	2025-10-13 04:58:35.563899-05
7ffe3168-6c80-4e8b-97da-5dcb9f36b2c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:58:01.883815-05	2025-10-13 02:58:04.90217-05	\N	2025-10-13 07:58:00	00:15:00	2025-10-13 02:57:04.883815-05	2025-10-13 02:58:04.914871-05	2025-10-13 02:59:01.883815-05	f	\N	2025-10-13 14:58:52.543213-05
9caa2760-5c44-4325-8480-061f31ef5814	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:57:01.853492-05	2025-10-13 02:57:04.872858-05	\N	2025-10-13 07:57:00	00:15:00	2025-10-13 02:56:04.853492-05	2025-10-13 02:57:04.8858-05	2025-10-13 02:58:01.853492-05	f	\N	2025-10-13 14:58:52.543213-05
16d32f05-af63-4f28-86ac-1d74ce2f8d74	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 02:57:35.406921-05	2025-10-13 02:58:35.40078-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:55:35.406921-05	2025-10-13 02:58:35.408212-05	2025-10-13 03:05:35.406921-05	f	\N	2025-10-13 14:58:52.543213-05
4198c18f-8058-4b65-a3e8-72fdcaad1353	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:56:01.831782-05	2025-10-13 02:56:04.845426-05	\N	2025-10-13 07:56:00	00:15:00	2025-10-13 02:55:04.831782-05	2025-10-13 02:56:04.854834-05	2025-10-13 02:57:01.831782-05	f	\N	2025-10-13 14:58:52.543213-05
ee029ed4-1579-4bc3-8951-dde13974e39a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:37:32.467331-05	2025-10-13 05:38:32.45509-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:37:32.467331-05	2025-10-13 05:38:32.462108-05	2025-10-13 05:45:32.467331-05	f	\N	2025-10-13 17:38:52.839642-05
f1d9fa03-0007-418c-8ad7-294f5085f858	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:23:01.522785-05	2025-10-13 05:37:32.452155-05	\N	2025-10-13 10:23:00	00:15:00	2025-10-13 05:22:01.522785-05	2025-10-13 05:37:32.468037-05	2025-10-13 05:24:01.522785-05	f	\N	2025-10-13 17:38:52.839642-05
05188426-ab32-4869-9620-bc083657ef77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:37:32.460028-05	2025-10-13 05:37:36.447208-05	\N	2025-10-13 10:37:00	00:15:00	2025-10-13 05:37:32.460028-05	2025-10-13 05:37:36.460139-05	2025-10-13 05:38:32.460028-05	f	\N	2025-10-13 17:38:52.839642-05
2959a8ba-7b48-4a27-bfc8-847d88777b8a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:38:01.466885-05	2025-10-13 05:38:04.463632-05	\N	2025-10-13 10:38:00	00:15:00	2025-10-13 05:37:32.466885-05	2025-10-13 05:38:04.47862-05	2025-10-13 05:39:01.466885-05	f	\N	2025-10-13 17:38:52.839642-05
c5cfa728-3d13-451d-ac74-233658b9a73c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:44:01.768733-05	2025-10-13 05:48:02.027006-05	\N	2025-10-13 10:44:00	00:15:00	2025-10-13 05:43:02.768733-05	2025-10-13 05:48:02.038623-05	2025-10-13 05:45:01.768733-05	f	\N	2025-10-13 17:49:52.86686-05
4d308ab4-c7b5-458e-9c56-f8d6f69fb3be	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:48:02.030206-05	2025-10-13 05:48:06.021462-05	\N	2025-10-13 10:48:00	00:15:00	2025-10-13 05:48:02.030206-05	2025-10-13 05:48:06.033011-05	2025-10-13 05:49:02.030206-05	f	\N	2025-10-13 17:49:52.86686-05
fcf938cc-4cd7-48e7-ae26-030f1a1dab41	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:47:01.325259-05	2025-10-12 16:47:03.329917-05	\N	2025-10-12 21:47:00	00:15:00	2025-10-12 16:46:03.325259-05	2025-10-12 16:47:03.343072-05	2025-10-12 16:48:01.325259-05	f	\N	2025-10-13 04:49:35.54925-05
a78f2efd-305b-4cfa-a019-71c2929b2b43	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:48:01.341832-05	2025-10-12 16:48:03.342976-05	\N	2025-10-12 21:48:00	00:15:00	2025-10-12 16:47:03.341832-05	2025-10-12 16:48:03.356249-05	2025-10-12 16:49:01.341832-05	f	\N	2025-10-13 04:49:35.54925-05
42c81fda-bd96-4849-808c-d3787dab2056	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 16:48:30.944546-05	2025-10-12 16:49:30.938156-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:46:30.944546-05	2025-10-12 16:49:30.942634-05	2025-10-12 16:56:30.944546-05	f	\N	2025-10-13 04:49:35.54925-05
8c92b15b-56b1-46d2-a937-b4a9f92de740	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:49:01.35473-05	2025-10-12 16:49:03.359332-05	\N	2025-10-12 21:49:00	00:15:00	2025-10-12 16:48:03.35473-05	2025-10-12 16:49:03.370029-05	2025-10-12 16:50:01.35473-05	f	\N	2025-10-13 04:49:35.54925-05
ba8fa822-fe03-42a5-8fd9-741ea1d1de4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:06:01.495695-05	2025-10-12 17:06:03.495779-05	\N	2025-10-12 22:06:00	00:15:00	2025-10-12 17:05:03.495695-05	2025-10-12 17:06:03.505625-05	2025-10-12 17:07:01.495695-05	f	\N	2025-10-13 05:07:35.576187-05
61c43072-3d1f-4c2a-9f56-26e7e2973243	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:05:01.482797-05	2025-10-12 17:05:03.48477-05	\N	2025-10-12 22:05:00	00:15:00	2025-10-12 17:04:03.482797-05	2025-10-12 17:05:03.497081-05	2025-10-12 17:06:01.482797-05	f	\N	2025-10-13 05:07:35.576187-05
01da20c9-b788-4f03-b40e-e1bb464406c3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:05:03.363972-05	2025-10-12 17:06:03.352801-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:03:03.363972-05	2025-10-12 17:06:03.356786-05	2025-10-12 17:13:03.363972-05	f	\N	2025-10-13 05:07:35.576187-05
d380d45c-a602-4f71-ac59-d180486c5b05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:07:01.504438-05	2025-10-12 17:07:03.516686-05	\N	2025-10-12 22:07:00	00:15:00	2025-10-12 17:06:03.504438-05	2025-10-12 17:07:03.523917-05	2025-10-12 17:08:01.504438-05	f	\N	2025-10-13 05:07:35.576187-05
32553029-445c-4c04-9a5f-47e282c82b04	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:00:35.409649-05	2025-10-13 03:01:35.407248-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 02:58:35.409649-05	2025-10-13 03:01:35.414303-05	2025-10-13 03:08:35.409649-05	f	\N	2025-10-13 15:01:52.488076-05
b4b18b8d-820e-4f23-832e-74d1852bedd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 02:59:01.913015-05	2025-10-13 02:59:04.926739-05	\N	2025-10-13 07:59:00	00:15:00	2025-10-13 02:58:04.913015-05	2025-10-13 02:59:04.937816-05	2025-10-13 03:00:01.913015-05	f	\N	2025-10-13 15:01:52.488076-05
5245df92-f2f9-4035-bb12-5e65892a1710	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:00:01.935984-05	2025-10-13 03:00:04.952116-05	\N	2025-10-13 08:00:00	00:15:00	2025-10-13 02:59:04.935984-05	2025-10-13 03:00:04.958296-05	2025-10-13 03:01:01.935984-05	f	\N	2025-10-13 15:01:52.488076-05
bf07b60d-96a3-40ef-b02b-6e94d8d5abb4	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 03:00:04.956042-05	2025-10-13 03:00:08.952884-05	dailyStatsJob	2025-10-13 08:00:00	00:15:00	2025-10-13 03:00:04.956042-05	2025-10-13 03:00:08.957684-05	2025-10-27 03:00:04.956042-05	f	\N	2025-10-13 15:01:52.488076-05
7abd14cf-f51b-401f-93fb-a6693af646df	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 03:00:08.956092-05	2025-10-13 03:00:10.137961-05	\N	\N	00:15:00	2025-10-13 03:00:08.956092-05	2025-10-13 03:00:10.301303-05	2025-10-27 03:00:08.956092-05	f	\N	2025-10-13 15:01:52.488076-05
a3158bfa-a778-44c1-811e-aaadd3262e6d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:01:01.957727-05	2025-10-13 03:01:04.980619-05	\N	2025-10-13 08:01:00	00:15:00	2025-10-13 03:00:04.957727-05	2025-10-13 03:01:04.990609-05	2025-10-13 03:02:01.957727-05	f	\N	2025-10-13 15:01:52.488076-05
6cd221ce-0c4c-4a7f-b6a7-0caa91437ba0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:40:32.463114-05	2025-10-13 05:41:42.735115-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:38:32.463114-05	2025-10-13 05:41:42.74863-05	2025-10-13 05:48:32.463114-05	f	\N	2025-10-13 17:41:52.83798-05
7f1ebe54-12b1-46e2-9ec4-f64bd2c1dc9e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:39:01.477224-05	2025-10-13 05:41:42.726275-05	\N	2025-10-13 10:39:00	00:15:00	2025-10-13 05:38:04.477224-05	2025-10-13 05:41:42.739116-05	2025-10-13 05:40:01.477224-05	f	\N	2025-10-13 17:41:52.83798-05
16d88c18-4adf-46d7-be7d-944b7e65d0d9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:41:42.735996-05	2025-10-13 05:41:46.727022-05	\N	2025-10-13 10:41:00	00:15:00	2025-10-13 05:41:42.735996-05	2025-10-13 05:41:46.737064-05	2025-10-13 05:42:42.735996-05	f	\N	2025-10-13 17:41:52.83798-05
94483bb0-f03a-40df-84fd-cebefc0de7ca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:42:01.735788-05	2025-10-13 05:42:02.73436-05	\N	2025-10-13 10:42:00	00:15:00	2025-10-13 05:41:46.735788-05	2025-10-13 05:42:02.743743-05	2025-10-13 05:43:01.735788-05	f	\N	2025-10-13 17:43:52.858877-05
126a13f8-f17b-4ee7-a95b-d283b9d4d1df	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:43:01.742581-05	2025-10-13 05:43:02.759466-05	\N	2025-10-13 10:43:00	00:15:00	2025-10-13 05:42:02.742581-05	2025-10-13 05:43:02.769893-05	2025-10-13 05:44:01.742581-05	f	\N	2025-10-13 17:43:52.858877-05
9f2b8183-3cc5-494b-baa9-63d895981c59	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 16:59:01.395321-05	2025-10-12 16:59:03.396284-05	\N	2025-10-12 21:59:00	00:15:00	2025-10-12 16:58:03.395321-05	2025-10-12 16:59:03.414733-05	2025-10-12 17:00:01.395321-05	f	\N	2025-10-13 05:01:35.569239-05
b0fccebf-9996-4ab7-a888-6c75c4125206	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:00:01.41336-05	2025-10-12 17:00:03.411138-05	\N	2025-10-12 22:00:00	00:15:00	2025-10-12 16:59:03.41336-05	2025-10-12 17:00:03.418407-05	2025-10-12 17:01:01.41336-05	f	\N	2025-10-13 05:01:35.569239-05
8ed399e4-86e2-44b3-ab8c-ab572937ad72	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T21:55:03.359Z"}	completed	0	0	0	f	2025-10-12 17:00:03.414639-05	2025-10-12 17:00:07.411796-05	dailyStatsJob	2025-10-12 22:00:00	00:15:00	2025-10-12 17:00:03.414639-05	2025-10-12 17:00:07.414575-05	2025-10-26 17:00:03.414639-05	f	\N	2025-10-13 05:01:35.569239-05
078d6a93-1ecc-4a32-b301-9e1607fcff26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:01:01.417242-05	2025-10-12 17:01:03.428369-05	\N	2025-10-12 22:01:00	00:15:00	2025-10-12 17:00:03.417242-05	2025-10-12 17:01:03.4386-05	2025-10-12 17:02:01.417242-05	f	\N	2025-10-13 05:01:35.569239-05
e805d9fa-13db-4932-808c-2b9b3a9d0bc7	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 17:00:07.413481-05	2025-10-12 17:00:07.521358-05	\N	\N	00:15:00	2025-10-12 17:00:07.413481-05	2025-10-12 17:00:07.751071-05	2025-10-26 17:00:07.413481-05	f	\N	2025-10-13 05:01:35.569239-05
1ea21b8a-c2f2-49c7-a271-61ab3741c31d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:00:03.347539-05	2025-10-12 17:01:03.340807-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 16:58:03.347539-05	2025-10-12 17:01:03.345606-05	2025-10-12 17:08:03.347539-05	f	\N	2025-10-13 05:01:35.569239-05
023d9690-0d5b-4648-8936-8118e231d2fb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:03:01.456666-05	2025-10-12 17:03:03.459328-05	\N	2025-10-12 22:03:00	00:15:00	2025-10-12 17:02:03.456666-05	2025-10-12 17:03:03.473426-05	2025-10-12 17:04:01.456666-05	f	\N	2025-10-13 05:04:35.568757-05
d9f232f3-f74a-4ce9-9349-324bd1522c4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:02:01.437515-05	2025-10-12 17:02:03.44512-05	\N	2025-10-12 22:02:00	00:15:00	2025-10-12 17:01:03.437515-05	2025-10-12 17:02:03.458095-05	2025-10-12 17:03:01.437515-05	f	\N	2025-10-13 05:04:35.568757-05
29da5064-e525-47d7-bf86-7bbadafc76c3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:04:01.47144-05	2025-10-12 17:04:03.470581-05	\N	2025-10-12 22:04:00	00:15:00	2025-10-12 17:03:03.47144-05	2025-10-12 17:04:03.484122-05	2025-10-12 17:05:01.47144-05	f	\N	2025-10-13 05:04:35.568757-05
43241c1a-55dd-46fc-b3df-87f1d13c27ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:03:03.347296-05	2025-10-12 17:03:03.349366-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:01:03.347296-05	2025-10-12 17:03:03.359698-05	2025-10-12 17:11:03.347296-05	f	\N	2025-10-13 05:04:35.568757-05
15e6a629-655c-4275-a47f-dbc80a6ae360	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:08:01.522925-05	2025-10-12 17:08:03.5305-05	\N	2025-10-12 22:08:00	00:15:00	2025-10-12 17:07:03.522925-05	2025-10-12 17:08:03.546498-05	2025-10-12 17:09:01.522925-05	f	\N	2025-10-13 05:10:35.579761-05
9150adf8-5d87-4121-9d83-a6bd5eaa8d36	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:08:03.358222-05	2025-10-12 17:09:03.356661-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:06:03.358222-05	2025-10-12 17:09:03.367544-05	2025-10-12 17:16:03.358222-05	f	\N	2025-10-13 05:10:35.579761-05
98dad080-fe75-44cb-928a-771191ae7d27	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:09:01.54454-05	2025-10-12 17:09:03.548684-05	\N	2025-10-12 22:09:00	00:15:00	2025-10-12 17:08:03.54454-05	2025-10-12 17:09:03.559933-05	2025-10-12 17:10:01.54454-05	f	\N	2025-10-13 05:10:35.579761-05
2a0fccf2-1761-4936-8d6a-275e57ab7904	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:10:01.558395-05	2025-10-12 17:10:03.564463-05	\N	2025-10-12 22:10:00	00:15:00	2025-10-12 17:09:03.558395-05	2025-10-12 17:10:03.572929-05	2025-10-12 17:11:01.558395-05	f	\N	2025-10-13 05:10:35.579761-05
24cbf987-b351-47c9-b7f6-07e994466fbf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:03:35.415753-05	2025-10-13 03:04:35.41339-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:01:35.415753-05	2025-10-13 03:04:35.419808-05	2025-10-13 03:11:35.415753-05	f	\N	2025-10-13 15:04:52.492385-05
f738a887-aa77-42b4-a8d9-ef57dac81b61	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:02:01.988983-05	2025-10-13 03:02:05.011494-05	\N	2025-10-13 08:02:00	00:15:00	2025-10-13 03:01:04.988983-05	2025-10-13 03:02:05.021959-05	2025-10-13 03:03:01.988983-05	f	\N	2025-10-13 15:04:52.492385-05
c380c4ea-013d-4444-b006-58ff12bb280f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:03:01.020247-05	2025-10-13 03:03:01.039428-05	\N	2025-10-13 08:03:00	00:15:00	2025-10-13 03:02:05.020247-05	2025-10-13 03:03:01.049574-05	2025-10-13 03:04:01.020247-05	f	\N	2025-10-13 15:04:52.492385-05
32b8bf01-9029-4ddf-94b9-93658d0f7915	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:04:01.047865-05	2025-10-13 03:04:01.068603-05	\N	2025-10-13 08:04:00	00:15:00	2025-10-13 03:03:01.047865-05	2025-10-13 03:04:01.07457-05	2025-10-13 03:05:01.047865-05	f	\N	2025-10-13 15:04:52.492385-05
c579675e-4321-42a2-a922-d50b110f25b4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:57:08.761604-05	2025-10-13 05:57:12.754315-05	\N	2025-10-13 10:57:00	00:15:00	2025-10-13 05:57:08.761604-05	2025-10-13 05:57:12.773018-05	2025-10-13 05:58:08.761604-05	f	\N	2025-10-13 17:58:52.883051-05
6b265535-01ad-4cec-94e5-7dde6efbf338	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:58:01.771303-05	2025-10-13 05:58:04.765857-05	\N	2025-10-13 10:58:00	00:15:00	2025-10-13 05:57:12.771303-05	2025-10-13 05:58:04.781492-05	2025-10-13 05:59:01.771303-05	f	\N	2025-10-13 17:58:52.883051-05
804113cc-3a8a-4123-b692-23467b296eda	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 05:57:08.766628-05	2025-10-13 05:58:08.739457-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:57:08.766628-05	2025-10-13 05:58:08.752972-05	2025-10-13 06:05:08.766628-05	f	\N	2025-10-13 17:58:52.883051-05
4636f07e-ce90-467b-8a02-a217d177670c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:49:01.037749-05	2025-10-13 05:57:08.756544-05	\N	2025-10-13 10:49:00	00:15:00	2025-10-13 05:48:02.037749-05	2025-10-13 05:57:08.762502-05	2025-10-13 05:50:01.037749-05	f	\N	2025-10-13 17:58:52.883051-05
0d1664a8-2a90-4416-a04b-c6adaed5bc95	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-13 06:00:04.823226-05	2025-10-13 06:00:08.824218-05	dailyStatsJob	2025-10-13 11:00:00	00:15:00	2025-10-13 06:00:04.823226-05	2025-10-13 06:00:08.828519-05	2025-10-27 06:00:04.823226-05	f	\N	2025-10-13 18:01:52.880087-05
ae3f5797-cdbb-4cba-8c9a-1a022f2e01c0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:00:08.755222-05	2025-10-13 06:01:08.742189-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 05:58:08.755222-05	2025-10-13 06:01:08.749777-05	2025-10-13 06:08:08.755222-05	f	\N	2025-10-13 18:01:52.880087-05
74381eed-8720-4c0c-a875-a3e1cea0d903	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 06:00:08.826721-05	2025-10-13 06:00:08.85642-05	\N	\N	00:15:00	2025-10-13 06:00:08.826721-05	2025-10-13 06:00:09.020212-05	2025-10-27 06:00:08.826721-05	f	\N	2025-10-13 18:01:52.880087-05
d6b8c422-ad66-4d58-a03f-5dde3e3ccb57	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:01:01.824609-05	2025-10-13 06:01:04.848816-05	\N	2025-10-13 11:01:00	00:15:00	2025-10-13 06:00:04.824609-05	2025-10-13 06:01:04.857195-05	2025-10-13 06:02:01.824609-05	f	\N	2025-10-13 18:01:52.880087-05
51a87cac-105f-4e6c-a046-6a3a5e84332f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 05:59:01.779622-05	2025-10-13 05:59:04.796433-05	\N	2025-10-13 10:59:00	00:15:00	2025-10-13 05:58:04.779622-05	2025-10-13 05:59:04.80762-05	2025-10-13 06:00:01.779622-05	f	\N	2025-10-13 18:01:52.880087-05
0ca93553-beed-41ba-90e9-a4faedc980dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:00:01.806523-05	2025-10-13 06:00:04.822025-05	\N	2025-10-13 11:00:00	00:15:00	2025-10-13 05:59:04.806523-05	2025-10-13 06:00:04.825205-05	2025-10-13 06:01:01.806523-05	f	\N	2025-10-13 18:01:52.880087-05
be68296d-f9a8-40f6-8b5b-64a956d59533	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:11:01.572067-05	2025-10-12 17:11:03.581592-05	\N	2025-10-12 22:11:00	00:15:00	2025-10-12 17:10:03.572067-05	2025-10-12 17:11:03.594187-05	2025-10-12 17:12:01.572067-05	f	\N	2025-10-13 05:12:35.614686-05
18cd60bb-fbd5-498a-b2bc-8a10b338a6da	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:12:01.592717-05	2025-10-12 17:12:03.594465-05	\N	2025-10-12 22:12:00	00:15:00	2025-10-12 17:11:03.592717-05	2025-10-12 17:12:03.602931-05	2025-10-12 17:13:01.592717-05	f	\N	2025-10-13 05:12:35.614686-05
905a567f-4376-43b6-8194-cc9bbc62a954	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:11:03.369012-05	2025-10-12 17:12:03.361542-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:09:03.369012-05	2025-10-12 17:12:03.368564-05	2025-10-12 17:19:03.369012-05	f	\N	2025-10-13 05:12:35.614686-05
d5459244-4647-45c4-882e-94ae14610a7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:05:01.073553-05	2025-10-13 03:05:01.096029-05	\N	2025-10-13 08:05:00	00:15:00	2025-10-13 03:04:01.073553-05	2025-10-13 03:05:01.107208-05	2025-10-13 03:06:01.073553-05	f	\N	2025-10-13 15:06:53.668302-05
ac7cf17f-5b21-4397-ab03-86a462973f28	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:06:01.105531-05	2025-10-13 03:06:01.126505-05	\N	2025-10-13 08:06:00	00:15:00	2025-10-13 03:05:01.105531-05	2025-10-13 03:06:01.133929-05	2025-10-13 03:07:01.105531-05	f	\N	2025-10-13 15:06:53.668302-05
93eec10f-424c-4506-ac70-fd2d736292eb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:02:01.855952-05	2025-10-13 06:02:04.875553-05	\N	2025-10-13 11:02:00	00:15:00	2025-10-13 06:01:04.855952-05	2025-10-13 06:02:04.88578-05	2025-10-13 06:03:01.855952-05	f	\N	2025-10-13 18:04:52.88387-05
0fb6354e-8179-4ef9-9cd6-23e187c788d9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:03:01.88419-05	2025-10-13 06:03:04.902751-05	\N	2025-10-13 11:03:00	00:15:00	2025-10-13 06:02:04.88419-05	2025-10-13 06:03:04.913457-05	2025-10-13 06:04:01.88419-05	f	\N	2025-10-13 18:04:52.88387-05
5f358807-41e2-4f91-a53f-e189885fff89	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:04:01.911899-05	2025-10-13 06:04:04.929877-05	\N	2025-10-13 11:04:00	00:15:00	2025-10-13 06:03:04.911899-05	2025-10-13 06:04:04.93811-05	2025-10-13 06:05:01.911899-05	f	\N	2025-10-13 18:04:52.88387-05
1450207d-ed02-4fc5-84cb-e204a113dbc6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:03:08.750926-05	2025-10-13 06:04:08.748484-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:01:08.750926-05	2025-10-13 06:04:08.756143-05	2025-10-13 06:11:08.750926-05	f	\N	2025-10-13 18:04:52.88387-05
868e2495-ce84-4153-a468-455284ea6c24	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:14:01.619748-05	2025-10-12 17:14:03.622025-05	\N	2025-10-12 22:14:00	00:15:00	2025-10-12 17:13:03.619748-05	2025-10-12 17:14:03.630114-05	2025-10-12 17:15:01.619748-05	f	\N	2025-10-13 05:15:35.62112-05
3e7f91f8-9e4d-44b9-9d8f-1d39aa124a36	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:14:03.370244-05	2025-10-12 17:15:03.363719-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:12:03.370244-05	2025-10-12 17:15:03.370471-05	2025-10-12 17:22:03.370244-05	f	\N	2025-10-13 05:15:35.62112-05
6334df9d-c922-41f8-bbcf-dddef7e526f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:13:01.602137-05	2025-10-12 17:13:03.608373-05	\N	2025-10-12 22:13:00	00:15:00	2025-10-12 17:12:03.602137-05	2025-10-12 17:13:03.621499-05	2025-10-12 17:14:01.602137-05	f	\N	2025-10-13 05:15:35.62112-05
c9d246cf-a92e-4f2e-85d3-6e0198e46046	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:15:01.629236-05	2025-10-12 17:15:03.636549-05	\N	2025-10-12 22:15:00	00:15:00	2025-10-12 17:14:03.629236-05	2025-10-12 17:15:03.642646-05	2025-10-12 17:16:01.629236-05	f	\N	2025-10-13 05:15:35.62112-05
c438499b-1bc0-4a25-815a-899bc049f63f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:16:01.642062-05	2025-10-12 17:16:03.64993-05	\N	2025-10-12 22:16:00	00:15:00	2025-10-12 17:15:03.642062-05	2025-10-12 17:16:03.662444-05	2025-10-12 17:17:01.642062-05	f	\N	2025-10-13 05:18:35.627969-05
029bf709-e770-4f24-9399-1527a727f4b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:18:01.672571-05	2025-10-12 17:18:05.198736-05	\N	2025-10-12 22:18:00	00:15:00	2025-10-12 17:17:03.672571-05	2025-10-12 17:18:05.215333-05	2025-10-12 17:19:01.672571-05	f	\N	2025-10-13 05:18:35.627969-05
141059b9-2ab2-4fa9-9cbb-f39d3c4f1c45	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:17:01.660252-05	2025-10-12 17:17:03.667452-05	\N	2025-10-12 22:17:00	00:15:00	2025-10-12 17:16:03.660252-05	2025-10-12 17:17:03.673368-05	2025-10-12 17:18:01.660252-05	f	\N	2025-10-13 05:18:35.627969-05
2e938684-28a1-4e75-9deb-47b67e82ecb6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:17:53.186453-05	2025-10-12 17:17:53.189228-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:17:53.186453-05	2025-10-12 17:17:53.195815-05	2025-10-12 17:25:53.186453-05	f	\N	2025-10-13 05:18:35.627969-05
05a59079-f6db-4d10-bba0-41616850327c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:18:52.277142-05	2025-10-12 17:18:52.279837-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:18:52.277142-05	2025-10-12 17:18:52.287535-05	2025-10-12 17:26:52.277142-05	f	\N	2025-10-13 05:20:35.644852-05
55f407ac-3e91-4d83-a6eb-544cc3e1e52d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:19:01.214568-05	2025-10-12 17:19:04.29091-05	\N	2025-10-12 22:19:00	00:15:00	2025-10-12 17:18:05.214568-05	2025-10-12 17:19:04.306726-05	2025-10-12 17:20:01.214568-05	f	\N	2025-10-13 05:20:35.644852-05
f4c38438-3643-404a-a2fa-9a05068b19fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:20:01.305495-05	2025-10-12 17:20:04.308266-05	\N	2025-10-12 22:20:00	00:15:00	2025-10-12 17:19:04.305495-05	2025-10-12 17:20:04.32231-05	2025-10-12 17:21:01.305495-05	f	\N	2025-10-13 05:20:35.644852-05
a76bc30a-a464-4cfc-a0d5-65db8b4b9dd5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:07:01.132752-05	2025-10-13 03:07:01.150207-05	\N	2025-10-13 08:07:00	00:15:00	2025-10-13 03:06:01.132752-05	2025-10-13 03:07:01.156212-05	2025-10-13 03:08:01.132752-05	f	\N	2025-10-13 15:07:20.269237-05
16cd7b67-0e68-4483-b1c3-4662b2e2fc49	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:05:01.936845-05	2025-10-13 06:05:04.955797-05	\N	2025-10-13 11:05:00	00:15:00	2025-10-13 06:04:04.936845-05	2025-10-13 06:05:04.965195-05	2025-10-13 06:06:01.936845-05	f	\N	2025-10-13 18:07:52.885531-05
0b4dba5d-705f-4a7a-806b-dc0f16a1ce4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:07:01.991911-05	2025-10-13 06:07:05.011212-05	\N	2025-10-13 11:07:00	00:15:00	2025-10-13 06:06:04.991911-05	2025-10-13 06:07:05.02063-05	2025-10-13 06:08:01.991911-05	f	\N	2025-10-13 18:07:52.885531-05
d6458392-c6e4-47f4-a82d-353eaedbce40	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:06:01.963655-05	2025-10-13 06:06:04.983934-05	\N	2025-10-13 11:06:00	00:15:00	2025-10-13 06:05:04.963655-05	2025-10-13 06:06:04.993661-05	2025-10-13 06:07:01.963655-05	f	\N	2025-10-13 18:07:52.885531-05
f2618695-94d8-40e1-807a-cfe312ebfcc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:06:08.757874-05	2025-10-13 06:07:08.754978-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:04:08.757874-05	2025-10-13 06:07:08.762747-05	2025-10-13 06:14:08.757874-05	f	\N	2025-10-13 18:07:52.885531-05
5c25444f-7e87-419d-a4f9-0497cededd69	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:09:01.044399-05	2025-10-13 06:09:01.060767-05	\N	2025-10-13 11:09:00	00:15:00	2025-10-13 06:08:01.044399-05	2025-10-13 06:09:01.069726-05	2025-10-13 06:10:01.044399-05	f	\N	2025-10-13 18:09:52.897834-05
edb6e45f-a05d-4d4e-8329-836e580a22b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:08:01.019247-05	2025-10-13 06:08:01.03598-05	\N	2025-10-13 11:08:00	00:15:00	2025-10-13 06:07:05.019247-05	2025-10-13 06:08:01.046113-05	2025-10-13 06:09:01.019247-05	f	\N	2025-10-13 18:09:52.897834-05
2879dbff-de5c-4480-929b-2cff85149c95	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:10:01.068059-05	2025-10-13 06:10:01.083882-05	\N	2025-10-13 11:10:00	00:15:00	2025-10-13 06:09:01.068059-05	2025-10-13 06:10:01.094275-05	2025-10-13 06:11:01.068059-05	f	\N	2025-10-13 18:12:52.900043-05
fbbad2a4-c387-4916-97df-377033177ef6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:09:08.764474-05	2025-10-13 06:10:08.757178-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:07:08.764474-05	2025-10-13 06:10:08.759849-05	2025-10-13 06:17:08.764474-05	f	\N	2025-10-13 18:12:52.900043-05
15f91638-5dea-4838-8edd-32d0d9a18d3b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:11:01.092813-05	2025-10-13 06:11:01.109557-05	\N	2025-10-13 11:11:00	00:15:00	2025-10-13 06:10:01.092813-05	2025-10-13 06:11:01.120656-05	2025-10-13 06:12:01.092813-05	f	\N	2025-10-13 18:12:52.900043-05
6e9e8ed0-1ab3-4fff-bdc5-1c6ef441d0ad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:12:01.120127-05	2025-10-13 06:12:01.133813-05	\N	2025-10-13 11:12:00	00:15:00	2025-10-13 06:11:01.120127-05	2025-10-13 06:12:01.143153-05	2025-10-13 06:13:01.120127-05	f	\N	2025-10-13 18:12:52.900043-05
c235a4ad-7a85-4463-b118-fee4826a98e8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:12:08.760434-05	2025-10-13 06:12:08.761837-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:10:08.760434-05	2025-10-13 06:12:08.768949-05	2025-10-13 06:20:08.760434-05	f	\N	2025-10-13 18:12:52.900043-05
7801b35b-1e6e-4f30-ae5a-85f264d64fcc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:21:01.321193-05	2025-10-12 17:21:04.32064-05	\N	2025-10-12 22:21:00	00:15:00	2025-10-12 17:20:04.321193-05	2025-10-12 17:21:04.33193-05	2025-10-12 17:22:01.321193-05	f	\N	2025-10-13 05:37:32.468098-05
e827966d-9a9d-450e-8f6b-af59bf1f5937	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:20:52.289016-05	2025-10-12 17:21:52.282531-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:18:52.289016-05	2025-10-12 17:21:52.290982-05	2025-10-12 17:28:52.289016-05	f	\N	2025-10-13 05:37:32.468098-05
2bf0812c-dfbf-4c55-8e2c-87ba326e1406	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:22:01.330797-05	2025-10-12 17:22:04.341492-05	\N	2025-10-12 22:22:00	00:15:00	2025-10-12 17:21:04.330797-05	2025-10-12 17:22:04.357204-05	2025-10-12 17:23:01.330797-05	f	\N	2025-10-13 05:37:32.468098-05
ee7e949f-10e3-43a9-8665-c94e3a94eabf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:23:01.354508-05	2025-10-12 17:23:04.360903-05	\N	2025-10-12 22:23:00	00:15:00	2025-10-12 17:22:04.354508-05	2025-10-12 17:23:04.381018-05	2025-10-12 17:24:01.354508-05	f	\N	2025-10-13 05:37:32.468098-05
860300e9-a4dc-48ca-9879-4b11c2c998b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:24:01.380063-05	2025-10-12 17:24:04.379684-05	\N	2025-10-12 22:24:00	00:15:00	2025-10-12 17:23:04.380063-05	2025-10-12 17:24:04.391214-05	2025-10-12 17:25:01.380063-05	f	\N	2025-10-13 05:37:32.468098-05
d6c8fa10-ead3-4df2-bf52-493660d672b0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:23:52.292371-05	2025-10-12 17:24:52.286275-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:21:52.292371-05	2025-10-12 17:24:52.295819-05	2025-10-12 17:31:52.292371-05	f	\N	2025-10-13 05:37:32.468098-05
d0c8f8f5-3a76-40a7-bcaa-1dbabcb4195d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:25:01.389336-05	2025-10-12 17:25:04.396807-05	\N	2025-10-12 22:25:00	00:15:00	2025-10-12 17:24:04.389336-05	2025-10-12 17:25:04.405004-05	2025-10-12 17:26:01.389336-05	f	\N	2025-10-13 05:37:32.468098-05
a234e72d-c80b-4672-bd11-465746e8852e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:26:01.403884-05	2025-10-12 17:26:04.409542-05	\N	2025-10-12 22:26:00	00:15:00	2025-10-12 17:25:04.403884-05	2025-10-12 17:26:04.419174-05	2025-10-12 17:27:01.403884-05	f	\N	2025-10-13 05:37:32.468098-05
2687dc9e-0928-4c82-a10a-e7a1ccbbbbec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:27:01.418196-05	2025-10-12 17:27:04.424448-05	\N	2025-10-12 22:27:00	00:15:00	2025-10-12 17:26:04.418196-05	2025-10-12 17:27:04.434524-05	2025-10-12 17:28:01.418196-05	f	\N	2025-10-13 05:37:32.468098-05
ec5866df-d737-477c-87bd-1852834871ea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:26:52.297643-05	2025-10-12 17:27:52.290493-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:24:52.297643-05	2025-10-12 17:27:52.298298-05	2025-10-12 17:34:52.297643-05	f	\N	2025-10-13 05:37:32.468098-05
473ca0aa-281e-4cdf-998e-f81b8529df2a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:28:01.43321-05	2025-10-12 17:28:04.440368-05	\N	2025-10-12 22:28:00	00:15:00	2025-10-12 17:27:04.43321-05	2025-10-12 17:28:04.45379-05	2025-10-12 17:29:01.43321-05	f	\N	2025-10-13 05:37:32.468098-05
88e4d1d5-d405-406e-8f48-4a302d0fa42f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:29:01.452486-05	2025-10-12 17:29:04.452245-05	\N	2025-10-12 22:29:00	00:15:00	2025-10-12 17:28:04.452486-05	2025-10-12 17:29:04.460543-05	2025-10-12 17:30:01.452486-05	f	\N	2025-10-13 05:37:32.468098-05
f676b1a9-033e-4c92-9b1a-0fd40a91b3cc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:30:01.459768-05	2025-10-12 17:30:04.466743-05	\N	2025-10-12 22:30:00	00:15:00	2025-10-12 17:29:04.459768-05	2025-10-12 17:30:04.478032-05	2025-10-12 17:31:01.459768-05	f	\N	2025-10-13 05:37:32.468098-05
88e15db4-d7e6-4009-91ca-03d34b46bd7e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:29:52.3004-05	2025-10-12 17:30:52.293558-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:27:52.3004-05	2025-10-12 17:30:52.302037-05	2025-10-12 17:37:52.3004-05	f	\N	2025-10-13 05:37:32.468098-05
4a0e6516-57d0-41f5-9f18-9b643a5a781d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:31:01.476295-05	2025-10-12 17:31:04.483995-05	\N	2025-10-12 22:31:00	00:15:00	2025-10-12 17:30:04.476295-05	2025-10-12 17:31:04.494455-05	2025-10-12 17:32:01.476295-05	f	\N	2025-10-13 05:37:32.468098-05
9ec45458-eada-47c8-b10d-4dca86207730	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:32:01.492881-05	2025-10-12 17:32:04.49699-05	\N	2025-10-12 22:32:00	00:15:00	2025-10-12 17:31:04.492881-05	2025-10-12 17:32:04.500729-05	2025-10-12 17:33:01.492881-05	f	\N	2025-10-13 05:37:32.468098-05
22cc5a72-cff9-45b0-a636-3ea5e3f37c2e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:33:01.499788-05	2025-10-12 17:33:04.51052-05	\N	2025-10-12 22:33:00	00:15:00	2025-10-12 17:32:04.499788-05	2025-10-12 17:33:04.521801-05	2025-10-12 17:34:01.499788-05	f	\N	2025-10-13 05:37:32.468098-05
ec009a08-dd2c-402a-a24c-1e38beedb8c3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:32:52.303646-05	2025-10-12 17:33:52.294542-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:30:52.303646-05	2025-10-12 17:33:52.301568-05	2025-10-12 17:40:52.303646-05	f	\N	2025-10-13 05:37:32.468098-05
6f52d187-f7db-4a11-8baa-dd0037303638	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:34:01.520396-05	2025-10-12 17:34:04.524631-05	\N	2025-10-12 22:34:00	00:15:00	2025-10-12 17:33:04.520396-05	2025-10-12 17:34:04.537618-05	2025-10-12 17:35:01.520396-05	f	\N	2025-10-13 05:37:32.468098-05
4cc2276a-d3c6-4e65-aa99-0ae5edc8891e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:35:01.535958-05	2025-10-12 17:35:04.542274-05	\N	2025-10-12 22:35:00	00:15:00	2025-10-12 17:34:04.535958-05	2025-10-12 17:35:04.549247-05	2025-10-12 17:36:01.535958-05	f	\N	2025-10-13 05:37:32.468098-05
ac25cf57-5eea-46a3-a018-6fa0b7c46086	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:36:01.548652-05	2025-10-12 17:36:04.552947-05	\N	2025-10-12 22:36:00	00:15:00	2025-10-12 17:35:04.548652-05	2025-10-12 17:36:04.561594-05	2025-10-12 17:37:01.548652-05	f	\N	2025-10-13 05:37:32.468098-05
c4b39095-f9ca-4b18-ad01-169fb37563c7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:35:52.303223-05	2025-10-12 17:36:52.297884-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:33:52.303223-05	2025-10-12 17:36:52.307558-05	2025-10-12 17:43:52.303223-05	f	\N	2025-10-13 05:37:32.468098-05
116740cd-5563-40a4-a443-4979b790c7ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:37:01.560643-05	2025-10-12 17:37:04.567964-05	\N	2025-10-12 22:37:00	00:15:00	2025-10-12 17:36:04.560643-05	2025-10-12 17:37:04.576566-05	2025-10-12 17:38:01.560643-05	f	\N	2025-10-13 05:37:32.468098-05
e4a74abe-f551-484e-a35d-6fa5af4c103d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:06:35.421384-05	2025-10-13 03:07:35.418971-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:04:35.421384-05	2025-10-13 03:07:35.426545-05	2025-10-13 03:14:35.421384-05	f	\N	2025-10-13 15:09:44.32602-05
83c34787-66a9-40ed-aacd-db16946de494	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:08:01.155256-05	2025-10-13 03:08:01.184168-05	\N	2025-10-13 08:08:00	00:15:00	2025-10-13 03:07:01.155256-05	2025-10-13 03:08:01.194548-05	2025-10-13 03:09:01.155256-05	f	\N	2025-10-13 15:09:44.32602-05
911c1f87-7df3-4b18-987a-9afa2fc82d8f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:09:01.192703-05	2025-10-13 03:09:01.215052-05	\N	2025-10-13 08:09:00	00:15:00	2025-10-13 03:08:01.192703-05	2025-10-13 03:09:01.226039-05	2025-10-13 03:10:01.192703-05	f	\N	2025-10-13 15:09:44.32602-05
f6b8e2ff-180c-48e5-8484-7a4b7eede59d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 03:09:35.428059-05	2025-10-13 03:10:35.42525-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 03:07:35.428059-05	2025-10-13 03:10:35.431231-05	2025-10-13 03:17:35.428059-05	f	\N	2025-10-13 15:12:44.295899-05
e877e8fb-004b-43b1-a95a-5c58f6ac243b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:11:01.252487-05	2025-10-13 03:11:01.27131-05	\N	2025-10-13 08:11:00	00:15:00	2025-10-13 03:10:01.252487-05	2025-10-13 03:11:01.281348-05	2025-10-13 03:12:01.252487-05	f	\N	2025-10-13 15:12:44.295899-05
260e8501-882b-4ac3-960d-6dc985decebe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:12:01.27962-05	2025-10-13 03:12:01.299074-05	\N	2025-10-13 08:12:00	00:15:00	2025-10-13 03:11:01.27962-05	2025-10-13 03:12:01.307478-05	2025-10-13 03:13:01.27962-05	f	\N	2025-10-13 15:12:44.295899-05
d415a0ec-2df8-4cf9-a57f-172e84cf00a6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 03:10:01.224312-05	2025-10-13 03:10:01.243758-05	\N	2025-10-13 08:10:00	00:15:00	2025-10-13 03:09:01.224312-05	2025-10-13 03:10:01.254204-05	2025-10-13 03:11:01.224312-05	f	\N	2025-10-13 15:12:44.295899-05
81819877-cb38-4286-969a-5a44aac0adcc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:15:01.203675-05	2025-10-13 06:15:01.218012-05	\N	2025-10-13 11:15:00	00:15:00	2025-10-13 06:14:01.203675-05	2025-10-13 06:15:01.228406-05	2025-10-13 06:16:01.203675-05	f	\N	2025-10-13 18:15:52.905119-05
210c29e2-3019-48f7-bd13-b5981e003424	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:14:08.770563-05	2025-10-13 06:15:08.768552-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:12:08.770563-05	2025-10-13 06:15:08.775942-05	2025-10-13 06:22:08.770563-05	f	\N	2025-10-13 18:15:52.905119-05
aa3ea9ba-aff4-496e-9eb7-5f99d95b5082	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:14:01.174421-05	2025-10-13 06:14:01.194366-05	\N	2025-10-13 11:14:00	00:15:00	2025-10-13 06:13:01.174421-05	2025-10-13 06:14:01.205918-05	2025-10-13 06:15:01.174421-05	f	\N	2025-10-13 18:15:52.905119-05
f5810ba3-3c40-4fa9-8daf-00833d50fc17	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:13:01.141693-05	2025-10-13 06:13:01.166027-05	\N	2025-10-13 11:13:00	00:15:00	2025-10-13 06:12:01.141693-05	2025-10-13 06:13:01.1758-05	2025-10-13 06:14:01.141693-05	f	\N	2025-10-13 18:15:52.905119-05
0c72e4af-198b-46a5-9aa7-df56df995a27	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:38:01.575845-05	2025-10-12 17:38:04.580172-05	\N	2025-10-12 22:38:00	00:15:00	2025-10-12 17:37:04.575845-05	2025-10-12 17:38:04.588176-05	2025-10-12 17:39:01.575845-05	f	\N	2025-10-13 05:38:32.459072-05
b2f8dee8-1c08-4718-bfd0-c5f5c9fb6200	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:16:01.226992-05	2025-10-13 06:16:01.24321-05	\N	2025-10-13 11:16:00	00:15:00	2025-10-13 06:15:01.226992-05	2025-10-13 06:16:01.253766-05	2025-10-13 06:17:01.226992-05	f	\N	2025-10-13 18:33:28.140275-05
87c7fa53-1753-4b28-9a2d-cb71764128f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:17:01.252192-05	2025-10-13 06:17:01.271836-05	\N	2025-10-13 11:17:00	00:15:00	2025-10-13 06:16:01.252192-05	2025-10-13 06:17:01.281117-05	2025-10-13 06:18:01.252192-05	f	\N	2025-10-13 18:33:28.140275-05
97e71b83-31f8-4731-bdb6-795c40f3b0e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:18:01.279508-05	2025-10-13 06:18:01.297722-05	\N	2025-10-13 11:18:00	00:15:00	2025-10-13 06:17:01.279508-05	2025-10-13 06:18:01.308638-05	2025-10-13 06:19:01.279508-05	f	\N	2025-10-13 18:33:28.140275-05
26bcf687-72c3-4021-a096-869f82fd4fd6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:17:08.777534-05	2025-10-13 06:18:08.777338-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:15:08.777534-05	2025-10-13 06:18:08.790278-05	2025-10-13 06:25:08.777534-05	f	\N	2025-10-13 18:33:28.140275-05
c39ca1ae-f47b-4447-b75b-390cc9c6532a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:19:01.306964-05	2025-10-13 06:19:01.324395-05	\N	2025-10-13 11:19:00	00:15:00	2025-10-13 06:18:01.306964-05	2025-10-13 06:19:01.333181-05	2025-10-13 06:20:01.306964-05	f	\N	2025-10-13 18:33:28.140275-05
e577d76e-6f26-4684-b40b-db187665b745	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:20:01.332-05	2025-10-13 06:20:01.349386-05	\N	2025-10-13 11:20:00	00:15:00	2025-10-13 06:19:01.332-05	2025-10-13 06:20:01.358747-05	2025-10-13 06:21:01.332-05	f	\N	2025-10-13 18:33:28.140275-05
8dfae7c4-238d-42a5-970c-ec92b092e83f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:21:01.357508-05	2025-10-13 06:21:01.376369-05	\N	2025-10-13 11:21:00	00:15:00	2025-10-13 06:20:01.357508-05	2025-10-13 06:21:01.38499-05	2025-10-13 06:22:01.357508-05	f	\N	2025-10-13 18:33:28.140275-05
c890f1cb-7385-4077-aef5-565d1ced7026	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:20:08.793207-05	2025-10-13 06:21:08.779413-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:18:08.793207-05	2025-10-13 06:21:08.784229-05	2025-10-13 06:28:08.793207-05	f	\N	2025-10-13 18:33:28.140275-05
e5ecc2d1-d4f5-49f5-a0e5-389e925059d6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:22:01.38374-05	2025-10-13 06:22:01.397643-05	\N	2025-10-13 11:22:00	00:15:00	2025-10-13 06:21:01.38374-05	2025-10-13 06:22:01.409303-05	2025-10-13 06:23:01.38374-05	f	\N	2025-10-13 18:33:28.140275-05
956dca6f-02a5-4b1a-baef-389610b9d0bd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:23:01.40761-05	2025-10-13 06:23:01.421669-05	\N	2025-10-13 11:23:00	00:15:00	2025-10-13 06:22:01.40761-05	2025-10-13 06:23:01.431614-05	2025-10-13 06:24:01.40761-05	f	\N	2025-10-13 18:33:28.140275-05
99b08cf0-b049-48c6-b72f-c183f7e2a37a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:24:01.43013-05	2025-10-13 06:24:05.425345-05	\N	2025-10-13 11:24:00	00:15:00	2025-10-13 06:23:01.43013-05	2025-10-13 06:24:05.437577-05	2025-10-13 06:25:01.43013-05	f	\N	2025-10-13 18:33:28.140275-05
33890ff3-d14f-486c-a3f6-7203011b8550	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:25:01.435964-05	2025-10-13 06:25:01.457897-05	\N	2025-10-13 11:25:00	00:15:00	2025-10-13 06:24:05.435964-05	2025-10-13 06:25:01.464573-05	2025-10-13 06:26:01.435964-05	f	\N	2025-10-13 18:33:28.140275-05
65b77de9-cdbf-4916-82b3-eea1dee8b719	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:26:01.46394-05	2025-10-13 06:26:01.471145-05	\N	2025-10-13 11:26:00	00:15:00	2025-10-13 06:25:01.46394-05	2025-10-13 06:26:01.482208-05	2025-10-13 06:27:01.46394-05	f	\N	2025-10-13 18:33:28.140275-05
16cf8a3b-1d0d-4f14-ab71-da376249f170	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:27:01.480534-05	2025-10-13 06:27:01.483635-05	\N	2025-10-13 11:27:00	00:15:00	2025-10-13 06:26:01.480534-05	2025-10-13 06:27:01.49247-05	2025-10-13 06:28:01.480534-05	f	\N	2025-10-13 18:33:28.140275-05
0563afc1-aefb-4ee7-81d6-7186406f7bba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:28:01.491561-05	2025-10-13 06:28:01.498278-05	\N	2025-10-13 11:28:00	00:15:00	2025-10-13 06:27:01.491561-05	2025-10-13 06:28:01.509208-05	2025-10-13 06:29:01.491561-05	f	\N	2025-10-13 18:33:28.140275-05
709fbef7-ab4e-4fd4-a40b-460e4b6589a2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:30:01.523496-05	2025-10-13 06:30:01.53566-05	\N	2025-10-13 11:30:00	00:15:00	2025-10-13 06:29:01.523496-05	2025-10-13 06:30:01.545711-05	2025-10-13 06:31:01.523496-05	f	\N	2025-10-13 18:33:28.140275-05
1924fe09-258e-45bb-99b5-554aecdd3444	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:29:08.778594-05	2025-10-13 06:30:08.772367-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:27:08.778594-05	2025-10-13 06:30:08.780315-05	2025-10-13 06:37:08.778594-05	f	\N	2025-10-13 18:33:28.140275-05
e8164b15-fe46-4c12-83b4-246f7b788cdf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:33:01.569277-05	2025-10-13 06:33:01.578473-05	\N	2025-10-13 11:33:00	00:15:00	2025-10-13 06:32:01.569277-05	2025-10-13 06:33:01.588832-05	2025-10-13 06:34:01.569277-05	f	\N	2025-10-13 18:33:28.140275-05
35ee0813-856f-41e2-a936-52c5fac399a6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:23:08.785425-05	2025-10-13 06:24:08.758142-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:21:08.785425-05	2025-10-13 06:24:08.770905-05	2025-10-13 06:31:08.785425-05	f	\N	2025-10-13 18:33:28.140275-05
13f5a52e-5b0a-4ce7-8282-77354e79f57b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:26:08.77333-05	2025-10-13 06:27:08.771276-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:24:08.77333-05	2025-10-13 06:27:08.777414-05	2025-10-13 06:34:08.77333-05	f	\N	2025-10-13 18:33:28.140275-05
3dbff002-b465-4701-9412-447f9b98da37	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:29:01.507606-05	2025-10-13 06:29:01.515414-05	\N	2025-10-13 11:29:00	00:15:00	2025-10-13 06:28:01.507606-05	2025-10-13 06:29:01.525027-05	2025-10-13 06:30:01.507606-05	f	\N	2025-10-13 18:33:28.140275-05
d56b9d4d-1861-487e-9e72-22b70b1d35fd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:31:01.544318-05	2025-10-13 06:31:01.550313-05	\N	2025-10-13 11:31:00	00:15:00	2025-10-13 06:30:01.544318-05	2025-10-13 06:31:01.557893-05	2025-10-13 06:32:01.544318-05	f	\N	2025-10-13 18:33:28.140275-05
4e4312ea-f110-4472-9379-dd818d5a1885	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:32:01.556831-05	2025-10-13 06:32:01.564471-05	\N	2025-10-13 11:32:00	00:15:00	2025-10-13 06:31:01.556831-05	2025-10-13 06:32:01.570315-05	2025-10-13 06:33:01.556831-05	f	\N	2025-10-13 18:33:28.140275-05
93b6aebb-1397-4f90-b8e1-fdff5239d286	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:32:08.781942-05	2025-10-13 06:33:08.774502-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:30:08.781942-05	2025-10-13 06:33:08.780802-05	2025-10-13 06:40:08.781942-05	f	\N	2025-10-13 18:33:28.140275-05
ddb484d5-3b44-4b7d-bc7d-6e0967b9e3d6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:39:01.587137-05	2025-10-12 17:39:04.591794-05	\N	2025-10-12 22:39:00	00:15:00	2025-10-12 17:38:04.587137-05	2025-10-12 17:39:04.599338-05	2025-10-12 17:40:01.587137-05	f	\N	2025-10-13 05:41:42.744998-05
89efa00b-7f2d-49cb-bd87-794699ee2664	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:38:52.309555-05	2025-10-12 17:39:52.301547-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:36:52.309555-05	2025-10-12 17:39:52.310678-05	2025-10-12 17:46:52.309555-05	f	\N	2025-10-13 05:41:42.744998-05
8fa8baa2-6c26-4def-a16c-365dcf5dbb0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:40:01.598402-05	2025-10-12 17:40:04.601044-05	\N	2025-10-12 22:40:00	00:15:00	2025-10-12 17:39:04.598402-05	2025-10-12 17:40:04.614241-05	2025-10-12 17:41:01.598402-05	f	\N	2025-10-13 05:41:42.744998-05
129df652-e664-458b-87d6-728736c5bd8f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:41:01.612167-05	2025-10-12 17:41:04.613726-05	\N	2025-10-12 22:41:00	00:15:00	2025-10-12 17:40:04.612167-05	2025-10-12 17:41:04.628817-05	2025-10-12 17:42:01.612167-05	f	\N	2025-10-13 05:41:42.744998-05
c49e0617-7975-461c-9a6b-89a37f318de0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:34:01.587286-05	2025-10-13 06:34:01.591325-05	\N	2025-10-13 11:34:00	00:15:00	2025-10-13 06:33:01.587286-05	2025-10-13 06:34:01.60166-05	2025-10-13 06:35:01.587286-05	f	\N	2025-10-13 18:41:57.710958-05
0125e336-9095-4ab2-a4f9-1717d081917b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:35:01.600245-05	2025-10-13 06:35:01.604986-05	\N	2025-10-13 11:35:00	00:15:00	2025-10-13 06:34:01.600245-05	2025-10-13 06:35:01.61527-05	2025-10-13 06:36:01.600245-05	f	\N	2025-10-13 18:41:57.710958-05
1efe844d-feef-49ad-95b5-a0709532734f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:35:08.782112-05	2025-10-13 06:36:08.776656-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:33:08.782112-05	2025-10-13 06:36:08.780762-05	2025-10-13 06:43:08.782112-05	f	\N	2025-10-13 18:41:57.710958-05
3ea7557a-e086-4208-8fdf-622f12572c03	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:37:01.625845-05	2025-10-13 06:37:01.634712-05	\N	2025-10-13 11:37:00	00:15:00	2025-10-13 06:36:01.625845-05	2025-10-13 06:37:01.646869-05	2025-10-13 06:38:01.625845-05	f	\N	2025-10-13 18:41:57.710958-05
a2eb8e1c-5209-42be-b51f-283a4d600b1d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:39:01.653871-05	2025-10-13 06:39:01.659274-05	\N	2025-10-13 11:39:00	00:15:00	2025-10-13 06:38:01.653871-05	2025-10-13 06:39:01.670001-05	2025-10-13 06:40:01.653871-05	f	\N	2025-10-13 18:41:57.710958-05
23e6a0b1-62eb-45e8-b2aa-26bed90e892b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:38:08.781724-05	2025-10-13 06:39:08.777975-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:36:08.781724-05	2025-10-13 06:39:08.782969-05	2025-10-13 06:46:08.781724-05	f	\N	2025-10-13 18:41:57.710958-05
a73b83ca-8551-4f90-9a53-c5205a90104c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:36:01.61374-05	2025-10-13 06:36:01.619692-05	\N	2025-10-13 11:36:00	00:15:00	2025-10-13 06:35:01.61374-05	2025-10-13 06:36:01.62629-05	2025-10-13 06:37:01.61374-05	f	\N	2025-10-13 18:41:57.710958-05
ceaceb94-f799-4faa-8534-783bd5cc1194	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:38:01.645126-05	2025-10-13 06:38:01.646459-05	\N	2025-10-13 11:38:00	00:15:00	2025-10-13 06:37:01.645126-05	2025-10-13 06:38:01.654721-05	2025-10-13 06:39:01.645126-05	f	\N	2025-10-13 18:41:57.710958-05
e15cc698-6ba0-4dc9-a13f-73cd80c87e41	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:40:01.668661-05	2025-10-13 06:40:01.671737-05	\N	2025-10-13 11:40:00	00:15:00	2025-10-13 06:39:01.668661-05	2025-10-13 06:40:01.681799-05	2025-10-13 06:41:01.668661-05	f	\N	2025-10-13 18:41:57.710958-05
bb6f3d91-0b71-4a7f-beb5-188ef5dc457d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:41:01.680451-05	2025-10-13 06:41:01.685322-05	\N	2025-10-13 11:41:00	00:15:00	2025-10-13 06:40:01.680451-05	2025-10-13 06:41:01.696351-05	2025-10-13 06:42:01.680451-05	f	\N	2025-10-13 18:41:57.710958-05
021d044f-4fd8-4b99-af38-38273ccf1679	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:44:01.647162-05	2025-10-12 17:44:04.654969-05	\N	2025-10-12 22:44:00	00:15:00	2025-10-12 17:43:04.647162-05	2025-10-12 17:44:04.668232-05	2025-10-12 17:45:01.647162-05	f	\N	2025-10-13 05:48:02.036145-05
6728228e-51dc-40af-87bd-7453432c5a20	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:45:01.666847-05	2025-10-12 17:45:04.66964-05	\N	2025-10-12 22:45:00	00:15:00	2025-10-12 17:44:04.666847-05	2025-10-12 17:45:04.679863-05	2025-10-12 17:46:01.666847-05	f	\N	2025-10-13 05:48:02.036145-05
b2c6adb2-146f-4571-afb8-4fe758abf075	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:46:01.679369-05	2025-10-12 17:46:04.687342-05	\N	2025-10-12 22:46:00	00:15:00	2025-10-12 17:45:04.679369-05	2025-10-12 17:46:04.697217-05	2025-10-12 17:47:01.679369-05	f	\N	2025-10-13 05:48:02.036145-05
f268ccbf-49ab-4aea-a724-e70036feecc8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:47:01.696106-05	2025-10-12 17:47:04.705548-05	\N	2025-10-12 22:47:00	00:15:00	2025-10-12 17:46:04.696106-05	2025-10-12 17:47:04.712651-05	2025-10-12 17:48:01.696106-05	f	\N	2025-10-13 05:48:02.036145-05
8441833c-2ee7-4c22-aa2c-692b2c0db975	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:42:01.626875-05	2025-10-12 17:42:04.626795-05	\N	2025-10-12 22:42:00	00:15:00	2025-10-12 17:41:04.626875-05	2025-10-12 17:42:04.630556-05	2025-10-12 17:43:01.626875-05	f	\N	2025-10-13 05:48:02.036145-05
19b259c6-0751-487e-ae88-a4d7afa598d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:43:01.629692-05	2025-10-12 17:43:04.638912-05	\N	2025-10-12 22:43:00	00:15:00	2025-10-12 17:42:04.629692-05	2025-10-12 17:43:04.648331-05	2025-10-12 17:44:01.629692-05	f	\N	2025-10-13 05:48:02.036145-05
26fc679f-5283-43ae-a272-6444f1eb26f3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:41:52.313849-05	2025-10-12 17:42:52.303604-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:39:52.313849-05	2025-10-12 17:42:52.309717-05	2025-10-12 17:49:52.313849-05	f	\N	2025-10-13 05:48:02.036145-05
7dc64a1c-6c99-40ee-af70-9b9d4a659c2b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:44:52.311699-05	2025-10-12 17:45:52.307996-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:42:52.311699-05	2025-10-12 17:45:52.310886-05	2025-10-12 17:52:52.311699-05	f	\N	2025-10-13 05:48:02.036145-05
e9047efe-db8e-4f16-88f0-f3e668574ed0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:41:08.783981-05	2025-10-13 06:42:08.780269-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:39:08.783981-05	2025-10-13 06:42:08.788985-05	2025-10-13 06:49:08.783981-05	f	\N	2025-10-13 18:42:57.699369-05
12258304-2e59-43c6-88df-0f02e97ac18d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:42:01.695094-05	2025-10-13 06:42:01.700907-05	\N	2025-10-13 11:42:00	00:15:00	2025-10-13 06:41:01.695094-05	2025-10-13 06:42:01.708489-05	2025-10-13 06:43:01.695094-05	f	\N	2025-10-13 18:42:57.699369-05
2f52b404-2e97-44cc-a3f5-08d9d614bff2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:48:01.711583-05	2025-10-12 17:48:26.883585-05	\N	2025-10-12 22:48:00	00:15:00	2025-10-12 17:47:04.711583-05	2025-10-12 17:48:26.886857-05	2025-10-12 17:49:01.711583-05	f	\N	2025-10-13 05:58:08.74709-05
2147697b-7bc1-4a88-9d23-f1ad04ed22e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:49:01.889981-05	2025-10-12 17:49:02.893341-05	\N	2025-10-12 22:49:00	00:15:00	2025-10-12 17:48:26.889981-05	2025-10-12 17:49:02.916759-05	2025-10-12 17:50:01.889981-05	f	\N	2025-10-13 05:58:08.74709-05
003043bb-8731-4c08-8b8b-aed320c1e48e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:50:01.915856-05	2025-10-12 17:50:02.909154-05	\N	2025-10-12 22:50:00	00:15:00	2025-10-12 17:49:02.915856-05	2025-10-12 17:50:02.925238-05	2025-10-12 17:51:01.915856-05	f	\N	2025-10-13 05:58:08.74709-05
ee446a67-7fcf-4b1c-ad45-72fc31dcdf38	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:54:34.540367-05	2025-10-12 17:54:34.542716-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:54:34.540367-05	2025-10-12 17:54:34.548458-05	2025-10-12 18:02:34.540367-05	f	\N	2025-10-13 05:58:08.74709-05
d6db8731-6837-4ff5-8e38-df20b4f505fd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:55:01.990225-05	2025-10-12 17:55:02.556865-05	\N	2025-10-12 22:55:00	00:15:00	2025-10-12 17:54:02.990225-05	2025-10-12 17:55:02.591191-05	2025-10-12 17:56:01.990225-05	f	\N	2025-10-13 05:58:08.74709-05
0f50ab8e-e4ba-4f69-b406-0bd38c5afa7d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:57:01.585054-05	2025-10-12 17:57:02.583342-05	\N	2025-10-12 22:57:00	00:15:00	2025-10-12 17:56:02.585054-05	2025-10-12 17:57:02.596777-05	2025-10-12 17:58:01.585054-05	f	\N	2025-10-13 05:58:08.74709-05
fde1777c-810d-4b09-a309-a23b601b1f24	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:56:34.549411-05	2025-10-12 17:57:34.546301-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:54:34.549411-05	2025-10-12 17:57:34.551252-05	2025-10-12 18:04:34.549411-05	f	\N	2025-10-13 05:58:08.74709-05
fec592a6-4e6f-4be5-81b8-e33562a6e69a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:58:01.59572-05	2025-10-12 17:58:02.595588-05	\N	2025-10-12 22:58:00	00:15:00	2025-10-12 17:57:02.59572-05	2025-10-12 17:58:02.609753-05	2025-10-12 17:59:01.59572-05	f	\N	2025-10-13 05:58:08.74709-05
d6ce28ea-9df7-4e28-b71c-36bf0f602a23	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:48:26.875776-05	2025-10-12 17:48:26.877768-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:48:26.875776-05	2025-10-12 17:48:26.884617-05	2025-10-12 17:56:26.875776-05	f	\N	2025-10-13 05:58:08.74709-05
609838d4-e951-4867-8d6d-c427eb9fca1b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:51:01.923546-05	2025-10-12 17:51:02.924391-05	\N	2025-10-12 22:51:00	00:15:00	2025-10-12 17:50:02.923546-05	2025-10-12 17:51:02.939287-05	2025-10-12 17:52:01.923546-05	f	\N	2025-10-13 05:58:08.74709-05
148d0f99-9790-46df-9fd5-23712906f6a8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:50:26.885447-05	2025-10-12 17:51:26.881738-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:48:26.885447-05	2025-10-12 17:51:26.889807-05	2025-10-12 17:58:26.885447-05	f	\N	2025-10-13 05:58:08.74709-05
d6134c42-fb0b-4f09-beb6-9493b41a37c3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:52:01.937995-05	2025-10-12 17:52:02.940417-05	\N	2025-10-12 22:52:00	00:15:00	2025-10-12 17:51:02.937995-05	2025-10-12 17:52:02.959624-05	2025-10-12 17:53:01.937995-05	f	\N	2025-10-13 05:58:08.74709-05
28681cfe-0c98-4bcc-9b3e-b725f5416f1d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:53:01.958213-05	2025-10-12 17:53:02.960791-05	\N	2025-10-12 22:53:00	00:15:00	2025-10-12 17:52:02.958213-05	2025-10-12 17:53:02.976444-05	2025-10-12 17:54:01.958213-05	f	\N	2025-10-13 05:58:08.74709-05
2f21d486-92df-4ed8-b0fc-6b8bb4db7916	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:54:01.975236-05	2025-10-12 17:54:02.972293-05	\N	2025-10-12 22:54:00	00:15:00	2025-10-12 17:53:02.975236-05	2025-10-12 17:54:02.991665-05	2025-10-12 17:55:01.975236-05	f	\N	2025-10-13 05:58:08.74709-05
d7d67c2f-69b0-48cb-bb9f-68e7847eab2d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:53:26.891737-05	2025-10-12 17:54:26.885368-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:51:26.891737-05	2025-10-12 17:54:26.895293-05	2025-10-12 18:01:26.891737-05	f	\N	2025-10-13 05:58:08.74709-05
2aa28ea7-ce92-4d8b-942c-5e2feb2b2af8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:56:01.58813-05	2025-10-12 17:56:02.568254-05	\N	2025-10-12 22:56:00	00:15:00	2025-10-12 17:55:02.58813-05	2025-10-12 17:56:02.586267-05	2025-10-12 17:57:01.58813-05	f	\N	2025-10-13 05:58:08.74709-05
4d3ec708-54d5-449c-b866-6fba391aa8bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:02:01.646128-05	2025-10-12 18:02:02.655303-05	\N	2025-10-12 23:02:00	00:15:00	2025-10-12 18:01:02.646128-05	2025-10-12 18:02:02.663571-05	2025-10-12 18:03:01.646128-05	f	\N	2025-10-13 06:04:08.752383-05
4d3d54c4-04a1-45aa-afff-4ca6fff23f77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:03:01.662393-05	2025-10-12 18:03:02.670002-05	\N	2025-10-12 23:03:00	00:15:00	2025-10-12 18:02:02.662393-05	2025-10-12 18:03:02.679216-05	2025-10-12 18:04:01.662393-05	f	\N	2025-10-13 06:04:08.752383-05
341e2d05-8696-44b0-bfa0-ecdd1d57e8d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:04:01.677994-05	2025-10-12 18:04:02.687647-05	\N	2025-10-12 23:04:00	00:15:00	2025-10-12 18:03:02.677994-05	2025-10-12 18:04:02.695412-05	2025-10-12 18:05:01.677994-05	f	\N	2025-10-13 06:04:08.752383-05
232888f5-8451-473f-8f9f-101f239f0257	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:02:34.558493-05	2025-10-12 18:03:34.551894-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:00:34.558493-05	2025-10-12 18:03:34.559906-05	2025-10-12 18:10:34.558493-05	f	\N	2025-10-13 06:04:08.752383-05
977c8045-65b0-4740-809c-c416ac8a655a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:08:34.567371-05	2025-10-12 18:08:34.576931-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:06:34.567371-05	2025-10-12 18:08:34.585987-05	2025-10-12 18:16:34.567371-05	f	\N	2025-10-13 06:10:08.758569-05
68bbce80-4bdb-4307-9c05-7519def828f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:10:01.786209-05	2025-10-12 18:10:02.791322-05	\N	2025-10-12 23:10:00	00:15:00	2025-10-12 18:09:02.786209-05	2025-10-12 18:10:02.802136-05	2025-10-12 18:11:01.786209-05	f	\N	2025-10-13 06:10:08.758569-05
a4832475-7022-4c2b-9e2d-3d4641ee7452	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:08:01.73855-05	2025-10-12 18:08:02.762498-05	\N	2025-10-12 23:08:00	00:15:00	2025-10-12 18:07:02.73855-05	2025-10-12 18:08:02.774533-05	2025-10-12 18:09:01.73855-05	f	\N	2025-10-13 06:10:08.758569-05
8b5c6a5b-bf91-44c4-903a-b4e012ac7585	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:09:01.772788-05	2025-10-12 18:09:02.777008-05	\N	2025-10-12 23:09:00	00:15:00	2025-10-12 18:08:02.772788-05	2025-10-12 18:09:02.788012-05	2025-10-12 18:10:01.772788-05	f	\N	2025-10-13 06:10:08.758569-05
ee8e9dfe-8598-407f-b39a-f42ec0b39c0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:19:01.912705-05	2025-10-12 18:19:02.921256-05	\N	2025-10-12 23:19:00	00:15:00	2025-10-12 18:18:02.912705-05	2025-10-12 18:19:02.931563-05	2025-10-12 18:20:01.912705-05	f	\N	2025-10-13 06:21:08.781903-05
d10a7335-9e61-4909-bfc4-660771b615ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:20:01.930385-05	2025-10-12 18:20:02.93841-05	\N	2025-10-12 23:20:00	00:15:00	2025-10-12 18:19:02.930385-05	2025-10-12 18:20:02.946635-05	2025-10-12 18:21:01.930385-05	f	\N	2025-10-13 06:21:08.781903-05
1d57b9ab-a6f0-4f7e-8097-f80e5b20b6d9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:19:34.601956-05	2025-10-12 18:20:34.593624-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:17:34.601956-05	2025-10-12 18:20:34.598297-05	2025-10-12 18:27:34.601956-05	f	\N	2025-10-13 06:21:08.781903-05
434e8478-669d-4219-af48-a0e61709b7e1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-05 11:06:34.939351-05	2025-10-05 11:06:34.943069-05	__pgboss__maintenance	\N	00:15:00	2025-10-05 11:06:34.939351-05	2025-10-05 11:06:34.951193-05	2025-10-05 11:14:34.939351-05	f	\N	2025-10-07 14:05:41.173252-05
ed37d906-0b90-41d8-8a47-7cd91d4eb12a	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-05 11:07:01.967347-05	\N	\N	2025-10-05 16:07:00	00:15:00	2025-10-05 11:06:38.967347-05	\N	2025-10-05 11:08:01.967347-05	f	\N	2025-10-07 14:05:41.173252-05
96ba4f39-ca17-413f-a0ff-95fd960bcbd8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-05 10:27:11.881162-05	2025-10-05 10:27:11.886494-05	__pgboss__maintenance	\N	00:15:00	2025-10-05 10:27:11.881162-05	2025-10-05 10:27:11.89774-05	2025-10-05 10:35:11.881162-05	f	\N	2025-10-07 14:05:41.173252-05
1560be21-b0fd-4767-9200-277cb9bc397c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-05 11:06:34.954548-05	2025-10-05 11:06:38.950129-05	\N	2025-10-05 16:06:00	00:15:00	2025-10-05 11:06:34.954548-05	2025-10-05 11:06:38.969149-05	2025-10-05 11:07:34.954548-05	f	\N	2025-10-07 14:05:41.173252-05
17a7a4c1-1666-4079-b674-353c2f381dda	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-05 10:27:11.898149-05	2025-10-05 10:27:15.894748-05	\N	2025-10-05 15:27:00	00:15:00	2025-10-05 10:27:11.898149-05	2025-10-05 10:27:15.910549-05	2025-10-05 10:28:11.898149-05	f	\N	2025-10-07 14:05:41.173252-05
cb862b44-768e-4573-877b-b7c367b98d76	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:21:01.945425-05	2025-10-12 18:21:02.957373-05	\N	2025-10-12 23:21:00	00:15:00	2025-10-12 18:20:02.945425-05	2025-10-12 18:21:02.970575-05	2025-10-12 18:22:01.945425-05	f	\N	2025-10-13 06:21:08.781903-05
cdf7dff9-8523-4cc7-9b78-2ae898a12dcf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:44:08.790816-05	2025-10-13 06:45:08.782619-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:42:08.790816-05	2025-10-13 06:45:08.786649-05	2025-10-13 06:52:08.790816-05	f	\N	2025-10-13 18:45:46.624528-05
62fd3a57-592b-4a69-ae65-91eb1b412e0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:43:01.707643-05	2025-10-13 06:43:01.717395-05	\N	2025-10-13 11:43:00	00:15:00	2025-10-13 06:42:01.707643-05	2025-10-13 06:43:01.728443-05	2025-10-13 06:44:01.707643-05	f	\N	2025-10-13 18:45:46.624528-05
c3890681-e8c2-4ce2-9d77-a8ca445963aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:44:01.727186-05	2025-10-13 06:44:01.732209-05	\N	2025-10-13 11:44:00	00:15:00	2025-10-13 06:43:01.727186-05	2025-10-13 06:44:01.7413-05	2025-10-13 06:45:01.727186-05	f	\N	2025-10-13 18:45:46.624528-05
1d46da4d-7d93-427d-8a83-05fbf31ac13c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:45:01.740211-05	2025-10-13 06:45:01.749677-05	\N	2025-10-13 11:45:00	00:15:00	2025-10-13 06:44:01.740211-05	2025-10-13 06:45:01.759773-05	2025-10-13 06:46:01.740211-05	f	\N	2025-10-13 18:45:46.624528-05
70f7e17b-a693-4a41-afa2-2fdbe17acaa2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:00:01.625511-05	2025-10-12 18:00:02.626895-05	\N	2025-10-12 23:00:00	00:15:00	2025-10-12 17:59:02.625511-05	2025-10-12 18:00:02.636185-05	2025-10-12 18:01:01.625511-05	f	\N	2025-10-13 06:01:08.746264-05
440e76ea-49c3-45e0-a11e-ee229c8d1e2d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 17:59:34.5522-05	2025-10-12 18:00:34.548821-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 17:57:34.5522-05	2025-10-12 18:00:34.556383-05	2025-10-12 18:07:34.5522-05	f	\N	2025-10-13 06:01:08.746264-05
24aadfdd-20e3-4291-b53e-fe06d906d660	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 17:59:01.608674-05	2025-10-12 17:59:02.611336-05	\N	2025-10-12 22:59:00	00:15:00	2025-10-12 17:58:02.608674-05	2025-10-12 17:59:02.626924-05	2025-10-12 18:00:01.608674-05	f	\N	2025-10-13 06:01:08.746264-05
77841c67-7f2b-4b73-afb7-210c097a628e	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 18:00:02.631506-05	2025-10-12 18:00:06.628804-05	dailyStatsJob	2025-10-12 23:00:00	00:15:00	2025-10-12 18:00:02.631506-05	2025-10-12 18:00:06.63353-05	2025-10-26 18:00:02.631506-05	f	\N	2025-10-13 06:01:08.746264-05
03ca72f8-63a8-4db5-b5e6-bbecd0677757	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 18:00:06.631713-05	2025-10-12 18:00:06.731274-05	\N	\N	00:15:00	2025-10-12 18:00:06.631713-05	2025-10-12 18:00:07.002078-05	2025-10-26 18:00:06.631713-05	f	\N	2025-10-13 06:01:08.746264-05
86c94d87-26c6-49ae-bf51-0f351cae0e8d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:01:01.634668-05	2025-10-12 18:01:02.641522-05	\N	2025-10-12 23:01:00	00:15:00	2025-10-12 18:00:02.634668-05	2025-10-12 18:01:02.646787-05	2025-10-12 18:02:01.634668-05	f	\N	2025-10-13 06:01:08.746264-05
4c00a5bd-86e9-47d2-a1fe-1d00db161d25	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:05:01.694457-05	2025-10-12 18:05:02.703782-05	\N	2025-10-12 23:05:00	00:15:00	2025-10-12 18:04:02.694457-05	2025-10-12 18:05:02.713063-05	2025-10-12 18:06:01.694457-05	f	\N	2025-10-13 06:07:08.759317-05
55d85a51-c5f0-42f2-b115-5c11d9cbac30	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:06:01.71204-05	2025-10-12 18:06:02.716686-05	\N	2025-10-12 23:06:00	00:15:00	2025-10-12 18:05:02.71204-05	2025-10-12 18:06:02.729962-05	2025-10-12 18:07:01.71204-05	f	\N	2025-10-13 06:07:08.759317-05
c2ac72c6-7797-4788-bb10-c4a7f64e7389	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:05:34.561527-05	2025-10-12 18:06:34.556806-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:03:34.561527-05	2025-10-12 18:06:34.56601-05	2025-10-12 18:13:34.561527-05	f	\N	2025-10-13 06:07:08.759317-05
d7c49e09-f0b8-422c-83f1-0d964d991ccc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:07:01.728394-05	2025-10-12 18:07:02.730688-05	\N	2025-10-12 23:07:00	00:15:00	2025-10-12 18:06:02.728394-05	2025-10-12 18:07:02.739781-05	2025-10-12 18:08:01.728394-05	f	\N	2025-10-13 06:07:08.759317-05
b43659dd-373b-487c-8f95-5e5a4a5d8009	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:11:01.801084-05	2025-10-12 18:11:02.80902-05	\N	2025-10-12 23:11:00	00:15:00	2025-10-12 18:10:02.801084-05	2025-10-12 18:11:02.820556-05	2025-10-12 18:12:01.801084-05	f	\N	2025-10-13 06:12:08.76569-05
4f981aea-83e9-4d2e-89f2-fd54e46adf47	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:10:34.588119-05	2025-10-12 18:11:34.583072-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:08:34.588119-05	2025-10-12 18:11:34.593485-05	2025-10-12 18:18:34.588119-05	f	\N	2025-10-13 06:12:08.76569-05
33d3d6cc-81e3-4819-8b1d-b4395b623ec4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:12:01.818852-05	2025-10-12 18:12:02.824885-05	\N	2025-10-12 23:12:00	00:15:00	2025-10-12 18:11:02.818852-05	2025-10-12 18:12:02.835573-05	2025-10-12 18:13:01.818852-05	f	\N	2025-10-13 06:12:08.76569-05
02fbff52-559d-4bee-a03e-e3b0245bf32c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:13:01.834352-05	2025-10-12 18:13:02.839289-05	\N	2025-10-12 23:13:00	00:15:00	2025-10-12 18:12:02.834352-05	2025-10-12 18:13:02.849223-05	2025-10-12 18:14:01.834352-05	f	\N	2025-10-13 06:15:08.772641-05
7b5738c7-954e-4b63-a72e-aebcbddb0dfe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:14:01.847343-05	2025-10-12 18:14:02.850919-05	\N	2025-10-12 23:14:00	00:15:00	2025-10-12 18:13:02.847343-05	2025-10-12 18:14:02.859817-05	2025-10-12 18:15:01.847343-05	f	\N	2025-10-13 06:15:08.772641-05
c7cc42d9-f697-468f-b09a-347c8d4cd030	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:13:34.595009-05	2025-10-12 18:14:34.586077-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:11:34.595009-05	2025-10-12 18:14:34.594602-05	2025-10-12 18:21:34.595009-05	f	\N	2025-10-13 06:15:08.772641-05
782f5c2b-feb0-482e-96a1-45d24acad9cc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:15:01.858917-05	2025-10-12 18:15:02.862443-05	\N	2025-10-12 23:15:00	00:15:00	2025-10-12 18:14:02.858917-05	2025-10-12 18:15:02.87009-05	2025-10-12 18:16:01.858917-05	f	\N	2025-10-13 06:15:08.772641-05
8211320b-5049-4d9d-9f7e-f1d27888cbed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:16:01.86896-05	2025-10-12 18:16:02.873702-05	\N	2025-10-12 23:16:00	00:15:00	2025-10-12 18:15:02.86896-05	2025-10-12 18:16:02.88685-05	2025-10-12 18:17:01.86896-05	f	\N	2025-10-13 06:18:08.784754-05
16f57158-61ec-4cce-abfd-d7aaa018cdbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:17:01.885411-05	2025-10-12 18:17:02.889076-05	\N	2025-10-12 23:17:00	00:15:00	2025-10-12 18:16:02.885411-05	2025-10-12 18:17:02.901492-05	2025-10-12 18:18:01.885411-05	f	\N	2025-10-13 06:18:08.784754-05
ac992571-28f3-4248-b726-0203d28bb000	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:16:34.596324-05	2025-10-12 18:17:34.590244-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:14:34.596324-05	2025-10-12 18:17:34.600279-05	2025-10-12 18:24:34.596324-05	f	\N	2025-10-13 06:18:08.784754-05
040b13e5-cfd3-4dde-a0d3-00fd7865bc7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:18:01.899566-05	2025-10-12 18:18:02.904518-05	\N	2025-10-12 23:18:00	00:15:00	2025-10-12 18:17:02.899566-05	2025-10-12 18:18:02.914494-05	2025-10-12 18:19:01.899566-05	f	\N	2025-10-13 06:18:08.784754-05
579a8652-ac76-4510-a777-8ea98428c1aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:22:01.968291-05	2025-10-12 18:22:02.973567-05	\N	2025-10-12 23:22:00	00:15:00	2025-10-12 18:21:02.968291-05	2025-10-12 18:22:02.981359-05	2025-10-12 18:23:01.968291-05	f	\N	2025-10-13 06:24:08.76563-05
5aeb53e6-fa9c-4e36-9bd3-2c8ba3cb13bb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:23:01.980211-05	2025-10-12 18:23:02.99024-05	\N	2025-10-12 23:23:00	00:15:00	2025-10-12 18:22:02.980211-05	2025-10-12 18:23:02.999183-05	2025-10-12 18:24:01.980211-05	f	\N	2025-10-13 06:24:08.76563-05
e144e6a7-ab3f-4fb0-a621-e36f5acfaf87	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:22:34.599969-05	2025-10-12 18:23:34.598192-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:20:34.599969-05	2025-10-12 18:23:34.606833-05	2025-10-12 18:30:34.599969-05	f	\N	2025-10-13 06:24:08.76563-05
5e7c6c68-641e-48ad-b855-921ac65232fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:24:01.998272-05	2025-10-12 18:24:03.002966-05	\N	2025-10-12 23:24:00	00:15:00	2025-10-12 18:23:02.998272-05	2025-10-12 18:24:03.011161-05	2025-10-12 18:25:01.998272-05	f	\N	2025-10-13 06:24:08.76563-05
2a81c531-5f9c-4ae1-bcb4-c5feb3a97322	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:28:01.05428-05	2025-10-12 18:28:03.056833-05	\N	2025-10-12 23:28:00	00:15:00	2025-10-12 18:27:03.05428-05	2025-10-12 18:28:03.068422-05	2025-10-12 18:29:01.05428-05	f	\N	2025-10-13 06:30:08.776803-05
6a86782b-3cfc-44e4-8166-eb3006c53316	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:29:01.067152-05	2025-10-12 18:29:03.070527-05	\N	2025-10-12 23:29:00	00:15:00	2025-10-12 18:28:03.067152-05	2025-10-12 18:29:03.079352-05	2025-10-12 18:30:01.067152-05	f	\N	2025-10-13 06:30:08.776803-05
99c57e7e-da93-4d74-aaae-81db414099e4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:28:34.60931-05	2025-10-12 18:29:34.604248-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:26:34.60931-05	2025-10-12 18:29:34.609351-05	2025-10-12 18:36:34.60931-05	f	\N	2025-10-13 06:30:08.776803-05
87626bc1-ee1f-4398-87bf-0dcd5c8701a2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:30:01.078083-05	2025-10-12 18:30:03.087086-05	\N	2025-10-12 23:30:00	00:15:00	2025-10-12 18:29:03.078083-05	2025-10-12 18:30:03.097656-05	2025-10-12 18:31:01.078083-05	f	\N	2025-10-13 06:30:08.776803-05
07854cf7-0e5b-4547-b269-3cec7f1b0f52	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:40:01.332478-05	2025-10-12 18:40:03.356048-05	\N	2025-10-12 23:40:00	00:15:00	2025-10-12 18:39:03.332478-05	2025-10-12 18:40:03.365458-05	2025-10-12 18:41:01.332478-05	f	\N	2025-10-13 06:42:08.785191-05
a5da48ba-5794-4c3a-bd0a-45fedb073003	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:39:34.627232-05	2025-10-12 18:40:34.626225-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:37:34.627232-05	2025-10-12 18:40:34.634524-05	2025-10-12 18:47:34.627232-05	f	\N	2025-10-13 06:42:08.785191-05
27e6dc2b-4ac7-4a69-86ba-a9167a3a4826	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:42:01.400046-05	2025-10-12 18:42:03.411856-05	\N	2025-10-12 23:42:00	00:15:00	2025-10-12 18:41:03.400046-05	2025-10-12 18:42:03.421334-05	2025-10-12 18:43:01.400046-05	f	\N	2025-10-13 06:42:08.785191-05
1beed7aa-f962-4311-a3e6-855a8b04c763	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:41:01.364361-05	2025-10-12 18:41:03.388618-05	\N	2025-10-12 23:41:00	00:15:00	2025-10-12 18:40:03.364361-05	2025-10-12 18:41:03.401797-05	2025-10-12 18:42:01.364361-05	f	\N	2025-10-13 06:42:08.785191-05
08b121af-4759-4735-97c8-c3d2fae37c43	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:42:34.636577-05	2025-10-12 18:43:34.631315-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:40:34.636577-05	2025-10-12 18:43:34.63893-05	2025-10-12 18:50:34.636577-05	f	\N	2025-10-13 06:45:08.785026-05
93f52273-f94a-4c35-abbb-561869f87d68	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:43:01.420242-05	2025-10-12 18:43:03.446974-05	\N	2025-10-12 23:43:00	00:15:00	2025-10-12 18:42:03.420242-05	2025-10-12 18:43:03.455087-05	2025-10-12 18:44:01.420242-05	f	\N	2025-10-13 06:45:08.785026-05
da7a94e4-54c7-487f-9f86-2357c8decd41	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:44:01.45405-05	2025-10-12 18:44:03.479398-05	\N	2025-10-12 23:44:00	00:15:00	2025-10-12 18:43:03.45405-05	2025-10-12 18:44:03.491072-05	2025-10-12 18:45:01.45405-05	f	\N	2025-10-13 06:45:08.785026-05
4bb6091e-724d-4b15-a581-845749fbb5cc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:45:01.489864-05	2025-10-12 18:45:03.511754-05	\N	2025-10-12 23:45:00	00:15:00	2025-10-12 18:44:03.489864-05	2025-10-12 18:45:03.518362-05	2025-10-12 18:46:01.489864-05	f	\N	2025-10-13 06:45:08.785026-05
72c50a2e-73e0-4023-addc-fd875df4f8c3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:25:01.010269-05	2025-10-12 18:25:03.0164-05	\N	2025-10-12 23:25:00	00:15:00	2025-10-12 18:24:03.010269-05	2025-10-12 18:25:03.02422-05	2025-10-12 18:26:01.010269-05	f	\N	2025-10-13 06:27:08.77437-05
d0f87d9e-2777-4826-922a-7f248a7d6656	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:26:01.022842-05	2025-10-12 18:26:03.030173-05	\N	2025-10-12 23:26:00	00:15:00	2025-10-12 18:25:03.022842-05	2025-10-12 18:26:03.040547-05	2025-10-12 18:27:01.022842-05	f	\N	2025-10-13 06:27:08.77437-05
c2690201-4134-4dfc-925b-356c5bb76479	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:25:34.60873-05	2025-10-12 18:26:34.600585-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:23:34.60873-05	2025-10-12 18:26:34.60832-05	2025-10-12 18:33:34.60873-05	f	\N	2025-10-13 06:27:08.77437-05
5bc84fa3-4b84-4ced-95bb-a39365277101	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:27:01.039183-05	2025-10-12 18:27:03.044789-05	\N	2025-10-12 23:27:00	00:15:00	2025-10-12 18:26:03.039183-05	2025-10-12 18:27:03.056112-05	2025-10-12 18:28:01.039183-05	f	\N	2025-10-13 06:27:08.77437-05
d013304b-9528-410d-a282-086f3a353931	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:32:01.114436-05	2025-10-12 18:32:03.136427-05	\N	2025-10-12 23:32:00	00:15:00	2025-10-12 18:31:03.114436-05	2025-10-12 18:32:03.146171-05	2025-10-12 18:33:01.114436-05	f	\N	2025-10-13 06:33:08.778061-05
895e2da7-175f-4376-ad07-b709710acb9b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:31:34.610679-05	2025-10-12 18:32:34.608934-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:29:34.610679-05	2025-10-12 18:32:34.612956-05	2025-10-12 18:39:34.610679-05	f	\N	2025-10-13 06:33:08.778061-05
4d9e7b02-5eb9-46f1-b786-b53d1e3f6085	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:31:01.096329-05	2025-10-12 18:31:03.107454-05	\N	2025-10-12 23:31:00	00:15:00	2025-10-12 18:30:03.096329-05	2025-10-12 18:31:03.115915-05	2025-10-12 18:32:01.096329-05	f	\N	2025-10-13 06:33:08.778061-05
651bc031-0926-4972-b35a-2a8b2f6a7b5e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:33:01.144594-05	2025-10-12 18:33:03.160969-05	\N	2025-10-12 23:33:00	00:15:00	2025-10-12 18:32:03.144594-05	2025-10-12 18:33:03.169906-05	2025-10-12 18:34:01.144594-05	f	\N	2025-10-13 06:33:08.778061-05
beda8d5d-9b55-4ed3-868d-28a7f74fce30	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:34:01.168707-05	2025-10-12 18:34:03.187551-05	\N	2025-10-12 23:34:00	00:15:00	2025-10-12 18:33:03.168707-05	2025-10-12 18:34:03.198711-05	2025-10-12 18:35:01.168707-05	f	\N	2025-10-13 06:36:08.778904-05
d4b2266f-89ae-4297-8aa3-c04cd4e99b75	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:34:34.613936-05	2025-10-12 18:34:34.614169-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:32:34.613936-05	2025-10-12 18:34:34.620387-05	2025-10-12 18:42:34.613936-05	f	\N	2025-10-13 06:36:08.778904-05
cee03f3a-ee06-44f9-bd6b-e9946fee5d5a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:35:01.197451-05	2025-10-12 18:35:03.217322-05	\N	2025-10-12 23:35:00	00:15:00	2025-10-12 18:34:03.197451-05	2025-10-12 18:35:03.225041-05	2025-10-12 18:36:01.197451-05	f	\N	2025-10-13 06:36:08.778904-05
fbd2e151-9a3e-4440-b0f7-2bdc494151bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:36:01.224019-05	2025-10-12 18:36:03.244006-05	\N	2025-10-12 23:36:00	00:15:00	2025-10-12 18:35:03.224019-05	2025-10-12 18:36:03.252747-05	2025-10-12 18:37:01.224019-05	f	\N	2025-10-13 06:36:08.778904-05
bd2df6dd-9939-490d-93a4-0290c36ef4fd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:37:01.251296-05	2025-10-12 18:37:03.273916-05	\N	2025-10-12 23:37:00	00:15:00	2025-10-12 18:36:03.251296-05	2025-10-12 18:37:03.286583-05	2025-10-12 18:38:01.251296-05	f	\N	2025-10-13 06:39:08.780915-05
88af97e4-119a-4bf1-be28-b24f73a3252b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:39:01.31394-05	2025-10-12 18:39:03.324301-05	\N	2025-10-12 23:39:00	00:15:00	2025-10-12 18:38:03.31394-05	2025-10-12 18:39:03.333502-05	2025-10-12 18:40:01.31394-05	f	\N	2025-10-13 06:39:08.780915-05
42c3fab1-a6aa-4cd8-863e-9bb96158f56a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:36:34.621919-05	2025-10-12 18:37:34.620617-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:34:34.621919-05	2025-10-12 18:37:34.625925-05	2025-10-12 18:44:34.621919-05	f	\N	2025-10-13 06:39:08.780915-05
6268912e-d0c5-4298-b935-ae42c38ecf43	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:38:01.285112-05	2025-10-12 18:38:03.300787-05	\N	2025-10-12 23:38:00	00:15:00	2025-10-12 18:37:03.285112-05	2025-10-12 18:38:03.315673-05	2025-10-12 18:39:01.285112-05	f	\N	2025-10-13 06:39:08.780915-05
209082f9-e42e-4609-9b7e-af1908b718af	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-07 14:06:01.203669-05	\N	\N	2025-10-07 19:06:00	00:15:00	2025-10-07 14:05:45.203669-05	\N	2025-10-07 14:07:01.203669-05	f	\N	2025-10-07 23:25:44.64576-05
ba64fbaa-27e4-45b1-a1a9-9706cba9c21b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:45:34.640749-05	2025-10-12 18:46:34.63895-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:43:34.640749-05	2025-10-12 18:46:34.644471-05	2025-10-12 18:53:34.640749-05	f	\N	2025-10-13 06:48:08.788788-05
52e98f9b-b31e-4263-a8eb-d8443e95f0b3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:46:01.517358-05	2025-10-12 18:46:03.535509-05	\N	2025-10-12 23:46:00	00:15:00	2025-10-12 18:45:03.517358-05	2025-10-12 18:46:03.542675-05	2025-10-12 18:47:01.517358-05	f	\N	2025-10-13 06:48:08.788788-05
fc54ef20-91e2-4cf6-8e4a-9739a371185a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:47:01.541692-05	2025-10-12 18:47:03.568494-05	\N	2025-10-12 23:47:00	00:15:00	2025-10-12 18:46:03.541692-05	2025-10-12 18:47:03.582716-05	2025-10-12 18:48:01.541692-05	f	\N	2025-10-13 06:48:08.788788-05
4fe5f5ff-92b5-4b09-8374-b97565609eec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:48:01.580523-05	2025-10-12 18:48:03.601471-05	\N	2025-10-12 23:48:00	00:15:00	2025-10-12 18:47:03.580523-05	2025-10-12 18:48:03.609074-05	2025-10-12 18:49:01.580523-05	f	\N	2025-10-13 06:48:08.788788-05
2040bb5a-c792-4531-a2a9-a62258e7106f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:48:34.645884-05	2025-10-12 18:49:34.64594-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:46:34.645884-05	2025-10-12 18:49:34.651776-05	2025-10-12 18:56:34.645884-05	f	\N	2025-10-13 06:54:09.662438-05
8f3d6ccb-817b-486a-86a5-f5f9f0ecd698	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:50:01.642507-05	2025-10-12 18:50:03.645651-05	\N	2025-10-12 23:50:00	00:15:00	2025-10-12 18:49:03.642507-05	2025-10-12 18:50:03.655094-05	2025-10-12 18:51:01.642507-05	f	\N	2025-10-13 06:54:09.662438-05
356554a7-5c19-4ff7-bdaf-434f31864a2a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 18:51:34.653154-05	2025-10-12 18:52:34.627058-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 18:49:34.653154-05	2025-10-12 18:52:34.63138-05	2025-10-12 18:59:34.653154-05	f	\N	2025-10-13 06:54:09.662438-05
2c412ddf-f82a-4728-8189-abe05c1965e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:49:01.60817-05	2025-10-12 18:49:03.632048-05	\N	2025-10-12 23:49:00	00:15:00	2025-10-12 18:48:03.60817-05	2025-10-12 18:49:03.643957-05	2025-10-12 18:50:01.60817-05	f	\N	2025-10-13 06:54:09.662438-05
004b4005-ac5a-42ff-ab77-5c46b817915d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:51:01.653695-05	2025-10-12 18:51:03.671327-05	\N	2025-10-12 23:51:00	00:15:00	2025-10-12 18:50:03.653695-05	2025-10-12 18:51:03.684048-05	2025-10-12 18:52:01.653695-05	f	\N	2025-10-13 06:54:09.662438-05
9413e777-a2a2-413e-acc0-b7f62c119a8e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:52:01.682546-05	2025-10-12 18:52:03.697159-05	\N	2025-10-12 23:52:00	00:15:00	2025-10-12 18:51:03.682546-05	2025-10-12 18:52:03.708715-05	2025-10-12 18:53:01.682546-05	f	\N	2025-10-13 06:54:09.662438-05
4765e20e-a387-4b65-bb8a-46c8c7ee2f14	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:53:01.70715-05	2025-10-12 18:53:03.72702-05	\N	2025-10-12 23:53:00	00:15:00	2025-10-12 18:52:03.70715-05	2025-10-12 18:53:03.74088-05	2025-10-12 18:54:01.70715-05	f	\N	2025-10-13 06:54:09.662438-05
8f0bde28-5992-47c5-b46c-d554d64b2c68	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 18:54:01.739403-05	2025-10-12 18:54:03.751358-05	\N	2025-10-12 23:54:00	00:15:00	2025-10-12 18:53:03.739403-05	2025-10-12 18:54:03.765166-05	2025-10-12 18:55:01.739403-05	f	\N	2025-10-13 06:54:09.662438-05
ee514193-156c-4011-9c47-80b9ffb2cf09	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:38:01.757785-05	2025-10-07 23:38:03.767111-05	\N	2025-10-08 04:38:00	00:15:00	2025-10-07 23:37:03.757785-05	2025-10-07 23:38:03.783297-05	2025-10-07 23:39:01.757785-05	f	\N	2025-10-12 00:29:55.578677-05
91f3815a-c214-4a50-b0e1-dc7119510035	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:39:01.782216-05	2025-10-07 23:39:03.784284-05	\N	2025-10-08 04:39:00	00:15:00	2025-10-07 23:38:03.782216-05	2025-10-07 23:39:03.804148-05	2025-10-07 23:40:01.782216-05	f	\N	2025-10-12 00:29:55.578677-05
5d17bf2c-28c5-4c65-bf5b-0658f83e9c1a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:39:03.722459-05	2025-10-07 23:40:03.710378-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:37:03.722459-05	2025-10-07 23:40:03.714904-05	2025-10-07 23:47:03.722459-05	f	\N	2025-10-12 00:29:55.578677-05
58217ae8-8b6e-4de4-9215-bf399b4d9aab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 14:05:41.187652-05	2025-10-07 14:05:45.182549-05	\N	2025-10-07 19:05:00	00:15:00	2025-10-07 14:05:41.187652-05	2025-10-07 14:05:45.205405-05	2025-10-07 14:06:41.187652-05	f	\N	2025-10-12 00:29:55.578677-05
17b78f7e-f825-495b-bd7a-576bc3277c34	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:42:01.828664-05	2025-10-07 23:42:03.835202-05	\N	2025-10-08 04:42:00	00:15:00	2025-10-07 23:41:03.828664-05	2025-10-07 23:42:03.844045-05	2025-10-07 23:43:01.828664-05	f	\N	2025-10-12 00:29:55.578677-05
8dd04590-c319-4884-8d8e-3f7a62ff1150	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:25:44.661181-05	2025-10-07 23:25:48.649564-05	\N	2025-10-08 04:25:00	00:15:00	2025-10-07 23:25:44.661181-05	2025-10-07 23:25:48.666107-05	2025-10-07 23:26:44.661181-05	f	\N	2025-10-12 00:29:55.578677-05
73e7c19b-3db9-4580-97e0-2d714c01f843	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:42:03.716066-05	2025-10-07 23:43:03.714502-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:40:03.716066-05	2025-10-07 23:43:03.722748-05	2025-10-07 23:50:03.716066-05	f	\N	2025-10-12 00:29:55.578677-05
2433e7e0-f1b4-4ffc-8b70-98f2968936aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:26:01.664793-05	2025-10-07 23:26:04.653192-05	\N	2025-10-08 04:26:00	00:15:00	2025-10-07 23:25:48.664793-05	2025-10-07 23:26:04.660072-05	2025-10-07 23:27:01.664793-05	f	\N	2025-10-12 00:29:55.578677-05
95782281-122f-4c07-a197-bffb5f264e4e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:31:01.726824-05	2025-10-07 23:31:04.727171-05	\N	2025-10-08 04:31:00	00:15:00	2025-10-07 23:30:04.726824-05	2025-10-07 23:31:04.735951-05	2025-10-07 23:32:01.726824-05	f	\N	2025-10-12 00:29:55.578677-05
2467d2c8-d814-4634-a569-7f09236bf124	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:43:01.843065-05	2025-10-07 23:43:03.848796-05	\N	2025-10-08 04:43:00	00:15:00	2025-10-07 23:42:03.843065-05	2025-10-07 23:43:03.861176-05	2025-10-07 23:44:01.843065-05	f	\N	2025-10-12 00:29:55.578677-05
a60097fc-a020-48fb-a170-1db48162d9d9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:33:44.66608-05	2025-10-07 23:34:03.736999-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:31:44.66608-05	2025-10-07 23:34:03.745074-05	2025-10-07 23:41:44.66608-05	f	\N	2025-10-12 00:29:55.578677-05
9508b515-bea3-4ba6-8d52-4d3173cee9e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:45:01.878252-05	2025-10-07 23:45:03.879039-05	\N	2025-10-08 04:45:00	00:15:00	2025-10-07 23:44:03.878252-05	2025-10-07 23:45:03.891864-05	2025-10-07 23:46:01.878252-05	f	\N	2025-10-12 00:29:55.578677-05
241e549d-a53e-4e2f-8c80-8e04ce38dcd1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:34:03.727366-05	2025-10-07 23:34:07.704921-05	\N	2025-10-08 04:34:00	00:15:00	2025-10-07 23:34:03.727366-05	2025-10-07 23:34:07.718527-05	2025-10-07 23:35:03.727366-05	f	\N	2025-10-12 00:29:55.578677-05
498e8660-065f-46ad-b937-aec0de3ce7a3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:45:03.724704-05	2025-10-07 23:46:03.71758-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:43:03.724704-05	2025-10-07 23:46:03.721445-05	2025-10-07 23:53:03.724704-05	f	\N	2025-10-12 00:29:55.578677-05
dd1926fa-8329-4dcf-8689-a0e82431f624	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-07 23:48:01.916541-05	\N	\N	2025-10-08 04:48:00	00:15:00	2025-10-07 23:47:03.916541-05	\N	2025-10-07 23:49:01.916541-05	f	\N	2025-10-12 00:29:55.578677-05
6411ebd6-2616-47e9-b25c-6230da3d0378	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:47:01.895707-05	2025-10-07 23:47:03.911172-05	\N	2025-10-08 04:47:00	00:15:00	2025-10-07 23:46:03.895707-05	2025-10-07 23:47:03.917482-05	2025-10-07 23:48:01.895707-05	f	\N	2025-10-12 00:29:55.578677-05
a05e41dd-6089-432c-b122-3e66788b120c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:40:01.800955-05	2025-10-07 23:40:03.802594-05	\N	2025-10-08 04:40:00	00:15:00	2025-10-07 23:39:03.800955-05	2025-10-07 23:40:03.80953-05	2025-10-07 23:41:01.800955-05	f	\N	2025-10-12 00:29:55.578677-05
198962ab-c3d8-452d-8fb3-2aeef07fb673	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:41:01.808741-05	2025-10-07 23:41:03.81934-05	\N	2025-10-08 04:41:00	00:15:00	2025-10-07 23:40:03.808741-05	2025-10-07 23:41:03.829974-05	2025-10-07 23:42:01.808741-05	f	\N	2025-10-12 00:29:55.578677-05
87a7a7dd-e4c5-4893-90a2-b4e0bfbfe24e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 14:05:41.15758-05	2025-10-07 14:05:41.164341-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 14:05:41.15758-05	2025-10-07 14:05:41.18437-05	2025-10-07 14:13:41.15758-05	f	\N	2025-10-12 00:29:55.578677-05
e1167b66-707b-4c64-a199-cb3af5dda743	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:44:01.858802-05	2025-10-07 23:44:03.866114-05	\N	2025-10-08 04:44:00	00:15:00	2025-10-07 23:43:03.858802-05	2025-10-07 23:44:03.881062-05	2025-10-07 23:45:01.858802-05	f	\N	2025-10-12 00:29:55.578677-05
ee5c61b8-756c-47f5-890c-efdbcf00fa43	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:25:44.635511-05	2025-10-07 23:25:44.640675-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:25:44.635511-05	2025-10-07 23:25:44.656468-05	2025-10-07 23:33:44.635511-05	f	\N	2025-10-12 00:29:55.578677-05
7fd50041-050e-4577-aab8-95725eb0cbcd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:46:01.890113-05	2025-10-07 23:46:03.892439-05	\N	2025-10-08 04:46:00	00:15:00	2025-10-07 23:45:03.890113-05	2025-10-07 23:46:03.896347-05	2025-10-07 23:47:01.890113-05	f	\N	2025-10-12 00:29:55.578677-05
bcf2b6a0-34d0-4296-904d-261d3d361de8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:27:01.65937-05	2025-10-07 23:27:04.672486-05	\N	2025-10-08 04:27:00	00:15:00	2025-10-07 23:26:04.65937-05	2025-10-07 23:27:04.684256-05	2025-10-07 23:28:01.65937-05	f	\N	2025-10-12 00:29:55.578677-05
cf079dc7-2f69-4f4e-acb4-316f913e2815	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:28:01.682777-05	2025-10-07 23:28:04.703991-05	\N	2025-10-08 04:28:00	00:15:00	2025-10-07 23:27:04.682777-05	2025-10-07 23:28:04.725466-05	2025-10-07 23:29:01.682777-05	f	\N	2025-10-12 00:29:55.578677-05
32e87c3b-031d-4d18-87ff-b4ceb6ef28bc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:27:44.65878-05	2025-10-07 23:28:44.646556-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:25:44.65878-05	2025-10-07 23:28:44.662352-05	2025-10-07 23:35:44.65878-05	f	\N	2025-10-12 00:29:55.578677-05
138a9799-5498-4936-808d-7420d1c9475a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:29:01.723548-05	2025-10-07 23:29:04.706897-05	\N	2025-10-08 04:29:00	00:15:00	2025-10-07 23:28:04.723548-05	2025-10-07 23:29:04.720938-05	2025-10-07 23:30:01.723548-05	f	\N	2025-10-12 00:29:55.578677-05
144fe852-281d-48ff-80ca-3020eb4d5a26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:34:01.472828-05	2025-10-12 20:34:02.492661-05	\N	2025-10-13 01:34:00	00:15:00	2025-10-12 20:33:02.472828-05	2025-10-12 20:34:02.505462-05	2025-10-12 20:35:01.472828-05	f	\N	2025-10-13 12:42:16.717855-05
8c3624ff-f46b-485e-bd23-e846fdc0c95c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:26:01.062518-05	2025-10-12 23:26:03.084409-05	\N	2025-10-13 04:26:00	00:15:00	2025-10-12 23:25:03.062518-05	2025-10-12 23:26:03.093078-05	2025-10-12 23:27:01.062518-05	f	\N	2025-10-13 12:42:16.717855-05
8d2d4f94-7458-4ecf-879a-e04451d0be86	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:36:01.534006-05	2025-10-12 20:36:02.554745-05	\N	2025-10-13 01:36:00	00:15:00	2025-10-12 20:35:02.534006-05	2025-10-12 20:36:02.560536-05	2025-10-12 20:37:01.534006-05	f	\N	2025-10-13 12:42:16.717855-05
0f9953e3-afff-467e-a430-f737b17e6460	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:37:01.559811-05	2025-10-12 20:37:02.584697-05	\N	2025-10-13 01:37:00	00:15:00	2025-10-12 20:36:02.559811-05	2025-10-12 20:37:02.597223-05	2025-10-12 20:38:01.559811-05	f	\N	2025-10-13 12:42:16.717855-05
54bfc910-bf84-4a19-8bc5-5c4ff517b75d	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 21:00:03.200771-05	2025-10-12 21:00:07.197946-05	dailyStatsJob	2025-10-13 02:00:00	00:15:00	2025-10-12 21:00:03.200771-05	2025-10-12 21:00:07.201182-05	2025-10-26 21:00:03.200771-05	f	\N	2025-10-13 12:42:16.717855-05
42643bf1-2f3b-4de4-ab4a-023028cb1448	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 21:00:07.200299-05	2025-10-12 21:00:08.105701-05	\N	\N	00:15:00	2025-10-12 21:00:07.200299-05	2025-10-12 21:00:08.267243-05	2025-10-26 21:00:07.200299-05	f	\N	2025-10-13 12:42:16.717855-05
c01976a2-13be-43a8-a296-aa707e5b4b8c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:01:01.205355-05	2025-10-12 21:01:03.226905-05	\N	2025-10-13 02:01:00	00:15:00	2025-10-12 21:00:03.205355-05	2025-10-12 21:01:03.237502-05	2025-10-12 21:02:01.205355-05	f	\N	2025-10-13 12:42:16.717855-05
a122fbdd-d677-4ea1-b494-8f06b99433a9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:02:01.235674-05	2025-10-12 21:02:03.249434-05	\N	2025-10-13 02:02:00	00:15:00	2025-10-12 21:01:03.235674-05	2025-10-12 21:02:03.258365-05	2025-10-12 21:03:01.235674-05	f	\N	2025-10-13 12:42:16.717855-05
9ff711a1-dd86-4c41-814b-264237a4ef5c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:03:01.256837-05	2025-10-12 21:03:03.276702-05	\N	2025-10-13 02:03:00	00:15:00	2025-10-12 21:02:03.256837-05	2025-10-12 21:03:03.286561-05	2025-10-12 21:04:01.256837-05	f	\N	2025-10-13 12:42:16.717855-05
c7434f3b-be72-4195-8f72-92968597479a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:05:01.311332-05	2025-10-12 21:05:03.329684-05	\N	2025-10-13 02:05:00	00:15:00	2025-10-12 21:04:03.311332-05	2025-10-12 21:05:03.337047-05	2025-10-12 21:06:01.311332-05	f	\N	2025-10-13 12:42:16.717855-05
69e4a96d-c61b-40b0-aecb-2ee595ed5444	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:07:34.892872-05	2025-10-12 21:08:34.887774-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:05:34.892872-05	2025-10-12 21:08:34.894447-05	2025-10-12 21:15:34.892872-05	f	\N	2025-10-13 12:42:16.717855-05
cfb1dd74-83a8-478d-93ad-22f603bbddc5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:09:01.418479-05	2025-10-12 21:09:03.438714-05	\N	2025-10-13 02:09:00	00:15:00	2025-10-12 21:08:03.418479-05	2025-10-12 21:09:03.448914-05	2025-10-12 21:10:01.418479-05	f	\N	2025-10-13 12:42:16.717855-05
b6d4a0cc-6076-4f2d-8119-551f0fa8b6c5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:10:34.895872-05	2025-10-12 21:11:34.892407-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:08:34.895872-05	2025-10-12 21:11:34.898749-05	2025-10-12 21:18:34.895872-05	f	\N	2025-10-13 12:42:16.717855-05
4410c797-36db-4c08-8bd3-bd4dda26aa8f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:12:01.499138-05	2025-10-12 21:12:03.521389-05	\N	2025-10-13 02:12:00	00:15:00	2025-10-12 21:11:03.499138-05	2025-10-12 21:12:03.526106-05	2025-10-12 21:13:01.499138-05	f	\N	2025-10-13 12:42:16.717855-05
1ab0dcd2-10a5-4515-9414-494c0a8cdfe3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:15:01.583922-05	2025-10-12 21:15:03.606428-05	\N	2025-10-13 02:15:00	00:15:00	2025-10-12 21:14:03.583922-05	2025-10-12 21:15:03.617411-05	2025-10-12 21:16:01.583922-05	f	\N	2025-10-13 12:42:16.717855-05
fad0af53-f3c0-4819-a4c1-61d041731fec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:17:01.642279-05	2025-10-12 21:17:03.664907-05	\N	2025-10-13 02:17:00	00:15:00	2025-10-12 21:16:03.642279-05	2025-10-12 21:17:03.674367-05	2025-10-12 21:18:01.642279-05	f	\N	2025-10-13 12:42:16.717855-05
a0472cde-1541-4992-97e2-b9e2d86f0caa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 20:35:01.503779-05	2025-10-12 20:35:02.523337-05	\N	2025-10-13 01:35:00	00:15:00	2025-10-12 20:34:02.503779-05	2025-10-12 20:35:02.535701-05	2025-10-12 20:36:01.503779-05	f	\N	2025-10-13 12:42:16.717855-05
a741bff7-57ad-4902-84ec-748d7d4abcee	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:32:01.03902-05	2025-10-12 21:32:04.060399-05	\N	2025-10-13 02:32:00	00:15:00	2025-10-12 21:31:04.03902-05	2025-10-12 21:32:04.066911-05	2025-10-12 21:33:01.03902-05	f	\N	2025-10-13 12:42:16.717855-05
dc7a8bd7-692a-4666-9ed2-90782228b792	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 20:37:34.843643-05	2025-10-12 20:38:34.836303-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 20:35:34.843643-05	2025-10-12 20:38:34.844574-05	2025-10-12 20:45:34.843643-05	f	\N	2025-10-13 12:42:16.717855-05
6608dee5-7b2e-40e2-a555-d7aec809dfc3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:04:01.284894-05	2025-10-12 21:04:03.302089-05	\N	2025-10-13 02:04:00	00:15:00	2025-10-12 21:03:03.284894-05	2025-10-12 21:04:03.312896-05	2025-10-12 21:05:01.284894-05	f	\N	2025-10-13 12:42:16.717855-05
cc9442b1-b423-49cf-89c6-0956f41d8b61	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:04:34.880617-05	2025-10-12 21:05:34.882565-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:02:34.880617-05	2025-10-12 21:05:34.890606-05	2025-10-12 21:12:34.880617-05	f	\N	2025-10-13 12:42:16.717855-05
97913fbb-8981-40df-a4ae-2ed75bb73eac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:06:01.335569-05	2025-10-12 21:06:03.358778-05	\N	2025-10-13 02:06:00	00:15:00	2025-10-12 21:05:03.335569-05	2025-10-12 21:06:03.364321-05	2025-10-12 21:07:01.335569-05	f	\N	2025-10-13 12:42:16.717855-05
3c66fe5a-1df0-4149-bafa-ca514b44f92c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:07:01.3635-05	2025-10-12 21:07:03.385913-05	\N	2025-10-13 02:07:00	00:15:00	2025-10-12 21:06:03.3635-05	2025-10-12 21:07:03.393227-05	2025-10-12 21:08:01.3635-05	f	\N	2025-10-13 12:42:16.717855-05
bf6c2e24-e0ea-4cc5-8807-475a0e1eb738	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:08:01.392338-05	2025-10-12 21:08:03.411444-05	\N	2025-10-13 02:08:00	00:15:00	2025-10-12 21:07:03.392338-05	2025-10-12 21:08:03.420445-05	2025-10-12 21:09:01.392338-05	f	\N	2025-10-13 12:42:16.717855-05
a6ff3beb-3bf9-44ef-aa20-803384523d25	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:10:01.447153-05	2025-10-12 21:10:03.464358-05	\N	2025-10-13 02:10:00	00:15:00	2025-10-12 21:09:03.447153-05	2025-10-12 21:10:03.473178-05	2025-10-12 21:11:01.447153-05	f	\N	2025-10-13 12:42:16.717855-05
acfe484f-474a-41e1-bbcc-794563c9d046	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:11:01.471527-05	2025-10-12 21:11:03.494334-05	\N	2025-10-13 02:11:00	00:15:00	2025-10-12 21:10:03.471527-05	2025-10-12 21:11:03.500064-05	2025-10-12 21:12:01.471527-05	f	\N	2025-10-13 12:42:16.717855-05
2128b769-67c2-4969-83e2-17830858a20b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:13:01.525366-05	2025-10-12 21:13:03.547828-05	\N	2025-10-13 02:13:00	00:15:00	2025-10-12 21:12:03.525366-05	2025-10-12 21:13:03.55572-05	2025-10-12 21:14:01.525366-05	f	\N	2025-10-13 12:42:16.717855-05
c779890d-3018-4eae-a444-ea1cf6e1e41e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:14:01.554576-05	2025-10-12 21:14:03.577122-05	\N	2025-10-13 02:14:00	00:15:00	2025-10-12 21:13:03.554576-05	2025-10-12 21:14:03.585175-05	2025-10-12 21:15:01.554576-05	f	\N	2025-10-13 12:42:16.717855-05
20f7dc26-4577-4c7c-ba92-f7d1d8e89dc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:13:34.900096-05	2025-10-12 21:14:34.895529-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:11:34.900096-05	2025-10-12 21:14:34.902869-05	2025-10-12 21:21:34.900096-05	f	\N	2025-10-13 12:42:16.717855-05
4c87e341-50af-427b-bc2f-d3000a4e3d98	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:16:34.904849-05	2025-10-12 21:17:34.902511-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:14:34.904849-05	2025-10-12 21:17:34.910755-05	2025-10-12 21:24:34.904849-05	f	\N	2025-10-13 12:42:16.717855-05
fd6a1797-45d2-4366-a326-e991259519b8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:20:01.721225-05	2025-10-12 21:20:03.741252-05	\N	2025-10-13 02:20:00	00:15:00	2025-10-12 21:19:03.721225-05	2025-10-12 21:20:03.749056-05	2025-10-12 21:21:01.721225-05	f	\N	2025-10-13 12:42:16.717855-05
1381d4e3-311c-408d-9b50-dc5a5fbaf57a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:19:34.912801-05	2025-10-12 21:20:34.908034-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:17:34.912801-05	2025-10-12 21:20:34.914667-05	2025-10-12 21:27:34.912801-05	f	\N	2025-10-13 12:42:16.717855-05
1097ebb6-cbbe-4d1d-be5f-6e7b54c74c18	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:22:01.775768-05	2025-10-12 21:22:03.793237-05	\N	2025-10-13 02:22:00	00:15:00	2025-10-12 21:21:03.775768-05	2025-10-12 21:22:03.805738-05	2025-10-12 21:23:01.775768-05	f	\N	2025-10-13 12:42:16.717855-05
ec0fa07c-41a8-4a3a-bba4-1d1fc027ef3f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:24:01.827265-05	2025-10-12 21:24:03.848571-05	\N	2025-10-13 02:24:00	00:15:00	2025-10-12 21:23:03.827265-05	2025-10-12 21:24:03.859987-05	2025-10-12 21:25:01.827265-05	f	\N	2025-10-13 12:42:16.717855-05
beb59f67-c3f2-4031-b6ff-205fa91d307c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:25:01.858224-05	2025-10-12 21:25:03.877199-05	\N	2025-10-13 02:25:00	00:15:00	2025-10-12 21:24:03.858224-05	2025-10-12 21:25:03.885336-05	2025-10-12 21:26:01.858224-05	f	\N	2025-10-13 12:42:16.717855-05
c37e3061-01fd-4bda-86f3-c4092baefcb5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:25:34.924822-05	2025-10-12 21:26:34.913188-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:23:34.924822-05	2025-10-12 21:26:34.91964-05	2025-10-12 21:33:34.924822-05	f	\N	2025-10-13 12:42:16.717855-05
1d9140f8-c307-48ed-927d-9c269cf8ba8a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:27:01.913698-05	2025-10-12 21:27:03.921742-05	\N	2025-10-13 02:27:00	00:15:00	2025-10-12 21:26:03.913698-05	2025-10-12 21:27:03.931111-05	2025-10-12 21:28:01.913698-05	f	\N	2025-10-13 12:42:16.717855-05
807ebe2d-a29b-4b4b-a958-6491fe88b0ee	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:29:01.952448-05	2025-10-12 21:29:03.977378-05	\N	2025-10-13 02:29:00	00:15:00	2025-10-12 21:28:03.952448-05	2025-10-12 21:29:03.985567-05	2025-10-12 21:30:01.952448-05	f	\N	2025-10-13 12:42:16.717855-05
86202ac8-5357-4c85-bf54-ad4f7f62a4f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:31:01.014819-05	2025-10-12 21:31:04.029102-05	\N	2025-10-13 02:31:00	00:15:00	2025-10-12 21:30:04.014819-05	2025-10-12 21:31:04.040547-05	2025-10-12 21:32:01.014819-05	f	\N	2025-10-13 12:42:16.717855-05
cb3fb884-381c-45a3-b230-99ba01df4835	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:36:01.719438-05	2025-10-12 22:36:01.740116-05	\N	2025-10-13 03:36:00	00:15:00	2025-10-12 22:35:01.719438-05	2025-10-12 22:36:01.751473-05	2025-10-12 22:37:01.719438-05	f	\N	2025-10-13 12:42:16.717855-05
2c5ff6f1-bb32-4ee2-aab3-729141c2945b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:25:01.033782-05	2025-10-12 23:25:03.055674-05	\N	2025-10-13 04:25:00	00:15:00	2025-10-12 23:24:03.033782-05	2025-10-12 23:25:03.063913-05	2025-10-12 23:26:01.033782-05	f	\N	2025-10-13 12:42:16.717855-05
1ab88475-e601-4b56-aaea-a8656634f78d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:37:01.749965-05	2025-10-12 22:37:01.768689-05	\N	2025-10-13 03:37:00	00:15:00	2025-10-12 22:36:01.749965-05	2025-10-12 22:37:01.779414-05	2025-10-12 22:38:01.749965-05	f	\N	2025-10-13 12:42:16.717855-05
0ca7b05a-e99e-4a98-a9d6-5e9f945bfd49	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:33:01.065997-05	2025-10-12 21:33:04.087246-05	\N	2025-10-13 02:33:00	00:15:00	2025-10-12 21:32:04.065997-05	2025-10-12 21:33:04.09549-05	2025-10-12 21:34:01.065997-05	f	\N	2025-10-13 12:42:16.717855-05
c8f761ea-af5e-472e-aae3-cae238adabd7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:38:01.777936-05	2025-10-12 22:38:01.794004-05	\N	2025-10-13 03:38:00	00:15:00	2025-10-12 22:37:01.777936-05	2025-10-12 22:38:01.806705-05	2025-10-12 22:39:01.777936-05	f	\N	2025-10-13 12:42:16.717855-05
a402b6b3-1fae-43ed-8561-6ebf7a709d55	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:34:01.094125-05	2025-10-12 21:34:04.116154-05	\N	2025-10-13 02:34:00	00:15:00	2025-10-12 21:33:04.094125-05	2025-10-12 21:34:04.127037-05	2025-10-12 21:35:01.094125-05	f	\N	2025-10-13 12:42:16.717855-05
c85d383d-888b-4998-87fd-828cb2455ab3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:35:01.125378-05	2025-10-12 21:35:04.141314-05	\N	2025-10-13 02:35:00	00:15:00	2025-10-12 21:34:04.125378-05	2025-10-12 21:35:04.151724-05	2025-10-12 21:36:01.125378-05	f	\N	2025-10-13 12:42:16.717855-05
b9d44f14-0425-4b30-a3cb-de4476a33489	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:39:01.805035-05	2025-10-12 22:39:01.822334-05	\N	2025-10-13 03:39:00	00:15:00	2025-10-12 22:38:01.805035-05	2025-10-12 22:39:01.831418-05	2025-10-12 22:40:01.805035-05	f	\N	2025-10-13 12:42:16.717855-05
9f6e5c1d-6426-444d-900f-992f0f28d071	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 21:34:34.93201-05	2025-10-12 21:35:34.930379-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 21:32:34.93201-05	2025-10-12 21:35:34.936397-05	2025-10-12 21:42:34.93201-05	f	\N	2025-10-13 12:42:16.717855-05
1b547475-6355-49df-baae-e0fcc880e1cd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:36:01.15028-05	2025-10-12 21:36:04.166797-05	\N	2025-10-13 02:36:00	00:15:00	2025-10-12 21:35:04.15028-05	2025-10-12 21:36:04.176351-05	2025-10-12 21:37:01.15028-05	f	\N	2025-10-13 12:42:16.717855-05
95ec445f-0517-48d1-9c5f-8b60c9cf78c2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:37:01.175152-05	2025-10-12 21:37:04.192485-05	\N	2025-10-13 02:37:00	00:15:00	2025-10-12 21:36:04.175152-05	2025-10-12 21:37:04.203354-05	2025-10-12 21:38:01.175152-05	f	\N	2025-10-13 12:42:16.717855-05
bb047e1a-04c6-43fe-91f1-d6c1d0ab0b6a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:48:01.069755-05	2025-10-12 22:48:02.08456-05	\N	2025-10-13 03:48:00	00:15:00	2025-10-12 22:47:02.069755-05	2025-10-12 22:48:02.099093-05	2025-10-12 22:49:01.069755-05	f	\N	2025-10-13 12:42:16.717855-05
6d098281-5c28-4437-ad90-b3edac7f3a8b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:38:01.201688-05	2025-10-12 21:38:04.219639-05	\N	2025-10-13 02:38:00	00:15:00	2025-10-12 21:37:04.201688-05	2025-10-12 21:38:04.227818-05	2025-10-12 21:39:01.201688-05	f	\N	2025-10-13 12:42:16.717855-05
a2c164f3-90cf-4420-b060-711b2e2bb027	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:47:35.010832-05	2025-10-12 22:48:35.00284-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:45:35.010832-05	2025-10-12 22:48:35.012461-05	2025-10-12 22:55:35.010832-05	f	\N	2025-10-13 12:42:16.717855-05
59bbb6c0-e20c-4c1c-b08c-fb17ba0b3b7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:39:01.226626-05	2025-10-12 21:39:04.248248-05	\N	2025-10-13 02:39:00	00:15:00	2025-10-12 21:38:04.226626-05	2025-10-12 21:39:04.258003-05	2025-10-12 21:40:01.226626-05	f	\N	2025-10-13 12:42:16.717855-05
dcb2fa93-554e-488e-b9f1-9b4d138b4910	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:40:01.256866-05	2025-10-12 21:40:04.269309-05	\N	2025-10-13 02:40:00	00:15:00	2025-10-12 21:39:04.256866-05	2025-10-12 21:40:04.283086-05	2025-10-12 21:41:01.256866-05	f	\N	2025-10-13 12:42:16.717855-05
abe54d9e-f205-4e68-b531-8b2ea3626308	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:50:35.01408-05	2025-10-12 22:51:35.009297-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:48:35.01408-05	2025-10-12 22:51:35.015218-05	2025-10-12 22:58:35.01408-05	f	\N	2025-10-13 12:42:16.717855-05
35a2c9ae-27d4-4eeb-b965-2dcd39c1d4d3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:30:01.719673-05	2025-10-07 23:30:04.719534-05	\N	2025-10-08 04:30:00	00:15:00	2025-10-07 23:29:04.719673-05	2025-10-07 23:30:04.727729-05	2025-10-07 23:31:01.719673-05	f	\N	2025-10-12 00:29:55.578677-05
eca5f835-dc73-49c0-9f24-229a0da87056	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:30:44.665664-05	2025-10-07 23:31:44.649838-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:28:44.665664-05	2025-10-07 23:31:44.663429-05	2025-10-07 23:38:44.665664-05	f	\N	2025-10-12 00:29:55.578677-05
5990a211-0441-4b79-bea3-59bc455430e2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:32:01.735004-05	2025-10-07 23:32:04.747733-05	\N	2025-10-08 04:32:00	00:15:00	2025-10-07 23:31:04.735004-05	2025-10-07 23:32:04.76147-05	2025-10-07 23:33:01.735004-05	f	\N	2025-10-12 00:29:55.578677-05
b3ec2259-041a-455d-87a5-f0aa3ac06e1c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:33:01.760071-05	2025-10-07 23:34:03.7096-05	\N	2025-10-08 04:33:00	00:15:00	2025-10-07 23:32:04.760071-05	2025-10-07 23:34:03.730828-05	2025-10-07 23:34:01.760071-05	f	\N	2025-10-12 00:29:55.578677-05
4ad0fcfa-5e68-4671-b1aa-bce35ac9496c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:35:01.717708-05	2025-10-07 23:35:03.717361-05	\N	2025-10-08 04:35:00	00:15:00	2025-10-07 23:34:07.717708-05	2025-10-07 23:35:03.728725-05	2025-10-07 23:36:01.717708-05	f	\N	2025-10-12 00:29:55.578677-05
33e2f6cc-e6af-4376-b8f0-198330777bbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:36:01.727384-05	2025-10-07 23:36:03.732215-05	\N	2025-10-08 04:36:00	00:15:00	2025-10-07 23:35:03.727384-05	2025-10-07 23:36:03.742827-05	2025-10-07 23:37:01.727384-05	f	\N	2025-10-12 00:29:55.578677-05
58a4a752-f74c-4fef-aa7f-3182b2a686d8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-07 23:36:03.746299-05	2025-10-07 23:37:03.706548-05	__pgboss__maintenance	\N	00:15:00	2025-10-07 23:34:03.746299-05	2025-10-07 23:37:03.719437-05	2025-10-07 23:44:03.746299-05	f	\N	2025-10-12 00:29:55.578677-05
c27c0ad5-2bfd-40b0-a1cf-3326cdf639ff	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-07 23:37:01.74159-05	2025-10-07 23:37:03.747963-05	\N	2025-10-08 04:37:00	00:15:00	2025-10-07 23:36:03.74159-05	2025-10-07 23:37:03.759089-05	2025-10-07 23:38:01.74159-05	f	\N	2025-10-12 00:29:55.578677-05
0a143171-c144-4b7a-8c1e-827ef2e31bcd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:43:01.344085-05	2025-10-12 21:43:04.358684-05	\N	2025-10-13 02:43:00	00:15:00	2025-10-12 21:42:04.344085-05	2025-10-12 21:43:04.367659-05	2025-10-12 21:44:01.344085-05	f	\N	2025-10-13 12:42:16.717855-05
3c5829cc-f74a-40e3-80c7-8413bb0b9e27	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:52:01.175962-05	2025-10-12 22:52:02.19253-05	\N	2025-10-13 03:52:00	00:15:00	2025-10-12 22:51:02.175962-05	2025-10-12 22:52:02.198924-05	2025-10-12 22:53:01.175962-05	f	\N	2025-10-13 12:42:16.717855-05
92f4b67d-0cc5-42d8-bef6-63e821355dfc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:44:01.366464-05	2025-10-12 21:44:04.385077-05	\N	2025-10-13 02:44:00	00:15:00	2025-10-12 21:43:04.366464-05	2025-10-12 21:44:04.391099-05	2025-10-12 21:45:01.366464-05	f	\N	2025-10-13 12:42:16.717855-05
a16b462f-0928-4583-9ca6-d676d814eb96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:54:01.231053-05	2025-10-12 22:54:02.251552-05	\N	2025-10-13 03:54:00	00:15:00	2025-10-12 22:53:02.231053-05	2025-10-12 22:54:02.262123-05	2025-10-12 22:55:01.231053-05	f	\N	2025-10-13 12:42:16.717855-05
21db6049-fd62-460c-8476-0fc1835209f8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:45:01.390408-05	2025-10-12 21:45:04.415914-05	\N	2025-10-13 02:45:00	00:15:00	2025-10-12 21:44:04.390408-05	2025-10-12 21:45:04.427091-05	2025-10-12 21:46:01.390408-05	f	\N	2025-10-13 12:42:16.717855-05
d41a6c35-052c-4867-b7ed-aab4ceca307f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 22:56:01.292958-05	2025-10-12 22:56:02.303477-05	\N	2025-10-13 03:56:00	00:15:00	2025-10-12 22:55:02.292958-05	2025-10-12 22:56:02.312009-05	2025-10-12 22:57:01.292958-05	f	\N	2025-10-13 12:42:16.717855-05
5d7ab286-b297-4e57-bbe0-e434a596fe79	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:56:35.023452-05	2025-10-12 22:57:35.018498-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:54:35.023452-05	2025-10-12 22:57:35.025815-05	2025-10-12 23:04:35.023452-05	f	\N	2025-10-13 12:42:16.717855-05
171ad88b-ee6c-4cb8-afea-72ab7a22ac7e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 21:48:01.478112-05	2025-10-12 21:48:04.498036-05	\N	2025-10-13 02:48:00	00:15:00	2025-10-12 21:47:04.478112-05	2025-10-12 21:48:04.507063-05	2025-10-12 21:49:01.478112-05	f	\N	2025-10-13 12:42:16.717855-05
a3152679-9c55-4044-b112-06edf597afc1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:00:01.393149-05	2025-10-12 23:00:02.410095-05	\N	2025-10-13 04:00:00	00:15:00	2025-10-12 22:59:02.393149-05	2025-10-12 23:00:02.420474-05	2025-10-12 23:01:01.393149-05	f	\N	2025-10-13 12:42:16.717855-05
951770b5-0684-40b8-9015-fdc2332f12c5	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-12T22:54:34.564Z"}	completed	0	0	0	f	2025-10-12 23:00:02.414583-05	2025-10-12 23:00:06.411623-05	dailyStatsJob	2025-10-13 04:00:00	00:15:00	2025-10-12 23:00:02.414583-05	2025-10-12 23:00:06.413648-05	2025-10-26 23:00:02.414583-05	f	\N	2025-10-13 12:42:16.717855-05
a993d734-0d97-4dec-8308-9068b1bb3d0d	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-12 23:00:06.41295-05	2025-10-12 23:00:06.71179-05	\N	\N	00:15:00	2025-10-12 23:00:06.41295-05	2025-10-12 23:00:06.86886-05	2025-10-26 23:00:06.41295-05	f	\N	2025-10-13 12:42:16.717855-05
3a6bc40c-e4a2-4efc-968e-871d0d32976c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 22:59:35.027334-05	2025-10-12 23:00:35.022629-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 22:57:35.027334-05	2025-10-12 23:00:35.030228-05	2025-10-12 23:07:35.027334-05	f	\N	2025-10-13 12:42:16.717855-05
1b428c21-614a-4c7b-a0f0-44d34e5fdf5c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:01:01.418829-05	2025-10-12 23:01:02.43866-05	\N	2025-10-13 04:01:00	00:15:00	2025-10-12 23:00:02.418829-05	2025-10-12 23:01:02.448721-05	2025-10-12 23:02:01.418829-05	f	\N	2025-10-13 12:42:16.717855-05
a7800e35-b1d9-458f-95d6-f287e6115c60	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:02:35.03193-05	2025-10-12 23:03:35.027859-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:00:35.03193-05	2025-10-12 23:03:35.031924-05	2025-10-12 23:10:35.03193-05	f	\N	2025-10-13 12:42:16.717855-05
359fe81e-bc07-416b-a70b-31b90dd78ec3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:04:01.486855-05	2025-10-12 23:04:02.510974-05	\N	2025-10-13 04:04:00	00:15:00	2025-10-12 23:03:02.486855-05	2025-10-12 23:04:02.518915-05	2025-10-12 23:05:01.486855-05	f	\N	2025-10-13 12:42:16.717855-05
82fa7050-1135-47b9-ba71-d70687d1b727	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:07:01.576407-05	2025-10-12 23:07:02.597087-05	\N	2025-10-13 04:07:00	00:15:00	2025-10-12 23:06:02.576407-05	2025-10-12 23:07:02.604027-05	2025-10-12 23:08:01.576407-05	f	\N	2025-10-13 12:42:16.717855-05
9105b039-e611-4281-a3d3-da5310a9d9ba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:08:01.603057-05	2025-10-12 23:08:02.622084-05	\N	2025-10-13 04:08:00	00:15:00	2025-10-12 23:07:02.603057-05	2025-10-12 23:08:02.63281-05	2025-10-12 23:09:01.603057-05	f	\N	2025-10-13 12:42:16.717855-05
29055154-2da2-48ff-a2bf-043bffd67533	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:09:01.630946-05	2025-10-12 23:09:02.633765-05	\N	2025-10-13 04:09:00	00:15:00	2025-10-12 23:08:02.630946-05	2025-10-12 23:09:02.64146-05	2025-10-12 23:10:01.630946-05	f	\N	2025-10-13 12:42:16.717855-05
470956c4-5d89-43c6-b46d-07da1c618440	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-12 23:08:35.042377-05	2025-10-12 23:09:35.022821-05	__pgboss__maintenance	\N	00:15:00	2025-10-12 23:06:35.042377-05	2025-10-12 23:09:35.029259-05	2025-10-12 23:16:35.042377-05	f	\N	2025-10-13 12:42:16.717855-05
f5de5131-d936-4d60-bec4-adf3333fb5ef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:12:01.691749-05	2025-10-12 23:12:02.705127-05	\N	2025-10-13 04:12:00	00:15:00	2025-10-12 23:11:02.691749-05	2025-10-12 23:12:02.712773-05	2025-10-12 23:13:01.691749-05	f	\N	2025-10-13 12:42:16.717855-05
f14ba9d4-a887-4159-8309-7a00f05ee7ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:13:01.711501-05	2025-10-12 23:13:02.732342-05	\N	2025-10-13 04:13:00	00:15:00	2025-10-12 23:12:02.711501-05	2025-10-12 23:13:02.740242-05	2025-10-12 23:14:01.711501-05	f	\N	2025-10-13 12:42:16.717855-05
ed63aa0b-91e6-44a5-86e7-43b129da31c8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:15:01.760522-05	2025-10-12 23:15:02.780356-05	\N	2025-10-13 04:15:00	00:15:00	2025-10-12 23:14:02.760522-05	2025-10-12 23:15:02.790988-05	2025-10-12 23:16:01.760522-05	f	\N	2025-10-13 12:42:16.717855-05
a23a191e-1165-4e9b-83e0-d4934d308545	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:17:01.814685-05	2025-10-12 23:17:02.83613-05	\N	2025-10-13 04:17:00	00:15:00	2025-10-12 23:16:02.814685-05	2025-10-12 23:17:02.843408-05	2025-10-12 23:18:01.814685-05	f	\N	2025-10-13 12:42:16.717855-05
eff1db6a-69d4-428a-9f39-cb6d872d29c4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:18:01.842153-05	2025-10-12 23:18:02.863968-05	\N	2025-10-13 04:18:00	00:15:00	2025-10-12 23:17:02.842153-05	2025-10-12 23:18:02.875509-05	2025-10-12 23:19:01.842153-05	f	\N	2025-10-13 12:42:16.717855-05
45897140-aaf2-4f34-ba8b-87302cc3d39b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-12 23:22:01.957784-05	2025-10-12 23:22:02.97475-05	\N	2025-10-13 04:22:00	00:15:00	2025-10-12 23:21:02.957784-05	2025-10-12 23:22:02.985584-05	2025-10-12 23:23:01.957784-05	f	\N	2025-10-13 12:42:16.717855-05
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output) FROM stdin;
1f302c70-676b-45bf-8937-6d1d56352a0d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:16:01.971925-05	2025-10-13 17:16:04.973927-05	\N	2025-10-13 22:16:00	00:15:00	2025-10-13 17:15:04.971925-05	2025-10-13 17:16:04.98658-05	2025-10-13 17:17:01.971925-05	f	\N
e96703dd-1b00-43cf-ac57-dc0fd15f1f24	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:23:01.462939-05	2025-10-13 15:23:04.465889-05	\N	2025-10-13 20:23:00	00:15:00	2025-10-13 15:22:04.462939-05	2025-10-13 15:23:04.47812-05	2025-10-13 15:24:01.462939-05	f	\N
f37e74a6-d3fa-473b-ab0f-5c47bb8e9909	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:50:01.383009-05	2025-10-13 14:55:58.371627-05	\N	2025-10-13 19:50:00	00:15:00	2025-10-13 14:49:17.383009-05	2025-10-13 14:55:58.380735-05	2025-10-13 14:51:01.383009-05	f	\N
5b5452d3-c302-43a6-bcaf-d9d91e9e63ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:44:01.751937-05	2025-10-13 12:44:04.754534-05	\N	2025-10-13 17:44:00	00:15:00	2025-10-13 12:43:04.751937-05	2025-10-13 12:44:04.769474-05	2025-10-13 12:45:01.751937-05	f	\N
883f6908-c49e-49c3-81c9-e341e06b13c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:43:01.694086-05	2025-10-13 16:46:53.311504-05	\N	2025-10-13 21:43:00	00:15:00	2025-10-13 16:42:05.694086-05	2025-10-13 16:46:53.447458-05	2025-10-13 16:44:01.694086-05	f	\N
8f6d70a9-78af-445a-87d2-5e4a5baef6a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:33:28.014704-05	2025-10-13 18:33:31.961127-05	\N	2025-10-13 23:33:00	00:15:00	2025-10-13 18:33:28.014704-05	2025-10-13 18:33:31.973326-05	2025-10-13 18:34:28.014704-05	f	\N
b1660f46-c3b4-4ed7-a812-7a575e0cfccb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:45:01.768382-05	2025-10-13 12:45:04.770213-05	\N	2025-10-13 17:45:00	00:15:00	2025-10-13 12:44:04.768382-05	2025-10-13 12:45:04.790152-05	2025-10-13 12:46:01.768382-05	f	\N
d43932d5-0965-40a0-8646-5eb6952ddd0e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:50:01.559778-05	2025-10-13 17:50:01.573441-05	\N	2025-10-13 22:50:00	00:15:00	2025-10-13 17:49:01.559778-05	2025-10-13 17:50:01.583156-05	2025-10-13 17:51:01.559778-05	f	\N
89a363bc-f3fd-4e00-a003-5b94ceb3e042	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:55:58.379217-05	2025-10-13 14:56:02.369779-05	\N	2025-10-13 19:55:00	00:15:00	2025-10-13 14:55:58.379217-05	2025-10-13 14:56:02.384339-05	2025-10-13 14:56:58.379217-05	f	\N
34100f6a-b553-4a49-a716-de702d382701	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:19:01.010597-05	2025-10-13 17:19:05.010395-05	\N	2025-10-13 22:19:00	00:15:00	2025-10-13 17:18:05.010597-05	2025-10-13 17:19:05.024638-05	2025-10-13 17:20:01.010597-05	f	\N
015f5edc-a6bd-40e5-bb40-588be78abcad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:47:01.801572-05	2025-10-13 12:47:04.792328-05	\N	2025-10-13 17:47:00	00:15:00	2025-10-13 12:46:04.801572-05	2025-10-13 12:47:04.805152-05	2025-10-13 12:48:01.801572-05	f	\N
d9b0675d-2362-4f40-a3bd-3fd8790a68da	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:19:52.83499-05	2025-10-13 17:20:52.819221-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:17:52.83499-05	2025-10-13 17:20:52.827588-05	2025-10-13 17:27:52.83499-05	f	\N
f5ee81a4-bf97-4b24-a94f-b5e3940f03b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:51:01.581972-05	2025-10-13 17:51:01.597935-05	\N	2025-10-13 22:51:00	00:15:00	2025-10-13 17:50:01.581972-05	2025-10-13 17:51:01.614867-05	2025-10-13 17:52:01.581972-05	f	\N
be1f2503-6761-430a-a86d-3efb3bd57520	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:21:01.029382-05	2025-10-13 17:21:01.036541-05	\N	2025-10-13 22:21:00	00:15:00	2025-10-13 17:20:05.029382-05	2025-10-13 17:21:01.045971-05	2025-10-13 17:22:01.029382-05	f	\N
5b1bec5f-f180-4352-ab55-7d566ad79bf4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:20:23.470979-05	2025-10-13 13:20:27.45738-05	\N	2025-10-13 18:20:00	00:15:00	2025-10-13 13:20:23.470979-05	2025-10-13 13:20:27.470509-05	2025-10-13 13:21:23.470979-05	f	\N
bacd8345-56e4-4d61-8ed0-19b879281591	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:52:01.611501-05	2025-10-13 17:52:01.62355-05	\N	2025-10-13 22:52:00	00:15:00	2025-10-13 17:51:01.611501-05	2025-10-13 17:52:01.645196-05	2025-10-13 17:53:01.611501-05	f	\N
9c27be57-06e2-4a5a-9183-0daf667d0c41	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:25:01.089776-05	2025-10-13 17:25:01.10058-05	\N	2025-10-13 22:25:00	00:15:00	2025-10-13 17:24:01.089776-05	2025-10-13 17:25:01.114898-05	2025-10-13 17:26:01.089776-05	f	\N
7bc09373-b0ce-4b74-9d6b-300564abfac5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:51:52.873931-05	2025-10-13 17:52:52.865154-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:49:52.873931-05	2025-10-13 17:52:52.878398-05	2025-10-13 17:59:52.873931-05	f	\N
947de892-bf2f-4dbc-bfb4-1fa246982810	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:54:01.668247-05	2025-10-13 17:54:01.680417-05	\N	2025-10-13 22:54:00	00:15:00	2025-10-13 17:53:01.668247-05	2025-10-13 17:54:01.696961-05	2025-10-13 17:55:01.668247-05	f	\N
2de19a8c-2b1e-4b1e-b8d5-f7a1ab47a931	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:24:01.47648-05	2025-10-13 15:24:04.480337-05	\N	2025-10-13 20:24:00	00:15:00	2025-10-13 15:23:04.47648-05	2025-10-13 15:24:04.48871-05	2025-10-13 15:25:01.47648-05	f	\N
3331e1d2-03e7-4d4f-8ffa-2a6e1f3af4f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:33:01.259168-05	2025-10-13 13:33:04.266757-05	\N	2025-10-13 18:33:00	00:15:00	2025-10-13 13:32:04.259168-05	2025-10-13 13:33:04.279304-05	2025-10-13 13:34:01.259168-05	f	\N
2300cc6a-f891-40b3-ac22-7249d09efc1d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:46:01.788149-05	2025-10-13 12:46:04.782728-05	\N	2025-10-13 17:46:00	00:15:00	2025-10-13 12:45:04.788149-05	2025-10-13 12:46:04.803256-05	2025-10-13 12:47:01.788149-05	f	\N
0869fe6c-842e-44c4-9b2a-feb16805bca5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:56:02.382707-05	2025-10-13 14:56:06.367131-05	\N	2025-10-13 19:56:00	00:15:00	2025-10-13 14:56:02.382707-05	2025-10-13 14:56:06.376762-05	2025-10-13 14:57:02.382707-05	f	\N
7b6183d8-202a-439a-8fe3-d5c2ae9b9ef4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:46:53.319269-05	2025-10-13 16:46:57.279416-05	\N	2025-10-13 21:46:00	00:15:00	2025-10-13 16:46:53.319269-05	2025-10-13 16:46:57.292564-05	2025-10-13 16:47:53.319269-05	f	\N
8cda7ac6-8c1e-410e-8f1f-80bd6ba9cf5a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:17:01.984757-05	2025-10-13 17:17:04.991859-05	\N	2025-10-13 22:17:00	00:15:00	2025-10-13 17:16:04.984757-05	2025-10-13 17:17:04.999537-05	2025-10-13 17:18:01.984757-05	f	\N
572ac68d-474c-4b6c-829d-940a89b55c9c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:34:01.277892-05	2025-10-13 13:49:37.152312-05	\N	2025-10-13 18:34:00	00:15:00	2025-10-13 13:33:04.277892-05	2025-10-13 13:49:37.167915-05	2025-10-13 13:35:01.277892-05	f	\N
843c30cb-4fa1-467a-a2ad-4441fa01d2bb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:48:01.804033-05	2025-10-13 12:48:04.805228-05	\N	2025-10-13 17:48:00	00:15:00	2025-10-13 12:47:04.804033-05	2025-10-13 12:48:04.820436-05	2025-10-13 12:49:01.804033-05	f	\N
929e35c2-0159-47f8-89f4-22e991f40bb1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 14:55:58.387167-05	2025-10-13 14:58:52.489907-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:55:58.387167-05	2025-10-13 14:58:52.544366-05	2025-10-13 15:03:58.387167-05	f	\N
cd74f89f-432a-4c93-8e32-407ed553bb5f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:53:01.641357-05	2025-10-13 17:53:01.653422-05	\N	2025-10-13 22:53:00	00:15:00	2025-10-13 17:52:01.641357-05	2025-10-13 17:53:01.670007-05	2025-10-13 17:54:01.641357-05	f	\N
c6669df7-0e64-4a99-9552-d0e45b06569a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:18:01.997918-05	2025-10-13 17:18:05.001971-05	\N	2025-10-13 22:18:00	00:15:00	2025-10-13 17:17:04.997918-05	2025-10-13 17:18:05.01167-05	2025-10-13 17:19:01.997918-05	f	\N
242fb498-b03e-4411-a1c9-96b730ab3867	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:41:57.700564-05	2025-10-13 18:42:01.690432-05	\N	2025-10-13 23:41:00	00:15:00	2025-10-13 18:41:57.700564-05	2025-10-13 18:42:01.701856-05	2025-10-13 18:42:57.700564-05	f	\N
5d632b74-f2bc-49f7-ad37-742b66cdd09c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:47:16.729987-05	2025-10-13 12:48:16.71449-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:45:16.729987-05	2025-10-13 12:48:16.726064-05	2025-10-13 12:55:16.729987-05	f	\N
46279717-2350-4db2-975d-ec8e870d92dc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:20:01.022211-05	2025-10-13 17:20:05.020791-05	\N	2025-10-13 22:20:00	00:15:00	2025-10-13 17:19:05.022211-05	2025-10-13 17:20:05.030942-05	2025-10-13 17:21:01.022211-05	f	\N
3b5beec3-9212-40e5-94cd-126a22b26cd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:55:01.695603-05	2025-10-13 17:55:01.708124-05	\N	2025-10-13 22:55:00	00:15:00	2025-10-13 17:54:01.695603-05	2025-10-13 17:55:01.721237-05	2025-10-13 17:56:01.695603-05	f	\N
f8aab89f-d317-4f71-a659-a6a6a57bf147	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:42:01.687981-05	2025-10-13 14:49:13.379216-05	\N	2025-10-13 19:42:00	00:15:00	2025-10-13 14:41:15.687981-05	2025-10-13 14:49:13.397245-05	2025-10-13 14:43:01.687981-05	f	\N
ea82e326-27ee-41ea-8a53-2296d063053b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:21:01.481191-05	2025-10-13 13:30:36.224723-05	\N	2025-10-13 18:21:00	00:15:00	2025-10-13 13:20:23.481191-05	2025-10-13 13:30:36.254081-05	2025-10-13 13:22:01.481191-05	f	\N
35277574-17eb-495e-96ce-d7672188b575	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:54:52.88191-05	2025-10-13 17:55:52.869878-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:52:52.88191-05	2025-10-13 17:55:52.877451-05	2025-10-13 18:02:52.88191-05	f	\N
4e913f9c-5430-4b09-96f5-295ef1405826	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:22:01.044484-05	2025-10-13 17:22:01.047764-05	\N	2025-10-13 22:22:00	00:15:00	2025-10-13 17:21:01.044484-05	2025-10-13 17:22:01.060487-05	2025-10-13 17:23:01.044484-05	f	\N
450922e4-1100-41a5-b227-3ac77f15af5d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:23:01.058411-05	2025-10-13 17:23:01.067936-05	\N	2025-10-13 22:23:00	00:15:00	2025-10-13 17:22:01.058411-05	2025-10-13 17:23:01.077813-05	2025-10-13 17:24:01.058411-05	f	\N
95ed69a0-81bd-4e93-b24e-4658910d045e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:22:52.828898-05	2025-10-13 17:23:52.820006-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:20:52.828898-05	2025-10-13 17:23:52.830748-05	2025-10-13 17:30:52.828898-05	f	\N
f100e024-ddb1-4e7b-849e-6534bd5654a6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:56:01.71994-05	2025-10-13 17:56:01.736345-05	\N	2025-10-13 22:56:00	00:15:00	2025-10-13 17:55:01.71994-05	2025-10-13 17:56:01.74498-05	2025-10-13 17:57:01.71994-05	f	\N
a0616da1-2026-4235-81d9-51cf364faa27	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:24:01.075184-05	2025-10-13 17:24:01.081607-05	\N	2025-10-13 22:24:00	00:15:00	2025-10-13 17:23:01.075184-05	2025-10-13 17:24:01.091004-05	2025-10-13 17:25:01.075184-05	f	\N
cb287cb2-f2d0-4d4c-a256-1a408f5b3f97	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:57:01.743939-05	2025-10-13 17:57:01.759857-05	\N	2025-10-13 22:57:00	00:15:00	2025-10-13 17:56:01.743939-05	2025-10-13 17:57:01.778459-05	2025-10-13 17:58:01.743939-05	f	\N
b535e82e-e34d-4907-9c9c-8ad28e2392b3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:26:01.113191-05	2025-10-13 17:26:01.125098-05	\N	2025-10-13 22:26:00	00:15:00	2025-10-13 17:25:01.113191-05	2025-10-13 17:26:01.136524-05	2025-10-13 17:27:01.113191-05	f	\N
5c0dbde4-fdfc-4ca0-b815-2449b74b4156	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:25:52.834263-05	2025-10-13 17:26:52.823173-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:23:52.834263-05	2025-10-13 17:26:52.835792-05	2025-10-13 17:33:52.834263-05	f	\N
8815144c-b88d-48c4-8d09-2d6e4e5c6545	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:57:52.880426-05	2025-10-13 17:58:52.876225-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:55:52.880426-05	2025-10-13 17:58:52.890795-05	2025-10-13 18:05:52.880426-05	f	\N
17e65e09-ac91-4fab-afbe-572955fb7239	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:59:01.801974-05	2025-10-13 17:59:01.807399-05	\N	2025-10-13 22:59:00	00:15:00	2025-10-13 17:58:01.801974-05	2025-10-13 17:59:01.822877-05	2025-10-13 18:00:01.801974-05	f	\N
92567655-57f9-47d6-ae1e-e01651b37d27	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:49:13.393159-05	2025-10-13 14:49:17.372844-05	\N	2025-10-13 19:49:00	00:15:00	2025-10-13 14:49:13.393159-05	2025-10-13 14:49:17.384527-05	2025-10-13 14:50:13.393159-05	f	\N
123ed4d7-5c1f-4090-9422-969894bc69b6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:49:01.819313-05	2025-10-13 12:49:02.999316-05	\N	2025-10-13 17:49:00	00:15:00	2025-10-13 12:48:04.819313-05	2025-10-13 12:49:03.007625-05	2025-10-13 12:50:01.819313-05	f	\N
f121ee10-5f93-43b5-b903-1180699b325f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:49:37.164535-05	2025-10-13 13:49:41.15378-05	\N	2025-10-13 18:49:00	00:15:00	2025-10-13 13:49:37.164535-05	2025-10-13 13:49:41.170175-05	2025-10-13 13:50:37.164535-05	f	\N
f34e4553-7dfd-43e2-a399-f1d14c98c64a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 16:46:53.444473-05	2025-10-13 16:48:00.275339-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 16:46:53.444473-05	2025-10-13 16:48:00.285967-05	2025-10-13 16:54:53.444473-05	f	\N
3038b762-8d33-421f-bb85-61ecaa8247b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:25:01.48751-05	2025-10-13 15:25:04.496463-05	\N	2025-10-13 20:25:00	00:15:00	2025-10-13 15:24:04.48751-05	2025-10-13 15:25:04.507356-05	2025-10-13 15:26:01.48751-05	f	\N
4f8987c3-fc3f-45a8-9232-c3a28a8944b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:58:01.775909-05	2025-10-13 17:58:01.788076-05	\N	2025-10-13 22:58:00	00:15:00	2025-10-13 17:57:01.775909-05	2025-10-13 17:58:01.803415-05	2025-10-13 17:59:01.775909-05	f	\N
6593d113-c761-420c-8d57-bdbd1ce23dea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:30:36.253242-05	2025-10-13 13:30:40.228003-05	\N	2025-10-13 18:30:00	00:15:00	2025-10-13 13:30:36.253242-05	2025-10-13 13:30:40.2434-05	2025-10-13 13:31:36.253242-05	f	\N
eca36e28-35c7-4059-aabd-785a2e8e9184	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:57:01.375698-05	2025-10-13 14:58:52.482148-05	\N	2025-10-13 19:57:00	00:15:00	2025-10-13 14:56:06.375698-05	2025-10-13 14:58:52.54406-05	2025-10-13 14:58:01.375698-05	f	\N
cf1c0dda-bff5-46e8-999e-20a88d32b482	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:26:01.506194-05	2025-10-13 15:42:46.223571-05	\N	2025-10-13 20:26:00	00:15:00	2025-10-13 15:25:04.506194-05	2025-10-13 15:42:46.239546-05	2025-10-13 15:27:01.506194-05	f	\N
019386d3-dc6d-47d5-958f-ed6db190c167	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:59:01.543781-05	2025-10-13 14:59:06.848429-05	\N	2025-10-13 19:59:00	00:15:00	2025-10-13 14:58:52.543781-05	2025-10-13 14:59:06.860804-05	2025-10-13 15:00:01.543781-05	f	\N
c2d19a4b-21a9-4253-8d61-a869ba62339f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:34:01.140173-05	2025-10-13 18:41:57.690123-05	\N	2025-10-13 23:34:00	00:15:00	2025-10-13 18:33:28.140173-05	2025-10-13 18:41:57.701945-05	2025-10-13 18:35:01.140173-05	f	\N
96854b14-dd5d-4019-9af1-e7a52e710033	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:27:01.134724-05	2025-10-13 17:27:01.14431-05	\N	2025-10-13 22:27:00	00:15:00	2025-10-13 17:26:01.134724-05	2025-10-13 17:27:01.156216-05	2025-10-13 17:28:01.134724-05	f	\N
85105549-baa1-42ec-8f27-3cf30844d604	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:28:01.154058-05	2025-10-13 17:28:01.165263-05	\N	2025-10-13 22:28:00	00:15:00	2025-10-13 17:27:01.154058-05	2025-10-13 17:28:01.178792-05	2025-10-13 17:29:01.154058-05	f	\N
c06ba042-8283-4b3e-8e3a-c4af20328ae7	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-13T17:48:35.014Z"}	completed	0	0	0	f	2025-10-13 15:00:02.839893-05	2025-10-13 15:00:06.836244-05	dailyStatsJob	2025-10-13 20:00:00	00:15:00	2025-10-13 15:00:02.839893-05	2025-10-13 15:00:06.839915-05	2025-10-27 15:00:02.839893-05	f	\N
a6cea5e7-9b89-4f13-9db6-80003c68f573	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 15:00:06.838926-05	2025-10-13 15:00:06.843587-05	\N	\N	00:15:00	2025-10-13 15:00:06.838926-05	2025-10-13 15:00:06.990735-05	2025-10-27 15:00:06.838926-05	f	\N
38c73b71-c839-4f39-8549-89abf647e545	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:28:52.837649-05	2025-10-13 17:29:52.824827-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:26:52.837649-05	2025-10-13 17:29:52.835487-05	2025-10-13 17:36:52.837649-05	f	\N
b7f77c1d-3f89-46dc-9fbd-f136357cb2e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:01:01.842926-05	2025-10-13 15:01:02.845628-05	\N	2025-10-13 20:01:00	00:15:00	2025-10-13 15:00:02.842926-05	2025-10-13 15:01:02.853284-05	2025-10-13 15:02:01.842926-05	f	\N
293ed79e-541e-45a3-aee8-29eb445ad496	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:00:01.820497-05	2025-10-13 18:00:01.824927-05	\N	2025-10-13 23:00:00	00:15:00	2025-10-13 17:59:01.820497-05	2025-10-13 18:00:01.833933-05	2025-10-13 18:01:01.820497-05	f	\N
613052dc-259e-4a1d-8839-bbd2815e90f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:03:01.867726-05	2025-10-13 15:03:02.876232-05	\N	2025-10-13 20:03:00	00:15:00	2025-10-13 15:02:02.867726-05	2025-10-13 15:03:02.882851-05	2025-10-13 15:04:01.867726-05	f	\N
42caa4e8-2599-4ece-a935-a297cd1bff95	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:00:52.89354-05	2025-10-13 18:01:52.877216-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:58:52.89354-05	2025-10-13 18:01:52.881982-05	2025-10-13 18:08:52.89354-05	f	\N
7c5c6d49-f068-4967-9366-dff635254a24	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:06:52.501953-05	2025-10-13 15:06:53.664554-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:04:52.501953-05	2025-10-13 15:06:53.671146-05	2025-10-13 15:14:52.501953-05	f	\N
ae5d9d0a-efda-4dad-9ffe-82c33fccde61	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:29:01.17691-05	2025-10-13 17:29:01.178712-05	\N	2025-10-13 22:29:00	00:15:00	2025-10-13 17:28:01.17691-05	2025-10-13 17:29:01.198672-05	2025-10-13 17:30:01.17691-05	f	\N
35305495-c097-4c8b-979b-c45084a1ddab	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 13:30:36.266581-05	2025-10-13 13:31:36.228541-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 13:30:36.266581-05	2025-10-13 13:31:36.237928-05	2025-10-13 13:38:36.266581-05	f	\N
c021d3b9-7373-4f06-a4b4-bb529283c04a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:31:01.242221-05	2025-10-13 13:31:04.233993-05	\N	2025-10-13 18:31:00	00:15:00	2025-10-13 13:30:40.242221-05	2025-10-13 13:31:04.237813-05	2025-10-13 13:32:01.242221-05	f	\N
f98a8a82-ab16-427d-be7b-94e0b7b0ef67	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:58:52.493237-05	2025-10-13 14:58:56.482963-05	\N	2025-10-13 19:58:00	00:15:00	2025-10-13 14:58:52.493237-05	2025-10-13 14:58:56.490184-05	2025-10-13 14:59:52.493237-05	f	\N
68594409-c8ee-47f9-9d6d-bb01886a0943	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:47:01.446356-05	2025-10-13 16:47:05.283634-05	\N	2025-10-13 21:47:00	00:15:00	2025-10-13 16:46:53.446356-05	2025-10-13 16:47:05.294285-05	2025-10-13 16:48:01.446356-05	f	\N
6b7a3451-7b6e-447f-bc3d-38be815104a7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:50:01.166991-05	2025-10-13 13:50:05.160174-05	\N	2025-10-13 18:50:00	00:15:00	2025-10-13 13:49:37.166991-05	2025-10-13 13:50:05.171852-05	2025-10-13 13:51:01.166991-05	f	\N
3058b145-2b5e-4c1a-aaf9-a666cb81c5f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:42:46.237597-05	2025-10-13 15:42:50.216048-05	\N	2025-10-13 20:42:00	00:15:00	2025-10-13 15:42:46.237597-05	2025-10-13 15:42:50.231101-05	2025-10-13 15:43:46.237597-05	f	\N
2f4d8e29-872b-4395-869b-df84ce154c51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:48:01.293144-05	2025-10-13 16:48:04.271545-05	\N	2025-10-13 21:48:00	00:15:00	2025-10-13 16:47:05.293144-05	2025-10-13 16:48:04.281739-05	2025-10-13 16:49:01.293144-05	f	\N
431b15b4-5fa3-4459-a2ea-acd916171bdd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:02:01.852142-05	2025-10-13 15:02:02.858829-05	\N	2025-10-13 20:02:00	00:15:00	2025-10-13 15:01:02.852142-05	2025-10-13 15:02:02.869472-05	2025-10-13 15:03:01.852142-05	f	\N
f428974b-81f7-40fa-9cba-6fcb28de304b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:31:52.838067-05	2025-10-13 17:32:52.826527-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:29:52.838067-05	2025-10-13 17:32:52.832388-05	2025-10-13 17:39:52.838067-05	f	\N
15b7b701-ba4f-4940-b745-a30a525da5b5	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-13T20:07:20.290Z"}	completed	0	0	0	f	2025-10-13 18:00:01.828527-05	2025-10-13 18:00:05.825937-05	dailyStatsJob	2025-10-13 23:00:00	00:15:00	2025-10-13 18:00:01.828527-05	2025-10-13 18:00:05.831496-05	2025-10-27 18:00:01.828527-05	f	\N
465c3bca-f850-49ab-b3b9-72e51a6b219f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:42:01.700023-05	2025-10-13 18:42:05.689914-05	\N	2025-10-13 23:42:00	00:15:00	2025-10-13 18:42:01.700023-05	2025-10-13 18:42:05.699384-05	2025-10-13 18:43:01.700023-05	f	\N
b3b1a5f4-de8e-41cf-aeac-fe680e2606b8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:04:01.881762-05	2025-10-13 15:04:02.892421-05	\N	2025-10-13 20:04:00	00:15:00	2025-10-13 15:03:02.881762-05	2025-10-13 15:04:02.902426-05	2025-10-13 15:05:01.881762-05	f	\N
2750faac-6838-4b93-8b36-b35c9a2e792f	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 18:00:05.8292-05	2025-10-13 18:00:06.851981-05	\N	\N	00:15:00	2025-10-13 18:00:05.8292-05	2025-10-13 18:00:07.047404-05	2025-10-27 18:00:05.8292-05	f	\N
000d0672-dccd-4d93-9527-91349e993332	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:03:52.494617-05	2025-10-13 15:04:52.485834-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:01:52.494617-05	2025-10-13 15:04:52.499929-05	2025-10-13 15:11:52.494617-05	f	\N
9ac3569f-1da3-4cb9-abab-27aa20d2a42e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:34:01.244397-05	2025-10-13 17:34:01.256374-05	\N	2025-10-13 22:34:00	00:15:00	2025-10-13 17:33:01.244397-05	2025-10-13 17:34:01.274277-05	2025-10-13 17:35:01.244397-05	f	\N
3fa7031d-1057-4aff-b975-d9ad436fe71e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:05:01.900921-05	2025-10-13 15:05:02.909299-05	\N	2025-10-13 20:05:00	00:15:00	2025-10-13 15:04:02.900921-05	2025-10-13 15:05:02.919831-05	2025-10-13 15:06:01.900921-05	f	\N
bfd90423-0d72-4277-99ad-2d058865b685	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:41:57.710458-05	2025-10-13 18:42:57.691773-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:41:57.710458-05	2025-10-13 18:42:57.705608-05	2025-10-13 18:49:57.710458-05	f	\N
438fb8dc-4e17-4489-b1ea-2036d1b8fddb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:06:01.917943-05	2025-10-13 15:06:05.659217-05	\N	2025-10-13 20:06:00	00:15:00	2025-10-13 15:05:02.917943-05	2025-10-13 15:06:05.671927-05	2025-10-13 15:07:01.917943-05	f	\N
165e5640-44f2-4f71-ac69-7e02c4ba95dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:01:01.832604-05	2025-10-13 18:01:01.843976-05	\N	2025-10-13 23:01:00	00:15:00	2025-10-13 18:00:01.832604-05	2025-10-13 18:01:01.855687-05	2025-10-13 18:02:01.832604-05	f	\N
b587c288-23c8-45a4-b773-0b4b8880793c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:35:01.271675-05	2025-10-13 17:35:01.283546-05	\N	2025-10-13 22:35:00	00:15:00	2025-10-13 17:34:01.271675-05	2025-10-13 17:35:01.299501-05	2025-10-13 17:36:01.271675-05	f	\N
1734eb72-93a7-41fe-954e-0bd69a3b872b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:34:52.834316-05	2025-10-13 17:35:52.826917-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:32:52.834316-05	2025-10-13 17:35:52.839718-05	2025-10-13 17:42:52.834316-05	f	\N
ae2cc7c2-eaf8-4628-bced-3cab7672d008	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:02:01.854323-05	2025-10-13 18:02:01.858511-05	\N	2025-10-13 23:02:00	00:15:00	2025-10-13 18:01:01.854323-05	2025-10-13 18:02:01.867812-05	2025-10-13 18:03:01.854323-05	f	\N
3e645df7-60c6-4270-b142-f9576e69f590	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:36:01.29472-05	2025-10-13 17:36:01.306402-05	\N	2025-10-13 22:36:00	00:15:00	2025-10-13 17:35:01.29472-05	2025-10-13 17:36:01.32564-05	2025-10-13 17:37:01.29472-05	f	\N
fa409fe2-f551-434b-9122-0a03c4fd8768	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:43:01.697871-05	2025-10-13 18:43:01.703304-05	\N	2025-10-13 23:43:00	00:15:00	2025-10-13 18:42:05.697871-05	2025-10-13 18:43:01.719151-05	2025-10-13 18:44:01.697871-05	f	\N
928f4835-4fc5-4682-9e23-620767a7c761	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:37:01.32367-05	2025-10-13 17:37:05.321495-05	\N	2025-10-13 22:37:00	00:15:00	2025-10-13 17:36:01.32367-05	2025-10-13 17:37:05.338036-05	2025-10-13 17:38:01.32367-05	f	\N
2f79af5d-77d6-44f6-8bd4-14fef1cffa1c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:44:57.707349-05	2025-10-13 18:45:46.614059-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:42:57.707349-05	2025-10-13 18:45:46.630461-05	2025-10-13 18:52:57.707349-05	f	\N
7973c6b6-fcf3-441c-9f53-2cb467e4d28c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:38:01.335968-05	2025-10-13 17:38:01.336768-05	\N	2025-10-13 22:38:00	00:15:00	2025-10-13 17:37:05.335968-05	2025-10-13 17:38:01.355675-05	2025-10-13 17:39:01.335968-05	f	\N
da6f028c-d546-4689-964c-d7fe0183902d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:40:01.366118-05	2025-10-13 17:40:05.367848-05	\N	2025-10-13 22:40:00	00:15:00	2025-10-13 17:39:05.366118-05	2025-10-13 17:40:05.380888-05	2025-10-13 17:41:01.366118-05	f	\N
d51e0111-b43e-40b4-bbb7-952cbfb19c9d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:41:01.379036-05	2025-10-13 17:41:01.390905-05	\N	2025-10-13 22:41:00	00:15:00	2025-10-13 17:40:05.379036-05	2025-10-13 17:41:01.405422-05	2025-10-13 17:42:01.379036-05	f	\N
d289e880-19ca-4f36-926e-9930e56975c6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:32:01.237277-05	2025-10-13 13:32:04.249451-05	\N	2025-10-13 18:32:00	00:15:00	2025-10-13 13:31:04.237277-05	2025-10-13 13:32:04.260379-05	2025-10-13 13:33:01.237277-05	f	\N
d899405b-7a6d-4e3e-b933-8ec5772c845a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:48:34.989148-05	2025-10-13 12:48:34.990524-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:48:34.989148-05	2025-10-13 12:48:34.997251-05	2025-10-13 12:56:34.989148-05	f	\N
00c0fed0-9114-4272-a2f2-5d30f8dd9772	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:44:01.717722-05	2025-10-13 18:45:46.604633-05	\N	2025-10-13 23:44:00	00:15:00	2025-10-13 18:43:01.717722-05	2025-10-13 18:45:46.616674-05	2025-10-13 18:45:01.717722-05	f	\N
175c48cb-37fd-4eca-904f-3111954cda03	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:03:52.883024-05	2025-10-13 18:04:52.879084-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:01:52.883024-05	2025-10-13 18:04:52.888565-05	2025-10-13 18:11:52.883024-05	f	\N
54ba66f1-fd19-4788-b4be-6d2908638d61	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:49:01.281109-05	2025-10-13 16:49:36.820753-05	\N	2025-10-13 21:49:00	00:15:00	2025-10-13 16:48:04.281109-05	2025-10-13 16:49:36.832306-05	2025-10-13 16:50:01.281109-05	f	\N
18793ec0-5de2-43ad-91b6-cd4f4443172a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:50:34.998728-05	2025-10-13 12:51:34.993138-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:48:34.998728-05	2025-10-13 12:51:35.003939-05	2025-10-13 12:58:34.998728-05	f	\N
e20dcd85-adb1-48b5-8624-44d2ee5f0ee1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:00:01.859701-05	2025-10-13 15:00:02.835745-05	\N	2025-10-13 20:00:00	00:15:00	2025-10-13 14:59:06.859701-05	2025-10-13 15:00:02.844165-05	2025-10-13 15:01:01.859701-05	f	\N
a4e7902c-c4b9-42f8-ad91-f0472f35658d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 13:49:37.166841-05	2025-10-13 13:49:37.167054-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 13:49:37.166841-05	2025-10-13 13:49:37.179012-05	2025-10-13 13:57:37.166841-05	f	\N
6086f9f2-cc9a-43dd-81d1-c9ad462ed981	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:43:01.229844-05	2025-10-13 15:43:02.219207-05	\N	2025-10-13 20:43:00	00:15:00	2025-10-13 15:42:50.229844-05	2025-10-13 15:43:02.232312-05	2025-10-13 15:44:01.229844-05	f	\N
2d3a94e9-d893-450b-8a67-5c72d4191be3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:00:52.544885-05	2025-10-13 15:01:52.482787-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:58:52.544885-05	2025-10-13 15:01:52.492766-05	2025-10-13 15:08:52.544885-05	f	\N
6f12174a-e81f-4073-b5c6-66092e0e688d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:51:01.170601-05	2025-10-13 13:51:02.789299-05	\N	2025-10-13 18:51:00	00:15:00	2025-10-13 13:50:05.170601-05	2025-10-13 13:51:02.807008-05	2025-10-13 13:52:01.170601-05	f	\N
df01e586-d8d5-4179-965d-b878eaa6d4a0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:30:01.196521-05	2025-10-13 17:30:05.192741-05	\N	2025-10-13 22:30:00	00:15:00	2025-10-13 17:29:01.196521-05	2025-10-13 17:30:05.20897-05	2025-10-13 17:31:01.196521-05	f	\N
965129e7-7518-4c8b-8ba9-e662c8918a39	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:31:01.2077-05	2025-10-13 17:31:05.205285-05	\N	2025-10-13 22:31:00	00:15:00	2025-10-13 17:30:05.2077-05	2025-10-13 17:31:05.222161-05	2025-10-13 17:32:01.2077-05	f	\N
509f037e-3972-433b-952c-05beaad49318	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:07:01.925884-05	2025-10-13 18:07:01.929394-05	\N	2025-10-13 23:07:00	00:15:00	2025-10-13 18:06:01.925884-05	2025-10-13 18:07:01.939542-05	2025-10-13 18:08:01.925884-05	f	\N
a7fff40c-b165-4d95-8a73-28fd502085fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:10:01.991025-05	2025-10-13 18:10:01.998098-05	\N	2025-10-13 23:10:00	00:15:00	2025-10-13 18:09:01.991025-05	2025-10-13 18:10:02.011033-05	2025-10-13 18:11:01.991025-05	f	\N
77f3c20e-c8de-41ae-9318-8f5c0b11a3fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:14:01.049409-05	2025-10-13 18:14:02.056123-05	\N	2025-10-13 23:14:00	00:15:00	2025-10-13 18:13:02.049409-05	2025-10-13 18:14:02.061842-05	2025-10-13 18:15:01.049409-05	f	\N
4e7e0a1f-c27d-4145-b690-f24c5df2de40	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:15:01.060667-05	2025-10-13 18:15:02.071764-05	\N	2025-10-13 23:15:00	00:15:00	2025-10-13 18:14:02.060667-05	2025-10-13 18:15:02.075763-05	2025-10-13 18:16:01.060667-05	f	\N
3c2c0768-665f-49f4-aab2-c99670ed25d6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:16:01.074874-05	2025-10-13 18:16:02.086553-05	\N	2025-10-13 23:16:00	00:15:00	2025-10-13 18:15:02.074874-05	2025-10-13 18:16:02.093846-05	2025-10-13 18:17:01.074874-05	f	\N
d2a968a5-273c-4b97-9ea0-17c25ff70af4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:50:01.831255-05	2025-10-13 16:53:01.859262-05	\N	2025-10-13 21:50:00	00:15:00	2025-10-13 16:49:36.831255-05	2025-10-13 16:53:01.944481-05	2025-10-13 16:51:01.831255-05	f	\N
e79df680-e5f5-4b8f-8ee1-1e5241e21213	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:07:01.670221-05	2025-10-13 15:07:01.681444-05	\N	2025-10-13 20:07:00	00:15:00	2025-10-13 15:06:05.670221-05	2025-10-13 15:07:01.696538-05	2025-10-13 15:08:01.670221-05	f	\N
deedbef3-3931-4784-9724-2cacd0c41e26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:44:01.231341-05	2025-10-13 16:00:01.697223-05	\N	2025-10-13 20:44:00	00:15:00	2025-10-13 15:43:02.231341-05	2025-10-13 16:00:01.70739-05	2025-10-13 15:45:01.231341-05	f	\N
8160a85b-8e07-46d3-9018-ed34f913a734	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:03:01.865673-05	2025-10-13 18:03:01.873685-05	\N	2025-10-13 23:03:00	00:15:00	2025-10-13 18:02:01.865673-05	2025-10-13 18:03:01.891385-05	2025-10-13 18:04:01.865673-05	f	\N
5d798c58-7c33-4774-9108-0e07730ae725	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:32:01.219868-05	2025-10-13 17:32:05.219709-05	\N	2025-10-13 22:32:00	00:15:00	2025-10-13 17:31:05.219868-05	2025-10-13 17:32:05.233563-05	2025-10-13 17:33:01.219868-05	f	\N
898e5635-8628-4e61-a70e-32b54bde190f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:45:46.613449-05	2025-10-13 18:45:50.606255-05	\N	2025-10-13 23:45:00	00:15:00	2025-10-13 18:45:46.613449-05	2025-10-13 18:45:50.611456-05	2025-10-13 18:46:46.613449-05	f	\N
c067341f-8049-4dbb-b31c-78a44bdf6f73	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:33:01.230977-05	2025-10-13 17:33:01.233576-05	\N	2025-10-13 22:33:00	00:15:00	2025-10-13 17:32:05.230977-05	2025-10-13 17:33:01.245352-05	2025-10-13 17:34:01.230977-05	f	\N
9335dde4-5af3-4115-ba46-c51e4e478aaa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:46:01.610414-05	2025-10-13 18:46:02.608253-05	\N	2025-10-13 23:46:00	00:15:00	2025-10-13 18:45:50.610414-05	2025-10-13 18:46:02.623258-05	2025-10-13 18:47:01.610414-05	f	\N
47661f8d-8a6b-4eb2-8084-7a54fa801a05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:51:01.030521-05	2025-10-13 12:51:03.03329-05	\N	2025-10-13 17:51:00	00:15:00	2025-10-13 12:50:03.030521-05	2025-10-13 12:51:03.05281-05	2025-10-13 12:52:01.030521-05	f	\N
79eb9bd8-97e5-4859-81db-325cd82c6799	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:37:52.841757-05	2025-10-13 17:38:52.830254-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:35:52.841757-05	2025-10-13 17:38:52.843123-05	2025-10-13 17:45:52.841757-05	f	\N
0c45bce8-8a22-4744-b96b-0709ef4ee37a	__pgboss__maintenance	0	\N	created	0	0	0	f	2025-10-13 18:47:46.632352-05	\N	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:45:46.632352-05	\N	2025-10-13 18:55:46.632352-05	f	\N
5447d475-3e68-4888-9e73-4b2c055a0fe4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:50:01.006483-05	2025-10-13 12:50:03.01624-05	\N	2025-10-13 17:50:00	00:15:00	2025-10-13 12:49:03.006483-05	2025-10-13 12:50:03.031575-05	2025-10-13 12:51:01.006483-05	f	\N
3f26efd1-99a3-41fc-a528-ace9bfdf7f6f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:53:01.876656-05	2025-10-13 16:53:05.835444-05	\N	2025-10-13 21:53:00	00:15:00	2025-10-13 16:53:01.876656-05	2025-10-13 16:53:05.844228-05	2025-10-13 16:54:01.876656-05	f	\N
bd24580a-adbc-4901-bf71-3e31e11db187	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:52:01.80506-05	2025-10-13 13:54:44.721168-05	\N	2025-10-13 18:52:00	00:15:00	2025-10-13 13:51:02.80506-05	2025-10-13 13:54:44.842328-05	2025-10-13 13:53:01.80506-05	f	\N
9815f6b7-b00b-46a1-9168-bdb185e0a73a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:39:01.352617-05	2025-10-13 17:39:05.353216-05	\N	2025-10-13 22:39:00	00:15:00	2025-10-13 17:38:01.352617-05	2025-10-13 17:39:05.368288-05	2025-10-13 17:40:01.352617-05	f	\N
1419e424-02d6-463b-91d8-a00e02118507	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-13T20:07:20.290Z"}	completed	0	0	0	f	2025-10-13 16:00:01.70256-05	2025-10-13 16:04:58.281238-05	dailyStatsJob	2025-10-13 21:00:00	00:15:00	2025-10-13 16:00:01.70256-05	2025-10-13 16:04:58.291762-05	2025-10-27 16:00:01.70256-05	f	\N
e3c92b64-1cc5-4c8e-a110-f220c65f5a56	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:04:01.888965-05	2025-10-13 18:04:01.893156-05	\N	2025-10-13 23:04:00	00:15:00	2025-10-13 18:03:01.888965-05	2025-10-13 18:04:01.899604-05	2025-10-13 18:05:01.888965-05	f	\N
ec282d25-3caa-4024-bc55-bbe909a10969	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:53:01.055009-05	2025-10-13 12:53:03.064948-05	\N	2025-10-13 17:53:00	00:15:00	2025-10-13 12:52:03.055009-05	2025-10-13 12:53:03.085938-05	2025-10-13 12:54:01.055009-05	f	\N
71c73de9-e4fd-476c-9f8a-4b5aa5822dd1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:00:01.706231-05	2025-10-13 16:04:58.281531-05	\N	2025-10-13 21:00:00	00:15:00	2025-10-13 16:00:01.706231-05	2025-10-13 16:04:58.29644-05	2025-10-13 16:01:01.706231-05	f	\N
983ff39d-6a35-41be-a15f-d949b7eb5a4e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:40:52.844263-05	2025-10-13 17:41:52.830391-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:38:52.844263-05	2025-10-13 17:41:52.844676-05	2025-10-13 17:48:52.844263-05	f	\N
acaa3967-5477-4743-a23f-271375393d17	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:42:01.404146-05	2025-10-13 17:42:05.397822-05	\N	2025-10-13 22:42:00	00:15:00	2025-10-13 17:41:01.404146-05	2025-10-13 17:42:05.412906-05	2025-10-13 17:43:01.404146-05	f	\N
9f67d404-576b-4980-b8a6-d8b2794194e8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:05:01.898363-05	2025-10-13 18:05:01.903779-05	\N	2025-10-13 23:05:00	00:15:00	2025-10-13 18:04:01.898363-05	2025-10-13 18:05:01.916662-05	2025-10-13 18:06:01.898363-05	f	\N
d3b4e43f-a9ea-4584-9bfe-2c1230e03e80	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:44:01.429278-05	2025-10-13 17:44:01.4451-05	\N	2025-10-13 22:44:00	00:15:00	2025-10-13 17:43:01.429278-05	2025-10-13 17:44:01.465138-05	2025-10-13 17:45:01.429278-05	f	\N
3447acb5-1094-4fad-a60f-f769a1ef8e04	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:06:01.915123-05	2025-10-13 18:06:01.917498-05	\N	2025-10-13 23:06:00	00:15:00	2025-10-13 18:05:01.915123-05	2025-10-13 18:06:01.927348-05	2025-10-13 18:07:01.915123-05	f	\N
6341b560-6434-4364-a62f-e242c51c0284	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:06:52.890885-05	2025-10-13 18:07:52.880868-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:04:52.890885-05	2025-10-13 18:07:52.889923-05	2025-10-13 18:14:52.890885-05	f	\N
ab6053fd-3000-4185-b49f-48e2d7887596	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:08:01.694289-05	2025-10-13 15:08:04.281885-05	\N	2025-10-13 20:08:00	00:15:00	2025-10-13 15:07:01.694289-05	2025-10-13 15:08:04.287666-05	2025-10-13 15:09:01.694289-05	f	\N
830cc59a-ae7a-47a7-b6cb-b7f56fc7267a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:47:01.621378-05	2025-10-13 18:47:02.62554-05	\N	2025-10-13 23:47:00	00:15:00	2025-10-13 18:46:02.621378-05	2025-10-13 18:47:02.63765-05	2025-10-13 18:48:01.621378-05	f	\N
271702e9-8f9e-4370-a982-f83fd450211d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:54:44.725069-05	2025-10-13 13:54:48.685726-05	\N	2025-10-13 18:54:00	00:15:00	2025-10-13 13:54:44.725069-05	2025-10-13 13:54:48.698076-05	2025-10-13 13:55:44.725069-05	f	\N
e9dd9ed9-5af5-47e9-b0c4-615d2e0e9a04	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 16:00:01.710455-05	2025-10-13 16:00:01.710565-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 16:00:01.710455-05	2025-10-13 16:00:01.719169-05	2025-10-13 16:08:01.710455-05	f	\N
cd7321bd-ad0a-4473-a822-b2e2812c75c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:43:01.411162-05	2025-10-13 17:43:01.413596-05	\N	2025-10-13 22:43:00	00:15:00	2025-10-13 17:42:05.411162-05	2025-10-13 17:43:01.431572-05	2025-10-13 17:44:01.411162-05	f	\N
1efa3320-0dbe-404b-b87e-a3c97a4a08f4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:53:35.006067-05	2025-10-13 12:53:35.012884-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:51:35.006067-05	2025-10-13 12:53:35.025978-05	2025-10-13 13:01:35.006067-05	f	\N
da56f090-c843-4253-b13c-e0c08767eebb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:08:01.938282-05	2025-10-13 18:08:01.952257-05	\N	2025-10-13 23:08:00	00:15:00	2025-10-13 18:07:01.938282-05	2025-10-13 18:08:01.95941-05	2025-10-13 18:09:01.938282-05	f	\N
4574454b-feac-4805-a508-24e446480dfb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:04:58.295344-05	2025-10-13 16:05:02.285057-05	\N	2025-10-13 21:04:00	00:15:00	2025-10-13 16:04:58.295344-05	2025-10-13 16:05:02.29664-05	2025-10-13 16:05:58.295344-05	f	\N
50ed9bfb-871e-4007-844d-8be30af5845e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:43:52.848002-05	2025-10-13 17:43:52.853475-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:41:52.848002-05	2025-10-13 17:43:52.863295-05	2025-10-13 17:51:52.848002-05	f	\N
210cc132-87c5-4dc3-b7dc-c93f04db3d72	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:09:01.958581-05	2025-10-13 18:09:01.982559-05	\N	2025-10-13 23:09:00	00:15:00	2025-10-13 18:08:01.958581-05	2025-10-13 18:09:01.99293-05	2025-10-13 18:10:01.958581-05	f	\N
a1db0c7f-f09f-4427-999e-a02e0cae3a1a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:06:01.666762-05	2025-10-13 16:19:06.231052-05	\N	2025-10-13 21:06:00	00:15:00	2025-10-13 16:05:24.666762-05	2025-10-13 16:19:06.301913-05	2025-10-13 16:07:01.666762-05	f	\N
209a3793-c2ce-4adf-8b5c-7457a8d064ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:54:01.084514-05	2025-10-13 12:54:03.114614-05	\N	2025-10-13 17:54:00	00:15:00	2025-10-13 12:53:03.084514-05	2025-10-13 12:54:03.128533-05	2025-10-13 12:55:01.084514-05	f	\N
1437d6b5-6a5f-400f-a145-fee089b629e2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:45:01.463188-05	2025-10-13 17:45:05.459435-05	\N	2025-10-13 22:45:00	00:15:00	2025-10-13 17:44:01.463188-05	2025-10-13 17:45:05.482992-05	2025-10-13 17:46:01.463188-05	f	\N
0ea0f122-be60-480f-8a9f-81a68ddd02aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:55:01.127495-05	2025-10-13 12:55:03.129083-05	\N	2025-10-13 17:55:00	00:15:00	2025-10-13 12:54:03.127495-05	2025-10-13 12:55:03.13867-05	2025-10-13 12:56:01.127495-05	f	\N
c4b8ca63-6954-4785-9ef7-47c5c24df32b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:09:52.892585-05	2025-10-13 18:09:52.894695-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:07:52.892585-05	2025-10-13 18:09:52.905007-05	2025-10-13 18:17:52.892585-05	f	\N
b8abd500-be80-45d0-a64f-11c08f1ad8ff	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:45:52.865441-05	2025-10-13 17:46:52.858205-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:43:52.865441-05	2025-10-13 17:46:52.864714-05	2025-10-13 17:53:52.865441-05	f	\N
ecf66136-5c5a-468b-a4d3-3574e3f9d477	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:11:01.008959-05	2025-10-13 18:11:02.008207-05	\N	2025-10-13 23:11:00	00:15:00	2025-10-13 18:10:02.008959-05	2025-10-13 18:11:02.019479-05	2025-10-13 18:12:01.008959-05	f	\N
b9e4971e-e12c-4c98-a3d3-c62ac2022c60	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:12:01.017579-05	2025-10-13 18:12:02.025423-05	\N	2025-10-13 23:12:00	00:15:00	2025-10-13 18:11:02.017579-05	2025-10-13 18:12:02.02918-05	2025-10-13 18:13:01.017579-05	f	\N
51f708f4-1c81-4f70-9539-9d0e38113397	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:11:52.909758-05	2025-10-13 18:12:52.897513-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:09:52.909758-05	2025-10-13 18:12:52.902713-05	2025-10-13 18:19:52.909758-05	f	\N
c85e6819-c006-465a-ba75-083d8502bdec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:58:01.167354-05	2025-10-13 12:58:03.177761-05	\N	2025-10-13 17:58:00	00:15:00	2025-10-13 12:57:03.167354-05	2025-10-13 12:58:03.188865-05	2025-10-13 12:59:01.167354-05	f	\N
87377b5a-8916-4f92-a0a0-fcb1c78571c1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:57:35.047146-05	2025-10-13 12:58:35.033683-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:55:35.047146-05	2025-10-13 12:58:35.048541-05	2025-10-13 13:05:35.047146-05	f	\N
a26dcbc1-189e-448e-b3eb-a5d12ca1f8aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:13:01.028397-05	2025-10-13 18:13:02.041316-05	\N	2025-10-13 23:13:00	00:15:00	2025-10-13 18:12:02.028397-05	2025-10-13 18:13:02.051083-05	2025-10-13 18:14:01.028397-05	f	\N
c4071b2c-d83b-43e5-9f16-265cba6466be	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:59:01.18794-05	2025-10-13 12:59:03.192366-05	\N	2025-10-13 17:59:00	00:15:00	2025-10-13 12:58:03.18794-05	2025-10-13 12:59:03.206389-05	2025-10-13 13:00:01.18794-05	f	\N
da6ba065-409a-43fa-8498-27ec602799b2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 18:14:52.903684-05	2025-10-13 18:15:52.900985-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 18:12:52.903684-05	2025-10-13 18:15:52.909242-05	2025-10-13 18:22:52.903684-05	f	\N
dc1bdb66-e4a6-46cd-a198-1e26ba12a2e4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:52:01.050922-05	2025-10-13 12:52:03.048203-05	\N	2025-10-13 17:52:00	00:15:00	2025-10-13 12:51:03.050922-05	2025-10-13 12:52:03.055958-05	2025-10-13 12:53:01.050922-05	f	\N
7b40c814-a477-4449-ae39-1a607923ded2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:49:01.525812-05	2025-10-13 17:49:01.544268-05	\N	2025-10-13 22:49:00	00:15:00	2025-10-13 17:48:01.525812-05	2025-10-13 17:49:01.562851-05	2025-10-13 17:50:01.525812-05	f	\N
bae75e2d-8ecd-49d2-a9ef-7b16c78b00d7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:07:20.263101-05	2025-10-13 15:07:20.265596-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:07:20.263101-05	2025-10-13 15:07:20.272817-05	2025-10-13 15:15:20.263101-05	f	\N
87c225ff-de03-4e60-b959-df05d2a540eb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:46:01.480466-05	2025-10-13 17:46:05.47854-05	\N	2025-10-13 22:46:00	00:15:00	2025-10-13 17:45:05.480466-05	2025-10-13 17:46:05.493136-05	2025-10-13 17:47:01.480466-05	f	\N
607424c1-30a1-4819-85a0-8512679bf20d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:55:35.028339-05	2025-10-13 12:55:35.03028-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:53:35.028339-05	2025-10-13 12:55:35.043989-05	2025-10-13 13:03:35.028339-05	f	\N
30713db5-4f78-4582-ae7d-f82f18c69793	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:07:03.579721-05	2025-10-13 14:07:07.521997-05	\N	2025-10-13 19:07:00	00:15:00	2025-10-13 14:07:03.579721-05	2025-10-13 14:07:07.53353-05	2025-10-13 14:08:03.579721-05	f	\N
dc970930-3268-4080-8152-5a6300691462	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:54:01.843261-05	2025-10-13 16:59:15.956322-05	\N	2025-10-13 21:54:00	00:15:00	2025-10-13 16:53:05.843261-05	2025-10-13 16:59:15.966013-05	2025-10-13 16:55:01.843261-05	f	\N
21b49e29-e78d-473c-9af3-516e2bda6506	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:56:01.138105-05	2025-10-13 12:56:03.143716-05	\N	2025-10-13 17:56:00	00:15:00	2025-10-13 12:55:03.138105-05	2025-10-13 12:56:03.157389-05	2025-10-13 12:57:01.138105-05	f	\N
49dedc23-e2d3-49b3-aa2a-5ff4b765ef44	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 16:04:58.289876-05	2025-10-13 16:05:00.284116-05	\N	\N	00:15:00	2025-10-13 16:04:58.289876-05	2025-10-13 16:05:00.512662-05	2025-10-27 16:04:58.289876-05	f	\N
90257cb7-fbb6-4351-8af0-24def666a218	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:57:01.156425-05	2025-10-13 12:57:03.156885-05	\N	2025-10-13 17:57:00	00:15:00	2025-10-13 12:56:03.156425-05	2025-10-13 12:57:03.168113-05	2025-10-13 12:58:01.156425-05	f	\N
5ecdd857-b029-44ec-a0c9-da4b970c9e28	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:09:20.273759-05	2025-10-13 15:09:44.321225-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:07:20.273759-05	2025-10-13 15:09:44.328548-05	2025-10-13 15:17:20.273759-05	f	\N
48e3013e-88c0-4e81-b383-9318a314ccb9	__pgboss__cron	0	\N	created	2	0	0	f	2025-10-13 18:48:01.635637-05	\N	\N	2025-10-13 23:48:00	00:15:00	2025-10-13 18:47:02.635637-05	\N	2025-10-13 18:49:01.635637-05	f	\N
d62819b7-f571-43c7-91ff-100b46086dac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:10:01.320603-05	2025-10-13 15:10:04.290913-05	\N	2025-10-13 20:10:00	00:15:00	2025-10-13 15:09:44.320603-05	2025-10-13 15:10:04.301986-05	2025-10-13 15:11:01.320603-05	f	\N
c1c5b2b0-fbe8-437f-bd81-f29397a7c968	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:59:15.964313-05	2025-10-13 16:59:19.959687-05	\N	2025-10-13 21:59:00	00:15:00	2025-10-13 16:59:15.964313-05	2025-10-13 16:59:19.972427-05	2025-10-13 17:00:15.964313-05	f	\N
746b0c56-a603-4b0f-a98c-06b453c17c40	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:12:01.312255-05	2025-10-13 15:12:04.317234-05	\N	2025-10-13 20:12:00	00:15:00	2025-10-13 15:11:04.312255-05	2025-10-13 15:12:04.333821-05	2025-10-13 15:13:01.312255-05	f	\N
2d0cc446-8d0d-4e25-b75e-f65b15f7dd3b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:48:52.866351-05	2025-10-13 17:49:52.86111-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:46:52.866351-05	2025-10-13 17:49:52.871434-05	2025-10-13 17:56:52.866351-05	f	\N
0e514caf-e88e-4ece-8d5b-f5cd02c269ca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:13:01.332175-05	2025-10-13 15:13:04.326453-05	\N	2025-10-13 20:13:00	00:15:00	2025-10-13 15:12:04.332175-05	2025-10-13 15:13:04.339853-05	2025-10-13 15:14:01.332175-05	f	\N
12550367-8a4c-470e-89c2-d3e78239d78a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:46:01.758397-05	2025-10-13 06:46:01.762729-05	\N	2025-10-13 11:46:00	00:15:00	2025-10-13 06:45:01.758397-05	2025-10-13 06:46:01.770608-05	2025-10-13 06:47:01.758397-05	f	\N
a8f92d05-8f6a-4044-8444-a438e5d38b35	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:14:01.33829-05	2025-10-13 15:14:04.341409-05	\N	2025-10-13 20:14:00	00:15:00	2025-10-13 15:13:04.33829-05	2025-10-13 15:14:04.355115-05	2025-10-13 15:15:01.33829-05	f	\N
9f30635e-79e6-47fa-9174-3ff1912219b4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:47:08.787512-05	2025-10-13 06:48:08.784489-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:45:08.787512-05	2025-10-13 06:48:08.792476-05	2025-10-13 06:55:08.787512-05	f	\N
d99cf4d2-49bc-428c-9b97-c6a3b5bad1a3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:17:01.092536-05	2025-10-13 18:17:02.098298-05	\N	2025-10-13 23:17:00	00:15:00	2025-10-13 18:16:02.092536-05	2025-10-13 18:17:02.109686-05	2025-10-13 18:18:01.092536-05	f	\N
44f7a8d4-c7e1-4479-8931-041d8656f79e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:50:01.813384-05	2025-10-13 06:53:09.678638-05	\N	2025-10-13 11:50:00	00:15:00	2025-10-13 06:49:01.813384-05	2025-10-13 06:53:09.687079-05	2025-10-13 06:51:01.813384-05	f	\N
715d341d-d291-4984-97e3-79b25c03f6e4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:16:01.367812-05	2025-10-13 15:16:04.36662-05	\N	2025-10-13 20:16:00	00:15:00	2025-10-13 15:15:04.367812-05	2025-10-13 15:16:04.37746-05	2025-10-13 15:17:01.367812-05	f	\N
cf8b69f7-5246-4fd4-ac27-9d3e1c474860	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:43:01.741339-05	2025-10-13 12:43:04.7391-05	\N	2025-10-13 17:43:00	00:15:00	2025-10-13 12:42:20.741339-05	2025-10-13 12:43:04.753487-05	2025-10-13 12:44:01.741339-05	f	\N
18cef10b-192f-4d2a-8b0d-3b198ec17f93	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:44:16.726301-05	2025-10-13 12:45:16.714635-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:42:16.726301-05	2025-10-13 12:45:16.727162-05	2025-10-13 12:52:16.726301-05	f	\N
cde9b455-67e6-4e45-8635-4af4ef0d7f05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:55:01.839836-05	2025-10-13 14:07:03.573688-05	\N	2025-10-13 18:55:00	00:15:00	2025-10-13 13:54:44.839836-05	2025-10-13 14:07:03.580328-05	2025-10-13 13:56:01.839836-05	f	\N
47111d9a-14a2-4a1f-8347-98299f39490c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:09:01.286928-05	2025-10-13 15:09:44.307815-05	\N	2025-10-13 20:09:00	00:15:00	2025-10-13 15:08:04.286928-05	2025-10-13 15:09:44.321396-05	2025-10-13 15:10:01.286928-05	f	\N
dae48b29-f2db-491f-902c-c197bf82c7a6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 18:18:01.107629-05	2025-10-13 18:33:28.005167-05	\N	2025-10-13 23:18:00	00:15:00	2025-10-13 18:17:02.107629-05	2025-10-13 18:33:28.14073-05	2025-10-13 18:19:01.107629-05	f	\N
432c6721-8ecb-44f6-a4f0-bdb817dff268	dailyStatsJob	0	\N	completed	0	0	0	f	2025-10-13 13:00:07.212041-05	2025-10-13 13:00:07.371334-05	\N	\N	00:15:00	2025-10-13 13:00:07.212041-05	2025-10-13 13:00:07.616468-05	2025-10-27 13:00:07.212041-05	f	\N
87016626-fbc4-4f7a-8ba5-a9b59b38c47c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:05:02.295572-05	2025-10-13 16:05:24.658141-05	\N	2025-10-13 21:05:00	00:15:00	2025-10-13 16:05:02.295572-05	2025-10-13 16:05:24.667755-05	2025-10-13 16:06:02.295572-05	f	\N
8b633aad-85a5-4b34-8034-502165d2eaf3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 13:00:35.050428-05	2025-10-13 13:01:35.036541-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:58:35.050428-05	2025-10-13 13:01:35.043071-05	2025-10-13 13:08:35.050428-05	f	\N
3211590b-5fa7-498d-bbf8-2d5ef766a5e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:00:01.971244-05	2025-10-13 17:04:49.481432-05	\N	2025-10-13 22:00:00	00:15:00	2025-10-13 16:59:19.971244-05	2025-10-13 17:04:49.495303-05	2025-10-13 17:01:01.971244-05	f	\N
5684744a-2e18-4cf0-8752-ca93e74a541b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:47:01.490521-05	2025-10-13 17:47:01.492333-05	\N	2025-10-13 22:47:00	00:15:00	2025-10-13 17:46:05.490521-05	2025-10-13 17:47:01.508573-05	2025-10-13 17:48:01.490521-05	f	\N
6a58dbec-5f8c-448d-9ffa-29c7d5cf5d6a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:48:01.506959-05	2025-10-13 17:48:01.516992-05	\N	2025-10-13 22:48:00	00:15:00	2025-10-13 17:47:01.506959-05	2025-10-13 17:48:01.526708-05	2025-10-13 17:49:01.506959-05	f	\N
b97ea68f-d9fd-4d18-8a64-7a0d07a85b2a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:53:09.679894-05	2025-10-13 06:53:13.66028-05	\N	2025-10-13 11:53:00	00:15:00	2025-10-13 06:53:09.679894-05	2025-10-13 06:53:13.667722-05	2025-10-13 06:54:09.679894-05	f	\N
7c34d5e6-56a7-48f4-b924-ed180cd0de90	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 12:42:16.710376-05	2025-10-13 12:42:16.713655-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 12:42:16.710376-05	2025-10-13 12:42:16.725267-05	2025-10-13 12:50:16.710376-05	f	\N
75736354-8b58-4554-9196-f063fbdc90b6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:19:06.300994-05	2025-10-13 16:19:10.198732-05	\N	2025-10-13 21:19:00	00:15:00	2025-10-13 16:19:06.300994-05	2025-10-13 16:19:10.21122-05	2025-10-13 16:20:06.300994-05	f	\N
01ee7a4b-67b2-43b9-a59b-a45ad37f0fb1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:08:01.5321-05	2025-10-13 14:09:11.006683-05	\N	2025-10-13 19:08:00	00:15:00	2025-10-13 14:07:07.5321-05	2025-10-13 14:09:11.016858-05	2025-10-13 14:09:01.5321-05	f	\N
56bbeca2-da2f-4f79-812b-dfb569a400f4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:00:01.204707-05	2025-10-13 13:00:03.207877-05	\N	2025-10-13 18:00:00	00:15:00	2025-10-13 12:59:03.204707-05	2025-10-13 13:00:03.21258-05	2025-10-13 13:01:01.204707-05	f	\N
3d5203e2-d5eb-4d4d-9eae-f5ea4eeb750c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:11:01.299057-05	2025-10-13 15:11:04.302672-05	\N	2025-10-13 20:11:00	00:15:00	2025-10-13 15:10:04.299057-05	2025-10-13 15:11:04.313971-05	2025-10-13 15:12:01.299057-05	f	\N
e2e0dcfc-213e-4de2-86ca-35430629d9c2	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-10-02T03:45:28.994Z", "updated_on": "2025-10-13T17:48:35.014Z"}	completed	0	0	0	f	2025-10-13 13:00:03.209652-05	2025-10-13 13:00:07.209148-05	dailyStatsJob	2025-10-13 18:00:00	00:15:00	2025-10-13 13:00:03.209652-05	2025-10-13 13:00:07.213543-05	2025-10-27 13:00:03.209652-05	f	\N
3ff19c21-68e7-4a29-bdc7-0c23516d2ab8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 14:07:03.581268-05	2025-10-13 14:09:11.014834-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:07:03.581268-05	2025-10-13 14:09:11.024604-05	2025-10-13 14:15:03.581268-05	f	\N
3b31e3bf-2d75-4c72-be4f-e31d2f78a6c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:01:01.211705-05	2025-10-13 13:01:03.222551-05	\N	2025-10-13 18:01:00	00:15:00	2025-10-13 13:00:03.211705-05	2025-10-13 13:01:03.235951-05	2025-10-13 13:02:01.211705-05	f	\N
2afab87f-af3a-4786-a4bb-97d5a72beee3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:04:49.493431-05	2025-10-13 17:04:53.482434-05	\N	2025-10-13 22:04:00	00:15:00	2025-10-13 17:04:49.493431-05	2025-10-13 17:04:53.496569-05	2025-10-13 17:05:49.493431-05	f	\N
e34a78df-aea0-405d-9d4e-960581c3fe50	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:11:44.329525-05	2025-10-13 15:12:44.291861-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:09:44.329525-05	2025-10-13 15:12:44.2995-05	2025-10-13 15:19:44.329525-05	f	\N
b4ac67d2-cd36-4596-8c95-e8bd659bb4a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:15:01.353387-05	2025-10-13 15:15:04.354927-05	\N	2025-10-13 20:15:00	00:15:00	2025-10-13 15:14:04.353387-05	2025-10-13 15:15:04.369059-05	2025-10-13 15:16:01.353387-05	f	\N
b4bc64df-edb2-4f33-84f6-8e7315e500ab	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:14:44.301717-05	2025-10-13 15:15:44.295718-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:12:44.301717-05	2025-10-13 15:15:44.303787-05	2025-10-13 15:22:44.301717-05	f	\N
55fd659e-0d7a-4dc8-96fa-e64b0101e24c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:54:01.685648-05	2025-10-13 06:54:05.673031-05	\N	2025-10-13 11:54:00	00:15:00	2025-10-13 06:53:09.685648-05	2025-10-13 06:54:05.686591-05	2025-10-13 06:55:01.685648-05	f	\N
8a78ec3f-5af8-42c8-a341-18932672a120	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 12:42:16.725618-05	2025-10-13 12:42:20.720435-05	\N	2025-10-13 17:42:00	00:15:00	2025-10-13 12:42:16.725618-05	2025-10-13 12:42:20.742612-05	2025-10-13 12:43:16.725618-05	f	\N
da92426c-3ada-4c80-87c0-003502f093dd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:23:44.308295-05	2025-10-13 15:24:44.302496-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:21:44.308295-05	2025-10-13 15:24:44.312833-05	2025-10-13 15:31:44.308295-05	f	\N
1e1f0a3b-1fb8-46b8-87aa-9b32e69c698e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:02:01.233572-05	2025-10-13 13:02:03.240052-05	\N	2025-10-13 18:02:00	00:15:00	2025-10-13 13:01:03.233572-05	2025-10-13 13:02:03.247402-05	2025-10-13 13:03:01.233572-05	f	\N
64a302bb-90d9-4080-914e-d32c0f24f165	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:09:11.014107-05	2025-10-13 14:09:15.009262-05	\N	2025-10-13 19:09:00	00:15:00	2025-10-13 14:09:11.014107-05	2025-10-13 14:09:15.017033-05	2025-10-13 14:10:11.014107-05	f	\N
16961604-61aa-43b6-9b84-ba4b5b6e7e77	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:17:01.376432-05	2025-10-13 15:17:04.38308-05	\N	2025-10-13 20:17:00	00:15:00	2025-10-13 15:16:04.376432-05	2025-10-13 15:17:04.394676-05	2025-10-13 15:18:01.376432-05	f	\N
28a07dcf-7141-4585-949c-82dc64af38fc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 13:03:35.044181-05	2025-10-13 13:03:49.854534-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 13:01:35.044181-05	2025-10-13 13:03:49.873057-05	2025-10-13 13:11:35.044181-05	f	\N
790009df-0f43-48ff-8298-0c4f02fea956	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:10:01.015875-05	2025-10-13 14:11:20.364897-05	\N	2025-10-13 19:10:00	00:15:00	2025-10-13 14:09:15.015875-05	2025-10-13 14:11:20.37779-05	2025-10-13 14:11:01.015875-05	f	\N
c77eb5e0-39cd-4631-a342-e97aca334336	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:04:01.258581-05	2025-10-13 13:11:08.727423-05	\N	2025-10-13 18:04:00	00:15:00	2025-10-13 13:03:03.258581-05	2025-10-13 13:11:08.744899-05	2025-10-13 13:05:01.258581-05	f	\N
6c6d58dc-7c98-4926-9e2d-68f98873ee0e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:04:49.497939-05	2025-10-13 17:05:52.823428-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:04:49.497939-05	2025-10-13 17:05:52.834493-05	2025-10-13 17:12:49.497939-05	f	\N
62b3b346-23ba-4d89-b0c4-4ca3683dbd25	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:17:44.304703-05	2025-10-13 15:18:44.298004-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:15:44.304703-05	2025-10-13 15:18:44.30464-05	2025-10-13 15:25:44.304703-05	f	\N
3b4aafa6-8ffb-45a4-ac80-a26ff1c8771a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:28:35.825407-05	2025-10-13 16:28:39.814489-05	\N	2025-10-13 21:28:00	00:15:00	2025-10-13 16:28:35.825407-05	2025-10-13 16:28:39.8208-05	2025-10-13 16:29:35.825407-05	f	\N
96ea0a53-ff1c-484e-8d29-e45fac3e421d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:20:01.421343-05	2025-10-13 15:20:04.421032-05	\N	2025-10-13 20:20:00	00:15:00	2025-10-13 15:19:04.421343-05	2025-10-13 15:20:04.433193-05	2025-10-13 15:21:01.421343-05	f	\N
4b0f5fad-0bd5-4462-acbf-3668cd21b591	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:21:01.431924-05	2025-10-13 15:21:04.434394-05	\N	2025-10-13 20:21:00	00:15:00	2025-10-13 15:20:04.431924-05	2025-10-13 15:21:04.443066-05	2025-10-13 15:22:01.431924-05	f	\N
5d534c13-68d6-4c93-8b7b-afa72d143c4f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 15:20:44.30616-05	2025-10-13 15:21:44.300342-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 15:18:44.30616-05	2025-10-13 15:21:44.306803-05	2025-10-13 15:28:44.30616-05	f	\N
b902060e-044e-4af8-bfc8-490a8093795c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:22:01.442175-05	2025-10-13 15:22:04.451211-05	\N	2025-10-13 20:22:00	00:15:00	2025-10-13 15:21:04.442175-05	2025-10-13 15:22:04.464854-05	2025-10-13 15:23:01.442175-05	f	\N
d4d6695a-6b70-46b5-962b-f51483734b76	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:03:01.246283-05	2025-10-13 13:03:03.250621-05	\N	2025-10-13 18:03:00	00:15:00	2025-10-13 13:02:03.246283-05	2025-10-13 13:03:03.259943-05	2025-10-13 13:04:01.246283-05	f	\N
eb5ee117-ef75-4161-a2f5-6877fedcbf73	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 06:53:09.686479-05	2025-10-13 06:54:09.659261-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 06:53:09.686479-05	2025-10-13 06:54:09.665098-05	2025-10-13 07:01:09.686479-05	f	\N
d7ffe83e-acbe-4626-b824-fcb7a8b233d2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 14:11:11.025917-05	2025-10-13 14:11:20.382046-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:09:11.025917-05	2025-10-13 14:11:20.389932-05	2025-10-13 14:19:11.025917-05	f	\N
c64fe940-f616-43dd-898d-ccc3db49b422	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:18:01.393491-05	2025-10-13 15:18:04.396633-05	\N	2025-10-13 20:18:00	00:15:00	2025-10-13 15:17:04.393491-05	2025-10-13 15:18:04.40738-05	2025-10-13 15:19:01.393491-05	f	\N
aadd437e-9ac0-49cb-ab92-7a04a7424318	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:11:20.375278-05	2025-10-13 14:11:24.36496-05	\N	2025-10-13 19:11:00	00:15:00	2025-10-13 14:11:20.375278-05	2025-10-13 14:11:24.379279-05	2025-10-13 14:12:20.375278-05	f	\N
dc668d75-d4ea-4688-89b4-ef0d8419a46a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 15:19:01.406272-05	2025-10-13 15:19:04.410857-05	\N	2025-10-13 20:19:00	00:15:00	2025-10-13 15:18:04.406272-05	2025-10-13 15:19:04.422288-05	2025-10-13 15:20:01.406272-05	f	\N
b02aaf0e-61b1-47a7-bb5a-68e117875d36	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:05:01.494936-05	2025-10-13 17:05:05.486679-05	\N	2025-10-13 22:05:00	00:15:00	2025-10-13 17:04:53.494936-05	2025-10-13 17:05:05.496896-05	2025-10-13 17:06:01.494936-05	f	\N
4f792805-28dd-4418-b844-d68c65208141	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:20:01.209794-05	2025-10-13 16:28:35.814698-05	\N	2025-10-13 21:20:00	00:15:00	2025-10-13 16:19:10.209794-05	2025-10-13 16:28:35.827031-05	2025-10-13 16:21:01.209794-05	f	\N
fb2ddfed-9730-4f11-aa20-19ce8031e46d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:06:01.495478-05	2025-10-13 17:06:04.821351-05	\N	2025-10-13 22:06:00	00:15:00	2025-10-13 17:05:05.495478-05	2025-10-13 17:06:04.834244-05	2025-10-13 17:07:01.495478-05	f	\N
df2c33ce-a3c8-40f6-84ed-366ba7d6452b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 14:13:20.391205-05	2025-10-13 14:14:23.978469-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:11:20.391205-05	2025-10-13 14:14:23.984497-05	2025-10-13 14:21:20.391205-05	f	\N
27287d7a-4b4c-45a4-b88b-502f3135d95f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:07:52.835595-05	2025-10-13 17:08:52.820409-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:05:52.835595-05	2025-10-13 17:08:52.828276-05	2025-10-13 17:15:52.835595-05	f	\N
5d273ce1-4252-400d-ba31-125eb8d9494f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:11:08.741866-05	2025-10-13 13:11:12.728779-05	\N	2025-10-13 18:11:00	00:15:00	2025-10-13 13:11:08.741866-05	2025-10-13 13:11:12.749723-05	2025-10-13 13:12:08.741866-05	f	\N
c699755a-baf4-4654-b68c-12aa06422eb1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:12:01.377731-05	2025-10-13 14:14:23.924885-05	\N	2025-10-13 19:12:00	00:15:00	2025-10-13 14:11:24.377731-05	2025-10-13 14:14:23.980126-05	2025-10-13 14:13:01.377731-05	f	\N
f204afd6-6424-4b78-aaf5-4c49a4519283	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:07:01.832479-05	2025-10-13 17:07:04.835622-05	\N	2025-10-13 22:07:00	00:15:00	2025-10-13 17:06:04.832479-05	2025-10-13 17:07:04.849859-05	2025-10-13 17:08:01.832479-05	f	\N
3082d365-a3dc-4ba2-ab3c-76a34a42707c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:29:01.819921-05	2025-10-13 16:33:28.522992-05	\N	2025-10-13 21:29:00	00:15:00	2025-10-13 16:28:39.819921-05	2025-10-13 16:33:28.587691-05	2025-10-13 16:30:01.819921-05	f	\N
411cebe2-955d-432f-9787-a5efdf9e192c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:33:28.587196-05	2025-10-13 16:33:32.524623-05	\N	2025-10-13 21:33:00	00:15:00	2025-10-13 16:33:28.587196-05	2025-10-13 16:33:32.531288-05	2025-10-13 16:34:28.587196-05	f	\N
1e4db705-0e4e-4891-b942-1210539cbbe5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 16:33:28.588308-05	2025-10-13 16:34:28.52651-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 16:33:28.588308-05	2025-10-13 16:34:28.530633-05	2025-10-13 16:41:28.588308-05	f	\N
ed5ab228-f154-4add-83d2-678d3febb536	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:08:01.847792-05	2025-10-13 17:08:04.850192-05	\N	2025-10-13 22:08:00	00:15:00	2025-10-13 17:07:04.847792-05	2025-10-13 17:08:04.864541-05	2025-10-13 17:09:01.847792-05	f	\N
78885cbf-cab0-47a5-8cc3-c0cdc3224ba4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 13:11:08.763553-05	2025-10-13 13:14:25.815797-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 13:11:08.763553-05	2025-10-13 13:14:25.830552-05	2025-10-13 13:19:08.763553-05	f	\N
833269a9-1358-4779-98a7-15e750a3c132	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:14:23.978721-05	2025-10-13 14:14:27.923854-05	\N	2025-10-13 19:14:00	00:15:00	2025-10-13 14:14:23.978721-05	2025-10-13 14:14:27.931586-05	2025-10-13 14:15:23.978721-05	f	\N
8f3d191f-e19f-4a7b-a0a2-2e62a2256704	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:14:25.817213-05	2025-10-13 13:14:25.827656-05	\N	2025-10-13 18:14:00	00:15:00	2025-10-13 13:14:25.817213-05	2025-10-13 13:14:25.840012-05	2025-10-13 13:15:25.817213-05	f	\N
5ae68760-7e6d-4cde-adfa-38db50fde8a3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:15:01.930351-05	2025-10-13 14:17:05.801631-05	\N	2025-10-13 19:15:00	00:15:00	2025-10-13 14:14:27.930351-05	2025-10-13 14:17:05.814146-05	2025-10-13 14:16:01.930351-05	f	\N
bb866aa1-ebcb-4cdc-89c1-dd49202ad825	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:34:01.53057-05	2025-10-13 16:34:25.686485-05	\N	2025-10-13 21:34:00	00:15:00	2025-10-13 16:33:32.53057-05	2025-10-13 16:34:25.691873-05	2025-10-13 16:35:01.53057-05	f	\N
116ebb0a-52a3-46b3-853e-f9d457909f8b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:12:01.747284-05	2025-10-13 13:12:05.64983-05	\N	2025-10-13 18:12:00	00:15:00	2025-10-13 13:11:12.747284-05	2025-10-13 13:12:05.665459-05	2025-10-13 13:13:01.747284-05	f	\N
5890b745-d50b-4f31-aa0b-8c36bd2628e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 14:16:23.985429-05	2025-10-13 14:17:05.822207-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 14:14:23.985429-05	2025-10-13 14:17:05.836737-05	2025-10-13 14:24:23.985429-05	f	\N
504a36f6-d67d-4e52-8c39-287982ea0df1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:17:05.81217-05	2025-10-13 14:17:09.803563-05	\N	2025-10-13 19:17:00	00:15:00	2025-10-13 14:17:05.81217-05	2025-10-13 14:17:09.819061-05	2025-10-13 14:18:05.81217-05	f	\N
e71198b0-369f-4f7e-8768-f209647de1af	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:09:01.862221-05	2025-10-13 17:09:04.864853-05	\N	2025-10-13 22:09:00	00:15:00	2025-10-13 17:08:04.862221-05	2025-10-13 17:09:04.879469-05	2025-10-13 17:10:01.862221-05	f	\N
0dda164e-a4a1-4c29-bfde-6710db80b151	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:10:52.830785-05	2025-10-13 17:11:52.823096-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:08:52.830785-05	2025-10-13 17:11:52.833052-05	2025-10-13 17:18:52.830785-05	f	\N
63a08ee5-f359-4d60-ba3f-394dc5896481	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:10:01.876659-05	2025-10-13 17:10:04.88112-05	\N	2025-10-13 22:10:00	00:15:00	2025-10-13 17:09:04.876659-05	2025-10-13 17:10:04.89034-05	2025-10-13 17:11:01.876659-05	f	\N
261700f2-2eb9-4b70-80fc-ca5c5b40a24d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:35:01.691135-05	2025-10-13 16:40:19.604688-05	\N	2025-10-13 21:35:00	00:15:00	2025-10-13 16:34:25.691135-05	2025-10-13 16:40:19.613456-05	2025-10-13 16:36:01.691135-05	f	\N
bc7e7ef0-e1db-433f-ad04-039254560cc4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:40:19.612263-05	2025-10-13 16:40:23.606539-05	\N	2025-10-13 21:40:00	00:15:00	2025-10-13 16:40:19.612263-05	2025-10-13 16:40:23.622286-05	2025-10-13 16:41:19.612263-05	f	\N
e3e6317d-fe01-4031-889e-dac87edb6788	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:11:01.888051-05	2025-10-13 17:11:04.893154-05	\N	2025-10-13 22:11:00	00:15:00	2025-10-13 17:10:04.888051-05	2025-10-13 17:11:04.904084-05	2025-10-13 17:12:01.888051-05	f	\N
f10554b2-59c8-4364-a6a7-bf06903f4b05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:18:01.817258-05	2025-10-13 14:33:25.744803-05	\N	2025-10-13 19:18:00	00:15:00	2025-10-13 14:17:09.817258-05	2025-10-13 14:33:25.753824-05	2025-10-13 14:19:01.817258-05	f	\N
17e88987-6fd3-4ccc-b33c-58d9a541e92d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:12:01.901853-05	2025-10-13 17:12:04.906965-05	\N	2025-10-13 22:12:00	00:15:00	2025-10-13 17:11:04.901853-05	2025-10-13 17:12:04.917667-05	2025-10-13 17:13:01.901853-05	f	\N
574b6825-f97b-4738-b3aa-99957cf9310e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:33:25.747237-05	2025-10-13 14:33:29.683504-05	\N	2025-10-13 19:33:00	00:15:00	2025-10-13 14:33:25.747237-05	2025-10-13 14:33:29.694751-05	2025-10-13 14:34:25.747237-05	f	\N
047edf15-ae8f-42b4-a1d9-5e34e181bb1f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:41:01.620648-05	2025-10-13 16:41:05.82685-05	\N	2025-10-13 21:41:00	00:15:00	2025-10-13 16:40:23.620648-05	2025-10-13 16:41:05.841931-05	2025-10-13 16:42:01.620648-05	f	\N
0c66054a-5fb8-422a-ad30-c30fb7de9d41	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 16:40:19.620405-05	2025-10-13 16:42:01.693137-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 16:40:19.620405-05	2025-10-13 16:42:01.704808-05	2025-10-13 16:48:19.620405-05	f	\N
d5fd301f-0231-4a5c-aea4-180a3935099f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:14:01.930127-05	2025-10-13 17:14:04.938334-05	\N	2025-10-13 22:14:00	00:15:00	2025-10-13 17:13:04.930127-05	2025-10-13 17:14:04.949744-05	2025-10-13 17:15:01.930127-05	f	\N
81252260-84bd-45bb-9e14-04c49145d695	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:15:01.947843-05	2025-10-13 17:15:04.960604-05	\N	2025-10-13 22:15:00	00:15:00	2025-10-13 17:14:04.947843-05	2025-10-13 17:15:04.973487-05	2025-10-13 17:16:01.947843-05	f	\N
6b3050e3-5983-45ce-9bd3-26a5ead7f523	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 16:42:01.839547-05	2025-10-13 16:42:05.684002-05	\N	2025-10-13 21:42:00	00:15:00	2025-10-13 16:41:05.839547-05	2025-10-13 16:42:05.695224-05	2025-10-13 16:43:01.839547-05	f	\N
acb8be6d-f570-4720-b66c-ee2256627f12	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:16:52.828545-05	2025-10-13 17:17:52.823862-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:14:52.828545-05	2025-10-13 17:17:52.832852-05	2025-10-13 17:24:52.828545-05	f	\N
b06a1548-e647-4561-94ec-5a582b6b5d58	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 17:13:01.916649-05	2025-10-13 17:13:04.920709-05	\N	2025-10-13 22:13:00	00:15:00	2025-10-13 17:12:04.916649-05	2025-10-13 17:13:04.932059-05	2025-10-13 17:14:01.916649-05	f	\N
003a10a4-7489-4142-a35f-609ced22c1a8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-10-13 17:13:52.835053-05	2025-10-13 17:14:52.821882-05	__pgboss__maintenance	\N	00:15:00	2025-10-13 17:11:52.835053-05	2025-10-13 17:14:52.827407-05	2025-10-13 17:21:52.835053-05	f	\N
0d40cf4b-b353-47b6-808b-e9a4c9a8a609	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:15:01.839089-05	2025-10-13 13:15:29.28806-05	\N	2025-10-13 18:15:00	00:15:00	2025-10-13 13:14:25.839089-05	2025-10-13 13:15:29.295092-05	2025-10-13 13:16:01.839089-05	f	\N
91c13818-1e3a-4b0b-8469-b5089d4a8ae6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 13:16:01.294032-05	2025-10-13 13:20:23.468408-05	\N	2025-10-13 18:16:00	00:15:00	2025-10-13 13:15:29.294032-05	2025-10-13 13:20:23.482187-05	2025-10-13 13:17:01.294032-05	f	\N
1c183448-6963-48bc-8f14-8e48b25bf078	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:34:01.752927-05	2025-10-13 14:41:11.68944-05	\N	2025-10-13 19:34:00	00:15:00	2025-10-13 14:33:25.752927-05	2025-10-13 14:41:11.700226-05	2025-10-13 14:35:01.752927-05	f	\N
59a39e81-d42a-48fa-8c60-c03aaeca3453	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 14:41:11.69876-05	2025-10-13 14:41:15.674819-05	\N	2025-10-13 19:41:00	00:15:00	2025-10-13 14:41:11.69876-05	2025-10-13 14:41:15.690048-05	2025-10-13 14:42:11.69876-05	f	\N
a023d798-8e2a-4370-bb6e-a415fd45a081	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:47:01.769123-05	2025-10-13 06:47:01.777615-05	\N	2025-10-13 11:47:00	00:15:00	2025-10-13 06:46:01.769123-05	2025-10-13 06:47:01.785679-05	2025-10-13 06:48:01.769123-05	f	\N
674cc9e0-2472-4564-82a2-5f12fea5f825	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:48:01.784654-05	2025-10-13 06:48:01.790647-05	\N	2025-10-13 11:48:00	00:15:00	2025-10-13 06:47:01.784654-05	2025-10-13 06:48:01.801157-05	2025-10-13 06:49:01.784654-05	f	\N
b89c8cd3-2773-4862-8bcc-a3a68ef26e4a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:49:01.799515-05	2025-10-13 06:49:01.803045-05	\N	2025-10-13 11:49:00	00:15:00	2025-10-13 06:48:01.799515-05	2025-10-13 06:49:01.815396-05	2025-10-13 06:50:01.799515-05	f	\N
979cf494-e4ce-48ac-b382-553b5f345192	__pgboss__cron	0	\N	completed	2	0	0	f	2025-10-13 06:55:01.685239-05	2025-10-13 12:42:16.719062-05	\N	2025-10-13 11:55:00	00:15:00	2025-10-13 06:54:05.685239-05	2025-10-13 12:42:16.723276-05	2025-10-13 06:56:01.685239-05	f	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
dailyStatsJob	0 * * * *	UTC	\N	{}	2025-10-01 22:45:28.99421-05	2025-10-13 15:07:20.290187-05
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2025-10-13 18:45:46.629056-05	2025-10-13 18:47:02.632756-05
\.


--
-- Data for Name: ApprovalAction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ApprovalAction" (id, "createdAt", "userId", "purchaseOrderId", "stepNumber", action, comment, "ipAddress", "userAgent") FROM stdin;
47828564-f1ec-40c3-a5d2-af6f1495d28a	2025-10-12 22:25:17.858	6375367a-ae0e-4f05-88ac-040d269cd9e9	d300786e-078e-4a0d-afdf-a276f88e9d20	1	APPROVED	\N	\N	\N
51db8f4f-6afb-4203-9f48-02824a96d334	2025-10-12 22:26:35.266	9eb28b8e-8b2c-4df2-9808-36e6007a4b7f	d300786e-078e-4a0d-afdf-a276f88e9d20	2	APPROVED	\N	\N	\N
bae3b61f-993b-4901-908c-ff39419519c7	2025-10-12 22:26:57.091	8a9784c7-caf5-4215-a65a-ce76b6b6307d	d300786e-078e-4a0d-afdf-a276f88e9d20	3	APPROVED	\N	\N	\N
\.


--
-- Data for Name: ApprovalStep; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ApprovalStep" (id, "createdAt", "updatedAt", "purchaseOrderId", "stepNumber", "stepName", "requiredRole", status, "approvedById", "approvedAt", comment, "notificationSentAt") FROM stdin;
3d02de1b-f59c-449a-bdf6-fa3544061399	2025-10-12 22:19:55.642	2025-10-12 22:25:17.856	d300786e-078e-4a0d-afdf-a276f88e9d20	1	Property Manager	PROPERTY_MANAGER	APPROVED	6375367a-ae0e-4f05-88ac-040d269cd9e9	2025-10-12 22:25:17.855	\N	\N
3e922a0a-0803-4ad2-aefc-52b358fd1c8f	2025-10-12 22:19:55.642	2025-10-12 22:26:57.089	d300786e-078e-4a0d-afdf-a276f88e9d20	3	Corporate	CORPORATE	APPROVED	8a9784c7-caf5-4215-a65a-ce76b6b6307d	2025-10-12 22:26:57.089	\N	\N
a3e3260a-43aa-41e4-be47-a0cf22c035e9	2025-10-13 22:13:45.537	2025-10-13 22:13:45.537	5ceeae0b-4bff-43ed-a442-6096dcf53328	1	Property Manager	PROPERTY_MANAGER	PENDING	\N	\N	\N	\N
239b11df-03ff-484d-8824-fd82477e3647	2025-10-13 22:13:45.537	2025-10-13 22:13:45.537	5ceeae0b-4bff-43ed-a442-6096dcf53328	2	Accounting	ACCOUNTING	PENDING	\N	\N	\N	\N
16c55724-1859-4965-89af-3aa28f5bc8f6	2025-10-13 22:13:45.537	2025-10-13 22:13:45.537	5ceeae0b-4bff-43ed-a442-6096dcf53328	3	Corporate	CORPORATE	PENDING	\N	\N	\N	\N
dc875614-3438-46b8-be7d-50143bc8d95b	2025-10-12 22:19:55.642	2025-10-12 22:26:35.264	d300786e-078e-4a0d-afdf-a276f88e9d20	2	Accounting	ACCOUNTING	APPROVED	9eb28b8e-8b2c-4df2-9808-36e6007a4b7f	2025-10-12 22:26:35.263	\N	\N
\.


--
-- Data for Name: Auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Auth" (id, "userId") FROM stdin;
d990a4d4-b7a3-44c7-9dec-c6aab935ad5e	6375367a-ae0e-4f05-88ac-040d269cd9e9
cac4a631-3c47-4e61-b53d-0a9db4ab1816	61eacdc7-6ed8-4a91-a79d-0edc0aac14ff
eb171945-7d49-4851-b04f-6142097088f3	9eb28b8e-8b2c-4df2-9808-36e6007a4b7f
b0fcd905-359c-4eaa-8727-a70a28ce44fb	8a9784c7-caf5-4215-a65a-ce76b6b6307d
\.


--
-- Data for Name: AuthIdentity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AuthIdentity" ("providerName", "providerUserId", "providerData", "authId") FROM stdin;
email	admin@demo.com	{"hashedPassword": "$argon2id$v=19$m=19456,t=2,p=1$nOPWbsnDlM40yn8x/9kvwQ$aDypzEnPh+SAhmG/vCaOQDUNU3Hg0Fs08WzfMCXK15w", "isEmailVerified": true, "passwordResetSentAt": null, "emailVerificationSentAt": "2025-10-12T22:01:48.687Z"}	d990a4d4-b7a3-44c7-9dec-c6aab935ad5e
email	pm@demo.com	{"hashedPassword": "$argon2id$v=19$m=19456,t=2,p=1$Z40gEl3tVuVOTilpEkvHnA$Oa8K/ErT1o49sCAy7cGbB6R9TYeK+rixzx1n1gK+taM", "isEmailVerified": true, "passwordResetSentAt": null, "emailVerificationSentAt": "2025-10-12T22:02:03.951Z"}	cac4a631-3c47-4e61-b53d-0a9db4ab1816
email	accounting@demo.com	{"hashedPassword": "$argon2id$v=19$m=19456,t=2,p=1$V3gRIUw6MPUiLOWGc+w7Jg$tSyZAxVKpbdBfUcZKow556hdU85ZEigYC9N3HlJgWd0", "isEmailVerified": true, "passwordResetSentAt": null, "emailVerificationSentAt": "2025-10-12T22:02:15.604Z"}	eb171945-7d49-4851-b04f-6142097088f3
email	corporate@demo.com	{"hashedPassword": "$argon2id$v=19$m=19456,t=2,p=1$71U7jfY+q6ArEPV5DnUNCQ$p5C3TcA9BAs4/xIyL9HpZEm+fe5Pu9NugIINcJ4h1cA", "isEmailVerified": true, "passwordResetSentAt": null, "emailVerificationSentAt": "2025-10-12T22:02:29.573Z"}	b0fcd905-359c-4eaa-8727-a70a28ce44fb
\.


--
-- Data for Name: ContactFormMessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactFormMessage" (id, "createdAt", "userId", content, "isRead", "repliedAt") FROM stdin;
\.


--
-- Data for Name: DailyStats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DailyStats" (id, date, "totalViews", "prevDayViewsChangePercent", "userCount", "paidUserCount", "userDelta", "paidUserDelta", "totalRevenue", "totalProfit") FROM stdin;
\.


--
-- Data for Name: ExpenseType; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ExpenseType" (id, "createdAt", "updatedAt", "organizationId", name, code, "isActive") FROM stdin;
84d9159b-7349-4f1b-bbac-6a6a1a610796	2025-10-12 22:07:20.881	2025-10-12 22:07:20.881	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	Capital Expense	CAPEX	t
b6524511-4786-419c-b44c-cd02e06a357d	2025-10-12 22:07:20.881	2025-10-12 22:07:20.881	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	Operating Expense	OPEX	t
013026a8-e0bb-470a-be72-c07ae9e099fe	2025-10-12 22:07:20.881	2025-10-12 22:07:20.881	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	Maintenance	MAINT	t
\.


--
-- Data for Name: File; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."File" (id, "createdAt", "userId", name, type, key, "uploadUrl") FROM stdin;
\.


--
-- Data for Name: GLAccount; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GLAccount" (id, "createdAt", "updatedAt", "organizationId", "accountNumber", name, "accountType", "isActive", "annualBudget") FROM stdin;
e65d54f0-a8f2-4e1f-924f-175aee1a08cc	2025-10-12 22:07:20.873	2025-10-12 22:07:20.873	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	7556	Paint & Sheetrock - Interior	EXPENSE	t	75000
0cb3a57c-42d8-4eb3-8396-f06c4844a611	2025-10-12 22:07:20.873	2025-10-12 22:07:20.873	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	7594	Resurface	EXPENSE	t	100000
cec32a9b-05fc-466a-86b3-5cdf1924b5df	2025-10-12 22:07:20.873	2025-10-12 22:07:20.873	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	7582	Other Interior Replacement	EXPENSE	t	30000
1fdecb97-9f89-4385-ace8-2dcae4528ce9	2025-10-12 22:07:20.873	2025-10-12 22:07:20.873	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6770	Paint & Supplies (Expense)	EXPENSE	t	25000
97a6015b-7f18-4af8-9318-cd5eeac3e615	2025-10-13 22:11:36.767	2025-10-13 22:11:36.767	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	8888	MISC	EXPENSE	t	20000
8d82507b-f571-4eaf-b117-50fa6c75990f	2025-10-12 22:07:20.872	2025-10-12 22:07:20.872	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	7520	Doors Replacement	EXPENSE	t	50000
\.


--
-- Data for Name: GptResponse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GptResponse" (id, "createdAt", "updatedAt", "userId", content) FROM stdin;
\.


--
-- Data for Name: Invoice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Invoice" (id, "createdAt", "updatedAt", "userId", "fileName", "fileSize", "fileUrl", "mimeType", status, "ocrText", "ocrConfidence", "ocrProcessedAt", "structuredData", "llmProcessedAt", "vendorName", "invoiceNumber", "invoiceDate", "totalAmount", currency, "errorMessage", "failedAt") FROM stdin;
e9f64498-592a-429e-8ef3-6983adfa8fc1	2025-10-12 22:43:17.377	2025-10-12 22:43:17.377	6375367a-ae0e-4f05-88ac-040d269cd9e9	Manual Invoice INV-001	0		application/manual	COMPLETED	\N	\N	\N	{"dueDate": "2025-10-15", "subtotal": 86, "taxAmount": 0, "description": "aise hi"}	\N	H1	INV-001	2025-10-12 00:00:00	86	USD	\N	\N
5c0df8d2-61b9-40f9-8019-7c804207351e	2025-10-12 22:49:41.416	2025-10-12 22:49:41.416	6375367a-ae0e-4f05-88ac-040d269cd9e9	Manual Invoice INV-002	0		application/manual	COMPLETED	\N	\N	\N	{"dueDate": "2025-10-22", "subtotal": 899.62, "taxAmount": 0, "description": "gulla"}	\N	halla	INV-002	2025-10-12 00:00:00	899.62	USD	\N	\N
393a9fca-7f83-48fe-ac2c-b1f119eff073	2025-10-13 17:49:36.538	2025-10-13 17:49:36.538	6375367a-ae0e-4f05-88ac-040d269cd9e9	MANUAL-INV_TEST_001	0		application/manual	UPLOADED	\N	\N	\N	{"dueDate": "2025-10-16", "subtotal": 100, "taxAmount": 0, "description": "halla", "paymentStatus": "PENDING"}	\N	halla	INV_TEST_001	2025-10-13 00:00:00	100	USD	\N	\N
c2ad4b58-3730-49f4-b978-76a0d468c7b8	2025-10-13 17:59:01.087	2025-10-13 17:59:01.087	6375367a-ae0e-4f05-88ac-040d269cd9e9	1565.pdf	49675	https://storage.googleapis.com/invoice-processor-uploads/invoices/1760378317162-1565.pdf	application/pdf	UPLOADED	\N	\N	\N	{"dueDate": "2025-10-23", "subtotal": 25, "taxAmount": 0, "description": "halla", "paymentStatus": "PENDING"}	\N	halla	INV_TEST_002	2025-10-13 00:00:00	25	USD	\N	\N
84a7f288-2017-4281-b980-7e036407893a	2025-10-13 18:00:01.579	2025-10-13 18:00:01.579	6375367a-ae0e-4f05-88ac-040d269cd9e9	1553.pdf	17571	https://storage.googleapis.com/invoice-processor-uploads/invoices/1760378367298-1553.pdf	application/pdf	UPLOADED	\N	\N	\N	{"dueDate": "2025-10-15", "subtotal": 30, "taxAmount": 0, "description": "h", "paymentStatus": "PENDING"}	\N	h	INV9	2025-10-13 00:00:00	30	USD	\N	\N
4adad1eb-6f5f-4837-917f-bf0735c91c01	2025-10-13 18:01:18.562	2025-10-13 18:01:18.562	6375367a-ae0e-4f05-88ac-040d269cd9e9	MANUAL-INV10	0		application/manual	UPLOADED	\N	\N	\N	{"dueDate": "2025-10-23", "subtotal": 209, "taxAmount": 0, "description": "hey", "paymentStatus": "PENDING"}	\N	h	INV10	2025-10-13 00:00:00	209	USD	\N	\N
\.


--
-- Data for Name: InvoiceLineItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."InvoiceLineItem" (id, "createdAt", "invoiceId", description, quantity, "unitPrice", amount, "taxAmount", category, "lineNumber") FROM stdin;
e49fd9b3-94e8-49d9-bed2-ecbba092ecb7	2025-10-12 22:43:17.377	e9f64498-592a-429e-8ef3-6983adfa8fc1	jalebi	1	10	10	\N	\N	1
0d6bfb08-88aa-4415-bae2-6743e531a7e5	2025-10-12 22:43:17.377	e9f64498-592a-429e-8ef3-6983adfa8fc1	samosa	19	4	76	\N	\N	2
2858d2b1-4d94-434c-9e20-c2d2fcdc3c57	2025-10-12 22:49:41.416	5c0df8d2-61b9-40f9-8019-7c804207351e	halla gulla	1	699.62	699.62	\N	\N	1
083b3cc7-f763-4422-8548-aa460808b6cb	2025-10-12 22:49:41.416	5c0df8d2-61b9-40f9-8019-7c804207351e	aise hi	10	20	200	\N	\N	2
ff8419cd-36f3-4698-ab3d-38ff464d00b3	2025-10-13 17:49:36.542	393a9fca-7f83-48fe-ac2c-b1f119eff073	jalebi	1	100	100	0	\N	1
a86132c4-7e52-40b9-8e82-95535af706b6	2025-10-13 17:59:01.09	c2ad4b58-3730-49f4-b978-76a0d468c7b8	samos	1	25	25	0	\N	1
d7f37c86-89b1-4cb9-82d4-abe92926a4ce	2025-10-13 18:00:01.581	84a7f288-2017-4281-b980-7e036407893a	gd	1	10	10	0	\N	1
02fbb5f7-ac86-46c1-9e1c-ea01068ae1cd	2025-10-13 18:00:01.582	84a7f288-2017-4281-b980-7e036407893a	as	1	20	20	0	\N	2
d917f453-b4f4-4b77-8590-443a9f35c346	2025-10-13 18:01:18.564	4adad1eb-6f5f-4837-917f-bf0735c91c01	hey	1	209	209	0	\N	1
\.


--
-- Data for Name: Logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs" (id, "createdAt", message, level) FROM stdin;
1	2025-10-12 23:00:06.998	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
2	2025-10-13 00:00:09.555	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
3	2025-10-13 01:00:06.813	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
4	2025-10-13 02:00:08.265	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
5	2025-10-13 03:00:09.543	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
6	2025-10-13 04:00:06.865	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
7	2025-10-13 05:00:08.317	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
8	2025-10-13 06:00:07.617	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
9	2025-10-13 07:00:08.959	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
10	2025-10-13 08:00:10.289	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
11	2025-10-13 09:00:07.552	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
12	2025-10-13 10:00:08.874	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
13	2025-10-13 11:00:09.016	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
14	2025-10-13 18:00:07.612	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
15	2025-10-13 20:00:06.988	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
16	2025-10-13 21:05:00.51	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
17	2025-10-13 23:00:07.033	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
\.


--
-- Data for Name: Notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Notification" (id, "createdAt", "updatedAt", "userId", type, title, message, "actionUrl", "purchaseOrderId", "invoiceId", read, "readAt", "emailSent", "emailSentAt", "smsSent", "smsSentAt") FROM stdin;
8e23a0dd-0faa-4289-ac3e-88e0702e4cc2	2025-10-12 22:26:57.094	2025-10-12 22:26:57.094	6375367a-ae0e-4f05-88ac-040d269cd9e9	PO_APPROVED	Purchase Order Approved	Purchase order #2004 has been fully approved	\N	d300786e-078e-4a0d-afdf-a276f88e9d20	\N	f	\N	f	\N	f	\N
\.


--
-- Data for Name: Organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Organization" (id, "createdAt", "updatedAt", name, code, "poApprovalThreshold") FROM stdin;
eed36e5c-4364-4a8b-acd6-580e02ddbfdf	2025-10-12 22:07:20.849	2025-10-12 22:07:20.849	Demo Organization	DEMO-ORG	500
\.


--
-- Data for Name: POLineItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."POLineItem" (id, "createdAt", "updatedAt", "purchaseOrderId", "lineNumber", description, "propertyId", "glAccountId", quantity, "unitPrice", "taxAmount", "totalAmount") FROM stdin;
7e9a485b-244a-428d-a558-33044780fd59	2025-10-12 22:19:54.181	2025-10-12 22:19:54.181	70253ee8-f09a-4f60-962a-ea5ba18ddb3f	1	halla gulla	f0fad37c-962f-4f91-a83b-085c9f6af3a4	0cb3a57c-42d8-4eb3-8396-f06c4844a611	1	999.62	0	999.62
14397e8a-6180-44d8-a42e-188f91bf544a	2025-10-12 22:19:54.203	2025-10-12 22:19:54.203	52c9c162-5eb9-4425-a5d7-872c3072c825	1	halla gulla	f0fad37c-962f-4f91-a83b-085c9f6af3a4	0cb3a57c-42d8-4eb3-8396-f06c4844a611	1	999.62	0	999.62
07ff43da-6caa-4226-bd88-6f6b09a0406c	2025-10-12 22:19:55.621	2025-10-12 22:19:55.621	ce5a342c-927b-4e44-8f54-a319c6f8d806	1	halla gulla	f0fad37c-962f-4f91-a83b-085c9f6af3a4	0cb3a57c-42d8-4eb3-8396-f06c4844a611	1	999.62	0	999.62
1f7f092c-cdd6-42ca-a4ce-0786743f540e	2025-10-12 22:19:55.637	2025-10-12 22:19:55.637	d300786e-078e-4a0d-afdf-a276f88e9d20	1	halla gulla	f0fad37c-962f-4f91-a83b-085c9f6af3a4	0cb3a57c-42d8-4eb3-8396-f06c4844a611	1	999.62	0	999.62
4e939ea2-1368-48b8-86a1-e94d8cd6b339	2025-10-13 22:13:45.518	2025-10-13 22:13:45.518	5ceeae0b-4bff-43ed-a442-6096dcf53328	1	jalebi	af05363e-5e2c-4437-ac0e-c525355d3468	97a6015b-7f18-4af8-9318-cd5eeac3e615	1	10	0	10
46dafae1-96e5-46d6-add2-f52277d18f47	2025-10-13 22:13:45.518	2025-10-13 22:13:45.518	5ceeae0b-4bff-43ed-a442-6096dcf53328	2	samosa	af05363e-5e2c-4437-ac0e-c525355d3468	97a6015b-7f18-4af8-9318-cd5eeac3e615	1000	10	0	10000
\.


--
-- Data for Name: PageViewSource; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PageViewSource" (name, date, "dailyStatsId", visitors) FROM stdin;
\.


--
-- Data for Name: ProcessingJob; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ProcessingJob" (id, "createdAt", "updatedAt", "invoiceId", status, "currentStep", attempts, "maxAttempts", "startedAt", "completedAt", "errorLog", "lastError") FROM stdin;
\.


--
-- Data for Name: Property; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Property" (id, "createdAt", "updatedAt", "organizationId", code, name, address, "isActive") FROM stdin;
f0fad37c-962f-4f91-a83b-085c9f6af3a4	2025-10-12 22:07:20.862	2025-10-12 22:07:20.862	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	MW-1007	Maxton West Apartment - Unit 1007	123 Main St, Unit 1007	t
141de2cc-9b69-4cb1-9e8b-c2d7566c937d	2025-10-12 22:07:20.862	2025-10-12 22:07:20.862	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	MWA	Maxton West Apartment - Common Area	123 Main St, Common Area	t
af05363e-5e2c-4437-ac0e-c525355d3468	2025-10-13 22:10:35.984	2025-10-13 22:10:35.984	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	ANDA	BINDA		t
\.


--
-- Data for Name: PurchaseOrder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PurchaseOrder" (id, "createdAt", "updatedAt", "organizationId", "createdById", "poNumber", vendor, description, "expenseTypeId", "poDate", status, subtotal, "taxAmount", "totalAmount", "isTemplate", "templateName", "requiresApproval", "currentApprovalStep", "linkedInvoiceId") FROM stdin;
70253ee8-f09a-4f60-962a-ea5ba18ddb3f	2025-10-12 22:19:54.181	2025-10-12 22:19:54.181	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6375367a-ae0e-4f05-88ac-040d269cd9e9	2001	halla	gulla	84d9159b-7349-4f1b-bbac-6a6a1a610796	2025-10-12 22:19:54.18	DRAFT	999.62	0	999.62	t	halla gulla	t	\N	\N
52c9c162-5eb9-4425-a5d7-872c3072c825	2025-10-12 22:19:54.203	2025-10-12 22:19:54.203	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6375367a-ae0e-4f05-88ac-040d269cd9e9	2002	halla	gulla	84d9159b-7349-4f1b-bbac-6a6a1a610796	2025-10-12 22:19:54.202	DRAFT	999.62	0	999.62	f	\N	t	\N	\N
ce5a342c-927b-4e44-8f54-a319c6f8d806	2025-10-12 22:19:55.621	2025-10-12 22:19:55.621	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6375367a-ae0e-4f05-88ac-040d269cd9e9	2003	halla	gulla	84d9159b-7349-4f1b-bbac-6a6a1a610796	2025-10-12 22:19:55.621	DRAFT	999.62	0	999.62	t	halla gulla	t	\N	\N
d300786e-078e-4a0d-afdf-a276f88e9d20	2025-10-12 22:19:55.637	2025-10-12 22:49:41.42	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6375367a-ae0e-4f05-88ac-040d269cd9e9	2004	halla	gulla	84d9159b-7349-4f1b-bbac-6a6a1a610796	2025-10-12 22:19:55.636	INVOICED	999.62	0	999.62	f	\N	t	\N	5c0df8d2-61b9-40f9-8019-7c804207351e
5ceeae0b-4bff-43ed-a442-6096dcf53328	2025-10-13 22:13:45.518	2025-10-13 22:13:45.547	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	6375367a-ae0e-4f05-88ac-040d269cd9e9	2005	halla	trial	013026a8-e0bb-470a-be72-c07ae9e099fe	2025-10-13 22:13:45.517	PENDING_APPROVAL	10010	0	10010	f	\N	t	1	\N
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Session" (id, "expiresAt", "userId") FROM stdin;
cw7pu6djzmdr5ivvk7vzwgoeh2or4tlohshjaeu5	2025-11-11 22:19:07.826	d990a4d4-b7a3-44c7-9dec-c6aab935ad5e
iuztfnhci2uy36oluxbwy4uvthm3erzqccaaeeyz	2025-11-12 22:15:32.917	eb171945-7d49-4851-b04f-6142097088f3
\.


--
-- Data for Name: Task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Task" (id, "createdAt", "userId", description, "time", "isDone") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, "createdAt", "updatedAt", email, username, "organizationId", role, "isAdmin", "hasCompletedOnboarding", "invitedById", "invitationToken", "invitationExpiresAt", "phoneNumber", "paymentProcessorUserId", "lemonSqueezyCustomerPortalUrl", "subscriptionStatus", "subscriptionPlan", "datePaid", credits) FROM stdin;
5a696f93-5ebb-4413-8836-572ad77e578c	2025-10-12 22:07:20.86	2025-10-12 22:07:20.86	user@demo.com	user	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	USER	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	5
6375367a-ae0e-4f05-88ac-040d269cd9e9	2025-10-12 22:01:48.677	2025-10-12 22:01:48.677	admin@demo.com	admin@demo.com	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	ADMIN	t	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3
9eb28b8e-8b2c-4df2-9808-36e6007a4b7f	2025-10-12 22:02:15.601	2025-10-12 22:02:15.601	accounting@demo.com	accounting@demo.com	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	ACCOUNTING	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3
8a9784c7-caf5-4215-a65a-ce76b6b6307d	2025-10-12 22:02:29.571	2025-10-12 22:02:29.571	corporate@demo.com	corporate@demo.com	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	CORPORATE	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3
61eacdc7-6ed8-4a91-a79d-0edc0aac14ff	2025-10-12 22:02:03.948	2025-10-12 22:02:03.948	pm@demo.com	pm@demo.com	eed36e5c-4364-4a8b-acd6-580e02ddbfdf	PROPERTY_MANAGER	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
262d523c-cddb-43e3-9fea-79f44123f4b1	eba58f95816a5b75f7cb2b46d4ae0e0ff3dfb4f8de4c5bf4c61ec2a43863fe43	2025-10-12 17:00:56.977259-05	20251012220056_fix_invoice_po_relation_final	\N	\N	2025-10-12 17:00:56.933222-05	1
\.


--
-- Name: DailyStats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DailyStats_id_seq"', 1, false);


--
-- Name: Logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_id_seq"', 17, true);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: ApprovalAction ApprovalAction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApprovalAction"
    ADD CONSTRAINT "ApprovalAction_pkey" PRIMARY KEY (id);


--
-- Name: ApprovalStep ApprovalStep_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApprovalStep"
    ADD CONSTRAINT "ApprovalStep_pkey" PRIMARY KEY (id);


--
-- Name: AuthIdentity AuthIdentity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuthIdentity"
    ADD CONSTRAINT "AuthIdentity_pkey" PRIMARY KEY ("providerName", "providerUserId");


--
-- Name: Auth Auth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Auth"
    ADD CONSTRAINT "Auth_pkey" PRIMARY KEY (id);


--
-- Name: ContactFormMessage ContactFormMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactFormMessage"
    ADD CONSTRAINT "ContactFormMessage_pkey" PRIMARY KEY (id);


--
-- Name: DailyStats DailyStats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DailyStats"
    ADD CONSTRAINT "DailyStats_pkey" PRIMARY KEY (id);


--
-- Name: ExpenseType ExpenseType_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExpenseType"
    ADD CONSTRAINT "ExpenseType_pkey" PRIMARY KEY (id);


--
-- Name: File File_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."File"
    ADD CONSTRAINT "File_pkey" PRIMARY KEY (id);


--
-- Name: GLAccount GLAccount_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GLAccount"
    ADD CONSTRAINT "GLAccount_pkey" PRIMARY KEY (id);


--
-- Name: GptResponse GptResponse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GptResponse"
    ADD CONSTRAINT "GptResponse_pkey" PRIMARY KEY (id);


--
-- Name: InvoiceLineItem InvoiceLineItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceLineItem"
    ADD CONSTRAINT "InvoiceLineItem_pkey" PRIMARY KEY (id);


--
-- Name: Invoice Invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_pkey" PRIMARY KEY (id);


--
-- Name: Logs Logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY (id);


--
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id);


--
-- Name: Organization Organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Organization"
    ADD CONSTRAINT "Organization_pkey" PRIMARY KEY (id);


--
-- Name: POLineItem POLineItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POLineItem"
    ADD CONSTRAINT "POLineItem_pkey" PRIMARY KEY (id);


--
-- Name: PageViewSource PageViewSource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PageViewSource"
    ADD CONSTRAINT "PageViewSource_pkey" PRIMARY KEY (date, name);


--
-- Name: ProcessingJob ProcessingJob_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProcessingJob"
    ADD CONSTRAINT "ProcessingJob_pkey" PRIMARY KEY (id);


--
-- Name: Property Property_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Property"
    ADD CONSTRAINT "Property_pkey" PRIMARY KEY (id);


--
-- Name: PurchaseOrder PurchaseOrder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseOrder"
    ADD CONSTRAINT "PurchaseOrder_pkey" PRIMARY KEY (id);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- Name: ApprovalAction_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalAction_createdAt_idx" ON public."ApprovalAction" USING btree ("createdAt");


--
-- Name: ApprovalAction_purchaseOrderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalAction_purchaseOrderId_idx" ON public."ApprovalAction" USING btree ("purchaseOrderId");


--
-- Name: ApprovalAction_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalAction_userId_idx" ON public."ApprovalAction" USING btree ("userId");


--
-- Name: ApprovalStep_purchaseOrderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalStep_purchaseOrderId_idx" ON public."ApprovalStep" USING btree ("purchaseOrderId");


--
-- Name: ApprovalStep_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalStep_status_idx" ON public."ApprovalStep" USING btree (status);


--
-- Name: ApprovalStep_stepNumber_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ApprovalStep_stepNumber_idx" ON public."ApprovalStep" USING btree ("stepNumber");


--
-- Name: Auth_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Auth_userId_key" ON public."Auth" USING btree ("userId");


--
-- Name: DailyStats_date_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "DailyStats_date_key" ON public."DailyStats" USING btree (date);


--
-- Name: ExpenseType_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExpenseType_isActive_idx" ON public."ExpenseType" USING btree ("isActive");


--
-- Name: ExpenseType_organizationId_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ExpenseType_organizationId_code_key" ON public."ExpenseType" USING btree ("organizationId", code);


--
-- Name: ExpenseType_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExpenseType_organizationId_idx" ON public."ExpenseType" USING btree ("organizationId");


--
-- Name: GLAccount_accountType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GLAccount_accountType_idx" ON public."GLAccount" USING btree ("accountType");


--
-- Name: GLAccount_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GLAccount_isActive_idx" ON public."GLAccount" USING btree ("isActive");


--
-- Name: GLAccount_organizationId_accountNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "GLAccount_organizationId_accountNumber_key" ON public."GLAccount" USING btree ("organizationId", "accountNumber");


--
-- Name: GLAccount_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "GLAccount_organizationId_idx" ON public."GLAccount" USING btree ("organizationId");


--
-- Name: InvoiceLineItem_invoiceId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "InvoiceLineItem_invoiceId_idx" ON public."InvoiceLineItem" USING btree ("invoiceId");


--
-- Name: Invoice_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Invoice_createdAt_idx" ON public."Invoice" USING btree ("createdAt");


--
-- Name: Invoice_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Invoice_status_idx" ON public."Invoice" USING btree (status);


--
-- Name: Invoice_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Invoice_userId_idx" ON public."Invoice" USING btree ("userId");


--
-- Name: Notification_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Notification_createdAt_idx" ON public."Notification" USING btree ("createdAt");


--
-- Name: Notification_read_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Notification_read_idx" ON public."Notification" USING btree (read);


--
-- Name: Notification_type_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Notification_type_idx" ON public."Notification" USING btree (type);


--
-- Name: Notification_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Notification_userId_idx" ON public."Notification" USING btree ("userId");


--
-- Name: Organization_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Organization_code_idx" ON public."Organization" USING btree (code);


--
-- Name: Organization_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Organization_code_key" ON public."Organization" USING btree (code);


--
-- Name: POLineItem_glAccountId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "POLineItem_glAccountId_idx" ON public."POLineItem" USING btree ("glAccountId");


--
-- Name: POLineItem_propertyId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "POLineItem_propertyId_idx" ON public."POLineItem" USING btree ("propertyId");


--
-- Name: POLineItem_purchaseOrderId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "POLineItem_purchaseOrderId_idx" ON public."POLineItem" USING btree ("purchaseOrderId");


--
-- Name: ProcessingJob_invoiceId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ProcessingJob_invoiceId_key" ON public."ProcessingJob" USING btree ("invoiceId");


--
-- Name: ProcessingJob_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ProcessingJob_status_idx" ON public."ProcessingJob" USING btree (status);


--
-- Name: Property_isActive_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Property_isActive_idx" ON public."Property" USING btree ("isActive");


--
-- Name: Property_organizationId_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Property_organizationId_code_key" ON public."Property" USING btree ("organizationId", code);


--
-- Name: Property_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Property_organizationId_idx" ON public."Property" USING btree ("organizationId");


--
-- Name: PurchaseOrder_createdById_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseOrder_createdById_idx" ON public."PurchaseOrder" USING btree ("createdById");


--
-- Name: PurchaseOrder_linkedInvoiceId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PurchaseOrder_linkedInvoiceId_key" ON public."PurchaseOrder" USING btree ("linkedInvoiceId");


--
-- Name: PurchaseOrder_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseOrder_organizationId_idx" ON public."PurchaseOrder" USING btree ("organizationId");


--
-- Name: PurchaseOrder_organizationId_poNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "PurchaseOrder_organizationId_poNumber_key" ON public."PurchaseOrder" USING btree ("organizationId", "poNumber");


--
-- Name: PurchaseOrder_requiresApproval_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseOrder_requiresApproval_idx" ON public."PurchaseOrder" USING btree ("requiresApproval");


--
-- Name: PurchaseOrder_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "PurchaseOrder_status_idx" ON public."PurchaseOrder" USING btree (status);


--
-- Name: Session_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Session_id_key" ON public."Session" USING btree (id);


--
-- Name: Session_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Session_userId_idx" ON public."Session" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_invitationToken_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "User_invitationToken_idx" ON public."User" USING btree ("invitationToken");


--
-- Name: User_invitationToken_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_invitationToken_key" ON public."User" USING btree ("invitationToken");


--
-- Name: User_organizationId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "User_organizationId_idx" ON public."User" USING btree ("organizationId");


--
-- Name: User_paymentProcessorUserId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_paymentProcessorUserId_key" ON public."User" USING btree ("paymentProcessorUserId");


--
-- Name: User_role_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "User_role_idx" ON public."User" USING btree (role);


--
-- Name: User_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_username_key" ON public."User" USING btree (username);


--
-- Name: ApprovalAction ApprovalAction_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApprovalAction"
    ADD CONSTRAINT "ApprovalAction_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ApprovalStep ApprovalStep_approvedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApprovalStep"
    ADD CONSTRAINT "ApprovalStep_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ApprovalStep ApprovalStep_purchaseOrderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ApprovalStep"
    ADD CONSTRAINT "ApprovalStep_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES public."PurchaseOrder"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: AuthIdentity AuthIdentity_authId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuthIdentity"
    ADD CONSTRAINT "AuthIdentity_authId_fkey" FOREIGN KEY ("authId") REFERENCES public."Auth"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Auth Auth_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Auth"
    ADD CONSTRAINT "Auth_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContactFormMessage ContactFormMessage_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactFormMessage"
    ADD CONSTRAINT "ContactFormMessage_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ExpenseType ExpenseType_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExpenseType"
    ADD CONSTRAINT "ExpenseType_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: File File_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."File"
    ADD CONSTRAINT "File_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GLAccount GLAccount_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GLAccount"
    ADD CONSTRAINT "GLAccount_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: GptResponse GptResponse_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GptResponse"
    ADD CONSTRAINT "GptResponse_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: InvoiceLineItem InvoiceLineItem_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."InvoiceLineItem"
    ADD CONSTRAINT "InvoiceLineItem_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Invoice Invoice_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invoice"
    ADD CONSTRAINT "Invoice_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Notification Notification_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Notification"
    ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: POLineItem POLineItem_glAccountId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POLineItem"
    ADD CONSTRAINT "POLineItem_glAccountId_fkey" FOREIGN KEY ("glAccountId") REFERENCES public."GLAccount"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: POLineItem POLineItem_propertyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POLineItem"
    ADD CONSTRAINT "POLineItem_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES public."Property"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: POLineItem POLineItem_purchaseOrderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."POLineItem"
    ADD CONSTRAINT "POLineItem_purchaseOrderId_fkey" FOREIGN KEY ("purchaseOrderId") REFERENCES public."PurchaseOrder"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PageViewSource PageViewSource_dailyStatsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PageViewSource"
    ADD CONSTRAINT "PageViewSource_dailyStatsId_fkey" FOREIGN KEY ("dailyStatsId") REFERENCES public."DailyStats"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ProcessingJob ProcessingJob_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProcessingJob"
    ADD CONSTRAINT "ProcessingJob_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Property Property_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Property"
    ADD CONSTRAINT "Property_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PurchaseOrder PurchaseOrder_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseOrder"
    ADD CONSTRAINT "PurchaseOrder_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PurchaseOrder PurchaseOrder_expenseTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseOrder"
    ADD CONSTRAINT "PurchaseOrder_expenseTypeId_fkey" FOREIGN KEY ("expenseTypeId") REFERENCES public."ExpenseType"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PurchaseOrder PurchaseOrder_linkedInvoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseOrder"
    ADD CONSTRAINT "PurchaseOrder_linkedInvoiceId_fkey" FOREIGN KEY ("linkedInvoiceId") REFERENCES public."Invoice"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PurchaseOrder PurchaseOrder_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PurchaseOrder"
    ADD CONSTRAINT "PurchaseOrder_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Auth"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Task Task_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: User User_invitedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: User User_organizationId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public."Organization"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict pd2j71mfwM15zdXqaRffjEd11lWlyeKEvAeBDUfJHyJaFnjeB0Hf7PlMQ28rGWe

