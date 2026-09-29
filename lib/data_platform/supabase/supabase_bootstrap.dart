import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import 'secure_local_storage.dart';

Future<void> bootstrapSupabase(Env env) async {
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );
}

SupabaseClient get supabaseClient => Supabase.instance.client;
