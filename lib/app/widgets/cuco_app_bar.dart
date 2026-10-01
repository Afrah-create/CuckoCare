import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import 'app_logo.dart';
import 'sync_status_badge.dart';

class CucoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CucoAppBar({
    required this.title,
    required this.profileInitials,
    required this.onProfileTap,
    this.syncStatus,
    this.compact = false,
    super.key,
  });

  final String title;
  final String profileInitials;
  final VoidCallback onProfileTap;
  final SyncStatus? syncStatus;
  final bool compact;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return AppBar(
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          const AppLogo(size: AppLogoSize.compact, showWordmark: false),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compact
                          ? context.text.titleSmall
                          : context.text.titleMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (!compact)
                  Text(
                    'CucoCare',
                    style: context.text.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.2,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (syncStatus != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xxs),
            child: Center(child: SyncStatusBadge(status: syncStatus!)),
          ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: IconButton(
            tooltip: 'Account',
            onPressed: onProfileTap,
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text(
                profileInitials,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
