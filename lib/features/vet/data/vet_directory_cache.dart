import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/available_vet.dart';

class VetDirectoryCache {
  VetDirectoryCache({SharedPreferences? prefs}) : _prefs = prefs;

  static const ttl = Duration(days: 7);
  static const _prefix = 'vet_directory_v1_';

  final SharedPreferences? _prefs;

  Future<void> save({
    required String farmKey,
    required List<AvailableVet> vets,
    required DateTime fetchedAt,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$farmKey',
      jsonEncode({
        'fetchedAt': fetchedAt.toIso8601String(),
        'vets': vets.map((v) => v.toJson()).toList(),
      }),
    );
  }

  Future<({List<AvailableVet> vets, DateTime fetchedAt})?> load(
    String farmKey,
  ) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$farmKey');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final fetchedAt = DateTime.parse(map['fetchedAt'] as String);
      if (DateTime.now().toUtc().difference(fetchedAt.toUtc()) > ttl) {
        return null;
      }
      final list = map['vets'];
      if (list is! List) {
        return null;
      }
      final vets = list
          .whereType<Map<String, dynamic>>()
          .map(AvailableVet.fromJson)
          .where((v) => v.userId.isNotEmpty)
          .toList();
      return (vets: vets, fetchedAt: fetchedAt);
    } catch (_) {
      return null;
    }
  }
}
