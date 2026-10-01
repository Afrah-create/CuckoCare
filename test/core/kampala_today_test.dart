import 'package:cucocare/core/time/clock.dart';
import 'package:cucocare/core/time/kampala_today.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedClock implements Clock {
  FixedClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;
}

void main() {
  test('kampalaCalendarDate uses Kampala zone', () {
    final clock = FixedClock(DateTime.utc(2026, 3, 15, 22, 0));
    final day = kampalaCalendarDate(clock.now(), clock);
    expect(day, DateTime(2026, 3, 16));
  });
}
