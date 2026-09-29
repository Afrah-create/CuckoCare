import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../di/providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run redirect when auth snapshot resolution changes (login / sign-out).
  final authAsync = ref.watch(hasAuthSnapshotProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;
      final loading = authAsync.isLoading;

      if (loading) {
        return location == '/splash' ? null : '/splash';
      }

      if (authAsync.hasError) {
        return location == '/login' ? null : '/login';
      }

      final authed = authAsync.value ?? false;
      if (!authed) {
        return location == '/login' ? null : '/login';
      }

      if (location == '/login' || location == '/splash') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const AuthSplashScreen(),
      ),
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
