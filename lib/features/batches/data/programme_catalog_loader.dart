import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import '../domain/programme_catalog.dart';

class ProgrammeCatalogLoader {
  ProgrammeCatalogLoader({this.assetPath = _defaultAssetPath});

  static const _defaultAssetPath =
      'assets/seed/uganda_poultry_vaccination_schedule.json';

  final String assetPath;

  Future<ProgrammeCatalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final bytes = utf8.encode(raw);
    final hash = sha256.convert(bytes).toString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ProgrammeCatalog.parse(json, contentHash: hash);
  }

  /// For unit tests — parse bytes without Flutter assets.
  static ProgrammeCatalog parseJson(String raw) {
    final bytes = utf8.encode(raw);
    final hash = sha256.convert(bytes).toString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ProgrammeCatalog.parse(json, contentHash: hash);
  }
}
