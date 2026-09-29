import 'package:cucocare/data_platform/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scaffolding for drift_dev schema export comparisons.
/// Generate baseline: `dart run drift_dev schema dump lib/data_platform/db/app_database.dart test/drift/schema_v1/`
void main() {
  test('schema v1 creates all core tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final tables = await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      readsFrom: {},
    ).get();

    final names = tables.map((r) => r.read<String>('name')).toSet();
    expect(names, contains('farms'));
    expect(names, contains('batches'));
    expect(names, contains('vaccination_tasks'));
    expect(names, contains('outbox'));
    expect(names, contains('auth_snapshot'));
  });
}
