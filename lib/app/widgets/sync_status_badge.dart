import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';

/// Compact sync indicator for the app bar.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (status.phase) {
      SyncPhase.idle => ('Synced', Icons.cloud_done_outlined, Colors.green),
      SyncPhase.syncing => ('Syncing', Icons.sync, theme.colorScheme.primary),
      SyncPhase.offline => ('Offline', Icons.cloud_off_outlined, Colors.orange),
      SyncPhase.error => ('Error', Icons.error_outline, theme.colorScheme.error),
      SyncPhase.authRequired => ('Sign in', Icons.lock_outline, theme.colorScheme.error),
      SyncPhase.signedOutDemo => ('Demo', Icons.science_outlined, theme.colorScheme.outline),
    };

    final pending = status.pendingOutboxCount;
    var text = label;
    if (pending > 0) {
      text = '$label · $pending';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kept for existing tests and imports.
typedef SyncStatusChip = SyncStatusBadge;
