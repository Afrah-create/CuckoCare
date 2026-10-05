import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/widgets/states/app_dialog.dart';
import '../../../data_platform/db/app_database.dart';
import '../../../data_platform/sync/sync_engine.dart';

class SyncDiagnosticsScreen extends ConsumerStatefulWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  ConsumerState<SyncDiagnosticsScreen> createState() =>
      _SyncDiagnosticsScreenState();
}

class _SyncDiagnosticsScreenState extends ConsumerState<SyncDiagnosticsScreen> {
  _DiagData? _data;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final db = ref.read(appDatabaseProvider);
    final cursors = await db.syncDao.allCursors();
    final failed = await db.outboxDao.failedOps();
    setState(() => _data = _DiagData(cursors: cursors, failed: failed));
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);
    final db = ref.read(appDatabaseProvider);
    final status = sync.value ??
        const SyncStatus(phase: SyncPhase.idle, pendingOutboxCount: 0);
    final data = _data;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${status.phase.name}'),
          Text('Pending: ${status.pendingOutboxCount}'),
          Text('Failed: ${status.failedOutboxCount}'),
          if (status.lastSyncedAt != null)
            Text('Last synced: ${status.lastSyncedAt!.toUtc()}'),
          if (status.message != null) Text('Message: ${status.message}'),
          const SizedBox(height: 16),
          const Text('Cursors per scope', style: TextStyle(fontWeight: FontWeight.bold)),
          if (data != null)
            ...data.cursors.entries.map((e) => Text('${e.key}: ${e.value}')),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              await ref.read(syncEngineProvider).fullResync();
              await _reload();
            },
            child: const Text('Full resync (keep outbox)'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(syncEngineProvider).syncOnce(force: true);
              await _reload();
            },
            child: const Text('Sync now'),
          ),
          const SizedBox(height: 16),
          const Text('Failed operations', style: TextStyle(fontWeight: FontWeight.bold)),
          if (data != null)
            ...data.failed.map(
              (row) => ListTile(
                title: Text('${row.targetTable} / ${row.rowId}'),
                subtitle: Text(row.errorCode ?? row.lastError ?? 'unknown'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await db.outboxDao.retryFailed(row.opId);
                        await _reload();
                      },
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final ok = await showAppDialog<bool>(
                          context: context,
                          builder: (ctx) => AppDialog(
                            title: const Text('Discard this change?'),
                            message:
                                'Removes the failed change from the queue. The saved row stays on this phone.',
                            actions: [
                              TextButton(
                                onPressed: () => ctx.pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => ctx.pop(true),
                                child: const Text('Discard'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await db.outboxDao.discard(row.opId);
                          await db.into(db.syncEvents).insert(
                                SyncEventsCompanion.insert(
                                  occurredAt: DateTime.now().toUtc(),
                                  level: 'warn',
                                  message: 'Discarded ${row.opId}',
                                ),
                              );
                          await _reload();
                        }
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DiagData {
  _DiagData({required this.cursors, required this.failed});

  final Map<String, int> cursors;
  final List<OutboxRow> failed;
}
