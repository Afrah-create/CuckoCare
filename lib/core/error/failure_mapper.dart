import 'failure.dart';
import 'ui_failure.dart';

abstract final class FailureMapper {
  static UiFailure map(Failure failure) {
    return switch (failure) {
      NetworkFailure() => _offline,
      SyncOffline() => _offline,
      SyncTimeout() => _timeout,
      LocationCaptureTimeout() => _timeout,
      SyncServerFailure(:final message) => message.toUpperCase() == 'PGRST202'
          ? _info(
              kind: UiFailureKind.server,
              code: 'PGRST202',
              title: 'We could not reach the server',
              message: 'Try again in a moment.',
              action: UiAction.retry,
              presentation: UiPresentation.page,
            )
          : _server,
      SyncSchemaMismatch() => _server,
      AuthFailure() => _auth,
      SyncAuthRequired() => _auth,
      LocationPermissionDenied() => _permission(
          AppPermission.location,
          blocked: false,
        ),
      LocationPermissionPermanentlyDenied() => _permission(
          AppPermission.location,
          blocked: true,
        ),
      LocationServiceDisabled() => _permission(
          AppPermission.location,
          blocked: true,
        ),
      StorageFailure() => _storage,
      SyncRejected() => _conflict(failure.message),
      SyncSignedOutDemo() => _info(
          kind: UiFailureKind.offline,
          code: 'demo',
          title: 'Demo mode',
          message: 'Cloud sync is off in this demo.',
          action: UiAction.none,
          presentation: UiPresentation.banner,
        ),
      UnexpectedFailure() => _unknown,
      ValidationFailure(:final message) => _info(
          kind: UiFailureKind.validation,
          code: 'validation',
          title: "Couldn't save",
          message: message,
          action: UiAction.dismiss,
          presentation: UiPresentation.inline,
        ),
      NotFoundFailure(:final message) => _info(
          kind: UiFailureKind.notFound,
          code: 'not-found',
          title: 'Not found',
          message: message,
          action: UiAction.dismiss,
          presentation: UiPresentation.page,
        ),
      PermissionFailure(:final message) => _info(
          kind: UiFailureKind.permissionDenied,
          code: 'role',
          title: 'Not allowed',
          message: message,
          action: UiAction.dismiss,
          presentation: UiPresentation.snack,
        ),
    };
  }

  static UiFailure mapObject(Object error) {
    if (error is Failure) {
      return map(error);
    }
    final classified = _classifyRemote(error);
    if (classified != null) {
      return map(classified);
    }
    final text = error.toString().toLowerCase();
    if (text.contains('loadtimedout') || text.contains('timeout')) {
      return _timeout;
    }
    if (text.contains('socket') ||
        text.contains('network') ||
        text.contains('offline') ||
        text.contains('failed host lookup') ||
        text.contains('clientexception')) {
      return _offline;
    }
    return _unknown;
  }

  static Failure? _classifyRemote(Object error) {
    try {
      final dynamic e = error;
      final code = e.code;
      final message = e.message;
      if (code is! String && message is! String) {
        return null;
      }
      final text = '${code ?? ''} ${message ?? ''}'.toLowerCase();
      final c = (code is String ? code : '').toUpperCase();
      if (c == 'PGRST202' ||
          text.contains('schema cache') ||
          text.contains('could not find the function')) {
        return const SyncServerFailure('PGRST202', retryable: false);
      }
      if (c == '42501' || text.contains('forbidden')) {
        return const PermissionFailure();
      }
      if (c == '28000' || text.contains('not authenticated')) {
        return const SyncAuthRequired();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String messageFor(Failure failure) => map(failure).message;
}

UiFailure _info({
  required UiFailureKind kind,
  required String code,
  required String title,
  required String message,
  required UiAction action,
  required UiPresentation presentation,
  AppPermission? permission,
}) {
  return UiFailure(
    kind: kind,
    code: code,
    title: title,
    message: message,
    action: action,
    presentation: presentation,
    permission: permission,
  );
}

final _offline = _info(
  kind: UiFailureKind.offline,
  code: 'offline',
  title: "You're offline",
  message: 'This needs internet. Try again when you are connected.',
  action: UiAction.retry,
  presentation: UiPresentation.page,
);

final _timeout = _info(
  kind: UiFailureKind.timeout,
  code: 'timeout',
  title: 'This is taking too long',
  message: 'Check your connection and try again.',
  action: UiAction.retry,
  presentation: UiPresentation.page,
);

final _server = _info(
  kind: UiFailureKind.server,
  code: 'server',
  title: 'We could not reach the server',
  message: 'Try again in a moment.',
  action: UiAction.retry,
  presentation: UiPresentation.snack,
);

final _auth = _info(
  kind: UiFailureKind.authRequired,
  code: 'auth',
  title: 'Please sign in again',
  message: 'Your session ended. Sign in to continue.',
  action: UiAction.signIn,
  presentation: UiPresentation.page,
);

final _storage = _info(
  kind: UiFailureKind.storageFull,
  code: 'storage',
  title: "Couldn't save",
  message: 'Free some space on this phone and try again.',
  action: UiAction.retry,
  presentation: UiPresentation.banner,
);

final _unknown = _info(
  kind: UiFailureKind.unknown,
  code: 'unknown',
  title: 'Something went wrong',
  message: 'Please try again.',
  action: UiAction.retry,
  presentation: UiPresentation.page,
);

UiFailure _permission(AppPermission permission, {required bool blocked}) {
  return _info(
    kind: blocked
        ? UiFailureKind.permissionBlocked
        : UiFailureKind.permissionDenied,
    code: blocked ? 'permission-blocked' : 'permission-denied',
    title: blocked ? 'Permission is blocked' : 'Permission is needed',
    message: blocked
        ? 'Open settings and allow access, then come back.'
        : 'Allow access to continue. You can still use the rest of the app.',
    action: blocked ? UiAction.openSettings : UiAction.retry,
    presentation: UiPresentation.page,
    permission: permission,
  );
}

UiFailure _conflict(String message) {
  final lower = message.toLowerCase();
  final safe = lower.contains('exception') || message.length > 80
      ? "Couldn't save that change. Please try again."
      : message;
  return _info(
    kind: UiFailureKind.conflict,
    code: 'conflict',
    title: "Couldn't save",
    message: safe,
    action: UiAction.retry,
    presentation: UiPresentation.banner,
  );
}
