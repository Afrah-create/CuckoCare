/// Runtime configuration from `--dart-define-from-file`.
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
        'Run with --dart-define-from-file=env/dev.json',
      );
    }
    return Env(
      supabaseUrl: url,
      supabaseAnonKey: anon,
      envName: name,
      offlineGraceDays: grace,
    );
  }

  bool get isDev => envName == 'dev';
}
