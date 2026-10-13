-- pgTAP tests for feed schema correctness.
-- These tests are RED before migration 0018 and GREEN after it.
--
-- Run: supabase test db
--
-- Test plan (11 tests):
--   1-2:  kind constraint: 'consumption' accepted, 'usage' rejected
--   3-5:  quantity constraints by kind
--   6:    unit_cost must be >= 0
--   7-8:  indexes exist
--   9-10: sync_table_config for feed_items: kind=mutable, deleted_at in writable_columns
--   11:   no 'usage' rows remain after data migration

begin;
select plan(11);

-- ── 1. 'consumption' kind is accepted ─────────────────────────────────────────
-- Insert a minimal farm + feed_item so foreign-key is satisfied.
-- We use a fixed UUID to keep the test self-contained.
do $$
begin
  -- Ensure pgtap helper rows exist; skip farm-member/auth machinery.
  insert into public.farms (id, farm_id, name, created_at, updated_at)
  values (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Test Farm A',
    now(), now()
  ) on conflict do nothing;

  insert into public.feed_items (id, farm_id, name, feed_type, unit, created_at, updated_at)
  values (
    '20000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Starter Feed', 'starter', 'kg', now(), now()
  ) on conflict do nothing;
end;
$$;

select ok(
  (
    with ins as (
      insert into public.feed_transactions (
        id, farm_id, feed_item_id, kind, quantity, occurred_on, created_at, updated_at
      ) values (
        '30000000-0000-0000-0000-000000000001',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'consumption', 10, current_date, now(), now()
      ) on conflict do nothing returning id
    )
    select count(*) = 1 from ins
  ),
  'kind=consumption is accepted'
);

-- ── 2. 'usage' kind is rejected ───────────────────────────────────────────────
select throws_ok(
  $$
    insert into public.feed_transactions (
      id, farm_id, feed_item_id, kind, quantity, occurred_on, created_at, updated_at
    ) values (
      '30000000-0000-0000-0000-000000000099',
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      'usage', 5, current_date, now(), now()
    )
  $$,
  '23514',
  null,
  'kind=usage is rejected by check constraint'
);

-- ── 3. purchase quantity must be > 0 ─────────────────────────────────────────
select throws_ok(
  $$
    insert into public.feed_transactions (
      id, farm_id, feed_item_id, kind, quantity, occurred_on, created_at, updated_at
    ) values (
      '30000000-0000-0000-0000-000000000002',
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      'purchase', 0, current_date, now(), now()
    )
  $$,
  '23514',
  null,
  'purchase quantity = 0 is rejected'
);

-- ── 4. adjustment quantity = 0 is rejected ────────────────────────────────────
select throws_ok(
  $$
    insert into public.feed_transactions (
      id, farm_id, feed_item_id, kind, quantity, occurred_on, created_at, updated_at
    ) values (
      '30000000-0000-0000-0000-000000000003',
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      'adjustment', 0, current_date, now(), now()
    )
  $$,
  '23514',
  null,
  'adjustment quantity = 0 is rejected'
);

-- ── 5. negative adjustment is accepted ────────────────────────────────────────
select ok(
  (
    with ins as (
      insert into public.feed_transactions (
        id, farm_id, feed_item_id, kind, quantity, occurred_on, created_at, updated_at
      ) values (
        '30000000-0000-0000-0000-000000000004',
        '10000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        'adjustment', -5, current_date, now(), now()
      ) on conflict do nothing returning id
    )
    select count(*) = 1 from ins
  ),
  'adjustment with negative quantity is accepted'
);

-- ── 6. negative unit_cost is rejected ─────────────────────────────────────────
select throws_ok(
  $$
    insert into public.feed_transactions (
      id, farm_id, feed_item_id, kind, quantity, unit_cost, occurred_on, created_at, updated_at
    ) values (
      '30000000-0000-0000-0000-000000000005',
      '10000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000001',
      'purchase', 10, -1, current_date, now(), now()
    )
  $$,
  '23514',
  null,
  'negative unit_cost is rejected'
);

-- ── 7. index feed_items_farm_deleted_idx exists ───────────────────────────────
select has_index(
  'public',
  'feed_items',
  'feed_items_farm_deleted_idx',
  'index feed_items_farm_deleted_idx exists'
);

-- ── 8. index feed_transactions_item_occurred_idx exists ──────────────────────
select has_index(
  'public',
  'feed_transactions',
  'feed_transactions_item_occurred_idx',
  'index feed_transactions_item_occurred_idx exists'
);

-- ── 9. sync_table_config feed_items kind = mutable ───────────────────────────
select is(
  (select kind from public.sync_table_config where table_name = 'feed_items'),
  'mutable',
  'sync_table_config feed_items kind is mutable'
);

-- ── 10. sync_table_config feed_items writable_columns includes deleted_at ────
select ok(
  (
    select 'deleted_at' = any(writable_columns)
    from public.sync_table_config
    where table_name = 'feed_items'
  ),
  'sync_table_config feed_items writable_columns includes deleted_at'
);

-- ── 11. no 'usage' rows remain ────────────────────────────────────────────────
select is(
  (select count(*)::int from public.feed_transactions where kind = 'usage'),
  0,
  'no feed_transactions rows with kind=usage remain after migration'
);

select * from finish();
rollback;
