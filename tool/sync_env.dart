// Syncs root `.env` into Flutter `env/*.json` (anon key + URL only in app bundle).
//
// Usage: dart run tool/sync_env.dart [dev|staging|prod]

import 'dart:convert';
import 'dart:io';

import 'package:cucocare/core/config/env.dart';

const _allowedInApp = {'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'ENV_NAME'};

void main(List<String> args) {
  final flavor = args.isEmpty ? 'dev' : args.first;
  if (!{'dev', 'staging', 'prod'}.contains(flavor)) {
    stderr.writeln('Usage: dart run tool/sync_env.dart [dev|staging|prod]');
    exit(1);
  }

  final envFile = File('.env');
  if (!envFile.existsSync()) {
    stderr.writeln('Missing .env — copy .env.example to .env and fill values.');
    exit(1);
  }

  final values = _parseDotEnv(envFile.readAsLinesSync());

  final out = <String, String>{};
  for (final key in _allowedInApp) {
    final v = values[key];
    if (v == null || v.isEmpty) {
      stderr.writeln('Missing or empty $key in .env');
      exit(1);
    }
    out[key] = v;
  }

  out['SUPABASE_URL'] = normalizeSupabaseUrl(out['SUPABASE_URL']!);

  if (flavor != 'dev') {
    out['ENV_NAME'] = flavor;
  }

  final target = File('env/$flavor.json');
  target.parent.createSync(recursive: true);
  target.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('Wrote ${target.path} from .env (app-safe keys only).');
  stdout.writeln('Supabase URL: ${out['SUPABASE_URL']}');
}

Map<String, String> _parseDotEnv(List<String> lines) {
  final values = <String, String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    final eq = trimmed.indexOf('=');
    if (eq <= 0) {
      continue;
    }
    final key = trimmed.substring(0, eq).trim();
    var value = trimmed.substring(eq + 1).trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    }
    values[key] = value;
  }
  return values;
}
