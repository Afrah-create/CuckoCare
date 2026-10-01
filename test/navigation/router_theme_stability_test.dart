import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/app/router/app_router.dart';
import 'package:cucocare/core/config/env.dart';
import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:cucocare/features/settings/domain/theme_preference_repository.dart';
import 'package:cucocare/features/settings/presentation/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_snapshot_test_stub.dart';

class _NoOpThemeRepo implements ThemePreferenceRepository {
  @override
  Future<ThemeMode> load() async => ThemeMode.system;

  @override
  Future<void> save(ThemeMode mode) async {}
}

void main() {
  test('GoRouter instance is stable when theme mode changes', () {
    final db = AppDatabase();
    const env = Env(
      supabaseUrl: 'https://test-project.supabase.co',
      supabaseAnonKey: 'test-anon-key',
      envName: 'test',
    );
    final container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(env),
        appDatabaseProvider.overrideWithValue(db),
        hasAuthSnapshotProvider.overrideWith(
          () => FixedAuthSnapshotNotifier(true),
        ),
        themePreferenceRepositoryProvider.overrideWithValue(_NoOpThemeRepo()),
        initialThemeModeProvider.overrideWithValue(ThemeMode.light),
      ],
    );
    addTearDown(container.dispose);

    final routerBefore = container.read(appRouterProvider);
    container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    final routerAfter = container.read(appRouterProvider);

    expect(identical(routerBefore, routerAfter), isTrue);
  });
}
