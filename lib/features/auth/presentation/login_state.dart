import '../domain/app_role.dart';
import '../domain/auth_repository.dart';

enum AuthFormMode { signIn, signUp }

enum LoginMethod { email, phone }

enum LoginStatus {
  idle,
  submitting,
  success,
  failure,
  awaitingEmailOtp,
}

class LoginUiState {
  const LoginUiState({
    this.status = LoginStatus.idle,
    this.formMode = AuthFormMode.signIn,
    this.method = LoginMethod.email,
    this.signUpRole = AppRole.farmer,
    this.errorMessage,
    this.infoMessage,
    this.obscurePassword = true,
    this.isOnline = true,
    this.otpEmail,
    this.otpPassword,
    this.otpPurpose,
  });

  final LoginStatus status;
  final AuthFormMode formMode;
  final LoginMethod method;
  final AppRole signUpRole;
  final String? errorMessage;
  final String? infoMessage;
  final bool obscurePassword;
  final bool isOnline;
  final String? otpEmail;
  final String? otpPassword;
  final EmailOtpPurpose? otpPurpose;

  bool get isSubmitting => status == LoginStatus.submitting;
  bool get awaitingEmailOtp =>
      status == LoginStatus.awaitingEmailOtp ||
      (otpEmail != null && otpPurpose != null);

  LoginUiState copyWith({
    LoginStatus? status,
    AuthFormMode? formMode,
    LoginMethod? method,
    AppRole? signUpRole,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
    bool? obscurePassword,
    bool? isOnline,
    String? otpEmail,
    String? otpPassword,
    EmailOtpPurpose? otpPurpose,
    bool clearOtp = false,
  }) {
    return LoginUiState(
      status: status ?? this.status,
      formMode: formMode ?? this.formMode,
      method: method ?? this.method,
      signUpRole: signUpRole ?? this.signUpRole,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isOnline: isOnline ?? this.isOnline,
      otpEmail: clearOtp ? null : (otpEmail ?? this.otpEmail),
      otpPassword: clearOtp ? null : (otpPassword ?? this.otpPassword),
      otpPurpose: clearOtp ? null : (otpPurpose ?? this.otpPurpose),
    );
  }
}
