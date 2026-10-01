import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app/theme/brand_palette.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/time/kampala_time.dart';
import 'reminder_scheduler.dart';

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'vaccination_reminders',
    'Vaccination reminders',
    description: 'Due vaccination notifications for your flocks',
    importance: Importance.defaultImportance,
  );

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@drawable/ic_stat_hen');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> reconcile({int maxScheduled = 50}) async {
    // Scaffold: scheduling hooks; tasks loaded from Drift in a later feature pass.
    final unused = maxScheduled;
    final location = KampalaTime.location;
    tz.setLocalLocation(location);
    assert(unused >= 0);
  }

  Future<void> scheduleInexact({
    required int id,
    required String title,
    required String body,
    required DateTime whenUtc,
  }) async {
    final scheduled = tz.TZDateTime.from(whenUtc, KampalaTime.location);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: 'ic_stat_hen',
          color: BrandPalette.brandInk,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
