import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../supabase/supabase_bootstrap.dart';
import 'sms_gateway.dart';

class MakyReachGateway implements SmsGateway {
  @override
  Future<Result<void>> requestReminderSms({
    required String phoneE164,
    required String message,
  }) async {
    try {
      await supabaseClient.functions.invoke(
        'makyreach-send',
        body: {
          'phone': phoneE164,
          'message': message,
        },
      );
      return const Success(null);
    } catch (e) {
      return Error(UnexpectedFailure('$e'));
    }
  }
}
