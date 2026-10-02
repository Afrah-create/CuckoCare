import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di/providers.dart';
import 'bootstrap.dart';
import 'features/settings/data/shared_prefs_theme_preference_repository.dart';
import 'features/settings/presentation/theme_mode_provider.dart';
import 'core/config/env.dart';
import 'data_platform/db/account_session.dart';
import 'data_platform/db/launch_account_resolver.dart';
import 'data_platform/db/legacy_database_migrator.dart';
import 'data_platform/db/local_account_registry.dart';
import 'data_platform/notifications/local_reminder_scheduler.dart';
import 'features/auth/data/auth_snapshot_repository.dart';
import 'data_platform/supabase/offline_first_auth.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = Env.fromEnvironment();
  final registry = LocalAccountRegistry();
  final reminders = LocalReminderScheduler();

  await bootstrapSupabase(env);

  final launchUserId = await resolveLaunchAccountUserId(registry);
  await migrateLegacySharedDatabaseIfNeeded(activeUserId: launchUserId);

  final themeRepo = SharedPrefsThemePreferenceRepository();
  final initialThemeMode = await themeRepo.load();

  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      initialAccountUserIdProvider.overrideWithValue(launchUserId),
      localAccountRegistryProvider.overrideWithValue(registry),
      themePreferenceRepositoryProvider.overrideWithValue(themeRepo),
      initialThemeModeProvider.overrideWithValue(initialThemeMode),
    ],
  );

  await reconcileSupabaseWithLocalSnapshot(
    hasLocalAuthSnapshot: () =>
        AuthSnapshotRepository(container.read(appDatabaseProvider)).hasSnapshot(),
  );

  await bootstrap(
    env: env,
    db: container.read(appDatabaseProvider),
    syncScheduler: container.read(syncSchedulerProvider),
    reminders: reminders,
    initializeSupabase: false,
  );

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
