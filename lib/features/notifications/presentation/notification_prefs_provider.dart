import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../data_platform/db/account_session.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../app/router/deep_link_handler.dart';
import '../../../data_platform/notifications/notifications_gateway.dart';
import '../domain/notification_channels.dart';
import '../../../data_platform/notifications/notification_payload_codec.dart';
import '../../../data_platform/notifications/reminder_reconciler.dart';
import '../data/shared_prefs_notification_prefs_repository.dart';
import 'reminder_account_providers.dart';
import '../domain/notification_prefs.dart';
import '../domain/notification_prefs_repository.dart';
import '../domain/notifications_availability.dart';

final notificationsGatewayProvider = Provider<NotificationsGateway>(
  (ref) => throw UnimplementedError('Override before runApp'),
);

final notificationPrefsRepositoryProvider =
    Provider<NotificationPrefsRepository>(
  (ref) => SharedPrefsNotificationPrefsRepository(),
);

final initialNotificationPrefsProvider = Provider<NotificationPrefs>(
  (ref) => NotificationPrefs.defaults,
);

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() => ref.watch(initialNotificationPrefsProvider);

  Future<void> update(NotificationPrefs next) async {
    state = next;
    try {
      await ref.read(notificationPrefsRepositoryProvider).save(next);
    } catch (_) {}
    ref.read(reminderReconcilerProvider).scheduleReconcile();
  }
}

final reminderReconciliationDatabaseProvider = Provider<AppDatabase>((ref) {
  final reminderId = ref.watch(reminderAccountUserIdProvider);
  final sessionId = ref.watch(accountSessionProvider);
  if (reminderId != null && reminderId == sessionId) {
    return ref.watch(appDatabaseProvider);
  }
  final db = AppDatabase.forAccount(reminderId);
  ref.onDispose(() => disposeAppDatabase(db));
  return db;
});

final reminderReconcilerProvider = Provider<ReminderReconciler>((ref) {
  final reconciler = ReminderReconciler(
    gateway: ref.watch(notificationsGatewayProvider),
    prefsRepository: ref.watch(notificationPrefsRepositoryProvider),
    db: () => ref.read(reminderReconciliationDatabaseProvider),
    clock: ref.watch(clockProvider),
    reminderAccountId: () async => ref.read(reminderAccountUserIdProvider),
  );
  ref.onDispose(() {});
  return reconciler;
});

final notificationsAvailabilityProvider =
    FutureProvider<NotificationsAvailability>((ref) async {
  final prefs = ref.watch(notificationPrefsProvider);
  final gateway = ref.watch(notificationsGatewayProvider);
  final osAllows = await gateway.areNotificationsEnabled();
  final dueChannel = await gateway.channelState(
    NotificationChannels.scheduleDue,
  );
  final overdueChannel = await gateway.channelState(
    NotificationChannels.scheduleOverdue,
  );
  return resolveNotificationsAvailability(
    prefs: prefs,
    osAllowsNotifications: osAllows,
    permissionDeniedPermanently: prefs.permissionDenialCount >= 2,
    dueChannelEnabled: dueChannel != NotificationChannelState.blocked,
    overdueChannelEnabled: overdueChannel != NotificationChannelState.blocked,
  );
});

final nextPlannedReminderProvider = FutureProvider<String>((ref) async {
  final prefs = ref.watch(notificationPrefsProvider);
  final plan =
      await ref.read(reminderReconcilerProvider).previewPlan(prefs);
  if (plan.isEmpty) {
    return 'No reminders scheduled';
  }
  final first = plan.first;
  final time = _formatMinutes(prefs.reminderTimeMinutes);
  final day = _formatDay(first.fireAtLocal);
  final summary = first.title;
  return 'Next reminder: $day $time · $summary';
});

String _formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final hour12 = h % 12 == 0 ? 12 : h % 12;
  if (m == 0) {
    return '$hour12:00 $period';
  }
  return '$hour12:${m.toString().padLeft(2, '0')} $period';
}

String _formatDay(DateTime utcInstant) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[utcInstant.toUtc().weekday - 1];
}

void enqueueNotificationDeepLink(WidgetRef ref, String? payload) {
  final route = decodeNotificationRoute(payload);
  if (route != null) {
    ref.read(deepLinkHandlerProvider).enqueue(route);
  }
}
