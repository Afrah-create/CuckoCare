import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/uuid_v7.dart';
import '../sync/sync_json.dart';
import 'app_database.dart';
class SyncedWriteOp {
  SyncedWriteOp({
    required this.writeRow,
    required this.table,
    required this.rowId,
    required this.op,
    required this.payload,
  });

  final Future<void> Function() writeRow;
  final String table;
  final String rowId;
  final String op;
  final Map<String, dynamic> payload;
}

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
    await writeSyncedMany([
      SyncedWriteOp(
        writeRow: writeRow,
        table: table,
        rowId: rowId,
        op: op,
        payload: payload,
      ),
    ]);
  }

  /// Atomic local writes + outbox rows (batch first, then related rows).
  Future<void> writeSyncedMany(List<SyncedWriteOp> ops) async {
    if (ops.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      for (final op in ops) {
        await op.writeRow();
        await _coalescePending(table: op.table, rowId: op.rowId);
        await _db.into(_db.outbox).insert(
              OutboxCompanion.insert(
                opId: newId(),
                targetTable: op.table,
                rowId: op.rowId,
                op: op.op,
                payload: jsonEncode(sanitizeSyncPayload(op.payload)),
                createdAt: DateTime.now().toUtc(),
                state: const Value('pending'),
              ),
            );
      }
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
