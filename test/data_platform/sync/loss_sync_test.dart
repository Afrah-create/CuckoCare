import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/data_platform/sync/remote_sync_api.dart';
import 'package:cucocare/data_platform/sync/sync_apply.dart';
import 'package:cucocare/features/batches/data/loss_synced_table.dart';
import 'package:cucocare/features/batches/data/schedule_dates.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> remoteLoss({
  required int version,
  required String updatedAt,
  int count = 3,
  String? deletedAt,
}) => {
  'id': 'loss-1',
  'farm_id': 'farm-1',
  'batch_id': 'batch-1',
  'count': count,
  'kind': 'culled',
  'suspected_cause': 'injury',
  'occurred_on': '2026-03-05',
  'notes': null,
  'edited_at': null,
  'deleted_at': deletedAt,
  'deleted_group_id': null,
  'created_at': '2026-03-05T08:00:00Z',
  'updated_at': updatedAt,
  'server_version': version,
};

void main() {
  late AppDatabase db;
  late SyncApply apply;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    apply = SyncApply(db);
  });

  tearDown(() => db.close());

  Future<MortalityRecordRow?> local() => (db.select(
    db.mortalityRecords,
  )..where((l) => l.id.equals('loss-1'))).getSingleOrNull();

  Future<void> pull(Map<String, dynamic> row) => apply.applyPullPage([
    SyncPullRow(
      table: 'mortality_records',
      serverVersion: row['server_version'] as int,
      row: row,
    ),
  ]);

  test('pulled losses keep their calendar day', () async {
    await pull(remoteLoss(version: 1, updatedAt: '2026-03-05T08:00:00Z'));
    final row = await local();
    expect(row, isNotNull);
    expect(
      dueOnFromStorage(row!.occurredOn),
      const CalendarDate(year: 2026, month: 3, day: 5),
    );
    expect(row.kind, 'culled');
    expect(row.suspectedCause, 'injury');
  });

  test('a newer edit replaces the row; an older one is ignored', () async {
    await pull(remoteLoss(version: 2, updatedAt: '2026-03-05T09:00:00Z'));
    await pull(
      remoteLoss(version: 3, updatedAt: '2026-03-05T10:00:00Z', count: 5),
    );
    expect((await local())!.count, 5);

    await pull(
      remoteLoss(version: 1, updatedAt: '2026-03-05T07:00:00Z', count: 1),
    );
    expect((await local())!.count, 5);
  });

  test('a tombstone soft-deletes the local row', () async {
    await pull(remoteLoss(version: 1, updatedAt: '2026-03-05T08:00:00Z'));
    await pull(
      remoteLoss(
        version: 2,
        updatedAt: '2026-03-06T08:00:00Z',
        deletedAt: '2026-03-06T08:00:00Z',
      ),
    );
    expect((await local())!.deletedAt, isNotNull);
  });

  test('payload sends a plain date and every column the server needs', () {
    final row = MortalityRecordRow(
      id: 'loss-1',
      farmId: 'farm-1',
      createdAt: DateTime.utc(2026, 3, 5, 8),
      updatedAt: DateTime.utc(2026, 3, 5, 8),
      batchId: 'batch-1',
      count: 2,
      kind: 'died',
      occurredOn: dueOnToStorage(
        const CalendarDate(year: 2026, month: 3, day: 5),
      ),
    );
    final payload = LossSyncedTable().toPayload(row);
    expect(payload['occurred_on'], '2026-03-05');
    expect(
      payload.keys,
      containsAll(['id', 'farm_id', 'batch_id', 'count', 'kind', 'created_at']),
    );
  });
}
