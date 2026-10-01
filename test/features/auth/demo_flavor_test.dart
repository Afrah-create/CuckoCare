import 'package:cucocare/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('env flavor flags', () {
    const dev = Env(
      supabaseUrl: 'https://x.supabase.co',
      supabaseAnonKey: 'k',
      envName: 'dev',
    );
    const prod = Env(
      supabaseUrl: 'https://x.supabase.co',
      supabaseAnonKey: 'k',
      envName: 'prod',
    );

    expect(dev.isDev, isTrue);
    expect(prod.isProd, isTrue);
  });
}
