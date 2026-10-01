import 'programme_catalog.dart';
import 'batch_planner.dart';
import 'calendar_date.dart';

enum TaskUiState {
  upcoming,
  dueSoon,
  dueToday,
  overdueGentle,
  overdueUrgent,
  done,
  skipped,
  needsConfirmation,
  disabled,
}

class TaskStateCalculator {
  const TaskStateCalculator({required this.dueWindow});

  final DueWindowConvention dueWindow;

  TaskUiState state({
    required PlannedTaskStatus status,
    required bool enabled,
    required CalendarDate dueOn,
    required CalendarDate today,
  }) {
    if (!enabled) {
      return TaskUiState.disabled;
    }
    return switch (status) {
      PlannedTaskStatus.done => TaskUiState.done,
      PlannedTaskStatus.skipped => TaskUiState.skipped,
      PlannedTaskStatus.assumedDone => TaskUiState.needsConfirmation,
      PlannedTaskStatus.pending => _pendingState(dueOn, today),
    };
  }

  TaskUiState _pendingState(CalendarDate dueOn, CalendarDate today) {
    final daysUntil = today.daysUntil(dueOn);
    if (daysUntil == 0) {
      return TaskUiState.dueToday;
    }
    if (daysUntil > 0) {
      if (daysUntil <= dueWindow.defaultDaysBefore) {
        return TaskUiState.dueSoon;
      }
      return TaskUiState.upcoming;
    }
    final daysLate = -daysUntil;
    if (daysLate <= dueWindow.defaultDaysAfterOverdue) {
      return TaskUiState.overdueGentle;
    }
    return TaskUiState.overdueUrgent;
  }
}
