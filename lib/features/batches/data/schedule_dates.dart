import '../domain/calendar_date.dart';

DateTime dueOnToStorage(CalendarDate date) =>
    DateTime.utc(date.year, date.month, date.day);

CalendarDate dueOnFromStorage(DateTime stored) =>
    CalendarDate.fromDateTime(stored.toUtc());

/// A Postgres `date` from sync JSON. `DateTime.parse` would give local
/// midnight, which reads back as the previous day east of UTC.
DateTime dateOnlyFromJson(String value) =>
    dueOnToStorage(CalendarDate.parseIso(value.substring(0, 10)));
