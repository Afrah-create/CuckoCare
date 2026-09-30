import 'package:flutter/animation.dart';

/// Splash intro durations and curve intervals (single source of truth).
abstract final class SplashTiming {
  static const fullIntroMs = 1500;
  static const quickIntroMs = 700;
  static const reducedFadeMs = 250;

  static const plainHoldStart = 0.0;
  static const plainHoldEnd = 100 / fullIntroMs;

  static const eggsStart = 80 / fullIntroMs;
  static const eggsEnd = 520 / fullIntroMs;
  static const eggStaggerMs = 70;

  static const henStart = 380 / fullIntroMs;
  static const henEnd = 860 / fullIntroMs;

  static const wordmarkStart = 780 / fullIntroMs;
  static const wordmarkEnd = 1150 / fullIntroMs;

  static const holdEnd = 1150 / fullIntroMs;
  static const exitEnd = 1.0;

  static const eggPopOvershoot = 1.08;
  static const eggRiseDp = 10.0;
  static const henDropDp = 28.0;
  static const wordmarkRiseDp = 8.0;

  static const idleBreathMin = 1.0;
  static const idleBreathMax = 1.02;
  static const idleBreathPeriodMs = 1500;

  static Interval interval(double start, double end) =>
      Interval(start, end, curve: Curves.easeOutCubic);

  static double quickScale(double t, double fullEnd) =>
      (t * (fullIntroMs / quickIntroMs)).clamp(0.0, fullEnd);
}
