import 'package:cucocare/features/batches/domain/batch_planner.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/domain/programme_catalog.dart';
import 'package:cucocare/features/batches/domain/task_state_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dueWindow = DueWindowConvention(
    defaultDaysBefore: 2,
    defaultDaysAfterOverdue: 3,
  );
  const calc = TaskStateCalculator(dueWindow: dueWindow);

  test('cannot mark done before due date', () {
    final today = CalendarDate(year: 2026, month: 3, day: 10);
    final due = CalendarDate(year: 2026, month: 3, day: 15);
    expect(
      calc.canMarkDone(
        status: PlannedTaskStatus.pending,
        dueOn: due,
        today: today,
      ),
      isFalse,
    );
  });

  test('can mark done on due date is false (not overdue)', () {
    final today = CalendarDate(year: 2026, month: 3, day: 15);
    final due = CalendarDate(year: 2026, month: 3, day: 15);
    expect(
      calc.canMarkDone(
        status: PlannedTaskStatus.pending,
        dueOn: due,
        today: today,
      ),
      isFalse,
    );
  });

  test('can mark done after due date', () {
    final today = CalendarDate(year: 2026, month: 3, day: 16);
    final due = CalendarDate(year: 2026, month: 3, day: 15);
    expect(
      calc.canMarkDone(
        status: PlannedTaskStatus.pending,
        dueOn: due,
        today: today,
      ),
      isTrue,
    );
  });

  test('assumed done can be confirmed', () {
    final today = CalendarDate(year: 2026, month: 3, day: 20);
    final due = CalendarDate(year: 2026, month: 3, day: 10);
    expect(
      calc.canMarkDone(
        status: PlannedTaskStatus.assumedDone,
        dueOn: due,
        today: today,
      ),
      isTrue,
    );
  });
}
