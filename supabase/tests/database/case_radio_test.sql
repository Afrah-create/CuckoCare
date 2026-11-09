begin;
select plan(18);

select has_table('public', 'case_messages');
select has_table('public', 'case_message_attachments');
select has_table('public', 'case_read_state');
select has_table('public', 'device_push_tokens');
select has_table('public', 'push_log');

select has_function('public', 'send_case_message');
select has_function('public', 'add_case_attachment');
select has_function('public', 'mark_case_read');
select has_function('public', 'set_case_muted');
select has_function('public', 'pull_assigned_case_messages');
select has_function('public', 'register_push_token');
select has_function('public', 'unregister_push_token');
select has_function('public', 'enqueue_urgent_case_sms');

select ok(
  exists(
    select 1 from public.sync_table_config
    where table_name = 'case_messages'
      and kind = 'append_only'
  ),
  'case_messages is append-only in sync_table_config'
);

select ok(
  exists(
    select 1 from public.sync_table_config
    where table_name = 'case_message_attachments'
  ),
  'attachments registered in sync_table_config'
);

select ok(
  exists(
    select 1 from public.sync_table_config
    where table_name = 'case_read_state'
  ),
  'read state registered in sync_table_config'
);

select ok(
  not has_table_privilege('anon', 'public.case_messages', 'INSERT'),
  'anon cannot insert case_messages'
);

select ok(
  not has_table_privilege('anon', 'public.sms_outbox', 'SELECT'),
  'anon cannot read sms_outbox'
);

select * from finish();
rollback;
