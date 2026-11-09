import 'link_quality.dart';

class MediaDecision {
  const MediaDecision({
    required this.sendNow,
    required this.maxEdgePx,
    required this.jpegQuality,
    required this.targetBytes,
  });

  final bool sendNow;
  final int maxEdgePx;
  final int jpegQuality;
  final int targetBytes;
}

class MediaPolicy {
  const MediaPolicy();

  MediaDecision decide({
    required LinkQualityLevel quality,
    required bool metered,
    required bool dataSaver,
    required int sizeBytes,
    required bool userForced,
  }) {
    if (userForced) {
      return const MediaDecision(
        sendNow: true,
        maxEdgePx: 800,
        jpegQuality: 70,
        targetBytes: 120 * 1024,
      );
    }
    if (quality == LinkQualityLevel.poor || (metered && dataSaver)) {
      return const MediaDecision(
        sendNow: false,
        maxEdgePx: 800,
        jpegQuality: 70,
        targetBytes: 120 * 1024,
      );
    }
    if (quality == LinkQualityLevel.fair) {
      return const MediaDecision(
        sendNow: true,
        maxEdgePx: 800,
        jpegQuality: 70,
        targetBytes: 120 * 1024,
      );
    }
    return const MediaDecision(
      sendNow: true,
      maxEdgePx: 1280,
      jpegQuality: 80,
      targetBytes: 300 * 1024,
    );
  }
}
