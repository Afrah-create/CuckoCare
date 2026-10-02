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
