import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/router/app_router.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/core/config/env.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer createNavigationTestContainer({required bool authed}) {
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
      hasAuthSnapshotProvider.overrideWith((ref) async => authed),
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
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
