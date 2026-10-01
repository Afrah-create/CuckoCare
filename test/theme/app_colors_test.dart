import 'package:cucocare/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppColors lerp endpoints match light and dark', () {
    expect(
      AppColors.light.lerp(AppColors.dark, 0)!.taskOverdue,
      AppColors.light.taskOverdue,
    );
    expect(
      AppColors.light.lerp(AppColors.dark, 1)!.taskOverdue,
      AppColors.dark.taskOverdue,
    );
  });

  test('copyWith overrides a single field', () {
    final copy = AppColors.light.copyWith(syncIdle: const Color(0xFFABCDEF));
    expect(copy.syncIdle, const Color(0xFFABCDEF));
    expect(copy.syncOffline, AppColors.light.syncOffline);
  });

  test('both themes define every semantic token non-transparent where needed', () {
    for (final colors in [AppColors.light, AppColors.dark]) {
      expect(colors.logoTint.alpha, greaterThan(0));
      expect(colors.splashBackground.alpha, greaterThan(0));
      expect(colors.taskOverdue.alpha, greaterThan(0));
      expect(colors.syncError.alpha, greaterThan(0));
    }
  });
}
