import 'package:cucocare/app/theme/app_colors.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/app/theme/theme_context.dart';
import 'package:cucocare/app/widgets/status_chip.dart';
import 'package:cucocare/features/settings/domain/theme_preference_repository.dart';
import 'package:cucocare/features/settings/presentation/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoOpThemeRepo implements ThemePreferenceRepository {
  @override
  Future<ThemeMode> load() async => ThemeMode.light;

  @override
  Future<void> save(ThemeMode mode) async {}
}

void main() {
  testWidgets('themeMode on MaterialApp recolours scaffold and tokens', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        themePreferenceRepositoryProvider.overrideWithValue(_NoOpThemeRepo()),
        initialThemeModeProvider.overrideWithValue(ThemeMode.light),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: Builder(
                builder: (context) {
                  final c = context.colors;
                  return Scaffold(
                    appBar: AppBar(title: const Text('T')),
                    body: Column(
                      children: [
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Go'),
                        ),
                        StatusChip(
                          label: 'Overdue',
                          icon: Icons.warning,
                          background: c.taskOverdue,
                          foreground: c.onTaskOverdue,
                        ),
                      ],
                    ),
                    bottomNavigationBar: NavigationBar(
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.settings),
                          label: 'More',
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final lightSurface = Theme.of(
      tester.element(find.byType(Scaffold)),
    ).colorScheme.surface;

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    final darkSurface = Theme.of(
      tester.element(find.byType(Scaffold)),
    ).colorScheme.surface;

    expect(lightSurface, isNot(equals(darkSurface)));

    final colors = Theme.of(tester.element(find.byType(Scaffold)))
        .extension<AppColors>()!;
    expect(colors.taskOverdue, AppColors.dark.taskOverdue);
  });
}
