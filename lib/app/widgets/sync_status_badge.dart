import 'package:flutter/material.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../theme/theme_context.dart';
import 'states/sync_details_sheet.dart';
import 'status_chip.dart';

/// Compact sync indicator for the app bar.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, fg) = switch (status.phase) {
      SyncPhase.idle => (Icons.cloud_done_outlined, colors.syncIdle),
      SyncPhase.syncing => (Icons.sync, colors.syncSyncing),
      SyncPhase.offline => (Icons.cloud_off_outlined, colors.syncOffline),
      SyncPhase.error => (Icons.error_outline, colors.syncError),
      SyncPhase.authRequired => (Icons.lock_outline, colors.syncError),
      SyncPhase.signedOutDemo => (Icons.science_outlined, context.scheme.outline),
    };
    final text = syncStatusLabel(status);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Tooltip(
          message: text,
          child: InkWell(
            onTap: () => showSyncDetailsSheet(context, status),
            borderRadius: BorderRadius.circular(20),
            child: StatusChip(
              label: text,
              icon: icon,
              background: fg,
              foreground: fg,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kept for existing tests and imports.
typedef SyncStatusChip = SyncStatusBadge;
