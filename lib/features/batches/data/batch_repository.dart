import 'package:drift/drift.dart';

import '../../../core/time/clock.dart';
import '../../../core/utils/uuid_v7.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/db/synced_write.dart';
import '../domain/batch_planner.dart';
import '../domain/calendar_date.dart';
import '../domain/programme_catalog.dart';
import '../domain/task_state_calculator.dart';
import 'batch_synced_table.dart';
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
        _taskMapper = VaccinationTaskSyncedTable();

  final AppDatabase _db;
  final Clock _clock;
  final SyncedWrite _syncedWrite;
  final BatchSyncedTable _batchMapper;
  final VaccinationTaskSyncedTable _taskMapper;

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
      writeRow: () => _db.into(_db.batches).insertOnConflictUpdate(
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
        writeRow: () => _db.into(_db.batches).insertOnConflictUpdate(
              BatchesCompanion.insert(
                id: batchId,
                farmId: request.farmId,
                createdAt: now,
                updatedAt: now,
                name: request.input.name,
                birdType: request.input.birdType.name,
                initialCount: request.input.initialCount,
                acquiredOn: dueOnToStorage(request.input.acquiredOn),
                ageAtAcquisitionDays:
                    Value(request.input.ageAtAcquisitionDays),
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
        doneBy: status == 'done' &&
                task.location == StepLocation.hatchery
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
          writeRow: () => _db.into(_db.vaccinationTasks).insertOnConflictUpdate(
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

  DateTime? _doneOnFor(
    PlannedTask task,
    CalendarDate hatch,
    String status,
  ) {
    if (status != 'done') {
      return null;
    }
    if (task.location == StepLocation.hatchery) {
      return dueOnToStorage(hatch);
    }
    return dueOnToStorage(task.dueOn);
  }

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
    return (_db.select(_db.batches)..where((b) => b.id.equals(batchId)))
        .watchSingleOrNull();
  }

  Stream<List<VaccinationTaskRow>> watchTasksForBatch(String batchId) {
    return (_db.select(_db.vaccinationTasks)
          ..where(
            (t) => t.batchId.equals(batchId) & t.deletedAt.isNull(),
          )
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
    return (_db.select(_db.vaccinationTasks)
          ..where(
            (t) =>
                t.farmId.equals(farmId) &
                t.deletedAt.isNull() &
                t.enabled.equals(true) &
                t.status.equals('pending') &
                t.dueOn.isBiggerOrEqualValue(todayStart) &
                t.dueOn.isSmallerOrEqualValue(end),
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
                    t.status.equals('assumed_done')),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueOn)]))
        .watch();
  }

  Future<void> markTaskDone({
    required String taskId,
    required DateTime doneOn,
    required DateTime todayLocal,
    String? productUsed,
    String? notes,
  }) async {
    final now = _clock.now();
    final existing = await (_db.select(_db.vaccinationTasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
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
      writeRow: () => (_db.update(_db.vaccinationTasks)
            ..where((t) => t.id.equals(taskId)))
          .write(
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
    final existing = await (_db.select(_db.vaccinationTasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
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
      writeRow: () => (_db.update(_db.vaccinationTasks)
            ..where((t) => t.id.equals(taskId)))
          .write(
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
