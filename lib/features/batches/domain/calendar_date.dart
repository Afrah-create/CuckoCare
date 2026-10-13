/// Calendar date for schedule arithmetic (no time zone, no DST).
class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  factory CalendarDate.parseIso(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) {
      throw FormatException('Expected YYYY-MM-DD', iso);
    }
    return CalendarDate(
      year: int.parse(parts[0]),
      month: int.parse(parts[1]),
      day: int.parse(parts[2]),
    );
  }

  /// Local calendar components from [dateTime] (use Kampala-local wall date at call site).
  factory CalendarDate.fromDateTime(DateTime dateTime) {
    return CalendarDate(
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
    );
  }

  String toIso() {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) {
    final dt = toUtcDateTime().add(Duration(days: days));
    return CalendarDate(year: dt.year, month: dt.month, day: dt.day);
  }

  /// Signed day distance from this date to [other] ([other] - this).
  int daysUntil(CalendarDate other) {
    final a = toUtcDateTime();
    final b = other.toUtcDateTime();
    return b.difference(a).inDays;
  }

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    if (month != other.month) {
      return month.compareTo(other.month);
    }
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
