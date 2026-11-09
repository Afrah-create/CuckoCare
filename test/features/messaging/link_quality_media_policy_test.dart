import 'package:cucocare/features/messaging/domain/link_quality.dart';
import 'package:cucocare/features/messaging/domain/media_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hysteresis does not flap across the poor/fair boundary', () {
    final q = LinkQuality(level: LinkQualityLevel.poor);
    q.observe(
      const LinkQualitySample(
        rttMs: 1490,
        bytesPerSecond: 31 * 1024,
        metered: false,
        dataSaver: false,
      ),
    );
    expect(q.level, LinkQualityLevel.poor);
    q.observe(
      const LinkQualitySample(
        rttMs: 400,
        bytesPerSecond: 80 * 1024,
        metered: false,
        dataSaver: false,
      ),
    );
    expect(q.level, LinkQualityLevel.fair);
  });

  test('media policy table', () {
    const policy = MediaPolicy();
    expect(
      policy
          .decide(
            quality: LinkQualityLevel.good,
            metered: false,
            dataSaver: false,
            sizeBytes: 10,
            userForced: false,
          )
          .sendNow,
      isTrue,
    );
    expect(
      policy
          .decide(
            quality: LinkQualityLevel.poor,
            metered: false,
            dataSaver: false,
            sizeBytes: 10,
            userForced: false,
          )
          .sendNow,
      isFalse,
    );
    expect(
      policy
          .decide(
            quality: LinkQualityLevel.fair,
            metered: true,
            dataSaver: true,
            sizeBytes: 10,
            userForced: false,
          )
          .sendNow,
      isFalse,
    );
    expect(
      policy
          .decide(
            quality: LinkQualityLevel.poor,
            metered: true,
            dataSaver: true,
            sizeBytes: 10,
            userForced: true,
          )
          .sendNow,
      isTrue,
    );
  });
}
