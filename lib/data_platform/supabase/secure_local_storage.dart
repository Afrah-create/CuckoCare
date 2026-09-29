import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Encrypted Supabase session persistence for offline-capable auth.
class SecureLocalStorage extends LocalStorage {
  SecureLocalStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(aOptions: AndroidOptions()),
        super();

  final FlutterSecureStorage _storage;
  static const _sessionKey = 'supabase_session';

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<bool> hasAccessToken() async {
    final value = await _storage.read(key: _sessionKey);
    return value != null && value.isNotEmpty;
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: _sessionKey, value: persistSessionString);
  }

  Future<String?> persistSessionString() => _storage.read(key: _sessionKey);

  @override
  Future<void> removePersistedSession() {
    return _storage.delete(key: _sessionKey);
  }
}
