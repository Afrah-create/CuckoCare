/// Postgres / JSON numbers often arrive as [int], [double], or [String].
int? syncJsonInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

int syncJsonIntOrZero(dynamic value) => syncJsonInt(value) ?? 0;

bool syncJsonBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == 't' || lower == '1') {
      return true;
    }
    if (lower == 'false' || lower == 'f' || lower == '0') {
      return false;
    }
  }
  return defaultValue;
}
