import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/batches/presentation/batches_list_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/records/presentation/records_screen.dart';
import '../../features/auth/presentation/auth_shell.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/splash/splash_controller.dart';
import '../../features/today/presentation/today_screen.dart';
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

  final introDone = ref.read(splashIntroCompleteProvider);
  if (location == '/splash' && (!introDone || authAsync.isLoading)) {
    return null;
  }

  if (authAsync.isLoading) {
    if (location == '/splash') {
      return null;
    }
    if (location.startsWith('/auth/') || location == '/login') {
      return null;
    }
    return '/splash';
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
    final destination = from != null &&
            from.isNotEmpty &&
            !from.startsWith('/auth') &&
            from != '/splash'
        ? from
        : '/today';
    if (state.uri.path == destination) {
      return null;
    }
    return destination;
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

List<RouteBase> _authRoutes() {
  return [
    ShellRoute(
      builder: (context, state, child) => AuthShell(child: child),
      routes: [
        GoRoute(
          path: '/auth/login',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/auth/signup',
          redirect: (context, state) => '/auth/login',
        ),
        GoRoute(
          path: '/auth/forgot-password',
          pageBuilder: (context, state) => const NoTransitionPage<void>(
            child: ForgotPasswordScreen(),
          ),
        ),
      ],
    ),
  ];
}

List<RouteBase> _shellRoutes() {
  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: todayNavigatorKey,
          routes: [
            GoRoute(
              path: '/today',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const TodayScreen(),
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
          navigatorKey: feedNavigatorKey,
          routes: [
            _fadeTabRoot('/feed', const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: recordsNavigatorKey,
          routes: [
            _fadeTabRoot('/records', const RecordsScreen()),
          ],
        ),
        StatefulShellBranch(
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
  ref.keepAlive();
  final refresh = ref.watch(routerRefreshProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => _authRedirect(ref, state),
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      $splashRoute,
      ..._authRoutes(),
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
