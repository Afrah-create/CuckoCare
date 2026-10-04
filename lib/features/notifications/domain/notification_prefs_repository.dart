import 'notification_prefs.dart';

abstract class NotificationPrefsRepository {
  Future<NotificationPrefs> load();

  Future<void> save(NotificationPrefs prefs);
}
