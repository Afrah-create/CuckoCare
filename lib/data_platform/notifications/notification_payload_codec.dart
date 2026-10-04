import 'dart:convert';

String encodeNotificationPayload({
  required String routePath,
  required String contentHash,
}) {
  return jsonEncode({'p': routePath, 'h': contentHash});
}

String? decodeNotificationRoute(String? payload) {
  if (payload == null || payload.isEmpty) {
    return null;
  }
  try {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return map['p'] as String?;
  } catch (_) {
    if (payload.startsWith('/')) {
      return payload;
    }
    return null;
  }
}

String? decodeNotificationContentHash(String? payload) {
  if (payload == null || payload.isEmpty) {
    return null;
  }
  try {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return map['h'] as String?;
  } catch (_) {
    return null;
  }
}
