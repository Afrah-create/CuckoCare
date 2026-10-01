import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';
import '../../../data_platform/sync/remote_sync_api.dart';
import '../domain/auth_repository.dart';
import '../../farms/data/farm_repository.dart';
import 'auth_snapshot_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required AuthSnapshotRepository snapshotRepository,
    required FarmRepository farmRepository,
    required RemoteSyncApi remoteSyncApi,
    SupabaseClient? client,
  })  : _snapshots = snapshotRepository,
        _farms = farmRepository,
        _remote = remoteSyncApi,
        _client = client ?? Supabase.instance.client;

  final AuthSnapshotRepository _snapshots;
  final FarmRepository _farms;
  final RemoteSyncApi _remote;
  final SupabaseClient _client;

  @override
  Future<Result<AuthSessionResult>> signInWithEmail(SignInRequest request) async {
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
      return await refreshMembershipFromServer();
    } on AuthException catch (e) {
      return Error(AuthFailure(mapSupabaseAuthMessage(e.message)));
    } catch (e) {
      return Error(AuthFailure(userMessageForError(e)));
    }
  }

  @override
  Future<Result<AuthSessionResult>> signUpWithEmail(SignUpRequest request) async {
    final email = request.email.trim();
    final password = request.password;

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (request.displayName != null && request.displayName!.trim().isNotEmpty)
            'display_name': request.displayName!.trim(),
        },
      );

      Session? session = response.session;
      User? user = response.user;

      // No email confirmation flow — sign in immediately if sign-up did not return a session.
      if (session == null) {
        final signIn = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        session = signIn.session;
        user = signIn.user;
      }

      if (user == null) {
        return const Error(
          AuthFailure('Could not create your account. Try again or sign in.'),
        );
      }

      await _snapshots.persistFromSupabaseUser(user);
      return await refreshMembershipFromServer();
    } on AuthException catch (e) {
      return Error(AuthFailure(mapSupabaseAuthMessage(e.message)));
    } catch (e) {
      return Error(AuthFailure(userMessageForError(e)));
    }
  }

  @override
  Future<Result<AuthSessionResult>> refreshMembershipFromServer() async {
    final boot = await _remote.bootstrap();
    return boot.when(
      success: (data) async {
        await _farms.cacheBootstrapData(
          farms: data.farms,
          memberships: data.memberships,
        );
        final farmIds = data.farms
            .map((f) => f['id'])
            .whereType<String>()
            .toList();
        await _snapshots.setFarmIds(farmIds);
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          await _snapshots.alignSyncScopesForUser(
            userId: userId,
            farmScopeIds: farmIds,
          );
        }
        return Success(AuthSessionResult(needsFarmSetup: farmIds.isEmpty));
      },
      failure: (_) async {
        await _snapshots.setFarmIds([]);
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          await _snapshots.alignSyncScopesForUser(
            userId: userId,
            farmScopeIds: const [],
          );
        }
        return const Success(AuthSessionResult(needsFarmSetup: true));
      },
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Offline or server unreachable — still clear the device session.
      await _client.auth.signOut(scope: SignOutScope.local);
    }
    await _snapshots.clear();
  }
}
