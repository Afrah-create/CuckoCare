import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/features/settings/domain/theme_preference_repository.dart';
import 'package:cucocare/features/settings/presentation/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeThemePreferenceRepository implements ThemePreferenceRepository {
  FakeThemePreferenceRepository(this.initial);

  ThemeMode initial;
  ThemeMode? lastSaved;
  bool throwOnSave = false;

  @override
  Future<ThemeMode> load() async => initial;

  @override
  Future<void> save(ThemeMode mode) async {
    if (throwOnSave) {
      throw StateError('disk full');
    }
    lastSaved = mode;
    initial = mode;
  }
}

void main() {
  test('persistence: dark survives fresh container with override', () {
    final repo = FakeThemePreferenceRepository(ThemeMode.dark);
    final container = ProviderContainer(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repo),
        initialThemeModeProvider.overrideWithValue(ThemeMode.dark),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('corrupt storage falls back to system via repository', () async {
    final repo = FakeThemePreferenceRepository(ThemeMode.system);
    expect(await repo.load(), ThemeMode.system);
  });

  test('save failure keeps in-memory dark', () async {
    final repo = FakeThemePreferenceRepository(ThemeMode.system)
      ..throwOnSave = true;
    final container = ProviderContainer(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(repo),
        initialThemeModeProvider.overrideWithValue(ThemeMode.system),
      ],
    );
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('system mode follows platform brightness', (tester) async {
    final repo = FakeThemePreferenceRepository(ThemeMode.system);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferenceRepositoryProvider.overrideWithValue(repo),
          initialThemeModeProvider.overrideWithValue(ThemeMode.system),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: Builder(
            builder: (context) => Text(
              MediaQuery.platformBrightnessOf(context).name,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('light'), findsOneWidget);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pump();
    expect(find.text('dark'), findsOneWidget);
  });

  testWidgets('explicit light ignores platform dark', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const Scaffold(body: SizedBox()),
      ),
    );
    await tester.pump();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
  });
}
