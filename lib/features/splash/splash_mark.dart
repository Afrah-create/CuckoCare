import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import 'splash_timing.dart';

/// Deterministic splash logo composer (opacity + transforms only).
class SplashMark extends StatelessWidget {
  const SplashMark({
    required this.progress,
    required this.henMask,
    required this.eggLeft,
    required this.eggMid,
    required this.eggRight,
    this.showWordmark = true,
    this.markSize = 180,
    super.key,
  });

  final double progress;
  final ImageProvider henMask;
  final ImageProvider eggLeft;
  final ImageProvider eggMid;
  final ImageProvider eggRight;
  final bool showWordmark;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.logoTint;
    final t = progress.clamp(0.0, 1.0);

    double eggPhase(int index) {
      final start = SplashTiming.eggsStart +
          (index * SplashTiming.eggStaggerMs / SplashTiming.fullIntroMs);
      final local = ((t - start) / (SplashTiming.eggsEnd - SplashTiming.eggsStart))
          .clamp(0.0, 1.0);
      return Curves.easeOutBack.transform(local).clamp(0.0, 1.0);
    }

    final henLocal = SplashTiming.interval(SplashTiming.henStart, SplashTiming.henEnd)
        .transform(t)
        .clamp(0.0, 1.0);

    final wordLocal = SplashTiming.interval(
      SplashTiming.wordmarkStart,
      SplashTiming.wordmarkEnd,
    )
        .transform(t)
        .clamp(0.0, 1.0);

    Widget tinted(ImageProvider provider, {required double opacity, required double scale, double dy = 0}) {
      return Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
              child: Image(
                image: provider,
                width: markSize,
                height: markSize,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      );
    }

    final eggs = [
      eggPhase(0),
      eggPhase(1),
      eggPhase(2),
    ];
    final providers = [eggLeft, eggMid, eggRight];

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: markSize,
            height: markSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  tinted(
                    providers[i],
                    opacity: eggs[i],
                    scale: 0.6 + 0.4 * eggs[i],
                    dy: (1 - eggs[i]) * SplashTiming.eggRiseDp,
                  ),
                tinted(
                  henMask,
                  opacity: henLocal,
                  scale: 1.0 - (henLocal < 1 ? (1 - henLocal) * 0.04 : 0),
                  dy: -SplashTiming.henDropDp * (1 - henLocal),
                ),
              ],
            ),
          ),
          if (showWordmark) ...[
            const SizedBox(height: 16),
            Opacity(
              opacity: wordLocal,
              child: Transform.translate(
                offset: Offset(0, (1 - wordLocal) * SplashTiming.wordmarkRiseDp),
                child: Text(
                  'CucoCare',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6 - wordLocal * 0.4,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
