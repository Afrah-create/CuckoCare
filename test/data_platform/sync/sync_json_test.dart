import 'package:cucocare/data_platform/sync/sync_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('syncJsonInt parses num and string', () {
    expect(syncJsonInt(42), 42);
    expect(syncJsonInt('99'), 99);
    expect(syncJsonInt(null), isNull);
  });

  test('syncJsonBool parses common forms', () {
    expect(syncJsonBool(true), isTrue);
    expect(syncJsonBool('1'), isTrue);
    expect(syncJsonBool('false'), isFalse);
  });

  test('sanitizeSyncPayload drops blank uuid strings', () {
    expect(
      sanitizeSyncPayload({
        'id': '01a18cea-e8a9-7c37-9b21-79777ef9b1b4',
        'farm_id': '  ',
        'requested_vet_user_id': '',
        'last_read_message_id': null,
        'muted': false,
      }),
      {
        'id': '01a18cea-e8a9-7c37-9b21-79777ef9b1b4',
        'muted': false,
      },
    );
  });
}
