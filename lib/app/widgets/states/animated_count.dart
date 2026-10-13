import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    this.style,
    this.format,
    super.key,
  });

  final int value;
  final TextStyle? style;
  final String Function(int value)? format;

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    return AnimatedSwitcher(
      duration: motion.fast,
      switchInCurve: motion.curveStandard,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Text(
        format?.call(value) ?? '$value',
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}
