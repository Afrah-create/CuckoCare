import 'package:drift/drift.dart';

@DataClassName('VetAssistanceRequestRow')
class VetAssistanceRequests extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  TextColumn get batchId => text()();
  TextColumn get healthRecordId => text()();
  TextColumn get serviceType => text()();
  TextColumn get status => text()();
  BoolColumn get shareLocation => boolean().withDefault(const Constant(false))();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  TextColumn get farmerNotes => text().nullable()();
  TextColumn get assignedVetUserId => text().nullable()();
  TextColumn get requestedVetUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
