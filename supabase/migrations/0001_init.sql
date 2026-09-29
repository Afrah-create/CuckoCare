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

-- Helper: membership check (evaluated once per query via scalar subselect in policies)
create or replace function public.is_farm_member(p_farm_id uuid)
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
