import 'package:drift/drift.dart';

@DataClassName('MortalityRecordRow')
class MortalityRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  IntColumn get count => integer()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get cause => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
