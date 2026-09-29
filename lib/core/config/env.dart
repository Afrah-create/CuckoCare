/// Runtime configuration from `--dart-define-from-file=env/<flavor>.json`.
///
/// Generate that file from root `.env`: `dart run tool/sync_env.dart dev`
class Env {
  const Env({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.envName,
    this.offlineGraceDays = 30,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String envName;
  final int offlineGraceDays;

  static Env fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anon = String.fromEnvironment('SUPABASE_ANON_KEY');
    const name = String.fromEnvironment('ENV_NAME', defaultValue: 'dev');
    const grace = int.fromEnvironment('OFFLINE_GRACE_DAYS', defaultValue: 30);
    if (url.isEmpty || anon.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
        'Fill .env then run: dart run tool/sync_env.dart dev '
        'and flutter run --dart-define-from-file=env/dev.json',
      );
    }

    final normalizedUrl = normalizeSupabaseUrl(url);
    if (_looksLikePlaceholder(normalizedUrl, anon)) {
      throw StateError(
        'Supabase config is still a placeholder. '
        'Fill .env then run: dart run tool/sync_env.dart dev',
      );
    }

    return Env(
      supabaseUrl: normalizedUrl,
      supabaseAnonKey: anon.trim(),
      envName: name,
      offlineGraceDays: grace,
    );
  }

  bool get isDev => envName == 'dev';
}

/// Project URL only — not the REST or Auth path (strip `/rest/v1` if pasted).
String normalizeSupabaseUrl(String raw) {
  var u = raw.trim();
  while (u.endsWith('/')) {
    u = u.substring(0, u.length - 1);
  }
  const restSuffix = '/rest/v1';
  if (u.endsWith(restSuffix)) {
    u = u.substring(0, u.length - restSuffix.length);
  }
  return u;
}

bool _looksLikePlaceholder(String url, String anon) {
  final lower = url.toLowerCase();
  return lower.contains('placeholder') ||
      lower.contains('your_project') ||
      anon.toLowerCase().contains('placeholder') ||
      anon == 'your-anon-key';
}
