import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/features/batches/domain/batch_facts.dart';
import 'package:cucocare/features/batches/domain/batch_metrics.dart';
import 'package:cucocare/features/batches/domain/calendar_date.dart';
import 'package:cucocare/features/batches/domain/loss_record.dart';
import 'package:cucocare/features/batches/presentation/batch_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const today = CalendarDate(year: 2026, month: 3, day: 20);

final metrics = BatchMetrics.compute(
  const BatchFacts(
    id: 'b1',
    initialCount: 940,
    acquiredOn: CalendarDate(year: 2026, month: 3, day: 1),
    ageAtAcquisitionDays: 1,
  ),
  [
    LossTally(kind: LossKind.died, occurredOn: today, count: 3),
    LossTally(kind: LossKind.culled, occurredOn: today.addDays(-2), count: 2),
  ],
  today,
);

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('stats card fits a small phone at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: LayoutScope(
              tokens: tokensFor(const Size(320, 568), textScale: scale),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BatchStatsCard(metrics: metrics),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('935'), findsOneWidget);
      expect(find.text('of 940 placed'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Live birds, 935 of 940 placed'),
        findsOneWidget,
      );
    });
  }
}
