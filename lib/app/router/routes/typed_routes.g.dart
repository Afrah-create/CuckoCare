// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $loginRoute,
  $signUpRoute,
  $todayRoute,
  $forgotPasswordRoute,
  $batchNewRoute,
  $batchDetailRoute,
  $moreFarmRoute,
  $moreSyncRoute,
  $vetSyncRoute,
];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/auth/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) =>
      LoginRoute(from: state.uri.queryParameters['from']);

  LoginRoute get _self => this as LoginRoute;

  @override
  String get location => GoRouteData.$location(
    '/auth/login',
    queryParams: {if (_self.from != null) 'from': _self.from},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
  path: '/auth/signup',
  hasOverriddenOnExit: false,
  factory: $SignUpRoute._fromState,
);

mixin $SignUpRoute on GoRouteData {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  @override
  String get location => GoRouteData.$location('/auth/signup');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $todayRoute => GoRouteData.$route(
  path: '/today',
  hasOverriddenOnExit: false,
  factory: $TodayRoute._fromState,
);

mixin $TodayRoute on GoRouteData {
  static TodayRoute _fromState(GoRouterState state) => const TodayRoute();

  @override
  String get location => GoRouteData.$location('/today');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $forgotPasswordRoute => GoRouteData.$route(
  path: '/auth/forgot-password',
  hasOverriddenOnExit: false,
  factory: $ForgotPasswordRoute._fromState,
);

mixin $ForgotPasswordRoute on GoRouteData {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  @override
  String get location => GoRouteData.$location('/auth/forgot-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $batchNewRoute => GoRouteData.$route(
  path: '/batches/new',
  hasOverriddenOnExit: false,
  parentNavigatorKey: BatchNewRoute.$parentNavigatorKey,
  factory: $BatchNewRoute._fromState,
);

mixin $BatchNewRoute on GoRouteData {
  static BatchNewRoute _fromState(GoRouterState state) => const BatchNewRoute();

  @override
  String get location => GoRouteData.$location('/batches/new');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $batchDetailRoute => GoRouteData.$route(
  path: '/batches/:batchId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: BatchDetailRoute.$parentNavigatorKey,
  factory: $BatchDetailRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'vaccinations/:taskId',
      hasOverriddenOnExit: false,
      parentNavigatorKey: BatchVaccinationTaskRoute.$parentNavigatorKey,
      factory: $BatchVaccinationTaskRoute._fromState,
    ),
  ],
);

mixin $BatchDetailRoute on GoRouteData {
  static BatchDetailRoute _fromState(GoRouterState state) =>
      BatchDetailRoute(batchId: state.pathParameters['batchId']!);

  BatchDetailRoute get _self => this as BatchDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/batches/${Uri.encodeComponent(_self.batchId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BatchVaccinationTaskRoute on GoRouteData {
  static BatchVaccinationTaskRoute _fromState(GoRouterState state) =>
      BatchVaccinationTaskRoute(
        batchId: state.pathParameters['batchId']!,
        taskId: state.pathParameters['taskId']!,
      );

  BatchVaccinationTaskRoute get _self => this as BatchVaccinationTaskRoute;

  @override
  String get location => GoRouteData.$location(
    '/batches/${Uri.encodeComponent(_self.batchId)}/vaccinations/${Uri.encodeComponent(_self.taskId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $moreFarmRoute => GoRouteData.$route(
  path: '/more/farm',
  hasOverriddenOnExit: false,
  parentNavigatorKey: MoreFarmRoute.$parentNavigatorKey,
  factory: $MoreFarmRoute._fromState,
);

mixin $MoreFarmRoute on GoRouteData {
  static MoreFarmRoute _fromState(GoRouterState state) => const MoreFarmRoute();

  @override
  String get location => GoRouteData.$location('/more/farm');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $moreSyncRoute => GoRouteData.$route(
  path: '/more/sync',
  hasOverriddenOnExit: false,
  parentNavigatorKey: MoreSyncRoute.$parentNavigatorKey,
  factory: $MoreSyncRoute._fromState,
);

mixin $MoreSyncRoute on GoRouteData {
  static MoreSyncRoute _fromState(GoRouterState state) => const MoreSyncRoute();

  @override
  String get location => GoRouteData.$location('/more/sync');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $vetSyncRoute => GoRouteData.$route(
  path: '/vet/sync',
  hasOverriddenOnExit: false,
  parentNavigatorKey: VetSyncRoute.$parentNavigatorKey,
  factory: $VetSyncRoute._fromState,
);

mixin $VetSyncRoute on GoRouteData {
  static VetSyncRoute _fromState(GoRouterState state) => const VetSyncRoute();

  @override
  String get location => GoRouteData.$location('/vet/sync');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
