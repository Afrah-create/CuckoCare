import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Plain-language copy for UI — never expose raw exceptions.
String userMessageForFailure(Failure failure) {
  return switch (failure) {
    NetworkFailure() => 'No internet connection. Check your network and try again.',
    AuthFailure(:final message) => message,
    StorageFailure() => 'Could not save on this device. Try again.',
    UnexpectedFailure() => 'Something went wrong. Please try again.',
    SyncOffline() => 'You are offline. Changes will sync when you reconnect.',
    SyncTimeout() => 'The server took too long. Try again in a moment.',
    SyncAuthRequired() => 'Your session expired. Please sign in again.',
    SyncServerFailure(:final message) => _sanitizeServerMessage(message),
    SyncRejected(:final message) => message,
    SyncSchemaMismatch() =>
      'This app version needs an update to sync with the server.',
    SyncSignedOutDemo() => 'Demo mode — cloud sync is disabled.',
  };
}

String userMessageForError(Object error) {
  if (error is AuthException) {
    return mapSupabaseAuthMessage(error.message);
  }
  if (error is PostgrestException) {
    return _mapPostgrest(error);
  }
  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('host lookup') ||
      text.contains('failed host') ||
      text.contains('network is unreachable') ||
      text.contains('connection refused') ||
      text.contains('clientexception')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (text.contains('timeout')) {
    return 'The request timed out. Try again.';
  }
  if (text.contains('sqliteexception') || text.contains('constraint failed')) {
    return 'Could not save on this device. Clear app storage or reinstall, then try again.';
  }
  return 'Something went wrong. Please try again.';
}

String mapSupabaseAuthMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('invalid login credentials') ||
      lower.contains('invalid email or password')) {
    return 'Email or password is incorrect.';
  }
  if (lower.contains('user already registered') ||
      lower.contains('already been registered')) {
    return 'An account with this email already exists. Try signing in.';
  }
  if (lower.contains('password') && lower.contains('least')) {
    return 'Use a stronger password (at least 6 characters).';
  }
  if (lower.contains('email not confirmed')) {
    return 'This account is not active yet. Try signing in, or contact support.';
  }
  if (lower.contains('signup') && lower.contains('disabled')) {
    return 'New sign-ups are not available right now.';
  }
  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('host lookup')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (message.length > 120) {
    return 'Something went wrong. Please try again.';
  }
  return message;
}

String _mapPostgrest(PostgrestException error) {
  final code = error.code;
  if (code == 'PGRST301' || code == '42501') {
    return 'You do not have permission to do that.';
  }
  if (code == 'PGRST202') {
    return 'Farm setup is not available yet. Check that server migrations are applied.';
  }
  final msg = error.message.toLowerCase();
  if (msg.contains('not authenticated')) {
    return 'Your session expired. Please sign in again.';
  }
  if (msg.contains('farm name is required') || msg.contains('location is required')) {
    return 'Enter a farm name and location.';
  }
  return 'Could not save your farm. Try again.';
}

String _sanitizeServerMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('socket') || lower.contains('host lookup')) {
    return 'No internet connection. Check your network and try again.';
  }
  if (message.length > 100) {
    return 'Could not reach the server. Try again later.';
  }
  return message;
}
