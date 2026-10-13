import 'package:drift/drift.dart';

@DataClassName('BatchRow')
@TableIndex(name: 'batches_farm_status_idx', columns: {#farmId, #status})
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get name => text()();
  TextColumn get birdType => text()();
  IntColumn get initialCount => integer()();
  DateTimeColumn get acquiredOn => dateTime()();
  IntColumn get ageAtAcquisitionDays => integer().withDefault(const Constant(0))();
  BoolColumn get hatcheryVaccinated => boolean().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get status => text()();
  TextColumn get programmeId => text()();
  IntColumn get programmeVersion => integer()();
  TextColumn get productionType => text().nullable()();
  TextColumn get programmeContentHash => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get closedOn => dateTime().nullable()();
  TextColumn get closeReason => text().nullable()();
  TextColumn get closeNote => text().nullable()();
  TextColumn get deletedGroupId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
