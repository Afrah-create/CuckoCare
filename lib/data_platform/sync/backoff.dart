import 'dart:math';

class ExponentialBackoff {
  ExponentialBackoff({
    this.baseMs = 1000,
    this.maxMs = 60000,
    Random? random,
  }) : _random = random ?? Random();

  final int baseMs;
  final int maxMs;
  final Random _random;

  Duration delayForAttempt(int attempt) {
    final exp = min(maxMs, baseMs * pow(2, attempt).toInt());
    final jitter = _random.nextInt(exp ~/ 4 + 1);
    return Duration(milliseconds: min(maxMs, exp + jitter));
  }
}
