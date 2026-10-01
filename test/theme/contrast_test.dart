import 'dart:math' as math;

import 'package:cucocare/app/theme/app_colors.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color fg, Color bg) {
  double lum(Color c) {
    double ch(int v) {
      final s = v / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * ch(c.red) + 0.7152 * ch(c.green) + 0.0722 * ch(c.blue);
  }

  final l1 = lum(fg);
  final l2 = lum(bg);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final scheme = theme.colorScheme;
    final colors = theme.extension<AppColors>()!;

    test('body text contrast ${theme.brightness}', () {
      expect(contrastRatio(scheme.onSurface, scheme.surface), greaterThan(4.5));
      expect(contrastRatio(scheme.onPrimary, scheme.primary), greaterThan(4.5));
    });

    test('status chip contrast ${theme.brightness}', () {
      expect(
        contrastRatio(colors.onTaskOverdue, colors.taskOverdue),
        greaterThan(3.0),
      );
      expect(contrastRatio(colors.onSuccess, colors.success), greaterThan(3.0));
    });
  }
}
