import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import 'batch_views.dart';
import 'loss_synced_table.dart';
import 'schedule_dates.dart';

class LossDraft {
  const LossDraft({
    required this.count,
    required this.kind,
    required this.occurredOn,
    this.suspectedCause,
    this.notes,
  });

  final int count;
  final LossKind kind;
  final CalendarDate occurredOn;
  final SuspectedCause? suspectedCause;
  final String? notes;
}

/// Loss records in Drift. Every write also queues an outbox row.
class LossRepository {
  LossRepository(this._db, this._clock, {SyncedWrite? syncedWrite})
    : _syncedWrite = syncedWrite ?? SyncedWrite(_db);

  final AppDatabase _db;
  final Clock _clock;
  final SyncedWrite _syncedWrite;
  final _mapper = LossSyncedTable();

  Stream<List<MortalityRecordRow>> watchLosses(String batchId) {
    return (_db.select(_db.mortalityRecords)
          ..where((l) => l.batchId.equals(batchId) & l.deletedAt.isNull())
          ..orderBy([
            (l) => OrderingTerm.desc(l.occurredOn),
            (l) => OrderingTerm.desc(l.createdAt),
          ]))
        .watch();
  }

  Future<List<MortalityRecordRow>> lossesForBatch(String batchId) {
    return (_db.select(
      _db.mortalityRecords,
    )..where((l) => l.batchId.equals(batchId) & l.deletedAt.isNull())).get();
  }

  /// All live losses on the farm (batch not deleted), newest first.
  Stream<List<FarmLossRow>> watchFarmLosses(String farmId, {String? batchId}) {
    final query =
        _db.select(_db.mortalityRecords).join([
            innerJoin(
              _db.batches,
              _db.batches.id.equalsExp(_db.mortalityRecords.batchId),
            ),
          ])
          ..where(
            _db.mortalityRecords.farmId.equals(farmId) &
                _db.mortalityRecords.deletedAt.isNull() &
                _db.batches.deletedAt.isNull() &
                (batchId == null
                    ? const Constant(true)
                    : _db.mortalityRecords.batchId.equals(batchId)),
          )
          ..orderBy([
            OrderingTerm.desc(_db.mortalityRecords.occurredOn),
            OrderingTerm.desc(_db.mortalityRecords.createdAt),
          ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          FarmLossRow(
            loss: row.readTable(_db.mortalityRecords),
            batchName: row.readTable(_db.batches).name,
          ),
      ],
    );
  }

  Future<MortalityRecordRow?> findLoss(String lossId) {
    return (_db.select(
      _db.mortalityRecords,
    )..where((l) => l.id.equals(lossId))).getSingleOrNull();
  }

  Stream<MortalityRecordRow?> watchLoss(String lossId) {
    return (_db.select(_db.mortalityRecords)
          ..where((l) => l.id.equals(lossId) & l.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Future<MortalityRecordRow> insertLoss({
    required String farmId,
    required String batchId,
    required LossDraft draft,
  }) async {
    final now = _clock.now();
    final row = MortalityRecordRow(
      id: newId(),
      farmId: farmId,
      createdAt: now,
      updatedAt: now,
      batchId: batchId,
      count: draft.count,
      kind: draft.kind.storage,
      suspectedCause: draft.suspectedCause?.storage,
      occurredOn: dueOnToStorage(draft.occurredOn),
      notes: _clean(draft.notes),
    );
    await _write(row, insert: true);
    return row;
  }

  Future<MortalityRecordRow> updateLoss(
    MortalityRecordRow existing,
    LossDraft draft,
  ) async {
    final now = _clock.now();
    final row = existing.copyWith(
      updatedAt: now,
      editedAt: Value(now),
      count: draft.count,
      kind: draft.kind.storage,
      suspectedCause: Value(draft.suspectedCause?.storage),
      occurredOn: dueOnToStorage(draft.occurredOn),
      notes: Value(_clean(draft.notes)),
    );
    await _write(row);
    return row;
  }

  Future<void> setDeleted(
    MortalityRecordRow existing, {
    required bool deleted,
  }) {
    final now = _clock.now();
    final row = existing.copyWith(
      updatedAt: now,
      deletedAt: Value(deleted ? now : null),
      deletedGroupId: const Value(null),
    );
    return _write(row);
  }

  Future<void> _write(MortalityRecordRow row, {bool insert = false}) {
    return _syncedWrite.writeSynced(
      writeRow: () => insert
          ? _db.into(_db.mortalityRecords).insert(row)
          : _db
                .into(_db.mortalityRecords)
                .insertOnConflictUpdate(row.toCompanion(false)),
      table: _mapper.tableName,
      rowId: row.id,
      op: 'upsert',
      payload: _mapper.toPayload(row),
    );
  }

  static String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
