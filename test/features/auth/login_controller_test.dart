import 'package:cucocare/app/di/providers.dart';
import 'package:cucocare/core/error/result.dart';
import 'package:cucocare/features/auth/domain/app_role.dart';
import 'package:cucocare/features/auth/domain/auth_repository.dart';
import 'package:cucocare/features/auth/presentation/login_controller.dart';
import 'package:cucocare/features/auth/presentation/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthSessionResult>> signInWithEmail(SignInRequest request) async {
    return const Success(
      AuthSessionResult(appRole: AppRole.farmer, needsFarmSetup: false),
    );
  }

  @override
  Future<Result<AuthSessionResult>> signUpWithEmail(SignUpRequest request) async {
    return Success(
      AuthSessionResult(
        appRole: request.appRole,
        needsFarmSetup: request.appRole == AppRole.farmer,
      ),
    );
  }

  @override
  Future<Result<AuthSessionResult>> refreshMembershipFromServer() async {
    return const Success(
      AuthSessionResult(appRole: AppRole.farmer, needsFarmSetup: false),
    );
  }

  @override
  Future<Result<void>> requestEmailOtp({
    required String email,
    required EmailOtpPurpose purpose,
    String? password,
    String? displayName,
    AppRole? appRole,
  }) async {
    return const Success(null);
  }

  @override
  Future<Result<AuthSessionResult>> verifyEmailOtp({
    required String email,
    required String code,
    required EmailOtpPurpose purpose,
    String? password,
    String? newPassword,
  }) async {
    return const Success(
      AuthSessionResult(appRole: AppRole.farmer, needsFarmSetup: false),
    );
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  test('signInWithEmail sets failure when offline', () async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(loginControllerProvider.notifier);
    notifier.setOnline(false);

    final session = await notifier.signInWithEmail(
      email: 'a@b.com',
      password: 'secret1',
    );

    expect(session, isNull);
    expect(container.read(loginControllerProvider).status, LoginStatus.failure);
  });
}
