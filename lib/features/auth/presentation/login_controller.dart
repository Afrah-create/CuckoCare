import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../domain/auth_repository.dart';
import 'login_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginUiState>(LoginController.new);

class LoginController extends Notifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginUiState();

  void setMethod(LoginMethod method) {
    state = state.copyWith(method: method, clearError: true, status: LoginStatus.idle);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setOnline(bool online) {
    if (state.isOnline != online) {
      state = state.copyWith(isOnline: online);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!state.isOnline) {
      state = state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'First sign-in needs internet. Connect and try again.',
      );
      return false;
    }

    state = state.copyWith(status: LoginStatus.submitting, clearError: true);

    final auth = ref.read(authRepositoryProvider);
    final result = await auth.signInWithEmail(
      SignInRequest(email: email, password: password),
    );

    return result.when(
      success: (_) {
        state = state.copyWith(status: LoginStatus.success);
        ref.invalidate(hasAuthSnapshotProvider);
        ref.read(syncSchedulerProvider).onForeground();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  Future<void> continueWithDemoSession() async {
    state = state.copyWith(status: LoginStatus.submitting, clearError: true);
    await ref.read(authSnapshotRepositoryProvider).saveDemoSnapshot();
    state = state.copyWith(status: LoginStatus.success);
    ref.invalidate(hasAuthSnapshotProvider);
  }
}
