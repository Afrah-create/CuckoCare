import 'dart:ui';

import 'app_motion.dart';

Duration themeAnimationDurationForView(FlutterView view) {
  final disableAnimations =
      view.platformDispatcher.accessibilityFeatures.disableAnimations;
  return disableAnimations ? AppMotion.instant : AppMotion.standard;
}
