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
