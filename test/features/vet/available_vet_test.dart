import 'package:cucocare/features/vet/domain/available_vet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses int distance, null phone, and missing optional fields', () {
    final vet = AvailableVet.fromJson({
      'user_id': 'u1',
      'display_name': 'Dr. Amina',
      'distance_km': 3,
    });
    expect(vet.distanceKm, 3.0);
    expect(vet.phone, isNull);
    expect(vet.district, isNull);
    expect(vet.offersConsultation, isTrue);
  });

  test('parses null distance and empty list contract', () {
    final vet = AvailableVet.fromJson({
      'user_id': 'u2',
      'phone': '+256700000001',
      'distance_km': null,
    });
    expect(vet.displayName, 'Veterinarian');
    expect(vet.distanceKm, isNull);
    expect(vet.phone, '+256700000001');
  });

  test('does not keep coordinates even if a payload includes them', () {
    final vet = AvailableVet.fromJson({
      'user_id': 'u3',
      'display_name': 'Dr. X',
      'latitude': 0.3,
      'longitude': 32.5,
      'distance_km': 1.2,
    });
    expect(vet.toJson().containsKey('latitude'), isFalse);
    expect(vet.toJson().containsKey('longitude'), isFalse);
    expect(vet.distanceKm, 1.2);
  });
}
