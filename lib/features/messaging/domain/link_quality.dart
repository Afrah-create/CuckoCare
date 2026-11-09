enum LinkQualityLevel { none, poor, fair, good }

class LinkQualitySample {
  const LinkQualitySample({
    required this.rttMs,
    required this.bytesPerSecond,
    required this.metered,
    required this.dataSaver,
  });

  final double rttMs;
  final double bytesPerSecond;
  final bool metered;
  final bool dataSaver;
}

class LinkQuality {
  LinkQuality({this.level = LinkQualityLevel.none});

  static const poorRttMs = 1500.0;
  static const poorBytesPerSecond = 30.0 * 1024;
  static const fairBytesPerSecond = 80.0 * 1024;
  static const hysteresis = 0.15;

  LinkQualityLevel level;
  double _ewmaRtt = 0;
  double _ewmaBps = 0;
  var _haveSample = false;

  void observe(LinkQualitySample sample) {
    if (!_haveSample) {
      _ewmaRtt = sample.rttMs;
      _ewmaBps = sample.bytesPerSecond;
      _haveSample = true;
    } else {
      _ewmaRtt = 0.3 * sample.rttMs + 0.7 * _ewmaRtt;
      _ewmaBps = 0.3 * sample.bytesPerSecond + 0.7 * _ewmaBps;
    }
    final next = classify(_ewmaRtt, _ewmaBps);
    if (next == level) return;
    if (!_crossesHysteresis(level, next, _ewmaRtt, _ewmaBps)) return;
    level = next;
  }

  static LinkQualityLevel classify(double rttMs, double bps) {
    if (bps <= 0 && rttMs <= 0) return LinkQualityLevel.none;
    if (rttMs > poorRttMs || bps < poorBytesPerSecond) {
      return LinkQualityLevel.poor;
    }
    if (bps < fairBytesPerSecond) return LinkQualityLevel.fair;
    return LinkQualityLevel.good;
  }

  static bool _crossesHysteresis(
    LinkQualityLevel current,
    LinkQualityLevel next,
    double rtt,
    double bps,
  ) {
    if (current == LinkQualityLevel.none) return true;
    final poorBps = poorBytesPerSecond;
    final fairBps = fairBytesPerSecond;
    if (current == LinkQualityLevel.poor && next == LinkQualityLevel.fair) {
      return bps > poorBps * (1 + hysteresis) && rtt < poorRttMs * (1 - hysteresis);
    }
    if (current == LinkQualityLevel.fair && next == LinkQualityLevel.poor) {
      return bps < poorBps * (1 - hysteresis) || rtt > poorRttMs * (1 + hysteresis);
    }
    if (current == LinkQualityLevel.fair && next == LinkQualityLevel.good) {
      return bps > fairBps * (1 + hysteresis);
    }
    if (current == LinkQualityLevel.good && next == LinkQualityLevel.fair) {
      return bps < fairBps * (1 - hysteresis);
    }
    return true;
  }
}
