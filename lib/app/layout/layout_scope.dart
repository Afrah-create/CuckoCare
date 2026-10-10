import 'package:flutter/material.dart';

import 'layout_profile.dart';

class LayoutScope extends InheritedWidget {
  const LayoutScope({
    required this.tokens,
    required super.child,
    super.key,
  });

  final LayoutTokens tokens;

  static LayoutTokens of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LayoutScope>();
    assert(scope != null, 'LayoutScope missing above MaterialApp builder');
    return scope!.tokens;
  }

  @override
  bool updateShouldNotify(LayoutScope oldWidget) {
    return !oldWidget.tokens.sameBreakpoint(tokens);
  }
}

extension LayoutContext on BuildContext {
  LayoutTokens get layout => LayoutScope.of(this);
}
