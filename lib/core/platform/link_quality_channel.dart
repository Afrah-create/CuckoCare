import 'package:flutter/services.dart';

class LinkCapabilities {
  const LinkCapabilities({
    required this.downstreamKbps,
    required this.upstreamKbps,
    required this.metered,
    required this.dataSaver,
  });

  final int downstreamKbps;
  final int upstreamKbps;
  final bool metered;
  final bool dataSaver;
}

class LinkQualityChannel {
  LinkQualityChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('ug.cucocare/system_settings');

  final MethodChannel _channel;

  Future<LinkCapabilities> read() async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'getLinkCapabilities',
      );
      if (raw == null) {
        return const LinkCapabilities(
          downstreamKbps: 0,
          upstreamKbps: 0,
          metered: false,
          dataSaver: false,
        );
      }
      return LinkCapabilities(
        downstreamKbps: (raw['downstreamKbps'] as num?)?.toInt() ?? 0,
        upstreamKbps: (raw['upstreamKbps'] as num?)?.toInt() ?? 0,
        metered: raw['metered'] as bool? ?? false,
        dataSaver: raw['dataSaver'] as bool? ?? false,
      );
    } catch (_) {
      return const LinkCapabilities(
        downstreamKbps: 0,
        upstreamKbps: 0,
        metered: false,
        dataSaver: false,
      );
    }
  }
}
