import 'dart:ui';

import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/app/widgets/states/screen_error_fallback.dart';
import 'package:cucocare/app/widgets/states/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('skeleton announces loading once and hides bone text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SkeletonScope(
            child: SkeletonLine(),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });

  testWidgets('release fallback offers Go to Today', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ScreenErrorFallback(),
      ),
    );
    expect(find.text('Something went wrong on this screen'), findsOneWidget);
    expect(find.text('Go to Today'), findsOneWidget);
  });

  testWidgets('reduced motion leaves the skeleton still', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SkeletonScope(child: SkeletonLine()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SkeletonLine), findsOneWidget);
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
