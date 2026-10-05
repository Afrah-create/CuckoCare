import 'package:flutter/widgets.dart';

/// Durations and curves for the whole app.
///
/// Read them through [AppMotion.of] so reduced motion collapses to zero.
abstract final class AppMotion {
  static const instant = Duration.zero;
  static const fast = Duration(milliseconds: 100);
  static const standard = Duration(milliseconds: 200);
  static const emphasized = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const shimmer = Duration(milliseconds: 1200);

  static const skeletonDelay = Duration(milliseconds: 200);
  static const skeletonMinVisible = Duration(milliseconds: 400);
  static const snackbarShort = Duration(seconds: 3);
  static const snackbarWithAction = Duration(seconds: 6);
  static const undoWindow = Duration(seconds: 6);
  static const highlightPulse = Duration(milliseconds: 900);
  static const loadTimeout = Duration(seconds: 8);
  static const slowNetwork = Duration(seconds: 3);

  static const curveStandard = Cubic(0.33, 1, 0.68, 1);
  static const curveEmphasized = Cubic(0.2, 0, 0, 1);
  static const curveDecelerate = Cubic(0, 0, 0.2, 1);
  static const curveAccelerate = Cubic(0.4, 0, 1, 1);

  static MotionTokens of(BuildContext context) {
    return MotionTokens(
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
  }
}

class MotionTokens {
  const MotionTokens({required this.reduceMotion});

  final bool reduceMotion;

  Duration _d(Duration value) => reduceMotion ? Duration.zero : value;

  Duration get instant => Duration.zero;
  Duration get fast => _d(AppMotion.fast);
  Duration get standard => _d(AppMotion.standard);
  Duration get emphasized => _d(AppMotion.emphasized);
  Duration get slow => _d(AppMotion.slow);
  Duration get shimmer => _d(AppMotion.shimmer);
  Duration get skeletonDelay => _d(AppMotion.skeletonDelay);
  Duration get skeletonMinVisible => _d(AppMotion.skeletonMinVisible);
  Duration get snackbarShort => _d(AppMotion.snackbarShort);
  Duration get snackbarWithAction => _d(AppMotion.snackbarWithAction);
  Duration get undoWindow => AppMotion.undoWindow;
  Duration get highlightPulse => _d(AppMotion.highlightPulse);
  Duration get loadTimeout => AppMotion.loadTimeout;

  Curve get curveStandard =>
      reduceMotion ? Curves.linear : AppMotion.curveStandard;
  Curve get curveEmphasized =>
      reduceMotion ? Curves.linear : AppMotion.curveEmphasized;
}
