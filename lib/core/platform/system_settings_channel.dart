import 'package:flutter/services.dart';

class SystemSettingsChannel {
  SystemSettingsChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('ug.cucocare/system_settings');

  final MethodChannel _channel;

  Future<void> openAppNotificationSettings() async {
    try {
      await _channel.invokeMethod<void>('openAppNotificationSettings');
    } catch (_) {}
  }

  Future<void> openChannelSettings(String channelId) async {
    try {
      await _channel.invokeMethod<void>(
        'openChannelSettings',
        {'channelId': channelId},
      );
    } catch (_) {}
  }

  Future<void> openBatteryOptimizationSettings() async {
    try {
      await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
    } catch (_) {}
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
