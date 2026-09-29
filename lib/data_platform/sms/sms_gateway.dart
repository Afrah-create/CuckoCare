import '../../core/error/result.dart';

abstract class SmsGateway {
  Future<Result<void>> requestReminderSms({
    required String phoneE164,
    required String message,
  });
}
