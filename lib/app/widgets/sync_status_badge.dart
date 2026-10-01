import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../theme/theme_context.dart';
import 'status_chip.dart';

/// Compact sync indicator for the app bar.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (label, icon, fg) = switch (status.phase) {
      SyncPhase.idle => ('Synced', Icons.cloud_done_outlined, colors.syncIdle),
      SyncPhase.syncing => ('Syncing', Icons.sync, colors.syncSyncing),
      SyncPhase.offline => ('Offline', Icons.cloud_off_outlined, colors.syncOffline),
      SyncPhase.error => ('Error', Icons.error_outline, colors.syncError),
      SyncPhase.authRequired => (
          'Sign in',
          Icons.lock_outline,
          colors.syncError,
        ),
      SyncPhase.signedOutDemo => (
          'Demo',
          Icons.science_outlined,
          context.scheme.outline,
        ),
    };

    final pending = status.pendingOutboxCount;
    var text = label;
    if (pending > 0) {
      text = '$label · $pending';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: StatusChip(
          label: text,
          icon: icon,
          background: fg,
          foreground: fg,
        ),
      ),
    );
  }
}

/// Kept for existing tests and imports.
typedef SyncStatusChip = SyncStatusBadge;
