import 'package:drift/drift.dart';

@DataClassName('OutboxRow')
class Outbox extends Table {
  TextColumn get opId => text()();
  TextColumn get targetTable => text()();
  TextColumn get rowId => text()();
  TextColumn get op => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {opId};
}
