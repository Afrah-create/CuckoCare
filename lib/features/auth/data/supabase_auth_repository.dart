import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/error/user_messages.dart';
import '../../../data_platform/sync/remote_sync_api.dart';
import '../domain/app_role.dart';
import '../domain/auth_repository.dart';
import '../../farms/data/farm_repository.dart';
import 'auth_snapshot_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required AuthSnapshotRepository Function() readSnapshots,
    required FarmRepository Function() readFarms,
    required RemoteSyncApi remoteSyncApi,
    required Future<void> Function(String? userId) activateAccount,
    SupabaseClient? client,
  })  : _readSnapshots = readSnapshots,
        _readFarms = readFarms,
        _remote = remoteSyncApi,
        _activateAccount = activateAccount,
        _client = client ?? Supabase.instance.client;

  final AuthSnapshotRepository Function() _readSnapshots;
  final FarmRepository Function() _readFarms;
  final RemoteSyncApi _remote;
  final Future<void> Function(String? userId) _activateAccount;
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
      await _activateAccount(user.id);
      await _readSnapshots().persistFromSupabaseUser(user);
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
          'app_role': request.appRole.wireValue,
          if (request.displayName != null && request.displayName!.trim().isNotEmpty)
            'display_name': request.displayName!.trim(),
        },
      );

      Session? session = response.session;
      User? user = response.user;

      if (user == null) {
        return const Error(
          AuthFailure('Could not create your account. Try again or sign in.'),
        );
      }

      if (session == null && _needsEmailConfirmation(user)) {
        return Success(
          AuthSessionResult(
            appRole: request.appRole,
            needsFarmSetup: request.appRole == AppRole.farmer,
            emailConfirmationPending: true,
          ),
        );
      }

      if (session == null) {
        try {
          final signIn = await _client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          session = signIn.session;
          user = signIn.user ?? user;
        } on AuthException catch (e) {
          if (_isEmailNotConfirmedError(e.message)) {
            return Success(
              AuthSessionResult(
                appRole: request.appRole,
                needsFarmSetup: request.appRole == AppRole.farmer,
                emailConfirmationPending: true,
              ),
            );
          }
          return Error(AuthFailure(mapSupabaseAuthMessage(e.message)));
        }
      }

      if (session == null) {
        return Success(
          AuthSessionResult(
            appRole: request.appRole,
            needsFarmSetup: request.appRole == AppRole.farmer,
            emailConfirmationPending: true,
          ),
        );
      }

      await _activateAccount(user.id);
      await _readSnapshots().persistFromSupabaseUser(
        user,
        appRole: request.appRole,
      );
      return await refreshMembershipFromServer();
    } on AuthException catch (e) {
      return Error(AuthFailure(mapSupabaseAuthMessage(e.message)));
    } catch (e) {
      return Error(AuthFailure(userMessageForError(e)));
    }
  }

  @override
  Future<Result<AuthSessionResult>> refreshMembershipFromServer() async {
    final userId = _client.auth.currentUser?.id;
    final snapshots = _readSnapshots();
    final farms = _readFarms();
    final appRole = userId == null
        ? AppRole.farmer
        : await _fetchAndPersistAppRole(userId, snapshots);

    final boot = await _remote.bootstrap();
    return boot.when(
      success: (data) async {
        if (appRole == AppRole.farmer) {
          await farms.cacheBootstrapData(
            farms: data.farms,
            memberships: data.memberships,
          );
        }
        final serverFarmIds = appRole == AppRole.farmer
            ? data.farms.map((f) => f['id']).whereType<String>().toList()
            : <String>[];
        final scopeIds = await farms.mergeFarmScopeIds(serverFarmIds);
        await snapshots.setFarmIds(scopeIds);
        if (userId != null && appRole == AppRole.farmer) {
          await snapshots.alignSyncScopesForUser(
            userId: userId,
            farmScopeIds: scopeIds,
          );
        }
        return Success(_sessionResult(appRole, scopeIds));
      },
      failure: (_) async {
        final scopeIds = await farms.mergeFarmScopeIds(const []);
        await snapshots.setFarmIds(scopeIds);
        if (userId != null && appRole == AppRole.farmer) {
          await snapshots.alignSyncScopesForUser(
            userId: userId,
            farmScopeIds: scopeIds,
          );
        }
        return Success(_sessionResult(appRole, scopeIds));
      },
    );
  }

  AuthSessionResult _sessionResult(AppRole appRole, List<String> scopeIds) {
    return AuthSessionResult(
      appRole: appRole,
      needsFarmSetup: appRole == AppRole.farmer && scopeIds.isEmpty,
    );
  }

  Future<AppRole> _fetchAndPersistAppRole(
    String userId,
    AuthSnapshotRepository snapshots,
  ) async {
    try {
      final row = await _client
          .from('profiles')
          .select('app_role')
          .eq('user_id', userId)
          .maybeSingle();
      final role = AppRole.fromWire(row?['app_role'] as String?);
      await snapshots.setAppRole(role);
      return role;
    } catch (_) {
      return snapshots.loadAppRole();
    }
  }

  bool _needsEmailConfirmation(User user) {
    return user.emailConfirmedAt == null;
  }

  bool _isEmailNotConfirmedError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('email not confirmed') ||
        lower.contains('not confirmed');
  }

  @override
  Future<void> signOut() async {
    await _readSnapshots().clear();
    try {
      await _client.auth.signOut();
    } catch (_) {
      await _client.auth.signOut(scope: SignOutScope.local);
    }
    await _activateAccount(null);
  }
}
