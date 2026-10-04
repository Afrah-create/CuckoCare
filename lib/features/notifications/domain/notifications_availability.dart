import 'notification_prefs.dart';

enum NotificationBlockKind { due, overdue }

sealed class NotificationsAvailability {
  const NotificationsAvailability();
}

class NotificationsOn extends NotificationsAvailability {
  const NotificationsOn();
}

class NotificationsOffInApp extends NotificationsAvailability {
  const NotificationsOffInApp();
}

class NotificationsPermissionNotAsked extends NotificationsAvailability {
  const NotificationsPermissionNotAsked();
}

class NotificationsPermissionDenied extends NotificationsAvailability {
  const NotificationsPermissionDenied();
}

class NotificationsBlockedBySystem extends NotificationsAvailability {
  const NotificationsBlockedBySystem();
}

class NotificationsChannelBlocked extends NotificationsAvailability {
  const NotificationsChannelBlocked(this.kind);

  final NotificationBlockKind kind;
}

NotificationsAvailability resolveNotificationsAvailability({
  required NotificationPrefs prefs,
  required bool osAllowsNotifications,
  required bool permissionDeniedPermanently,
  required bool dueChannelEnabled,
  required bool overdueChannelEnabled,
}) {
  if (!prefs.remindersEnabled) {
    return const NotificationsOffInApp();
  }
  if (!osAllowsNotifications) {
    if (permissionDeniedPermanently || prefs.permissionDenialCount >= 2) {
      return const NotificationsBlockedBySystem();
    }
    if (prefs.permissionDenialCount == 0) {
      return const NotificationsPermissionNotAsked();
    }
    return const NotificationsPermissionDenied();
  }
  if (!dueChannelEnabled) {
    return const NotificationsChannelBlocked(NotificationBlockKind.due);
  }
  if (!overdueChannelEnabled) {
    return const NotificationsChannelBlocked(NotificationBlockKind.overdue);
  }
  return const NotificationsOn();
}

String availabilitySubtitle(NotificationsAvailability availability) {
  return switch (availability) {
    NotificationsOn() => 'On',
    NotificationsOffInApp() => 'Off',
    NotificationsPermissionNotAsked() => 'Permission needed',
    NotificationsPermissionDenied() => 'Permission denied',
    NotificationsBlockedBySystem() => 'Blocked in system settings',
    NotificationsChannelBlocked() => 'Channel blocked in settings',
  };
}
