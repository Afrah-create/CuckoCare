-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  user_id uuid NOT NULL,
  display_name text,
  phone text,
  app_role text NOT NULL DEFAULT 'farmer'::text CHECK (app_role = ANY (ARRAY['farmer'::text, 'vet'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.vet_profiles (
  user_id uuid NOT NULL,
  display_name text,
  organization text,
  offers_consultation boolean NOT NULL DEFAULT true,
  offers_farm_visit boolean NOT NULL DEFAULT true,
  poultry_specialist boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT vet_profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT vet_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.farms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  farm_id uuid NOT NULL,
  name text NOT NULL,
  location text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  created_by uuid,
  district text,
  village text,
  phone text,
  alt_phone text,
  profile_completed_at timestamp with time zone,
  CONSTRAINT farms_pkey PRIMARY KEY (id),
  CONSTRAINT farms_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.farm_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  farm_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['owner'::text, 'manager'::text, 'worker'::text, 'viewer'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT farm_members_pkey PRIMARY KEY (id),
  CONSTRAINT farm_members_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT farm_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.batches (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  name text NOT NULL,
  bird_type text NOT NULL,
  initial_count integer NOT NULL,
  acquired_on date NOT NULL,
  age_at_acquisition_days integer NOT NULL DEFAULT 0,
  hatchery_vaccinated boolean,
  source text,
  status text NOT NULL,
  programme_id text NOT NULL,
  programme_version integer NOT NULL,
  production_type text,
  programme_content_hash text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT batches_pkey PRIMARY KEY (id),
  CONSTRAINT batches_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.programmes (
  id text NOT NULL,
  farm_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  name text NOT NULL,
  version integer NOT NULL,
  bird_types jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT programmes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.programme_steps (
  id text NOT NULL,
  farm_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  programme_id text NOT NULL,
  name text NOT NULL,
  age_days integer NOT NULL,
  location text NOT NULL,
  optional boolean NOT NULL DEFAULT false,
  due_window_days_before integer NOT NULL DEFAULT 0,
  due_window_days_after integer NOT NULL DEFAULT 0,
  recurring jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT programme_steps_pkey PRIMARY KEY (id),
  CONSTRAINT programme_steps_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES public.programmes(id)
);
CREATE TABLE public.vaccination_tasks (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  batch_id uuid NOT NULL,
  step_id text NOT NULL,
  occurrence integer NOT NULL DEFAULT 0,
  due_on date NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  status text NOT NULL CHECK (status = ANY (ARRAY['pending'::text, 'done'::text, 'skipped'::text, 'assumed_done'::text])),
  done_on date,
  done_by text,
  product_used text,
  notes text,
  step_snapshot text,
  programme_content_hash text,
  shifted_from date,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT vaccination_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT vaccination_tasks_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT vaccination_tasks_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id)
);
CREATE TABLE public.entitlements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  farm_id uuid NOT NULL,
  plan text NOT NULL,
  status text NOT NULL,
  valid_until timestamp with time zone,
  last_verified_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT entitlements_pkey PRIMARY KEY (id),
  CONSTRAINT entitlements_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  farm_id uuid NOT NULL,
  provider_reference text NOT NULL UNIQUE,
  amount_cents integer NOT NULL,
  currency text NOT NULL DEFAULT 'UGX'::text,
  status text NOT NULL,
  raw jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.sms_outbox (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  farm_id uuid,
  phone text NOT NULL,
  message text NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT sms_outbox_pkey PRIMARY KEY (id),
  CONSTRAINT sms_outbox_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.sync_counters (
  scope text NOT NULL,
  last_version bigint NOT NULL DEFAULT 0,
  CONSTRAINT sync_counters_pkey PRIMARY KEY (scope)
);
CREATE TABLE public.sync_meta (
  key text NOT NULL,
  value text NOT NULL,
  CONSTRAINT sync_meta_pkey PRIMARY KEY (key)
);
CREATE TABLE public.sync_ops_applied (
  op_id uuid NOT NULL,
  user_id uuid NOT NULL,
  applied_at timestamp with time zone NOT NULL DEFAULT now(),
  result jsonb NOT NULL,
  CONSTRAINT sync_ops_applied_pkey PRIMARY KEY (op_id),
  CONSTRAINT sync_ops_applied_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.sync_table_config (
  table_name text NOT NULL,
  kind text NOT NULL CHECK (kind = ANY (ARRAY['mutable'::text, 'append_only'::text, 'reference'::text])),
  scope_kind text NOT NULL CHECK (scope_kind = ANY (ARRAY['farm'::text, 'reference'::text])),
  writable_columns ARRAY NOT NULL,
  CONSTRAINT sync_table_config_pkey PRIMARY KEY (table_name)
);
CREATE TABLE public.sync_lock (
  id integer NOT NULL DEFAULT 1 CHECK (id = 1),
  holder text,
  lease_until timestamp with time zone,
  CONSTRAINT sync_lock_pkey PRIMARY KEY (id)
);
CREATE TABLE public.feed_items (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  name text NOT NULL,
  feed_type text NOT NULL,
  unit text NOT NULL,
  reorder_level numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT feed_items_pkey PRIMARY KEY (id),
  CONSTRAINT feed_items_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.feed_transactions (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  feed_item_id uuid NOT NULL,
  batch_id uuid,
  kind text NOT NULL CHECK (kind = ANY (ARRAY['purchase'::text, 'usage'::text, 'adjustment'::text])),
  quantity numeric NOT NULL CHECK (quantity > 0::numeric),
  unit_cost numeric,
  occurred_on date NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT feed_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT feed_transactions_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT feed_transactions_feed_item_id_fkey FOREIGN KEY (feed_item_id) REFERENCES public.feed_items(id),
  CONSTRAINT feed_transactions_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id)
);
CREATE TABLE public.health_records (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  batch_id uuid NOT NULL,
  occurred_on date NOT NULL,
  summary text NOT NULL,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT health_records_pkey PRIMARY KEY (id),
  CONSTRAINT health_records_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT health_records_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id)
);
CREATE TABLE public.mortality_records (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  batch_id uuid NOT NULL,
  count integer NOT NULL CHECK (count > 0),
  occurred_on date NOT NULL,
  cause text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT mortality_records_pkey PRIMARY KEY (id),
  CONSTRAINT mortality_records_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT mortality_records_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id)
);
CREATE TABLE public.farm_events (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  batch_id uuid,
  event_type text NOT NULL,
  occurred_on date NOT NULL,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT farm_events_pkey PRIMARY KEY (id),
  CONSTRAINT farm_events_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT farm_events_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id)
);