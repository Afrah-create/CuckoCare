import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';

/// Signed URLs for private storage objects (valid ~1 hour).
final vetIncidentPhotoUrlsProvider =
    FutureProvider.family<List<String>, List<String>>((ref, objectKeys) async {
  if (objectKeys.isEmpty) {
    return const [];
  }
  final storage = ref.watch(healthIncidentPhotoStorageProvider);
  final urls = <String>[];
  for (final key in objectKeys) {
    if (key.trim().isEmpty) {
      continue;
    }
    try {
      urls.add(await storage.signedUrl(key.trim()));
    } catch (_) {
      // Skip failed keys; UI shows partial gallery.
    }
  }
  return urls;
});
