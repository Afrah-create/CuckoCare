import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

/// One ticker for every bone under this scope.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({required this.child, super.key});

  final Widget child;

  static SkeletonTicker? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SkeletonTicker>()?.ticker;
  }

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class SkeletonTicker {
  SkeletonTicker(this.animation);

  final Animation<double> animation;
}

class _SkeletonTicker extends InheritedWidget {
  const _SkeletonTicker({required this.ticker, required super.child});

  final SkeletonTicker ticker;

  @override
  bool updateShouldNotify(_SkeletonTicker oldWidget) =>
      ticker != oldWidget.ticker;
}

class _SkeletonScopeState extends State<SkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.shimmer);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = AppMotion.of(context);
    if (motion.reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      container: true,
      child: ExcludeSemantics(
        child: _SkeletonTicker(
          ticker: SkeletonTicker(_controller),
          child: widget.child,
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    this.widthFactor = 1,
    this.height = 12,
    super.key,
  });

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: _Bone(height: height, radius: height / 2),
      ),
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    this.width,
    this.height = 16,
    this.radius = AppSpacing.radiusSm,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Bone(width: width, height: height, radius: radius);
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _Bone(width: size, height: size, radius: size / 2);
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({this.lineWidth = 0.62, super.key});

  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const SkeletonCircle(size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(widthFactor: lineWidth, height: 14),
                const SizedBox(height: AppSpacing.xs),
                const SkeletonLine(widthFactor: 0.38, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.lines = const [0.7, 0.42], super.key});

  final List<double> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.xs),
              SkeletonLine(widthFactor: lines[i], height: i == 0 ? 14 : 11),
            ],
          ],
        ),
      ),
    );
  }
}

class SkeletonStatTile extends StatelessWidget {
  const SkeletonStatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.scheme.surfaceContainerLow,
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBlock(
                  width: 28,
                  height: 28,
                  radius: AppSpacing.radiusSm,
                ),
                SizedBox(width: AppSpacing.sm),
                SkeletonBlock(width: 36, height: 22, radius: 6),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            SkeletonLine(widthFactor: 0.72, height: 12),
          ],
        ),
      ),
    );
  }
}

class SkeletonDetailHeader extends StatelessWidget {
  const SkeletonDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLine(widthFactor: 0.46, height: 22),
        SizedBox(height: AppSpacing.sm),
        SkeletonLine(widthFactor: 0.28, height: 12),
        SizedBox(height: AppSpacing.lg),
        SkeletonBlock(height: 72, radius: AppSpacing.radiusMd),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height, required this.radius, this.width});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final base = context.colors.skeletonBase;
    final highlight = context.colors.skeletonHighlight;
    final ticker = SkeletonScope.maybeOf(context);
    final still = ticker == null || AppMotion.of(context).reduceMotion;

    final box = SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );

    if (still) {
      return box;
    }

    return AnimatedBuilder(
      animation: ticker.animation,
      builder: (context, child) {
        final t = ticker.animation.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.4 + (t * 2.8), -0.15),
              end: Alignment(-0.2 + (t * 2.8), 0.15),
              colors: [base, highlight, base],
              stops: const [0.36, 0.5, 0.64],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: box,
    );
  }
}
