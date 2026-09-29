import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/user_messages.dart';
import '../domain/auth_repository.dart';
import 'login_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginUiState>(LoginController.new);

class LoginController extends Notifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginUiState();

  void setFormMode(AuthFormMode mode) {
    state = state.copyWith(formMode: mode, clearError: true, status: LoginStatus.idle);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setOnline(bool online) {
    if (state.isOnline != online) {
      state = state.copyWith(isOnline: online);
    }
  }

  Future<AuthSessionResult?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!state.isOnline) {
      state = state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Connect to the internet to sign in.',
      );
      return null;
    }

    state = state.copyWith(status: LoginStatus.submitting, clearError: true);

    final auth = ref.read(authRepositoryProvider);
    final result = await auth.signInWithEmail(
      SignInRequest(email: email, password: password),
    );

    return result.when(
      success: (session) {
        state = state.copyWith(status: LoginStatus.success);
        ref.invalidate(hasAuthSnapshotProvider);
        ref.invalidate(userProfileProvider);
        ref.invalidate(farmProfileIncompleteProvider);
        ref.read(syncSchedulerProvider).onForeground();
        return session;
      },
      failure: (failure) {
        state = state.copyWith(
          status: LoginStatus.failure,
          errorMessage: userMessageForFailure(failure),
        );
        return null;
      },
    );
  }

  Future<AuthSessionResult?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!state.isOnline) {
      state = state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Connect to the internet to create an account.',
      );
      return null;
    }

    state = state.copyWith(status: LoginStatus.submitting, clearError: true);

    final auth = ref.read(authRepositoryProvider);
    final result = await auth.signUpWithEmail(
      SignUpRequest(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );

    return result.when(
      success: (session) {
        state = state.copyWith(status: LoginStatus.success);
        ref.invalidate(hasAuthSnapshotProvider);
        ref.invalidate(userProfileProvider);
        ref.invalidate(farmProfileIncompleteProvider);
        return session;
      },
      failure: (failure) {
        state = state.copyWith(
          status: LoginStatus.failure,
          errorMessage: userMessageForFailure(failure),
        );
        return null;
      },
    );
  }

  Future<void> continueWithDemoSession() async {
    state = state.copyWith(status: LoginStatus.submitting, clearError: true);
    await ref.read(authSnapshotRepositoryProvider).saveDemoSnapshot();
    state = state.copyWith(status: LoginStatus.success);
    ref.invalidate(hasAuthSnapshotProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(farmProfileIncompleteProvider);
  }
}
