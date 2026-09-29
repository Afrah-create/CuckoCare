import 'package:drift/drift.dart';

@DataClassName('ProgrammeStepRow')
class ProgrammeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get programmeId => text()();
  TextColumn get name => text()();
  IntColumn get ageDays => integer()();
  TextColumn get location => text()();
  BoolColumn get optional => boolean().withDefault(const Constant(false))();
  IntColumn get dueWindowDaysBefore => integer().withDefault(const Constant(0))();
  IntColumn get dueWindowDaysAfter => integer().withDefault(const Constant(0))();
  TextColumn get recurringJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
