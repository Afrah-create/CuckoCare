import 'package:flutter/material.dart';

/// Typography — system font (offline-first, no runtime download).
abstract final class AppTypography {
  static const fontFamily = null;

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;
    return base.apply(
      fontFamily: fontFamily,
      bodyColor: base.bodyLarge?.color,
      displayColor: base.displayLarge?.color,
    );
  }
}
