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
