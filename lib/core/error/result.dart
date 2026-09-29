import 'failure.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure err) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Error<T>(failure: final err) => failure(err),
    };
  }

  bool get isSuccess => this is Success<T>;
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Error<T>() => null,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
