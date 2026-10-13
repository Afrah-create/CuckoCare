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
