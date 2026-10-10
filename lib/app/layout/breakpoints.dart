/// Window size classes (dp). Layout code reads these through [LayoutScope].
abstract final class Breakpoints {
  static const widthNarrowMax = 359.0;
  static const widthCompactMin = 360.0;
  static const widthCompactMax = 599.0;
  static const widthMediumMax = 839.0;
  static const widthExpandedMax = 1199.0;
  static const widthLargeMin = 1200.0;

  static const heightShortMax = 479.0;
  static const heightRegularMax = 899.0;
  static const heightTallMin = 900.0;

  /// Kept for existing call sites. Short windows are below this height.
  static const heightCompactMax = heightShortMax;

  /// Kept for existing call sites. Tall windows start above this height.
  static const heightMediumMax = heightRegularMax;

  static const crampedMinWidth = 320.0;
  static const crampedMinHeight = 240.0;

  static const largeTextScale = 1.5;
  static const touchTarget = 48.0;

  static const formTwoColumnMinWidth = 560.0;
  static const listGridMinContentWidth = 720.0;
  static const railExtendedMinWidth = widthLargeMin;
}
