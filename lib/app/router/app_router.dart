import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../di/providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(hasAuthSnapshotProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final loading = authAsync.isLoading;
      if (loading) {
        return null;
      }
      final authed = authAsync.value ?? false;
      final onLogin = state.matchedLocation == '/login';
      if (!authed && !onLogin) {
        return '/login';
      }
      if (authed && onLogin) {
        return '/home';
      }
      return null;
    },
    refreshListenable: _GoRouterRefresh(ref),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),
    ],
  );
});

class _GoRouterRefresh extends ChangeNotifier {
  _GoRouterRefresh(this._ref) {
    _ref.listen(hasAuthSnapshotProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}
