import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/uuid_v7.dart';
import 'app_database.dart';
/// Performs a local row mutation and outbox enqueue in one Drift transaction.
class SyncedWrite {
  SyncedWrite(this._db);

  final AppDatabase _db;

  Future<void> writeSynced({
    required Future<void> Function() writeRow,
    required String table,
    required String rowId,
    required String op,
    required Map<String, dynamic> payload,
  }) async {
    await _db.transaction(() async {
      await writeRow();
      await _coalescePending(table: table, rowId: rowId);
      await _db.into(_db.outbox).insert(
            OutboxCompanion.insert(
              opId: newId(),
              targetTable: table,
              rowId: rowId,
              op: op,
              payload: jsonEncode(payload),
              createdAt: DateTime.now().toUtc(),
              state: const Value('pending'),
            ),
          );
    });
  }

  Future<void> _coalescePending({
    required String table,
    required String rowId,
  }) async {
    final pending = await (_db.select(_db.outbox)
          ..where(
            (o) =>
                o.targetTable.equals(table) &
                o.rowId.equals(rowId) &
                o.state.equals('pending'),
          ))
        .get();
    for (final row in pending) {
      await (_db.delete(_db.outbox)..where((o) => o.opId.equals(row.opId))).go();
    }
  }
}
