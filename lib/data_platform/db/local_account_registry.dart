import 'package:shared_preferences/shared_preferences.dart';

/// Persists which local Drift database to open on cold start (offline gate).
class LocalAccountRegistry {
  LocalAccountRegistry({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const _activeAccountKey = 'active_local_account_id';

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> readActiveAccountId() async {
    final prefs = await _ensurePrefs();
    return prefs.getString(_activeAccountKey);
  }

  Future<void> setActiveAccountId(String? userId) async {
    final prefs = await _ensurePrefs();
    if (userId == null || userId.isEmpty) {
      await prefs.remove(_activeAccountKey);
      return;
    }
    await prefs.setString(_activeAccountKey, userId);
  }
}
