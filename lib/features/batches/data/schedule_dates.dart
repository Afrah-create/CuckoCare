import '../domain/calendar_date.dart';

DateTime dueOnToStorage(CalendarDate date) =>
    DateTime.utc(date.year, date.month, date.day);

CalendarDate dueOnFromStorage(DateTime stored) =>
    CalendarDate.fromDateTime(stored.toUtc());
