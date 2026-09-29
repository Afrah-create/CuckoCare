import 'package:drift/drift.dart';

@DataClassName('SyncLockRow')
class SyncLock extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get holder => text().nullable()();
  DateTimeColumn get leaseUntil => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
