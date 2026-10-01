import 'calendar_date.dart';

/// Hatch day (day 1) from acquisition date and age at acquisition.
CalendarDate hatchDate({
  required CalendarDate acquiredOn,
  required int ageAtAcquisitionDays,
}) {
  if (ageAtAcquisitionDays < 1) {
    throw ArgumentError.value(ageAtAcquisitionDays, 'ageAtAcquisitionDays');
  }
  return acquiredOn.addDays(-(ageAtAcquisitionDays - 1));
}

int ageDaysAt({
  required CalendarDate hatch,
  required CalendarDate today,
}) {
  return hatch.daysUntil(today) + 1;
}
