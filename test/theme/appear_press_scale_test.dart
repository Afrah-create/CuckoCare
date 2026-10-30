import 'package:cucocare/app/widgets/motion/appear.dart';
import 'package:cucocare/app/widgets/motion/press_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide FakeAccessibilityFeatures;

import 'reduced_motion_test.dart';

void main() {
  testWidgets('Appear paints the child immediately when motion is reduced', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      () => tester.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    const appearKey = Key('appear');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Appear(key: appearKey, child: Text('flock')),
        ),
      ),
    );

    expect(find.text('flock'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(appearKey),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('Appear uses a fade when motion is allowed', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    addTearDown(
      () => tester.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    const appearKey = Key('appear');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Appear(key: appearKey, child: Text('flock')),
        ),
      ),
    );

    expect(find.text('flock'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(appearKey),
        matching: find.byType(FadeTransition),
      ),
      findsOneWidget,
    );
  });

  testWidgets('PressScale stays at 1.0 when motion is reduced', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      () => tester.platformDispatcher.clearAccessibilityFeaturesTestValue(),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PressScale(child: SizedBox(width: 80, height: 80)),
        ),
      ),
    );

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1.0);
    expect(scale.duration, Duration.zero);
  });
}
