/// Injectable clock for testable date/time logic.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now().toUtc();
}

class FixedClock implements Clock {
  FixedClock(this.fixed);

  final DateTime fixed;

  @override
  DateTime now() => fixed;
}
