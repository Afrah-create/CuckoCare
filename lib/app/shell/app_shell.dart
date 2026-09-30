import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../../features/home/presentation/profile_sheet.dart';
import '../di/providers.dart';
import '../router/routes/typed_routes.dart';
import '../widgets/cuco_app_bar.dart';
import 'back_behavior.dart';
import 'tab_scroll_registry.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _titles = ['Today', 'Batches', 'Feed', 'Records', 'More'];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(hasAuthSnapshotProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(farmProfileIncompleteProvider);
    if (mounted) {
      const LoginRoute().go(context);
    }
  }

  void _openProfile() {
    showProfileSheet(context, ref, onSignOut: _signOut);
  }

  void _onDestinationSelected(int index) {
    final shell = widget.navigationShell;
    if (index == shell.currentIndex) {
      final router = GoRouter.of(context);
      while (router.canPop()) {
        router.pop();
      }
      ref.read(tabScrollRegistryProvider.notifier).scrollToTop(index);
      return;
    }
    shell.goBranch(index, initialLocation: false);
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final index = shell.currentIndex;
    final sync = ref.watch(syncStatusProvider);
    final profile = ref.watch(userProfileProvider);
    final status = sync.value ??
        const SyncStatus(phase: SyncPhase.idle, pendingOutboxCount: 0);
    final initials = profile.value?.initials ?? '?';
    final useRail = MediaQuery.sizeOf(context).width >= 600;

    final navBar = NavigationBar(
      selectedIndex: index,
      onDestinationSelected: _onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: 'Today',
        ),
        NavigationDestination(
          icon: Icon(Icons.egg_outlined),
          selectedIcon: Icon(Icons.egg),
          label: 'Batches',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: 'Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.note_alt_outlined),
          selectedIcon: Icon(Icons.note_alt),
          label: 'Records',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );

    final rail = NavigationRail(
      selectedIndex: index,
      onDestinationSelected: _onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: Text('Today'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.egg_outlined),
          selectedIcon: Icon(Icons.egg),
          label: Text('Batches'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: Text('Feed'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.note_alt_outlined),
          selectedIcon: Icon(Icons.note_alt),
          label: Text('Records'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: Text('More'),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        handleShellBack(
          router: GoRouter.of(context),
          currentTabIndex: index,
          goToTodayTab: () => shell.goBranch(0, initialLocation: false),
        );
      },
      child: Scaffold(
        appBar: CucoAppBar(
          title: AppShell._titles[index],
          profileInitials: initials,
          onProfileTap: _openProfile,
          syncStatus: status,
        ),
        body: Row(
          children: [
            if (useRail) rail,
            Expanded(child: shell),
          ],
        ),
        bottomNavigationBar: useRail ? null : navBar,
      ),
    );
  }
}
