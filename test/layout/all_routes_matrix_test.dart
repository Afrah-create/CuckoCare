import 'dart:io';

import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'route_samples.dart';

void main() {
  final routes = registeredRoutes();

  test('every registered route has a sample', () {
    expect(routes.toSet(), routeSamplePaths);
  });

  final sizes = <Size>[
    const Size(320, 568),
    const Size(360, 800),
    const Size(915, 412),
    const Size(800, 1280),
  ];

  for (final path in routes) {
    for (final size in sizes) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          '$path fits ${size.width.toInt()}x${size.height.toInt()} at text $scale',
          (tester) async {
            await tester.binding.setSurfaceSize(size);
            addTearDown(() => tester.binding.setSurfaceSize(null));

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                builder: (context, child) {
                  return LayoutScope(
                    tokens: tokensFor(size, textScale: scale),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
                home: routeSample(path),
              ),
            );
            await tester.pump();

            expect(tester.takeException(), isNull);
            if (path != '/auth/signup') {
              expect(find.text('Primary action'), findsOneWidget);
            }
          },
        );
      }
    }
  }
}

List<String> registeredRoutes() {
  final sources = [
    File('lib/app/router/routes/typed_routes.dart').readAsStringSync(),
    File('lib/app/router/app_router.dart').readAsStringSync(),
  ].join('\n');
  final paths = <String>{
    ...RegExp(r"path:\s*'(/[^']+)'").allMatches(sources).map((m) => m.group(1)!),
    ...RegExp(r"_fadeTabRoot\(\s*'(/[^']+)'")
        .allMatches(sources)
        .map((m) => m.group(1)!),
    '/batches/:batchId/vaccinations/:taskId',
    '/batches/:batchId/edit',
    '/batches/:batchId/losses',
    '/batches/:batchId/losses/new',
    '/batches/:batchId/losses/:lossId',
  };
  return paths.toList()..sort();
}
