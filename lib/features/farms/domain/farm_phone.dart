/// Local digits to show beside a +256 prefix.
String ugandaPhoneFieldText(String? stored) {
  if (stored == null || stored.trim().isEmpty) {
    return '';
  }
  final digits = stored.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('256')) {
    return digits.substring(3);
  }
  if (digits.length == 10 && digits.startsWith('0')) {
    return digits.substring(1);
  }
  if (digits.length == 9) {
    return digits;
  }
  return stored.trim();
}

/// Normalizes farmer-entered digits to E.164 for Uganda (+256…).
String normalizeUgandaPhone(String input) {
  return tryNormalizeUgandaPhone(input) ?? input.trim();
}

/// Returns E.164 (+256…) for a Uganda mobile, or null when the input is not
/// a complete 07x/03x (or +256 7/3…) number.
String? tryNormalizeUgandaPhone(String? input) {
  if (input == null) {
    return null;
  }
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return null;
  }
  String? e164;
  if (digits.length == 9) {
    e164 = '+256$digits';
  } else if (digits.length == 12 && digits.startsWith('256')) {
    e164 = '+$digits';
  } else if (digits.length == 10 && digits.startsWith('0')) {
    e164 = '+256${digits.substring(1)}';
  }
  if (e164 == null) {
    return null;
  }
  if (!RegExp(r'^\+256[37]\d{8}$').hasMatch(e164)) {
    return null;
  }
  return e164;
}
