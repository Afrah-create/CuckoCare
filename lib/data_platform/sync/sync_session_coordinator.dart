import '../db/app_database.dart';

/// Keeps sync scopes aligned with the signed-in account (avoids pulling demo
/// or another user's farm scopes after login).
class SyncSessionCoordinator {
  SyncSessionCoordinator(this._db);

  final AppDatabase _db;

  static const _userIdMetaKey = 'sync_user_id';

  Future<void> alignWithAccount({
    required String userId,
    required List<String> farmScopeIds,
  }) async {
    final lastUser = await _db.syncMetaDao.getValue(_userIdMetaKey);
    if (lastUser != userId) {
      await _db.syncMetaDao.setValue('hydrated', 'false');
      await _db.syncDao.deleteAllScopes();
    }

    final allowed = {'reference', ...farmScopeIds};
    await _db.syncDao.removeScopesNotIn(allowed);
    for (final id in farmScopeIds) {
      await _db.syncDao.ensureScope(id);
    }
    await _db.syncDao.ensureScope('reference');
    await _db.syncMetaDao.setValue(_userIdMetaKey, userId);
  }

  Future<void> clearOnSignOut() async {
    await _db.syncMetaDao.setValue('hydrated', 'false');
    await _db.syncDao.deleteAllScopes();
    await _db.syncMetaDao.setValue(_userIdMetaKey, '');
  }
}
