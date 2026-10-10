import 'package:cucocare/app/layout/adaptive.dart';
import 'package:cucocare/app/layout/layout_inspector.dart';
import 'package:cucocare/app/layout/layout_profile.dart';
import 'package:cucocare/app/layout/layout_scope.dart';
import 'package:cucocare/app/layout/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'device_profiles.dart';

void main() {
  test('width classes follow the breakpoint table', () {
    expect(widthClassFor(320), WidthClass.narrow);
    expect(widthClassFor(360), WidthClass.compact);
    expect(widthClassFor(600), WidthClass.medium);
    expect(widthClassFor(840), WidthClass.expanded);
    expect(widthClassFor(1200), WidthClass.large);
  });

  test('profile comes from the full window, not orientation', () {
    expect(layoutProfileFor(const Size(412, 915)), LayoutProfile.phonePortrait);
    expect(layoutProfileFor(const Size(915, 412)), LayoutProfile.phoneLandscape);
    expect(layoutProfileFor(const Size(800, 1280)), LayoutProfile.tablet);
    expect(layoutProfileFor(const Size(300, 500)), LayoutProfile.cramped);
  });

  test('columnsFor uses fewer columns for large text', () {
    final phone = tokensFor(const Size(800, 360));
    final large = tokensFor(const Size(800, 360), textScale: 2);
    expect(large.columnsFor(800), lessThan(phone.columnsFor(800)));
  });

  test('form width is full on a phone and capped on a tablet', () {
    expect(
      tokensFor(const Size(360, 800)).maxWidthFor(PageLayout.form),
      double.infinity,
    );
    expect(
      tokensFor(const Size(800, 1280)).maxWidthFor(PageLayout.form),
      640,
    );
  });

  test('every catalogue size resolves a profile', () {
    for (final device in deviceProfiles) {
      expect(tokensFor(device.size).profile, isNotNull);
    }
  });

  testWidgets('LayoutScope does not notify for a resize inside one class', (
    tester,
  ) async {
    _leafBuilds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LayoutScope(
          tokens: tokensFor(const Size(400, 800)),
          child: const _LayoutWatch(),
        ),
      ),
    );
    expect(_leafBuilds, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: LayoutScope(
          tokens: tokensFor(const Size(410, 810)),
          child: const _LayoutWatch(),
        ),
      ),
    );
    expect(_leafBuilds, 1);
  });

  testWidgets('an open keyboard does not change the profile', (tester) async {
    late LayoutTokens tokens;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
        child: Builder(
          builder: (context) {
            tokens = tokensForContext(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(tokens.profile, LayoutProfile.phonePortrait);
    expect(tokens.size, const Size(360, 800));
  });

  testWidgets('large text keeps a form on one column', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> pump(double scale) {
      return tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return LayoutScope(
              tokens: tokensFor(const Size(800, 600), textScale: scale),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const Scaffold(
            body: AdaptiveForm(children: [Text('A'), Text('B')]),
          ),
        ),
      );
    }

    await pump(1);
    expect(find.byType(Row), findsOneWidget);
    await pump(2);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('layout inspector prints the central values', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: (context, child) {
            return LayoutScope(
              tokens: tokensFor(const Size(915, 412)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const Scaffold(body: LayoutInspectorBanner()),
        ),
      ),
    );
    expect(find.textContaining('phoneLandscape'), findsOneWidget);
    expect(find.textContaining('915×412'), findsOneWidget);
  });
}

int _leafBuilds = 0;

class _LayoutWatch extends StatelessWidget {
  const _LayoutWatch();

  @override
  Widget build(BuildContext context) => const _LayoutLeaf();
}

class _LayoutLeaf extends StatelessWidget {
  const _LayoutLeaf();

  @override
  Widget build(BuildContext context) {
    context.layout;
    _leafBuilds++;
    return const SizedBox.shrink();
  }
}
