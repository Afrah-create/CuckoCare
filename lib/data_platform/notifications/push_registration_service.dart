import '../../core/time/clock.dart';
import '../db/app_database.dart';
import '../supabase/supabase_bootstrap.dart';
import 'push_availability.dart';

class PushRegistrationService {
  PushRegistrationService({
    required AppDatabase db,
    required Clock clock,
  })  : _db = db,
        _clock = clock;

  final AppDatabase _db;
  final Clock _clock;

  Future<void> registerIfAvailable({
    required bool permissionGranted,
    required bool vetMessagesEnabled,
    String platform = 'android',
  }) async {
    if (!kPushAvailable || !permissionGranted || !vetMessagesEnabled) {
      return;
    }
    // Firebase is not bundled until google-services.json exists per flavor.
  }

  Future<void> unregister(String token) async {
    if (!kPushAvailable || token.isEmpty) return;
    try {
      await supabaseClient.rpc(
        'unregister_push_token',
        params: {'p_token': token},
      );
    } catch (_) {}
    await _db.delete(_db.pushRegistrations).go();
  }

  DateTime now() => _clock.now();
}
