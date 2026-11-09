/// Drop nulls and blank strings so Postgres never sees `''::uuid` (22P02).
Map<String, dynamic> sanitizeSyncPayload(Map<String, dynamic> payload) {
  final out = <String, dynamic>{};
  for (final entry in payload.entries) {
    final value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      out[entry.key] = trimmed;
      continue;
    }
    out[entry.key] = value;
  }
  return out;
}

/// Postgres / JSON numbers often arrive as [int], [double], or [String].
String? syncJsonString(dynamic value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

DateTime? syncJsonDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  final text = syncJsonString(value);
  if (text == null) {
    return null;
  }
  return DateTime.tryParse(text);
}

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
