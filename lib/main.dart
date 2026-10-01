import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di/providers.dart';
import 'bootstrap.dart';
import 'features/settings/data/shared_prefs_theme_preference_repository.dart';
import 'features/settings/presentation/theme_mode_provider.dart';
import 'core/config/env.dart';
import 'data_platform/db/app_database.dart';
import 'data_platform/notifications/local_reminder_scheduler.dart';
import 'features/auth/data/auth_snapshot_repository.dart';
import 'data_platform/supabase/offline_first_auth.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = Env.fromEnvironment();
  final db = AppDatabase();
  final reminders = LocalReminderScheduler();

  // Sync providers touch SupabaseRemoteSyncApi at creation time.
  await bootstrapSupabase(env);

  final authSnapshots = AuthSnapshotRepository(db);
  await reconcileSupabaseWithLocalSnapshot(
    hasLocalAuthSnapshot: authSnapshots.hasSnapshot,
  );

  final themeRepo = SharedPrefsThemePreferenceRepository();
  final initialThemeMode = await themeRepo.load();

  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      appDatabaseProvider.overrideWithValue(db),
      themePreferenceRepositoryProvider.overrideWithValue(themeRepo),
      initialThemeModeProvider.overrideWithValue(initialThemeMode),
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
    await container.read(farmProfileIncompleteProvider.future);
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
