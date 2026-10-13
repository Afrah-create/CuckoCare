import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'core/platform/supported_orientations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import 'core/time/clock.dart';
import 'core/time/kampala_time.dart';
import 'core/logging/app_logger.dart';
import 'package:workmanager/workmanager.dart';

import 'core/config/env.dart';
import 'data_platform/db/app_database.dart';
import 'data_platform/notifications/flutter_local_notifications_gateway.dart';
import 'data_platform/notifications/reminder_reconciler.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';
import 'data_platform/sync/sync_scheduler.dart';
import 'features/notifications/data/shared_prefs_notification_prefs_repository.dart';
import 'features/vaccination/data/seed_programme_loader.dart';
import 'features/notifications/data/reminder_account_store.dart';

const backgroundSyncTask = 'cucocare.sync';

/// Runs every 12 hours without requiring a network connection.
/// Reconciles scheduled notifications so reminders stay current even
/// when the app hasn't been opened for several days.
const backgroundReminderTask = 'cucocare.reminders';

@pragma('vm:entry-point')
void workmanagerCallback() {
  Workmanager().executeTask((task, _) async {
    try {
      if (task == backgroundSyncTask) {
        // Best-effort; foreground sync is primary.
        return true;
      }

      if (task == backgroundReminderTask) {
        return await _reconcileRemindersBackground();
      }
    } catch (error, stack) {
      appLogger.e(
        'Background task $task failed',
        error: error,
        stackTrace: stack,
      );
    }
    return false;
  });
}

/// Reconciles scheduled notifications from a background isolate.
/// Runs without Flutter widgets or Supabase — reads Drift + SharedPrefs only.
Future<bool> _reconcileRemindersBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  KampalaTime.ensureInitialized();

  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  } catch (_) {
    tz.setLocalLocation(KampalaTime.location);
  }

  final accountStore = ReminderAccountStore();
  final accountId = await accountStore.read();

  // If no account is stored, there's nothing to schedule.
  if (accountId == null || accountId.isEmpty) {
    return true;
  }

  final db = AppDatabase.forAccount(accountId);
  final gateway = FlutterLocalNotificationsGateway();
  await gateway.initialize();

  final prefsRepo = SharedPrefsNotificationPrefsRepository();
  final clock = SystemClock();

  final reconciler = ReminderReconciler(
    gateway: gateway,
    prefsRepository: prefsRepo,
    db: () => db,
    clock: clock,
    reminderAccountId: () async => accountId,
    debounce: Duration.zero,
  );

  try {
    await reconciler.reconcile();
  } finally {
    disposeAppDatabase(db);
  }

  return true;
}

Future<void> bootstrap({
  required Env env,
  required AppDatabase db,
  required SyncScheduler syncScheduler,
  Clock? clock,
  bool initializeSupabase = true,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(kSupportedOrientations);

  KampalaTime.ensureInitialized();
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  } catch (_) {
    tz.setLocalLocation(KampalaTime.location);
  }

  if (initializeSupabase) {
    await bootstrapSupabase(env);
  }
  await SeedProgrammeLoader(db, clock ?? SystemClock()).loadIfEmpty();

  await syncScheduler.start();

  await Workmanager().initialize(workmanagerCallback);

  // Network-gated sync — every 6 hours.
  await Workmanager().registerPeriodicTask(
    backgroundSyncTask,
    backgroundSyncTask,
    frequency: const Duration(hours: 6),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // Notification reconciliation — every 12 hours, no network required.
  // Ensures reminders stay current even if the app hasn't been opened.
  await Workmanager().registerPeriodicTask(
    backgroundReminderTask,
    backgroundReminderTask,
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
