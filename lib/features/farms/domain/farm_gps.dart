/// A single GPS fix for a farm (stored on the local farm row).
class FarmGpsReading {
  const FarmGpsReading({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime capturedAt;
}

/// Human-readable coordinates for farmers and vets (5 decimal places ≈ 1 m).
String formatFarmCoordinates(FarmGpsReading reading) {
  final lat = reading.latitude.toStringAsFixed(5);
  final lng = reading.longitude.toStringAsFixed(5);
  return '$lat°, $lng°';
}

String formatGpsAccuracy(double? meters) {
  if (meters == null || meters.isNaN || meters <= 0) {
    return 'Accuracy unknown';
  }
  if (meters < 1000) {
    return '± ${meters.round()} m';
  }
  return '± ${(meters / 1000).toStringAsFixed(1)} km';
}
