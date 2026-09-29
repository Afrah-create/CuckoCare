import '../../../core/time/clock.dart';
import '../../../core/time/kampala_time.dart';
import 'batch_age.dart';
import 'entities.dart';

DateTime dueDate(Batch batch, ProgrammeStep step) {
  final acquiredStart = KampalaTime.startOfDay(batch.acquiredOn);
  return acquiredStart.add(Duration(days: step.ageDays));
}

TaskDisplayState taskState(VaccinationTask task, Clock clock) {
  if (task.status == VaccinationTaskStatus.done ||
      task.status == VaccinationTaskStatus.skipped) {
    return TaskDisplayState.done;
  }

  final now = clock.now();
  final dueStart =
      KampalaTime.startOfDay(task.dueOn).subtract(const Duration(days: 0));
  final dueEnd = KampalaTime.endOfDay(task.dueOn);

  if (now.isAfter(dueEnd) &&
      task.status != VaccinationTaskStatus.assumedDone) {
    return TaskDisplayState.overdue;
  }

  if (KampalaTime.isSameLocalDay(now, task.dueOn)) {
    return TaskDisplayState.dueToday;
  }

  if (now.isBefore(dueStart)) {
    return TaskDisplayState.upcoming;
  }

  return TaskDisplayState.overdue;
}

/// Whether [step] is within its due window relative to batch age.
bool isStepInDueWindow(Batch batch, ProgrammeStep step, Clock clock) {
  final age = currentAgeDays(batch, clock);
  final earliest = step.ageDays - step.dueWindowDaysBefore;
  final latest = step.ageDays + step.dueWindowDaysAfter;
  return age >= earliest && age <= latest;
}
