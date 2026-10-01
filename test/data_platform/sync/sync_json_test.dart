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
}
