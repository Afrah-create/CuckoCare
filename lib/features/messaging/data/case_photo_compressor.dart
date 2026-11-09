import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../domain/media_policy.dart';

class CompressedPhoto {
  const CompressedPhoto({
    required this.bytes,
    required this.thumbB64,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String thumbB64;
  final int width;
  final int height;
}

class CasePhotoCompressor {
  const CasePhotoCompressor();

  CompressedPhoto compress(Uint8List source, MediaDecision policy) {
    final decoded = img.decodeImage(source);
    if (decoded == null) {
      throw const FormatException('unreadable_image');
    }
    var work = decoded;
    if (work.width > policy.maxEdgePx || work.height > policy.maxEdgePx) {
      work = img.copyResize(
        work,
        width: work.width >= work.height ? policy.maxEdgePx : null,
        height: work.height > work.width ? policy.maxEdgePx : null,
        interpolation: img.Interpolation.linear,
      );
    }
    // Re-encode JPEG with no EXIF (image package does not copy GPS tags).
    var quality = policy.jpegQuality;
    var encoded = Uint8List.fromList(img.encodeJpg(work, quality: quality));
    while (encoded.length > policy.targetBytes && quality > 40) {
      quality -= 10;
      encoded = Uint8List.fromList(img.encodeJpg(work, quality: quality));
    }
    final thumb = img.copyResize(
      work,
      width: work.width >= work.height ? 96 : null,
      height: work.height > work.width ? 96 : null,
    );
    var thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: 50));
    var tq = 50;
    while (thumbBytes.length > 8192 && tq > 20) {
      tq -= 10;
      thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: tq));
    }
    return CompressedPhoto(
      bytes: encoded,
      thumbB64: base64Encode(thumbBytes),
      width: work.width,
      height: work.height,
    );
  }

  CompressedPhoto compressFile(File file, MediaDecision policy) {
    return compress(file.readAsBytesSync(), policy);
  }
}
