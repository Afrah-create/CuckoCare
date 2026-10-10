import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../build_app_page.dart';
import '../../layout/page_layout.dart';
import '../../../features/splash/presentation/splash_screen.dart';
import '../../../features/auth/presentation/forgot_password_screen.dart';
import '../../../features/auth/presentation/login_screen.dart';
import '../../../features/auth/presentation/sign_up_screen.dart';
import '../../../features/batches/presentation/batch_detail_screen.dart';
import '../../../features/batches/presentation/batch_new_screen.dart';
import '../../../features/batches/presentation/batch_vaccination_task_screen.dart';
import '../../../features/farms/presentation/farm_setup_screen.dart';
import '../../../features/notifications/presentation/notifications_settings_screen.dart';
import '../../../features/settings/presentation/sync_diagnostics_screen.dart';
import '../../../features/today/presentation/today_screen.dart';
import '../navigator_keys.dart';

part 'typed_routes.g.dart';

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: '/auth/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.from});

  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<SignUpRoute>(path: '/auth/signup')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignUpScreen();
}

@TypedGoRoute<TodayRoute>(path: '/today')
class TodayRoute extends GoRouteData with $TodayRoute {
  const TodayRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TodayScreen();
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/auth/forgot-password')
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ForgotPasswordScreen();
}

@TypedGoRoute<BatchNewRoute>(path: '/batches/new')
class BatchNewRoute extends GoRouteData with $BatchNewRoute {
  const BatchNewRoute();

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => buildAppPage(
        preset: PageLayout.form,
        child: const BatchNewScreen(),
      );
}

@TypedGoRoute<BatchDetailRoute>(
  path: '/batches/:batchId',
  routes: [
    TypedGoRoute<BatchVaccinationTaskRoute>(
      path: 'vaccinations/:taskId',
    ),
  ],
)
class BatchDetailRoute extends GoRouteData with $BatchDetailRoute {
  const BatchDetailRoute({required this.batchId});

  final String batchId;

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BatchDetailScreen(batchId: batchId);
}

class BatchVaccinationTaskRoute extends GoRouteData with $BatchVaccinationTaskRoute {
  const BatchVaccinationTaskRoute({
    required this.batchId,
    required this.taskId,
  });

  final String batchId;
  final String taskId;

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BatchVaccinationTaskScreen(batchId: batchId, taskId: taskId);
}

@TypedGoRoute<MoreFarmRoute>(path: '/more/farm')
class MoreFarmRoute extends GoRouteData with $MoreFarmRoute {
  const MoreFarmRoute();

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => buildAppPage(
        preset: PageLayout.form,
        child: const FarmSetupScreen(),
      );
}

@TypedGoRoute<NotificationsSettingsRoute>(
  path: '/more/settings/notifications',
)
class NotificationsSettingsRoute extends GoRouteData
    with $NotificationsSettingsRoute {
  const NotificationsSettingsRoute();

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => buildAppPage(
        preset: PageLayout.form,
        child: const NotificationsSettingsScreen(),
      );
}

@TypedGoRoute<MoreSyncRoute>(path: '/more/sync')
class MoreSyncRoute extends GoRouteData with $MoreSyncRoute {
  const MoreSyncRoute();

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SyncDiagnosticsScreen();
}

@TypedGoRoute<VetSyncRoute>(path: '/vet/sync')
class VetSyncRoute extends GoRouteData with $VetSyncRoute {
  const VetSyncRoute();

  static GlobalKey<NavigatorState> get $parentNavigatorKey => rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SyncDiagnosticsScreen();
}
