import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/batches/presentation/batches_list_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/records/presentation/records_screen.dart';
import '../di/providers.dart';
import '../shell/app_shell.dart';
import '../widgets/not_found_screen.dart';
import 'navigator_keys.dart';
import 'router_refresh.dart';
import 'routes/typed_routes.dart';

export 'navigator_keys.dart';

bool _isAuthLocation(String location) {
  return location == '/splash' ||
      location.startsWith('/auth/') ||
      location == '/login';
}

String? _authRedirect(Ref ref, GoRouterState state) {
  final location = state.uri.path;
  final authAsync = ref.read(hasAuthSnapshotProvider);

  if (location == '/login') {
    return '/auth/login${state.uri.hasQuery ? '?${state.uri.query}' : ''}';
  }

  if (authAsync.isLoading) {
    return location == '/splash' ? null : '/splash';
  }

  if (authAsync.hasError) {
    return _isAuthLocation(location) && location != '/splash'
        ? null
        : '/auth/login';
  }

  final authed = authAsync.value ?? false;
  if (!authed) {
    if (_isAuthLocation(location)) {
      return null;
    }
    final from = Uri.encodeComponent(state.uri.toString());
    return '/auth/login?from=$from';
  }

  if (_isAuthLocation(location)) {
    final from = state.uri.queryParameters['from'];
    if (from != null &&
        from.isNotEmpty &&
        !from.startsWith('/auth') &&
        from != '/splash') {
      return from;
    }
    return '/today';
  }

  return null;
}

GoRoute _fadeTabRoot(String path, Widget child) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

List<RouteBase> _shellRoutes() {
  return [
    StatefulShellRoute.indexedStack(
      restorationScopeId: 'appShell',
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          restorationScopeId: 'todayBranch',
          navigatorKey: todayNavigatorKey,
          routes: [
            $todayRoute,
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'batchesBranch',
          navigatorKey: batchesNavigatorKey,
          routes: [
            GoRoute(
              path: '/batches',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const BatchesListScreen(),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'feedBranch',
          navigatorKey: feedNavigatorKey,
          routes: [
            _fadeTabRoot('/feed', const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'recordsBranch',
          navigatorKey: recordsNavigatorKey,
          routes: [
            _fadeTabRoot('/records', const RecordsScreen()),
          ],
        ),
        StatefulShellBranch(
          restorationScopeId: 'moreBranch',
          navigatorKey: moreNavigatorKey,
          routes: [
            GoRoute(
              path: '/more',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const MoreScreen(),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    restorationScopeId: 'router',
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => _authRedirect(ref, state),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      $splashRoute,
      $loginRoute,
      $signUpRoute,
      $forgotPasswordRoute,
      $batchNewRoute,
      $batchDetailRoute,
      $moreFarmRoute,
      $moreSyncRoute,
      ..._shellRoutes(),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
