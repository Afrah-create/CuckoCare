import 'dart:ui';

import 'app_spacing.dart';

Duration themeAnimationDurationForView(FlutterView view) {
  final disableAnimations =
      view.platformDispatcher.accessibilityFeatures.disableAnimations;
  return disableAnimations
      ? Duration.zero
      : const Duration(milliseconds: AppSpacing.durationThemeMs);
}
