/// Normalizes farmer-entered digits to E.164 for Uganda (+256…).
String normalizeUgandaPhone(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 9) {
    return '+256$digits';
  }
  if (digits.length == 12 && digits.startsWith('256')) {
    return '+$digits';
  }
  if (digits.length == 10 && digits.startsWith('0')) {
    return '+256${digits.substring(1)}';
  }
  return input.trim();
}
