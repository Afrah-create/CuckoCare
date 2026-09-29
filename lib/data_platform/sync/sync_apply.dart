import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'remote_sync_api.dart';
import 'synced_table.dart';
import '../../features/batches/data/batch_synced_table.dart';
import '../../features/vaccination/data/vaccination_task_synced_table.dart';

int taskStatusRank(String status) => switch (status) {
      'pending' => 0,
      'assumed_done' => 1,
      'skipped' => 2,
      'done' => 3,
      _ => -1,
    };

class SyncApply {
  SyncApply(this._db);

  final AppDatabase _db;
  final _batches = BatchSyncedTable();
  final _tasks = VaccinationTaskSyncedTable();

  Future<void> applyPullPage(List<SyncPullRow> rows) async {
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    try {
      for (final remote in rows) {
        await _applyOne(remote);
      }
    } finally {
      await _db.customStatement('PRAGMA defer_foreign_keys = OFF');
    }
  }

  Future<void> _applyOne(SyncPullRow remote) async {
    final table = remote.table;
    final mapper = _mapperFor(table);
    if (mapper == null) {
      return;
    }

    final localPending = await (_db.select(_db.outbox)
          ..where(
            (o) =>
                o.targetTable.equals(table) &
                o.rowId.equals(remote.row['id'] as String) &
                (o.state.equals('pending') | o.state.equals('in_flight')),
          ))
        .getSingleOrNull();
    if (localPending != null) {
      return;
    }

    await _applyRow(mapper, remote);
  }

  SyncedTable<dynamic>? _mapperFor(String table) => switch (table) {
        'batches' => _batches,
        'vaccination_tasks' => _tasks,
        _ => null,
      };

  Future<void> _applyRow(SyncedTable<dynamic> mapper, SyncPullRow remote) async {
    final incoming = mapper.fromRemote(remote.row);
    final id = remote.row['id'] as String;
    final incomingVersion = remote.serverVersion;

    if (mapper.tableName == 'batches') {
      final local = await (_db.select(_db.batches)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      if (local != null &&
          (local.serverVersion ?? 0) >= incomingVersion &&
          local.deletedAt == null) {
        return;
      }
      final row = incoming as dynamic;
      await _db.into(_db.batches).insertOnConflictUpdate(
            BatchesCompanion(
              id: Value(row.id as String),
              farmId: Value(row.farmId as String),
              createdAt: Value(row.createdAt as DateTime),
              updatedAt: Value(row.updatedAt as DateTime),
              deletedAt: Value(row.deletedAt as DateTime?),
              serverVersion: Value(incomingVersion),
              name: Value(row.name as String),
              birdType: Value(row.birdType as String),
              initialCount: Value(row.initialCount as int),
              acquiredOn: Value(row.acquiredOn as DateTime),
              ageAtAcquisitionDays: Value(row.ageAtAcquisitionDays as int),
              hatcheryVaccinated: Value(row.hatcheryVaccinated as bool?),
              source: Value(row.source as String?),
              status: Value(row.status as String),
              programmeId: Value(row.programmeId as String),
              programmeVersion: Value(row.programmeVersion as int),
              notes: Value(row.notes as String?),
            ),
          );
      return;
    }

    if (mapper.tableName == 'vaccination_tasks') {
      final local = await (_db.select(_db.vaccinationTasks)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      if (local != null && (local.serverVersion ?? 0) >= incomingVersion) {
        return;
      }
      final row = incoming as dynamic;
      final mergedStatus = local == null
          ? row.status as String
          : taskStatusRank(row.status as String) >=
                  taskStatusRank(local.status)
              ? row.status as String
              : local.status;

      await _db.into(_db.vaccinationTasks).insertOnConflictUpdate(
            VaccinationTasksCompanion(
              id: Value(row.id as String),
              farmId: Value(row.farmId as String),
              createdAt: Value(row.createdAt as DateTime),
              updatedAt: Value(row.updatedAt as DateTime),
              deletedAt: Value(row.deletedAt as DateTime?),
              serverVersion: Value(incomingVersion),
              batchId: Value(row.batchId as String),
              stepId: Value(row.stepId as String),
              dueOn: Value(row.dueOn as DateTime),
              status: Value(mergedStatus),
              doneOn: Value(row.doneOn as DateTime?),
              productUsed: Value(row.productUsed as String?),
              notes: Value(row.notes as String?),
            ),
          );
    }
  }

  Future<void> applyPushAck({
    required String table,
    required Map<String, dynamic> row,
    required int serverVersion,
  }) async {
    final id = row['id'] as String;
    if (table == 'batches') {
      await (_db.update(_db.batches)..where((b) => b.id.equals(id))).write(
        BatchesCompanion(serverVersion: Value(serverVersion)),
      );
    } else if (table == 'vaccination_tasks') {
      await (_db.update(_db.vaccinationTasks)..where((b) => b.id.equals(id)))
          .write(
        VaccinationTasksCompanion(serverVersion: Value(serverVersion)),
      );
    }
  }
}
