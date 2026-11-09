-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  user_id uuid NOT NULL,
  display_name text,
  phone text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  app_role text NOT NULL DEFAULT 'farmer'::text CHECK (app_role = ANY (ARRAY['farmer'::text, 'vet'::text])),
  CONSTRAINT profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
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
  latitude double precision,
  longitude double precision,
  location_accuracy_m real,
  location_captured_at timestamp with time zone,
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
  status text NOT NULL CHECK (status = ANY (ARRAY['active'::text, 'closed'::text])) NOT VALI),
  programme_id text NOT NULL,
  programme_version integer NOT NULL,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  production_type text,
  programme_content_hash text,
  closed_on date,
  close_reason text CHECK (close_reason IS NULL OR (close_reason = ANY (ARRAY['sold'::text, 'cycle_complete'::text, 'flock_lost'::text, 'other'::text]))),
  close_note text,
  deleted_group_id uuid,
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
  due_on date NOT NULL,
  status text NOT NULL CHECK (status = ANY (ARRAY['pending'::text, 'done'::text, 'skipped'::text, 'assumed_done'::text])),
  done_on date,
  product_used text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  occurrence integer NOT NULL DEFAULT 0,
  enabled boolean NOT NULL DEFAULT true,
  done_by text,
  step_snapshot text,
  programme_content_hash text,
  shifted_from date,
  deleted_group_id uuid,
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
  kind text NOT NULL DEFAULT 'generic'::text,
  request_id uuid,
  recipient_user_id uuid,
  dedupe_key text,
  attempts integer NOT NULL DEFAULT 0,
  sent_at timestamp with time zone,
  provider_message_id text,
  error_code text,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
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
  kind text NOT NULL CHECK (kind = ANY (ARRAY['purchase'::text, 'consumption'::text, 'wastage'::text, 'adjustment'::text])),
  quantity numeric NOT NULL,
  unit_cost numeric CHECK (unit_cost IS NULL OR unit_cost >= 0::numeric),
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
  affected_bird_count integer,
  symptoms jsonb NOT NULL DEFAULT '[]'::jsonb,
  record_kind text NOT NULL DEFAULT 'observation'::text CHECK (record_kind = ANY (ARRAY['observation'::text, 'incident'::text, 'follow_up'::text, 'vet_consultation'::text])),
  photo_object_keys jsonb NOT NULL DEFAULT '[]'::jsonb,
  CONSTRAINT health_records_pkey PRIMARY KEY (id),
  CONSTRAINT health_records_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id),
  CONSTRAINT health_records_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
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
  kind text NOT NULL DEFAULT 'died'::text CHECK (kind = ANY (ARRAY['died'::text, 'culled'::text, 'missing'::text, 'other'::text])),
  suspected_cause text CHECK (suspected_cause IS NULL OR (suspected_cause = ANY (ARRAY['unknown'::text, 'disease_signs'::text, 'injury'::text, 'heat_or_cold'::text, 'predator'::text, 'other'::text]))),
  edited_at timestamp with time zone,
  deleted_group_id uuid,
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
CREATE TABLE public.vet_profiles (
  user_id uuid NOT NULL,
  display_name text,
  organization text,
  offers_consultation boolean NOT NULL DEFAULT true,
  offers_farm_visit boolean NOT NULL DEFAULT true,
  poultry_specialist boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  latitude double precision,
  longitude double precision,
  location_accuracy_m real,
  location_captured_at timestamp with time zone,
  district text,
  is_verified boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  opted_in boolean NOT NULL DEFAULT true,
  phone text,
  sms_urgent_alerts boolean NOT NULL DEFAULT true,
  CONSTRAINT vet_profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT vet_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.vet_assistance_requests (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  batch_id uuid NOT NULL,
  health_record_id uuid NOT NULL,
  service_type text NOT NULL CHECK (service_type = ANY (ARRAY['consultation'::text, 'farm_visit'::text, 'either'::text])),
  status text NOT NULL CHECK (status = ANY (ARRAY['draft'::text, 'pending_sync'::text, 'submitted'::text, 'received'::text, 'accepted'::text, 'declined'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text])),
  share_location boolean NOT NULL DEFAULT false,
  priority text NOT NULL DEFAULT 'normal'::text,
  farmer_notes text,
  assigned_vet_user_id uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  requested_vet_user_id uuid,
  CONSTRAINT vet_assistance_requests_pkey PRIMARY KEY (id),
  CONSTRAINT vet_assistance_requests_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT vet_assistance_requests_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id),
  CONSTRAINT vet_assistance_requests_health_record_id_fkey FOREIGN KEY (health_record_id) REFERENCES public.health_records(id),
  CONSTRAINT vet_assistance_requests_assigned_vet_user_id_fkey FOREIGN KEY (assigned_vet_user_id) REFERENCES auth.users(id),
  CONSTRAINT vet_assistance_requests_requested_vet_user_id_fkey FOREIGN KEY (requested_vet_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.vet_consultations (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  request_id uuid NOT NULL,
  vet_user_id uuid NOT NULL,
  message text,
  assessment text,
  follow_up_required boolean NOT NULL DEFAULT false,
  follow_up_on date,
  farm_visit_required boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT vet_consultations_pkey PRIMARY KEY (id),
  CONSTRAINT vet_consultations_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT vet_consultations_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.vet_assistance_requests(id),
  CONSTRAINT vet_consultations_vet_user_id_fkey FOREIGN KEY (vet_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.email_otp_challenges (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL,
  purpose text NOT NULL CHECK (purpose = ANY (ARRAY['signup'::text, 'password_reset'::text])),
  code_hash text NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  attempt_count integer NOT NULL DEFAULT 0,
  consumed_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT email_otp_challenges_pkey PRIMARY KEY (id)
);
CREATE TABLE public.case_messages (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  request_id uuid NOT NULL,
  sender_user_id uuid,
  sender_role text NOT NULL CHECK (sender_role = ANY (ARRAY['farmer'::text, 'vet'::text, 'system'::text])),
  kind text NOT NULL CHECK (kind = ANY (ARRAY['text'::text, 'photo'::text, 'system'::text])),
  body text,
  client_created_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT case_messages_pkey PRIMARY KEY (id),
  CONSTRAINT case_messages_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT case_messages_sender_user_id_fkey FOREIGN KEY (sender_user_id) REFERENCES auth.users(id),
  CONSTRAINT case_messages_request_farm_fk FOREIGN KEY (request_id) REFERENCES public.vet_assistance_requests(id),
  CONSTRAINT case_messages_request_farm_fk FOREIGN KEY (farm_id) REFERENCES public.vet_assistance_requests(farm_id)
);
CREATE TABLE public.case_message_attachments (
  id uuid NOT NULL,
  farm_id uuid NOT NULL,
  request_id uuid NOT NULL,
  message_id uuid NOT NULL,
  object_key text NOT NULL,
  mime text NOT NULL DEFAULT 'image/jpeg'::text,
  bytes integer,
  width integer,
  height integer,
  thumb_b64 text CHECK (thumb_b64 IS NULL OR octet_length(thumb_b64) <= 10922),
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'uploaded'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT case_message_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT case_message_attachments_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id),
  CONSTRAINT case_message_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.case_messages(id),
  CONSTRAINT case_message_attachments_request_farm_fk FOREIGN KEY (request_id) REFERENCES public.vet_assistance_requests(id),
  CONSTRAINT case_message_attachments_request_farm_fk FOREIGN KEY (farm_id) REFERENCES public.vet_assistance_requests(farm_id)
);
CREATE TABLE public.case_read_state (
  request_id uuid NOT NULL,
  user_id uuid NOT NULL,
  farm_id uuid,
  last_read_at timestamp with time zone NOT NULL,
  last_read_message_id uuid,
  muted boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  deleted_at timestamp with time zone,
  server_version bigint,
  CONSTRAINT case_read_state_pkey PRIMARY KEY (request_id, user_id),
  CONSTRAINT case_read_state_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT case_read_state_farm_id_fkey FOREIGN KEY (farm_id) REFERENCES public.farms(id)
);
CREATE TABLE public.device_push_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  token text NOT NULL UNIQUE,
  platform text NOT NULL DEFAULT 'android'::text,
  app_flavor text,
  app_version text,
  locale text NOT NULL DEFAULT 'en'::text,
  push_messages_enabled boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  last_seen_at timestamp with time zone NOT NULL DEFAULT now(),
  revoked_at timestamp with time zone,
  CONSTRAINT device_push_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT device_push_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.push_log (
  message_id uuid NOT NULL,
  user_id uuid NOT NULL,
  sent_at timestamp with time zone NOT NULL DEFAULT now(),
  result text,
  CONSTRAINT push_log_pkey PRIMARY KEY (message_id, user_id)
);