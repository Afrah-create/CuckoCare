import '../domain/app_role.dart';

enum AuthFormMode { signIn, signUp }

enum LoginMethod { email, phone }

enum LoginStatus {
  idle,
  submitting,
  success,
  failure,
  emailConfirmationSent,
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
  });

  final LoginStatus status;
  final AuthFormMode formMode;
  final LoginMethod method;
  final AppRole signUpRole;
  final String? errorMessage;
  final String? infoMessage;
  final bool obscurePassword;
  final bool isOnline;

  bool get isSubmitting => status == LoginStatus.submitting;

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
    );
  }
}
