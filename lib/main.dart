import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di/providers.dart';
import 'bootstrap.dart';
import 'core/config/env.dart';
import 'data_platform/db/app_database.dart';
import 'data_platform/notifications/local_reminder_scheduler.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = Env.fromEnvironment();
  final db = AppDatabase();
  final reminders = LocalReminderScheduler();

  // Sync providers touch SupabaseRemoteSyncApi at creation time.
  await bootstrapSupabase(env);

  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      appDatabaseProvider.overrideWithValue(db),
    ],
  );

  await bootstrap(
    env: env,
    db: db,
    syncScheduler: container.read(syncSchedulerProvider),
    reminders: reminders,
    initializeSupabase: false,
  );

  // Resolve auth before first frame so routing is not stuck on splash.
  try {
    await container.read(hasAuthSnapshotProvider.future);
  } catch (_) {
    // Router sends users to login when snapshot read fails.
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CucoCareApp(),
    ),
  );
}
