import 'programme_catalog.dart';
import 'batch_planner.dart';
import 'calendar_date.dart';

PlannedTaskStatus plannedStatusFromDb(String status) => switch (status) {
      'done' => PlannedTaskStatus.done,
      'skipped' => PlannedTaskStatus.skipped,
      'assumed_done' => PlannedTaskStatus.assumedDone,
      _ => PlannedTaskStatus.pending,
    };

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

  /// Whether the farmer may mark this step done (not before the due date).
  bool canMarkDone({
    required PlannedTaskStatus status,
    required CalendarDate dueOn,
    required CalendarDate today,
  }) {
    if (status == PlannedTaskStatus.assumedDone) {
      return true;
    }
    if (status != PlannedTaskStatus.pending) {
      return false;
    }
    return today.daysUntil(dueOn) < 0;
  }
}

bool taskUiStateAllowsMarkDone(TaskUiState ui) {
  return ui == TaskUiState.overdueGentle ||
      ui == TaskUiState.overdueUrgent ||
      ui == TaskUiState.needsConfirmation;
}
