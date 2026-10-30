import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';

/// Scales to 0.98 while pressed. Does not own the tap so InkWell still works.
class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    this.pressedScale = 0.98,
    super.key,
  });

  final Widget child;
  final double pressedScale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final motion = AppMotion.of(context);
    final scale = !motion.reduceMotion && _pressed ? widget.pressedScale : 1.0;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: motion.fast,
        curve: motion.curveStandard,
        child: widget.child,
      ),
    );
  }
}
