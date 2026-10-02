import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/uuid_v7.dart';

/// Supabase Storage for batch health incident photos.
class HealthIncidentPhotoStorage {
  HealthIncidentPhotoStorage({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const bucketId = 'health-incident-images';

  final SupabaseClient _client;

  Future<String> persistPickedFile(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final incidentsDir = Directory(p.join(dir.path, 'health_incidents'));
    if (!await incidentsDir.exists()) {
      await incidentsDir.create(recursive: true);
    }
    final ext = p.extension(source.path).toLowerCase();
    final safeExt = ext == '.png' || ext == '.webp' ? ext : '.jpg';
    final dest = File(p.join(incidentsDir.path, '${newId()}$safeExt'));
    await source.copy(dest.path);
    return dest.path;
  }

  /// Uploads [localPaths] and returns storage object keys `{userId}/{healthId}/{file}`.
  Future<List<String>> uploadPhotos({
    required String healthRecordId,
    required List<String> localPaths,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in required to upload photos');
    }

    final keys = <String>[];
    for (final localPath in localPaths) {
      final file = File(localPath);
      if (!await file.exists()) {
        continue;
      }
      final ext = p.extension(localPath).toLowerCase();
      final objectName =
          '$userId/$healthRecordId/${newId()}${ext.isEmpty ? '.jpg' : ext}';
      await _client.storage.from(bucketId).upload(
            objectName,
            file,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _mimeForExt(ext),
            ),
          );
      keys.add(objectName);
    }
    return keys;
  }

  Future<String> signedUrl(String objectKey) {
    return _client.storage.from(bucketId).createSignedUrl(objectKey, 3600);
  }

  Future<Uint8List?> downloadBytes(String objectKey) async {
    return _client.storage.from(bucketId).download(objectKey);
  }

  static String? _mimeForExt(String ext) => switch (ext) {
        '.png' => 'image/png',
        '.webp' => 'image/webp',
        _ => 'image/jpeg',
      };
}
