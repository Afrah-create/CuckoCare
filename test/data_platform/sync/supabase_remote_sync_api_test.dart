// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:cucocare/core/error/failure.dart';
import 'package:cucocare/data_platform/sync/supabase_remote_sync_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // We test _parsePushResponse via the @visibleForTesting wrapper.
  // No real Supabase client is needed — we pass a mock client stub.

  SupabaseRemoteSyncApi makeApi() {
    // Pass null to use the lazy singleton — but since we only test parsing,
    // we never call any network methods.  We construct directly so no client
    // initialisation is required.
    return _FakeApi();
  }

  group('_parsePushResponse', () {
    test('applied result is parsed correctly', () {
      final api = makeApi();
      final raw = {
        'epoch': 42,
        'results': [
          {
            'op_id': 'op-1',
            'status': 'applied',
            'server_version': 7,
            'row': {'id': 'row-1'},
            'error_code': null,
            'retryable': false,
            'duplicate': false,
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      expect(response.epoch, 42);
      expect(response.results, hasLength(1));
      final r = response.results.first;
      expect(r.opId, 'op-1');
      expect(r.status, 'applied');
      expect(r.serverVersion, 7);
      expect(r.isDuplicate, isFalse);
      expect(r.retryable, isFalse);
    });

    test('server_version as string is parsed to int', () {
      final api = makeApi();
      final raw = {
        'epoch': 1,
        'results': [
          {
            'op_id': 'op-2',
            'status': 'applied',
            'server_version': '99',
            'row': null,
            'retryable': false,
            'duplicate': false,
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      expect(response.results.first.serverVersion, 99);
    });

    test('duplicate:true sets isDuplicate and status preserved', () {
      final api = makeApi();
      final raw = {
        'epoch': 1,
        'results': [
          {
            'op_id': 'op-3',
            'status': 'applied',
            'server_version': 5,
            'row': null,
            'retryable': false,
            'duplicate': true,
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      final r = response.results.first;
      expect(r.isDuplicate, isTrue);
      expect(r.status, 'applied');
    });

    test('rejected retryable error', () {
      final api = makeApi();
      final raw = {
        'epoch': 1,
        'results': [
          {
            'op_id': 'op-4',
            'status': 'rejected',
            'error_code': 'fk_violation',
            'retryable': true,
            'duplicate': false,
            'row': null,
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      final r = response.results.first;
      expect(r.status, 'rejected');
      expect(r.retryable, isTrue);
      expect(r.errorCode, 'fk_violation');
      expect(r.isDuplicate, isFalse);
    });

    test('rejected non-retryable error', () {
      final api = makeApi();
      final raw = {
        'epoch': 1,
        'results': [
          {
            'op_id': 'op-5',
            'status': 'rejected',
            'error_code': 'payload_too_large',
            'retryable': false,
            'duplicate': false,
            'row': null,
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      final r = response.results.first;
      expect(r.retryable, isFalse);
      expect(r.errorCode, 'payload_too_large');
    });

    test('top-level error key throws SyncRejected', () {
      final api = makeApi();
      final raw = {
        'error': 'insufficient_permission',
        'results': <dynamic>[],
        'epoch': 1,
      };
      expect(
        () => api.parsePushResponseForTest(raw),
        throwsA(isA<SyncRejected>()),
      );
    });

    test('missing duplicate key defaults isDuplicate to false', () {
      final api = makeApi();
      final raw = {
        'epoch': 1,
        'results': [
          {
            'op_id': 'op-6',
            'status': 'applied',
            'server_version': 1,
            'row': null,
            'retryable': false,
            // no 'duplicate' key
          },
        ],
      };
      final response = api.parsePushResponseForTest(raw);
      expect(response.results.first.isDuplicate, isFalse);
    });
  });
}

/// A thin subclass that skips the client initialisation.
class _FakeApi extends SupabaseRemoteSyncApi {
  _FakeApi() : super(client: _DummyClient());
}

/// A minimal stub that satisfies the type requirement but is never called.
class _DummyClient extends Fake implements SupabaseClient {}
