enum OverdueReminderMode {
  standard,
  daily,
}

class NotificationPrefs {
  const NotificationPrefs({
    required this.remindersEnabled,
    required this.dueRemindersEnabled,
    required this.overdueRemindersEnabled,
    required this.overdueMode,
    required this.reminderTimeMinutes,
    required this.permissionDenialCount,
  });

  final bool remindersEnabled;
  final bool dueRemindersEnabled;
  final bool overdueRemindersEnabled;
  final OverdueReminderMode overdueMode;
  final int reminderTimeMinutes;
  final int permissionDenialCount;

  static const defaults = NotificationPrefs(
    remindersEnabled: true,
    dueRemindersEnabled: true,
    overdueRemindersEnabled: true,
    overdueMode: OverdueReminderMode.standard,
    reminderTimeMinutes: 420,
    permissionDenialCount: 0,
  );

  NotificationPrefs copyWith({
    bool? remindersEnabled,
    bool? dueRemindersEnabled,
    bool? overdueRemindersEnabled,
    OverdueReminderMode? overdueMode,
    int? reminderTimeMinutes,
    int? permissionDenialCount,
  }) {
    return NotificationPrefs(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      dueRemindersEnabled: dueRemindersEnabled ?? this.dueRemindersEnabled,
      overdueRemindersEnabled:
          overdueRemindersEnabled ?? this.overdueRemindersEnabled,
      overdueMode: overdueMode ?? this.overdueMode,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      permissionDenialCount:
          permissionDenialCount ?? this.permissionDenialCount,
    );
  }
}
