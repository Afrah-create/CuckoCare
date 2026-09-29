import 'package:drift/drift.dart';

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get syncTable => text()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {syncTable};
}
