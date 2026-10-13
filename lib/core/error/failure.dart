sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// A business rule was broken. [message] is already user-facing copy.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'This item no longer exists.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'You do not have permission to do that.',
  ]);
}

final class SyncOffline extends Failure {
  const SyncOffline() : super('Offline');
}

final class SyncTimeout extends Failure {
  const SyncTimeout() : super('Sync timed out');
}

final class SyncServerFailure extends Failure {
  const SyncServerFailure(super.message, {required this.retryable});

  final bool retryable;
}

final class SyncAuthRequired extends Failure {
  const SyncAuthRequired() : super('Authentication required');
}

final class SyncRejected extends Failure {
  const SyncRejected(super.message, {this.errorCode});

  final String? errorCode;
}

final class SyncSchemaMismatch extends Failure {
  const SyncSchemaMismatch(super.message);
}

final class SyncSignedOutDemo extends Failure {
  const SyncSignedOutDemo() : super('Demo session — sync disabled');
}

final class LocationPermissionDenied extends Failure {
  const LocationPermissionDenied()
      : super('Location permission is required to capture your farm on the map.');
}

final class LocationPermissionPermanentlyDenied extends Failure {
  const LocationPermissionPermanentlyDenied()
      : super(
          'Location access was denied. Enable it in system settings to capture GPS.',
        );
}

final class LocationServiceDisabled extends Failure {
  const LocationServiceDisabled()
      : super('Turn on location services on this device, then try again.');
}

final class LocationCaptureTimeout extends Failure {
  const LocationCaptureTimeout()
      : super('Could not get a GPS fix in time. Move outdoors and try again.');
}
