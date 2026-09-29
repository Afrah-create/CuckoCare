sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable']);
}

final class SyncFailure extends Failure {
  const SyncFailure(super.message);
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
