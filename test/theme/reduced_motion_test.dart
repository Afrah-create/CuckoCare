import 'dart:ui';

import 'package:cucocare/app/theme/app_motion.dart';
import 'package:cucocare/app/theme/theme_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('themeAnimationDuration is zero when reduce motion is on', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      () => tester.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    late Duration duration;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          duration = themeAnimationDurationForView(View.of(context));
          return const SizedBox();
        },
      ),
    );

    expect(duration, Duration.zero);
  });

  testWidgets('themeAnimationDuration uses default when motion allowed', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: false);
    addTearDown(
      () => tester.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    late Duration duration;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          duration = themeAnimationDurationForView(View.of(context));
          return const SizedBox();
        },
      ),
    );

    expect(
      duration,
      AppMotion.standard,
    );
  });
}

class FakeAccessibilityFeatures implements AccessibilityFeatures {
  const FakeAccessibilityFeatures({this.disableAnimations = false});

  @override
  final bool disableAnimations;

  @override
  bool get accessibleNavigation => false;

  @override
  bool get boldText => false;

  @override
  bool get highContrast => false;

  @override
  bool get invertColors => false;

  @override
  bool get onOffSwitchLabels => false;

  @override
  bool get reduceMotion => disableAnimations;

  @override
  bool get supportsAnnounce => false;

  @override
  bool get autoPlayAnimatedImages => true;

  @override
  bool get autoPlayVideos => true;

  @override
  bool get deterministicCursor => false;
}
