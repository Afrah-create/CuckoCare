# CukoCare Feed Module — Implementation Plan

Generated from `docs/feed.md` and a full read of all migrations (0001–0017),
supabase tests, Dart data-platform and feed-feature code, and project rules.

---

## Ground rules (encoded from spec)

- Never edit a migration file that has already been applied. Add corrective
  migrations only. Next migration number: **0018**.
- One concern per migration file.
- No new Dart or pub dependencies (geolocator already present; no additions
  needed).
- Fix root causes. Never delete, skip, or weaken tests.
- All paths in prompts and stop conditions are absolute.
- Docker / Supabase CLI may not be available in CI. If `supabase db reset`
  cannot run, say so and proceed with static analysis; write every migration
  and test as if it will run.

---

## Key decisions (canonical names)

| Question | Decision | Rationale |
|---|---|---|
| `usage` vs `consumption` for feed transactions | **`consumption`** is canonical | Dart enum `FeedTransactionKind` already uses `consumption`; `usage` only appears in the 0002 DB check. Data-migration row required. |
| `adjustment` semantics | **Signed quantity** (positive = stock in, negative = stock out, non-zero) | Domain model needs this for net stock to be correct. Existing `quantity > 0` check on the DB must be removed for the `adjustment` kind only. |
| `feed_items` upsert | **Config-driven from `writable_columns`** | Generic fallback in 0017 only updates `name`; `feed_type`, `unit`, `reorder_level`, `deleted_at` are silently dropped. |
| `FeedMetrics` vs `FeedStock` | Introduce **`FeedMetrics`** as the canonical domain class | `FeedStock` lacks `isInconsistent`, clamping, `totalPurchased`, `totalConsumed`, `totalWastage`, cost totals. Architecture rule 6. |
| `FeedTransactionKind.isPositive` | Remove; replace with **`signedQuantity(double raw)`** helper | Adjustments can be negative; a simple boolean sign is wrong. |
| Same-farm references for `feed_transactions` | **DB-level check in the `sync_push` apply step** (not composite FK) | Composite FKs require `(feed_item_id, farm_id)` index on `feed_items`, which is additive but the check is simpler to maintain and matches the existing `mortality_records` pattern. |
| `feed_routes.dart` | Convert to **typed GoRouter `GoRouteData`** | Current code uses `Navigator.push` / `MaterialPageRoute` directly, violating the navigation steering rule. |
| `sync_apply.dart` feed handlers | **Add `feed_items` and `feed_transactions` to `_mapperFor`** | They currently return `null` and are silently dropped on pull. |

---

## STEP 1 — Reproduce and triage

**What:** Run the test/build suite and capture all failures; write the review
document stub.

If Docker / Supabase CLI is unavailable, document that and proceed with static
analysis.

**Files to create/modify:**
- `docs/feed-module-review.md` (create; initial triage table)

**Commands (run in order):**
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
supabase db reset          # if available
supabase test db           # if available
```

**Expected failures to capture (from static analysis):**

| ID | Severity | Layer | Root cause (pre-fix) |
|----|----------|-------|----------------------|
| F-01 | P0 | DB / sync_push | Cross-farm IDOR: `v_farm_id` from payload, no stored-row authorisation |
| F-02 | P0 | DB / sync_push | `writable_columns` never enforced |
| F-03 | P0 | DB / sync_push | Reference tables (`programmes`, `programme_steps`) not rejected — currently just skip auth but run generic upsert |
| F-04 | P0 | DB / sync_push | Retryable FK failure stored in `sync_ops_applied` → permanent duplicate |
| F-05 | P0 | DB / sync_push | Duplicate overwrites `rejected` status |
| F-06 | P0 | DB / sync_push | `sqlerrm` returned to client |
| F-07 | P0 | DB / list_available_vets | No farm-membership check; returns raw coordinates; no verified filter |
| F-08 | P0 | DB / vet request | `pending_sync` accepted as server status; farmer can revert vet-controlled states |
| F-09 | P1 | DB / feed_transactions | `usage` kind still in schema (0002 check); Dart enum uses `consumption` |
| F-10 | P1 | DB / feed_transactions | No same-farm reference check for `feed_item_id` / `batch_id` |
| F-11 | P1 | DB / sync_push | Generic fallback only updates `name`; `feed_items` edits silently dropped |
| F-12 | P1 | DB / feed_transactions | `quantity > 0` blocks negative adjustments |
| F-13 | P1 | Dart / sync_apply | `feed_items` and `feed_transactions` not in `_mapperFor` → pull silently dropped |
| F-14 | P1 | Dart / FeedMetrics | `FeedStock.isInconsistent` missing; no clamping; adjustment sign wrong |
| F-15 | P1 | DB / vaccination_tasks | Monotonic status guard does not protect `done_on`, `done_by`, `product_used`, `notes` when status loses |
| F-16 | P2 | Dart / feed_routes | Uses raw `Navigator.push` / `MaterialPageRoute` (navigation rule violation) |
| F-17 | P2 | DB / sync_push | `server_version` returned as text string; Dart `syncJsonInt` handles it but spec requires numeric |
| F-18 | P2 | DB / farms | `coalesce()` in upsert prevents clearing location/phone fields |
| F-19 | P2 | DB | No `revoke execute from public, anon` on `sync_push`, `list_available_vets` |
| F-20 | P2 | DB | `farms` upsert branch appears twice in 0017 (dead second branch after `elsif v_table = 'farms'`) |

**Record in:** `docs/feed-module-review.md` — findings table, contract mismatch
table (columns compared across Supabase, `sync_table_config`, `sync_push`
upserts, Drift tables, mapper `toPayload`).

**Verify:** `flutter analyze` exits 0; `flutter test` result captured (may fail
before fixes).

---

## STEP 2 — Contract mismatch table and canonical-name decisions

**What:** Build the contract mismatch table by comparing columns across the five
layers for each synced table. Record decisions already made above; flag any
remaining ambiguities.

**Files to modify:**
- `docs/feed-module-review.md` (append contract mismatch section)

**Mismatch table to populate (per table):**

| Table | Column | Supabase | sync_table_config writable_cols | sync_push upsert | Drift table | toPayload mapper |
|-------|--------|----------|---------------------------------|-------------------|-------------|-----------------|
| feed_transactions | kind check | `purchase,usage,adjustment` (0002) | — | `kind in ('purchase','consumption','wastage','adjustment','usage')` (0017) | enum: purchase, consumption, adjustment, wastage | `row.kind` (from Dart enum `.storage` = `.name`) |
| feed_items | writable_cols 0017 | id,farm_id,name,feed_type,unit,reorder_level,deleted_at,created_at | ✓ | sync_push generic only updates `name` | ✓ | ✓ |
| batches | `farm_id` in do-update | — | not listed | `farm_id = excluded.farm_id` | — | — |
| vaccination_tasks | `farm_id` in do-update | — | not listed | `farm_id = excluded.farm_id` | — | — |
| vet_assistance_requests | `farm_id` in do-update | — | not listed | `farm_id = excluded.farm_id` | — | — |
| farms | null-clearing via `coalesce()` | all nullable fields | listed | `coalesce(excluded.x, farms.x)` | — | — |

**Decisions to record:**
1. Canonical `feed_transactions.kind` = `consumption` (not `usage`). Migration 0018 renames existing rows and tightens the CHECK constraint.
2. `adjustment` `quantity` must allow negative values. The CHECK on `feed_transactions` changes from `quantity > 0` to `quantity <> 0` for `adjustment` only.
3. Column lists in `sync_push` branches for `batches`, `vaccination_tasks`, `vet_assistance_requests` must not include `farm_id` in the `do update set` clause. `farm_id` is immutable after insert.
4. `farms` upsert must use `excluded.x` (not `coalesce`) so null values clear fields; retain coalesce ONLY for `location` (derived from district+village) and `profile_completed_at`.

**No column renames required** (Drift column names, after `camelToSnake`, match Supabase column names for all feed tables). STEP 7 (column-name reconciliation migration) is therefore a **no-op** for the feed tables, but needed for `vaccination_tasks` if `occurrence`, `enabled`, `done_by`, `shifted_from` differ — check confirmed they match (0006 added them). No migration 0021 needed.

**Verify:** Manually review the mismatch table in `docs/feed-module-review.md`. No automated gate for this step.

---

## STEP 3 — pgTAP tests (red — all expected to fail before fixes)

**What:** Write all pgTAP tests from Part F of the spec. These are the acceptance
gate for STEPS 4–6 and must be red before any schema change.

**Files to create:**
- `supabase/tests/database/feed_schema_test.sql` — feed constraints, kinds, same-farm refs
- `supabase/tests/database/sync_push_security_test.sql` — cross-farm, payload filtering, reference-table rejection, idempotency, per-op isolation, config-driven upsert, task monotonicity, vet request transitions, farm field clearing, roles
- `supabase/tests/database/list_available_vets_test.sql` — membership check, privacy, filter, limit, anon

**Test plan per file:**

### `feed_schema_test.sql`
```
select plan(N);  -- fill N after writing tests
-- 1. kind CHECK rejects 'usage' after migration
-- 2. kind CHECK accepts purchase, consumption, wastage, adjustment
-- 3. quantity > 0 for purchase
-- 4. quantity > 0 for consumption
-- 5. quantity > 0 for wastage
-- 6. quantity <> 0 for adjustment (allows negative)
-- 7. unit_cost >= 0 when present
-- 8. feed_transaction with feed_item_id from another farm is rejected (via sync_push)
-- 9. feed_transaction with batch_id from another farm is rejected (via sync_push)
-- 10. sync_pull returns feed_items with (farm_id, server_version) index present
```

### `sync_push_security_test.sql`
```
select plan(N);
-- Cross-farm upsert: farm_id cannot change after insert (batches, vaccination_tasks, etc.)
-- Cross-farm upsert: row from farm A cannot be overwritten by user of farm B
-- Payload filtering: server_version, created_by, deleted_group_id in payload do not set them
-- Reference table: sync_push on 'programmes' returns rejected/forbidden
-- Reference table: sync_push on 'programme_steps' returns rejected/forbidden
-- Idempotency: replaying applied op returns duplicate with original status not overwritten
-- Idempotency: retryable FK failure NOT stored → retry succeeds once parent exists
-- Idempotency: non-retryable rejection replays as rejected
-- Per-op isolation: second op in a batch succeeds even if first op fails
-- Config-driven upsert feed_items: feed_type, unit, reorder_level, deleted_at persist
-- Schema contract: every writable_column for every table exists as real column
-- Task monotonicity: lower-rank incoming update does not erase done_on, done_by, product_used, notes
-- Vet request: farmer cannot push 'accepted' or 'in_progress' status
-- Vet request: pending_sync is not accepted server status after fix
-- Vet request: farmer can cancel only before vet accepts
-- Farm fields: explicit null in payload clears latitude
-- Farm fields: omitting key keeps existing latitude
-- Role viewer: cannot push any op
-- Role worker: can push feed_transaction; cannot push batch edit
```

### `list_available_vets_test.sql`
```
select plan(N);
-- Non-member calling list_available_vets with another farm's id raises exception
-- Response does not contain raw latitude/longitude fields
-- Unverified vet not returned
-- Inactive / opted-out vet not returned
-- Result count <= limit
-- anon cannot execute list_available_vets
-- anon cannot execute sync_push
```

**Verify (pre-fix, expected RED):**
```
supabase test db   # many failures expected
```

---

## STEP 4 — Feed schema migration (E.1) → `0018_feed_schema_fix.sql`

**What:** Fix the `feed_transactions` kind values and constraints.

**Files to create:**
- `supabase/migrations/0018_feed_schema_fix.sql`

**Content must include (in order):**

1. **Kind migration** — migrate `usage` → `consumption` in existing rows:
   ```sql
   update public.feed_transactions set kind = 'consumption' where kind = 'usage';
   ```
2. **Drop old check, add new check** — canonical set, no `usage`:
   ```sql
   alter table public.feed_transactions drop constraint if exists feed_transactions_kind_check;
   alter table public.feed_transactions
     add constraint feed_transactions_kind_check
     check (kind in ('purchase', 'consumption', 'wastage', 'adjustment'));
   ```
3. **Quantity sign rules** — split check so adjustment can be negative:
   ```sql
   alter table public.feed_transactions drop constraint if exists feed_transactions_quantity_check;
   alter table public.feed_transactions
     add constraint feed_transactions_quantity_positive
     check (kind in ('purchase','consumption','wastage') and quantity > 0
            or kind = 'adjustment' and quantity <> 0) not valid;
   -- (validate only new rows; old rows left as-is)
   ```
   Add `not valid` to avoid blocking the migration if legacy rows are odd.
4. **`unit_cost` non-negative check**:
   ```sql
   alter table public.feed_transactions drop constraint if exists feed_transactions_unit_cost_check;
   alter table public.feed_transactions
     add constraint feed_transactions_unit_cost_check
     check (unit_cost is null or unit_cost >= 0) not valid;
   ```
5. **Same-farm composite references** — enforced via function-based check added to `sync_push` (STEP 5) rather than composite FK (because `feed_items.id` is UUID primary key not composite). Add a comment to this migration noting that enforcement is in `sync_push` (STEP 5).
6. **Indexes** — add if not present:
   ```sql
   create index if not exists feed_items_farm_deleted_idx
     on public.feed_items (farm_id, deleted_at);
   create index if not exists feed_transactions_item_occurred_idx
     on public.feed_transactions (feed_item_id, occurred_on)
     where deleted_at is null;
   ```
   The `(farm_id, server_version)` index already exists from 0002.
7. **`sync_table_config` — correct `feed_items` writable columns** (already updated in 0017 to include `deleted_at`; verify and only update if 0017 left a gap):
   ```sql
   update public.sync_table_config
   set kind = 'mutable',
       writable_columns = array[
         'id','farm_id','name','feed_type','unit','reorder_level','deleted_at','created_at'
       ]
   where table_name = 'feed_items';
   ```
   `feed_transactions` is `append_only`; its writable_columns from 0017 are correct.

**Header comment** must state: reason = "Feed schema hardening: canonical kinds, signed adjustments, indexes. Corrects 0002/0017. Rollback: reverse data migration and drop constraints."

**Verify:**
```
supabase db reset
supabase test db   # feed_schema_test.sql should now pass; security tests still red
flutter test       # no Dart changes yet
```

---

## STEP 5 — `sync_push` hardening migration (E.2) → `0019_sync_push_hardening.sql`

**What:** Fix all B1 and B2 bugs in `sync_push`. This is the largest migration.

**Files to create:**
- `supabase/migrations/0019_sync_push_hardening.sql`

**The new `sync_push` must implement these changes (all in one `create or replace function`):**

### Security hardening (B1)

**B1.1 — Stored-farm authorisation (IDOR fix)**

Before any upsert branch, for a non-`farms` table, load the stored `farm_id`
from the existing row when `v_row_id` already exists:

```sql
-- After v_farm_id is set from payload:
if v_table <> 'farms' and v_kind is not null then
  declare v_stored_farm_id uuid;
  execute format('select farm_id from public.%I where id = $1', v_table)
    into v_stored_farm_id using v_row_id;
  if v_stored_farm_id is not null then
    -- Row exists: authorise against STORED farm, ignore payload farm_id
    if v_stored_farm_id <> v_farm_id then
      -- Payload farm_id doesn't match stored — reject, not retryable
      v_result := jsonb_build_object('op_id', v_op_id, 'status', 'rejected',
        'error_code', 'forbidden', 'retryable', false);
      insert into public.sync_ops_applied (op_id, user_id, result) values (v_op_id, v_uid, v_result);
      v_results := v_results || jsonb_build_array(v_result);
      continue;
    end if;
    v_farm_id := v_stored_farm_id;
  end if;
end if;
```

**B1.2 — `farm_id` immutable in every `do update set` clause**

Remove `farm_id = excluded.farm_id` from every branch: `batches`,
`vaccination_tasks`, `mortality_records`, `vet_assistance_requests`.
In the `farms` branch, `farm_id` is the row id so no change needed.

**B1.3 — `where ... farm_id = excluded.farm_id` guard on all mutable upserts**

Add `where <table>.farm_id = excluded.farm_id` to every `on conflict ... do
update` so the UPDATE silently does nothing (returns null rows) if farm_id
mismatches, then check `v_existing is null` and reject with `forbidden`.

**B1.4 — Reference-table rejection**

Before the farm-authorisation block, add:
```sql
if v_kind = 'reference' then
  v_result := jsonb_build_object('op_id', v_op_id, 'status', 'rejected',
    'error_code', 'forbidden', 'retryable', false);
  insert into public.sync_ops_applied (op_id, user_id, result)
    values (v_op_id, v_uid, v_result);
  v_results := v_results || jsonb_build_array(v_result);
  continue;
end if;
```
Remove the `elsif v_table <> 'programmes' and v_table <> 'programme_steps'` bypass — it is no longer needed (the `reference` kind check above rejects them).

**B1.5 — Vet request state-machine enforcement**

Replace the current allowlist check with a transition table:

```sql
-- Farmer-writable initial states: draft, submitted
-- Farmer can cancel only if current status not in (accepted, in_progress, completed)
-- pending_sync is never a server status
declare
  v_existing_status text;
  v_new_status text := coalesce(v_payload->>'status', 'submitted');

select status into v_existing_status from public.vet_assistance_requests where id = v_row_id;

if v_new_status = 'pending_sync' then
  -- Normalise to submitted
  v_new_status := 'submitted';
  v_payload := jsonb_set(v_payload, '{status}', '"submitted"');
end if;

if v_new_status not in ('draft','submitted','cancelled') then
  -- Farmer cannot push vet-controlled statuses
  v_result := jsonb_build_object('op_id', v_op_id, 'status', 'rejected',
    'error_code', 'forbidden', 'retryable', false);
  ...continue;
end if;

if v_new_status = 'cancelled' and v_existing_status in ('accepted','in_progress','completed') then
  v_result := jsonb_build_object(...'error_code', 'forbidden'...);
  ...continue;
end if;
```

**B1.6 — No `sqlerrm` in response**

In the `when others` exception handler, change:
```sql
-- REMOVE: 'message', sqlerrm
v_result := jsonb_build_object(
  'op_id', v_op->>'op_id',
  'status', 'rejected',
  'error_code', sqlstate,
  'retryable', v_retryable
);
```

**B1.7 — Revokes and `search_path` hardening**

After `create or replace function`:
```sql
revoke execute on function public.sync_push(jsonb) from public, anon;
grant execute on function public.sync_push(jsonb) to authenticated;
```
`set search_path = public` already present; confirm it stays.

### Data-loss fixes (B2)

**B2.1 — Terminal-only idempotency records**

In the `fk_violation` handler (retryable = true), **remove** the insert into
`sync_ops_applied`. Only terminal (applied, non-retryable rejected) outcomes are
stored.

**B2.2 — Duplicate preserves original status**

Change the duplicate branch from:
```sql
-- OLD (wrong):
v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('status', 'duplicate'));
```
to:
```sql
-- NEW (correct): return original result + duplicate flag
v_results := v_results || jsonb_build_array(v_result || jsonb_build_object('duplicate', true));
```
The `status` field retains the original `applied` or `rejected` value.

**B2.3 — Config-driven generic upsert for `feed_items` (and any future table)**

Replace the catch-all `else` branch with a generic upsert that iterates over
`writable_columns` from `sync_table_config`, building a parameterised UPDATE:

```sql
-- Build SET clause from writable_columns excluding id, farm_id, created_at on update
declare
  v_cols text[];
  v_set_parts text[];
  v_col text;

select writable_columns into v_cols
from public.sync_table_config where table_name = v_table;

-- Filter: exclude id, farm_id, created_at for update
select array_agg(c)
into v_set_parts
from unnest(v_cols) c
where c not in ('id', 'farm_id', 'created_at');

-- Build and execute upsert
execute format(
  'insert into public.%1$I (%2$s)
   select %2$s from jsonb_populate_record(null::public.%1$I, $1)
   on conflict (id) do update set %3$s, updated_at = now()
   where public.%1$I.farm_id = excluded.farm_id
   returning to_jsonb(%1$I.*)',
  v_table,
  (select string_agg(format('%%I', c), ', ' order by c) from unnest(v_cols) c),
  (select string_agg(format('%%1$I = excluded.%%1$I', c), ', ' order by c)
     from unnest(v_set_parts) c)
) into v_existing using v_payload;
```

This makes `feed_items` edits (feed_type, unit, reorder_level, deleted_at)
persist correctly and future tables automatically benefit.

**B2.4 — Task monotonicity guard on sibling fields**

In the `vaccination_tasks` branch, wrap `done_on`, `done_by`, `product_used`,
`notes` updates inside the same rank check:
```sql
done_on = case
  when public.task_status_rank(excluded.status) >= public.task_status_rank(vaccination_tasks.status)
    then excluded.done_on
  else vaccination_tasks.done_on
end,
-- same pattern for done_by, product_used, notes
```

**B2.5 — Farm field null-clearing**

Change `coalesce(excluded.x, farms.x)` to `excluded.x` for all nullable
location/contact fields so an explicit `null` clears them. Keep
`coalesce(excluded.location, farms.location)` ONLY if `location` is derived;
since we synthesise `location` in `save_farm_profile`, the `sync_push` farm
branch should use `excluded.x` for `latitude`, `longitude`, `phone`,
`alt_phone`, `location`, `notes`.

**B2.6 — Numeric `server_version`**

Change `'server_version', v_existing->>'server_version'` to:
```sql
'server_version', (v_existing->>'server_version')::bigint
```

**B2.7 — Same-farm reference check for `feed_transactions`**

In the `feed_transactions` upsert (inside the generic branch, or as a pre-check
before the generic upsert when `v_table = 'feed_transactions'`), add:
```sql
-- feed_item_id must belong to the same farm
if not exists (
  select 1 from public.feed_items
  where id = (v_payload->>'feed_item_id')::uuid and farm_id = v_farm_id
) then
  raise exception 'forbidden' using errcode = '42501';
end if;
-- batch_id (if present) must belong to the same farm
if v_payload->>'batch_id' is not null and not exists (
  select 1 from public.batches
  where id = (v_payload->>'batch_id')::uuid and farm_id = v_farm_id
) then
  raise exception 'forbidden' using errcode = '42501';
end if;
```

**B2.8 — Delete op farm-check**

In the `(v_op->>'op') = 'delete'` branch, load the stored `farm_id` first and
authorise; return `not_found` (non-retryable) when the row doesn't exist:
```sql
declare v_del_farm_id uuid;
execute format('select farm_id from public.%I where id = $1', v_table)
  into v_del_farm_id using v_row_id;
if v_del_farm_id is null then
  v_result := jsonb_build_object('op_id', v_op_id, 'status', 'rejected',
    'error_code', 'not_found', 'retryable', false);
  ...continue;
end if;
if not public.can_farm_push(v_del_farm_id) then
  raise exception 'forbidden' using errcode = '42501';
end if;
execute format('update public.%I set deleted_at = now() where id = $1
  returning to_jsonb(%I.*)', v_table, v_table) into v_existing using v_row_id;
```

**B2.9 — Remove dead second `farms` branch**

In 0017, `v_table = 'farms'` is handled twice (once in the CREATE branch
logic and once in the `elsif` chain). Remove the dead second branch.

**Header comment:** reason = "sync_push hardening: IDOR fix, allow-list
enforcement, reference-table rejection, terminal-only idempotency, duplicate
status preservation, config-driven generic upsert, task monotonicity, vet
request state-machine, safe error codes, numeric server_version, revokes."

**Verify:**
```
supabase db reset
supabase test db   # sync_push_security_test.sql should now pass
flutter test
```

---

## STEP 6 — Vet RPC hardening migration (E.3) → `0020_vet_rpc_hardening.sql`

**What:** Fix `list_available_vets` per B1.6 / Part F of the spec.

**Files to create:**
- `supabase/migrations/0020_vet_rpc_hardening.sql`

**Content:**

1. **Farm-membership check** — require caller to be a member of `p_farm_id`:
   ```sql
   if p_farm_id is not null and not public.is_farm_member(p_farm_id) then
     raise exception 'forbidden' using errcode = '42501';
   end if;
   ```

2. **Privacy-preserving output** — remove `latitude`/`longitude` from the
   returned JSONB; keep only `distance_km` and `district`:
   ```sql
   -- Remove: 'latitude', v.latitude, 'longitude', v.longitude
   ```

3. **Verified, active, opted-in filter** — add columns to `vet_profiles` if not
   present, then filter:
   ```sql
   alter table public.vet_profiles
     add column if not exists is_verified boolean not null default false,
     add column if not exists is_active boolean not null default true,
     add column if not exists opted_in boolean not null default true;

   -- In the WHERE clause of list_available_vets:
   where v.is_verified = true
     and v.is_active = true
     and v.opted_in = true
   ```

4. **Result limit** — add a `p_limit int default 50` parameter and apply:
   ```sql
   create or replace function public.list_available_vets(
     p_farm_id uuid default null,
     p_limit int default 50
   )
   ...
   v_limit := least(greatest(coalesce(p_limit, 50), 1), 100);
   ```

5. **Revokes and grants:**
   ```sql
   revoke execute on function public.list_available_vets(uuid, int) from public, anon;
   grant execute on function public.list_available_vets(uuid, int) to authenticated;
   ```

**Header comment:** reason = "list_available_vets hardening: farm-membership
check, privacy-preserving output (no raw coordinates), verified+active+opted-in
filter, result limit, revokes."

**Verify:**
```
supabase db reset
supabase test db   # list_available_vets_test.sql should now pass; all pgTAP green
flutter test
```

---

## STEP 7 — Column-name reconciliation migration

**Decision (from STEP 2):** No column renames are needed for the feed tables.
Drift `camelToSnake` produces names that match Supabase columns exactly.
The `vaccination_tasks` extra columns (`occurrence`, `enabled`, `done_by`,
`shifted_from`) were added in 0006 and match the Drift table.

**Action:** Skip — no migration 0021 required. Record in `docs/feed-module-review.md` under "Could not verify / Did not act."

---

## STEP 8 — Dart layer fixes

**What:** Fix `FeedMetrics`, mapper contracts, `SupabaseRemoteSyncApi` result
parsing, `sync_apply` feed handlers, `feed_routes` typed navigation, and
`FeedTransactionKind` sign semantics.

### 8a. Introduce `FeedMetrics` domain class

**Files to modify:**
- `lib/features/feed/domain/feed_models.dart`

**Changes:**

1. Change `FeedTransactionKind.isPositive` to a `sign` method that returns the
   multiplier for stock calculation:
   ```dart
   /// Returns +1 for stock-in kinds, -1 for stock-out kinds.
   /// For adjustment, the quantity is already signed; return +1 so
   /// callers multiply: signedDelta = kind.sign * quantity
   /// (caller must ensure adjustment.quantity is negative for a stock-out).
   int get stockSign => switch (this) {
     purchase => 1,
     consumption => -1,
     wastage => -1,
     adjustment => 1,  // quantity carries the sign
   };
   ```
   Keep `isPositive` as a deprecated alias that calls `stockSign > 0` until all
   call sites are migrated (see 8b, 8c).

2. Remove `FeedStock`. Add `FeedMetrics`:
   ```dart
   class FeedMetrics {
     const FeedMetrics({
       required this.feedItem,
       required this.currentQuantity,
       required this.recentTransactions,
       required this.totalPurchased,
       required this.totalConsumed,
       required this.totalWasted,
       required this.totalAdjustment,
       required this.totalCost,
       required this.isInconsistent,
     });

     final FeedItem feedItem;
     final double currentQuantity;   // clamped to 0 for display (see below)
     final double rawQuantity;       // may be negative if offline inconsistency
     final List<FeedTransaction> recentTransactions;
     final double totalPurchased;
     final double totalConsumed;
     final double totalWasted;
     final double totalAdjustment;   // signed sum of adjustments
     final double totalCost;         // sum(unit_cost * quantity) for purchases
     final bool isInconsistent;      // rawQuantity < 0

     bool get belowReorderLevel {
       final level = feedItem.reorderLevel;
       if (level == null) return false;
       return currentQuantity <= level;  // use clamped quantity
     }
     bool get isOutOfStock => currentQuantity <= 0;

     /// Factory: compute from a list of non-deleted transactions.
     /// Excludes soft-deleted rows (callers must filter before passing).
     factory FeedMetrics.compute(
       FeedItem item,
       List<FeedTransaction> transactions,
     ) {
       double purchased = 0, consumed = 0, wasted = 0, adj = 0, cost = 0;
       for (final tx in transactions) {
         switch (tx.kind) {
           case FeedTransactionKind.purchase:
             purchased += tx.quantity;
             cost += (tx.unitCost ?? 0) * tx.quantity;
           case FeedTransactionKind.consumption:
             consumed += tx.quantity;
           case FeedTransactionKind.wastage:
             wasted += tx.quantity;
           case FeedTransactionKind.adjustment:
             adj += tx.quantity;  // signed
         }
       }
       final raw = purchased - consumed - wasted + adj;
       return FeedMetrics(
         feedItem: item,
         rawQuantity: raw,
         currentQuantity: raw < 0 ? 0 : raw,
         recentTransactions: transactions,
         totalPurchased: purchased,
         totalConsumed: consumed,
         totalWasted: wasted,
         totalAdjustment: adj,
         totalCost: cost,
         isInconsistent: raw < 0,
       );
     }
   }
   ```

3. Keep `FeedItem`, `FeedTransaction`, `FeedItemInput`, `FeedTransactionInput`,
   `FeedTypes`, `FeedUnits`, `FeedReportData` unchanged.

4. Update `FeedTransactionInput` to allow negative `quantity` for `adjustment`:
   add `assert` note in the class doc rather than a constructor validation.

**Files to modify:**
- `lib/features/feed/data/feed_repository.dart`

**Changes:**

1. Replace `FeedStockRow` with `FeedMetrics` (keep `FeedStockRow` as a
   `typedef FeedStockRow = FeedMetrics` temporarily for zero-churn on call
   sites until this step is verified, then inline).
2. Change `_computeStockRows` to call `FeedMetrics.compute`:
   ```dart
   List<FeedMetrics> _computeStockRows(...) {
     return items.map((item) {
       final txs = byItem[item.id] ?? const [];
       // Convert rows to domain models
       final domainTxs = txs.map(_rowToTransaction).toList();
       final domainItem = _rowToItem(item);
       return FeedMetrics.compute(domainItem, domainTxs);
     }).toList();
   }
   ```
3. Update `_assertValidQuantity` to allow negative adjustment:
   ```dart
   static void _assertValidQuantity(double quantity, FeedTransactionKind kind) {
     if (kind == FeedTransactionKind.adjustment) {
       if (quantity == 0) throw ArgumentError('Adjustment quantity must be non-zero');
     } else {
       if (quantity <= 0) throw ArgumentError('Quantity must be greater than zero');
     }
   }
   ```
4. Update `watchStockLevelsCombined` return type to `Stream<List<FeedMetrics>>`.

**Files to modify:**
- `lib/features/feed/presentation/feed_providers.dart`
- `lib/features/feed/presentation/feed_screen.dart`

**Changes:** Replace `FeedStockRow` references with `FeedMetrics`; replace
`.isBelowReorderLevel` / `.isOutOfStock` calls which still exist on `FeedMetrics`.

### 8b. Sync-apply feed handlers

**Files to modify:**
- `lib/data_platform/sync/sync_apply.dart`

**Changes:**

1. Import feed synced tables:
   ```dart
   import '../../features/feed/data/feed_item_synced_table.dart';
   import '../../features/feed/data/feed_transaction_synced_table.dart';
   ```

2. Add to `_mapperFor`:
   ```dart
   'feed_items' => FeedItemSyncedTable(),
   'feed_transactions' => FeedTransactionSyncedTable(),
   ```

3. Add `applyPushAck` cases for `feed_items` and `feed_transactions`:
   ```dart
   } else if (table == 'feed_items') {
     await (_db.update(_db.feedItems)..where((b) => b.id.equals(id))).write(
       FeedItemsCompanion(serverVersion: Value(serverVersion)),
     );
   } else if (table == 'feed_transactions') {
     await (_db.update(_db.feedTransactions)..where((b) => b.id.equals(id))).write(
       FeedTransactionsCompanion(serverVersion: Value(serverVersion)),
     );
   }
   ```

4. Add pull-apply handlers for `feed_items` (mutable — full replace with
   `shouldApplyRemoteVersion`) and `feed_transactions` (append-only — insert
   only, `on conflict do nothing`):
   ```dart
   if (mapper.tableName == 'feed_items') {
     final local = await (_db.select(_db.feedItems)..where((b) => b.id.equals(id)))
         .getSingleOrNull();
     final row = incoming as FeedItemRow;
     if (local != null && !shouldApplyRemoteVersion(
       localServerVersion: local.serverVersion,
       localUpdatedAt: local.updatedAt,
       incomingServerVersion: incomingVersion,
       incomingUpdatedAt: row.updatedAt,
     )) return;
     await _db.into(_db.feedItems).insertOnConflictUpdate(...);
     return;
   }
   if (mapper.tableName == 'feed_transactions') {
     // Append-only: never overwrite an existing local row
     await _db.into(_db.feedTransactions).insert(
       ..., mode: InsertMode.insertOrIgnore);
     return;
   }
   ```

### 8c. `SupabaseRemoteSyncApi` result parsing fixes

**Files to modify:**
- `lib/data_platform/sync/supabase_remote_sync_api.dart`

**Changes:**

1. **Oversized-payload response** — already handled (`if (raw.containsKey('error'))`). Verify the `SyncRejected` error propagates to the engine correctly. If `SyncRejected` is not defined in `failure.dart`, add it:
   ```dart
   class SyncRejected extends Failure {
     const SyncRejected(String code) : super(code);
   }
   ```

2. **Duplicate flag** — after STEP 5 fix, server returns `{'status': 'applied', 'duplicate': true}` instead of `{'status': 'duplicate'}`. Update `_parsePushResponse` to recognise `duplicate: true`:
   ```dart
   SyncPushOpResult(
     opId: r['op_id'] as String,
     status: r['status'] as String,   // 'applied' or 'rejected'
     isDuplicate: r['duplicate'] as bool? ?? false,
     serverVersion: syncJsonInt(r['server_version']),
     ...
   )
   ```
   Add `isDuplicate` field to `SyncPushOpResult` in `remote_sync_api.dart`.
   Update engine's `_pushLoop` to treat `status == 'applied' || isDuplicate` as acknowledged.

3. **Numeric `server_version`** — `syncJsonInt` already handles both int and string, so no change needed, but confirm no cast exceptions with a unit test.

### 8d. `feed_routes.dart` typed navigation fix

**Files to modify:**
- `lib/features/feed/presentation/feed_routes.dart`

**What:** Replace raw `Navigator.push` / `MaterialPageRoute` with a typed `GoRouteData` subclass following the pattern in other features.

**Changes:**
```dart
// Before (wrong):
class FeedItemDetailRoute {
  Future<T?> push<T>(BuildContext context) {
    return Navigator.of(rootNavigatorKey.currentContext ?? context, rootNavigator: true)
        .push<T>(MaterialPageRoute<T>(builder: (_) => FeedItemDetailScreen(...)));
  }
}

// After (correct):
@TypedGoRoute<FeedItemDetailRoute>(path: '/feed/:feedItemId')
class FeedItemDetailRoute extends GoRouteData {
  const FeedItemDetailRoute({required this.feedItemId});
  final String feedItemId;

  static final $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      FeedItemDetailScreen(feedItemId: feedItemId);
}
```

Add the route to the router configuration file where other feature routes are registered (find the router file first and follow the existing pattern).

Add a sample in `test/layout/route_samples.dart` for the `/feed/:feedItemId` path (navigation rule).

**Files to modify:**
- `lib/features/feed/presentation/feed_routes.dart`
- `lib/app/router/app_router.dart` (or wherever routes are registered)
- `test/layout/route_samples.dart`

**Verify:**
```
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

## STEP 9 — Screen alignment audit (no redesign)

**What:** Audit each feed screen for small in-scope gaps per Part C.5 of the
spec. Fix only confirmed small gaps; list larger ones in review doc.

**Files to review:**
- `lib/features/feed/presentation/feed_screen.dart`
- `lib/features/feed/presentation/feed_item_form_sheet.dart`
- `lib/features/feed/presentation/feed_item_detail_screen.dart`
- `lib/features/feed/presentation/record_feed_transaction_sheet.dart`
- `lib/features/feed/presentation/feed_report_screen.dart`

**Checklist per screen:**

| Check | What to look for | Status |
|-------|------------------|--------|
| AsyncStateView | `AsyncValue` consumed via `AsyncStateView`, not `.when` in screen | Review each screen |
| Enum values | `kind` strings match `FeedTransactionKind.storage` (i.e. `consumption`, not `usage`) | Fix any `'usage'` string literals |
| Validation | Positive quantity enforced for purchase/consumption/wastage; non-zero for adjustment; date not in future | Fix gaps |
| Drafts | Form sheets use `DiscardChangesScope` / `PopScope` if dirty | Fix if missing |
| Tokens only | No `Color(0x…)`, `Colors.*` outside theme | Fix if present |
| Localised strings | Strings not yet localised are acceptable but should not hard-code a different locale | Flag if wrong |
| Layout | Uses `AppPage` + `PageLayout` preset (not raw `Scaffold`) | Fix violations |
| PendingSyncBadge | Shown on save until outbox clears | Note if missing (follow-up unless trivial) |
| `_RecordFab` uses `context.colors.warning` | Correct colour token | Fix if using raw colour |

**Known issue from exploration:**
- `feed_screen.dart` Report tab uses `CircularProgressIndicator` directly instead
  of `AsyncStateView`. This is acceptable (it's a `ConsumerStatefulWidget` using a
  sealed state machine), but the retry path does not use the standard error
  components. Fix: wrap `_ReportError` case with the standard `ErrorState` widget
  if it exists, otherwise leave as a noted follow-up.

**Decisions on larger issues** (list in review doc, do not fix here):
- Low-stock notifications via `ReminderSource` not yet wired — follow-up.
- Report tab's `_load` does not use `AsyncStateView` — acceptable in-scope gap,
  fix in this step if easy (swap `_ReportLoading` for `ScreenSkeleton`,
  `_ReportError` for standard error widget).

**Verify:**
```
flutter analyze
flutter test   # widget tests added in STEP 10 gate this
```

---

## STEP 10 — Dart tests

**What:** Write all Dart tests from Part F of the spec.

### 10a. `FeedMetrics` unit tests

**File to create:** `test/features/feed/feed_metrics_test.dart`

**Table-driven test cases:**
- All four kinds contribute correctly to stock
- Soft-deleted rows excluded from `compute` (callers must filter; test the
  contract by NOT passing deleted rows)
- `belowReorderLevel` when `currentQuantity <= reorderLevel`
- `isInconsistent` when `rawQuantity < 0`; `currentQuantity` is clamped to 0
- Zero-cost entries (no `unitCost`) don't inflate `totalCost`
- Signed adjustment: negative adjustment reduces stock; positive increases it
- Empty transaction list → all zeros, `isInconsistent = false`

### 10b. Mapper contract tests

**File to create:** `test/features/feed/feed_mapper_test.dart`

**Tests:**
- `FeedItemSyncedTable().toPayload(row)` keys are a subset of
  `sync_table_config.writable_columns` for `feed_items` (derive from a
  hardcoded constant matching the migration, with a comment that it must be
  updated when the migration changes)
- `FeedTransactionSyncedTable().toPayload(row)` keys match `feed_transactions`
  writable columns
- `FeedItemSyncedTable().fromRemote(json)` round-trips the canonical fields
- `FeedTransactionSyncedTable().fromRemote(json)` handles `null` optional fields

### 10c. `SupabaseRemoteSyncApi` parsing tests

**File to create:** `test/data_platform/sync/supabase_remote_sync_api_test.dart`

**Tests (pure unit — no network calls; use `MockSupabaseClient` or just call
`_parsePushResponse` directly by making it package-visible with `@visibleForTesting`):**
- `applied` result parsed correctly, `serverVersion` is an `int`
- `rejected` result with `retryable: true`
- `rejected` result with `retryable: false`
- `duplicate: true` + `status: 'applied'` → `isDuplicate = true`
- `error: 'payload_too_large'` → throws `SyncRejected`
- `server_version` as a JSON string parses to `int` via `syncJsonInt`

### 10d. Repository and engine tests

**File to create:** `test/features/feed/feed_repository_test.dart`

**Tests (use `AppDatabase` in-memory via `NativeDatabase.memory()`):**
- `addFeedItem` then `watchStockLevelsCombined` returns empty stock
- `recordTransaction(purchase)` → stock increases
- `recordTransaction(consumption)` → stock decreases
- `recordTransaction(adjustment, negative)` → stock decreases (non-zero)
- `deleteFeedItem` → item absent from `watchFeedItems`; transactions retained
- `addFeedItem` then `recordTransaction` ordering: item pushed to outbox before
  transaction (verify via `outboxDao.claimBatch` order)
- Undo of soft-deleted transaction: mark `deletedAt`, then re-derive stock —
  should match stock without the deleted tx

### 10e. Feed screen widget tests

**File to create:** `test/features/feed/feed_screen_test.dart`

**Tests:**
- Loading state: `AsyncStateView` shows skeleton (mock `feedStockProvider` with
  `AsyncValue.loading()`)
- Empty state: shows `EmptyState` widget when stock list is empty
- Error state: shows retry button when provider is in error
- Stock tab: `_LowStockBanner` appears when at least one item is below reorder
  level
- Transactions tab: correct `+`/`−` prefix and colour based on kind
- Validation in `RecordFeedTransactionSheet`: quantity 0 is rejected; negative
  quantity for non-adjustment is rejected

### 10f. Architecture tests

**File to create:** `test/architecture/feed_rules_test.dart`

**Tests (using `dart:io` + file scanning, following the pattern in
`test/architecture/batch_metrics_rule_test.dart`):**
- No file under `lib/features/feed/` references `'usage'` as a kind string
  (except the mapper's `fromStorage` fallback which maps unknown → consumption)
- No file under `lib/features/feed/` calls `FeedTransactionKind.isPositive`
  directly (deprecated; must use `stockSign`)
- Feed stock is computed only in `FeedMetrics.compute` — no other file under
  `lib/` does arithmetic with `FeedTransactionKind` outside `feed_models.dart`
  and `feed_repository.dart`

**Verify:**
```
flutter test test/features/feed/
flutter test test/architecture/feed_rules_test.dart
```

---

## STEP 11 — Docs and ADRs

**What:** Finalise the review document; write the 7 ADRs; update architecture
sync documentation.

### 11a. Finalise `docs/feed-module-review.md`

**Files to modify:**
- `docs/feed-module-review.md`

**Sections to complete:**
1. Findings table with `status: FIXED` or `status: NOTED` for every finding
   from STEP 1.
2. Failing-test triage table (from STEP 1 runs).
3. Contract mismatch table and decisions (from STEP 2).
4. What could not be verified (Docker/Supabase CLI availability).
5. Open questions for the project owner:
   - Should `pending_sync` rows that exist in production be migrated? (Migration
     0019 normalises to `submitted` on write; existing server rows remain until
     a clean-up script runs.)
   - Should `adjustment` quantities in existing data be audited for sign?
   - Low-stock notification via `ReminderSource` — desired timeline?
   - `is_verified`, `is_active`, `opted_in` on `vet_profiles` — who sets these
     fields in production?

### 11b. Write ADRs

**Files to create (under `docs/adr/`):**
- `docs/adr/001_sync_push_writable_columns_and_farm_auth.md`
- `docs/adr/002_terminal_only_idempotency_records.md`
- `docs/adr/003_canonical_feed_transaction_kinds.md`
- `docs/adr/004_feed_stock_derived_in_feed_metrics.md`
- `docs/adr/005_server_controlled_vet_request_transitions.md`
- `docs/adr/006_vet_discovery_privacy_preserving.md`
- `docs/adr/007_migration_hygiene.md`

**Template per ADR:**
```markdown
# ADR-NNN: <title>

Status: Accepted
Date: <today>

## Context
<one paragraph>

## Decision
<one paragraph>

## Consequences
- <positive>
- <negative/tradeoff>
```

**ADR content summary:**

**ADR-001** — `sync_push` enforces `writable_columns` allow-list and authorises
against the stored `farm_id` (not the payload). Cross-farm IDOR is prevented by
loading the existing row's `farm_id` before authorisation.

**ADR-002** — Only terminal outcomes (applied, non-retryable rejected) are stored
in `sync_ops_applied`. Retryable failures are not recorded, allowing the client
to retry until the prerequisite row exists.

**ADR-003** — Canonical feed transaction kind is `consumption` (not `usage`).
`adjustment` quantities are signed (positive = stock in, negative = stock out,
non-zero). Data migration in 0018 renames existing `usage` rows.

**ADR-004** — Feed stock is derived exclusively in `FeedMetrics.compute`.
No consumer stores a stock quantity. Negative derived stock (from concurrent
offline inserts) is clamped to 0 for display and surfaced via `isInconsistent`.

**ADR-005** — `vet_assistance_requests.status` is server-controlled for vet
states (accepted, in_progress, completed, declined). Farmers may only push
`draft`, `submitted`, `cancelled` (before vet accepts). `pending_sync` is a
client-side state and is never persisted server-side.

**ADR-006** — `list_available_vets` returns only `distance_km` and `district`
(no raw coordinates). It requires farm membership and filters to verified,
active, opted-in vets with a configurable limit.

**ADR-007** — One concern per migration file. Applied migrations are never
edited. Corrective migrations must be additive or data-preserving. Rollback
notes are included in each migration's header comment.

### 11c. Update architecture sync documentation

**Files to modify:**
- `docs/feed-module-review.md` — sync section (inline since `docs/architecture.md`
  does not exist yet; create it if desired, or append a "Sync Protocol" section
  to the review doc)

Alternatively, create `docs/architecture.md` with a minimal sync section
covering: per-scope counters, `sync_push` contract (allow-list, idempotency,
stored-farm auth, terminal-only records), `sync_pull` streaming model,
`SyncApply` conflict resolution, and links to ADRs.

**Verify:**
```
flutter analyze     # must be clean
flutter test        # all tests green
supabase db reset   # must succeed from scratch
supabase test db    # all pgTAP tests green
```

---

## Acceptance criteria gates

Each step is gated by the verify commands listed in that step. Final acceptance
requires all four commands to exit 0:

```
flutter analyze
flutter test
supabase db reset
supabase test db
```

No test was skipped, deleted, or weakened without a written justification in
`docs/feed-module-review.md`.
