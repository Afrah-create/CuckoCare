import 'package:shared_preferences/shared_preferences.dart';

class SplashIntroStorage {
  static const _key = 'hasSeenIntroForVersion';

  Future<bool> shouldPlayFullIntro(String appVersion) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) != appVersion;
  }

  Future<void> markIntroSeen(String appVersion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, appVersion);
  }

  Future<void> clearForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
