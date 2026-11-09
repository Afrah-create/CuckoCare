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
  $notificationsSettingsRoute,
  $feedItemDetailRoute,
  $findVetRoute,
  $caseMessagesRoute,
  $vetProfileRoute,
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
    GoRouteData.$route(
      path: 'edit',
      hasOverriddenOnExit: false,
      parentNavigatorKey: BatchEditRoute.$parentNavigatorKey,
      factory: $BatchEditRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'losses',
      hasOverriddenOnExit: false,
      parentNavigatorKey: BatchLossesRoute.$parentNavigatorKey,
      factory: $BatchLossesRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'losses/new',
      hasOverriddenOnExit: false,
      parentNavigatorKey: LossNewRoute.$parentNavigatorKey,
      factory: $LossNewRoute._fromState,
    ),
    GoRouteData.$route(
      path: 'losses/:lossId',
      hasOverriddenOnExit: false,
      parentNavigatorKey: LossEditRoute.$parentNavigatorKey,
      factory: $LossEditRoute._fromState,
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

mixin $BatchEditRoute on GoRouteData {
  static BatchEditRoute _fromState(GoRouterState state) =>
      BatchEditRoute(batchId: state.pathParameters['batchId']!);

  BatchEditRoute get _self => this as BatchEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/batches/${Uri.encodeComponent(_self.batchId)}/edit',
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

mixin $BatchLossesRoute on GoRouteData {
  static BatchLossesRoute _fromState(GoRouterState state) =>
      BatchLossesRoute(batchId: state.pathParameters['batchId']!);

  BatchLossesRoute get _self => this as BatchLossesRoute;

  @override
  String get location => GoRouteData.$location(
    '/batches/${Uri.encodeComponent(_self.batchId)}/losses',
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

mixin $LossNewRoute on GoRouteData {
  static LossNewRoute _fromState(GoRouterState state) =>
      LossNewRoute(batchId: state.pathParameters['batchId']!);

  LossNewRoute get _self => this as LossNewRoute;

  @override
  String get location => GoRouteData.$location(
    '/batches/${Uri.encodeComponent(_self.batchId)}/losses/new',
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

mixin $LossEditRoute on GoRouteData {
  static LossEditRoute _fromState(GoRouterState state) => LossEditRoute(
    batchId: state.pathParameters['batchId']!,
    lossId: state.pathParameters['lossId']!,
  );

  LossEditRoute get _self => this as LossEditRoute;

  @override
  String get location => GoRouteData.$location(
    '/batches/${Uri.encodeComponent(_self.batchId)}/losses/${Uri.encodeComponent(_self.lossId)}',
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

RouteBase get $notificationsSettingsRoute => GoRouteData.$route(
  path: '/more/settings/notifications',
  hasOverriddenOnExit: false,
  parentNavigatorKey: NotificationsSettingsRoute.$parentNavigatorKey,
  factory: $NotificationsSettingsRoute._fromState,
);

mixin $NotificationsSettingsRoute on GoRouteData {
  static NotificationsSettingsRoute _fromState(GoRouterState state) =>
      const NotificationsSettingsRoute();

  @override
  String get location => GoRouteData.$location('/more/settings/notifications');

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

RouteBase get $feedItemDetailRoute => GoRouteData.$route(
  path: '/feed/:feedItemId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: FeedItemDetailRoute.$parentNavigatorKey,
  factory: $FeedItemDetailRoute._fromState,
);

mixin $FeedItemDetailRoute on GoRouteData {
  static FeedItemDetailRoute _fromState(GoRouterState state) =>
      FeedItemDetailRoute(feedItemId: state.pathParameters['feedItemId']!);

  FeedItemDetailRoute get _self => this as FeedItemDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/feed/${Uri.encodeComponent(_self.feedItemId)}');

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

RouteBase get $findVetRoute => GoRouteData.$route(
  path: '/more/vets',
  hasOverriddenOnExit: false,
  parentNavigatorKey: FindVetRoute.$parentNavigatorKey,
  factory: $FindVetRoute._fromState,
);

mixin $FindVetRoute on GoRouteData {
  static FindVetRoute _fromState(GoRouterState state) => const FindVetRoute();

  @override
  String get location => GoRouteData.$location('/more/vets');

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

RouteBase get $caseMessagesRoute => GoRouteData.$route(
  path: '/cases/:requestId/messages',
  hasOverriddenOnExit: false,
  parentNavigatorKey: CaseMessagesRoute.$parentNavigatorKey,
  factory: $CaseMessagesRoute._fromState,
);

mixin $CaseMessagesRoute on GoRouteData {
  static CaseMessagesRoute _fromState(GoRouterState state) => CaseMessagesRoute(
    requestId: state.pathParameters['requestId']!,
    farmId: state.uri.queryParameters['farm-id'],
    status: state.uri.queryParameters['status'],
    priority: state.uri.queryParameters['priority'],
    summary: state.uri.queryParameters['summary'],
  );

  CaseMessagesRoute get _self => this as CaseMessagesRoute;

  @override
  String get location => GoRouteData.$location(
    '/cases/${Uri.encodeComponent(_self.requestId)}/messages',
    queryParams: {
      if (_self.farmId != null) 'farm-id': _self.farmId,
      if (_self.status != null) 'status': _self.status,
      if (_self.priority != null) 'priority': _self.priority,
      if (_self.summary != null) 'summary': _self.summary,
    },
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

RouteBase get $vetProfileRoute => GoRouteData.$route(
  path: '/vet/more/profile',
  hasOverriddenOnExit: false,
  parentNavigatorKey: VetProfileRoute.$parentNavigatorKey,
  factory: $VetProfileRoute._fromState,
);

mixin $VetProfileRoute on GoRouteData {
  static VetProfileRoute _fromState(GoRouterState state) =>
      const VetProfileRoute();

  @override
  String get location => GoRouteData.$location('/vet/more/profile');

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
