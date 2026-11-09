import '../db/app_database.dart';

/// Ensures parent rows (e.g. health_records) push before dependents (vet requests).
int syncPushTablePriority(String table) {
  return switch (table) {
    'farms' => 10,
    'batches' => 20,
    'feed_items' => 25,
    'health_records' => 30,
    'mortality_records' => 31,
    'farm_events' => 32,
    'feed_transactions' => 33,
    'vaccination_tasks' => 35,
    'vet_assistance_requests' => 40,
    'vet_consultations' => 41,
    'case_messages' => 42,
    'case_message_attachments' => 43,
    'case_read_state' => 44,
    _ => 50,
  };
}

void sortOutboxRowsForPush(List<OutboxRow> rows) {
  rows.sort((a, b) {
    final byTable = syncPushTablePriority(a.targetTable)
        .compareTo(syncPushTablePriority(b.targetTable));
    if (byTable != 0) {
      return byTable;
    }
    return a.createdAt.compareTo(b.createdAt);
  });
}
