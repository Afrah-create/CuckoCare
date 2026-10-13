import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp, SMS (Airtel/MTN), or a phone dialer for a vet contact.
class VetContactLauncher {
  const VetContactLauncher._();

  /// Opens WhatsApp chat with [phone] (E.164 format, e.g. +256701234567).
  /// Tries the native whatsapp:// scheme first; falls back to wa.me HTTPS.
  static Future<bool> whatsApp(String phone, {String? message}) async {
    final cleaned = _digitsOnly(phone); // wa.me needs digits only, no '+'
    final encoded = message != null ? Uri.encodeComponent(message) : null;

    // Native WhatsApp intent — most reliable on Android
    final nativeUri = Uri.parse(
      encoded != null
          ? 'whatsapp://send?phone=$cleaned&text=$encoded'
          : 'whatsapp://send?phone=$cleaned',
    );
    if (await _tryLaunch(nativeUri)) return true;

    // Fallback: wa.me HTTPS link (opens WhatsApp via browser → app handoff)
    final webUri = Uri.parse(
      encoded != null
          ? 'https://wa.me/$cleaned?text=$encoded'
          : 'https://wa.me/$cleaned',
    );
    return _tryLaunch(webUri);
  }

  /// Opens the native SMS app with [phone] pre-filled and optional [body].
  static Future<bool> sms(String phone, {String? body}) async {
    // Android prefers 'smsto:' with a body parameter
    final smsto = Uri(
      scheme: 'smsto',
      path: phone,
      queryParameters: body != null ? {'body': body} : null,
    );
    if (await _tryLaunch(smsto)) return true;

    // Fallback: plain 'sms:'
    final sms = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: body != null ? {'body': body} : null,
    );
    return _tryLaunch(sms);
  }

  /// Opens the phone dialer with [phone] pre-filled.
  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    return _tryLaunch(uri);
  }

  /// Launches [uri] without calling canLaunchUrl first — canLaunchUrl
  /// returns false on Android 11+ unless the package is in <queries>,
  /// but launchUrl itself works fine when the intent resolves.
  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Strips everything except digits (no '+') — used for wa.me / WhatsApp.
  static String _digitsOnly(String raw) {
    final normalized = normalizeUgandaPhone(raw);
    return normalized.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Formats a Uganda phone to E.164 if it starts with 07x or 03x.
  static String normalizeUgandaPhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) return trimmed;
    if (trimmed.startsWith('0')) return '+256${trimmed.substring(1)}';
    if (trimmed.startsWith('256')) return '+$trimmed';
    return trimmed;
  }

  /// True when the number looks like a valid Uganda mobile (MTN/Airtel).
  static bool looksLikeUgandaMobile(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final n = normalizeUgandaPhone(phone);
    return RegExp(r'^\+256[73]\d{8}$').hasMatch(n);
  }
}
