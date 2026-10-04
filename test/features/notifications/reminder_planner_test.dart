import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/notifications/domain/notification_prefs.dart';
import 'package:cucocare/features/notifications/domain/planned_reminder.dart';
import 'package:cucocare/features/notifications/domain/reminder_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final planner = ReminderPlanner();
  final today = CalendarDate.parseIso('2026-10-04');
  final nowLocal = DateTime.utc(2026, 10, 4, 6, 0);

  ReminderPlanTask task({
    String id = 't1',
    CalendarDate? dueOn,
  }) {
    return ReminderPlanTask(
      taskId: id,
      batchId: 'b1',
      farmId: 'f1',
      batchName: 'Batch 1',
      farmName: 'Home farm',
      stepLabel: 'Gumboro',
      dueOn: dueOn ?? CalendarDate.parseIso('2026-10-06'),
      enabled: true,
      status: 'pending',
      isHatcheryStep: false,
      batchActive: true,
    );
  }

  test('master switch off yields empty plan', () {
    final plan = planner.plan(
      prefs: NotificationPrefs.defaults.copyWith(remindersEnabled: false),
      tasks: [task()],
      today: today,
      nowLocal: nowLocal,
      farmCount: 1,
    );
    expect(plan, isEmpty);
  });

  test('standard overdue schedules day 1 and 3 only', () {
    final due = CalendarDate.parseIso('2026-10-05');
    final plan = planner.plan(
      prefs: NotificationPrefs.defaults.copyWith(
        dueRemindersEnabled: false,
      ),
      tasks: [task(dueOn: due)],
      today: today,
      nowLocal: nowLocal,
      farmCount: 1,
    );
    final overdue = plan.where((p) => p.kind == ReminderKind.scheduleOverdue);
    expect(overdue.length, 2);
  });

  test('daily overdue mode schedules seven days', () {
    final due = CalendarDate.parseIso('2026-10-05');
    final plan = planner.plan(
      prefs: NotificationPrefs.defaults.copyWith(
        dueRemindersEnabled: false,
        overdueMode: OverdueReminderMode.daily,
      ),
      tasks: [task(dueOn: due)],
      today: today,
      nowLocal: nowLocal,
      farmCount: 1,
    );
    expect(
      plan.where((p) => p.kind == ReminderKind.scheduleOverdue).length,
      7,
    );
  });

  test('catch-up schedules missed due reminder after phone was off', () {
    final due = CalendarDate.parseIso('2026-10-04');
    final plan = planner.plan(
      prefs: NotificationPrefs.defaults,
      tasks: [task(dueOn: due)],
      today: today,
      nowLocal: DateTime.utc(2026, 10, 4, 8, 0),
      farmCount: 1,
    );
    expect(plan.any((p) => p.kind == ReminderKind.scheduleDue), isTrue);
  });

  test('content hash changes when task set changes', () {
    final prefs = NotificationPrefs.defaults.copyWith(
      dueRemindersEnabled: false,
    );
    final a = planner.plan(
      prefs: prefs,
      tasks: [task(id: 'a')],
      today: today,
      nowLocal: nowLocal,
      farmCount: 1,
    );
    final b = planner.plan(
      prefs: prefs,
      tasks: [task(id: 'b')],
      today: today,
      nowLocal: nowLocal,
      farmCount: 1,
    );
    expect(a.first.contentHash, isNot(b.first.contentHash));
  });
}
