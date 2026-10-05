import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/theme_context.dart';

/// Brief background pulse so a new or changed row is easy to spot.
class HighlightOnInsert extends StatefulWidget {
  const HighlightOnInsert({
    required this.child,
    required this.active,
    super.key,
  });

  final Widget child;
  final bool active;

  @override
  State<HighlightOnInsert> createState() => _HighlightOnInsertState();
}

class _HighlightOnInsertState extends State<HighlightOnInsert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _playedForCurrent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.highlightPulse,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active && !_playedForCurrent) {
      _playedForCurrent = true;
      _play();
    }
  }

  @override
  void didUpdateWidget(covariant HighlightOnInsert oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) {
      _playedForCurrent = false;
      return;
    }
    if (!oldWidget.active) {
      _playedForCurrent = true;
      _play();
    }
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = context.colors.highlightPulse;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final alpha = t < 0.5 ? t * 2 : (1 - t) * 2;
        return ColoredBox(
          color: tint.withValues(alpha: alpha * 0.55),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
