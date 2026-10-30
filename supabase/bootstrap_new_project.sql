-- CucoCare: full schema for a NEW empty Supabase project
--
-- How to run
-- 1. Create a new Supabase project.
-- 2. Dashboard → SQL Editor → New query.
-- 3. Paste this entire file and Run.
-- 4. Dashboard → Authentication → Providers: Email enabled.
--    Turn OFF "Confirm email" if you want the same signup behaviour as local
--    (auth.email.enable_confirmations = false).
-- 5. Dashboard → Authentication → URL configuration: add your app redirect
--    (cucocare://app and any https callback).
--
-- This file is every migration from 0001 through 0022, in order.
-- It creates tables, columns, indexes, RLS, triggers, RPCs, grants, and the
-- health-incident-images storage bucket.
--
-- Do NOT run this on a project that already has CucoCare tables.
-- Do NOT run seed_dev_vets.sql on production (fake auth users).
--
-- After this succeeds, load vaccination programmes separately
-- (assets/seed JSON via tool/generate_seed.dart) if batches need programme rows.
--
-- Rollback: delete the Supabase project (there is no partial undo).


-- =============================================================================
-- 0001_init.sql
-- =============================================================================

-- CucoCare core schema: synced farm data, RLS, delta sync RPCs.

create extension if not exists "pgcrypto";

create sequence if not exists global_server_version_seq;

create or replace function public.set_server_version()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  if tg_op = 'INSERT' or new.server_version is null then
    new.server_version := nextval('global_server_version_seq');
  else
    new.server_version := nextval('global_server_version_seq');
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Identity & farms
-- ---------------------------------------------------------------------------

create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.farms (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null,
  name text not null,
  location text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger farms_set_version
before insert or update on public.farms
for each row execute function public.set_server_version();

create index farms_farm_version_idx on public.farms (farm_id, server_version);

create table public.farm_members (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null references public.farms (id),
  user_id uuid not null references auth.users (id),
  role text not null check (role in ('owner', 'manager', 'worker')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint,
  unique (farm_id, user_id)
);

create trigger farm_members_set_version
before insert or update on public.farm_members
for each row execute function public.set_server_version();

create index farm_members_farm_version_idx on public.farm_members (farm_id, server_version);

-- Helper: membership check (optional role filter; default matches legacy member roles)
create or replace function public.is_farm_member(
  p_farm_id uuid,
  p_roles text[] default array['owner', 'manager', 'worker']
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.farm_members fm
    where fm.farm_id = p_farm_id
      and fm.user_id = (select auth.uid())
      and fm.deleted_at is null
      and fm.role = any (p_roles)
  );
$$;

-- ---------------------------------------------------------------------------
-- Synced domain tables (shared columns)
-- ---------------------------------------------------------------------------

create table public.batches (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  name text not null,
  bird_type text not null,
  initial_count int not null,
  acquired_on date not null,
  age_at_acquisition_days int not null default 0,
  hatchery_vaccinated boolean,
  source text,
  status text not null,
  programme_id text not null,
  programme_version int not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger batches_set_version before insert or update on public.batches
for each row execute function public.set_server_version();
create index batches_farm_version_idx on public.batches (farm_id, server_version);

create table public.programmes (
  id text primary key,
  farm_id uuid not null default '00000000-0000-0000-0000-000000000000',
  name text not null,
  version int not null,
  bird_types jsonb not null default '[]',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger programmes_set_version before insert or update on public.programmes
for each row execute function public.set_server_version();
create index programmes_farm_version_idx on public.programmes (farm_id, server_version);

create table public.programme_steps (
  id text primary key,
  farm_id uuid not null default '00000000-0000-0000-0000-000000000000',
  programme_id text not null references public.programmes (id),
  name text not null,
  age_days int not null,
  location text not null,
  optional boolean not null default false,
  due_window_days_before int not null default 0,
  due_window_days_after int not null default 0,
  recurring jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger programme_steps_set_version before insert or update on public.programme_steps
for each row execute function public.set_server_version();
create index programme_steps_farm_version_idx on public.programme_steps (farm_id, server_version);

create table public.vaccination_tasks (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  batch_id uuid not null references public.batches (id),
  step_id text not null references public.programme_steps (id),
  due_on date not null,
  status text not null check (status in ('pending','done','skipped','assumed_done')),
  done_on date,
  product_used text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger vaccination_tasks_set_version before insert or update on public.vaccination_tasks
for each row execute function public.set_server_version();
create index vaccination_tasks_farm_version_idx on public.vaccination_tasks (farm_id, server_version);

-- TODO: feed_items, feed_transactions, health_records, mortality_records, farm_events DDL

create table public.entitlements (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null references public.farms (id),
  plan text not null,
  status text not null,
  valid_until timestamptz,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create trigger entitlements_set_version before insert or update on public.entitlements
for each row execute function public.set_server_version();
create index entitlements_farm_version_idx on public.entitlements (farm_id, server_version);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null references public.farms (id),
  provider_reference text not null unique,
  amount_cents int not null,
  currency text not null default 'UGX',
  status text not null,
  raw jsonb,
  created_at timestamptz not null default now()
);

create table public.sms_outbox (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid references public.farms (id),
  phone text not null,
  message text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.farms enable row level security;
alter table public.farm_members enable row level security;
alter table public.batches enable row level security;
alter table public.programmes enable row level security;
alter table public.programme_steps enable row level security;
alter table public.vaccination_tasks enable row level security;
alter table public.entitlements enable row level security;
alter table public.payments enable row level security;
alter table public.sms_outbox enable row level security;

create policy farms_member_select on public.farms for select
  using (public.is_farm_member(farm_id));
create policy farms_member_write on public.farms for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy farm_members_select on public.farm_members for select
  using (public.is_farm_member(farm_id));

create policy batches_member on public.batches for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy programmes_read on public.programmes for select
  to authenticated using (true);

create policy programme_steps_read on public.programme_steps for select
  to authenticated using (true);

create policy vaccination_tasks_member on public.vaccination_tasks for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy entitlements_read on public.entitlements for select
  using (public.is_farm_member(farm_id));

-- Service-role only writes for payments / sms / entitlement grants
create policy payments_service on public.payments for all
  using (false) with check (false);
create policy sms_service on public.sms_outbox for all
  using (false) with check (false);

-- ---------------------------------------------------------------------------
-- Sync RPCs (SECURITY INVOKER — RLS applies)
-- ---------------------------------------------------------------------------

create or replace function public.sync_push(ops jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  op jsonb;
  ack jsonb := '[]'::jsonb;
begin
  for op in select * from jsonb_array_elements(ops)
  loop
    if op->>'table_name' = 'batches' then
      insert into public.batches as t
      select * from jsonb_populate_record(null::public.batches, op->'payload')
      on conflict (id) do update set
        name = excluded.name,
        status = excluded.status,
        updated_at = now(),
        deleted_at = excluded.deleted_at;
      ack := ack || jsonb_build_array(op->>'op_id');
    elsif op->>'table_name' = 'vaccination_tasks' then
      insert into public.vaccination_tasks as t
      select * from jsonb_populate_record(null::public.vaccination_tasks, op->'payload')
      on conflict (id) do update set
        status = case
          when t.status = 'done' then t.status
          else excluded.status
        end,
        done_on = excluded.done_on,
        updated_at = now(),
        deleted_at = excluded.deleted_at;
      ack := ack || jsonb_build_array(op->>'op_id');
    else
      -- TODO: remaining tables
      null;
    end if;
  end loop;
  return jsonb_build_object('acknowledged_op_ids', ack);
end;
$$;

create or replace function public.sync_pull(cursors jsonb, page_size int default 100)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  result jsonb := '{}'::jsonb;
  tbl text;
  cur bigint;
  rows jsonb;
  has_more boolean;
begin
  for tbl, cur in
    select key, coalesce(value::bigint, 0)
    from jsonb_each(cursors)
  loop
    if tbl = 'batches' then
      select coalesce(jsonb_agg(to_jsonb(b)), '[]'::jsonb)
      into rows
      from (
        select * from public.batches b
        where b.server_version > cur and public.is_farm_member(b.farm_id)
        order by b.server_version
        limit page_size + 1
      ) b;
      has_more := jsonb_array_length(rows) > page_size;
      if has_more then
        rows := (select jsonb_agg(elem) from (
          select elem from jsonb_array_elements(rows) with ordinality as t(elem, ord)
          where ord <= page_size
        ) s);
      end if;
      result := result || jsonb_build_object(tbl, jsonb_build_object('rows', rows, 'has_more', has_more));
    elsif tbl = 'vaccination_tasks' then
      select coalesce(jsonb_agg(to_jsonb(v)), '[]'::jsonb)
      into rows
      from (
        select * from public.vaccination_tasks v
        where v.server_version > cur and public.is_farm_member(v.farm_id)
        order by v.server_version
        limit page_size + 1
      ) v;
      has_more := jsonb_array_length(rows) > page_size;
      if has_more then
        rows := (select jsonb_agg(elem) from (
          select elem from jsonb_array_elements(rows) with ordinality as t(elem, ord)
          where ord <= page_size
        ) s);
      end if;
      result := result || jsonb_build_object(tbl, jsonb_build_object('rows', rows, 'has_more', has_more));
    else
      -- TODO: remaining tables
      result := result || jsonb_build_object(tbl, jsonb_build_object('rows', '[]'::jsonb, 'has_more', false));
    end if;
  end loop;
  return result;
end;
$$;

-- =============================================================================
-- 0002_sync_infrastructure.sql
-- =============================================================================

-- Per-scope commit-ordered sync versions, config-driven tables, schema completion.
--
-- WHY PER-SCOPE COUNTERS (not a global sequence):
-- A global sequence assigns values in *call* order, not *commit* order. A reader
-- can advance past a version whose transaction commits later and miss rows forever.
-- sync_counters rows are locked until commit, so versions in a scope reflect commit
-- order and "server_version > cursor" pagination is safe. Clients keep one cursor
-- per scope (each farm id + 'reference'), not per table.

-- ---------------------------------------------------------------------------
-- Infrastructure tables
-- ---------------------------------------------------------------------------

create table public.sync_counters (
  scope text primary key,
  last_version bigint not null default 0
);

create table public.sync_meta (
  key text primary key,
  value text not null
);

insert into public.sync_meta (key, value) values ('epoch', '1');

create table public.sync_ops_applied (
  op_id uuid primary key,
  user_id uuid not null references auth.users (id),
  applied_at timestamptz not null default now(),
  result jsonb not null
);

create table public.sync_table_config (
  table_name text primary key,
  kind text not null check (kind in ('mutable', 'append_only', 'reference')),
  scope_kind text not null check (scope_kind in ('farm', 'reference')),
  writable_columns text[] not null
);

create table public.sync_lock (
  id int primary key default 1 check (id = 1),
  holder text,
  lease_until timestamptz
);

insert into public.sync_lock (id) values (1);

-- ---------------------------------------------------------------------------
-- Replace global sequence versioning with per-scope counters
-- ---------------------------------------------------------------------------

drop function if exists public.sync_pull(jsonb, int);
drop function if exists public.sync_push(jsonb);

drop trigger if exists farms_set_version on public.farms;
drop trigger if exists farm_members_set_version on public.farm_members;
drop trigger if exists batches_set_version on public.batches;
drop trigger if exists programmes_set_version on public.programmes;
drop trigger if exists programme_steps_set_version on public.programme_steps;
drop trigger if exists vaccination_tasks_set_version on public.vaccination_tasks;
drop trigger if exists entitlements_set_version on public.entitlements;

create or replace function public.sync_scope_for_table(p_table text, p_farm_id uuid)
returns text
language sql
immutable
as $$
  select case
    when p_table in ('programmes', 'programme_steps') then 'reference'
    else p_farm_id::text
  end;
$$;

create or replace function public.bump_sync_server_version(p_scope text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v bigint;
begin
  insert into public.sync_counters as sc (scope, last_version)
  values (p_scope, 1)
  on conflict (scope) do update
    set last_version = sc.last_version + 1
  returning last_version into v;
  return v;
end;
$$;

create or replace function public.assign_sync_server_version()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_scope text;
begin
  new.updated_at := now();
  if tg_table_name in ('programmes', 'programme_steps') then
    v_scope := 'reference';
  elsif tg_table_name = 'farms' then
    v_scope := new.id::text;
  else
    v_scope := new.farm_id::text;
  end if;
  new.server_version := public.bump_sync_server_version(v_scope);
  return new;
end;
$$;

drop function if exists public.set_server_version() cascade;
drop sequence if exists global_server_version_seq;

-- Farms: align scope column + creator
alter table public.farms add column if not exists created_by uuid references auth.users (id);
update public.farms set farm_id = id where farm_id is distinct from id;

alter table public.farm_members drop constraint if exists farm_members_role_check;
alter table public.farm_members add constraint farm_members_role_check
  check (role in ('owner', 'manager', 'worker', 'viewer'));

-- Replace legacy is_farm_member(uuid) if 0001 was applied before the 2-arg definition.
-- RLS policies must be dropped first (2BP01 otherwise).
drop policy if exists farms_member_select on public.farms;
drop policy if exists farms_member_write on public.farms;
drop policy if exists farm_members_select on public.farm_members;
drop policy if exists batches_member on public.batches;
drop policy if exists vaccination_tasks_member on public.vaccination_tasks;
drop policy if exists entitlements_read on public.entitlements;

drop function if exists public.is_farm_member(uuid);

create or replace function public.is_farm_member(
  p_farm_id uuid,
  p_roles text[] default array['owner', 'manager', 'worker', 'viewer']
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.farm_members fm
    where fm.farm_id = p_farm_id
      and fm.user_id = (select auth.uid())
      and fm.deleted_at is null
      and fm.role = any (p_roles)
  );
$$;

create policy farms_member_select on public.farms for select
  using (public.is_farm_member(farm_id));
create policy farms_member_write on public.farms for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy farm_members_select on public.farm_members for select
  using (public.is_farm_member(farm_id));

create policy batches_member on public.batches for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy vaccination_tasks_member on public.vaccination_tasks for all
  using (public.is_farm_member(farm_id))
  with check (public.is_farm_member(farm_id));

create policy entitlements_read on public.entitlements for select
  using (public.is_farm_member(farm_id));

create or replace function public.can_farm_push(p_farm_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_farm_member(p_farm_id, array['owner', 'manager', 'worker']);
$$;

-- ---------------------------------------------------------------------------
-- Remaining synced tables
-- ---------------------------------------------------------------------------

create table if not exists public.feed_items (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  name text not null,
  feed_type text not null,
  unit text not null,
  reorder_level numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create table if not exists public.feed_transactions (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  feed_item_id uuid not null references public.feed_items (id),
  batch_id uuid references public.batches (id),
  kind text not null check (kind in ('purchase', 'usage', 'adjustment')),
  quantity numeric not null check (quantity > 0),
  unit_cost numeric,
  occurred_on date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create table if not exists public.health_records (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  batch_id uuid not null references public.batches (id),
  occurred_on date not null,
  summary text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create table if not exists public.mortality_records (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  batch_id uuid not null references public.batches (id),
  count int not null check (count > 0),
  occurred_on date not null,
  cause text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create table if not exists public.farm_events (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  batch_id uuid references public.batches (id),
  event_type text not null,
  occurred_on date not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create index if not exists feed_items_farm_version_idx on public.feed_items (farm_id, server_version);
create index if not exists feed_tx_farm_version_idx on public.feed_transactions (farm_id, server_version);
create index if not exists health_records_farm_version_idx on public.health_records (farm_id, server_version);
create index if not exists mortality_records_farm_version_idx on public.mortality_records (farm_id, server_version);
create index if not exists farm_events_farm_version_idx on public.farm_events (farm_id, server_version);
create index if not exists vaccination_tasks_batch_idx on public.vaccination_tasks (batch_id);
create index if not exists vaccination_tasks_due_idx on public.vaccination_tasks (due_on);

-- Triggers on all synced tables
create trigger farms_assign_version before insert or update on public.farms
  for each row execute function public.assign_sync_server_version();
create trigger farm_members_assign_version before insert or update on public.farm_members
  for each row execute function public.assign_sync_server_version();
create trigger batches_assign_version before insert or update on public.batches
  for each row execute function public.assign_sync_server_version();
create trigger programmes_assign_version before insert or update on public.programmes
  for each row execute function public.assign_sync_server_version();
create trigger programme_steps_assign_version before insert or update on public.programme_steps
  for each row execute function public.assign_sync_server_version();
create trigger vaccination_tasks_assign_version before insert or update on public.vaccination_tasks
  for each row execute function public.assign_sync_server_version();
create trigger entitlements_assign_version before insert or update on public.entitlements
  for each row execute function public.assign_sync_server_version();
create trigger feed_items_assign_version before insert or update on public.feed_items
  for each row execute function public.assign_sync_server_version();
create trigger feed_transactions_assign_version before insert or update on public.feed_transactions
  for each row execute function public.assign_sync_server_version();
create trigger health_records_assign_version before insert or update on public.health_records
  for each row execute function public.assign_sync_server_version();
create trigger mortality_records_assign_version before insert or update on public.mortality_records
  for each row execute function public.assign_sync_server_version();
create trigger farm_events_assign_version before insert or update on public.farm_events
  for each row execute function public.assign_sync_server_version();

-- Config rows (allow-lists — no server_version / updated_at / farm_id on update)
insert into public.sync_table_config (table_name, kind, scope_kind, writable_columns) values
  ('farms', 'mutable', 'farm', array['id','name','location','notes','created_at']),
  ('batches', 'mutable', 'farm', array['id','farm_id','name','bird_type','initial_count','acquired_on','age_at_acquisition_days','hatchery_vaccinated','source','status','programme_id','programme_version','notes','created_at']),
  ('vaccination_tasks', 'mutable', 'farm', array['id','farm_id','batch_id','step_id','due_on','status','done_on','product_used','notes','created_at']),
  ('feed_items', 'mutable', 'farm', array['id','farm_id','name','feed_type','unit','reorder_level','created_at']),
  ('feed_transactions', 'append_only', 'farm', array['id','farm_id','feed_item_id','batch_id','kind','quantity','unit_cost','occurred_on','created_at']),
  ('health_records', 'append_only', 'farm', array['id','farm_id','batch_id','occurred_on','summary','notes','created_at']),
  ('mortality_records', 'append_only', 'farm', array['id','farm_id','batch_id','count','occurred_on','cause','notes','created_at']),
  ('farm_events', 'append_only', 'farm', array['id','farm_id','batch_id','event_type','occurred_on','notes','created_at']),
  ('programmes', 'reference', 'reference', array['id','name','version','bird_types','created_at']),
  ('programme_steps', 'reference', 'reference', array['id','programme_id','name','age_days','location','optional','due_window_days_before','due_window_days_after','recurring','created_at'])
on conflict (table_name) do nothing;

-- RLS for new tables
alter table public.feed_items enable row level security;
alter table public.feed_transactions enable row level security;
alter table public.health_records enable row level security;
alter table public.mortality_records enable row level security;
alter table public.farm_events enable row level security;

create policy feed_items_select on public.feed_items for select
  using (public.is_farm_member(farm_id));
create policy feed_tx_select on public.feed_transactions for select
  using (public.is_farm_member(farm_id));
create policy health_records_select on public.health_records for select
  using (public.is_farm_member(farm_id));
create policy mortality_records_select on public.mortality_records for select
  using (public.is_farm_member(farm_id));
create policy farm_events_select on public.farm_events for select
  using (public.is_farm_member(farm_id));

-- Revoke direct writes; reads via RLS. Mutations go through sync RPCs (see 0003).
revoke insert, update, delete on public.farms from authenticated;
revoke insert, update, delete on public.batches from authenticated;
revoke insert, update, delete on public.vaccination_tasks from authenticated;
revoke insert, update, delete on public.feed_items from authenticated;
revoke insert, update, delete on public.feed_transactions from authenticated;
revoke insert, update, delete on public.health_records from authenticated;
revoke insert, update, delete on public.mortality_records from authenticated;
revoke insert, update, delete on public.farm_events from authenticated;
revoke insert, update, delete on public.programmes from authenticated;
revoke insert, update, delete on public.programme_steps from authenticated;
revoke insert, update, delete on public.farm_members from authenticated;

grant select on all tables in schema public to authenticated;

-- =============================================================================
-- 0003_sync_rpcs.sql
-- =============================================================================

-- Sync RPCs: push, pull (single stream per scope), head, bootstrap.

create or replace function public.task_status_rank(p_status text)
returns int
language sql
immutable
as $$
  select case p_status
    when 'pending' then 0
    when 'assumed_done' then 1
    when 'skipped' then 2
    when 'done' then 3
    else -1
  end;
$$;

create or replace function public.sync_epoch()
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select value::bigint from public.sync_meta where key = 'epoch'), 1);
$$;

create or replace function public.sync_bootstrap()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_memberships jsonb;
  v_farms jsonb;
  v_heads jsonb := '{}'::jsonb;
  r record;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  select coalesce(jsonb_agg(to_jsonb(fm)), '[]'::jsonb)
  into v_memberships
  from public.farm_members fm
  where fm.user_id = v_uid and fm.deleted_at is null;

  select coalesce(jsonb_agg(to_jsonb(f)), '[]'::jsonb)
  into v_farms
  from public.farms f
  where public.is_farm_member(f.id)
    and f.deleted_at is null;

  for r in
    select scope, last_version from public.sync_counters
    where scope = 'reference'
       or scope in (select f.id::text from public.farms f where public.is_farm_member(f.id))
  loop
    v_heads := v_heads || jsonb_build_object(r.scope, r.last_version);
  end loop;

  return jsonb_build_object(
    'memberships', v_memberships,
    'farms', v_farms,
    'heads', v_heads,
    'epoch', public.sync_epoch()
  );
end;
$$;

create or replace function public.sync_head(p_scopes text[])
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  s text;
  out jsonb := '{}'::jsonb;
  v bigint;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  foreach s in array p_scopes loop
    if s = 'reference' then
      select last_version into v from public.sync_counters where scope = 'reference';
      out := out || jsonb_build_object(s, coalesce(v, 0));
    elsif public.is_farm_member(s::uuid, array['owner','manager','worker','viewer']) then
      select last_version into v from public.sync_counters where scope = s;
      out := out || jsonb_build_object(s, coalesce(v, 0));
    else
      raise exception 'forbidden scope %', s using errcode = '42501';
    end if;
  end loop;

  return out || jsonb_build_object('epoch', public.sync_epoch());
end;
$$;

create or replace function public.sync_pull(
  p_scope text,
  p_since bigint,
  p_limit int default 500
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 500), 1), 1000);
  v_rows jsonb;
  v_has_more boolean;
  v_next bigint;
  v_sql text;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if p_scope = 'reference' then
    null;
  elsif not public.is_farm_member(p_scope::uuid, array['owner','manager','worker','viewer']) then
    raise exception 'forbidden scope %', p_scope using errcode = '42501';
  end if;

  v_sql := $q$
    with stream as (
      select 'batches'::text as table_name, server_version, to_jsonb(t) as row
      from public.batches t
      where ($1 = 'reference' and false)
         or (t.farm_id::text = $1 and t.server_version > $2)
      union all
      select 'vaccination_tasks', server_version, to_jsonb(t)
      from public.vaccination_tasks t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'feed_items', server_version, to_jsonb(t)
      from public.feed_items t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'feed_transactions', server_version, to_jsonb(t)
      from public.feed_transactions t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'health_records', server_version, to_jsonb(t)
      from public.health_records t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'mortality_records', server_version, to_jsonb(t)
      from public.mortality_records t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'farm_events', server_version, to_jsonb(t)
      from public.farm_events t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'farms', server_version, to_jsonb(t)
      from public.farms t
      where t.id::text = $1 and t.server_version > $2
      union all
      select 'programmes', server_version, to_jsonb(t)
      from public.programmes t
      where $1 = 'reference' and t.server_version > $2
      union all
      select 'programme_steps', server_version, to_jsonb(t)
      from public.programme_steps t
      where $1 = 'reference' and t.server_version > $2
    ),
    ordered as (
      select * from stream order by server_version asc limit $3 + 1
    )
    select coalesce(jsonb_agg(jsonb_build_object(
      'table', table_name,
      'server_version', server_version,
      'row', row
    ) order by server_version), '[]'::jsonb),
    (select count(*) > $3 from ordered),
    (select server_version from ordered order by server_version desc offset $3 limit 1)
    from (select * from ordered limit $3) page;
  $q$;

  execute v_sql into v_rows, v_has_more, v_next using p_scope, p_since, v_limit;

  return jsonb_build_object(
    'rows', coalesce(v_rows, '[]'::jsonb),
    'next_cursor', coalesce(v_next, p_since),
    'has_more', coalesce(v_has_more, false),
    'epoch', public.sync_epoch()
  );
end;
$$;

create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
  v_sql text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            -- new farm: allowed for authenticated user creating self as owner
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          product_used = excluded.product_used,
          notes = excluded.notes,
          deleted_at = excluded.deleted_at
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

grant execute on function public.sync_bootstrap() to authenticated;
grant execute on function public.sync_head(text[]) to authenticated;
grant execute on function public.sync_pull(text, bigint, int) to authenticated;
grant execute on function public.sync_push(jsonb) to authenticated;

-- =============================================================================
-- 0004_signup_profiles_create_farm.sql
-- =============================================================================

-- Sign-up without a farm; profile + farm created in a later step.

-- ---------------------------------------------------------------------------
-- Profiles (auth.users companion)
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name, phone)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'display_name',
      nullif(split_part(coalesce(new.email, ''), '@', 1), '')
    ),
    new.phone
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Create first farm (post sign-up onboarding)
-- ---------------------------------------------------------------------------

create or replace function public.create_farm(
  p_name text,
  p_location text,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid := gen_random_uuid();
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;

  if nullif(trim(p_location), '') is null then
    raise exception 'farm location is required';
  end if;

  insert into public.farms (id, farm_id, name, location, notes, created_by)
  values (
    v_farm_id,
    v_farm_id,
    trim(p_name),
    trim(p_location),
    nullif(trim(coalesce(p_notes, '')), ''),
    v_user
  );

  insert into public.farm_members (id, farm_id, user_id, role)
  values (gen_random_uuid(), v_farm_id, v_user, 'owner');

  perform public.bump_sync_server_version(v_farm_id::text);

  return v_farm_id;
end;
$$;

revoke all on function public.create_farm(text, text, text) from public;
grant execute on function public.create_farm(text, text, text) to authenticated;

-- =============================================================================
-- 0005_farm_profile_fields.sql
-- =============================================================================

-- Farm profile fields (contact + location detail). Completion is optional at sign-up.

alter table public.farms
  add column if not exists district text,
  add column if not exists village text,
  add column if not exists phone text,
  add column if not exists alt_phone text,
  add column if not exists profile_completed_at timestamptz;

-- Replace create_farm with full profile save (create or update owner's farm).
drop function if exists public.create_farm(text, text, text);

create or replace function public.save_farm_profile(
  p_name text,
  p_district text,
  p_village text,
  p_phone text,
  p_alt_phone text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid;
  v_location text;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;
  if nullif(trim(p_district), '') is null then
    raise exception 'district is required';
  end if;
  if nullif(trim(p_village), '') is null then
    raise exception 'village is required';
  end if;
  if nullif(trim(p_phone), '') is null then
    raise exception 'phone is required';
  end if;

  v_location := trim(p_district) || ', ' || trim(p_village);

  select f.id into v_farm_id
  from public.farms f
  join public.farm_members fm on fm.farm_id = f.id and fm.deleted_at is null
  where fm.user_id = v_user and fm.role = 'owner'
  order by f.created_at
  limit 1;

  if v_farm_id is null then
    v_farm_id := gen_random_uuid();
    insert into public.farms (
      id, farm_id, name, location, district, village, phone, alt_phone, notes,
      created_by, profile_completed_at
    )
    values (
      v_farm_id,
      v_farm_id,
      trim(p_name),
      v_location,
      trim(p_district),
      trim(p_village),
      trim(p_phone),
      nullif(trim(coalesce(p_alt_phone, '')), ''),
      nullif(trim(coalesce(p_notes, '')), ''),
      v_user,
      now()
    );
    insert into public.farm_members (id, farm_id, user_id, role)
    values (gen_random_uuid(), v_farm_id, v_user, 'owner');
  else
    update public.farms
    set
      name = trim(p_name),
      location = v_location,
      district = trim(p_district),
      village = trim(p_village),
      phone = trim(p_phone),
      alt_phone = nullif(trim(coalesce(p_alt_phone, '')), ''),
      notes = nullif(trim(coalesce(p_notes, '')), ''),
      profile_completed_at = now(),
      updated_at = now()
    where id = v_farm_id;
  end if;

  perform public.bump_sync_server_version(v_farm_id::text);
  return v_farm_id;
end;
$$;

revoke all on function public.save_farm_profile(text, text, text, text, text, text) from public;
grant execute on function public.save_farm_profile(text, text, text, text, text, text) to authenticated;

-- Backward-compatible alias
create or replace function public.create_farm(
  p_name text,
  p_location text,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  parts text[];
begin
  parts := string_to_array(coalesce(p_location, ''), ',');
  return public.save_farm_profile(
    p_name,
    coalesce(nullif(trim(parts[1]), ''), 'Unknown'),
    coalesce(nullif(trim(parts[2]), ''), trim(p_location)),
    '0000000000',
    null,
    p_notes
  );
end;
$$;

grant execute on function public.create_farm(text, text, text) to authenticated;

-- =============================================================================
-- 0006_batch_planner_sync_fields.sql
-- =============================================================================

-- Align Supabase with Drift batch planner + full task payloads.
-- Run via: supabase db push  OR paste into Supabase SQL Editor (Dashboard).

-- ---------------------------------------------------------------------------
-- Columns (match lib/data_platform/db/tables/*.dart)
-- ---------------------------------------------------------------------------

alter table public.batches
  add column if not exists production_type text,
  add column if not exists programme_content_hash text;

alter table public.vaccination_tasks
  add column if not exists occurrence integer not null default 0,
  add column if not exists enabled boolean not null default true,
  add column if not exists done_by text,
  add column if not exists step_snapshot text,
  add column if not exists programme_content_hash text,
  add column if not exists shifted_from date;

-- App schedule uses asset step ids (e.g. BR-D14), not programme_steps rows.
alter table public.vaccination_tasks
  drop constraint if exists vaccination_tasks_step_id_fkey;

comment on column public.vaccination_tasks.step_id is
  'Schedule catalogue step id from the mobile app.';

-- ---------------------------------------------------------------------------
-- sync_push: full upsert for batches + vaccination_tasks (new columns)
-- ---------------------------------------------------------------------------

create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
  v_sql text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'batches' then
        insert into public.batches
        select * from jsonb_populate_record(null::public.batches, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          name = excluded.name,
          bird_type = excluded.bird_type,
          initial_count = excluded.initial_count,
          acquired_on = excluded.acquired_on,
          age_at_acquisition_days = excluded.age_at_acquisition_days,
          hatchery_vaccinated = excluded.hatchery_vaccinated,
          source = excluded.source,
          status = excluded.status,
          programme_id = excluded.programme_id,
          programme_version = excluded.programme_version,
          production_type = excluded.production_type,
          programme_content_hash = excluded.programme_content_hash,
          notes = excluded.notes,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(batches.*) into v_existing;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          step_id = excluded.step_id,
          occurrence = excluded.occurrence,
          due_on = excluded.due_on,
          enabled = excluded.enabled,
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          done_by = excluded.done_by,
          product_used = excluded.product_used,
          notes = excluded.notes,
          step_snapshot = coalesce(excluded.step_snapshot, vaccination_tasks.step_snapshot),
          programme_content_hash = coalesce(
            excluded.programme_content_hash,
            vaccination_tasks.programme_content_hash
          ),
          shifted_from = excluded.shifted_from,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      elsif v_table = 'vet_assistance_requests' then
        if coalesce(v_payload->>'status', 'submitted') not in (
          'draft', 'pending_sync', 'submitted', 'cancelled'
        ) then
          raise exception 'forbidden status for farmer push' using errcode = '42501';
        end if;
        insert into public.vet_assistance_requests
        select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          health_record_id = excluded.health_record_id,
          service_type = excluded.service_type,
          status = excluded.status,
          share_location = excluded.share_location,
          priority = excluded.priority,
          farmer_notes = excluded.farmer_notes,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vet_assistance_requests.*) into v_existing;
      elsif v_table = 'farms' then
        insert into public.farms
        select * from jsonb_populate_record(null::public.farms, v_payload)
        on conflict (id) do update set
          name = coalesce(excluded.name, farms.name),
          location = coalesce(excluded.location, farms.location),
          notes = coalesce(excluded.notes, farms.notes),
          district = coalesce(excluded.district, farms.district),
          village = coalesce(excluded.village, farms.village),
          phone = coalesce(excluded.phone, farms.phone),
          alt_phone = coalesce(excluded.alt_phone, farms.alt_phone),
          latitude = coalesce(excluded.latitude, farms.latitude),
          longitude = coalesce(excluded.longitude, farms.longitude),
          location_accuracy_m = coalesce(
            excluded.location_accuracy_m,
            farms.location_accuracy_m
          ),
          location_captured_at = coalesce(
            excluded.location_captured_at,
            farms.location_captured_at
          ),
          updated_at = now()
        returning to_jsonb(farms.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

-- =============================================================================
-- 0007_rbac_roles.sql
-- =============================================================================

-- RBAC: farmer vs veterinary professional at account creation (immutable role).
-- NOTE: role helper functions MUST exist before policies that reference them.

-- ---------------------------------------------------------------------------
-- profiles.app_role
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists app_role text not null default 'farmer';

alter table public.profiles drop constraint if exists profiles_app_role_check;
alter table public.profiles add constraint profiles_app_role_check
  check (app_role in ('farmer', 'vet'));

create or replace function public.profiles_lock_app_role()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and old.app_role is distinct from new.app_role then
    raise exception 'app_role cannot be changed after registration'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_lock_app_role on public.profiles;
create trigger profiles_lock_app_role
  before update on public.profiles
  for each row execute function public.profiles_lock_app_role();

-- ---------------------------------------------------------------------------
-- Role helpers (before any policy references them)
-- ---------------------------------------------------------------------------

create or replace function public.current_app_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.app_role from public.profiles p where p.user_id = (select auth.uid())),
    'farmer'
  );
$$;

create or replace function public.is_vet()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'vet';
$$;

create or replace function public.is_farmer()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'farmer';
$$;

revoke all on function public.current_app_role() from public;
grant execute on function public.current_app_role() to authenticated;

revoke all on function public.is_vet() from public;
grant execute on function public.is_vet() to authenticated;

revoke all on function public.is_farmer() from public;
grant execute on function public.is_farmer() to authenticated;

-- ---------------------------------------------------------------------------
-- Vet profile stub
-- ---------------------------------------------------------------------------

create table if not exists public.vet_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  organization text,
  offers_consultation boolean not null default true,
  offers_farm_visit boolean not null default true,
  poultry_specialist boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.vet_profiles enable row level security;

drop policy if exists vet_profiles_select_own on public.vet_profiles;
create policy vet_profiles_select_own on public.vet_profiles
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists vet_profiles_insert_own on public.vet_profiles;
create policy vet_profiles_insert_own on public.vet_profiles
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and public.current_app_role() = 'vet'
  );

drop policy if exists vet_profiles_update_own on public.vet_profiles;
create policy vet_profiles_update_own on public.vet_profiles
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- Sign-up trigger
-- ---------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text := coalesce(new.raw_user_meta_data->>'app_role', 'farmer');
  v_name text := coalesce(
    new.raw_user_meta_data->>'display_name',
    nullif(split_part(coalesce(new.email, ''), '@', 1), '')
  );
begin
  if v_role not in ('farmer', 'vet') then
    v_role := 'farmer';
  end if;

  insert into public.profiles (user_id, display_name, phone, app_role)
  values (new.id, v_name, new.phone, v_role)
  on conflict (user_id) do nothing;

  if v_role = 'vet' then
    insert into public.vet_profiles (user_id, display_name)
    values (new.id, v_name)
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Farmers only: create_farm
-- ---------------------------------------------------------------------------

create or replace function public.create_farm(
  p_name text,
  p_location text,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid := gen_random_uuid();
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if public.current_app_role() <> 'farmer' then
    raise exception 'only farmers can create farms' using errcode = '42501';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;

  if nullif(trim(p_location), '') is null then
    raise exception 'farm location is required';
  end if;

  insert into public.farms (id, farm_id, name, location, notes, created_by)
  values (
    v_farm_id,
    v_farm_id,
    trim(p_name),
    trim(p_location),
    nullif(trim(coalesce(p_notes, '')), ''),
    v_user
  );

  insert into public.farm_members (id, farm_id, user_id, role)
  values (gen_random_uuid(), v_farm_id, v_user, 'owner');

  perform public.bump_sync_server_version(v_farm_id::text);

  return v_farm_id;
end;
$$;

-- =============================================================================
-- 0007_rbac_roles_fix.sql
-- =============================================================================

-- Run this if 0007 failed partway (policies before functions).
-- Safe to run on a DB that already applied the corrected 0007.

create or replace function public.current_app_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.app_role from public.profiles p where p.user_id = (select auth.uid())),
    'farmer'
  );
$$;

create or replace function public.is_vet()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'vet';
$$;

create or replace function public.is_farmer()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'farmer';
$$;

grant execute on function public.current_app_role() to authenticated;
grant execute on function public.is_vet() to authenticated;
grant execute on function public.is_farmer() to authenticated;

drop policy if exists vet_profiles_insert_own on public.vet_profiles;
create policy vet_profiles_insert_own on public.vet_profiles
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and public.current_app_role() = 'vet'
  );

-- =============================================================================
-- 0008_vet_phase1_health_requests.sql
-- =============================================================================

-- Vet Phase 1: farm GPS, structured health records, assistance requests, vet inbox RPC.

-- ---------------------------------------------------------------------------
-- Farm GPS (mutable via sync)
-- ---------------------------------------------------------------------------

alter table public.farms
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists location_accuracy_m real,
  add column if not exists location_captured_at timestamptz;

-- ---------------------------------------------------------------------------
-- Health records (append-only, extended)
-- ---------------------------------------------------------------------------

alter table public.health_records
  add column if not exists affected_bird_count integer,
  add column if not exists symptoms jsonb not null default '[]'::jsonb,
  add column if not exists record_kind text not null default 'observation';

alter table public.health_records drop constraint if exists health_records_record_kind_check;
alter table public.health_records add constraint health_records_record_kind_check
  check (record_kind in ('observation', 'follow_up', 'vet_consultation'));

-- ---------------------------------------------------------------------------
-- Veterinary assistance requests (mutable workflow)
-- ---------------------------------------------------------------------------

create table if not exists public.vet_assistance_requests (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  batch_id uuid not null references public.batches (id),
  health_record_id uuid not null references public.health_records (id),
  service_type text not null check (
    service_type in ('consultation', 'farm_visit', 'either')
  ),
  status text not null check (
    status in (
      'draft',
      'pending_sync',
      'submitted',
      'received',
      'accepted',
      'declined',
      'in_progress',
      'completed',
      'cancelled'
    )
  ),
  share_location boolean not null default false,
  priority text not null default 'normal',
  farmer_notes text,
  assigned_vet_user_id uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create index if not exists vet_requests_farm_version_idx
  on public.vet_assistance_requests (farm_id, server_version);

create index if not exists vet_requests_status_idx
  on public.vet_assistance_requests (status, created_at desc);

create trigger vet_assistance_requests_assign_version
  before insert or update on public.vet_assistance_requests
  for each row execute function public.assign_sync_server_version();

-- ---------------------------------------------------------------------------
-- Vet consultations (append-only responses)
-- ---------------------------------------------------------------------------

create table if not exists public.vet_consultations (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  request_id uuid not null references public.vet_assistance_requests (id),
  vet_user_id uuid not null references auth.users (id),
  message text,
  assessment text,
  follow_up_required boolean not null default false,
  follow_up_on date,
  farm_visit_required boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint
);

create index if not exists vet_consultations_farm_version_idx
  on public.vet_consultations (farm_id, server_version);

create trigger vet_consultations_assign_version
  before insert or update on public.vet_consultations
  for each row execute function public.assign_sync_server_version();

-- ---------------------------------------------------------------------------
-- sync_table_config
-- ---------------------------------------------------------------------------

insert into public.sync_table_config (table_name, kind, scope_kind, writable_columns)
values
  (
    'vet_assistance_requests',
    'mutable',
    'farm',
    array[
      'id','farm_id','batch_id','health_record_id','service_type','status',
      'share_location','priority','farmer_notes','created_at'
    ]
  ),
  (
    'vet_consultations',
    'append_only',
    'farm',
    array[
      'id','farm_id','request_id','vet_user_id','message','assessment',
      'follow_up_required','follow_up_on','farm_visit_required','created_at'
    ]
  )
on conflict (table_name) do update set
  kind = excluded.kind,
  scope_kind = excluded.scope_kind,
  writable_columns = excluded.writable_columns;

update public.sync_table_config
set writable_columns = array[
  'id','name','location','notes','district','village','phone','alt_phone',
  'latitude','longitude','location_accuracy_m','location_captured_at','created_at'
]
where table_name = 'farms';

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','batch_id','occurred_on','summary','notes',
  'affected_bird_count','symptoms','record_kind','created_at'
]
where table_name = 'health_records';

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.vet_assistance_requests enable row level security;
alter table public.vet_consultations enable row level security;

drop policy if exists vet_requests_farmer_select on public.vet_assistance_requests;
create policy vet_requests_farmer_select on public.vet_assistance_requests
  for select to authenticated
  using (
    public.is_farm_member(farm_id)
    or (
      public.is_vet()
      and status not in ('draft', 'pending_sync', 'cancelled')
    )
  );

drop policy if exists vet_consultations_select on public.vet_consultations;
create policy vet_consultations_select on public.vet_consultations
  for select to authenticated
  using (
    public.is_farm_member(farm_id)
    or public.is_vet()
  );

revoke insert, update, delete on public.vet_assistance_requests from authenticated;
revoke insert, update, delete on public.vet_consultations from authenticated;

-- ---------------------------------------------------------------------------
-- Vet inbox + status RPCs (vet portal / vet app)
-- ---------------------------------------------------------------------------

create or replace function public.vet_inbox(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(to_jsonb(r) order by r.created_at desc), '[]'::jsonb)
  into v_rows
  from (
    select *
    from public.vet_assistance_requests r
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
    order by r.created_at desc
    limit v_limit
  ) r;

  return jsonb_build_object('requests', v_rows);
end;
$$;

create or replace function public.vet_set_request_status(
  p_request_id uuid,
  p_status text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.vet_assistance_requests;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_status not in ('received', 'accepted', 'declined', 'in_progress', 'completed') then
    raise exception 'invalid status';
  end if;

  update public.vet_assistance_requests
  set
    status = p_status,
    assigned_vet_user_id = coalesce(assigned_vet_user_id, auth.uid()),
    updated_at = now()
  where id = p_request_id
    and deleted_at is null
  returning * into v_row;

  if v_row.id is null then
    raise exception 'request not found';
  end if;

  return to_jsonb(v_row);
end;
$$;

grant execute on function public.vet_inbox(int) to authenticated;
grant execute on function public.vet_set_request_status(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Extend sync_pull stream (vet_assistance_requests + vet_consultations)
-- ---------------------------------------------------------------------------

create or replace function public.sync_pull(
  p_scope text,
  p_since bigint,
  p_limit int default 500
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 500), 1), 1000);
  v_rows jsonb;
  v_has_more boolean;
  v_next bigint;
  v_sql text;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  if p_scope = 'reference' then
    null;
  elsif not public.is_farm_member(p_scope::uuid, array['owner','manager','worker','viewer']) then
    raise exception 'forbidden scope %', p_scope using errcode = '42501';
  end if;

  v_sql := $q$
    with stream as (
      select 'batches'::text as table_name, server_version, to_jsonb(t) as row
      from public.batches t
      where ($1 = 'reference' and false)
         or (t.farm_id::text = $1 and t.server_version > $2)
      union all
      select 'vaccination_tasks', server_version, to_jsonb(t)
      from public.vaccination_tasks t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'health_records', server_version, to_jsonb(t)
      from public.health_records t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'vet_assistance_requests', server_version, to_jsonb(t)
      from public.vet_assistance_requests t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'vet_consultations', server_version, to_jsonb(t)
      from public.vet_consultations t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'feed_items', server_version, to_jsonb(t)
      from public.feed_items t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'feed_transactions', server_version, to_jsonb(t)
      from public.feed_transactions t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'mortality_records', server_version, to_jsonb(t)
      from public.mortality_records t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'farm_events', server_version, to_jsonb(t)
      from public.farm_events t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'farms', server_version, to_jsonb(t)
      from public.farms t
      where t.id::text = $1 and t.server_version > $2
      union all
      select 'programmes', server_version, to_jsonb(t)
      from public.programmes t
      where $1 = 'reference' and t.server_version > $2
      union all
      select 'programme_steps', server_version, to_jsonb(t)
      from public.programme_steps t
      where $1 = 'reference' and t.server_version > $2
    ),
    ordered as (
      select * from stream order by server_version asc limit $3 + 1
    )
    select coalesce(jsonb_agg(jsonb_build_object(
      'table', table_name,
      'server_version', server_version,
      'row', row
    ) order by server_version), '[]'::jsonb),
    (select count(*) > $3 from ordered),
    (select server_version from ordered order by server_version desc offset $3 limit 1)
    from (select * from ordered limit $3) page;
  $q$;

  execute v_sql into v_rows, v_has_more, v_next using p_scope, p_since, v_limit;

  return jsonb_build_object(
    'rows', coalesce(v_rows, '[]'::jsonb),
    'next_cursor', coalesce(v_next, p_since),
    'has_more', coalesce(v_has_more, false),
    'epoch', public.sync_epoch()
  );
end;
$$;

-- =============================================================================
-- 0009_sync_push_vet_phase1.sql
-- =============================================================================

-- Replaces sync_push with vet + farm GPS upsert branches (idempotent).
create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
  v_sql text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'batches' then
        insert into public.batches
        select * from jsonb_populate_record(null::public.batches, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          name = excluded.name,
          bird_type = excluded.bird_type,
          initial_count = excluded.initial_count,
          acquired_on = excluded.acquired_on,
          age_at_acquisition_days = excluded.age_at_acquisition_days,
          hatchery_vaccinated = excluded.hatchery_vaccinated,
          source = excluded.source,
          status = excluded.status,
          programme_id = excluded.programme_id,
          programme_version = excluded.programme_version,
          production_type = excluded.production_type,
          programme_content_hash = excluded.programme_content_hash,
          notes = excluded.notes,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(batches.*) into v_existing;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          step_id = excluded.step_id,
          occurrence = excluded.occurrence,
          due_on = excluded.due_on,
          enabled = excluded.enabled,
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          done_by = excluded.done_by,
          product_used = excluded.product_used,
          notes = excluded.notes,
          step_snapshot = coalesce(excluded.step_snapshot, vaccination_tasks.step_snapshot),
          programme_content_hash = coalesce(
            excluded.programme_content_hash,
            vaccination_tasks.programme_content_hash
          ),
          shifted_from = excluded.shifted_from,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      elsif v_table = 'vet_assistance_requests' then
        if coalesce(v_payload->>'status', 'submitted') not in (
          'draft', 'pending_sync', 'submitted', 'cancelled'
        ) then
          raise exception 'forbidden status for farmer push' using errcode = '42501';
        end if;
        insert into public.vet_assistance_requests
        select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          health_record_id = excluded.health_record_id,
          service_type = excluded.service_type,
          status = excluded.status,
          share_location = excluded.share_location,
          priority = excluded.priority,
          farmer_notes = excluded.farmer_notes,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vet_assistance_requests.*) into v_existing;
      elsif v_table = 'farms' then
        insert into public.farms
        select * from jsonb_populate_record(null::public.farms, v_payload)
        on conflict (id) do update set
          name = coalesce(excluded.name, farms.name),
          location = coalesce(excluded.location, farms.location),
          notes = coalesce(excluded.notes, farms.notes),
          district = coalesce(excluded.district, farms.district),
          village = coalesce(excluded.village, farms.village),
          phone = coalesce(excluded.phone, farms.phone),
          alt_phone = coalesce(excluded.alt_phone, farms.alt_phone),
          latitude = coalesce(excluded.latitude, farms.latitude),
          longitude = coalesce(excluded.longitude, farms.longitude),
          location_accuracy_m = coalesce(
            excluded.location_accuracy_m,
            farms.location_accuracy_m
          ),
          location_captured_at = coalesce(
            excluded.location_captured_at,
            farms.location_captured_at
          ),
          updated_at = now()
        returning to_jsonb(farms.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

-- =============================================================================
-- 0010_save_farm_profile_farmer.sql
-- =============================================================================

-- Farmers only for save_farm_profile (vets use vet_profiles, not farms).

create or replace function public.save_farm_profile(
  p_name text,
  p_district text,
  p_village text,
  p_phone text,
  p_alt_phone text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_farm_id uuid;
  v_location text;
begin
  if v_user is null then
    raise exception 'not authenticated';
  end if;

  if public.current_app_role() <> 'farmer' then
    raise exception 'only farmers can save a farm profile' using errcode = '42501';
  end if;

  if nullif(trim(p_name), '') is null then
    raise exception 'farm name is required';
  end if;
  if nullif(trim(p_district), '') is null then
    raise exception 'district is required';
  end if;
  if nullif(trim(p_village), '') is null then
    raise exception 'village is required';
  end if;
  if nullif(trim(p_phone), '') is null then
    raise exception 'phone is required';
  end if;

  v_location := trim(p_district) || ', ' || trim(p_village);

  select f.id into v_farm_id
  from public.farms f
  join public.farm_members fm on fm.farm_id = f.id and fm.deleted_at is null
  where fm.user_id = v_user and fm.role = 'owner'
  order by f.created_at
  limit 1;

  if v_farm_id is null then
    v_farm_id := gen_random_uuid();
    insert into public.farms (
      id, farm_id, name, location, district, village, phone, alt_phone, notes,
      created_by, profile_completed_at
    )
    values (
      v_farm_id,
      v_farm_id,
      trim(p_name),
      v_location,
      trim(p_district),
      trim(p_village),
      trim(p_phone),
      nullif(trim(coalesce(p_alt_phone, '')), ''),
      nullif(trim(coalesce(p_notes, '')), ''),
      v_user,
      now()
    );
    insert into public.farm_members (id, farm_id, user_id, role)
    values (gen_random_uuid(), v_farm_id, v_user, 'owner');
  else
    update public.farms
    set
      name = trim(p_name),
      location = v_location,
      district = trim(p_district),
      village = trim(p_village),
      phone = trim(p_phone),
      alt_phone = nullif(trim(coalesce(p_alt_phone, '')), ''),
      notes = nullif(trim(coalesce(p_notes, '')), ''),
      profile_completed_at = now(),
      updated_at = now()
    where id = v_farm_id;
  end if;

  perform public.bump_sync_server_version(v_farm_id::text);
  return v_farm_id;
end;
$$;

grant execute on function public.save_farm_profile(text, text, text, text, text, text) to authenticated;

-- =============================================================================
-- 0011_health_incident_storage.sql
-- =============================================================================

-- Incident photos (Supabase Storage) + vet map RPC with farm GPS + health context.

-- ---------------------------------------------------------------------------
-- Health records: photo object keys (storage paths, synced)
-- ---------------------------------------------------------------------------

alter table public.health_records
  add column if not exists photo_object_keys jsonb not null default '[]'::jsonb;

alter table public.health_records drop constraint if exists health_records_record_kind_check;
alter table public.health_records add constraint health_records_record_kind_check
  check (record_kind in ('observation', 'incident', 'follow_up', 'vet_consultation'));

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','batch_id','occurred_on','summary','notes','created_at',
  'affected_bird_count','symptoms','record_kind','photo_object_keys'
]
where table_name = 'health_records';

-- ---------------------------------------------------------------------------
-- Storage bucket: health-incident-images (private)
-- Object path: {user_id}/{health_record_id}/{uuid}.jpg
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'health-incident-images',
  'health-incident-images',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists health_incident_images_insert on storage.objects;
drop policy if exists health_incident_images_select_owner on storage.objects;
drop policy if exists health_incident_images_select_vet on storage.objects;

create policy health_incident_images_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'health-incident-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy health_incident_images_select_owner on storage.objects
  for select to authenticated
  using (
    bucket_id = 'health-incident-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy health_incident_images_select_vet on storage.objects
  for select to authenticated
  using (
    bucket_id = 'health-incident-images'
    and public.is_vet()
  );

-- ---------------------------------------------------------------------------
-- Vet map: open requests with location + incident details
-- ---------------------------------------------------------------------------

create or replace function public.vet_request_map(p_limit int default 100)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'priority', r.priority,
      'share_location', r.share_location,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'latitude', f.latitude,
      'longitude', f.longitude
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

grant execute on function public.vet_request_map(int) to authenticated;

-- Richer vet inbox (incident summary + symptoms from health record).
create or replace function public.vet_inbox(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'share_location', r.share_location,
      'priority', r.priority,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

-- =============================================================================
-- 0012_vet_routing_gps.sql
-- =============================================================================

-- Vet GPS on profiles, farmer-directed routing, directory RPC, inbox filtering.

alter table public.vet_profiles
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists location_accuracy_m real,
  add column if not exists location_captured_at timestamptz,
  add column if not exists district text;

alter table public.vet_assistance_requests
  add column if not exists requested_vet_user_id uuid references auth.users (id);

create index if not exists vet_requests_requested_vet_idx
  on public.vet_assistance_requests (requested_vet_user_id, status);

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','batch_id','health_record_id','service_type','status',
  'share_location','priority','farmer_notes','requested_vet_user_id','created_at'
]
where table_name = 'vet_assistance_requests';

drop policy if exists vet_profiles_select_farmer on public.vet_profiles;
create policy vet_profiles_select_farmer on public.vet_profiles
  for select to authenticated
  using (
    user_id = (select auth.uid())
    or public.current_app_role() = 'farmer'
  );

create or replace function public.save_vet_location(
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy_m real default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  update public.vet_profiles
  set
    latitude = p_latitude,
    longitude = p_longitude,
    location_accuracy_m = p_accuracy_m,
    location_captured_at = now(),
    updated_at = now()
  where user_id = auth.uid();

  if not found then
    insert into public.vet_profiles (user_id, latitude, longitude, location_accuracy_m, location_captured_at)
    values (auth.uid(), p_latitude, p_longitude, p_accuracy_m, now());
  end if;

  return jsonb_build_object(
    'latitude', p_latitude,
    'longitude', p_longitude,
    'location_accuracy_m', p_accuracy_m,
    'location_captured_at', now()
  );
end;
$$;

grant execute on function public.save_vet_location(double precision, double precision, real) to authenticated;

create or replace function public.list_available_vets(p_farm_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_farm_lat double precision;
  v_farm_lon double precision;
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if public.current_app_role() <> 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    select f.latitude, f.longitude into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id', v.user_id,
      'display_name', coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization', v.organization,
      'district', v.district,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit', v.offers_farm_visit,
      'latitude', v.latitude,
      'longitude', v.longitude,
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(v_farm_lat)) * cos(radians(v.latitude))
                * cos(radians(v.longitude) - radians(v_farm_lon))
                + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
              ))
            )
          )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

grant execute on function public.list_available_vets(uuid) to authenticated;

-- Inbox: broadcast (no requested vet) or directed to this vet.
create or replace function public.vet_inbox(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'share_location', r.share_location,
      'priority', r.priority,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'requested_vet_user_id', r.requested_vet_user_id,
      'assigned_vet_user_id', r.assigned_vet_user_id,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'farm_latitude', f.latitude,
      'farm_longitude', f.longitude,
      'distance_km', case
        when f.latitude is not null and f.longitude is not null
          and vp.latitude is not null and vp.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(vp.latitude)) * cos(radians(f.latitude))
                * cos(radians(f.longitude) - radians(vp.longitude))
                + sin(radians(vp.latitude)) * sin(radians(f.latitude))
              ))
            )
          )
        else null
      end
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    left join public.vet_profiles vp on vp.user_id = auth.uid()
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
      and (
        r.requested_vet_user_id is null
        or r.requested_vet_user_id = auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

-- =============================================================================
-- 0013_vet_request_visibility.sql
-- =============================================================================


create or replace function public.vet_can_view_request(
  p_assigned uuid,
  p_requested uuid,
  p_viewer uuid
)
returns boolean
language sql
immutable
as $$
  select
    (p_assigned is not null and p_assigned = p_viewer)
    or (
      p_assigned is null
      and (p_requested is null or p_requested = p_viewer)
    );
$$;

create or replace function public.vet_set_request_status(
  p_request_id uuid,
  p_status text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.vet_assistance_requests;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_status not in ('received', 'accepted', 'declined', 'in_progress', 'completed') then
    raise exception 'invalid status';
  end if;

  update public.vet_assistance_requests
  set
    status = p_status,
    assigned_vet_user_id = case
      when p_status in ('accepted', 'in_progress', 'completed') then
        coalesce(assigned_vet_user_id, auth.uid())
      else assigned_vet_user_id
    end,
    updated_at = now()
  where id = p_request_id
    and deleted_at is null
    and public.vet_can_view_request(
      assigned_vet_user_id,
      requested_vet_user_id,
      auth.uid()
    )
    and (
      assigned_vet_user_id is null
      or assigned_vet_user_id = auth.uid()
      or p_status = 'declined'
    )
  returning * into v_row;

  if v_row.id is null then
    raise exception 'request not found or not available';
  end if;

  return to_jsonb(v_row);
end;
$$;

create or replace function public.vet_inbox(p_limit int default 50)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'share_location', r.share_location,
      'priority', r.priority,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'requested_vet_user_id', r.requested_vet_user_id,
      'assigned_vet_user_id', r.assigned_vet_user_id,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'farm_latitude', f.latitude,
      'farm_longitude', f.longitude,
      'distance_km', case
        when f.latitude is not null and f.longitude is not null
          and vp.latitude is not null and vp.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(vp.latitude)) * cos(radians(f.latitude))
                * cos(radians(f.longitude) - radians(vp.longitude))
                + sin(radians(vp.latitude)) * sin(radians(f.latitude))
              ))
            )
          )
        else null
      end
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    left join public.vet_profiles vp on vp.user_id = auth.uid()
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
      and public.vet_can_view_request(
        r.assigned_vet_user_id,
        r.requested_vet_user_id,
        auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

create or replace function public.vet_request_map(p_limit int default 100)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'priority', r.priority,
      'share_location', r.share_location,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'requested_vet_user_id', r.requested_vet_user_id,
      'assigned_vet_user_id', r.assigned_vet_user_id,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'latitude', f.latitude,
      'longitude', f.longitude
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    where r.deleted_at is null
      and r.status in ('submitted', 'received', 'accepted', 'in_progress')
      and public.vet_can_view_request(
        r.assigned_vet_user_id,
        r.requested_vet_user_id,
        auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

grant execute on function public.vet_can_view_request(uuid, uuid, uuid) to authenticated;
grant execute on function public.vet_set_request_status(uuid, text) to authenticated;
grant execute on function public.vet_inbox(int) to authenticated;
grant execute on function public.vet_request_map(int) to authenticated;

-- =============================================================================
-- 0014_sync_push_vet_request_fields.sql
-- =============================================================================

-- sync_push: persist requested_vet on vet request upsert (0012 column).

create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
  v_sql text;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'batches' then
        insert into public.batches
        select * from jsonb_populate_record(null::public.batches, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          name = excluded.name,
          bird_type = excluded.bird_type,
          initial_count = excluded.initial_count,
          acquired_on = excluded.acquired_on,
          age_at_acquisition_days = excluded.age_at_acquisition_days,
          hatchery_vaccinated = excluded.hatchery_vaccinated,
          source = excluded.source,
          status = excluded.status,
          programme_id = excluded.programme_id,
          programme_version = excluded.programme_version,
          production_type = excluded.production_type,
          programme_content_hash = excluded.programme_content_hash,
          notes = excluded.notes,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(batches.*) into v_existing;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          step_id = excluded.step_id,
          occurrence = excluded.occurrence,
          due_on = excluded.due_on,
          enabled = excluded.enabled,
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          done_by = excluded.done_by,
          product_used = excluded.product_used,
          notes = excluded.notes,
          step_snapshot = coalesce(excluded.step_snapshot, vaccination_tasks.step_snapshot),
          programme_content_hash = coalesce(
            excluded.programme_content_hash,
            vaccination_tasks.programme_content_hash
          ),
          shifted_from = excluded.shifted_from,
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      elsif v_table = 'vet_assistance_requests' then
        if coalesce(v_payload->>'status', 'submitted') not in (
          'draft', 'pending_sync', 'submitted', 'cancelled'
        ) then
          raise exception 'forbidden status for farmer push' using errcode = '42501';
        end if;
        insert into public.vet_assistance_requests
        select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          health_record_id = excluded.health_record_id,
          service_type = excluded.service_type,
          status = excluded.status,
          share_location = excluded.share_location,
          priority = excluded.priority,
          farmer_notes = excluded.farmer_notes,
          requested_vet_user_id = coalesce(
            excluded.requested_vet_user_id,
            vet_assistance_requests.requested_vet_user_id
          ),
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vet_assistance_requests.*) into v_existing;
      elsif v_table = 'farms' then
        insert into public.farms
        select * from jsonb_populate_record(null::public.farms, v_payload)
        on conflict (id) do update set
          name = coalesce(excluded.name, farms.name),
          location = coalesce(excluded.location, farms.location),
          notes = coalesce(excluded.notes, farms.notes),
          district = coalesce(excluded.district, farms.district),
          village = coalesce(excluded.village, farms.village),
          phone = coalesce(excluded.phone, farms.phone),
          alt_phone = coalesce(excluded.alt_phone, farms.alt_phone),
          latitude = coalesce(excluded.latitude, farms.latitude),
          longitude = coalesce(excluded.longitude, farms.longitude),
          location_accuracy_m = coalesce(
            excluded.location_accuracy_m,
            farms.location_accuracy_m
          ),
          location_captured_at = coalesce(
            excluded.location_captured_at,
            farms.location_captured_at
          ),
          updated_at = now()
        returning to_jsonb(farms.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

-- =============================================================================
-- 0015_vet_request_map_all_statuses.sql
-- =============================================================================

-- Include completed (and in-progress) visits on the vet map, not only open queue.

create or replace function public.vet_request_map(p_limit int default 100)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := least(greatest(coalesce(p_limit, 100), 1), 200);
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select coalesce(jsonb_agg(row order by row->>'created_at' desc), '[]'::jsonb)
  into v_rows
  from (
    select jsonb_build_object(
      'id', r.id,
      'farm_id', r.farm_id,
      'batch_id', r.batch_id,
      'health_record_id', r.health_record_id,
      'service_type', r.service_type,
      'status', r.status,
      'priority', r.priority,
      'share_location', r.share_location,
      'farmer_notes', r.farmer_notes,
      'created_at', r.created_at,
      'requested_vet_user_id', r.requested_vet_user_id,
      'assigned_vet_user_id', r.assigned_vet_user_id,
      'summary', h.summary,
      'affected_bird_count', h.affected_bird_count,
      'symptoms', h.symptoms,
      'photo_object_keys', h.photo_object_keys,
      'farm_name', f.name,
      'farm_district', f.district,
      'farm_village', f.village,
      'latitude', f.latitude,
      'longitude', f.longitude
    ) as row
    from public.vet_assistance_requests r
    join public.health_records h on h.id = r.health_record_id and h.deleted_at is null
    join public.farms f on f.id = r.farm_id and f.deleted_at is null
    where r.deleted_at is null
      and r.status in (
        'submitted',
        'received',
        'accepted',
        'in_progress',
        'completed'
      )
      and public.vet_can_view_request(
        r.assigned_vet_user_id,
        r.requested_vet_user_id,
        auth.uid()
      )
    order by r.created_at desc
    limit v_limit
  ) s;

  return jsonb_build_object('requests', v_rows);
end;
$$;

-- =============================================================================
-- 0016_batch_management_losses.sql
-- =============================================================================

-- Batch management and editable loss records.
--
-- * batches: close fields (closed_on, close_reason, close_note) and deleted_group_id.
-- * vaccination_tasks: deleted_group_id (cascade soft delete with undo).
-- * mortality_records: becomes a MUTABLE synced table (was append_only) so farmers
--   can fix mistakes. Adds kind, suspected_cause, edited_at, deleted_group_id.
--   The old free-text `cause` is folded into notes and kept only for older clients.
-- * sync_push: mortality upsert branch (last write wins), close and group columns
--   on batches and tasks, and only owners or managers may change an existing batch.
--
-- Safe to run more than once.

-- ---------------------------------------------------------------------------
-- batches
-- ---------------------------------------------------------------------------
alter table public.batches
  add column if not exists closed_on date,
  add column if not exists close_reason text,
  add column if not exists close_note text,
  add column if not exists deleted_group_id uuid;

alter table public.batches drop constraint if exists batches_close_reason_check;
alter table public.batches
  add constraint batches_close_reason_check
  check (close_reason is null or close_reason in ('sold', 'cycle_complete', 'flock_lost', 'other'));

-- NOT VALID: enforce for new writes without rejecting any legacy rows.
alter table public.batches drop constraint if exists batches_status_check;
alter table public.batches
  add constraint batches_status_check
  check (status in ('active', 'closed')) not valid;

create index if not exists batches_farm_status_idx
  on public.batches (farm_id, status);
create index if not exists batches_deleted_group_idx
  on public.batches (deleted_group_id) where deleted_group_id is not null;

-- ---------------------------------------------------------------------------
-- vaccination_tasks
-- ---------------------------------------------------------------------------
alter table public.vaccination_tasks
  add column if not exists deleted_group_id uuid;

create index if not exists vaccination_tasks_deleted_group_idx
  on public.vaccination_tasks (deleted_group_id) where deleted_group_id is not null;

-- ---------------------------------------------------------------------------
-- mortality_records (loss records)
-- ---------------------------------------------------------------------------
alter table public.mortality_records
  add column if not exists kind text not null default 'died',
  add column if not exists suspected_cause text,
  add column if not exists edited_at timestamptz,
  add column if not exists deleted_group_id uuid;

update public.mortality_records
set notes = case
      when notes is null or notes = '' then cause
      else notes || ' (' || cause || ')'
    end,
    cause = null
where cause is not null and cause <> '';

alter table public.mortality_records drop constraint if exists mortality_records_kind_check;
alter table public.mortality_records
  add constraint mortality_records_kind_check
  check (kind in ('died', 'culled', 'missing', 'other'));

alter table public.mortality_records drop constraint if exists mortality_records_suspected_cause_check;
alter table public.mortality_records
  add constraint mortality_records_suspected_cause_check
  check (
    suspected_cause is null
    or suspected_cause in ('unknown', 'disease_signs', 'injury', 'heat_or_cold', 'predator', 'other')
  );

-- count > 0 already exists from 0002 (mortality_records_count_check).

comment on column public.mortality_records.cause is
  'Deprecated. Folded into notes by 0016; the app no longer writes it.';

create index if not exists mortality_records_batch_occurred_idx
  on public.mortality_records (batch_id, occurred_on);
create index if not exists mortality_records_deleted_group_idx
  on public.mortality_records (deleted_group_id) where deleted_group_id is not null;

-- ---------------------------------------------------------------------------
-- sync config
-- ---------------------------------------------------------------------------
update public.sync_table_config
set kind = 'mutable',
    writable_columns = array[
      'id', 'farm_id', 'batch_id', 'count', 'kind', 'suspected_cause',
      'occurred_on', 'notes', 'edited_at', 'deleted_at', 'deleted_group_id',
      'created_at'
    ]
where table_name = 'mortality_records';

update public.sync_table_config
set writable_columns = array[
      'id', 'farm_id', 'name', 'bird_type', 'initial_count', 'acquired_on',
      'age_at_acquisition_days', 'hatchery_vaccinated', 'source', 'status',
      'programme_id', 'programme_version', 'production_type',
      'programme_content_hash', 'notes', 'closed_on', 'close_reason',
      'close_note', 'deleted_at', 'deleted_group_id', 'created_at'
    ]
where table_name = 'batches';

update public.sync_table_config
set writable_columns = array[
      'id', 'farm_id', 'batch_id', 'step_id', 'occurrence', 'due_on', 'enabled',
      'status', 'done_on', 'done_by', 'product_used', 'notes', 'step_snapshot',
      'programme_content_hash', 'shifted_from', 'deleted_at', 'deleted_group_id',
      'created_at'
    ]
where table_name = 'vaccination_tasks';

-- ---------------------------------------------------------------------------
-- sync_push
-- ---------------------------------------------------------------------------
create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'batches' then
        -- Workers may add batches; changing, closing or deleting one needs owner or manager.
        if exists (select 1 from public.batches where id = v_row_id)
           and not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
        insert into public.batches
        select * from jsonb_populate_record(null::public.batches, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          name = excluded.name,
          bird_type = excluded.bird_type,
          initial_count = excluded.initial_count,
          acquired_on = excluded.acquired_on,
          age_at_acquisition_days = excluded.age_at_acquisition_days,
          hatchery_vaccinated = excluded.hatchery_vaccinated,
          source = excluded.source,
          status = excluded.status,
          programme_id = excluded.programme_id,
          programme_version = excluded.programme_version,
          production_type = excluded.production_type,
          programme_content_hash = excluded.programme_content_hash,
          notes = excluded.notes,
          closed_on = excluded.closed_on,
          close_reason = excluded.close_reason,
          close_note = excluded.close_note,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        returning to_jsonb(batches.*) into v_existing;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          step_id = excluded.step_id,
          occurrence = excluded.occurrence,
          due_on = excluded.due_on,
          enabled = excluded.enabled,
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          done_by = excluded.done_by,
          product_used = excluded.product_used,
          notes = excluded.notes,
          step_snapshot = coalesce(excluded.step_snapshot, vaccination_tasks.step_snapshot),
          programme_content_hash = coalesce(
            excluded.programme_content_hash,
            vaccination_tasks.programme_content_hash
          ),
          shifted_from = excluded.shifted_from,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      elsif v_table = 'mortality_records' then
        if not exists (
          select 1 from public.batches
          where id = (v_payload->>'batch_id')::uuid and farm_id = v_farm_id
        ) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
        insert into public.mortality_records
        select * from jsonb_populate_record(null::public.mortality_records, v_payload)
        on conflict (id) do update set
          batch_id = excluded.batch_id,
          count = excluded.count,
          kind = coalesce(excluded.kind, mortality_records.kind),
          suspected_cause = excluded.suspected_cause,
          occurred_on = excluded.occurred_on,
          notes = excluded.notes,
          edited_at = excluded.edited_at,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        where mortality_records.farm_id = excluded.farm_id
        returning to_jsonb(mortality_records.*) into v_existing;
        if v_existing is null then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table = 'vet_assistance_requests' then
        if coalesce(v_payload->>'status', 'submitted') not in (
          'draft', 'pending_sync', 'submitted', 'cancelled'
        ) then
          raise exception 'forbidden status for farmer push' using errcode = '42501';
        end if;
        insert into public.vet_assistance_requests
        select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          health_record_id = excluded.health_record_id,
          service_type = excluded.service_type,
          status = excluded.status,
          share_location = excluded.share_location,
          priority = excluded.priority,
          farmer_notes = excluded.farmer_notes,
          requested_vet_user_id = coalesce(
            excluded.requested_vet_user_id,
            vet_assistance_requests.requested_vet_user_id
          ),
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vet_assistance_requests.*) into v_existing;
      elsif v_table = 'farms' then
        insert into public.farms
        select * from jsonb_populate_record(null::public.farms, v_payload)
        on conflict (id) do update set
          name = coalesce(excluded.name, farms.name),
          location = coalesce(excluded.location, farms.location),
          notes = coalesce(excluded.notes, farms.notes),
          district = coalesce(excluded.district, farms.district),
          village = coalesce(excluded.village, farms.village),
          phone = coalesce(excluded.phone, farms.phone),
          alt_phone = coalesce(excluded.alt_phone, farms.alt_phone),
          latitude = coalesce(excluded.latitude, farms.latitude),
          longitude = coalesce(excluded.longitude, farms.longitude),
          location_accuracy_m = coalesce(
            excluded.location_accuracy_m,
            farms.location_accuracy_m
          ),
          location_captured_at = coalesce(
            excluded.location_captured_at,
            farms.location_captured_at
          ),
          updated_at = now()
        returning to_jsonb(farms.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

grant execute on function public.sync_push(jsonb) to authenticated;

-- =============================================================================
-- 0017_feed_management_vet_contacts.sql
-- =============================================================================


-- ---------------------------------------------------------------------------
-- feed_transactions
-- ---------------------------------------------------------------------------
alter table public.feed_transactions drop constraint if exists feed_transactions_kind_check;
alter table public.feed_transactions
  add constraint feed_transactions_kind_check
  check (kind in ('purchase', 'consumption', 'wastage', 'adjustment', 'usage'));

create index if not exists feed_transactions_item_idx
  on public.feed_transactions (feed_item_id, occurred_on);

-- ---------------------------------------------------------------------------
-- sync config
-- ---------------------------------------------------------------------------
update public.sync_table_config
set writable_columns = array[
  'id','farm_id','name','feed_type','unit','reorder_level','deleted_at','created_at'
]
where table_name = 'feed_items';

update public.sync_table_config
set writable_columns = array[
  'id','farm_id','feed_item_id','batch_id','kind','quantity','unit_cost',
  'occurred_on','deleted_at','created_at'
]
where table_name = 'feed_transactions';

-- ---------------------------------------------------------------------------
-- sync_push
-- ---------------------------------------------------------------------------
create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_results jsonb := '[]'::jsonb;
  v_count int;
  v_payload jsonb;
  v_table text;
  v_op_id uuid;
  v_row_id uuid;
  v_kind text;
  v_farm_id uuid;
  v_existing jsonb;
  v_result jsonb;
  v_retryable boolean;
begin
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error', 'payload_too_large',
      'retryable', false,
      'results', '[]'::jsonb
    );
  end if;

  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id := (v_op->>'op_id')::uuid;
      v_table := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
        continue;
      end if;

      select kind into v_kind from public.sync_table_config where table_name = v_table;
      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id', v_op_id,
          'status', 'rejected',
          'error_code', 'unknown_table',
          'retryable', false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      v_farm_id := coalesce((v_payload->>'farm_id')::uuid, v_row_id);

      if v_table = 'farms' then
        v_farm_id := v_row_id;
        if not exists (select 1 from public.farms where id = v_row_id) then
          if not public.can_farm_push(v_farm_id) then
            insert into public.farms (id, farm_id, name, location, notes, created_by, created_at)
            values (
              v_row_id,
              v_row_id,
              coalesce(v_payload->>'name', 'My farm'),
              v_payload->>'location',
              v_payload->>'notes',
              v_uid,
              coalesce((v_payload->>'created_at')::timestamptz, now())
            );
            insert into public.farm_members (id, farm_id, user_id, role)
            values (gen_random_uuid(), v_row_id, v_uid, 'owner');
          end if;
        elsif not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table <> 'programmes' and v_table <> 'programme_steps' then
        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      end if;

      if (v_op->>'op') = 'delete' then
        execute format('update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)', v_table, v_table)
          into v_existing using v_row_id;
      elsif v_kind = 'append_only' then
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do nothing returning to_jsonb(%I.*)',
          v_table, v_table, v_table
        ) into v_existing using v_payload;
        if v_existing is null then
          execute format('select to_jsonb(t) from public.%I t where id = $1', v_table)
            into v_existing using v_row_id;
        end if;
      elsif v_table = 'batches' then
        -- Workers may add batches; changing, closing or deleting one needs owner or manager.
        if exists (select 1 from public.batches where id = v_row_id)
           and not public.is_farm_member(v_farm_id, array['owner','manager']) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
        insert into public.batches
        select * from jsonb_populate_record(null::public.batches, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          name = excluded.name,
          bird_type = excluded.bird_type,
          initial_count = excluded.initial_count,
          acquired_on = excluded.acquired_on,
          age_at_acquisition_days = excluded.age_at_acquisition_days,
          hatchery_vaccinated = excluded.hatchery_vaccinated,
          source = excluded.source,
          status = excluded.status,
          programme_id = excluded.programme_id,
          programme_version = excluded.programme_version,
          production_type = excluded.production_type,
          programme_content_hash = excluded.programme_content_hash,
          notes = excluded.notes,
          closed_on = excluded.closed_on,
          close_reason = excluded.close_reason,
          close_note = excluded.close_note,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        returning to_jsonb(batches.*) into v_existing;
      elsif v_table = 'vaccination_tasks' then
        insert into public.vaccination_tasks
        select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          step_id = excluded.step_id,
          occurrence = excluded.occurrence,
          due_on = excluded.due_on,
          enabled = excluded.enabled,
          status = case
            when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
            else vaccination_tasks.status
          end,
          done_on = excluded.done_on,
          done_by = excluded.done_by,
          product_used = excluded.product_used,
          notes = excluded.notes,
          step_snapshot = coalesce(excluded.step_snapshot, vaccination_tasks.step_snapshot),
          programme_content_hash = coalesce(
            excluded.programme_content_hash,
            vaccination_tasks.programme_content_hash
          ),
          shifted_from = excluded.shifted_from,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        returning to_jsonb(vaccination_tasks.*) into v_existing;
      elsif v_table = 'mortality_records' then
        if not exists (
          select 1 from public.batches
          where id = (v_payload->>'batch_id')::uuid and farm_id = v_farm_id
        ) then
          raise exception 'forbidden' using errcode = '42501';
        end if;
        insert into public.mortality_records
        select * from jsonb_populate_record(null::public.mortality_records, v_payload)
        on conflict (id) do update set
          batch_id = excluded.batch_id,
          count = excluded.count,
          kind = coalesce(excluded.kind, mortality_records.kind),
          suspected_cause = excluded.suspected_cause,
          occurred_on = excluded.occurred_on,
          notes = excluded.notes,
          edited_at = excluded.edited_at,
          deleted_at = excluded.deleted_at,
          deleted_group_id = excluded.deleted_group_id,
          updated_at = now()
        where mortality_records.farm_id = excluded.farm_id
        returning to_jsonb(mortality_records.*) into v_existing;
        if v_existing is null then
          raise exception 'forbidden' using errcode = '42501';
        end if;
      elsif v_table = 'vet_assistance_requests' then
        if coalesce(v_payload->>'status', 'submitted') not in (
          'draft', 'pending_sync', 'submitted', 'cancelled'
        ) then
          raise exception 'forbidden status for farmer push' using errcode = '42501';
        end if;
        insert into public.vet_assistance_requests
        select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
        on conflict (id) do update set
          farm_id = excluded.farm_id,
          batch_id = excluded.batch_id,
          health_record_id = excluded.health_record_id,
          service_type = excluded.service_type,
          status = excluded.status,
          share_location = excluded.share_location,
          priority = excluded.priority,
          farmer_notes = excluded.farmer_notes,
          requested_vet_user_id = coalesce(
            excluded.requested_vet_user_id,
            vet_assistance_requests.requested_vet_user_id
          ),
          deleted_at = excluded.deleted_at,
          updated_at = now()
        returning to_jsonb(vet_assistance_requests.*) into v_existing;
      elsif v_table = 'farms' then
        insert into public.farms
        select * from jsonb_populate_record(null::public.farms, v_payload)
        on conflict (id) do update set
          name = coalesce(excluded.name, farms.name),
          location = coalesce(excluded.location, farms.location),
          notes = coalesce(excluded.notes, farms.notes),
          district = coalesce(excluded.district, farms.district),
          village = coalesce(excluded.village, farms.village),
          phone = coalesce(excluded.phone, farms.phone),
          alt_phone = coalesce(excluded.alt_phone, farms.alt_phone),
          latitude = coalesce(excluded.latitude, farms.latitude),
          longitude = coalesce(excluded.longitude, farms.longitude),
          location_accuracy_m = coalesce(
            excluded.location_accuracy_m,
            farms.location_accuracy_m
          ),
          location_captured_at = coalesce(
            excluded.location_captured_at,
            farms.location_captured_at
          ),
          updated_at = now()
        returning to_jsonb(farms.*) into v_existing;
      else
        execute format(
          'insert into public.%I select * from jsonb_populate_record(null::public.%I, $1)
           on conflict (id) do update set
             name = coalesce(excluded.name, %I.name),
             updated_at = now()
           returning to_jsonb(%I.*)',
          v_table, v_table, v_table, v_table
        ) into v_existing using v_payload;
      end if;

      v_result := jsonb_build_object(
        'op_id', v_op_id,
        'status', 'applied',
        'server_version', v_existing->>'server_version',
        'row', v_existing,
        'retryable', false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);
    exception
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'fk_violation',
          'retryable', true
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', 'serialization',
          'retryable', true
        );
        v_results := v_results || jsonb_build_array(v_result);
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id', v_op->>'op_id',
          'status', 'rejected',
          'error_code', sqlstate,
          'retryable', v_retryable,
          'message', sqlerrm
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values ((v_op->>'op_id')::uuid, v_uid, v_result)
        on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

grant execute on function public.sync_push(jsonb) to authenticated;

-- ---------------------------------------------------------------------------
-- list_available_vets
-- ---------------------------------------------------------------------------
create or replace function public.list_available_vets(p_farm_id uuid default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_farm_lat double precision;
  v_farm_lon double precision;
  v_rows jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if public.current_app_role() <> 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    select f.latitude, f.longitude into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id', v.user_id,
      'display_name', coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization', v.organization,
      'district', v.district,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit', v.offers_farm_visit,
      'latitude', v.latitude,
      'longitude', v.longitude,
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null then
          (
            6371 * acos(
              least(1.0, greatest(-1.0,
                cos(radians(v_farm_lat)) * cos(radians(v.latitude))
                * cos(radians(v.longitude) - radians(v_farm_lon))
                + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
              ))
            )
          )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

grant execute on function public.list_available_vets(uuid) to authenticated;

-- =============================================================================
-- 0018_feed_schema_fix.sql
-- =============================================================================

-- 0018: Feed schema fix
--
-- Addresses: F-12 (kind constraint / canonical names), F-13 (quantity constraint
-- split by kind), F-14 (unit_cost non-negative), F-16 (missing indexes),
-- F-17 (sync_table_config alignment for feed_items).
--
-- One concern: feed_transactions constraints, indexes, and sync_table_config sync.
--
-- Safe to run more than once (all DDL uses IF NOT EXISTS / DROP IF EXISTS / NOT VALID).

-- ---------------------------------------------------------------------------
-- 1. Migrate 'usage' → 'consumption'
-- ---------------------------------------------------------------------------

update public.feed_transactions
set kind = 'consumption'
where kind = 'usage';

-- ---------------------------------------------------------------------------
-- 2. Replace kind check: remove 'usage', add 'wastage', 'consumption'
-- ---------------------------------------------------------------------------

alter table public.feed_transactions
  drop constraint if exists feed_transactions_kind_check;

alter table public.feed_transactions
  add constraint feed_transactions_kind_check
  check (kind in ('purchase', 'consumption', 'wastage', 'adjustment'))
  not valid;

-- Validate only rows that pass (legacy data safe if migration above ran first).
alter table public.feed_transactions
  validate constraint feed_transactions_kind_check;

-- ---------------------------------------------------------------------------
-- 3. Split quantity constraint by kind:
--    purchase/consumption/wastage: quantity > 0
--    adjustment: quantity <> 0 (negative allowed)
-- ---------------------------------------------------------------------------

-- Drop old single constraint (may be named differently across migrations)
alter table public.feed_transactions
  drop constraint if exists feed_transactions_quantity_check;
-- Also drop the constraint from 0002 if it existed with a generic name
alter table public.feed_transactions
  drop constraint if exists feed_transactions_quantity_positive;

-- New split constraints (NOT VALID to avoid rejecting legacy rows on validate)
alter table public.feed_transactions
  add constraint feed_transactions_quantity_nonzero_check
  check (
    case kind
      when 'adjustment' then quantity <> 0
      else quantity > 0
    end
  ) not valid;

alter table public.feed_transactions
  validate constraint feed_transactions_quantity_nonzero_check;

-- ---------------------------------------------------------------------------
-- 4. unit_cost must be >= 0 when present
-- ---------------------------------------------------------------------------

alter table public.feed_transactions
  drop constraint if exists feed_transactions_unit_cost_check;

alter table public.feed_transactions
  add constraint feed_transactions_unit_cost_check
  check (unit_cost is null or unit_cost >= 0)
  not valid;

alter table public.feed_transactions
  validate constraint feed_transactions_unit_cost_check;

-- ---------------------------------------------------------------------------
-- 5. Indexes
-- ---------------------------------------------------------------------------

-- Partial index on feed_items: farm lookups excluding soft-deleted rows
create index if not exists feed_items_farm_deleted_idx
  on public.feed_items (farm_id, deleted_at)
  where deleted_at is null;

-- Partial index on feed_transactions: ledger queries per item, excluding soft-deleted
create index if not exists feed_transactions_item_occurred_idx
  on public.feed_transactions (feed_item_id, occurred_on)
  where deleted_at is null;

-- ---------------------------------------------------------------------------
-- 6. Align sync_table_config for feed_items
--    kind: mutable (already set in 0002/0017 but confirm)
--    writable_columns: include deleted_at (was missing in 0002; added in 0017 but
--    ensuring canonical post-0018 state)
-- ---------------------------------------------------------------------------

update public.sync_table_config
set
  kind = 'mutable',
  writable_columns = array[
    'id', 'farm_id', 'name', 'feed_type', 'unit',
    'reorder_level', 'deleted_at', 'created_at'
  ]
where table_name = 'feed_items';

-- =============================================================================
-- 0019_sync_push_hardening.sql
-- =============================================================================

-- 0019: sync_push hardening
--
-- Addresses: F-01 (cross-farm IDOR), F-02 (farm_id immutable), F-03 (farm_id guard),
-- F-04 (reference-table rejection), F-05 (FK retryable: do not store in applied),
-- F-06 (duplicate: preserve original status), F-07 (config-driven generic upsert),
-- F-08 (task monotonicity), F-09 (vet request state-machine), F-10 (delete farm_id
-- check), F-11 (no sqlerrm in response), F-15 (server_version as bigint), F-18
-- (dead second farms branch removed), F-19 (REVOKE from public/anon).
--
-- One concern: sync_push function replacement + privilege grants.

-- Revoke before replacing so no window of exposure
revoke execute on function public.sync_push(jsonb) from public;
revoke execute on function public.sync_push(jsonb) from anon;

create or replace function public.sync_push(p_ops jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid          uuid    := auth.uid();
  v_op           jsonb;
  v_results      jsonb   := '[]'::jsonb;
  v_count        int;
  v_payload      jsonb;
  v_table        text;
  v_op_id        uuid;
  v_row_id       uuid;
  v_kind         text;
  v_farm_id      uuid;
  v_stored_farm  uuid;
  v_existing     jsonb;
  v_result       jsonb;
  v_retryable    boolean;
  v_status       text;
  v_existing_status text;
  v_col          text;
  v_set_parts    text[];
  v_set_clause   text;
  v_sql          text;
begin
  -- ── Auth guard ──────────────────────────────────────────────────────────────
  if v_uid is null then
    raise exception 'not authenticated';
  end if;

  -- ── Payload size limit ──────────────────────────────────────────────────────
  v_count := jsonb_array_length(p_ops);
  if v_count > 200 or octet_length(p_ops::text) > 262144 then
    return jsonb_build_object(
      'error',     'payload_too_large',
      'retryable', false,
      'results',   '[]'::jsonb
    );
  end if;

  -- ── Per-op loop ─────────────────────────────────────────────────────────────
  for v_op in select * from jsonb_array_elements(p_ops)
  loop
    begin
      v_op_id  := (v_op->>'op_id')::uuid;
      v_table  := v_op->>'table';
      v_row_id := (v_op->>'row_id')::uuid;
      v_payload := v_op->'payload';

      -- ── Duplicate detection (preserve original result) ────────────────────
      select result into v_result
      from public.sync_ops_applied
      where op_id = v_op_id;

      if found then
        -- Return original result + duplicate:true flag; do NOT overwrite status.
        v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('duplicate', true));
        continue;
      end if;

      -- ── Table allow-list / reference rejection ────────────────────────────
      select kind into v_kind
      from public.sync_table_config
      where table_name = v_table;

      if v_kind is null then
        v_result := jsonb_build_object(
          'op_id',       v_op_id,
          'status',      'rejected',
          'error_code',  'unknown_table',
          'retryable',   false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      if v_kind = 'reference' then
        v_result := jsonb_build_object(
          'op_id',       v_op_id,
          'status',      'rejected',
          'error_code',  'reference_table',
          'retryable',   false
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (v_op_id, v_uid, v_result);
        v_results := v_results || jsonb_build_array(v_result);
        continue;
      end if;

      -- ── Resolve farm_id from payload ──────────────────────────────────────
      v_farm_id := (v_payload->>'farm_id')::uuid;

      -- ── Farm creation branch ──────────────────────────────────────────────
      if v_table = 'farms' then
        v_farm_id := v_row_id;

        if not exists (select 1 from public.farms where id = v_row_id) then
          -- New farm: any authenticated user may create their own farm.
          insert into public.farms (
            id, farm_id, name, location, notes, created_by, created_at
          ) values (
            v_row_id,
            v_row_id,
            coalesce(v_payload->>'name', 'My farm'),
            v_payload->>'location',
            v_payload->>'notes',
            v_uid,
            coalesce((v_payload->>'created_at')::timestamptz, now())
          );
          insert into public.farm_members (id, farm_id, user_id, role)
          values (gen_random_uuid(), v_row_id, v_uid, 'owner');

          execute 'select to_jsonb(f) from public.farms f where f.id = $1'
            into v_existing using v_row_id;
        else
          -- Existing farm: only owner or manager may update.
          if not public.is_farm_member(v_farm_id, array['owner','manager']) then
            raise exception 'forbidden' using errcode = '42501';
          end if;

          insert into public.farms
          select * from jsonb_populate_record(null::public.farms, v_payload)
          on conflict (id) do update set
            name                 = excluded.name,
            location             = excluded.location,
            notes                = excluded.notes,
            district             = excluded.district,
            village              = excluded.village,
            phone                = excluded.phone,
            alt_phone            = excluded.alt_phone,
            latitude             = excluded.latitude,
            longitude            = excluded.longitude,
            location_accuracy_m  = excluded.location_accuracy_m,
            location_captured_at = excluded.location_captured_at,
            updated_at           = now()
          returning to_jsonb(farms.*) into v_existing;
        end if;

      else
        -- ── Non-farm tables: membership + stored-farm ownership check ─────────

        -- All non-farm mutable/append_only tables must have a valid farm_id.
        if v_farm_id is null then
          raise exception 'forbidden' using errcode = '42501';
        end if;

        if not public.can_farm_push(v_farm_id) then
          raise exception 'forbidden' using errcode = '42501';
        end if;

        -- ── Delete op ────────────────────────────────────────────────────────
        if (v_op->>'op') = 'delete' then
          -- Load stored farm_id first to verify ownership.
          execute format('select farm_id from public.%I where id = $1', v_table)
            into v_stored_farm using v_row_id;

          if v_stored_farm is null then
            -- Row not found.
            v_result := jsonb_build_object(
              'op_id',      v_op_id,
              'status',     'rejected',
              'error_code', 'not_found',
              'retryable',  false
            );
            insert into public.sync_ops_applied (op_id, user_id, result)
            values (v_op_id, v_uid, v_result);
            v_results := v_results || jsonb_build_array(v_result);
            continue;
          end if;

          if v_stored_farm <> v_farm_id then
            raise exception 'forbidden' using errcode = '42501';
          end if;

          execute format(
            'update public.%I set deleted_at = now() where id = $1 returning to_jsonb(%I.*)',
            v_table, v_table
          ) into v_existing using v_row_id;

        -- ── Append-only tables ────────────────────────────────────────────────
        elsif v_kind = 'append_only' then
          -- Same-farm reference checks for feed_transactions
          if v_table = 'feed_transactions' then
            -- feed_item must belong to same farm
            if not exists (
              select 1 from public.feed_items
              where id = (v_payload->>'feed_item_id')::uuid
                and farm_id = v_farm_id
            ) then
              raise exception 'forbidden' using errcode = '42501';
            end if;
            -- batch_id (if present) must belong to same farm
            if (v_payload->>'batch_id') is not null then
              if not exists (
                select 1 from public.batches
                where id = (v_payload->>'batch_id')::uuid
                  and farm_id = v_farm_id
              ) then
                raise exception 'forbidden' using errcode = '42501';
              end if;
            end if;
          end if;

          execute format(
            'insert into public.%I
               select * from jsonb_populate_record(null::public.%I, $1)
             on conflict (id) do nothing
             returning to_jsonb(%I.*)',
            v_table, v_table, v_table
          ) into v_existing using v_payload;

          if v_existing is null then
            execute format(
              'select to_jsonb(t) from public.%I t where t.id = $1',
              v_table
            ) into v_existing using v_row_id;
          end if;

        -- ── batches ───────────────────────────────────────────────────────────
        elsif v_table = 'batches' then
          -- Workers may insert; changing or closing needs owner/manager.
          if exists (select 1 from public.batches where id = v_row_id)
             and not public.is_farm_member(v_farm_id, array['owner','manager'])
          then
            raise exception 'forbidden' using errcode = '42501';
          end if;

          insert into public.batches
          select * from jsonb_populate_record(null::public.batches, v_payload)
          on conflict (id) do update set
            -- farm_id intentionally omitted (immutable after insert)
            name                   = excluded.name,
            bird_type              = excluded.bird_type,
            initial_count          = excluded.initial_count,
            acquired_on            = excluded.acquired_on,
            age_at_acquisition_days = excluded.age_at_acquisition_days,
            hatchery_vaccinated    = excluded.hatchery_vaccinated,
            source                 = excluded.source,
            status                 = excluded.status,
            programme_id           = excluded.programme_id,
            programme_version      = excluded.programme_version,
            production_type        = excluded.production_type,
            programme_content_hash = excluded.programme_content_hash,
            notes                  = excluded.notes,
            closed_on              = excluded.closed_on,
            close_reason           = excluded.close_reason,
            close_note             = excluded.close_note,
            deleted_at             = excluded.deleted_at,
            deleted_group_id       = excluded.deleted_group_id,
            updated_at             = now()
          where batches.farm_id = excluded.farm_id
          returning to_jsonb(batches.*) into v_existing;

          if v_existing is null then
            raise exception 'forbidden' using errcode = '42501';
          end if;

        -- ── vaccination_tasks ─────────────────────────────────────────────────
        elsif v_table = 'vaccination_tasks' then
          insert into public.vaccination_tasks
          select * from jsonb_populate_record(null::public.vaccination_tasks, v_payload)
          on conflict (id) do update set
            -- farm_id intentionally omitted (immutable after insert)
            batch_id               = excluded.batch_id,
            step_id                = excluded.step_id,
            occurrence             = excluded.occurrence,
            due_on                 = excluded.due_on,
            enabled                = excluded.enabled,
            -- Status monotonicity: only advance, never retreat.
            status = case
              when public.task_status_rank(excluded.status)
                     >= public.task_status_rank(vaccination_tasks.status)
              then excluded.status
              else vaccination_tasks.status
            end,
            -- Completion fields: only update when rank is advancing.
            done_on = case
              when public.task_status_rank(excluded.status)
                     >= public.task_status_rank(vaccination_tasks.status)
              then excluded.done_on
              else vaccination_tasks.done_on
            end,
            done_by = case
              when public.task_status_rank(excluded.status)
                     >= public.task_status_rank(vaccination_tasks.status)
              then excluded.done_by
              else vaccination_tasks.done_by
            end,
            product_used = case
              when public.task_status_rank(excluded.status)
                     >= public.task_status_rank(vaccination_tasks.status)
              then excluded.product_used
              else vaccination_tasks.product_used
            end,
            notes = case
              when public.task_status_rank(excluded.status)
                     >= public.task_status_rank(vaccination_tasks.status)
              then excluded.notes
              else vaccination_tasks.notes
            end,
            step_snapshot = coalesce(
              excluded.step_snapshot,
              vaccination_tasks.step_snapshot
            ),
            programme_content_hash = coalesce(
              excluded.programme_content_hash,
              vaccination_tasks.programme_content_hash
            ),
            shifted_from           = excluded.shifted_from,
            deleted_at             = excluded.deleted_at,
            deleted_group_id       = excluded.deleted_group_id,
            updated_at             = now()
          where vaccination_tasks.farm_id = excluded.farm_id
          returning to_jsonb(vaccination_tasks.*) into v_existing;

          if v_existing is null then
            raise exception 'forbidden' using errcode = '42501';
          end if;

        -- ── mortality_records ─────────────────────────────────────────────────
        elsif v_table = 'mortality_records' then
          if not exists (
            select 1 from public.batches
            where id   = (v_payload->>'batch_id')::uuid
              and farm_id = v_farm_id
          ) then
            raise exception 'forbidden' using errcode = '42501';
          end if;

          insert into public.mortality_records
          select * from jsonb_populate_record(null::public.mortality_records, v_payload)
          on conflict (id) do update set
            batch_id        = excluded.batch_id,
            count           = excluded.count,
            kind            = coalesce(excluded.kind, mortality_records.kind),
            suspected_cause = excluded.suspected_cause,
            occurred_on     = excluded.occurred_on,
            notes           = excluded.notes,
            edited_at       = excluded.edited_at,
            deleted_at      = excluded.deleted_at,
            deleted_group_id = excluded.deleted_group_id,
            updated_at      = now()
          where mortality_records.farm_id = excluded.farm_id
          returning to_jsonb(mortality_records.*) into v_existing;

          if v_existing is null then
            raise exception 'forbidden' using errcode = '42501';
          end if;

        -- ── vet_assistance_requests ───────────────────────────────────────────
        elsif v_table = 'vet_assistance_requests' then
          -- Normalise pending_sync → submitted.
          v_status := coalesce(v_payload->>'status', 'submitted');
          if v_status = 'pending_sync' then
            v_status := 'submitted';
            v_payload := v_payload || jsonb_build_object('status', 'submitted');
          end if;

          -- Farmer may only push: draft, submitted, cancelled.
          if v_status not in ('draft', 'submitted', 'cancelled') then
            raise exception 'forbidden status for farmer push' using errcode = '42501';
          end if;

          -- Cancel only allowed from draft/submitted (not from accepted/in_progress/completed).
          if v_status = 'cancelled' then
            select status into v_existing_status
            from public.vet_assistance_requests
            where id = v_row_id;

            if v_existing_status is not null
               and v_existing_status not in ('draft', 'pending_sync', 'submitted')
            then
              raise exception 'forbidden: cannot cancel from status %', v_existing_status
                using errcode = '42501';
            end if;
          end if;

          insert into public.vet_assistance_requests
          select * from jsonb_populate_record(null::public.vet_assistance_requests, v_payload)
          on conflict (id) do update set
            -- farm_id intentionally omitted (immutable after insert)
            batch_id               = excluded.batch_id,
            health_record_id       = excluded.health_record_id,
            service_type           = excluded.service_type,
            status                 = excluded.status,
            share_location         = excluded.share_location,
            priority               = excluded.priority,
            farmer_notes           = excluded.farmer_notes,
            requested_vet_user_id  = coalesce(
              excluded.requested_vet_user_id,
              vet_assistance_requests.requested_vet_user_id
            ),
            deleted_at             = excluded.deleted_at,
            updated_at             = now()
          where vet_assistance_requests.farm_id = excluded.farm_id
          returning to_jsonb(vet_assistance_requests.*) into v_existing;

          if v_existing is null then
            raise exception 'forbidden' using errcode = '42501';
          end if;

        -- ── Config-driven generic upsert (feed_items and any other mutable table) ─
        else
          -- Verify row (if exists) belongs to the same farm.
          execute format(
            'select farm_id from public.%I where id = $1',
            v_table
          ) into v_stored_farm using v_row_id;

          if v_stored_farm is not null and v_stored_farm <> v_farm_id then
            raise exception 'forbidden' using errcode = '42501';
          end if;

          -- Build SET clause from writable_columns, excluding write-once / server fields.
          v_set_parts := array[]::text[];
          for v_col in
            select unnest(writable_columns)
            from public.sync_table_config
            where table_name = v_table
          loop
            -- Exclude fields that must never change after insert.
            if v_col not in ('id', 'farm_id', 'created_at') then
              v_set_parts := v_set_parts || format('%I = excluded.%I', v_col, v_col);
            end if;
          end loop;

          -- Always bump updated_at.
          v_set_parts := v_set_parts || 'updated_at = now()';
          v_set_clause := array_to_string(v_set_parts, ', ');

          v_sql := format(
            'insert into public.%I
               select * from jsonb_populate_record(null::public.%I, $1)
             on conflict (id) do update set %s
             where %I.farm_id = excluded.farm_id
             returning to_jsonb(%I.*)',
            v_table, v_table, v_set_clause, v_table, v_table
          );

          execute v_sql into v_existing using v_payload;

          if v_existing is null then
            -- Row exists but farm_id guard rejected it.
            raise exception 'forbidden' using errcode = '42501';
          end if;
        end if;
      end if;  -- end non-farms branch

      -- ── Build success result ─────────────────────────────────────────────────
      v_result := jsonb_build_object(
        'op_id',          v_op_id,
        'status',         'applied',
        'server_version', (v_existing->'server_version')::bigint,
        'row',            v_existing,
        'retryable',      false
      );

      insert into public.sync_ops_applied (op_id, user_id, result)
      values (v_op_id, v_uid, v_result);

      v_results := v_results || jsonb_build_array(v_result);

    exception
      -- ── FK violation: retryable, do NOT store in applied ──────────────────
      when sqlstate '23503' then
        v_result := jsonb_build_object(
          'op_id',       coalesce(v_op_id::text, v_op->>'op_id'),
          'status',      'rejected',
          'error_code',  'fk_violation',
          'retryable',   true
        );
        -- Do NOT insert into sync_ops_applied so the retry is treated as new.
        v_results := v_results || jsonb_build_array(v_result);

      -- ── Serialization error: retryable, no store ──────────────────────────
      when sqlstate '40001' or sqlstate '40P01' then
        v_result := jsonb_build_object(
          'op_id',      coalesce(v_op_id::text, v_op->>'op_id'),
          'status',     'rejected',
          'error_code', 'serialization',
          'retryable',  true
        );
        v_results := v_results || jsonb_build_array(v_result);

      -- ── All other errors: non-retryable, store result (no sqlerrm) ────────
      when others then
        v_retryable := sqlstate in ('40001', '40P01', '23503');
        v_result := jsonb_build_object(
          'op_id',      coalesce(v_op_id::text, v_op->>'op_id'),
          'status',     'rejected',
          'error_code', sqlstate,
          'retryable',  v_retryable
          -- Note: 'message' / sqlerrm deliberately omitted to avoid info leakage.
        );
        insert into public.sync_ops_applied (op_id, user_id, result)
        values (
          (coalesce(v_op_id::text, v_op->>'op_id'))::uuid,
          v_uid,
          v_result
        ) on conflict do nothing;
        v_results := v_results || jsonb_build_array(v_result);
    end;
  end loop;

  return jsonb_build_object('results', v_results, 'epoch', public.sync_epoch());
end;
$$;

-- Grant to authenticated only (revoke from public/anon already done above).
grant execute on function public.sync_push(jsonb) to authenticated;

-- =============================================================================
-- 0020_vet_rpc_hardening.sql
-- =============================================================================

-- 0020: Vet RPC hardening
--
-- Addresses: F-20 (list_available_vets: no raw coordinates, farm-membership check,
-- verified/active/opted-in filter, result limit, anon rejection).
-- Also adds is_verified / is_active / opted_in columns to vet_profiles.
--
-- One concern: vet_profiles schema + list_available_vets function replacement.

-- ---------------------------------------------------------------------------
-- 1. Add is_verified, is_active, opted_in columns to vet_profiles
-- ---------------------------------------------------------------------------

alter table public.vet_profiles
  add column if not exists is_verified boolean not null default false,
  add column if not exists is_active   boolean not null default true,
  add column if not exists opted_in    boolean not null default true;

-- ---------------------------------------------------------------------------
-- 2. Revoke before replacing to close any privilege window
-- ---------------------------------------------------------------------------

revoke execute on function public.list_available_vets(uuid) from public;
revoke execute on function public.list_available_vets(uuid) from anon;

-- ---------------------------------------------------------------------------
-- 3. Replace list_available_vets with hardened version
-- ---------------------------------------------------------------------------

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit   int  default 50
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit     int := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_farm_lat  double precision;
  v_farm_lon  double precision;
  v_rows      jsonb;
begin
  -- ── Auth ────────────────────────────────────────────────────────────────────
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- ── Farm membership check ───────────────────────────────────────────────────
  if p_farm_id is not null then
    if not public.is_farm_member(p_farm_id) then
      raise exception 'forbidden' using errcode = '42501';
    end if;

    -- Fetch GPS for distance sort (only if member, so already verified above).
    select f.latitude, f.longitude
      into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  -- ── Build result (no latitude/longitude in output) ──────────────────────────
  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id',             v.user_id,
      'display_name',        coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization',        v.organization,
      'district',            v.district,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit',   v.offers_farm_visit,
      -- Deliberately omit latitude and longitude from response.
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    where v.is_verified = true
      and v.is_active   = true
      and v.opted_in    = true
    order by (
      case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) nulls last
    limit v_limit
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

-- Grant to authenticated only.
revoke execute on function public.list_available_vets(uuid, integer) from public;
revoke execute on function public.list_available_vets(uuid, integer) from anon;
grant  execute on function public.list_available_vets(uuid, integer) to authenticated;

-- =============================================================================
-- 0021_vet_rpc_add_phone.sql
-- =============================================================================

-- 0021: Add phone column to vet_profiles + fix list_available_vets RPC + backfill is_verified
--
-- The RPC references v.phone but the column did not exist, causing the function
-- to fail on apply. This migration adds the column first, then recreates the RPC.

-- ---------------------------------------------------------------------------
-- 0. Add phone column to vet_profiles (idempotent)
-- ---------------------------------------------------------------------------

ALTER TABLE public.vet_profiles ADD COLUMN IF NOT EXISTS phone text;

-- ---------------------------------------------------------------------------
-- 1. Revoke before replacing (close any privilege window)
-- ---------------------------------------------------------------------------

revoke execute on function public.list_available_vets(uuid, integer) from public;
revoke execute on function public.list_available_vets(uuid, integer) from anon;

-- ---------------------------------------------------------------------------
-- 2. Replace list_available_vets — adds 'phone' to jsonb_build_object
-- ---------------------------------------------------------------------------

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit   int  default 50
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit     int := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_farm_lat  double precision;
  v_farm_lon  double precision;
  v_rows      jsonb;
begin
  -- Auth
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- Farm membership check
  if p_farm_id is not null then
    if not public.is_farm_member(p_farm_id) then
      raise exception 'forbidden' using errcode = '42501';
    end if;

    select f.latitude, f.longitude
      into v_farm_lat, v_farm_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  -- Build result
  select coalesce(
    jsonb_agg(entry order by (entry->>'distance_km')::double precision nulls last),
    '[]'::jsonb
  )
  into v_rows
  from (
    select jsonb_build_object(
      'user_id',             v.user_id,
      'display_name',        coalesce(v.display_name, p.display_name, 'Veterinarian'),
      'organization',        v.organization,
      'district',            v.district,
      'phone',               v.phone,
      'offers_consultation', v.offers_consultation,
      'offers_farm_visit',   v.offers_farm_visit,
      'distance_km', case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) as entry
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    where v.is_verified = true
      and v.is_active   = true
      and v.opted_in    = true
    order by (
      case
        when v_farm_lat is not null and v_farm_lon is not null
          and v.latitude is not null and v.longitude is not null
        then (
          6371 * acos(
            least(1.0, greatest(-1.0,
              cos(radians(v_farm_lat)) * cos(radians(v.latitude))
              * cos(radians(v.longitude) - radians(v_farm_lon))
              + sin(radians(v_farm_lat)) * sin(radians(v.latitude))
            ))
          )
        )
        else null
      end
    ) nulls last
    limit v_limit
  ) ranked;

  return jsonb_build_object('vets', v_rows);
end;
$$;

-- Grant to authenticated only.
revoke execute on function public.list_available_vets(uuid, integer) from public;
revoke execute on function public.list_available_vets(uuid, integer) from anon;
grant  execute on function public.list_available_vets(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Backfill: mark existing active+opted_in vets as verified
-- ---------------------------------------------------------------------------

update public.vet_profiles
  set is_verified = true
where is_verified = false
  and is_active   = true
  and opted_in    = true;

-- =============================================================================
-- 0022_list_available_vets_privacy.sql
-- =============================================================================

-- 0022: Harden list_available_vets and stop farmers reading vet_profiles.
--
-- Why: 0021 still omitted farmer-role checks, coalesced phone, rounded
-- distance, and search_path hardening. 0012 also let any farmer SELECT
-- vet_profiles (phone + coordinates). 0021 backfilled is_verified for all
-- active opted-in rows; this file does not repeat that.
--
-- Rollback: restore list_available_vets from 0021; recreate
-- vet_profiles_select_farmer; drop admin_set_vet_verified and the
-- verification-protect trigger.

drop policy if exists vet_profiles_select_farmer on public.vet_profiles;

create or replace function public.vet_profiles_protect_verification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE'
     and new.is_verified is distinct from old.is_verified
     and pg_catalog.current_setting('role', true) is distinct from 'service_role'
     and current_user is distinct from 'postgres' then
    new.is_verified := old.is_verified;
  end if;
  return new;
end;
$$;

drop trigger if exists vet_profiles_protect_verification on public.vet_profiles;
create trigger vet_profiles_protect_verification
  before update on public.vet_profiles
  for each row
  execute function public.vet_profiles_protect_verification();

create or replace function public.admin_set_vet_verified(
  p_user_id uuid,
  p_verified boolean
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if pg_catalog.current_setting('role', true) is distinct from 'service_role'
     and current_user is distinct from 'postgres' then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.vet_profiles
  set is_verified = p_verified, updated_at = pg_catalog.now()
  where user_id = p_user_id;
end;
$$;

revoke execute on function public.admin_set_vet_verified(uuid, boolean) from public, anon, authenticated;
grant execute on function public.admin_set_vet_verified(uuid, boolean) to service_role;

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit int default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit int := pg_catalog.least(pg_catalog.greatest(pg_catalog.coalesce(p_limit, 50), 1), 100);
  v_lat double precision;
  v_lon double precision;
  v_vets jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if public.current_app_role() is distinct from 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    if not public.is_farm_member(
      p_farm_id,
      array['owner', 'manager', 'worker', 'viewer']
    ) then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    select f.latitude, f.longitude
      into v_lat, v_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select pg_catalog.coalesce(
    pg_catalog.jsonb_agg(r.entry order by r.km nulls last, r.name),
    '[]'::jsonb
  )
  into v_vets
  from (
    select
      pg_catalog.jsonb_build_object(
        'user_id', v.user_id,
        'display_name', pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian'),
        'organization', v.organization,
        'district', v.district,
        'offers_consultation', v.offers_consultation,
        'offers_farm_visit', v.offers_farm_visit,
        'phone', pg_catalog.coalesce(v.phone, p.phone),
        'distance_km', pg_catalog.round(d.km::numeric, 1)
      ) as entry,
      d.km,
      pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian') as name
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    cross join lateral (
      select case
        when v_lat is not null and v_lon is not null
         and v.latitude is not null and v.longitude is not null
        then 6371 * pg_catalog.acos(pg_catalog.least(1.0, pg_catalog.greatest(-1.0,
               pg_catalog.cos(pg_catalog.radians(v_lat)) * pg_catalog.cos(pg_catalog.radians(v.latitude))
               * pg_catalog.cos(pg_catalog.radians(v.longitude) - pg_catalog.radians(v_lon))
               + pg_catalog.sin(pg_catalog.radians(v_lat)) * pg_catalog.sin(pg_catalog.radians(v.latitude)))))
      end as km
    ) d
    where v.is_verified and v.is_active and v.opted_in
    order by d.km nulls last, pg_catalog.coalesce(v.display_name, p.display_name, 'Veterinarian')
    limit v_limit
  ) r;

  return pg_catalog.jsonb_build_object('vets', v_vets);
end;
$$;

revoke execute on function public.list_available_vets(uuid, integer) from public, anon;
grant execute on function public.list_available_vets(uuid, integer) to authenticated;

-- 0023: drop list_available_vets(uuid) overload so PostgREST is not ambiguous.
do $$
begin
  if exists (
    select 1
    from pg_catalog.pg_proc p
    join pg_catalog.pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'list_available_vets'
      and pg_catalog.pg_get_function_identity_arguments(p.oid) = 'uuid, integer'
  ) then
    drop function if exists public.list_available_vets(uuid);
  end if;
end $$;

revoke execute on function public.list_available_vets(uuid, integer) from public, anon;
grant execute on function public.list_available_vets(uuid, integer) to authenticated;


-- 0024_fix_list_available_vets.sql
-- 0024: Fix list_available_vets so PostgREST can call it.
--
-- Two bugs on hosted projects that applied 0020–0022:
-- 1. list_available_vets(uuid) and list_available_vets(uuid, integer) both
--    exist, so 0/1-arg calls return PGRST203.
-- 2. search_path = '' plus pg_catalog.coalesce() fails: COALESCE is SQL
--    syntax, not a pg_catalog function (42883).

drop function if exists public.list_available_vets(uuid);
drop function if exists public.list_available_vets(uuid, integer);

create or replace function public.list_available_vets(
  p_farm_id uuid default null,
  p_limit int default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_limit int := pg_catalog.least(pg_catalog.greatest(COALESCE(p_limit, 50), 1), 100);
  v_lat double precision;
  v_lon double precision;
  v_vets jsonb;
begin
  if auth.uid() is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if public.current_app_role() is distinct from 'farmer' then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_farm_id is not null then
    if not public.is_farm_member(
      p_farm_id,
      array['owner', 'manager', 'worker', 'viewer']
    ) then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    select f.latitude, f.longitude
      into v_lat, v_lon
    from public.farms f
    where f.id = p_farm_id and f.deleted_at is null;
  end if;

  select COALESCE(
    pg_catalog.jsonb_agg(r.entry order by r.km nulls last, r.name),
    '[]'::jsonb
  )
  into v_vets
  from (
    select
      pg_catalog.jsonb_build_object(
        'user_id', v.user_id,
        'display_name', COALESCE(v.display_name, p.display_name, 'Veterinarian'),
        'organization', v.organization,
        'district', v.district,
        'offers_consultation', v.offers_consultation,
        'offers_farm_visit', v.offers_farm_visit,
        'phone', COALESCE(v.phone, p.phone),
        'distance_km', pg_catalog.round(d.km::numeric, 1)
      ) as entry,
      d.km,
      COALESCE(v.display_name, p.display_name, 'Veterinarian') as name
    from public.vet_profiles v
    join public.profiles p on p.user_id = v.user_id and p.app_role = 'vet'
    cross join lateral (
      select case
        when v_lat is not null and v_lon is not null
         and v.latitude is not null and v.longitude is not null
        then 6371 * pg_catalog.acos(pg_catalog.least(1.0, pg_catalog.greatest(-1.0,
               pg_catalog.cos(pg_catalog.radians(v_lat)) * pg_catalog.cos(pg_catalog.radians(v.latitude))
               * pg_catalog.cos(pg_catalog.radians(v.longitude) - pg_catalog.radians(v_lon))
               + pg_catalog.sin(pg_catalog.radians(v_lat)) * pg_catalog.sin(pg_catalog.radians(v.latitude)))))
      end as km
    ) d
    where v.is_verified and v.is_active and v.opted_in
    order by d.km nulls last, COALESCE(v.display_name, p.display_name, 'Veterinarian')
    limit v_limit
  ) r;

  return pg_catalog.jsonb_build_object('vets', v_vets);
end;
$$;

revoke execute on function public.list_available_vets(uuid, integer) from public, anon;
grant execute on function public.list_available_vets(uuid, integer) to authenticated;

-- 0025_email_otp.sql
-- 0025: Hashed 6-digit email OTP challenges (signup verify + password reset).
-- Written only by the email-otp Edge Function (service_role).

create table if not exists public.email_otp_challenges (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  purpose text not null check (purpose in ('signup', 'password_reset')),
  code_hash text not null,
  expires_at timestamptz not null,
  attempt_count int not null default 0,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists email_otp_challenges_lookup_idx
  on public.email_otp_challenges (email, purpose, created_at desc);

alter table public.email_otp_challenges enable row level security;

revoke all on table public.email_otp_challenges from public, anon, authenticated;
grant all on table public.email_otp_challenges to service_role;
