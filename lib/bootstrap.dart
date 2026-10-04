import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'core/platform/supported_orientations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

import 'core/time/kampala_time.dart';
import 'package:workmanager/workmanager.dart';

import 'core/config/env.dart';
import 'core/time/clock.dart';
import 'data_platform/db/app_database.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';
import 'data_platform/sync/sync_scheduler.dart';
import 'features/vaccination/data/seed_programme_loader.dart';

const backgroundSyncTask = 'cucocare.sync';

@pragma('vm:entry-point')
void workmanagerCallback() {
  Workmanager().executeTask((task, _) async {
    if (task == backgroundSyncTask) {
      // Best-effort; foreground sync is primary.
      return true;
    }
    return false;
  });
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
  await Workmanager().registerPeriodicTask(
    backgroundSyncTask,
    backgroundSyncTask,
    frequency: const Duration(hours: 6),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
