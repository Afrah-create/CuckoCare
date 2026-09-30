import 'package:flutter/material.dart';

/// Brand colours derived from `tool/generate_brand_assets.dart` (also in `brand_colours.json`).
class BrandTokens extends ThemeExtension<BrandTokens> {
  const BrandTokens({
    required this.brandInk,
    required this.brandCream,
    required this.splashBackgroundLight,
    required this.splashBackgroundDark,
    required this.notificationAccent,
    required this.adaptiveBackgroundDev,
    required this.adaptiveBackgroundStaging,
    required this.adaptiveBackgroundProd,
  });

  final Color brandInk;
  final Color brandCream;
  final Color splashBackgroundLight;
  final Color splashBackgroundDark;
  final Color notificationAccent;
  final Color adaptiveBackgroundDev;
  final Color adaptiveBackgroundStaging;
  final Color adaptiveBackgroundProd;

  static const defaults = BrandTokens(
    brandInk: Color(0xFF622347),
    brandCream: Color(0xFFFFF6E8),
    splashBackgroundLight: Color(0xFFFFF6E8),
    splashBackgroundDark: Color(0xFF1A1410),
    notificationAccent: Color(0xFF5C4033),
    adaptiveBackgroundDev: Color(0xFF455A64),
    adaptiveBackgroundStaging: Color(0xFFFFB300),
    adaptiveBackgroundProd: Color(0xFFFFF6E8),
  );

  Color splashBackgroundFor(Brightness brightness) =>
      brightness == Brightness.dark ? splashBackgroundDark : splashBackgroundLight;

  Color logoInkFor(Brightness brightness) =>
      brightness == Brightness.dark ? brandCream : brandInk;

  @override
  BrandTokens copyWith({
    Color? brandInk,
    Color? brandCream,
    Color? splashBackgroundLight,
    Color? splashBackgroundDark,
    Color? notificationAccent,
    Color? adaptiveBackgroundDev,
    Color? adaptiveBackgroundStaging,
    Color? adaptiveBackgroundProd,
  }) {
    return BrandTokens(
      brandInk: brandInk ?? this.brandInk,
      brandCream: brandCream ?? this.brandCream,
      splashBackgroundLight:
          splashBackgroundLight ?? this.splashBackgroundLight,
      splashBackgroundDark: splashBackgroundDark ?? this.splashBackgroundDark,
      notificationAccent: notificationAccent ?? this.notificationAccent,
      adaptiveBackgroundDev:
          adaptiveBackgroundDev ?? this.adaptiveBackgroundDev,
      adaptiveBackgroundStaging:
          adaptiveBackgroundStaging ?? this.adaptiveBackgroundStaging,
      adaptiveBackgroundProd:
          adaptiveBackgroundProd ?? this.adaptiveBackgroundProd,
    );
  }

  @override
  BrandTokens lerp(ThemeExtension<BrandTokens>? other, double t) {
    if (other is! BrandTokens) {
      return this;
    }
    return BrandTokens(
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
      brandCream: Color.lerp(brandCream, other.brandCream, t)!,
      splashBackgroundLight:
          Color.lerp(splashBackgroundLight, other.splashBackgroundLight, t)!,
      splashBackgroundDark:
          Color.lerp(splashBackgroundDark, other.splashBackgroundDark, t)!,
      notificationAccent:
          Color.lerp(notificationAccent, other.notificationAccent, t)!,
      adaptiveBackgroundDev:
          Color.lerp(adaptiveBackgroundDev, other.adaptiveBackgroundDev, t)!,
      adaptiveBackgroundStaging: Color.lerp(
        adaptiveBackgroundStaging,
        other.adaptiveBackgroundStaging,
        t,
      )!,
      adaptiveBackgroundProd:
          Color.lerp(adaptiveBackgroundProd, other.adaptiveBackgroundProd, t)!,
    );
  }
}

BrandTokens brandTokensOf(BuildContext context) {
  return Theme.of(context).extension<BrandTokens>() ?? BrandTokens.defaults;
}
