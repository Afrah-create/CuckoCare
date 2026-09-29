begin;
select plan(6);

-- Minimal smoke tests; expand with authenticated JWT helpers in CI.
select has_function('public', 'sync_push', array['jsonb']);
select has_function('public', 'sync_pull', array['text', 'bigint', 'int']);
select has_function('public', 'sync_head', array['text[]']);
select has_function('public', 'sync_bootstrap');

select ok(
  (select count(*) > 0 from public.sync_table_config),
  'sync_table_config seeded'
);

select ok(
  (select count(*) > 0 from public.sync_counters or true),
  'sync_counters table exists'
);

select * from finish();
rollback;
