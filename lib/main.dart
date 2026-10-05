import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/di/providers.dart';
import 'app/widgets/states/install_error_handlers.dart';
import 'bootstrap.dart';
import 'features/settings/data/shared_prefs_theme_preference_repository.dart';
import 'features/settings/presentation/theme_mode_provider.dart';
import 'core/config/env.dart';
import 'data_platform/db/account_session.dart';
import 'data_platform/db/launch_account_resolver.dart';
import 'data_platform/db/legacy_database_migrator.dart';
import 'data_platform/db/local_account_registry.dart';
import 'app/router/app_router.dart';
import 'app/router/deep_link_handler.dart';
import 'data_platform/notifications/flutter_local_notifications_gateway.dart';
import 'data_platform/notifications/notification_payload_codec.dart';
import 'features/notifications/data/reminder_account_store.dart';
import 'features/notifications/data/shared_prefs_notification_prefs_repository.dart';
import 'features/notifications/presentation/notification_prefs_provider.dart';
import 'features/notifications/presentation/reminder_account_providers.dart';
import 'features/auth/data/auth_snapshot_repository.dart';
import 'data_platform/supabase/offline_first_auth.dart';
import 'data_platform/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers();

  final env = Env.fromEnvironment();
  final registry = LocalAccountRegistry();
  final notificationsGateway = FlutterLocalNotificationsGateway();
  final notificationPrefsRepo = SharedPrefsNotificationPrefsRepository();
  final initialNotificationPrefs = await notificationPrefsRepo.load();
  final reminderAccountStore = ReminderAccountStore();

  await bootstrapSupabase(env);

  final launchUserId = await resolveLaunchAccountUserId(registry);
  final initialReminderAccountId =
      await reminderAccountStore.read() ?? launchUserId;
  if (initialReminderAccountId != null &&
      await reminderAccountStore.read() == null) {
    await reminderAccountStore.set(initialReminderAccountId);
  }
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
      notificationsGatewayProvider.overrideWithValue(notificationsGateway),
      notificationPrefsRepositoryProvider.overrideWithValue(
        notificationPrefsRepo,
      ),
      initialNotificationPrefsProvider.overrideWithValue(
        initialNotificationPrefs,
      ),
      initialReminderAccountUserIdProvider.overrideWithValue(
        initialReminderAccountId,
      ),
    ],
  );

  await notificationsGateway.initialize(
    onTap: (payload) {
      final route = decodeNotificationRoute(payload);
      container.read(deepLinkHandlerProvider).enqueue(route);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          container.read(deepLinkHandlerProvider).flush(
                container.read(appRouterProvider),
              ),
        );
      });
    },
  );

  final launchRoute = await notificationsGateway.notificationLaunchRoute();
  if (launchRoute != null) {
    container.read(deepLinkHandlerProvider).enqueue(launchRoute);
  }

  await reconcileSupabaseWithLocalSnapshot(
    hasLocalAuthSnapshot: () =>
        AuthSnapshotRepository(container.read(appDatabaseProvider)).hasSnapshot(),
  );

  await bootstrap(
    env: env,
    db: container.read(appDatabaseProvider),
    syncScheduler: container.read(syncSchedulerProvider),
    initializeSupabase: false,
  );

  container.read(reminderReconcilerProvider).scheduleReconcile();

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

  if (launchRoute != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        container.read(deepLinkHandlerProvider).flush(
              container.read(appRouterProvider),
            ),
      );
    });
  }
}
