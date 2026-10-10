import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import '../widgets/app_logo.dart';
import 'layout_scope.dart';

/// Gives the rail a bounded height and scrolls it when the window is short.
class ShellRailHost extends StatelessWidget {
  const ShellRailHost({
    required this.rail,
    required this.width,
    super.key,
  });

  final Widget rail;
  final double width;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    if (!layout.isShort) {
      return SizedBox(width: width, child: rail);
    }
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight < 520 ? 520.0 : constraints.maxHeight;
          return SingleChildScrollView(
            child: SizedBox(height: height, width: width, child: rail),
          );
        },
      ),
    );
  }
}

/// Brand mark at the top of the navigation rail.
class ShellRailLeading extends StatelessWidget {
  const ShellRailLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Semantics(
        label: 'CucoCare',
        child: const AppLogo(
          size: AppLogoSize.compact,
          showWordmark: false,
        ),
      ),
    );
  }
}

/// Sync control and account entry at the bottom of the rail.
class ShellRailTrailing extends StatelessWidget {
  const ShellRailTrailing({
    required this.syncStatus,
    required this.profileInitials,
    required this.onProfileTap,
    super.key,
  });

  final SyncStatus syncStatus;
  final String profileInitials;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final (tooltip, icon) = switch (syncStatus.phase) {
      SyncPhase.idle => ('Synced', Icons.cloud_done_outlined),
      SyncPhase.syncing => ('Syncing', Icons.sync),
      SyncPhase.offline => ('Offline', Icons.cloud_off_outlined),
      SyncPhase.error => ('Sync error', Icons.error_outline),
      SyncPhase.authRequired => ('Sign in required', Icons.lock_outline),
      SyncPhase.signedOutDemo => ('Demo mode', Icons.science_outlined),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: tooltip,
            onPressed: null,
            icon: Icon(icon),
          ),
          IconButton(
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
        ],
      ),
    );
  }
}
