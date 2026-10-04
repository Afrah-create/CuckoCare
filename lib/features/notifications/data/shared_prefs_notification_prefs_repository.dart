import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_prefs.dart';
import '../domain/notification_prefs_repository.dart';

class SharedPrefsNotificationPrefsRepository
    implements NotificationPrefsRepository {
  static const _prefix = 'notification_prefs.';

  static const _remindersEnabled = '${_prefix}reminders_enabled';
  static const _dueEnabled = '${_prefix}due_enabled';
  static const _overdueEnabled = '${_prefix}overdue_enabled';
  static const _overdueMode = '${_prefix}overdue_mode';
  static const _reminderTime = '${_prefix}reminder_time_minutes';
  static const _denialCount = '${_prefix}permission_denial_count';

  @override
  Future<NotificationPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return NotificationPrefs(
        remindersEnabled: prefs.getBool(_remindersEnabled) ?? true,
        dueRemindersEnabled: prefs.getBool(_dueEnabled) ?? true,
        overdueRemindersEnabled: prefs.getBool(_overdueEnabled) ?? true,
        overdueMode: _parseMode(prefs.getString(_overdueMode)),
        reminderTimeMinutes: _clampMinutes(
          prefs.getInt(_reminderTime) ?? NotificationPrefs.defaults.reminderTimeMinutes,
        ),
        permissionDenialCount: prefs.getInt(_denialCount) ?? 0,
      );
    } catch (_) {
      return NotificationPrefs.defaults;
    }
  }

  @override
  Future<void> save(NotificationPrefs prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_remindersEnabled, prefs.remindersEnabled);
    await sp.setBool(_dueEnabled, prefs.dueRemindersEnabled);
    await sp.setBool(_overdueEnabled, prefs.overdueRemindersEnabled);
    await sp.setString(_overdueMode, prefs.overdueMode.name);
    await sp.setInt(_reminderTime, prefs.reminderTimeMinutes);
    await sp.setInt(_denialCount, prefs.permissionDenialCount);
  }

  OverdueReminderMode _parseMode(String? raw) {
    return switch (raw) {
      'daily' => OverdueReminderMode.daily,
      'standard' => OverdueReminderMode.standard,
      _ => OverdueReminderMode.standard,
    };
  }

  int _clampMinutes(int value) {
    if (value < 0) {
      return 0;
    }
    if (value > 23 * 60 + 59) {
      return 23 * 60 + 59;
    }
    return value;
  }
}
