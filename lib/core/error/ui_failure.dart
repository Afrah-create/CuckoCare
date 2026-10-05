enum UiFailureKind {
  offline,
  timeout,
  server,
  authRequired,
  permissionDenied,
  permissionBlocked,
  validation,
  notFound,
  conflict,
  storageFull,
  unknown,
}

enum AppPermission { location, camera, photos, notifications }

enum UiAction { retry, signIn, openSettings, dismiss, none }

enum UiPresentation { inline, banner, page, snack, dialog }

class UiFailure {
  const UiFailure({
    required this.kind,
    required this.code,
    required this.title,
    required this.message,
    required this.action,
    required this.presentation,
    this.permission,
  });

  final UiFailureKind kind;
  final String code;
  final String title;
  final String message;
  final UiAction action;
  final UiPresentation presentation;
  final AppPermission? permission;
}
