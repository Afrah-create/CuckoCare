import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';

/// Hero disabled — avoids duplicate keys during splash/auth/shell transitions.
const kEnableLogoHero = false;

enum AppLogoSize { compact, small, medium, large }

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
        AppLogoSize.compact => 36,
        AppLogoSize.small => 48,
        AppLogoSize.medium => 96,
        AppLogoSize.large => 160,
      };

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.logoTint;

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
          const SizedBox(height: AppSpacing.sm),
          Text(
            'CucoCare',
            style: context.text.headlineSmall?.copyWith(
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
