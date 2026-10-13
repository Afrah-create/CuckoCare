import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/batches/data/batch_management.dart';
import 'package:cucocare/features/batches/data/batch_repository.dart';
import 'package:cucocare/features/batches/data/batch_views.dart';
import 'package:cucocare/features/batches/data/loss_repository.dart';
import 'package:cucocare/features/batches/data/schedule_dates.dart';
import 'package:cucocare/features/batches/domain/batch_facts.dart';
import 'package:cucocare/features/batches/domain/batch_permissions.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/domain/loss_record.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const farmId = 'farm-1';
const today = CalendarDate(year: 2026, month: 3, day: 20);
const arrived = CalendarDate(year: 2026, month: 3, day: 1);

void main() {
  late AppDatabase db;
  late BatchRepository batches;
  late LossRepository losses;
  late BatchManagement management;
  var role = FarmRole.owner;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final clock = FixedClock(DateTime.utc(2026, 3, 20, 9));
    batches = BatchRepository(db, clock);
    losses = LossRepository(db, clock);
    role = FarmRole.owner;
    management = BatchManagement(
      batches: batches,
      losses: losses,
      today: () => today,
      roleOf: (_) async => role,
    );
  });

  tearDown(() => db.close());

  Future<String> newBatch({int birds = 100}) async {
    final row = await batches.createBatch(
      farmId: farmId,
      name: 'Shed A',
      birdType: 'broiler',
      initialCount: birds,
      acquiredOn: dueOnToStorage(arrived),
      programmeId: 'p',
      programmeVersion: 1,
    );
    return row.id;
  }

  Future<void> addTask(
    String batchId,
    String id,
    CalendarDate due,
    String status,
  ) {
    return db
        .into(db.vaccinationTasks)
        .insert(
          VaccinationTasksCompanion.insert(
            id: id,
            farmId: farmId,
            createdAt: DateTime.utc(2026, 3, 1),
            updatedAt: DateTime.utc(2026, 3, 1),
            batchId: batchId,
            stepId: 'step-$id',
            dueOn: dueOnToStorage(due),
            status: status,
          ),
        );
  }

  Future<MortalityRecordRow> record(
    String batchId,
    int count, {
    CalendarDate on = today,
  }) async {
    final result = await management.recordLoss(
      batchId: batchId,
      draft: LossDraft(count: count, kind: LossKind.died, occurredOn: on),
    );
    return (result as Success<MortalityRecordRow>).value;
  }

  Future<int> liveCount(String batchId) async {
    final summaries = await batches.watchBatchSummaries(farmId).first;
    final s = summaries.firstWhere((s) => s.batch.id == batchId);
    final total = s.tallies.fold<int>(0, (sum, t) => sum + t.count);
    return s.batch.initialCount - total;
  }

  test(
    'recording a loss writes the row and an outbox entry together',
    () async {
      final batchId = await newBatch();
      final loss = await record(batchId, 3);

      final outbox = await (db.select(
        db.outbox,
      )..where((o) => o.targetTable.equals('mortality_records'))).get();
      expect(outbox.map((o) => o.rowId), contains(loss.id));
      expect(await liveCount(batchId), 97);
    },
  );

  test(
    'a loss above the live count is rejected with the rule message',
    () async {
      final batchId = await newBatch(birds: 5);
      await record(batchId, 4);

      final result = await management.recordLoss(
        batchId: batchId,
        draft: const LossDraft(
          count: 2,
          kind: LossKind.died,
          occurredOn: today,
        ),
      );
      final failure = (result as Error).failure;
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure as ValidationFailure).message,
        'You only have 1 live birds. You can record up to 1.',
      );
    },
  );

  test('editing a loss updates the count and marks it edited', () async {
    final batchId = await newBatch();
    final loss = await record(batchId, 3);

    final result = await management.editLoss(
      lossId: loss.id,
      draft: const LossDraft(
        count: 5,
        kind: LossKind.culled,
        occurredOn: today,
      ),
    );
    expect(result.isSuccess, isTrue);
    final saved = await losses.findLoss(loss.id);
    expect(saved!.count, 5);
    expect(saved.kind, 'culled');
    expect(saved.editedAt, isNotNull);
    expect(await liveCount(batchId), 95);
  });

  test('deleting a loss and undoing it restores the live count', () async {
    final batchId = await newBatch();
    final loss = await record(batchId, 4);

    await management.deleteLoss(loss.id);
    expect(await liveCount(batchId), 100);

    await management.restoreLoss(loss.id);
    expect(await liveCount(batchId), 96);
  });

  test(
    'deleting a batch stamps one group on the batch, tasks and losses',
    () async {
      final batchId = await newBatch();
      await addTask(batchId, 't1', today.addDays(2), 'pending');
      await addTask(batchId, 't2', arrived, 'done');
      await record(batchId, 2);

      final result = await management.deleteBatch(batchId);
      final deletion = (result as Success<BatchDeletion>).value;
      expect(deletion.taskCount, 2);
      expect(deletion.lossCount, 1);

      final batch = await batches.findBatch(batchId);
      final tasks = await db.select(db.vaccinationTasks).get();
      final lossRows = await db.select(db.mortalityRecords).get();
      expect(batch!.deletedGroupId, deletion.groupId);
      expect(tasks.every((t) => t.deletedGroupId == deletion.groupId), isTrue);
      expect(lossRows.every((l) => l.deletedAt != null), isTrue);
      expect(await batches.watchBatchSummaries(farmId).first, isEmpty);

      await management.restoreBatch(deletion.groupId);
      final restored = await batches.findBatch(batchId);
      expect(restored!.deletedAt, isNull);
      expect(
        (await db.select(db.vaccinationTasks).get()).every(
          (t) => t.deletedAt == null,
        ),
        isTrue,
      );
      expect(await liveCount(batchId), 98);
    },
  );

  test('a loss deleted before the batch stays deleted after undo', () async {
    final batchId = await newBatch();
    final early = await record(batchId, 2);
    await record(batchId, 3);
    await management.deleteLoss(early.id);

    final deletion = ((await management.deleteBatch(
      batchId,
    )) as Success<BatchDeletion>).value;
    await management.restoreBatch(deletion.groupId);

    expect((await losses.findLoss(early.id))!.deletedAt, isNotNull);
    expect(await liveCount(batchId), 97);
  });

  test(
    'closing hides due tasks; reopening brings them back untouched',
    () async {
      final batchId = await newBatch();
      await addTask(batchId, 't1', today.addDays(1), 'pending');
      final todayStart = dueOnToStorage(today);

      expect(await batches.watchDueThisWeekCount(farmId, todayStart).first, 1);

      final closed = await management.closeBatch(
        batchId: batchId,
        closedOn: today,
        reason: CloseReason.sold,
      );
      expect(closed.isSuccess, isTrue);
      expect(await batches.watchDueThisWeekCount(farmId, todayStart).first, 0);

      final blocked = await management.recordLoss(
        batchId: batchId,
        draft: const LossDraft(
          count: 1,
          kind: LossKind.died,
          occurredOn: today,
        ),
      );
      expect((blocked as Error).failure, isA<ValidationFailure>());

      await management.reopenBatch(batchId);
      final batch = await batches.findBatch(batchId);
      expect(batch!.status, 'active');
      expect(batch.closedOn, isNull);
      expect(await batches.watchDueThisWeekCount(farmId, todayStart).first, 1);
      final task = await (db.select(db.vaccinationTasks)).getSingle();
      expect(task.status, 'pending');
    },
  );

  test('moving the arrival date shifts only pending tasks', () async {
    final batchId = await newBatch();
    await addTask(batchId, 'pending', arrived.addDays(10), 'pending');
    await addTask(batchId, 'done', arrived.addDays(5), 'done');
    final batch = (await batches.findBatch(batchId))!;
    final edit = BatchEdit(
      name: batch.name,
      notes: batch.notes,
      source: batch.source,
      initialCount: batch.initialCount,
      acquiredOn: arrived.addDays(2),
      ageAtAcquisitionDays: batch.ageAtAcquisitionDays,
    );

    final impact = ((await management.previewEdit(
      batchId,
      edit,
    )) as Success<BatchEditImpact>).value;
    expect(impact.shiftDays, 2);
    expect(impact.pendingTasksToMove, 1);

    expect(
      (await management.updateBatchDetails(batchId, edit)).isSuccess,
      isTrue,
    );
    final tasks = {
      for (final t in await db.select(db.vaccinationTasks).get())
        t.id: dueOnFromStorage(t.dueOn),
    };
    expect(tasks['pending'], arrived.addDays(12));
    expect(tasks['done'], arrived.addDays(5));
  });

  test('initial count cannot drop below recorded losses', () async {
    final batchId = await newBatch(birds: 10);
    await record(batchId, 6);

    final result = await management.correctInitialCount(batchId, 5);
    expect((result as Error).failure, isA<ValidationFailure>());
    expect(
      (await management.correctInitialCount(batchId, 6)).isSuccess,
      isTrue,
    );
  });

  test(
    'workers record losses but cannot manage; viewers cannot do either',
    () async {
      final batchId = await newBatch();

      role = FarmRole.worker;
      expect(
        (await management.recordLoss(
          batchId: batchId,
          draft: const LossDraft(
            count: 1,
            kind: LossKind.died,
            occurredOn: today,
          ),
        )).isSuccess,
        isTrue,
      );
      expect(
        ((await management.deleteBatch(batchId)) as Error).failure,
        isA<PermissionFailure>(),
      );

      role = FarmRole.viewer;
      expect(
        ((await management.recordLoss(
          batchId: batchId,
          draft: const LossDraft(
            count: 1,
            kind: LossKind.died,
            occurredOn: today,
          ),
        )) as Error).failure,
        isA<PermissionFailure>(),
      );
    },
  );

  test('summary stream filters by status and reacts to new losses', () async {
    final a = await newBatch(birds: 10);
    final b = await newBatch(birds: 20);
    await management.closeBatch(
      batchId: b,
      closedOn: today,
      reason: CloseReason.cycleComplete,
    );

    final active = await batches
        .watchBatchSummaries(farmId, filter: BatchListFilter.active)
        .first;
    final closed = await batches
        .watchBatchSummaries(farmId, filter: BatchListFilter.closed)
        .first;
    expect(active.map((s) => s.batch.id), [a]);
    expect(closed.map((s) => s.batch.id), [b]);

    final stream = batches.watchBatchSummaries(
      farmId,
      filter: BatchListFilter.active,
    );
    final expectation = expectLater(
      stream.map(
        (rows) => rows.single.tallies.fold<int>(0, (n, t) => n + t.count),
      ),
      emitsThrough(3),
    );
    await record(a, 3);
    await expectation;
  });
}
