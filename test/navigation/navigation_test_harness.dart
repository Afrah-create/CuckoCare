import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/router/app_router.dart';
import 'package:cucocare/app/l10n/app_localizations.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cucocare/core/config/env.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_snapshot_test_stub.dart';

ProviderContainer createNavigationTestContainer({
  required bool authed,
  bool stubAuthSnapshot = true,
}) {
  final db = AppDatabase();
  const env = Env(
    supabaseUrl: 'https://test-project.supabase.co',
    supabaseAnonKey: 'test-anon-key',
    envName: 'test',
  );
  return ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(env),
      appDatabaseProvider.overrideWithValue(db),
      if (stubAuthSnapshot)
        hasAuthSnapshotProvider.overrideWith(
          () => FixedAuthSnapshotNotifier(authed),
        ),
    ],
  );
}

Future<void> pumpCucoRouter(
  WidgetTester tester,
  ProviderContainer container, {
  String initialLocation = '/today',
}) async {
  final router = container.read(appRouterProvider);
  router.go(initialLocation);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) {
          final tokens = tokensFor(MediaQuery.sizeOf(context));
          return LayoutScope(
            tokens: tokens,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}
