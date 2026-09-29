import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../data_platform/sync/sync_engine.dart';
import '../../settings/presentation/sync_diagnostics_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncSchedulerProvider).onForeground();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);
    final status = sync.value ??
        const SyncStatus(phase: SyncPhase.idle, pendingOutboxCount: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CucoCare'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: SyncStatusChip(status: status)),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          _HomeTab(),
          _PlaceholderTab(title: 'Batches'),
          _PlaceholderTab(title: 'Vaccination'),
          _PlaceholderTab(title: 'Settings'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.egg), label: 'Batches'),
          NavigationDestination(
            icon: Icon(Icons.vaccines),
            label: 'Vaccines',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.phase) {
      SyncPhase.idle => ('Synced', Colors.green),
      SyncPhase.syncing => ('Syncing…', Colors.blue),
      SyncPhase.offline => ('Offline', Colors.orange),
      SyncPhase.error => ('Sync error', Colors.red),
      SyncPhase.authRequired => ('Sign in', Colors.red),
      SyncPhase.signedOutDemo => ('Demo', Colors.grey),
    };
    final pending = status.pendingOutboxCount;
    final failed = status.failedOutboxCount;
    var text = pending > 0 ? '$label ($pending)' : label;
    if (failed > 0) {
      text = '$text · $failed failed';
    }
    return Chip(
      label: Text(text, style: TextStyle(color: color.shade900)),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Your farm at a glance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'All data is stored on this device. Sync runs in the background when you have connectivity.',
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () => ref.read(syncEngineProvider).syncOnce(force: true),
          child: const Text('Sync now'),
        ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    if (title == 'Settings') {
      return const _SettingsTab();
    }
    return Center(child: Text('$title — coming soon'));
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Sync diagnostics'),
          subtitle: const Text('Status, cursors, failed ops'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SyncDiagnosticsScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
