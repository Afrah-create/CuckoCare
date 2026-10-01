import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/features/today/presentation/today_greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(360, 240);

  Future<void> pumpCard(
    WidgetTester tester, {
    required ThemeData theme,
    required String name,
    double textScale = 1.0,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: TodayGreetingCard(
                greeting: 'Good morning, Amina',
                subtitle: "Here's what needs attention on your farm today.",
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(TodayGreetingCard),
      matchesGoldenFile(
        'goldens/today_greeting_${theme.brightness.name}_$name.png',
      ),
    );
  }

  testWidgets('today greeting light 1.0', (tester) async {
    await pumpCard(tester, theme: AppTheme.light, name: 'scale_1_0');
  });

  testWidgets('today greeting dark 1.0', (tester) async {
    await pumpCard(tester, theme: AppTheme.dark, name: 'scale_1_0');
  });
}
