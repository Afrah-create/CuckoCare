import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/combine_latest.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/batch_planner.dart';
import '../domain/calendar_date.dart';
import '../domain/loss_record.dart';
import '../domain/programme_catalog.dart';
import '../domain/task_state_calculator.dart';
import 'batch_synced_table.dart';
import 'batch_views.dart';
import 'loss_synced_table.dart';
import 'schedule_dates.dart';
import '../../vaccination/data/vaccination_task_synced_table.dart';

class CreateBatchRequest {
  CreateBatchRequest({
    required this.farmId,
    required this.input,
    required this.plan,
    required this.catalog,
    this.hatcheryVaccinated,
    this.sourceName,
    this.notes,
    this.productionType,
  });

  final String farmId;
  final BatchPlanInput input;
  final BatchPlan plan;
  final ProgrammeCatalog catalog;
  final bool? hatcheryVaccinated;
  final String? sourceName;
  final String? notes;
  final String? productionType;
}

class BatchRepository {
  BatchRepository(this._db, this._clock, {SyncedWrite? syncedWrite})
    : _syncedWrite = syncedWrite ?? SyncedWrite(_db),
      _batchMapper = BatchSyncedTable(),
      _taskMapper = VaccinationTaskSyncedTable(),
      _lossMapper = LossSyncedTable();

  final AppDatabase _db;
  final Clock _clock;
  final SyncedWrite _syncedWrite;
  final BatchSyncedTable _batchMapper;
  final VaccinationTaskSyncedTable _taskMapper;
  final LossSyncedTable _lossMapper;

  /// Minimal batch row for sync tests and legacy callers (no schedule tasks).
  Future<BatchRow> createBatch({
    required String farmId,
    required String name,
    required String birdType,
    required int initialCount,
    required DateTime acquiredOn,
    required String programmeId,
    required int programmeVersion,
    int ageAtAcquisitionDays = 1,
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
      productionType: null,
      programmeContentHash: null,
      notes: null,
    );

    await _syncedWrite.writeSynced(
      writeRow: () => _db
          .into(_db.batches)
          .insertOnConflictUpdate(
            BatchesCompanion.insert(
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
            ),
          ),
      table: _batchMapper.tableName,
      rowId: id,
      op: 'upsert',
      payload: _batchMapper.toPayload(row),
    );
    return row;
  }

  Future<String> createBatchWithSchedule(CreateBatchRequest request) async {
    final now = _clock.now();
    final batchId = request.input.batchId;
    final programmeKey = request.plan.programmeKey?.name ?? '';

    final batchRow = BatchRow(
      id: batchId,
      farmId: request.farmId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      serverVersion: null,
      name: request.input.name,
      birdType: request.input.birdType.name,
      initialCount: request.input.initialCount,
      acquiredOn: dueOnToStorage(request.input.acquiredOn),
      ageAtAcquisitionDays: request.input.ageAtAcquisitionDays,
      hatcheryVaccinated: request.hatcheryVaccinated,
      source: request.sourceName,
      status: 'active',
      programmeId: programmeKey,
      programmeVersion: request.catalog.schemaVersion,
      productionType: request.productionType,
      programmeContentHash: request.catalog.contentHash,
      notes: request.notes,
    );

    final ops = <SyncedWriteOp>[
      SyncedWriteOp(
        writeRow: () => _db
            .into(_db.batches)
            .insertOnConflictUpdate(
              BatchesCompanion.insert(
                id: batchId,
                farmId: request.farmId,
                createdAt: now,
                updatedAt: now,
                name: request.input.name,
                birdType: request.input.birdType.name,
                initialCount: request.input.initialCount,
                acquiredOn: dueOnToStorage(request.input.acquiredOn),
                ageAtAcquisitionDays: Value(request.input.ageAtAcquisitionDays),
                hatcheryVaccinated: Value(request.hatcheryVaccinated),
                source: Value(request.sourceName),
                status: 'active',
                programmeId: programmeKey,
                programmeVersion: request.catalog.schemaVersion,
                productionType: Value(request.productionType),
                programmeContentHash: Value(request.catalog.contentHash),
                notes: Value(request.notes),
              ),
            ),
        table: _batchMapper.tableName,
        rowId: batchId,
        op: 'upsert',
        payload: _batchMapper.toPayload(batchRow),
      ),
    ];

    for (final task in request.plan.tasks) {
      final status = _statusToDb(task.status);
      final doneOn = _doneOnFor(task, request.plan.hatchDate, status);
      final taskRow = VaccinationTaskRow(
        id: task.id,
        farmId: request.farmId,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        serverVersion: null,
        batchId: batchId,
        stepId: task.stepId,
        occurrence: task.occurrence,
        dueOn: dueOnToStorage(task.dueOn),
        enabled: task.enabled,
        status: status,
        doneOn: doneOn,
        doneBy: status == 'done' && task.location == StepLocation.hatchery
            ? 'hatchery'
            : null,
        productUsed: null,
        notes: task.status == PlannedTaskStatus.skipped
            ? 'Not given at hatchery'
            : null,
        stepSnapshot: task.stepSnapshotJson,
        programmeContentHash: request.catalog.contentHash,
        shiftedFrom: task.shiftedFrom == null
            ? null
            : dueOnToStorage(task.shiftedFrom!),
      );

      ops.add(
        SyncedWriteOp(
          writeRow: () => _db
              .into(_db.vaccinationTasks)
              .insertOnConflictUpdate(
                VaccinationTasksCompanion.insert(
                  id: task.id,
                  farmId: request.farmId,
                  createdAt: now,
                  updatedAt: now,
                  batchId: batchId,
                  stepId: task.stepId,
                  occurrence: Value(task.occurrence),
                  dueOn: dueOnToStorage(task.dueOn),
                  enabled: Value(task.enabled),
                  status: status,
                  doneOn: Value(doneOn),
                  doneBy: Value(taskRow.doneBy),
                  notes: Value(taskRow.notes),
                  stepSnapshot: Value(task.stepSnapshotJson),
                  programmeContentHash: Value(request.catalog.contentHash),
                  shiftedFrom: Value(taskRow.shiftedFrom),
                ),
              ),
          table: _taskMapper.tableName,
          rowId: task.id,
          op: 'upsert',
          payload: _taskMapper.toPayload(taskRow),
        ),
      );
    }

    await _syncedWrite.writeSyncedMany(ops);
    return batchId;
  }

  String _statusToDb(PlannedTaskStatus status) => switch (status) {
    PlannedTaskStatus.pending => 'pending',
    PlannedTaskStatus.done => 'done',
    PlannedTaskStatus.skipped => 'skipped',
    PlannedTaskStatus.assumedDone => 'assumed_done',
  };

  DateTime? _doneOnFor(PlannedTask task, CalendarDate hatch, String status) {
    if (status != 'done') {
      return null;
    }
    if (task.location == StepLocation.hatchery) {
      return dueOnToStorage(hatch);
    }
    return dueOnToStorage(task.dueOn);
  }

  /// Every batch on the farm with grouped losses and next pending task, from
  /// one SQL statement so the list never runs a query per card.
  Stream<List<BatchSummaryData>> watchBatchSummaries(
    String farmId, {
    BatchListFilter filter = BatchListFilter.all,
    String search = '',
  }) {
    final where = StringBuffer('b.farm_id = ? AND b.deleted_at IS NULL');
    final vars = <Variable<Object>>[Variable.withString(farmId)];
    switch (filter) {
      case BatchListFilter.active:
        where.write(" AND b.status = 'active'");
      case BatchListFilter.closed:
        where.write(" AND b.status = 'closed'");
      case BatchListFilter.all:
        break;
    }
    final term = search.trim();
    if (term.isNotEmpty) {
      where.write(r" AND b.name LIKE ? ESCAPE '\'");
      vars.add(Variable.withString('%${_escapeLike(term)}%'));
    }

    final query = _db.customSelect(
      '''
SELECT b.*, l.kind AS l_kind, l.occurred_on AS l_on, l.total AS l_total,
       t.next_due AS t_next_due
FROM batches b
LEFT JOIN (
  SELECT batch_id, kind, occurred_on, SUM(count) AS total
  FROM mortality_records
  WHERE deleted_at IS NULL
  GROUP BY batch_id, kind, occurred_on
) l ON l.batch_id = b.id
LEFT JOIN (
  SELECT batch_id, MIN(due_on) AS next_due
  FROM vaccination_tasks
  WHERE deleted_at IS NULL AND enabled = 1 AND status = 'pending'
  GROUP BY batch_id
) t ON t.batch_id = b.id
WHERE $where
''',
      variables: vars,
      readsFrom: {_db.batches, _db.mortalityRecords, _db.vaccinationTasks},
    );

    return query.watch().map((rows) {
      final byId = <String, BatchRow>{};
      final tallies = <String, List<LossTally>>{};
      final nextDue = <String, CalendarDate>{};
      for (final row in rows) {
        final batch = _db.batches.map(row.data);
        byId.putIfAbsent(batch.id, () => batch);
        final list = tallies.putIfAbsent(batch.id, () => []);
        final total = row.readNullable<int>('l_total');
        final on = row.readNullable<DateTime>('l_on');
        if (total != null && on != null) {
          list.add(
            LossTally(
              kind: LossKind.fromStorage(row.readNullable<String>('l_kind')),
              occurredOn: dueOnFromStorage(on),
              count: total,
            ),
          );
        }
        final due = row.readNullable<DateTime>('t_next_due');
        if (due != null) {
          nextDue[batch.id] = dueOnFromStorage(due);
        }
      }
      return [
        for (final batch in byId.values)
          BatchSummaryData(
            batch: batch,
            tallies: tallies[batch.id] ?? const [],
            nextDueOn: nextDue[batch.id],
          ),
      ];
    });
  }

  Stream<BatchDetailData?> watchBatchDetail(String batchId) {
    final batch =
        (_db.select(_db.batches)
              ..where((b) => b.id.equals(batchId) & b.deletedAt.isNull()))
            .watchSingleOrNull();
    final losses = (_db.select(
      _db.mortalityRecords,
    )..where((l) => l.batchId.equals(batchId) & l.deletedAt.isNull())).watch();
    return combineLatest2(
      batch,
      losses,
      (BatchRow? b, List<MortalityRecordRow> l) =>
          b == null ? null : BatchDetailData(batch: b, losses: l),
    );
  }

  Future<BatchRow?> findBatch(String batchId) {
    return (_db.select(
      _db.batches,
    )..where((b) => b.id.equals(batchId))).getSingleOrNull();
  }

  Future<List<VaccinationTaskRow>> pendingTasks(String batchId) {
    return (_db.select(_db.vaccinationTasks)..where(
          (t) =>
              t.batchId.equals(batchId) &
              t.deletedAt.isNull() &
              t.status.equals('pending'),
        ))
        .get();
  }

  /// Rows a batch delete would hide: live tasks and live loss records.
  Future<({int tasks, int losses})> cascadeCounts(String batchId) async {
    final tasks = await (_db.select(
      _db.vaccinationTasks,
    )..where((t) => t.batchId.equals(batchId) & t.deletedAt.isNull())).get();
    final losses = await (_db.select(
      _db.mortalityRecords,
    )..where((l) => l.batchId.equals(batchId) & l.deletedAt.isNull())).get();
    return (tasks: tasks.length, losses: losses.length);
  }

  /// Saves edited details. Pending tasks move by [shiftDays] in the same transaction.
  Future<void> updateDetails(
    BatchRow existing, {
    required String name,
    required String? notes,
    required String? source,
    required int initialCount,
    required CalendarDate acquiredOn,
    required int ageAtAcquisitionDays,
    int shiftDays = 0,
  }) async {
    final now = _clock.now();
    final batch = existing.copyWith(
      updatedAt: now,
      name: name.trim(),
      notes: Value(_clean(notes)),
      source: Value(_clean(source)),
      initialCount: initialCount,
      acquiredOn: dueOnToStorage(acquiredOn),
      ageAtAcquisitionDays: ageAtAcquisitionDays,
    );
    final ops = [_batchOp(batch)];
    if (shiftDays != 0) {
      for (final task in await pendingTasks(existing.id)) {
        final moved = task.copyWith(
          updatedAt: now,
          dueOn: dueOnToStorage(
            dueOnFromStorage(task.dueOn).addDays(shiftDays),
          ),
        );
        ops.add(_taskOp(moved));
      }
    }
    await _syncedWrite.writeSyncedMany(ops);
  }

  Future<void> close(
    BatchRow existing, {
    required CalendarDate closedOn,
    required String reason,
    String? note,
  }) {
    final row = existing.copyWith(
      updatedAt: _clock.now(),
      status: 'closed',
      closedOn: Value(dueOnToStorage(closedOn)),
      closeReason: Value(reason),
      closeNote: Value(_clean(note)),
    );
    return _syncedWrite.writeSyncedMany([_batchOp(row)]);
  }

  Future<void> reopen(BatchRow existing) {
    final row = existing.copyWith(
      updatedAt: _clock.now(),
      status: 'active',
      closedOn: const Value(null),
      closeReason: const Value(null),
      closeNote: const Value(null),
    );
    return _syncedWrite.writeSyncedMany([_batchOp(row)]);
  }

  /// Soft-deletes the batch, its tasks and its losses under one group id.
  /// Feed, health and vet records are left alone.
  Future<String> deleteCascade(BatchRow existing) async {
    final now = _clock.now();
    final groupId = newId();
    final ops = <SyncedWriteOp>[
      _batchOp(
        existing.copyWith(
          updatedAt: now,
          deletedAt: Value(now),
          deletedGroupId: Value(groupId),
        ),
      ),
    ];
    final tasks =
        await (_db.select(_db.vaccinationTasks)..where(
              (t) => t.batchId.equals(existing.id) & t.deletedAt.isNull(),
            ))
            .get();
    for (final task in tasks) {
      ops.add(
        _taskOp(
          task.copyWith(
            updatedAt: now,
            deletedAt: Value(now),
            deletedGroupId: Value(groupId),
          ),
        ),
      );
    }
    final losses =
        await (_db.select(_db.mortalityRecords)..where(
              (l) => l.batchId.equals(existing.id) & l.deletedAt.isNull(),
            ))
            .get();
    for (final loss in losses) {
      ops.add(
        _lossOp(
          loss.copyWith(
            updatedAt: now,
            deletedAt: Value(now),
            deletedGroupId: Value(groupId),
          ),
        ),
      );
    }
    await _syncedWrite.writeSyncedMany(ops);
    return groupId;
  }

  /// Brings back exactly the rows stamped with [groupId].
  Future<void> restoreGroup(String groupId) async {
    final now = _clock.now();
    final batches = await (_db.select(
      _db.batches,
    )..where((b) => b.deletedGroupId.equals(groupId))).get();
    final tasks = await (_db.select(
      _db.vaccinationTasks,
    )..where((t) => t.deletedGroupId.equals(groupId))).get();
    final losses = await (_db.select(
      _db.mortalityRecords,
    )..where((l) => l.deletedGroupId.equals(groupId))).get();
    const clear = Value<DateTime?>(null);
    const noGroup = Value<String?>(null);
    await _syncedWrite.writeSyncedMany([
      for (final b in batches)
        _batchOp(
          b.copyWith(updatedAt: now, deletedAt: clear, deletedGroupId: noGroup),
        ),
      for (final t in tasks)
        _taskOp(
          t.copyWith(updatedAt: now, deletedAt: clear, deletedGroupId: noGroup),
        ),
      for (final l in losses)
        _lossOp(
          l.copyWith(updatedAt: now, deletedAt: clear, deletedGroupId: noGroup),
        ),
    ]);
  }

  SyncedWriteOp _batchOp(BatchRow row) => SyncedWriteOp(
    writeRow: () =>
        _db.into(_db.batches).insertOnConflictUpdate(row.toCompanion(false)),
    table: _batchMapper.tableName,
    rowId: row.id,
    op: 'upsert',
    payload: _batchMapper.toPayload(row),
  );

  SyncedWriteOp _taskOp(VaccinationTaskRow row) => SyncedWriteOp(
    writeRow: () => _db
        .into(_db.vaccinationTasks)
        .insertOnConflictUpdate(row.toCompanion(false)),
    table: _taskMapper.tableName,
    rowId: row.id,
    op: 'upsert',
    payload: _taskMapper.toPayload(row),
  );

  SyncedWriteOp _lossOp(MortalityRecordRow row) => SyncedWriteOp(
    writeRow: () => _db
        .into(_db.mortalityRecords)
        .insertOnConflictUpdate(row.toCompanion(false)),
    table: _lossMapper.tableName,
    rowId: row.id,
    op: 'upsert',
    payload: _lossMapper.toPayload(row),
  );

  static String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _escapeLike(String term) => term
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  Stream<List<BatchRow>> watchActiveForFarm(String farmId) {
    return (_db.select(_db.batches)
          ..where(
            (b) =>
                b.farmId.equals(farmId) &
                b.deletedAt.isNull() &
                b.status.equals('active'),
          )
          ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)]))
        .watch();
  }

  Stream<BatchRow?> watchBatch(String batchId) {
    return (_db.select(
      _db.batches,
    )..where((b) => b.id.equals(batchId))).watchSingleOrNull();
  }

  Stream<List<VaccinationTaskRow>> watchTasksForBatch(String batchId) {
    return (_db.select(_db.vaccinationTasks)
          ..where((t) => t.batchId.equals(batchId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.dueOn)]))
        .watch();
  }

  Stream<VaccinationTaskRow?> watchTask(String taskId) {
    return (_db.select(_db.vaccinationTasks)
          ..where((t) => t.id.equals(taskId) & t.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Stream<int> watchActiveBatchCount(String farmId) {
    final query = _db.select(_db.batches)
      ..where(
        (b) =>
            b.farmId.equals(farmId) &
            b.deletedAt.isNull() &
            b.status.equals('active'),
      );
    return query.watch().map((rows) => rows.length);
  }

  Stream<int> watchDueThisWeekCount(String farmId, DateTime todayStart) {
    final end = todayStart.add(const Duration(days: 6));
    return (_db.select(_db.vaccinationTasks)..where(
          (t) =>
              t.farmId.equals(farmId) &
              t.deletedAt.isNull() &
              t.enabled.equals(true) &
              t.status.equals('pending') &
              t.dueOn.isBiggerOrEqualValue(todayStart) &
              t.dueOn.isSmallerOrEqualValue(end) &
              t.batchId.isInQuery(_activeBatchIds(farmId)),
        ))
        .watch()
        .map((rows) => rows.length);
  }

  Stream<List<VaccinationTaskRow>> watchNeedsAttention(
    String farmId,
    DateTime todayStart,
    DateTime todayEnd,
  ) {
    return (_db.select(_db.vaccinationTasks)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.deletedAt.isNull() &
                t.enabled.equals(true) &
                (t.status.equals('pending') | t.status.equals('assumed_done')) &
                (t.dueOn.isSmallerOrEqualValue(todayEnd) |
                    t.status.equals('assumed_done')) &
                t.batchId.isInQuery(_activeBatchIds(farmId)),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueOn)]))
        .watch();
  }

  /// Tasks of closed or deleted batches never show as due.
  BaseSelectStatement _activeBatchIds(String farmId) {
    return _db.selectOnly(_db.batches)
      ..addColumns([_db.batches.id])
      ..where(
        _db.batches.farmId.equals(farmId) &
            _db.batches.deletedAt.isNull() &
            _db.batches.status.equals('active'),
      );
  }

  Future<void> markTaskDone({
    required String taskId,
    required DateTime doneOn,
    required DateTime todayLocal,
    String? productUsed,
    String? notes,
  }) async {
    final now = _clock.now();
    final existing = await (_db.select(
      _db.vaccinationTasks,
    )..where((t) => t.id.equals(taskId))).getSingleOrNull();
    if (existing == null) {
      return;
    }

    const dueWindow = DueWindowConvention(
      defaultDaysBefore: 2,
      defaultDaysAfterOverdue: 3,
    );
    const calc = TaskStateCalculator(dueWindow: dueWindow);
    final today = CalendarDate.fromDateTime(todayLocal);
    final due = dueOnFromStorage(existing.dueOn);
    final status = plannedStatusFromDb(existing.status);
    if (!calc.canMarkDone(status: status, dueOn: due, today: today)) {
      throw StateError(
        'This step is not overdue yet. You can mark it done after the due date.',
      );
    }

    final updated = VaccinationTaskRow(
      id: existing.id,
      farmId: existing.farmId,
      createdAt: existing.createdAt,
      updatedAt: now,
      deletedAt: existing.deletedAt,
      serverVersion: existing.serverVersion,
      batchId: existing.batchId,
      stepId: existing.stepId,
      occurrence: existing.occurrence,
      dueOn: existing.dueOn,
      enabled: existing.enabled,
      status: 'done',
      doneOn: doneOn,
      doneBy: existing.doneBy,
      productUsed: productUsed,
      notes: notes ?? existing.notes,
      stepSnapshot: existing.stepSnapshot,
      programmeContentHash: existing.programmeContentHash,
      shiftedFrom: existing.shiftedFrom,
    );

    await _syncedWrite.writeSynced(
      writeRow: () =>
          (_db.update(
            _db.vaccinationTasks,
          )..where((t) => t.id.equals(taskId))).write(
            VaccinationTasksCompanion(
              updatedAt: Value(now),
              status: const Value('done'),
              doneOn: Value(doneOn),
              productUsed: Value(productUsed),
              notes: Value(notes ?? existing.notes),
            ),
          ),
      table: _taskMapper.tableName,
      rowId: taskId,
      op: 'upsert',
      payload: _taskMapper.toPayload(updated),
    );
  }

  Future<void> revertTaskDone({
    required String taskId,
    required String previousStatus,
    DateTime? previousDoneOn,
    String? previousProduct,
  }) async {
    final now = _clock.now();
    final existing = await (_db.select(
      _db.vaccinationTasks,
    )..where((t) => t.id.equals(taskId))).getSingleOrNull();
    if (existing == null) {
      return;
    }
    final updated = VaccinationTaskRow(
      id: existing.id,
      farmId: existing.farmId,
      createdAt: existing.createdAt,
      updatedAt: now,
      deletedAt: existing.deletedAt,
      serverVersion: existing.serverVersion,
      batchId: existing.batchId,
      stepId: existing.stepId,
      occurrence: existing.occurrence,
      dueOn: existing.dueOn,
      enabled: existing.enabled,
      status: previousStatus,
      doneOn: previousDoneOn,
      doneBy: existing.doneBy,
      productUsed: previousProduct,
      notes: existing.notes,
      stepSnapshot: existing.stepSnapshot,
      programmeContentHash: existing.programmeContentHash,
      shiftedFrom: existing.shiftedFrom,
    );
    await _syncedWrite.writeSynced(
      writeRow: () =>
          (_db.update(
            _db.vaccinationTasks,
          )..where((t) => t.id.equals(taskId))).write(
            VaccinationTasksCompanion(
              updatedAt: Value(now),
              status: Value(previousStatus),
              doneOn: Value(previousDoneOn),
              productUsed: Value(previousProduct),
            ),
          ),
      table: _taskMapper.tableName,
      rowId: taskId,
      op: 'upsert',
      payload: _taskMapper.toPayload(updated),
    );
  }
}
