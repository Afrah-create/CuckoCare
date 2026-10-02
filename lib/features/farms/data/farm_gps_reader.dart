import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/farm_gps.dart';

/// Platform GPS access (permission + current position).
abstract class FarmGpsReader {
  Future<Result<FarmGpsReading>> captureCurrentPosition();
}

class DeviceFarmGpsReader implements FarmGpsReader {
  DeviceFarmGpsReader({Duration? timeLimit})
      : _timeLimit = timeLimit ?? const Duration(seconds: 25);

  final Duration _timeLimit;

  @override
  Future<Result<FarmGpsReading>> captureCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Error(LocationServiceDisabled());
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const Error(LocationPermissionDenied());
    }
    if (permission == LocationPermission.deniedForever) {
      return const Error(LocationPermissionPermanentlyDenied());
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _timeLimit,
        ),
      );
      return Success(
        FarmGpsReading(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
          capturedAt: position.timestamp.toUtc(),
        ),
      );
    } on LocationServiceDisabledException {
      return const Error(LocationServiceDisabled());
    } on PermissionDeniedException {
      return const Error(LocationPermissionDenied());
    } on TimeoutException {
      return const Error(LocationCaptureTimeout());
    } catch (e) {
      return Error(UnexpectedFailure('Could not read GPS: $e'));
    }
  }
}
