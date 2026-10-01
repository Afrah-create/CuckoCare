import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'brand_palette.dart';
import 'component_themes.dart';

/// Cached [ThemeData] for light and dark — built once.
abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light, AppColors.light);
  static final ThemeData dark = _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final scheme = brightness == Brightness.light
        ? ColorScheme.fromSeed(
            seedColor: BrandPalette.seedLight,
            brightness: Brightness.light,
            surface: BrandPalette.brandCream,
          )
        : ColorScheme.fromSeed(
            seedColor: BrandPalette.seedDark,
            brightness: Brightness.dark,
            surface: BrandPalette.splashDark,
            onSurface: const Color(0xFFE8E0DA),
          );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? scheme.surfaceContainerLowest
          : BrandPalette.splashDark,
      textTheme: AppTypography.textTheme(brightness),
      extensions: [colors],
      appBarTheme: ComponentThemes.appBar(scheme),
      navigationBarTheme: ComponentThemes.navigationBar(scheme),
      navigationRailTheme: ComponentThemes.navigationRail(scheme),
      cardTheme: ComponentThemes.card(scheme),
      inputDecorationTheme: ComponentThemes.inputDecoration(scheme),
      filledButtonTheme: ComponentThemes.filledButton(scheme),
      listTileTheme: ComponentThemes.listTile(),
      dialogTheme: ComponentThemes.dialog(scheme),
      bottomSheetTheme: ComponentThemes.bottomSheet(scheme),
      snackBarTheme: ComponentThemes.snackBar(scheme),
      chipTheme: ComponentThemes.chip(scheme),
      dividerTheme: ComponentThemes.divider(scheme),
      progressIndicatorTheme: ComponentThemes.progress(scheme),
      pageTransitionsTheme: ComponentThemes.pageTransitions(),
    );
  }
}

/// @deprecated Use [AppTheme.light] / [AppTheme.dark].
ThemeData buildAppTheme({Brightness brightness = Brightness.light}) =>
    brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
