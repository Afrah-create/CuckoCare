import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Africa/Kampala helpers for calendar-day boundaries and reminders.
class KampalaTime {
  static bool _initialized = false;

  static void ensureInitialized() {
    if (_initialized) {
      return;
    }
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static tz.Location get location {
    ensureInitialized();
    return tz.getLocation('Africa/Kampala');
  }

  static DateTime startOfDay(DateTime instantUtc) {
    final local = tz.TZDateTime.from(instantUtc, location);
    final start = tz.TZDateTime(location, local.year, local.month, local.day);
    return start.toUtc();
  }

  static DateTime endOfDay(DateTime instantUtc) {
    final local = tz.TZDateTime.from(instantUtc, location);
    final end = tz.TZDateTime(
      location,
      local.year,
      local.month,
      local.day,
      23,
      59,
      59,
      999,
    );
    return end.toUtc();
  }

  static bool isSameLocalDay(DateTime aUtc, DateTime bUtc) {
    final a = tz.TZDateTime.from(aUtc, location);
    final b = tz.TZDateTime.from(bUtc, location);
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Default reminder fire time: 07:00 local on [dueOnLocalDayUtc].
  static DateTime reminderAtSevenAm(DateTime dueOnUtc) {
    final local = tz.TZDateTime.from(dueOnUtc, location);
    final atSeven = tz.TZDateTime(
      location,
      local.year,
      local.month,
      local.day,
      7,
    );
    return atSeven.toUtc();
  }
}
