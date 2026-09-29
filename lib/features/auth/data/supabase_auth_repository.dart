import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/auth_repository.dart';
import 'auth_snapshot_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required AuthSnapshotRepository snapshotRepository,
    SupabaseClient? client,
  })  : _snapshots = snapshotRepository,
        _client = client ?? Supabase.instance.client;

  final AuthSnapshotRepository _snapshots;
  final SupabaseClient _client;

  @override
  Future<Result<void>> signInWithEmail(SignInRequest request) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: request.email.trim(),
        password: request.password,
      );
      final user = response.user;
      if (user == null) {
        return const Error(AuthFailure('Sign-in failed. Try again.'));
      }
      await _snapshots.persistFromSupabaseUser(user);
      return const Success(null);
    } on AuthException catch (e) {
      return Error(AuthFailure(_mapAuthMessage(e.message)));
    } catch (e) {
      return Error(UnexpectedFailure('Sign-in failed: $e'));
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _snapshots.clear();
  }

  String _mapAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (lower.contains('network')) {
      return 'No connection. Check your internet and try again.';
    }
    return message;
  }
}
