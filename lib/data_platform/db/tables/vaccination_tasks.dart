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
  IntColumn get occurrence => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueOn => dateTime()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get status => text()();
  DateTimeColumn get doneOn => dateTime().nullable()();
  TextColumn get doneBy => text().nullable()();
  TextColumn get productUsed => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get stepSnapshot => text().nullable()();
  TextColumn get programmeContentHash => text().nullable()();
  DateTimeColumn get shiftedFrom => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
