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
