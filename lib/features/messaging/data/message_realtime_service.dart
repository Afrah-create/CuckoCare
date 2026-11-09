import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data_platform/supabase/supabase_bootstrap.dart';
import '../domain/link_quality.dart';

/// Realtime is a pull hint only. This service never writes local rows.
class MessageRealtimeService {
  MessageRealtimeService({
    required Future<void> Function() requestPull,
    required LinkQualityLevel Function() linkQuality,
  })  : _requestPull = requestPull,
        _linkQuality = linkQuality;

  final Future<void> Function() _requestPull;
  final LinkQualityLevel Function() _linkQuality;

  RealtimeChannel? _channel;
  Timer? _debounce;
  Timer? _poorPoll;
  String? _farmId;
  String? _requestId;

  void attach({String? farmId, String? requestId}) {
    _farmId = farmId;
    _requestId = requestId;
    try {
      if (_linkQuality() == LinkQualityLevel.poor) {
        _holdSocketOff();
        return;
      }
      _subscribe();
    } catch (_) {
      // Supabase or Realtime may be unavailable in tests and offline demos.
    }
  }

  void detach() {
    _debounce?.cancel();
    _poorPoll?.cancel();
    _channel?.unsubscribe();
    _channel = null;
  }

  void _holdSocketOff() {
    _channel?.unsubscribe();
    _channel = null;
    _poorPoll?.cancel();
    if (_requestId == null) return;
    _poorPoll = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(_requestPull());
    });
  }

  void _subscribe() {
    _poorPoll?.cancel();
    _channel?.unsubscribe();
    final name = _requestId != null
        ? 'case-radio-request-$_requestId'
        : 'case-radio-farm-$_farmId';
    var channel = supabaseClient.channel(name);
    if (_requestId != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'case_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'request_id',
          value: _requestId,
        ),
        callback: (_) => _hintPull(),
      );
    } else if (_farmId != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'case_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'farm_id',
          value: _farmId,
        ),
        callback: (_) => _hintPull(),
      );
    }
    _channel = channel..subscribe();
  }

  void _hintPull() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_requestPull());
    });
  }
}
