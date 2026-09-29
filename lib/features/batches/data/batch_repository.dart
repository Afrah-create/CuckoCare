import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import 'batch_synced_table.dart';

class BatchRepository {
  BatchRepository(this._db, this._clock, {SyncedWrite? syncedWrite})
      : _syncedWrite = syncedWrite ?? SyncedWrite(_db),
        _mapper = BatchSyncedTable();

  final AppDatabase _db;
  final Clock _clock;
  final SyncedWrite _syncedWrite;
  final BatchSyncedTable _mapper;

  Future<BatchRow> createBatch({
    required String farmId,
    required String name,
    required String birdType,
    required int initialCount,
    required DateTime acquiredOn,
    required String programmeId,
    required int programmeVersion,
    int ageAtAcquisitionDays = 0,
  }) async {
    final now = _clock.now();
    final id = newId();
    final row = BatchRow(
      id: id,
      farmId: farmId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      name: name,
      birdType: birdType,
      initialCount: initialCount,
      acquiredOn: acquiredOn,
      ageAtAcquisitionDays: ageAtAcquisitionDays,
      hatcheryVaccinated: null,
      source: null,
      status: 'active',
      programmeId: programmeId,
      programmeVersion: programmeVersion,
      notes: null,
    );

    final companion = BatchesCompanion.insert(
      id: id,
      farmId: farmId,
      createdAt: now,
      updatedAt: now,
      name: name,
      birdType: birdType,
      initialCount: initialCount,
      acquiredOn: acquiredOn,
      ageAtAcquisitionDays: Value(ageAtAcquisitionDays),
      status: 'active',
      programmeId: programmeId,
      programmeVersion: programmeVersion,
    );

    await _syncedWrite.writeSynced(
      writeRow: () => _db.into(_db.batches).insertOnConflictUpdate(companion),
      table: _mapper.tableName,
      rowId: id,
      op: 'upsert',
      payload: _mapper.toPayload(row),
    );
    return row;
  }

  Stream<List<BatchRow>> watchForFarm(String farmId) {
    return (_db.select(_db.batches)
          ..where((b) => b.farmId.equals(farmId) & b.deletedAt.isNull()))
        .watch();
  }
}
