import 'package:flutter/material.dart';

import '../theme/brand_tokens.dart';

/// When true, splash and login share a [Hero] on `app-logo`.
const kEnableLogoHero = true;

enum AppLogoSize { small, medium, large }

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = AppLogoSize.medium,
    this.showWordmark = false,
    this.heroTag,
    super.key,
  });

  final AppLogoSize size;
  final bool showWordmark;
  final Object? heroTag;

  double get _markSize => switch (size) {
        AppLogoSize.small => 48,
        AppLogoSize.medium => 96,
        AppLogoSize.large => 160,
      };

  @override
  Widget build(BuildContext context) {
    final brand = brandTokensOf(context);
    final brightness = Theme.of(context).brightness;
    final ink = brand.logoInkFor(brightness);

    final mark = ColorFiltered(
      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
      child: Image.asset(
        'assets/brand/hen_mark_mask.png',
        width: _markSize,
        height: _markSize,
        fit: BoxFit.contain,
        cacheWidth: (_markSize * MediaQuery.devicePixelRatioOf(context)).round(),
      ),
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        if (showWordmark) ...[
          const SizedBox(height: 12),
          Text(
            'CucoCare',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ],
    );

    if (heroTag != null && kEnableLogoHero) {
      content = Hero(tag: heroTag!, child: content);
    }

    return Semantics(label: 'CucoCare', child: content);
  }
}
