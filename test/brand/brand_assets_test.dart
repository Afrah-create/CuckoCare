import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('brand asset files exist with expected sizes', () {
    expect(File('assets/brand/hen_mark_mask.png').existsSync(), isTrue);
    expect(File('assets/brand/splash_transparent.png').existsSync(), isTrue);
    expect(File('assets/brand/layers/anchors.json').existsSync(), isTrue);

    final splash = img.decodePng(
      File('assets/brand/splash_transparent.png').readAsBytesSync(),
    )!;
    expect(splash.width, 288);
    expect(splash.height, 288);

    final fg = img.decodePng(
      File('design/brand/out/launcher_foreground.png').readAsBytesSync(),
    )!;
    expect(fg.width, 1024);
    expect(fg.height, 1024);

    for (final dpi in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      expect(
        File('android/app/src/main/res/drawable-$dpi/ic_stat_hen.png')
            .existsSync(),
        isTrue,
      );
    }
  });

  test('masks have transparency and notification icons are white silhouette', () {
    final mask = img.decodePng(
      File('assets/brand/hen_mark_mask.png').readAsBytesSync(),
    )!;
    var transparent = 0;
    var opaque = 0;
    for (var y = 0; y < mask.height; y++) {
      for (var x = 0; x < mask.width; x++) {
        final p = mask.getPixel(x, y);
        final a = p.a.toInt();
        if (a < 16) {
          transparent++;
        } else if (a > 240) {
          opaque++;
        }
      }
    }
    expect(transparent, greaterThan(0));
    expect(opaque, greaterThan(0));

    final notif = img.decodePng(
      File('android/app/src/main/res/drawable-mdpi/ic_stat_hen.png')
          .readAsBytesSync(),
    )!;
    expect(notif.width, 24);
    for (var y = 0; y < notif.height; y++) {
      for (var x = 0; x < notif.width; x++) {
        final p = notif.getPixel(x, y);
        if (p.a > 0) {
          expect(p.r, 255);
          expect(p.g, 255);
          expect(p.b, 255);
        }
      }
    }
  });

  test('launcher foreground art sits in central 60% safe zone', () {
    final fg = img.decodePng(
      File('design/brand/out/launcher_foreground.png').readAsBytesSync(),
    )!;
    final margin = (1024 * 0.2).round();
    var minX = 1024, minY = 1024, maxX = 0, maxY = 0;
    for (var y = 0; y < fg.height; y++) {
      for (var x = 0; x < fg.width; x++) {
        if (fg.getPixel(x, y).a > 24) {
          minX = minX < x ? minX : x;
          minY = minY < y ? minY : y;
          maxX = maxX > x ? maxX : x;
          maxY = maxY > y ? maxY : y;
        }
      }
    }
    expect(minX, greaterThanOrEqualTo(margin));
    expect(minY, greaterThanOrEqualTo(margin));
    expect(maxX, lessThanOrEqualTo(1024 - margin));
    expect(maxY, lessThanOrEqualTo(1024 - margin));
  });

  test('layer masks compose near full mark', () {
    final anchors = jsonDecode(
      File('assets/brand/layers/anchors.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final w = anchors['width'] as int;
    final h = anchors['height'] as int;

    Uint8List loadAlpha(String name) {
      final im = img.decodePng(
        File('assets/brand/layers/${name}_mask.png').readAsBytesSync(),
      )!;
      return Uint8List.fromList(
        List.generate(w * h, (i) {
          final x = i % w;
          final y = i ~/ w;
          return im.getPixel(x, y).a.toInt();
        }),
      );
    }

    final full = img.decodePng(
      File('assets/brand/hen_mark_mask.png').readAsBytesSync(),
    )!;
    final composed = List<int>.filled(w * h, 0);
    for (final layer in ['hen', 'egg_left', 'egg_mid', 'egg_right']) {
      final a = loadAlpha(layer);
      for (var i = 0; i < composed.length; i++) {
        composed[i] = composed[i] > a[i] ? composed[i] : a[i];
      }
    }

    var maxDiff = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final f = full.getPixel(x, y).a.toInt();
        final c = composed[y * w + x];
        maxDiff = maxDiff > (f - c).abs() ? maxDiff : (f - c).abs();
      }
    }
    expect(maxDiff, lessThanOrEqualTo(1));
  });
}
