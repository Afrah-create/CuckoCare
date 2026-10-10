import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'breakpoints.dart';
import 'page_layout.dart';

enum WidthClass { narrow, compact, medium, expanded, large }

/// [compact] is a short window, [medium] is regular, [expanded] is tall.
enum HeightClass { compact, medium, expanded }

enum LayoutProfile {
  phonePortrait,
  phoneLandscape,
  tablet,
  cramped,
}

WidthClass widthClassFor(double width) {
  if (width >= Breakpoints.widthLargeMin) {
    return WidthClass.large;
  }
  if (width >= Breakpoints.widthMediumMax + 1) {
    return WidthClass.expanded;
  }
  if (width >= Breakpoints.widthCompactMax + 1) {
    return WidthClass.medium;
  }
  if (width >= Breakpoints.widthCompactMin) {
    return WidthClass.compact;
  }
  return WidthClass.narrow;
}

HeightClass heightClassFor(double height) {
  if (height >= Breakpoints.heightTallMin) {
    return HeightClass.expanded;
  }
  if (height >= Breakpoints.heightShortMax + 1) {
    return HeightClass.medium;
  }
  return HeightClass.compact;
}

LayoutProfile layoutProfileFor(Size size) {
  if (size.width < Breakpoints.crampedMinWidth ||
      size.height < Breakpoints.crampedMinHeight) {
    return LayoutProfile.cramped;
  }
  final w = widthClassFor(size.width);
  final h = heightClassFor(size.height);
  if (w == WidthClass.narrow || w == WidthClass.compact) {
    return LayoutProfile.phonePortrait;
  }
  if (h == HeightClass.compact) {
    return LayoutProfile.phoneLandscape;
  }
  return LayoutProfile.tablet;
}

/// Layout tokens for the active [LayoutProfile].
class LayoutTokens {
  const LayoutTokens({
    required this.profile,
    required this.widthClass,
    required this.heightClass,
    required this.size,
    this.textScale = 1,
    this.reducedMotion = false,
    this.sideInset = 0,
  });

  final LayoutProfile profile;
  final WidthClass widthClass;
  final HeightClass heightClass;
  final Size size;
  final double textScale;
  final bool reducedMotion;
  final double sideInset;

  bool get isCompactHeight => heightClass == HeightClass.compact;

  bool get isShort => isCompactHeight;

  bool get isNarrow =>
      widthClass == WidthClass.narrow || profile == LayoutProfile.cramped;

  bool get isLargeText => textScale >= Breakpoints.largeTextScale;

  bool get hasSideInset => sideInset > 0;

  bool get useRail =>
      profile == LayoutProfile.phoneLandscape ||
      profile == LayoutProfile.tablet;

  bool get hideTabRootAppBar => profile == LayoutProfile.phoneLandscape;

  double get spaceScale => switch (profile) {
        LayoutProfile.phonePortrait => 1,
        LayoutProfile.tablet => 1.125,
        _ => 0.875,
      };

  double get margin => switch (profile) {
        LayoutProfile.phonePortrait => 16,
        LayoutProfile.phoneLandscape => 20,
        LayoutProfile.tablet => 32,
        LayoutProfile.cramped => 12,
      };

  double get gutter => switch (profile) {
        LayoutProfile.cramped => 8,
        LayoutProfile.phonePortrait => 12,
        LayoutProfile.phoneLandscape => 12,
        LayoutProfile.tablet => 16,
      };

  double get maxContentWidth => switch (profile) {
        LayoutProfile.tablet => 1000,
        _ => double.infinity,
      };

  double get maxFormWidth => switch (profile) {
        LayoutProfile.phoneLandscape || LayoutProfile.tablet => 640,
        _ => double.infinity,
      };

  double get maxReadingWidth => switch (profile) {
        LayoutProfile.phoneLandscape || LayoutProfile.tablet => 560,
        _ => double.infinity,
      };

  double get maxDialogWidth => switch (profile) {
        LayoutProfile.cramped => size.width - 24,
        LayoutProfile.phonePortrait => size.width - 32,
        _ => 560,
      };

  double get maxSheetWidth => switch (profile) {
        LayoutProfile.phoneLandscape || LayoutProfile.tablet => 640,
        _ => double.infinity,
      };

  double get minCardWidth => switch (profile) {
        LayoutProfile.cramped => 140,
        LayoutProfile.phonePortrait => 160,
        LayoutProfile.phoneLandscape => 180,
        LayoutProfile.tablet => 220,
      };

  double maxWidthFor(PageLayout preset) => switch (preset) {
        PageLayout.standard => maxContentWidth,
        PageLayout.form => maxFormWidth,
        PageLayout.reading => maxReadingWidth,
        PageLayout.fullBleed => double.infinity,
      };

  double get statCardMaxHeight => switch (profile) {
        LayoutProfile.phonePortrait => 120,
        LayoutProfile.phoneLandscape => 110,
        LayoutProfile.tablet => 130,
        LayoutProfile.cramped => 100,
      };

  int get statColumns => size.width >= Breakpoints.widthMediumMax + 1 ? 4 : 2;

  bool get useTwoPane =>
      profile == LayoutProfile.phoneLandscape ||
      profile == LayoutProfile.tablet;

  double get touchTarget => Breakpoints.touchTarget;

  double space(int step) => AppSpacing.xs * step * spaceScale;

  int columnsFor(double availableWidth, {double? minItemWidth}) {
    final min = (minItemWidth ?? minCardWidth) * (isLargeText ? 1.35 : 1);
    if (min <= 0 || availableWidth <= 0) {
      return 1;
    }
    final columns = (availableWidth / min).floor();
    return columns < 1 ? 1 : columns;
  }

  bool sameBreakpoint(LayoutTokens other) {
    return profile == other.profile &&
        widthClass == other.widthClass &&
        heightClass == other.heightClass &&
        isLargeText == other.isLargeText &&
        hasSideInset == other.hasSideInset &&
        reducedMotion == other.reducedMotion;
  }
}

LayoutTokens tokensFor(
  Size size, {
  double textScale = 1,
  bool reducedMotion = false,
  double sideInset = 0,
}) {
  return LayoutTokens(
    profile: layoutProfileFor(size),
    widthClass: widthClassFor(size.width),
    heightClass: heightClassFor(size.height),
    size: size,
    textScale: textScale,
    reducedMotion: reducedMotion,
    sideInset: sideInset,
  );
}

LayoutTokens tokensForContext(BuildContext context) {
  final padding = MediaQuery.viewPaddingOf(context);
  final side = padding.left > padding.right ? padding.left : padding.right;
  return tokensFor(
    MediaQuery.sizeOf(context),
    textScale: MediaQuery.textScalerOf(context).scale(1),
    reducedMotion: MediaQuery.disableAnimationsOf(context),
    sideInset: side,
  );
}
