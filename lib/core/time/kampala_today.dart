import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/di/providers.dart';
import 'clock.dart';
import 'kampala_time.dart';

/// Local calendar date in Africa/Kampala (date-only, no time component).
DateTime kampalaCalendarDate(DateTime instantUtc, Clock clock) {
  KampalaTime.ensureInitialized();
  final local = tz.TZDateTime.from(instantUtc, KampalaTime.location);
  return DateTime(local.year, local.month, local.day);
}

/// Refreshes after each app resume so "today" lists stay correct overnight.
final kampalaTodayProvider = Provider<DateTime>((ref) {
  ref.watch(lifecycleResumeCountProvider); // bump on app resume
  final clock = ref.watch(clockProvider);
  return kampalaCalendarDate(clock.now(), clock);
});

final lifecycleResumeCountProvider =
    NotifierProvider<LifecycleResumeCount, int>(LifecycleResumeCount.new);

class LifecycleResumeCount extends Notifier<int> {
  @override
  int build() => 0;

  void onResume() => state++;
}
