import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shared_prefs_theme_preference_repository.dart';
import '../domain/theme_preference_repository.dart';

final themePreferenceRepositoryProvider = Provider<ThemePreferenceRepository>(
  (ref) => SharedPrefsThemePreferenceRepository(),
);

/// Injected before [runApp] so the first frame uses the saved mode.
final initialThemeModeProvider = Provider<ThemeMode>(
  (ref) => ThemeMode.system,
);

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(themePreferenceRepositoryProvider).save(mode);
    } catch (_) {
      // Keep optimistic in-memory choice; persistence is best-effort.
    }
  }
}
