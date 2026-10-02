import 'package:cucocare/features/farms/domain/farm_gps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatFarmCoordinates uses fixed precision', () {
    final reading = FarmGpsReading(
      latitude: 0.34759612,
      longitude: 32.58245189,
      accuracyMeters: 12,
      capturedAt: _fixed,
    );
    expect(formatFarmCoordinates(reading), '0.34760°, 32.58245°');
  });

  test('formatGpsAccuracy formats meters and km', () {
    expect(formatGpsAccuracy(8.2), '± 8 m');
    expect(formatGpsAccuracy(1500), '± 1.5 km');
    expect(formatGpsAccuracy(null), 'Accuracy unknown');
  });
}

final _fixed = DateTime.utc(2026, 1, 15, 10);
