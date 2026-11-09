-- 0027: Case Radio tables, RLS, vet RPCs, system messages, storage, pull, SMS.
-- One concern: farmer–vet store-and-forward messaging on a vet assistance request.

alter table public.vet_assistance_requests
  drop constraint if exists vet_assistance_requests_id_farm_key;
alter table public.vet_assistance_requests
  add constraint vet_assistance_requests_id_farm_key unique (id, farm_id);

alter table public.vet_profiles
  add column if not exists sms_urgent_alerts boolean not null default true;

alter table public.sms_outbox
  add column if not exists kind text not null default 'generic',
  add column if not exists request_id uuid,
  add column if not exists recipient_user_id uuid,
  add column if not exists dedupe_key text,
  add column if not exists attempts integer not null default 0,
  add column if not exists sent_at timestamptz,
  add column if not exists provider_message_id text,
  add column if not exists error_code text,
  add column if not exists updated_at timestamptz not null default now();

create unique index if not exists sms_outbox_dedupe_key_idx
  on public.sms_outbox (dedupe_key)
  where dedupe_key is not null;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.case_messages (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  request_id uuid not null,
  sender_user_id uuid references auth.users (id),
  sender_role text not null check (sender_role in ('farmer', 'vet', 'system')),
  kind text not null check (kind in ('text', 'photo', 'system')),
  body text,
  client_created_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint,
  constraint case_messages_request_farm_fk
    foreign key (request_id, farm_id)
    references public.vet_assistance_requests (id, farm_id),
  constraint case_messages_body_or_photo check (
    (kind = 'text' and body is not null and char_length(btrim(body)) between 1 and 1000)
    or (kind = 'photo' and (body is null or char_length(btrim(body)) <= 1000))
    or (kind = 'system' and body is not null and char_length(body) <= 500)
  )
);

create index if not exists case_messages_request_created_idx
  on public.case_messages (request_id, created_at, id);
create index if not exists case_messages_farm_version_idx
  on public.case_messages (farm_id, server_version);

drop trigger if exists case_messages_assign_version on public.case_messages;
create trigger case_messages_assign_version
  before insert or update on public.case_messages
  for each row execute function public.assign_sync_server_version();

create table if not exists public.case_message_attachments (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  request_id uuid not null,
  message_id uuid not null references public.case_messages (id),
  object_key text not null,
  mime text not null default 'image/jpeg',
  bytes integer,
  width integer,
  height integer,
  thumb_b64 text,
  status text not null default 'pending' check (status in ('pending', 'uploaded')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint,
  constraint case_message_attachments_request_farm_fk
    foreign key (request_id, farm_id)
    references public.vet_assistance_requests (id, farm_id),
  constraint case_message_attachments_thumb_size
    check (thumb_b64 is null or octet_length(thumb_b64) <= 10922)
);

create index if not exists case_message_attachments_message_idx
  on public.case_message_attachments (message_id);
create index if not exists case_message_attachments_farm_version_idx
  on public.case_message_attachments (farm_id, server_version);

drop trigger if exists case_message_attachments_assign_version
  on public.case_message_attachments;
create trigger case_message_attachments_assign_version
  before insert or update on public.case_message_attachments
  for each row execute function public.assign_sync_server_version();

create table if not exists public.case_read_state (
  request_id uuid not null,
  user_id uuid not null references auth.users (id),
  farm_id uuid references public.farms (id),
  last_read_at timestamptz not null,
  last_read_message_id uuid,
  muted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  server_version bigint,
  primary key (request_id, user_id)
);

create index if not exists case_read_state_farm_version_idx
  on public.case_read_state (farm_id, server_version);

drop trigger if exists case_read_state_assign_version on public.case_read_state;
create trigger case_read_state_assign_version
  before insert or update on public.case_read_state
  for each row execute function public.assign_sync_server_version();

create table if not exists public.device_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id),
  token text not null,
  platform text not null default 'android',
  app_flavor text,
  app_version text,
  locale text not null default 'en',
  push_messages_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  revoked_at timestamptz,
  unique (token)
);

create table if not exists public.push_log (
  message_id uuid not null,
  user_id uuid not null,
  sent_at timestamptz not null default now(),
  result text,
  primary key (message_id, user_id)
);

insert into public.sync_table_config (table_name, kind, scope_kind, writable_columns)
values
  (
    'case_messages',
    'append_only',
    'farm',
    array['id','request_id','kind','body','client_created_at']
  ),
  (
    'case_message_attachments',
    'mutable',
    'farm',
    array['id','request_id','message_id','object_key','mime','bytes','width','height','thumb_b64','status']
  ),
  (
    'case_read_state',
    'mutable',
    'farm',
    array['request_id','last_read_at','last_read_message_id','muted']
  )
on conflict (table_name) do update
set kind = excluded.kind,
    scope_kind = excluded.scope_kind,
    writable_columns = excluded.writable_columns;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.case_request_is_open(p_status text)
returns boolean
language sql
immutable
as $$
  select p_status in ('accepted', 'in_progress');
$$;

create or replace function public.can_view_case_request(p_request_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.vet_assistance_requests r
    where r.id = p_request_id
      and r.deleted_at is null
      and (
        public.is_farm_member(r.farm_id)
        or r.assigned_vet_user_id = (select auth.uid())
      )
  );
$$;

create or replace function public.assert_farmer_can_send_case(p_request_id uuid)
returns public.vet_assistance_requests
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_row public.vet_assistance_requests;
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;
  select * into v_row
  from public.vet_assistance_requests
  where id = p_request_id and deleted_at is null;
  if v_row.id is null then
    raise exception 'not_found' using errcode = 'P0003';
  end if;
  if not public.is_farm_member(v_row.farm_id, array['owner','manager','worker']) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.case_request_is_open(v_row.status) then
    raise exception 'case_closed' using errcode = 'P0001';
  end if;
  return v_row;
end;
$$;

create or replace function public.assert_vet_can_send_case(p_request_id uuid)
returns public.vet_assistance_requests
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_row public.vet_assistance_requests;
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;
  if not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into v_row
  from public.vet_assistance_requests
  where id = p_request_id and deleted_at is null;
  if v_row.id is null then
    raise exception 'not_found' using errcode = 'P0003';
  end if;
  if v_row.assigned_vet_user_id is distinct from v_uid then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.vet_profiles vp
    where vp.user_id = v_uid and vp.is_verified and vp.is_active
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.case_request_is_open(v_row.status) then
    raise exception 'case_closed' using errcode = 'P0001';
  end if;
  return v_row;
end;
$$;

create or replace function public.assert_case_message_quota(p_uid uuid, p_request_id uuid)
returns void
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if (
    select count(*) from public.case_messages
    where sender_user_id = p_uid
      and request_id = p_request_id
      and created_at > now() - interval '10 minutes'
  ) >= 30 then
    raise exception 'rate_limited' using errcode = 'P0002';
  end if;
  if (
    select count(*) from public.case_messages
    where sender_user_id = p_uid
      and request_id = p_request_id
      and created_at > now() - interval '1 day'
  ) >= 300 then
    raise exception 'rate_limited' using errcode = 'P0002';
  end if;
end;
$$;

create or replace function public.apply_farmer_case_message(p_payload jsonb, p_uid uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_req public.vet_assistance_requests;
  v_id uuid := (p_payload->>'id')::uuid;
  v_kind text := coalesce(p_payload->>'kind', 'text');
  v_body text := nullif(btrim(coalesce(p_payload->>'body','')), '');
  v_row public.case_messages;
begin
  if v_id is null then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into v_row from public.case_messages where id = v_id;
  if found then
    if v_row.sender_user_id is distinct from p_uid then
      raise exception 'forbidden' using errcode = '42501';
    end if;
    return to_jsonb(v_row);
  end if;
  v_req := public.assert_farmer_can_send_case((p_payload->>'request_id')::uuid);
  perform public.assert_case_message_quota(p_uid, v_req.id);
  if v_kind not in ('text', 'photo') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  insert into public.case_messages (
    id, farm_id, request_id, sender_user_id, sender_role, kind, body,
    client_created_at, created_at, updated_at
  ) values (
    v_id,
    v_req.farm_id,
    v_req.id,
    p_uid,
    'farmer',
    v_kind,
    v_body,
    coalesce((p_payload->>'client_created_at')::timestamptz, now()),
    now(),
    now()
  )
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.apply_farmer_case_attachment(p_payload jsonb, p_uid uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_req public.vet_assistance_requests;
  v_id uuid := (p_payload->>'id')::uuid;
  v_msg public.case_messages;
  v_row public.case_message_attachments;
  v_status text := coalesce(p_payload->>'status', 'pending');
begin
  select * into v_row from public.case_message_attachments where id = v_id;
  if found then
    if v_status = 'uploaded' and v_row.status = 'pending' then
      select * into v_msg from public.case_messages where id = v_row.message_id;
      if v_msg.sender_user_id is distinct from p_uid then
        raise exception 'forbidden' using errcode = '42501';
      end if;
      update public.case_message_attachments
      set status = 'uploaded',
          object_key = coalesce(p_payload->>'object_key', object_key),
          bytes = coalesce((p_payload->>'bytes')::int, bytes),
          updated_at = now()
      where id = v_id
      returning * into v_row;
    end if;
    return to_jsonb(v_row);
  end if;
  select * into v_msg from public.case_messages where id = (p_payload->>'message_id')::uuid;
  if v_msg.id is null or v_msg.sender_user_id is distinct from p_uid then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  v_req := public.assert_farmer_can_send_case(v_msg.request_id);
  insert into public.case_message_attachments (
    id, farm_id, request_id, message_id, object_key, mime, bytes, width, height,
    thumb_b64, status, created_at, updated_at
  ) values (
    v_id,
    v_req.farm_id,
    v_req.id,
    v_msg.id,
    coalesce(p_payload->>'object_key', ''),
    coalesce(p_payload->>'mime', 'image/jpeg'),
    (p_payload->>'bytes')::int,
    (p_payload->>'width')::int,
    (p_payload->>'height')::int,
    p_payload->>'thumb_b64',
    'pending',
    now(),
    now()
  )
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.apply_farmer_case_read_state(p_payload jsonb, p_uid uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_request_id uuid := (p_payload->>'request_id')::uuid;
  v_read_at timestamptz := coalesce((p_payload->>'last_read_at')::timestamptz, now());
  v_row public.case_read_state;
  v_farm uuid;
begin
  if not public.can_view_case_request(v_request_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not public.is_farm_member(
    (select farm_id from public.vet_assistance_requests where id = v_request_id)
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select farm_id into v_farm from public.vet_assistance_requests where id = v_request_id;
  insert into public.case_read_state (
    request_id, user_id, farm_id, last_read_at, last_read_message_id, muted,
    created_at, updated_at
  ) values (
    v_request_id,
    p_uid,
    v_farm,
    v_read_at,
    (p_payload->>'last_read_message_id')::uuid,
    coalesce((p_payload->>'muted')::boolean, false),
    now(),
    now()
  )
  on conflict (request_id, user_id) do update set
    last_read_at = case
      when excluded.last_read_at > case_read_state.last_read_at
      then excluded.last_read_at
      else case_read_state.last_read_at
    end,
    last_read_message_id = case
      when excluded.last_read_at > case_read_state.last_read_at
      then excluded.last_read_message_id
      else case_read_state.last_read_message_id
    end,
    muted = excluded.muted,
    updated_at = now()
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

-- ---------------------------------------------------------------------------
-- Vet RPCs
-- ---------------------------------------------------------------------------

create or replace function public.send_case_message(
  p_id uuid,
  p_request_id uuid,
  p_kind text,
  p_body text,
  p_client_created_at timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_req public.vet_assistance_requests;
  v_uid uuid := auth.uid();
  v_row public.case_messages;
  v_kind text := coalesce(p_kind, 'text');
  v_body text := nullif(btrim(coalesce(p_body,'')), '');
begin
  select * into v_row from public.case_messages where id = p_id;
  if found then
    return to_jsonb(v_row);
  end if;
  v_req := public.assert_vet_can_send_case(p_request_id);
  perform public.assert_case_message_quota(v_uid, v_req.id);
  if v_kind not in ('text', 'photo') then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  insert into public.case_messages (
    id, farm_id, request_id, sender_user_id, sender_role, kind, body,
    client_created_at, created_at, updated_at
  ) values (
    p_id, v_req.farm_id, v_req.id, v_uid, 'vet', v_kind, v_body,
    coalesce(p_client_created_at, now()), now(), now()
  )
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.add_case_attachment(
  p_id uuid,
  p_request_id uuid,
  p_message_id uuid,
  p_object_key text,
  p_mime text,
  p_bytes int,
  p_width int,
  p_height int,
  p_thumb_b64 text,
  p_status text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_req public.vet_assistance_requests;
  v_uid uuid := auth.uid();
  v_msg public.case_messages;
  v_row public.case_message_attachments;
begin
  select * into v_row from public.case_message_attachments where id = p_id;
  if found then
    if coalesce(p_status, '') = 'uploaded' and v_row.status = 'pending' then
      update public.case_message_attachments
      set status = 'uploaded',
          object_key = coalesce(p_object_key, object_key),
          bytes = coalesce(p_bytes, bytes),
          updated_at = now()
      where id = p_id
      returning * into v_row;
    end if;
    return to_jsonb(v_row);
  end if;
  v_req := public.assert_vet_can_send_case(p_request_id);
  select * into v_msg from public.case_messages where id = p_message_id;
  if v_msg.sender_user_id is distinct from v_uid then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  insert into public.case_message_attachments (
    id, farm_id, request_id, message_id, object_key, mime, bytes, width, height,
    thumb_b64, status, created_at, updated_at
  ) values (
    p_id, v_req.farm_id, v_req.id, p_message_id,
    coalesce(p_object_key, ''), coalesce(p_mime, 'image/jpeg'),
    p_bytes, p_width, p_height, p_thumb_b64, 'pending', now(), now()
  )
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.mark_case_read(
  p_request_id uuid,
  p_message_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_farm uuid;
  v_row public.case_read_state;
begin
  if not public.can_view_case_request(p_request_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select farm_id into v_farm from public.vet_assistance_requests where id = p_request_id;
  insert into public.case_read_state (
    request_id, user_id, farm_id, last_read_at, last_read_message_id, muted,
    created_at, updated_at
  ) values (p_request_id, v_uid, v_farm, now(), p_message_id, false, now(), now())
  on conflict (request_id, user_id) do update set
    last_read_at = case
      when now() > case_read_state.last_read_at then now()
      else case_read_state.last_read_at
    end,
    last_read_message_id = case
      when now() > case_read_state.last_read_at then excluded.last_read_message_id
      else case_read_state.last_read_message_id
    end,
    updated_at = now()
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.set_case_muted(p_request_id uuid, p_muted boolean)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_farm uuid;
  v_row public.case_read_state;
begin
  if not public.can_view_case_request(p_request_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select farm_id into v_farm from public.vet_assistance_requests where id = p_request_id;
  insert into public.case_read_state (
    request_id, user_id, farm_id, last_read_at, muted, created_at, updated_at
  ) values (p_request_id, v_uid, v_farm, now(), coalesce(p_muted, false), now(), now())
  on conflict (request_id, user_id) do update set
    muted = excluded.muted,
    updated_at = now()
  returning * into v_row;
  return to_jsonb(v_row);
end;
$$;

create or replace function public.pull_assigned_case_messages(p_since bigint default 0)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_rows jsonb;
begin
  if v_uid is null or not public.is_vet() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'table', table_name,
    'server_version', server_version,
    'row', row
  ) order by server_version), '[]'::jsonb)
  into v_rows
  from (
    select 'case_messages'::text as table_name, m.server_version, to_jsonb(m) as row
    from public.case_messages m
    join public.vet_assistance_requests r on r.id = m.request_id
    where r.assigned_vet_user_id = v_uid
      and m.server_version > coalesce(p_since, 0)
    union all
    select 'case_message_attachments', a.server_version, to_jsonb(a)
    from public.case_message_attachments a
    join public.vet_assistance_requests r on r.id = a.request_id
    where r.assigned_vet_user_id = v_uid
      and a.server_version > coalesce(p_since, 0)
    union all
    select 'case_read_state', s.server_version, to_jsonb(s)
    from public.case_read_state s
    join public.vet_assistance_requests r on r.id = s.request_id
    where r.assigned_vet_user_id = v_uid
      and (s.user_id = v_uid or true)
      and s.server_version > coalesce(p_since, 0)
    order by 2
    limit 500
  ) t;
  return jsonb_build_object('rows', coalesce(v_rows, '[]'::jsonb));
end;
$$;

create or replace function public.register_push_token(
  p_token text,
  p_platform text default 'android',
  p_flavor text default null,
  p_version text default null,
  p_locale text default 'en'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or coalesce(p_token, '') = '' then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  insert into public.device_push_tokens (
    user_id, token, platform, app_flavor, app_version, locale, last_seen_at
  ) values (
    v_uid, p_token, coalesce(p_platform, 'android'), p_flavor, p_version,
    coalesce(p_locale, 'en'), now()
  )
  on conflict (token) do update set
    user_id = excluded.user_id,
    platform = excluded.platform,
    app_flavor = excluded.app_flavor,
    app_version = excluded.app_version,
    locale = excluded.locale,
    last_seen_at = now(),
    revoked_at = null,
    push_messages_enabled = true;
end;
$$;

create or replace function public.unregister_push_token(p_token text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.device_push_tokens
  set revoked_at = now(), push_messages_enabled = false
  where token = p_token and user_id = auth.uid();
end;
$$;

create or replace function public.set_push_messages_enabled(p_enabled boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.device_push_tokens
  set push_messages_enabled = coalesce(p_enabled, true)
  where user_id = auth.uid() and revoked_at is null;
end;
$$;

-- ---------------------------------------------------------------------------
-- System messages on status change
-- ---------------------------------------------------------------------------

create or replace function public.case_radio_status_system_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_body text;
  v_name text;
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;
  if old.status is not distinct from new.status then
    return new;
  end if;
  if new.status not in ('accepted', 'in_progress', 'completed', 'declined', 'cancelled') then
    return new;
  end if;
  select coalesce(nullif(p.display_name, ''), 'The vet')
    into v_name
  from public.profiles p
  where p.user_id = coalesce(new.assigned_vet_user_id, old.assigned_vet_user_id);
  v_body := case new.status
    when 'accepted' then coalesce(v_name, 'The vet') || ' accepted your request'
    when 'in_progress' then coalesce(v_name, 'The vet') || ' started the visit'
    when 'completed' then 'The vet marked this case completed'
    when 'declined' then 'The vet declined this request'
    when 'cancelled' then 'This request was cancelled'
    else null
  end;
  if v_body is null then
    return new;
  end if;
  insert into public.case_messages (
    id, farm_id, request_id, sender_user_id, sender_role, kind, body,
    client_created_at, created_at, updated_at
  ) values (
    gen_random_uuid(), new.farm_id, new.id, null, 'system', 'system', v_body,
    now(), now(), now()
  );
  return new;
end;
$$;

drop trigger if exists case_radio_status_system_message on public.vet_assistance_requests;
create trigger case_radio_status_system_message
  after update of status on public.vet_assistance_requests
  for each row execute function public.case_radio_status_system_message();

-- ---------------------------------------------------------------------------
-- Urgent SMS enqueue
-- ---------------------------------------------------------------------------

create or replace function public.enqueue_urgent_case_sms()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int := 0;
  v_req record;
  v_phone text;
  v_district text;
  v_key text;
  v_day date := (timezone('Africa/Kampala', now()))::date;
  v_vet_sms int;
  v_body text;
begin
  for v_req in
    select r.*,
      coalesce(vp.phone, pr.phone) as vet_phone,
      vp.sms_urgent_alerts,
      vp.is_verified,
      vp.is_active,
      f.district
    from public.vet_assistance_requests r
    left join public.vet_profiles vp
      on vp.user_id = coalesce(r.assigned_vet_user_id, r.requested_vet_user_id)
    left join public.profiles pr
      on pr.user_id = coalesce(r.assigned_vet_user_id, r.requested_vet_user_id)
    left join public.farms f on f.id = r.farm_id
    where r.deleted_at is null
      and r.priority = 'urgent'
      and coalesce(r.assigned_vet_user_id, r.requested_vet_user_id) is not null
  loop
    if v_req.is_verified is not true or v_req.is_active is not true then
      continue;
    end if;
    if v_req.sms_urgent_alerts is not true then
      continue;
    end if;
    v_phone := v_req.vet_phone;
    if v_phone is null or btrim(v_phone) = '' then
      continue;
    end if;
    select count(*) into v_vet_sms
    from public.sms_outbox
    where recipient_user_id = coalesce(v_req.assigned_vet_user_id, v_req.requested_vet_user_id)
      and created_at > now() - interval '1 day'
      and kind like 'urgent_%';
    if v_vet_sms >= 3 then
      continue;
    end if;
    v_district := coalesce(nullif(v_req.district, ''), 'your area');
    v_body := 'CucoCare: an urgent poultry case in '
      || v_district
      || ' is waiting for you. Please open the app to reply.';

    -- Rule A: unaccepted
    if v_req.status in ('submitted', 'received')
       and v_req.created_at < now() - interval '30 minutes' then
      v_key := 'urgent_accept:' || v_req.id::text || ':' || v_day::text;
      if not exists (select 1 from public.sms_outbox where dedupe_key = v_key) then
        insert into public.sms_outbox (
          farm_id, phone, message, status, kind, request_id, recipient_user_id, dedupe_key
        ) values (
          v_req.farm_id, v_phone, v_body, 'pending', 'urgent_accept',
          v_req.id, coalesce(v_req.assigned_vet_user_id, v_req.requested_vet_user_id), v_key
        );
        insert into public.case_messages (
          id, farm_id, request_id, sender_user_id, sender_role, kind, body,
          client_created_at, created_at, updated_at
        ) values (
          gen_random_uuid(), v_req.farm_id, v_req.id, null, 'system', 'system',
          'We sent the vet an SMS reminder',
          now(), now(), now()
        );
        v_count := v_count + 1;
      end if;
    end if;

    -- Rule B: unanswered after accept
    if v_req.status in ('accepted', 'in_progress') then
      if exists (
        select 1 from public.case_messages m
        where m.request_id = v_req.id
          and m.sender_role = 'farmer'
          and m.created_at < now() - interval '60 minutes'
          and not exists (
            select 1 from public.case_messages r
            where r.request_id = v_req.id
              and r.sender_role = 'vet'
              and r.created_at > m.created_at
          )
          and not exists (
            select 1 from public.case_read_state s
            where s.request_id = v_req.id
              and s.user_id = v_req.assigned_vet_user_id
              and s.last_read_at > m.created_at
          )
      ) then
        v_key := 'urgent_reply:' || v_req.id::text || ':' || v_day::text;
        if not exists (select 1 from public.sms_outbox where dedupe_key = v_key) then
          insert into public.sms_outbox (
            farm_id, phone, message, status, kind, request_id, recipient_user_id, dedupe_key
          ) values (
            v_req.farm_id, v_phone, v_body, 'pending', 'urgent_reply',
            v_req.id, v_req.assigned_vet_user_id, v_key
          );
          insert into public.case_messages (
            id, farm_id, request_id, sender_user_id, sender_role, kind, body,
            client_created_at, created_at, updated_at
          ) values (
            gen_random_uuid(), v_req.farm_id, v_req.id, null, 'system', 'system',
            'We sent the vet an SMS reminder',
            now(), now(), now()
          );
          v_count := v_count + 1;
        end if;
      end if;
    end if;
  end loop;
  return v_count;
end;
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.case_messages enable row level security;
alter table public.case_message_attachments enable row level security;
alter table public.case_read_state enable row level security;
alter table public.device_push_tokens enable row level security;
alter table public.push_log enable row level security;

drop policy if exists case_messages_select on public.case_messages;
create policy case_messages_select on public.case_messages
  for select to authenticated
  using (public.can_view_case_request(request_id));

drop policy if exists case_message_attachments_select on public.case_message_attachments;
create policy case_message_attachments_select on public.case_message_attachments
  for select to authenticated
  using (public.can_view_case_request(request_id));

drop policy if exists case_read_state_own on public.case_read_state;
create policy case_read_state_own on public.case_read_state
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists device_push_tokens_own on public.device_push_tokens;
create policy device_push_tokens_own on public.device_push_tokens
  for select to authenticated
  using (user_id = (select auth.uid()));

revoke insert, update, delete on public.case_messages from authenticated, anon, public;
revoke insert, update, delete on public.case_message_attachments from authenticated, anon, public;
revoke insert, update, delete on public.case_read_state from authenticated, anon, public;
revoke insert, update, delete on public.device_push_tokens from authenticated, anon, public;
revoke all on public.push_log from authenticated, anon, public;
grant select on public.case_messages to authenticated;
grant select on public.case_message_attachments to authenticated;
grant select on public.case_read_state to authenticated;
grant select on public.device_push_tokens to authenticated;

revoke execute on function public.send_case_message(uuid, uuid, text, text, timestamptz) from public, anon;
revoke execute on function public.add_case_attachment(uuid, uuid, uuid, text, text, int, int, int, text, text) from public, anon;
revoke execute on function public.mark_case_read(uuid, uuid) from public, anon;
revoke execute on function public.set_case_muted(uuid, boolean) from public, anon;
revoke execute on function public.pull_assigned_case_messages(bigint) from public, anon;
revoke execute on function public.register_push_token(text, text, text, text, text) from public, anon;
revoke execute on function public.unregister_push_token(text) from public, anon;
revoke execute on function public.set_push_messages_enabled(boolean) from public, anon;
revoke execute on function public.enqueue_urgent_case_sms() from public, anon, authenticated;
revoke execute on function public.apply_farmer_case_message(jsonb, uuid) from public, anon, authenticated;
revoke execute on function public.apply_farmer_case_attachment(jsonb, uuid) from public, anon, authenticated;
revoke execute on function public.apply_farmer_case_read_state(jsonb, uuid) from public, anon, authenticated;

grant execute on function public.send_case_message(uuid, uuid, text, text, timestamptz) to authenticated;
grant execute on function public.add_case_attachment(uuid, uuid, uuid, text, text, int, int, int, text, text) to authenticated;
grant execute on function public.mark_case_read(uuid, uuid) to authenticated;
grant execute on function public.set_case_muted(uuid, boolean) to authenticated;
grant execute on function public.pull_assigned_case_messages(bigint) to authenticated;
grant execute on function public.register_push_token(text, text, text, text, text) to authenticated;
grant execute on function public.unregister_push_token(text) to authenticated;
grant execute on function public.set_push_messages_enabled(boolean) to authenticated;

-- ---------------------------------------------------------------------------
-- Storage policies for message keys: {farm_id}/requests/{request_id}/messages/...
-- ---------------------------------------------------------------------------

drop policy if exists health_incident_images_select_case on storage.objects;
create policy health_incident_images_select_case on storage.objects
  for select to authenticated
  using (
    bucket_id = 'health-incident-images'
    and public.can_view_case_request(((storage.foldername(name))[3])::uuid)
  );

drop policy if exists health_incident_images_insert_case on storage.objects;
create policy health_incident_images_insert_case on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'health-incident-images'
    and (storage.foldername(name))[2] = 'requests'
    and public.can_view_case_request(((storage.foldername(name))[3])::uuid)
    and exists (
      select 1 from public.vet_assistance_requests r
      where r.id = ((storage.foldername(name))[3])::uuid
        and public.case_request_is_open(r.status)
    )
  );

-- ---------------------------------------------------------------------------
-- sync_pull: include case tables (own read-state only)
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
      select 'case_messages', server_version, to_jsonb(t)
      from public.case_messages t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'case_message_attachments', server_version, to_jsonb(t)
      from public.case_message_attachments t
      where t.farm_id::text = $1 and t.server_version > $2
      union all
      select 'case_read_state', server_version, to_jsonb(t)
      from public.case_read_state t
      where t.farm_id::text = $1
        and t.user_id = auth.uid()
        and t.server_version > $2
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

do $$
begin
  alter publication supabase_realtime add table public.case_messages;
exception
  when duplicate_object then null;
  when undefined_object then null;
end $$;
