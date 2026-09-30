// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

img.Image _rgbaImage(int w, int h) =>
    img.Image(width: w, height: h, numChannels: 4);

/// Regenerates brand PNGs from [design/brand/source/chicken.jpeg].
void main() {
  const sourcePath = 'design/brand/source/chicken.jpeg';
  const lo = 18;
  const hi = 72;
  const brandCream = 0xFFFFF6E8;

  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing $sourcePath');
    exit(1);
  }

  final decoded = img.decodeJpg(sourceFile.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode JPEG');
    exit(1);
  }

  final w = decoded.width;
  final h = decoded.height;
  final alpha = List<int>.filled(w * h, 0);
  final darkRgb = <List<int>>[];

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = decoded.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final luma = ((r * 299 + g * 587 + b * 114) / 1000).round();
      final a = ((255 - luma - lo) * 255 / (hi - lo)).clamp(0, 255).round();
      alpha[y * w + x] = a;
      if (luma < 120 && a > 40) {
        darkRgb.add([r, g, b]);
      }
    }
  }

  darkRgb.sort((a, b) => (a[0] + a[1] + a[2]).compareTo(b[0] + b[1] + b[2]));
  final median = darkRgb.isEmpty ? [92, 64, 51] : darkRgb[darkRgb.length ~/ 2];
  final brandInk = (median[0] << 16) | (median[1] << 8) | median[2];

  var minX = w, minY = h, maxX = 0, maxY = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (alpha[y * w + x] > 24) {
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }
  }

  const pad = 12;
  minX = math.max(0, minX - pad);
  minY = math.max(0, minY - pad);
  maxX = math.min(w - 1, maxX + pad);
  maxY = math.min(h - 1, maxY + pad);
  final cropW = maxX - minX + 1;
  final cropH = maxY - minY + 1;

  img.Image cropAlpha(int ox, int oy, int cw, int ch) {
    final out = _rgbaImage(cw, ch);
    for (var y = 0; y < ch; y++) {
      for (var x = 0; x < cw; x++) {
        final a = alpha[(oy + y) * w + (ox + x)];
        out.setPixelRgba(x, y, 255, 255, 255, a);
      }
    }
    return out;
  }

  final fullCrop = cropAlpha(minX, minY, cropW, cropH);

  int alphaOf(img.Image src, int x, int y) =>
      src.getPixel(x, y).a.toInt();

  img.Image whiteMask(img.Image src) {
    final out = _rgbaImage(src.width, src.height);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final a = alphaOf(src, x, y);
        out.setPixelRgba(x, y, 255, 255, 255, a);
      }
    }
    return out;
  }

  img.Image dilate(img.Image src, int radius) {
    final out = img.Image.from(src);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        var maxA = 0;
        for (var dy = -radius; dy <= radius; dy++) {
          for (var dx = -radius; dx <= radius; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= src.width || ny >= src.height) {
              continue;
            }
            maxA = math.max(maxA, alphaOf(src, nx, ny));
          }
        }
        final p = out.getPixel(x, y);
        out.setPixelRgba(
          x,
          y,
          p.r.toInt(),
          p.g.toInt(),
          p.b.toInt(),
          maxA,
        );
      }
    }
    return out;
  }

  img.Image solidSilhouette(img.Image mask) {
    final queue = <List<int>>[];
    for (var x = 0; x < mask.width; x++) {
      if (alphaOf(mask, x, 0) < 128) {
        queue.add([x, 0]);
      }
      if (alphaOf(mask, x, mask.height - 1) < 128) {
        queue.add([x, mask.height - 1]);
      }
    }
    for (var y = 0; y < mask.height; y++) {
      if (alphaOf(mask, 0, y) < 128) {
        queue.add([0, y]);
      }
      if (alphaOf(mask, mask.width - 1, y) < 128) {
        queue.add([mask.width - 1, y]);
      }
    }
    final exterior = List<bool>.filled(mask.width * mask.height, false);
    while (queue.isNotEmpty) {
      final pop = queue.removeLast();
      final x = pop[0];
      final y = pop[1];
      if (x < 0 ||
          y < 0 ||
          x >= mask.width ||
          y >= mask.height ||
          exterior[y * mask.width + x]) {
        continue;
      }
      if (alphaOf(mask, x, y) >= 128) {
        continue;
      }
      exterior[y * mask.width + x] = true;
      queue.add([x + 1, y]);
      queue.add([x - 1, y]);
      queue.add([x, y + 1]);
      queue.add([x, y - 1]);
    }
    final out = _rgbaImage(mask.width, mask.height);
    for (var y = 0; y < mask.height; y++) {
      for (var x = 0; x < mask.width; x++) {
        final inside = !exterior[y * mask.width + x];
        out.setPixelRgba(x, y, 255, 255, 255, inside ? 255 : 0);
      }
    }
    return out;
  }

  final eggSplitY = (cropH * 0.58).round();
  img.Image layerFromRegion(bool Function(int lx, int ly) include) {
    final out = _rgbaImage(cropW, cropH);
    for (var y = 0; y < cropH; y++) {
      for (var x = 0; x < cropW; x++) {
        if (!include(x, y)) {
          continue;
        }
        final a = alphaOf(fullCrop, x, y);
        if (a > 0) {
          out.setPixelRgba(x, y, 255, 255, 255, a);
        }
      }
    }
    return out;
  }

  final third = cropW / 3;
  final eggLeft = layerFromRegion((x, y) => y >= eggSplitY && x < third);
  final eggMid = layerFromRegion(
    (x, y) => y >= eggSplitY && x >= third && x < third * 2,
  );
  final eggRight = layerFromRegion((x, y) => y >= eggSplitY && x >= third * 2);
  final henLayer = layerFromRegion((x, y) {
    if (y < eggSplitY) {
      return true;
    }
    return alphaOf(eggLeft, x, y) +
            alphaOf(eggMid, x, y) +
            alphaOf(eggRight, x, y) <
        30;
  });

  void writePng(img.Image image, String path) {
    File(path).parent.createSync(recursive: true);
    File(path).writeAsBytesSync(img.encodePng(image));
    print('Wrote $path');
  }

  writePng(whiteMask(fullCrop), 'assets/brand/hen_mark_mask.png');
  writePng(whiteMask(henLayer), 'assets/brand/layers/hen_mask.png');
  writePng(whiteMask(eggLeft), 'assets/brand/layers/egg_left_mask.png');
  writePng(whiteMask(eggMid), 'assets/brand/layers/egg_mid_mask.png');
  writePng(whiteMask(eggRight), 'assets/brand/layers/egg_right_mask.png');

  File('assets/brand/layers/anchors.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'width': cropW,
      'height': cropH,
      'layers': {
        'hen': {'x': 0, 'y': 0, 'width': cropW, 'height': cropH},
        'egg_left': {'x': 0, 'y': 0, 'width': cropW, 'height': cropH},
        'egg_mid': {'x': 0, 'y': 0, 'width': cropW, 'height': cropH},
        'egg_right': {'x': 0, 'y': 0, 'width': cropW, 'height': cropH},
      },
    }),
  );

  img.Image composeColoured(img.Image mask, {required int rgb}) {
    final r = (rgb >> 16) & 0xFF;
    final g = (rgb >> 8) & 0xFF;
    final b = rgb & 0xFF;
    final out = _rgbaImage(mask.width, mask.height);
    for (var y = 0; y < mask.height; y++) {
      for (var x = 0; x < mask.width; x++) {
        final a = alphaOf(mask, x, y);
        out.setPixelRgba(x, y, r, g, b, a);
      }
    }
    return out;
  }

  img.Image placeOnCanvas(img.Image art, int size, double artFraction) {
    final canvas = _rgbaImage(size, size);
    img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
    final target = (size * artFraction).round();
    final scale = math.min(target / art.width, target / art.height);
    final nw = (art.width * scale).round();
    final nh = (art.height * scale).round();
    final resized = img.copyResize(art, width: nw, height: nh);
    img.compositeImage(
      canvas,
      resized,
      dstX: (size - nw) ~/ 2,
      dstY: (size - nh) ~/ 2,
    );
    return canvas;
  }

  img.Image opaqueSquare(img.Image foreground, int size, int bgRgb) {
    final canvas = _rgbaImage(size, size);
    final r = (bgRgb >> 16) & 0xFF;
    final g = (bgRgb >> 8) & 0xFF;
    final b = bgRgb & 0xFF;
    img.fill(canvas, color: img.ColorRgba8(r, g, b, 255));
    img.compositeImage(canvas, foreground);
    return canvas;
  }

  void drawFlavorPill(img.Image canvas, String label) {
    const pillW = 180;
    const pillH = 56;
    final x = canvas.width - pillW - 48;
    final y = canvas.height - pillH - 48;
    img.fillRect(
      canvas,
      x1: x,
      y1: y,
      x2: x + pillW,
      y2: y + pillH,
      color: img.ColorRgba8(0, 0, 0, 180),
    );
    img.drawString(
      canvas,
      label,
      font: img.arial24,
      x: x + 36,
      y: y + 14,
      color: img.ColorRgba8(255, 255, 255, 255),
    );
  }

  final thickened = dilate(fullCrop, 1);
  final fgArt = composeColoured(thickened, rgb: brandInk);
  final fgCanvas = placeOnCanvas(fgArt, 1024, 0.58);
  writePng(fgCanvas, 'design/brand/out/launcher_foreground.png');

  for (final entry in [('dev', 'DEV'), ('staging', 'STG')]) {
    final copy = img.Image.from(fgCanvas);
    drawFlavorPill(copy, entry.$2);
    writePng(copy, 'design/brand/out/launcher_foreground_${entry.$1}.png');
  }

  writePng(
    placeOnCanvas(solidSilhouette(thickened), 1024, 0.58),
    'design/brand/out/launcher_monochrome.png',
  );

  final legacyFg = placeOnCanvas(fgArt, 1024, 0.70);
  writePng(
    opaqueSquare(legacyFg, 1024, brandCream),
    'design/brand/out/launcher_legacy.png',
  );
  for (final entry in [('dev', 'DEV'), ('staging', 'STG')]) {
    final copy = img.Image.from(legacyFg);
    drawFlavorPill(copy, entry.$2);
    writePng(
      opaqueSquare(copy, 1024, brandCream),
      'design/brand/out/launcher_legacy_${entry.$1}.png',
    );
  }

  writePng(
    opaqueSquare(placeOnCanvas(fgArt, 512, 0.72), 512, brandCream),
    'design/brand/out/play_store_icon_512.png',
  );

  final notifBase = solidSilhouette(fullCrop);
  for (final entry in [
    ('mdpi', 24),
    ('hdpi', 36),
    ('xhdpi', 48),
    ('xxhdpi', 72),
    ('xxxhdpi', 96),
  ]) {
    final size = entry.$2;
    writePng(
      img.copyResize(notifBase, width: size, height: size),
      'android/app/src/main/res/drawable-${entry.$1}/ic_stat_hen.png',
    );
  }

  final transparent = _rgbaImage(288, 288);
  img.fill(transparent, color: img.ColorRgba8(0, 0, 0, 0));
  writePng(transparent, 'assets/brand/splash_transparent.png');

  File('design/brand/out/brand_colours.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'brandInk':
          '#${brandInk.toRadixString(16).padLeft(6, '0').toUpperCase()}',
      'brandCream': '#FFF6E8',
      'splashBackgroundDark': '#1A1410',
    }),
  );

  print('brandInk=$brandInk crop=${cropW}x$cropH');
}
