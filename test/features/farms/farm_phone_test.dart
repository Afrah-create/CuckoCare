import 'package:cucocare/features/farms/domain/farm_phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeUgandaPhone adds country code', () {
    expect(normalizeUgandaPhone('712345678'), '+256712345678');
    expect(normalizeUgandaPhone('256712345678'), '+256712345678');
  });

  test('tryNormalizeUgandaPhone is total', () {
    expect(tryNormalizeUgandaPhone('0772123456'), '+256772123456');
    expect(tryNormalizeUgandaPhone('+256 772 123 456'), '+256772123456');
    expect(tryNormalizeUgandaPhone('256772123456'), '+256772123456');
    expect(tryNormalizeUgandaPhone('0772-123-456'), '+256772123456');
    expect(tryNormalizeUgandaPhone('0414123456'), isNull);
    expect(tryNormalizeUgandaPhone('0772'), isNull);
    expect(tryNormalizeUgandaPhone('abc'), isNull);
    expect(tryNormalizeUgandaPhone(''), isNull);
    expect(tryNormalizeUgandaPhone(null), isNull);
  });

  test('ugandaPhoneFieldText strips the country code for the form', () {
    expect(ugandaPhoneFieldText('+256712345678'), '712345678');
    expect(ugandaPhoneFieldText('0712345678'), '712345678');
    expect(ugandaPhoneFieldText(null), '');
  });
}
