import '../../../core/error/result.dart';
import 'app_role.dart';

enum EmailOtpPurpose { signup, passwordReset }

extension EmailOtpPurposeWire on EmailOtpPurpose {
  String get wireValue =>
      this == EmailOtpPurpose.signup ? 'signup' : 'password_reset';
}

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
    required this.appRole,
    this.displayName,
  });

  final String email;
  final String password;
  final AppRole appRole;
  final String? displayName;
}

/// Result of a successful sign-in or sign-up.
class AuthSessionResult {
  const AuthSessionResult({
    required this.appRole,
    required this.needsFarmSetup,
    this.emailConfirmationPending = false,
  });

  final AppRole appRole;

  /// True when a farmer has no farm membership yet (onboarding required).
  final bool needsFarmSetup;

  /// Supabase created the user but session is withheld until email is confirmed.
  final bool emailConfirmationPending;
}

abstract class AuthRepository {
  Future<Result<AuthSessionResult>> signInWithEmail(SignInRequest request);

  Future<Result<AuthSessionResult>> signUpWithEmail(SignUpRequest request);

  Future<Result<void>> requestEmailOtp({
    required String email,
    required EmailOtpPurpose purpose,
    String? password,
    String? displayName,
    AppRole? appRole,
  });

  Future<Result<AuthSessionResult>> verifyEmailOtp({
    required String email,
    required String code,
    required EmailOtpPurpose purpose,
    String? password,
    String? newPassword,
  });

  Future<Result<AuthSessionResult>> refreshMembershipFromServer();

  Future<void> signOut();
}
