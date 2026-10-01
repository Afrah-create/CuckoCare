import 'package:flutter/material.dart';

import 'breakpoints.dart';

enum WidthClass { compact, medium, expanded }

enum HeightClass { compact, medium, expanded }

enum LayoutProfile {
  phonePortrait,
  phoneLandscape,
  tablet,
  cramped,
}

WidthClass widthClassFor(double width) {
  if (width >= Breakpoints.widthMediumMax + 1) {
    return WidthClass.expanded;
  }
  if (width >= Breakpoints.widthCompactMax + 1) {
    return WidthClass.medium;
  }
  return WidthClass.compact;
}

HeightClass heightClassFor(double height) {
  if (height >= Breakpoints.heightMediumMax + 1) {
    return HeightClass.expanded;
  }
  if (height >= Breakpoints.heightCompactMax + 1) {
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
  if (w == WidthClass.compact) {
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
  });

  final LayoutProfile profile;
  final WidthClass widthClass;
  final HeightClass heightClass;
  final Size size;

  bool get isCompactHeight => heightClass == HeightClass.compact;

  bool get useRail =>
      profile == LayoutProfile.phoneLandscape ||
      profile == LayoutProfile.tablet;

  bool get hideTabRootAppBar => profile == LayoutProfile.phoneLandscape;

  double get margin => switch (profile) {
        LayoutProfile.phonePortrait => 16,
        LayoutProfile.phoneLandscape => 20,
        LayoutProfile.tablet => 28,
        LayoutProfile.cramped => 12,
      };

  double get gutter => profile == LayoutProfile.tablet ? 16 : 12;

  double get maxContentWidth => switch (profile) {
        LayoutProfile.tablet => 1000,
        _ => double.infinity,
      };

  double get maxFormWidth => 640;

  double get maxDialogWidth => 560;

  double get statCardMaxHeight => switch (profile) {
        LayoutProfile.phonePortrait => 120,
        LayoutProfile.phoneLandscape => 110,
        LayoutProfile.tablet => 130,
        LayoutProfile.cramped => 100,
      };

  int get statColumns => size.width >= 840 ? 4 : 2;

  bool get useTwoPane =>
      profile == LayoutProfile.phoneLandscape ||
      profile == LayoutProfile.tablet;
}

LayoutTokens tokensFor(Size size) {
  final profile = layoutProfileFor(size);
  return LayoutTokens(
    profile: profile,
    widthClass: widthClassFor(size.width),
    heightClass: heightClassFor(size.height),
    size: size,
  );
}
