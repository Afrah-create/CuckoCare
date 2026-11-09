import 'package:cucocare/data_platform/notifications/case_message_push_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('push payload is generic and has no message body', () {
    const builder = CaseMessagePushBuilder();
    final payload = builder.buildHttpV1(
      fcmToken: 'token',
      requestId: 'req-1',
    );
    final encoded = payload.toString();
    expect(encoded, isNot(contains('Birds')));
    expect(encoded, contains('New message on your vet request'));
    expect(payload['message']['data']['request_id'], 'req-1');
    expect(payload['message']['data'].containsKey('body'), isFalse);
    expect(
      payload['message']['android']['collapse_key'],
      'case_req-1',
    );
  });
}
