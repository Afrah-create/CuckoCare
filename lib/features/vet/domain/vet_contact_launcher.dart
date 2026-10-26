import 'package:url_launcher/url_launcher.dart';

import '../../farms/domain/farm_phone.dart';

/// Opens WhatsApp, SMS (Airtel/MTN), or a phone dialer for a vet contact.
class VetContactLauncher {
  const VetContactLauncher._();

  /// Opens WhatsApp chat with [phone] (E.164 or local Uganda mobile).
  static Future<bool> whatsApp(String phone, {String? message}) async {
    final cleaned = digitsForWhatsApp(phone);
    if (cleaned == null) {
      return false;
    }
    final encoded = message != null ? Uri.encodeComponent(message) : null;

    final nativeUri = Uri.parse(
      encoded != null
          ? 'whatsapp://send?phone=$cleaned&text=$encoded'
          : 'whatsapp://send?phone=$cleaned',
    );
    if (await _tryLaunch(nativeUri)) {
      return true;
    }

    final webUri = Uri.parse(
      encoded != null
          ? 'https://wa.me/$cleaned?text=$encoded'
          : 'https://wa.me/$cleaned',
    );
    return _tryLaunch(webUri);
  }

  static Future<bool> sms(String phone, {String? body}) async {
    final normalized = tryNormalizeUgandaPhone(phone);
    if (normalized == null) {
      return false;
    }
    final smsto = Uri(
      scheme: 'smsto',
      path: normalized,
      queryParameters: body != null ? {'body': body} : null,
    );
    if (await _tryLaunch(smsto)) {
      return true;
    }

    final sms = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: body != null ? {'body': body} : null,
    );
    return _tryLaunch(sms);
  }

  static Future<bool> call(String phone) async {
    final normalized = tryNormalizeUgandaPhone(phone);
    if (normalized == null) {
      return false;
    }
    return _tryLaunch(Uri(scheme: 'tel', path: normalized));
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Digits only, no plus — for wa.me / WhatsApp.
  static String? digitsForWhatsApp(String raw) {
    final normalized = tryNormalizeUgandaPhone(raw);
    if (normalized == null) {
      return null;
    }
    return normalized.replaceAll(RegExp(r'\D'), '');
  }

  static String? normalizeUgandaPhone(String? raw) =>
      tryNormalizeUgandaPhone(raw);

  static bool looksLikeUgandaMobile(String? phone) {
    return tryNormalizeUgandaPhone(phone) != null;
  }
}
