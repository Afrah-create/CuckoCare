import '../../features/notifications/domain/planned_reminder.dart';

enum NotificationChannelState { enabled, disabled, blocked }

class ScheduledNotificationSnapshot {
  const ScheduledNotificationSnapshot({
    required this.id,
    required this.contentHash,
  });

  final int id;
  final String contentHash;
}

abstract class NotificationsGateway {
  Future<void> initialize({void Function(String? payload)? onTap});

  /// Route path if the app was opened from a notification tap (cold start).
  Future<String?> notificationLaunchRoute();

  Future<bool> areNotificationsEnabled();

  Future<bool> requestPermission();

  Future<NotificationChannelState> channelState(String channelId);

  Future<List<ScheduledNotificationSnapshot>> scheduled();

  Future<void> schedule(PlannedReminder reminder);

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<void> openAppNotificationSettings();

  Future<void> openChannelSettings(String channelId);

  Future<void> openBatteryOptimizationSettings();

  Future<bool> isIgnoringBatteryOptimizations();
}
