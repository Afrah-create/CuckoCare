import 'package:flutter/material.dart';

import 'layout_scope.dart';
import 'content_frame.dart';

/// Side-by-side on [LayoutProfile.phoneLandscape] and tablet; stacked otherwise.
class TwoPane extends StatelessWidget {
  const TwoPane({
    required this.primary,
    required this.secondary,
    this.primaryFlex = 3,
    this.secondaryFlex = 2,
    super.key,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final gap = layout.gutter;

    if (layout.useTwoPane) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: primaryFlex, child: primary),
          SizedBox(width: gap),
          Expanded(flex: secondaryFlex, child: secondary),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        primary,
        SizedBox(height: gap),
        secondary,
      ],
    );
  }
}

/// Scrollable pane with bottom inset for gesture bar clearance.
class PaneScrollView extends StatelessWidget {
  const PaneScrollView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: ContentFrame.scrollBottomInset(context),
      ),
      child: child,
    );
  }
}
