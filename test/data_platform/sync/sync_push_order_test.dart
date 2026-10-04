import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/sync/sync_push_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health_records push before vet_assistance_requests', () {
    final rows = [
      OutboxRow(
        opId: '2',
        targetTable: 'vet_assistance_requests',
        rowId: 'r2',
        op: 'upsert',
        payload: '{}',
        createdAt: DateTime.utc(2026, 1, 1, 0, 0, 1),
        attempts: 0,
        state: 'pending',
        retryable: true,
      ),
      OutboxRow(
        opId: '1',
        targetTable: 'health_records',
        rowId: 'r1',
        op: 'upsert',
        payload: '{}',
        createdAt: DateTime.utc(2026, 1, 1, 0, 0, 2),
        attempts: 0,
        state: 'pending',
        retryable: true,
      ),
    ];
    sortOutboxRowsForPush(rows);
    expect(rows.first.targetTable, 'health_records');
    expect(rows.last.targetTable, 'vet_assistance_requests');
  });
}
