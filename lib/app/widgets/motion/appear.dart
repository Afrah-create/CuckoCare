import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

/// Stagger cap so long lists do not take a second to appear.
const int kAppearStaggerCap = 5;
const int kAppearStaggerStepMs = 40;

Duration appearStagger(int index) {
  final clamped = index < 0
      ? 0
      : index > kAppearStaggerCap
      ? kAppearStaggerCap
      : index;
  return Duration(milliseconds: clamped * kAppearStaggerStepMs);
}

/// Fade + 8px slide-up on first layout. Instant when reduced motion is on.
class Appear extends StatefulWidget {
  const Appear({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    final motion = AppMotion.of(context);
    if (motion.reduceMotion) {
      return;
    }
    final controller = AnimationController(
      vsync: this,
      duration: motion.emphasized,
    );
    _controller = controller;
    final delay = widget.delay;
    if (delay == Duration.zero) {
      controller.forward();
      return;
    }
    Future<void>.delayed(delay, () {
      if (mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return widget.child;
    }
    final motion = AppMotion.of(context);
    final curved = CurvedAnimation(
      parent: controller,
      curve: motion.curveDecelerate,
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 8 * (1 - curved.value)),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
