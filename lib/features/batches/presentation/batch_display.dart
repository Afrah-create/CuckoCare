import '../../../data_platform/db/app_database.dart';
import '../data/schedule_dates.dart';
import '../domain/calendar_date.dart';
import '../domain/hatch_date.dart';
import '../domain/programme_catalog.dart';
import '../domain/task_state_calculator.dart';

int batchAgeDays(BatchRow batch, DateTime todayLocal) {
  final today = CalendarDate.fromDateTime(todayLocal);
  final acquired = dueOnFromStorage(batch.acquiredOn);
  final hatch = hatchDate(
    acquiredOn: acquired,
    ageAtAcquisitionDays: batch.ageAtAcquisitionDays,
  );
  return ageDaysAt(hatch: hatch, today: today);
}

String batchAgeLabel(BatchRow batch, DateTime todayLocal) {
  final days = batchAgeDays(batch, todayLocal);
  final week = ((days - 1) ~/ 7) + 1;
  return 'Day $days (Week $week)';
}

String birdTypeLabel(String birdType) => switch (birdType) {
  'broiler' => 'Broiler',
  'layer' => 'Layer',
  'dualPurpose' => 'Dual-purpose',
  'local' => 'Local / indigenous',
  _ => birdType,
};

const _defaultDueWindow = DueWindowConvention(
  defaultDaysBefore: 2,
  defaultDaysAfterOverdue: 3,
);

TaskUiState taskUiStateFor(VaccinationTaskRow task, DateTime todayLocal) {
  const calc = TaskStateCalculator(dueWindow: _defaultDueWindow);
  final today = CalendarDate.fromDateTime(todayLocal);
  final due = dueOnFromStorage(task.dueOn);
  return calc.state(
    status: plannedStatusFromDb(task.status),
    enabled: task.enabled,
    dueOn: due,
    today: today,
  );
}

String taskUiStateLabel(TaskUiState state) => switch (state) {
  TaskUiState.upcoming => 'Upcoming',
  TaskUiState.dueSoon => 'Due soon',
  TaskUiState.dueToday => 'Due today',
  TaskUiState.overdueGentle => 'Overdue',
  TaskUiState.overdueUrgent => 'Overdue',
  TaskUiState.done => 'Done',
  TaskUiState.skipped => 'Skipped',
  TaskUiState.needsConfirmation => 'Confirm',
  TaskUiState.disabled => 'Off',
};
