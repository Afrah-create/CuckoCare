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
