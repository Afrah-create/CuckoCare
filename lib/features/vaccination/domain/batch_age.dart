import '../../../core/time/clock.dart';
import '../../../core/time/kampala_time.dart';
import 'entities.dart';

/// Current flock age in whole days (Kampala calendar), from stored dates only.
int currentAgeDays(Batch batch, Clock clock) {
  final todayStart = KampalaTime.startOfDay(clock.now());
  final acquiredStart = KampalaTime.startOfDay(batch.acquiredOn);
  final daysSinceAcquisition =
      todayStart.difference(acquiredStart).inDays.clamp(0, 100000);
  return batch.ageAtAcquisitionDays + daysSinceAcquisition;
}
