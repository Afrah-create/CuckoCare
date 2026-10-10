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
import '../../features/auth/domain/app_role.dart';
import '../di/providers.dart';
import '../shell/app_shell.dart';
import '../shell/vet_shell.dart';
import '../../features/vet/domain/vet_incident_detail.dart';
import '../../features/vet/presentation/vet_active_screen.dart';
import '../../features/vet/presentation/vet_incident_detail_screen.dart';
import '../../features/vet/presentation/vet_map_screen.dart';
import '../../features/vet/presentation/vet_more_screen.dart';
import '../../features/vet/presentation/vet_requests_screen.dart';
import '../widgets/not_found_screen.dart';
import 'navigator_keys.dart';
import 'role_redirect.dart';
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

  final roleGuard = roleBasedRedirect(ref, state, authed: authed);
  if (roleGuard != null) {
    return roleGuard;
  }

  if (_isAuthLocation(location)) {
    final roleAsync = ref.read(appRoleProvider);
    if (roleAsync.isLoading) {
      return '/splash';
    }
    final from = state.uri.queryParameters['from'];
    final role = roleAsync.value ?? AppRole.farmer;
    final home = defaultHomeForRole(role);
    final destination = from != null &&
            from.isNotEmpty &&
            !from.startsWith('/auth') &&
            from != '/splash'
        ? from
        : home;
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

List<RouteBase> _vetShellRoutes() {
  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return VetShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: vetRequestsNavigatorKey,
          routes: [
            GoRoute(
              path: '/vet',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const VetRequestsScreen(),
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
          navigatorKey: vetMapNavigatorKey,
          routes: [
            _fadeTabRoot('/vet/map', const VetMapScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: vetActiveNavigatorKey,
          routes: [
            _fadeTabRoot('/vet/active', const VetActiveScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: vetMoreNavigatorKey,
          routes: [
            _fadeTabRoot('/vet/more', const VetMoreScreen()),
          ],
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
      GoRoute(
        path: '/vet/incident',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final detail = state.extra! as VetIncidentDetail;
          return MaterialPage<void>(
            key: state.pageKey,
            child: VetIncidentDetailScreen(detail: detail),
          );
        },
      ),
      $batchNewRoute,
      $batchDetailRoute,
      $moreFarmRoute,
      $notificationsSettingsRoute,
      ..._vetShellRoutes(),
      ..._shellRoutes(),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
