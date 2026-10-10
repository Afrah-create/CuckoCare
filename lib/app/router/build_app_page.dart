import 'package:flutter/material.dart';

import '../layout/page_layout.dart';

/// Carries the route's [PageLayout] preset. [AppPage] owns the scaffold and
/// the content frame, so this wrapper does not add a second one.
class PagePresetScope extends InheritedWidget {
  const PagePresetScope({
    required this.preset,
    required super.child,
    super.key,
  });

  final PageLayout preset;

  static PageLayout? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PagePresetScope>()?.preset;
  }

  @override
  bool updateShouldNotify(PagePresetScope oldWidget) => preset != oldWidget.preset;
}

Widget buildAppPage({
  required Widget child,
  PageLayout preset = PageLayout.standard,
}) {
  return PagePresetScope(preset: preset, child: child);
}
