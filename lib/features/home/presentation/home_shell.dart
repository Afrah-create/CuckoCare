import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/providers.dart';
import '../../../app/widgets/cuco_app_bar.dart';
import '../../../app/widgets/tab_empty_state.dart';
import '../../../data_platform/sync/sync_engine.dart';
import '../../auth/domain/user_profile.dart';
import '../../settings/presentation/sync_diagnostics_screen.dart';
import 'farm_profile_banner.dart';
import 'profile_sheet.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _titles = ['Home', 'Batches', 'Vaccines', 'Settings'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncSchedulerProvider).onForeground();
    });
  }

  void _openProfile() {
    showProfileSheet(
      context,
      ref,
      onOpenSettings: _goToSettings,
      onSignOut: _signOut,
    );
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(hasAuthSnapshotProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(farmProfileIncompleteProvider);
    if (mounted) {
      context.go('/login');
    }
  }

  void _goToSettings() {
    setState(() => _index = 3);
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);
    final profile = ref.watch(userProfileProvider);
    final status = sync.value ??
        const SyncStatus(phase: SyncPhase.idle, pendingOutboxCount: 0);
    final initials = profile.value?.initials ?? '?';

    return Scaffold(
      appBar: CucoAppBar(
        title: _titles[_index],
        profileInitials: initials,
        onProfileTap: _openProfile,
        syncStatus: status,
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _HomeTab(onOpenSettings: _goToSettings),
          const _BatchesTab(),
          const _VaccinesTab(),
          const _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.egg_outlined),
            selectedIcon: Icon(Icons.egg),
            label: 'Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.vaccines_outlined),
            selectedIcon: Icon(Icons.vaccines),
            label: 'Vaccines',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(userProfileProvider).value;
    final greeting = _greeting(profile);

    final profileIncomplete = ref.watch(farmProfileIncompleteProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        profileIncomplete.when(
          data: (incomplete) =>
              incomplete ? const FarmProfileBanner() : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        if (profileIncomplete.value == true) const SizedBox(height: 12),
        Text(
          greeting,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Today on your farm',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.egg_outlined,
                label: 'Active batches',
                value: '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.vaccines_outlined,
                label: 'Due this week',
                value: '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.restaurant_outlined,
                label: 'Feed stock',
                value: '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.favorite_outline,
                label: 'Health alerts',
                value: '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Quick actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.sync,
          title: 'Sync now',
          subtitle: 'Upload pending changes',
          onTap: () => ref.read(syncEngineProvider).syncOnce(force: true),
        ),
        _ActionTile(
          icon: Icons.add_circle_outline,
          title: 'Add batch',
          subtitle: 'Coming soon',
          onTap: null,
        ),
        _ActionTile(
          icon: Icons.tune,
          title: 'Settings & sync',
          subtitle: 'Diagnostics and account',
          onTap: onOpenSettings,
        ),
      ],
    );
  }

  String _greeting(UserProfile? profile) {
    final hour = DateTime.now().hour;
    final period = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    if (profile == null) {
      return period;
    }
    return '$period, ${profile.displayName}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
          foregroundColor: scheme.primary,
          child: Icon(icon, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _BatchesTab extends StatelessWidget {
  const _BatchesTab();

  @override
  Widget build(BuildContext context) {
    return const TabEmptyState(
      icon: Icons.egg_outlined,
      title: 'No batches yet',
      message: 'When you add flocks, they will show up here with age and counts.',
    );
  }
}

class _VaccinesTab extends StatelessWidget {
  const _VaccinesTab();

  @override
  Widget build(BuildContext context) {
    return const TabEmptyState(
      icon: Icons.vaccines_outlined,
      title: 'Vaccination schedule',
      message: 'Tasks and due dates for your batches will appear here.',
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'App',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync_problem_outlined),
                title: const Text('Sync diagnostics'),
                subtitle: const Text('Cursors, queue, failed ops'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SyncDiagnosticsScreen(),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.agriculture_outlined),
                title: const Text('Farm profile'),
                subtitle: const Text('Name, location, phone numbers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/home/farm-profile'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Reminders'),
                subtitle: const Text('Vaccination notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'About',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('CucoCare'),
            subtitle: const Text('Offline-first farm records'),
          ),
        ),
      ],
    );
  }
}
