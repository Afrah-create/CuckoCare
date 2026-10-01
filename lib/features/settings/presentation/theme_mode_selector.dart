import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme/theme_context.dart';
import 'theme_mode_provider.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(themeModeProvider);
    final platformDark =
        View.of(context).platformDispatcher.platformBrightness ==
            Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.appearance,
          child: Text(
            l10n.appearance,
            style: context.text.labelLarge?.copyWith(
              color: context.scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.themeSystem),
              icon: const Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.themeLight),
              icon: const Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.themeDark),
              icon: const Icon(Icons.dark_mode),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) {
            ref.read(themeModeProvider.notifier).setMode(selection.first);
          },
        ),
        if (mode == ThemeMode.system) ...[
          const SizedBox(height: 8),
          Text(
            platformDark
                ? l10n.themeSystemHelperDark
                : l10n.themeSystemHelperLight,
            style: context.text.bodySmall?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
