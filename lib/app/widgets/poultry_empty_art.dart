import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/theme_context.dart';

/// Idle-breathing hen used on empty flocks / feed / requests.
class PoultryEmptyArt extends StatefulWidget {
  const PoultryEmptyArt({this.size = 88, this.fallbackIcon, super.key});

  final double size;
  final IconData? fallbackIcon;

  static const asset = AssetImage('assets/brand/layers/hen_mask.png');

  @override
  State<PoultryEmptyArt> createState() => _PoultryEmptyArtState();
}

class _PoultryEmptyArtState extends State<PoultryEmptyArt>
    with SingleTickerProviderStateMixin {
  AnimationController? _breath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = AppMotion.of(context);
    if (motion.reduceMotion) {
      _breath?.dispose();
      _breath = null;
      return;
    }
    if (_breath != null) {
      return;
    }
    _breath = AnimationController(
      vsync: this,
      duration: motion.shimmer,
      lowerBound: 1,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = context.colors.logoTint;
    final hen = ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: Image(
        image: PoultryEmptyArt.asset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, _, _) => Icon(
          widget.fallbackIcon ?? Icons.egg_outlined,
          size: widget.size * 0.55,
          color: tint,
        ),
      ),
    );
    final breath = _breath;
    if (breath == null) {
      return hen;
    }
    return ScaleTransition(scale: breath, child: hen);
  }
}
