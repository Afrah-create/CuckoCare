import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/core/time/kampala_time.dart';
import 'package:cucocare/features/vaccination/domain/batch_age.dart';
import 'package:cucocare/features/vaccination/domain/entities.dart';
import 'package:cucocare/features/vaccination/domain/materialise_vaccination_tasks.dart';
import 'package:cucocare/features/vaccination/domain/task_scheduling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(KampalaTime.ensureInitialized);
  final clock = FixedClock(DateTime.utc(2026, 3, 10, 12));

  test('currentAgeDays uses Kampala calendar from acquired_on', () {
    final batch = Batch(
      id: 'b1',
      farmId: 'f1',
      acquiredOn: DateTime.utc(2026, 3, 1),
      ageAtAcquisitionDays: 5,
      programmeId: 'p1',
      programmeVersion: 1,
    );
    expect(currentAgeDays(batch, clock), 14);
  });

  test('hatchery steps become assumed_done', () {
    const materialiser = MaterialiseVaccinationTasks();
    final batch = Batch(
      id: 'b1',
      farmId: 'f1',
      acquiredOn: DateTime.utc(2026, 3, 8),
      ageAtAcquisitionDays: 0,
      programmeId: 'p1',
      programmeVersion: 1,
    );
    const hatchery = ProgrammeStep(
      id: 's1',
      programmeId: 'p1',
      name: 'Marek',
      ageDays: 1,
      location: StepLocation.hatchery,
      optional: false,
      dueWindowDaysBefore: 0,
      dueWindowDaysAfter: 0,
    );
    final drafts = materialiser(batch: batch, steps: [hatchery], clock: clock);
    expect(drafts.single.status, VaccinationTaskStatus.assumedDone);
  });

  test('steps before registration age become assumed_done not silent done', () {
    const materialiser = MaterialiseVaccinationTasks();
    final batch = Batch(
      id: 'b1',
      farmId: 'f1',
      acquiredOn: DateTime.utc(2026, 3, 1),
      ageAtAcquisitionDays: 10,
      programmeId: 'p1',
      programmeVersion: 1,
    );
    const step = ProgrammeStep(
      id: 's7',
      programmeId: 'p1',
      name: 'Day 7',
      ageDays: 7,
      location: StepLocation.farm,
      optional: false,
      dueWindowDaysBefore: 1,
      dueWindowDaysAfter: 2,
    );
    final drafts = materialiser(batch: batch, steps: [step], clock: clock);
    expect(drafts.single.status, VaccinationTaskStatus.assumedDone);
  });

  test('optional steps omitted by default', () {
    const materialiser = MaterialiseVaccinationTasks();
    final batch = Batch(
      id: 'b1',
      farmId: 'f1',
      acquiredOn: DateTime.utc(2026, 3, 8),
      ageAtAcquisitionDays: 0,
      programmeId: 'p1',
      programmeVersion: 1,
    );
    const optional = ProgrammeStep(
      id: 'opt',
      programmeId: 'p1',
      name: 'Optional',
      ageDays: 28,
      location: StepLocation.farm,
      optional: true,
      dueWindowDaysBefore: 0,
      dueWindowDaysAfter: 0,
    );
    final drafts = materialiser(batch: batch, steps: [optional], clock: clock);
    expect(drafts, isEmpty);
  });

  test('taskState marks due today and overdue', () {
    final batch = Batch(
      id: 'b1',
      farmId: 'f1',
      acquiredOn: DateTime.utc(2026, 3, 1),
      ageAtAcquisitionDays: 0,
      programmeId: 'p1',
      programmeVersion: 1,
    );
    const step = ProgrammeStep(
      id: 's',
      programmeId: 'p1',
      name: 'NCD',
      ageDays: 7,
      location: StepLocation.farm,
      optional: false,
      dueWindowDaysBefore: 0,
      dueWindowDaysAfter: 2,
    );
    final due = dueDate(batch, step);
    final task = VaccinationTask(
      id: 't1',
      batchId: 'b1',
      stepId: 's',
      dueOn: due,
      status: VaccinationTaskStatus.pending,
    );
    expect(taskState(task, FixedClock(due)), TaskDisplayState.dueToday);
    expect(
      taskState(task, FixedClock(due.add(const Duration(days: 5)))),
      TaskDisplayState.overdue,
    );
  });
}
