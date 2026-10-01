import 'package:flutter/material.dart';

import 'app_spacing.dart';

abstract final class ComponentThemes {
  static AppBarTheme appBar(ColorScheme scheme) => AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      );

  static NavigationBarThemeData navigationBar(ColorScheme scheme) =>
      NavigationBarThemeData(
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      );

  static NavigationRailThemeData navigationRail(ColorScheme scheme) =>
      NavigationRailThemeData(
        indicatorColor: scheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      );

  static CardThemeData card(ColorScheme scheme) => CardThemeData(
        elevation: AppSpacing.elevationCard,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      );

  static InputDecorationTheme inputDecoration(ColorScheme scheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        constraints: const BoxConstraints(minHeight: AppSpacing.fieldHeight),
      );

  static FilledButtonThemeData filledButton(ColorScheme scheme) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );

  static ListTileThemeData listTile() => ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 4,
        ),
      );

  static DialogThemeData dialog(ColorScheme scheme) => DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        backgroundColor: scheme.surface,
      );

  static BottomSheetThemeData bottomSheet(ColorScheme scheme) =>
      BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      );

  static SnackBarThemeData snackBar(ColorScheme scheme) => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      );

  static ChipThemeData chip(ColorScheme scheme) => ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        side: BorderSide(color: scheme.outlineVariant),
      );

  static DividerThemeData divider(ColorScheme scheme) => DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        space: 1,
      );

  static ProgressIndicatorThemeData progress(ColorScheme scheme) =>
      ProgressIndicatorThemeData(color: scheme.primary);

  static PageTransitionsTheme pageTransitions() => const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      );
}
