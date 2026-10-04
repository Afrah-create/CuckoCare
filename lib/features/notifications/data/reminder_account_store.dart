import 'package:shared_preferences/shared_preferences.dart';

/// Local account whose schedule backs offline reminders (survives sign-out).
class ReminderAccountStore {
  static const _key = 'reminder_local_account_id';

  Future<String?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    } catch (_) {
      return null;
    }
  }

  Future<void> set(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null || userId.isEmpty) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, userId);
  }
}
