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
