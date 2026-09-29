import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_cursors.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncCursors])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<int> cursorFor(String tableName) async {
    final row = await (select(syncCursors)
          ..where((t) => t.syncTable.equals(tableName)))
        .getSingleOrNull();
    return row?.cursor ?? 0;
  }

  Future<void> setCursor(String tableName, int cursor) {
    return into(syncCursors).insertOnConflictUpdate(
      SyncCursorsCompanion.insert(
        syncTable: tableName,
        cursor: Value(cursor),
      ),
    );
  }

  Future<Map<String, int>> allCursors() async {
    final rows = await select(syncCursors).get();
    return {for (final r in rows) r.syncTable: r.cursor};
  }
}
