import 'package:cucocare/data_platform/db/local_database_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guest database name is stable', () {
    expect(localDatabaseNameForAccount(null), 'cucocare_guest');
    expect(localDatabaseNameForAccount(''), 'cucocare_guest');
  });

  test('user database name normalizes uuid', () {
    const id = 'b34df515-e7a4-4273-8ba8-9acf1e9e2804';
    expect(
      localDatabaseNameForAccount(id),
      'cucocare_u_b34df515e7a442738ba89acf1e9e2804',
    );
  });
}
