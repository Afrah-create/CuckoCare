import '../../../core/error/result.dart';

class SignInRequest {
  const SignInRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignUpRequest {
  const SignUpRequest({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}

/// Result of a successful sign-in or sign-up.
class AuthSessionResult {
  const AuthSessionResult({required this.needsFarmSetup});

  /// True when the user has no farm membership yet (onboarding required).
  final bool needsFarmSetup;
}

abstract class AuthRepository {
  Future<Result<AuthSessionResult>> signInWithEmail(SignInRequest request);

  Future<Result<AuthSessionResult>> signUpWithEmail(SignUpRequest request);

  Future<Result<AuthSessionResult>> refreshMembershipFromServer();

  Future<void> signOut();
}
