import 'package:flutter/material.dart';

import '../../../app/layout/layout_scope.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/theme_context.dart';
import '../../../app/widgets/app_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.compact,
    required this.tagline,
    super.key,
  });

  final bool compact;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final logoSize = compact ? 56.0 : 72.0;

    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLogo(
            size: AppLogoSize.small,
            showWordmark: false,
            heroTag: kEnableLogoHero ? 'app-logo' : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'CucoCare',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.brandInk,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: logoSize,
          width: logoSize,
          child: AppLogo(
            size: AppLogoSize.small,
            showWordmark: false,
            heroTag: kEnableLogoHero ? 'app-logo' : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'CucoCare',
          style: context.text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.brandInk,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: context.scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

bool authHeaderCompact(BuildContext context) {
  return context.layout.isCompactHeight;
}
