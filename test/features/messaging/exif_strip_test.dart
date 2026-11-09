import 'dart:typed_data';

import 'package:cucocare/features/messaging/domain/link_quality.dart';
import 'package:cucocare/features/messaging/domain/media_policy.dart';
import 'package:cucocare/features/messaging/data/case_photo_compressor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List geotaggedJpeg() {
  final image = img.Image(width: 32, height: 24);
  img.fill(image, color: img.ColorRgb8(40, 120, 40));
  final jpeg = img.encodeJpg(image, quality: 80);
  const payload = 'GPSLatitude:0/1,0/1,0/1';
  final comLen = payload.length + 2;
  final com = <int>[
    0xFF,
    0xFE,
    (comLen >> 8) & 0xFF,
    comLen & 0xFF,
    ...payload.codeUnits,
  ];
  return Uint8List.fromList([
    jpeg[0],
    jpeg[1],
    ...com,
    ...jpeg.sublist(2),
  ]);
}

void main() {
  test('re-encode strips GPS EXIF tags', () {
    final source = geotaggedJpeg();
    expect(String.fromCharCodes(source), contains('GPSLatitude'));
    final out = const CasePhotoCompressor().compress(
      source,
      const MediaPolicy().decide(
        quality: LinkQualityLevel.good,
        metered: false,
        dataSaver: false,
        sizeBytes: source.length,
        userForced: true,
      ),
    );
    expect(String.fromCharCodes(out.bytes), isNot(contains('GPSLatitude')));
    expect(out.thumbB64.length, lessThan(12000));
    expect(out.bytes.length, lessThanOrEqualTo(300 * 1024));
  });
}
