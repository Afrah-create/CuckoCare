import 'package:flutter/material.dart';

import 'layout_scope.dart';
import 'page_layout.dart';

/// Applies side safe-area, page margin, and the preset max width.
///
/// Horizontal insets are marked consumed so nested widgets do not add them
/// again. The bottom gesture inset stays on the media query so scroll views
/// can pad their last item with [scrollBottomInset].
class ContentFrame extends StatelessWidget {
  const ContentFrame({
    required this.child,
    this.padding,
    this.preset = PageLayout.standard,
    super.key,
  });

  final Widget child;
  final EdgeInsets? padding;
  final PageLayout preset;

  /// Bottom inset for scroll views (gesture bar + margin).
  static double scrollBottomInset(BuildContext context) {
    final layout = context.layout;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return viewPadding.bottom + layout.margin;
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    if (preset == PageLayout.fullBleed) {
      return child;
    }

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final edge = padding ??
        EdgeInsets.fromLTRB(
          viewPadding.left + layout.margin,
          0,
          viewPadding.right + layout.margin,
          0,
        );

    return MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeRight: true,
      child: Padding(
        padding: edge,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxWidthFor(preset)),
            child: child,
          ),
        ),
      ),
    );
  }
}
