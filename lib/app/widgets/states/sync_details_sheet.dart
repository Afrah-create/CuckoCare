import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data_platform/sync/sync_engine.dart';
import '../../di/providers.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_context.dart';

Future<void> showSyncDetailsSheet(BuildContext context, SyncStatus status) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => _SyncDetails(status: status),
  );
}

class _SyncDetails extends ConsumerWidget {
  const _SyncDetails({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = status.lastSyncedAt;
    final lastLabel = last == null ? 'Not yet' : _ago(last);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.viewPaddingOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sync',
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Last sync: $lastLabel'),
          const SizedBox(height: AppSpacing.xs),
          Text('Waiting: ${status.pendingOutboxCount}'),
          const SizedBox(height: AppSpacing.xs),
          Text('Failed: ${status.failedOutboxCount}'),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(syncEngineProvider).syncOnce(force: true);
            },
            child: const Text('Retry now'),
          ),
        ],
      ),
    );
  }
}

String _ago(DateTime time) {
  final delta = DateTime.now().difference(time.toLocal());
  if (delta.inMinutes < 1) {
    return 'just now';
  }
  if (delta.inMinutes < 60) {
    return '${delta.inMinutes} min ago';
  }
  if (delta.inHours < 24) {
    return '${delta.inHours} h ago';
  }
  return '${delta.inDays} d ago';
}

String syncStatusLabel(SyncStatus status) {
  final pending = status.pendingOutboxCount;
  final base = switch (status.phase) {
    SyncPhase.idle => status.lastSyncedAt == null
        ? 'Synced'
        : 'Synced · ${_ago(status.lastSyncedAt!)}',
    SyncPhase.syncing => 'Syncing',
    SyncPhase.offline => 'Offline',
    SyncPhase.error => 'Sync problem',
    SyncPhase.authRequired => 'Sign in',
    SyncPhase.signedOutDemo => 'Demo',
  };
  if (pending > 0 && status.phase != SyncPhase.idle) {
    return '$base · $pending';
  }
  if (pending > 0) {
    return '$base · $pending';
  }
  return base;
}
