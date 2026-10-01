import 'dart:io';

import 'package:cucocare/features/batches/domain/batch_planner.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/data/programme_catalog_loader.dart';
import 'package:cucocare/features/batches/domain/programme_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String scheduleRaw;

  setUpAll(() {
    scheduleRaw = File('docs/schedule.json').readAsStringSync();
  });

  PlannedTask? findTask(BatchPlan plan, String stepId, {int occurrence = 0}) {
    for (final t in plan.tasks) {
      if (t.stepId == stepId && t.occurrence == occurrence) {
        return t;
      }
    }
    return null;
  }

  BatchPlan planLayerAge1(CalendarDate today) {
    final catalog = ProgrammeCatalogLoader.parseJson(scheduleRaw);
    const planner = BatchPlanner();
    return planner.plan(
      input: BatchPlanInput(
        batchId: 'batch-test',
        farmId: 'farm-test',
        name: 'Layers',
        birdType: BirdType.layer,
        initialCount: 100,
        acquiredOn: CalendarDate.parseIso('2026-10-01'),
        ageAtAcquisitionDays: 1,
      ),
      catalog: catalog,
      options: const BatchPlanOptions(
        includeRecommended: true,
        includeOptional: true,
        recurringHorizonDays: 365,
      ),
      today: today,
    );
  }

  test('real schedule file parses', () {
    expect(
      () => ProgrammeCatalogLoader.parseJson(scheduleRaw),
      returnsNormally,
    );
  });

  test('worked example: layer age 1 due dates', () {
    final plan = planLayerAge1(CalendarDate.parseIso('2026-10-01'));

    expect(findTask(plan, 'LY-D42')?.dueOn.toIso(), '2026-11-11');
    expect(findTask(plan, 'LY-D63')?.dueOn.toIso(), '2026-12-02');
    expect(findTask(plan, 'LY-D105')?.dueOn.toIso(), '2027-01-13');

    expect(findTask(plan, 'LY-W63')?.dueOn.toIso(), '2026-12-03');
    expect(findTask(plan, 'LY-W105')?.dueOn.toIso(), '2027-01-14');
    expect(findTask(plan, 'LY-M15')?.dueOn.toIso(), '2026-10-16');

    final r0 = findTask(plan, 'LY-R-NDIB', occurrence: 0);
    final r1 = findTask(plan, 'LY-R-NDIB', occurrence: 1);
    expect(r0?.dueOn.toIso(), '2027-02-24');
    expect(r1?.dueOn.toIso(), '2027-04-07');
  });

  test('worked example: broiler BR-D14 and BR-D28', () {
    final catalog = ProgrammeCatalogLoader.parseJson(scheduleRaw);
    const planner = BatchPlanner();
    final plan = planner.plan(
      input: BatchPlanInput(
        batchId: 'b',
        farmId: 'f',
        name: 'Broilers',
        birdType: BirdType.broiler,
        initialCount: 200,
        acquiredOn: CalendarDate.parseIso('2026-10-01'),
        ageAtAcquisitionDays: 1,
      ),
      catalog: catalog,
      options: const BatchPlanOptions(),
      today: CalendarDate.parseIso('2026-10-01'),
    );

    expect(findTask(plan, 'BR-D14')?.dueOn.toIso(), '2026-10-14');
    expect(findTask(plan, 'BR-D28')?.dueOn.toIso(), '2026-10-28');
  });

  test('layer bought at age 30: earlier steps assumed done', () {
    final catalog = ProgrammeCatalogLoader.parseJson(scheduleRaw);
    const planner = BatchPlanner();
    final plan = planner.plan(
      input: BatchPlanInput(
        batchId: 'b',
        farmId: 'f',
        name: 'Layers late',
        birdType: BirdType.layer,
        initialCount: 50,
        acquiredOn: CalendarDate.parseIso('2026-10-31'),
        ageAtAcquisitionDays: 30,
      ),
      catalog: catalog,
      options: const BatchPlanOptions(includeOptional: false),
      today: CalendarDate.parseIso('2026-10-31'),
    );

    for (final id in ['LY-D01', 'LY-D07', 'LY-D14', 'LY-D21', 'LY-D28']) {
      expect(
        findTask(plan, id)?.status,
        PlannedTaskStatus.assumedDone,
        reason: id,
      );
    }
    expect(findTask(plan, 'LY-D42')?.status, PlannedTaskStatus.pending);
  });

  test('local bird type yields no tasks', () {
    final catalog = ProgrammeCatalogLoader.parseJson(scheduleRaw);
    const planner = BatchPlanner();
    final plan = planner.plan(
      input: BatchPlanInput(
        batchId: 'b',
        farmId: 'f',
        name: 'Local',
        birdType: BirdType.local,
        initialCount: 20,
        acquiredOn: CalendarDate.parseIso('2026-10-01'),
        ageAtAcquisitionDays: 1,
      ),
      catalog: catalog,
      options: const BatchPlanOptions(),
      today: CalendarDate.parseIso('2026-10-01'),
    );
    expect(plan.tasks, isEmpty);
  });
}
