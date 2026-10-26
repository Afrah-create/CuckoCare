import 'package:cucocare/features/vet/domain/vet_contact_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WhatsApp digits omit the plus', () {
    expect(VetContactLauncher.digitsForWhatsApp('0772123456'), '256772123456');
    expect(VetContactLauncher.digitsForWhatsApp('0414123456'), isNull);
  });

  test('normalizeUgandaPhone is total', () {
    expect(VetContactLauncher.normalizeUgandaPhone('0772123456'), '+256772123456');
    expect(VetContactLauncher.normalizeUgandaPhone('not-a-number'), isNull);
  });
}
