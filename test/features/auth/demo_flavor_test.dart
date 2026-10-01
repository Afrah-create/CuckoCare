import 'package:cucocare/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('developer demo flag is dev and staging only', () {
    const dev = Env(
      supabaseUrl: 'https://x.supabase.co',
      supabaseAnonKey: 'k',
      envName: 'dev',
    );
    const staging = Env(
      supabaseUrl: 'https://x.supabase.co',
      supabaseAnonKey: 'k',
      envName: 'staging',
    );
    const prod = Env(
      supabaseUrl: 'https://x.supabase.co',
      supabaseAnonKey: 'k',
      envName: 'prod',
    );

    expect(dev.showDeveloperDemo, isTrue);
    expect(staging.showDeveloperDemo, isTrue);
    expect(prod.showDeveloperDemo, isFalse);
  });
}
