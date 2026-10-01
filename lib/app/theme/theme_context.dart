import 'package:flutter/material.dart';

import 'app_colors.dart';

extension ThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
