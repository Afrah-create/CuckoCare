import '../../../core/time/clock.dart';
import 'batch_age.dart';
import 'entities.dart';
import 'task_scheduling.dart';

class MaterialiseVaccinationTasks {
  const MaterialiseVaccinationTasks({
    this.recurringHorizonDays = 365,
    this.includeOptionalSteps = false,
  });

  final int recurringHorizonDays;
  final bool includeOptionalSteps;

  List<VaccinationTaskDraft> call({
    required Batch batch,
    required List<ProgrammeStep> steps,
    required Clock clock,
  }) {
    final age = currentAgeDays(batch, clock);
    final drafts = <VaccinationTaskDraft>[];

    for (final step in steps) {
      if (step.optional && !includeOptionalSteps) {
        continue;
      }

      if (step.recurring != null) {
        drafts.addAll(
          _recurringDrafts(batch: batch, step: step, clock: clock, age: age),
        );
        continue;
      }

      drafts.add(_singleDraft(batch: batch, step: step, age: age));
    }

    return drafts;
  }

  VaccinationTaskDraft _singleDraft({
    required Batch batch,
    required ProgrammeStep step,
    required int age,
  }) {
    final due = dueDate(batch, step);
    final status = _initialStatus(step: step, age: age);
    return VaccinationTaskDraft(stepId: step.id, dueOn: due, status: status);
  }

  List<VaccinationTaskDraft> _recurringDrafts({
    required Batch batch,
    required ProgrammeStep step,
    required Clock clock,
    required int age,
  }) {
    final recurring = step.recurring!;
    final horizon = recurring.horizonDays.clamp(1, recurringHorizonDays);
    final firstDue = dueDate(batch, step);
    final drafts = <VaccinationTaskDraft>[];

    var due = firstDue;
    final end = firstDue.add(Duration(days: horizon));
    while (!due.isAfter(end)) {
      final stepAge = step.ageDays +
          due.difference(firstDue).inDays ~/ recurring.intervalDays *
              recurring.intervalDays;
      final status = _initialStatus(
        step: step,
        age: age,
        stepAgeDays: stepAge,
      );
      drafts.add(
        VaccinationTaskDraft(stepId: step.id, dueOn: due, status: status),
      );
      due = due.add(Duration(days: recurring.intervalDays));
    }
    return drafts;
  }

  VaccinationTaskStatus _initialStatus({
    required ProgrammeStep step,
    required int age,
    int? stepAgeDays,
  }) {
    final targetAge = stepAgeDays ?? step.ageDays;

    if (step.location == StepLocation.hatchery) {
      return VaccinationTaskStatus.assumedDone;
    }

    if (targetAge < age) {
      return VaccinationTaskStatus.assumedDone;
    }

    return VaccinationTaskStatus.pending;
  }
}
