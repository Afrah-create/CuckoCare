import 'package:drift/drift.dart';

@DataClassName('HealthRecordRow')
class HealthRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get summary => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get affectedBirdCount => integer().nullable()();
  TextColumn get symptomsJson => text().withDefault(const Constant('[]'))();
  TextColumn get recordKind =>
      text().withDefault(const Constant('observation'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
