import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../core/error/user_messages.dart';
import '../domain/app_role.dart';
import '../domain/auth_repository.dart';
import 'login_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginUiState>(LoginController.new);

class LoginController extends Notifier<LoginUiState> {
  @override
  LoginUiState build() => const LoginUiState();

  void setFormMode(AuthFormMode mode) {
    state = state.copyWith(
      formMode: mode,
      clearError: true,
      clearInfo: true,
      status: LoginStatus.idle,
    );
  }

  void setSignUpRole(AppRole role) {
    state = state.copyWith(signUpRole: role, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearInfo() {
    state = state.copyWith(clearInfo: true);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setOnline(bool online) {
    if (state.isOnline != online) {
      state = state.copyWith(isOnline: online);
    }
  }

  void resetForSignOut() {
    state = const LoginUiState();
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
        _afterLocalAuthWrite(ref);
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

    state = state.copyWith(
      status: LoginStatus.submitting,
      clearError: true,
      clearInfo: true,
    );

    final auth = ref.read(authRepositoryProvider);
    final result = await auth.signUpWithEmail(
      SignUpRequest(
        email: email,
        password: password,
        appRole: state.signUpRole,
        displayName: displayName,
      ),
    );

    return result.when(
      success: (session) {
        if (session.emailConfirmationPending) {
          state = state.copyWith(
            status: LoginStatus.emailConfirmationSent,
            infoMessage:
                'Account created. Confirm the email from Supabase, then sign in.',
          );
          return null;
        }
        state = state.copyWith(status: LoginStatus.success);
        _afterLocalAuthWrite(ref);
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

}

void _afterLocalAuthWrite(Ref ref) {
  ref.read(hasAuthSnapshotProvider.notifier).adoptAuthenticated();
  SchedulerBinding.instance.scheduleFrameCallback((_) {
    ref.invalidate(userProfileProvider);
    ref.invalidate(appRoleProvider);
    ref.invalidate(farmProfileIncompleteProvider);
    ref.invalidate(primaryFarmProvider);
    ref.invalidate(syncStatusProvider);
  });
}
