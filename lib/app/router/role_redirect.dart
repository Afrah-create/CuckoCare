import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/app_role.dart';
import '../di/providers.dart';

/// Role-aware post-auth destination and cross-shell guards.
String? roleBasedRedirect(Ref ref, GoRouterState state, {required bool authed}) {
  if (!authed) {
    return null;
  }

  final location = state.uri.path;
  final roleAsync = ref.read(appRoleProvider);
  if (roleAsync.isLoading) {
    return null;
  }
  final role = roleAsync.value ?? AppRole.farmer;

  if (role == AppRole.vet && isFarmerOnlyAppPath(location)) {
    return AppRole.vet.homeLocation;
  }
  if (role == AppRole.farmer && isVetShellPath(location)) {
    return AppRole.farmer.homeLocation;
  }

  return null;
}

String defaultHomeForRole(AppRole role) => role.homeLocation;
