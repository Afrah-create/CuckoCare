import '../../../core/error/result.dart';

class SignInRequest {
  const SignInRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

abstract class AuthRepository {
  Future<Result<void>> signInWithEmail(SignInRequest request);

  Future<void> signOut();
}
