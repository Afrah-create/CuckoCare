import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data_platform/sync/sync_engine.dart';
import '../../features/auth/presentation/confirm_sign_out.dart';
import '../../features/auth/presentation/sign_out.dart';
import '../../features/home/presentation/profile_sheet.dart';
import '../di/providers.dart';
import '../layout/breakpoints.dart';
import '../layout/layout_profile.dart';
import '../layout/layout_scope.dart';
import '../layout/shell_chrome.dart';
import '../theme/app_spacing.dart';
import '../widgets/cuco_app_bar.dart';
import 'back_behavior.dart';
import 'vet_shell_destinations.dart';

class VetShell extends ConsumerStatefulWidget {
  const VetShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _titles = ['Requests', 'Map', 'Active cases', 'More'];

  @override
  ConsumerState<VetShell> createState() => _VetShellState();
}

class _VetShellState extends ConsumerState<VetShell> {
  Future<void> _signOut() async {
    if (!await confirmSignOut(context)) {
      return;
    }
    await signOutFromApp(ref);
  }

  void _openMoreTab() {
    widget.navigationShell.goBranch(3, initialLocation: false);
  }

  void _openProfile() {
    showProfileSheet(
      context,
      ref,
      onOpenSettings: _openMoreTab,
      onSignOut: _signOut,
    );
  }

  void _onDestinationSelected(int index) {
    final shell = widget.navigationShell;
    if (index == shell.currentIndex) {
      final router = GoRouter.of(context);
      while (router.canPop()) {
        router.pop();
      }
      return;
    }
    shell.goBranch(index, initialLocation: false);
  }

  NavigationRailLabelType _railLabelType(LayoutProfile profile) {
    return switch (profile) {
      LayoutProfile.tablet => NavigationRailLabelType.all,
      LayoutProfile.phoneLandscape => NavigationRailLabelType.selected,
      _ => NavigationRailLabelType.none,
    };
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
    final layout = context.layout;
    final useRail = layout.useRail;
    final hideTopBar = layout.hideTabRootAppBar;
    final railExtended = layout.size.width >= Breakpoints.railExtendedMinWidth;

    final rail = NavigationRail(
      extended: railExtended,
      selectedIndex: index,
      onDestinationSelected: _onDestinationSelected,
      labelType: _railLabelType(layout.profile),
      leading: const ShellRailLeading(),
      trailing: ShellRailTrailing(
        syncStatus: status,
        profileInitials: initials,
        onProfileTap: _openProfile,
      ),
      destinations: [
        for (final d in VetShellDestinations.tabs)
          NavigationRailDestination(
            icon: Icon(d.outlined),
            selectedIcon: Icon(d.filled),
            label: Text(d.label),
          ),
      ],
    );

    final navBar = NavigationBar(
      selectedIndex: index,
      onDestinationSelected: _onDestinationSelected,
      destinations: [
        for (final d in VetShellDestinations.tabs)
          NavigationDestination(
            icon: Icon(d.outlined),
            selectedIcon: Icon(d.filled),
            label: d.label,
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
        appBar: hideTopBar
            ? null
            : CucoAppBar(
                title: VetShell._titles[index],
                profileInitials: initials,
                onProfileTap: _openProfile,
                syncStatus: status,
                compact: layout.isCompactHeight,
              ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Offstage(
              offstage: !useRail,
              child: SizedBox(
                width: railExtended ? 256 : 80,
                child: rail,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: layout.maxContentWidth,
                  ),
                  child: shell,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: useRail
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom > 0
                      ? 0
                      : AppSpacing.xxs,
                ),
                child: navBar,
              ),
      ),
    );
  }
}
