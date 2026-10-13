import 'package:flutter/material.dart';

import '../layout/layout_scope.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// Primary form action pinned above the system navigation area.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: SizedBox(
          // bottomNavigationBar can get an unbounded width on some devices.
          width: context.layout.size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
