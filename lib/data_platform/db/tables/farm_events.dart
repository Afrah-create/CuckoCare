import 'package:drift/drift.dart';

@DataClassName('FarmEventRow')
class FarmEvents extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text().nullable()();
  TextColumn get eventType => text()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
