import 'package:cucocare/features/notifications/domain/notification_prefs.dart';
import 'package:cucocare/features/notifications/domain/notifications_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('off in app when master switch disabled', () {
    final state = resolveNotificationsAvailability(
      prefs: NotificationPrefs.defaults.copyWith(remindersEnabled: false),
      osAllowsNotifications: true,
      permissionDeniedPermanently: false,
      dueChannelEnabled: true,
      overdueChannelEnabled: true,
    );
    expect(state, isA<NotificationsOffInApp>());
  });

  test('second denial maps to blocked by system', () {
    final state = resolveNotificationsAvailability(
      prefs: NotificationPrefs.defaults.copyWith(permissionDenialCount: 2),
      osAllowsNotifications: false,
      permissionDeniedPermanently: false,
      dueChannelEnabled: true,
      overdueChannelEnabled: true,
    );
    expect(state, isA<NotificationsBlockedBySystem>());
  });

  test('channel blocked when overdue channel disabled', () {
    final state = resolveNotificationsAvailability(
      prefs: NotificationPrefs.defaults,
      osAllowsNotifications: true,
      permissionDeniedPermanently: false,
      dueChannelEnabled: true,
      overdueChannelEnabled: false,
    );
    expect(state, isA<NotificationsChannelBlocked>());
  });
}
