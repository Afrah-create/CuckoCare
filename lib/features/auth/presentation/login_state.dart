enum LoginMethod { email, phone }

enum LoginStatus { idle, submitting, success, failure }

class LoginUiState {
  const LoginUiState({
    this.status = LoginStatus.idle,
    this.method = LoginMethod.email,
    this.errorMessage,
    this.obscurePassword = true,
    this.isOnline = true,
  });

  final LoginStatus status;
  final LoginMethod method;
  final String? errorMessage;
  final bool obscurePassword;
  final bool isOnline;

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginUiState copyWith({
    LoginStatus? status,
    LoginMethod? method,
    String? errorMessage,
    bool clearError = false,
    bool? obscurePassword,
    bool? isOnline,
  }) {
    return LoginUiState(
      status: status ?? this.status,
      method: method ?? this.method,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
