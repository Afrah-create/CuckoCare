import 'package:drift/drift.dart';

@DataClassName('AuthSnapshotRow')
class AuthSnapshot extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get userId => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get farmIdsJson => text()();
  TextColumn get appRole => text().withDefault(const Constant('farmer'))();
  DateTimeColumn get lastVerifiedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
