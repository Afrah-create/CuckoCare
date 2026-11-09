import '../../../core/platform/link_quality_channel.dart';
import '../domain/link_quality.dart';

class LinkQualityService {
  LinkQualityService({
    LinkQualityChannel? channel,
    LinkQuality? quality,
  })  : _channel = channel ?? LinkQualityChannel(),
        _quality = quality ?? LinkQuality();

  final LinkQualityChannel _channel;
  final LinkQuality _quality;
  bool _metered = false;
  bool _dataSaver = false;

  LinkQualityLevel get level => _quality.level;
  bool get metered => _metered;
  bool get dataSaver => _dataSaver;

  Future<LinkQualityLevel> refresh({
    double? rttMs,
    double? bytesPerSecond,
  }) async {
    final caps = await _channel.read();
    _metered = caps.metered;
    _dataSaver = caps.dataSaver;
    final downstreamBps = caps.downstreamKbps * 1024 / 8;
    _quality.observe(
      LinkQualitySample(
        rttMs: rttMs ?? 0,
        bytesPerSecond: bytesPerSecond ?? downstreamBps,
        metered: caps.metered,
        dataSaver: caps.dataSaver,
      ),
    );
    return _quality.level;
  }

  void observeRequest({
    required double rttMs,
    required double bytesPerSecond,
  }) {
    _quality.observe(
      LinkQualitySample(
        rttMs: rttMs,
        bytesPerSecond: bytesPerSecond,
        metered: _metered,
        dataSaver: _dataSaver,
      ),
    );
  }
}
