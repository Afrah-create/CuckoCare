import 'package:cucocare/features/farms/domain/farm_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeUgandaPhone adds country code', () {
    expect(normalizeUgandaPhone('712345678'), '+256712345678');
    expect(normalizeUgandaPhone('256712345678'), '+256712345678');
  });
}
