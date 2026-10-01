import 'package:flutter/material.dart';

import 'layout_scope.dart';

/// Applies safe-area padding, page margin, and optional max width centring.
class ContentFrame extends StatelessWidget {
  const ContentFrame({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;

  /// Bottom inset for scroll views (gesture bar + margin).
  static double scrollBottomInset(BuildContext context) {
    final layout = context.layout;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return viewPadding.bottom + layout.margin;
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final edge = padding ??
        EdgeInsets.fromLTRB(
          viewPadding.left + layout.margin,
          viewPadding.top,
          viewPadding.right + layout.margin,
          viewPadding.bottom + layout.margin,
        );

    return Padding(
      padding: edge,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
