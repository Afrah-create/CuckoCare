import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import 'remote_sync_api.dart';

/// Supabase RPC implementation (`sync_push`, `sync_pull`).
class SupabaseRemoteSyncApi implements RemoteSyncApi {
  // TODO: wire supabase client RPC when auth session is available.
  @override
  Future<Result<bool>> ping() async => const Success(false);

  @override
  Future<Result<SyncPullPage>> pull({
    required String tableName,
    required int cursor,
    required int pageSize,
  }) async {
    return const Error(SyncFailure('Supabase pull not wired in scaffold'));
  }

  @override
  Future<Result<SyncPushResult>> push(List<SyncPushOp> ops) async {
    return const Error(SyncFailure('Supabase push not wired in scaffold'));
  }
}
