import 'calendar_date.dart';
import 'programme_catalog.dart';

/// Documented collision rules — list for vet review in [docs/batches-and-schedules.md].
class CollisionPolicy {
  const CollisionPolicy({
    this.dewormingMaxShiftDays = 3,
    this.managementMinGapFromVaccinationDays = 2,
    this.managementMaxShiftDays = 7,
  });

  final int dewormingMaxShiftDays;
  final int managementMinGapFromVaccinationDays;
  final int managementMaxShiftDays;

  CalendarDate resolveDueDate({
    required CalendarDate proposed,
    required StepCategory category,
    required Iterable<({CalendarDate dueOn, StepCategory category})> allTasks,
  }) {
    if (category == StepCategory.vaccination) {
      return proposed;
    }

    var due = proposed;
    if (category == StepCategory.deworming) {
      for (var shift = 0; shift <= dewormingMaxShiftDays; shift++) {
        if (!_collidesWithVaccination(due, allTasks)) {
          return due;
        }
        due = due.addDays(1);
      }
      return due;
    }

    if (category == StepCategory.management) {
      for (var shift = 0; shift <= managementMaxShiftDays; shift++) {
        if (!_tooCloseToVaccination(due, allTasks)) {
          return due;
        }
        due = due.addDays(1);
      }
      return due;
    }

    return proposed;
  }

  bool _collidesWithVaccination(
    CalendarDate due,
    Iterable<({CalendarDate dueOn, StepCategory category})> allTasks,
  ) {
    for (final t in allTasks) {
      if (t.category == StepCategory.vaccination && t.dueOn == due) {
        return true;
      }
    }
    return false;
  }

  bool _tooCloseToVaccination(
    CalendarDate due,
    Iterable<({CalendarDate dueOn, StepCategory category})> allTasks,
  ) {
    for (final t in allTasks) {
      if (t.category != StepCategory.vaccination) {
        continue;
      }
      final gap = (due.daysUntil(t.dueOn)).abs();
      if (gap < managementMinGapFromVaccinationDays) {
        return true;
      }
    }
    return false;
  }
}
