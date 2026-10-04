import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/brand_palette.dart';
import '../../core/time/kampala_time.dart';
import '../../features/notifications/domain/notification_channels.dart';
import '../../features/notifications/domain/planned_reminder.dart';
import '../../core/platform/system_settings_channel.dart';
import 'notification_payload_codec.dart';
import 'notifications_gateway.dart';

class FlutterLocalNotificationsGateway implements NotificationsGateway {
  FlutterLocalNotificationsGateway({
    FlutterLocalNotificationsPlugin? plugin,
    SystemSettingsChannel? systemSettings,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _systemSettings = systemSettings ?? SystemSettingsChannel();

  final FlutterLocalNotificationsPlugin _plugin;
  final SystemSettingsChannel _systemSettings;

  static const AndroidNotificationChannel _dueChannel =
      AndroidNotificationChannel(
    NotificationChannels.scheduleDue,
    'Schedule reminders',
    description: 'Reminders when vaccinations and tasks are due',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _overdueChannel =
      AndroidNotificationChannel(
    NotificationChannels.scheduleOverdue,
    'Overdue tasks',
    description: 'Reminders when tasks are overdue',
    importance: Importance.high,
  );

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {
    KampalaTime.ensureInitialized();
    tz.setLocalLocation(KampalaTime.location);

    const android = AndroidInitializationSettings('@drawable/ic_stat_hen');

    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (details) {
        onTap?.call(details.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_dueChannel);
    await androidPlugin?.createNotificationChannel(_overdueChannel);
  }

  @override
  Future<String?> notificationLaunchRoute() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) {
      return null;
    }
    return decodeNotificationRoute(details!.notificationResponse?.payload);
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return true;
    }
    return (await android.areNotificationsEnabled()) ?? true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return true;
    }
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<NotificationChannelState> channelState(String channelId) async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return NotificationChannelState.enabled;
    }
    final channels = await android.getNotificationChannels();
    final match = channels?.where((c) => c.id == channelId).firstOrNull;
    if (match == null) {
      return NotificationChannelState.enabled;
    }
    if (match.importance == Importance.none) {
      return NotificationChannelState.blocked;
    }
    return NotificationChannelState.enabled;
  }

  @override
  Future<List<ScheduledNotificationSnapshot>> scheduled() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((p) {
      return ScheduledNotificationSnapshot(
        id: p.id,
        contentHash: decodeNotificationContentHash(p.payload) ?? '',
      );
    }).toList();
  }

  @override
  Future<void> schedule(PlannedReminder reminder) async {
    final channel = reminder.kind == ReminderKind.scheduleDue
        ? _dueChannel
        : _overdueChannel;

    final payload = encodeNotificationPayload(
      routePath: reminder.payload,
      contentHash: reminder.contentHash,
    );

    final scheduled = tz.TZDateTime.from(
      reminder.fireAtLocal,
      KampalaTime.location,
    );

    await _plugin.zonedSchedule(
      id: reminder.notificationId,
      title: reminder.title,
      body: reminder.body,
      scheduledDate: scheduled,
      payload: payload,
      notificationDetails: NotificationDetails(
        android: _androidDetails(
          channel: channel,
          styleInformation: InboxStyleInformation(
            reminder.body.split('\n'),
            contentTitle: reminder.title,
          ),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  AndroidNotificationDetails _androidDetails({
    required AndroidNotificationChannel channel,
    StyleInformation? styleInformation,
  }) {
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: 'ic_stat_hen',
      color: BrandPalette.brandInk,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInformation,
    );
  }

  @override
  Future<void> openAppNotificationSettings() =>
      _systemSettings.openAppNotificationSettings();

  @override
  Future<void> openChannelSettings(String channelId) =>
      _systemSettings.openChannelSettings(channelId);

  @override
  Future<void> openBatteryOptimizationSettings() =>
      _systemSettings.openBatteryOptimizationSettings();

  @override
  Future<bool> isIgnoringBatteryOptimizations() =>
      _systemSettings.isIgnoringBatteryOptimizations();
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) {
      return null;
    }
    return it.current;
  }
}
