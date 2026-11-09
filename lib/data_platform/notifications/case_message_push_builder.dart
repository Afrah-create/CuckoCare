/// Builds FCM HTTP v1 payloads. Never includes message text.
class CaseMessagePushBuilder {
  const CaseMessagePushBuilder();

  static const genericTitle = 'CucoCare';
  static const genericBody = 'New message on your vet request';

  Map<String, dynamic> buildHttpV1({
    required String fcmToken,
    required String requestId,
    String locale = 'en',
  }) {
    return {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': genericTitle,
          'body': _bodyFor(locale),
        },
        'data': {
          'type': 'case_message',
          'request_id': requestId,
        },
        'android': {
          'priority': 'HIGH',
          'collapse_key': 'case_$requestId',
          'ttl': '86400s',
          'notification': {
            'channel_id': 'case_messages',
            'tag': 'case_$requestId',
          },
        },
      },
    };
  }

  String _bodyFor(String locale) {
    // Structure ready for Luganda; English only for now.
    switch (locale) {
      case 'lg':
        return genericBody;
      default:
        return genericBody;
    }
  }
}
