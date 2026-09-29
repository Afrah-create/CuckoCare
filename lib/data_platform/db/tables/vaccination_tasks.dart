import 'package:drift/drift.dart';

@DataClassName('VaccinationTaskRow')
class VaccinationTasks extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  TextColumn get stepId => text()();
  DateTimeColumn get dueOn => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get doneOn => dateTime().nullable()();
  TextColumn get productUsed => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
