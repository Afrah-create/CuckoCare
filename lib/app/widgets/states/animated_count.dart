import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

class AnimatedCount extends StatelessWidget {
  const AnimatedCount({required this.value, this.style, super.key});

  final int value;
  final TextStyle? style;

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
        '$value',
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}
