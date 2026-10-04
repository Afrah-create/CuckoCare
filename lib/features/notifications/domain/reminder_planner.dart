import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/time/kampala_time.dart';
import '../../../features/batches/domain/calendar_date.dart';
import '../../../features/batches/domain/programme_catalog.dart';
import 'notification_prefs.dart';
import 'planned_reminder.dart';

class ReminderPlanTask {
  const ReminderPlanTask({
    required this.taskId,
    required this.batchId,
    required this.farmId,
    required this.batchName,
    required this.farmName,
    required this.stepLabel,
    required this.dueOn,
    required this.enabled,
    required this.status,
    required this.isHatcheryStep,
    required this.batchActive,
  });

  final String taskId;
  final String batchId;
  final String farmId;
  final String batchName;
  final String farmName;
  final String stepLabel;
  final CalendarDate dueOn;
  final bool enabled;
  final String status;
  final bool isHatcheryStep;
  final bool batchActive;
}

class ReminderPlanner {
  ReminderPlanner({
    this.dueWindow = const DueWindowConvention(
      defaultDaysBefore: 1,
      defaultDaysAfterOverdue: 3,
    ),
    this.horizonDays = 30,
    this.maxReminders = 60,
  });

  final DueWindowConvention dueWindow;
  final int horizonDays;
  final int maxReminders;

  List<PlannedReminder> plan({
    required NotificationPrefs prefs,
    required List<ReminderPlanTask> tasks,
    required CalendarDate today,
    required DateTime nowLocal,
    required int farmCount,
  }) {
    if (!prefs.remindersEnabled ||
        (!prefs.dueRemindersEnabled && !prefs.overdueRemindersEnabled)) {
      return const [];
    }

    final candidates = <_Candidate>[];

    for (final task in tasks) {
      if (!task.batchActive || !task.enabled) {
        continue;
      }
      if (task.isHatcheryStep) {
        continue;
      }
      if (task.status != 'pending') {
        continue;
      }

      if (prefs.dueRemindersEnabled) {
        final dayBefore = task.dueOn.addDays(-dueWindow.defaultDaysBefore);
        _addDueCandidate(
          candidates,
          task: task,
          fireDate: dayBefore,
          kind: ReminderKind.scheduleDue,
          today: today,
          nowLocal: nowLocal,
          reminderTimeMinutes: prefs.reminderTimeMinutes,
        );
        _addDueCandidate(
          candidates,
          task: task,
          fireDate: task.dueOn,
          kind: ReminderKind.scheduleDue,
          today: today,
          nowLocal: nowLocal,
          reminderTimeMinutes: prefs.reminderTimeMinutes,
        );
      }

      if (prefs.overdueRemindersEnabled) {
        final overdueDays = prefs.overdueMode == OverdueReminderMode.daily
            ? List.generate(7, (i) => i + 1)
            : [1, 3];
        for (final d in overdueDays) {
          _addDueCandidate(
            candidates,
            task: task,
            fireDate: task.dueOn.addDays(d),
            kind: ReminderKind.scheduleOverdue,
            today: today,
            nowLocal: nowLocal,
            reminderTimeMinutes: prefs.reminderTimeMinutes,
            daysOverdue: d,
          );
        }
      }
    }

    final grouped = <String, List<_Candidate>>{};
    for (final c in candidates) {
      final key = '${c.fireAt.toIso8601String()}|${c.kind.name}|${c.task.farmId}';
      grouped.putIfAbsent(key, () => []).add(c);
    }

    final reminders = <PlannedReminder>[];
    final sortedKeys = grouped.keys.toList()..sort();
    for (final key in sortedKeys) {
      final group = grouped[key]!;
      if (group.isEmpty) {
        continue;
      }
      final first = group.first;
      if (first.fireAt.isAfter(
        KampalaTime.startOfDay(today.toUtcDateTime()).add(
          Duration(days: horizonDays + 1),
        ),
      )) {
        continue;
      }
      reminders.add(_toPlannedReminder(
        group: group,
        farmCount: farmCount,
      ));
      if (reminders.length >= maxReminders) {
        break;
      }
    }

    reminders.sort((a, b) => a.fireAtLocal.compareTo(b.fireAtLocal));
    return reminders.take(maxReminders).toList();
  }

  void _addDueCandidate(
    List<_Candidate> out, {
    required ReminderPlanTask task,
    required CalendarDate fireDate,
    required ReminderKind kind,
    required CalendarDate today,
    required DateTime nowLocal,
    required int reminderTimeMinutes,
    int daysOverdue = 0,
  }) {
    final fireAt = _fireDateTime(fireDate, reminderTimeMinutes);
    final DateTime effectiveFireAt;
    if (fireAt.isAfter(nowLocal)) {
      effectiveFireAt = fireAt;
    } else if (_eligibleForCatchUp(
      fireDate: fireDate,
      today: today,
      kind: kind,
    )) {
      effectiveFireAt = nowLocal.add(
        Duration(seconds: 60 + out.length * 20),
      );
    } else {
      return;
    }
    out.add(
      _Candidate(
        task: task,
        kind: kind,
        fireAt: effectiveFireAt,
        daysOverdue: daysOverdue,
      ),
    );
  }

  bool _eligibleForCatchUp({
    required CalendarDate fireDate,
    required CalendarDate today,
    required ReminderKind kind,
  }) {
    final daysSince = fireDate.daysUntil(today);
    if (daysSince < 0) {
      return false;
    }
    if (daysSince > 7) {
      return false;
    }
    if (kind == ReminderKind.scheduleDue && daysSince > 2) {
      return false;
    }
    return true;
  }

  DateTime _fireDateTime(CalendarDate date, int minutesAfterMidnight) {
    final start = KampalaTime.startOfDay(date.toUtcDateTime());
    return start.add(Duration(minutes: minutesAfterMidnight));
  }

  PlannedReminder _toPlannedReminder({
    required List<_Candidate> group,
    required int farmCount,
  }) {
    final first = group.first;
    final kind = first.kind;
    final farmId = first.task.farmId;
    final fireAt = first.fireAt;
    final id = _notificationId(kind, fireAt, farmId);

    final title = kind == ReminderKind.scheduleOverdue
        ? group.length == 1
            ? '1 task is overdue'
            : '${group.length} tasks are overdue'
        : group.length == 1
            ? '1 task due soon'
            : '${group.length} tasks due soon';

    final lines = group.take(5).map((c) {
      final farmPrefix =
          farmCount > 1 ? '${c.task.farmName}: ' : '';
      if (kind == ReminderKind.scheduleOverdue && c.daysOverdue > 0) {
        return '$farmPrefix${c.task.batchName}: ${c.task.stepLabel}, '
            '${c.daysOverdue} day${c.daysOverdue == 1 ? '' : 's'} overdue';
      }
      return '$farmPrefix${c.task.batchName}: ${c.task.stepLabel}';
    }).toList();
    if (group.length > 5) {
      lines.add('+${group.length - 5} more');
    }
    final body = lines.join('\n');

    final payload = group.length == 1
        ? '/batches/${first.task.batchId}/vaccinations/${first.task.taskId}'
        : kind == ReminderKind.scheduleOverdue
            ? '/today?filter=overdue'
            : '/today';

    final hashPayload = {
      'kind': kind.name,
      'fire': fireAt.toIso8601String(),
      'farm': farmId,
      'tasks': group.map((c) => c.task.taskId).toList(),
      'body': body,
    };
    final contentHash = reminderContentHash(jsonEncode(hashPayload));

    return PlannedReminder(
      notificationId: id,
      kind: kind,
      fireAtLocal: fireAt,
      title: title,
      body: body,
      payload: payload,
      contentHash: contentHash,
      farmId: farmId,
    );
  }

  int _notificationId(ReminderKind kind, DateTime fireAt, String farmId) {
    var hash = Object.hash(kind.name, fireAt.toIso8601String(), farmId) &
        0x7fffffff;
    if (hash == 0) {
      hash = 1;
    }
    return hash;
  }
}

class _Candidate {
  _Candidate({
    required this.task,
    required this.kind,
    required this.fireAt,
    required this.daysOverdue,
  });

  final ReminderPlanTask task;
  final ReminderKind kind;
  final DateTime fireAt;
  final int daysOverdue;
}

String reminderContentHash(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}
