import 'package:flutter/material.dart';

import 'brand_palette.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.taskUpcoming,
    required this.onTaskUpcoming,
    required this.taskDueToday,
    required this.onTaskDueToday,
    required this.taskOverdue,
    required this.onTaskOverdue,
    required this.taskDone,
    required this.onTaskDone,
    required this.syncIdle,
    required this.syncSyncing,
    required this.syncOffline,
    required this.syncError,
    required this.brandInk,
    required this.brandCream,
    required this.splashBackground,
    required this.authBackground,
    required this.logoTint,
    required this.gradientStart,
    required this.gradientEnd,
    required this.glassSurfaceFill,
    required this.glassSurfaceBorder,
    required this.scrim,
    required this.notificationAccent,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color taskUpcoming;
  final Color onTaskUpcoming;
  final Color taskDueToday;
  final Color onTaskDueToday;
  final Color taskOverdue;
  final Color onTaskOverdue;
  final Color taskDone;
  final Color onTaskDone;

  final Color syncIdle;
  final Color syncSyncing;
  final Color syncOffline;
  final Color syncError;

  final Color brandInk;
  final Color brandCream;
  final Color splashBackground;
  final Color authBackground;
  final Color logoTint;
  final Color gradientStart;
  final Color gradientEnd;
  final Color glassSurfaceFill;
  final Color glassSurfaceBorder;
  final Color scrim;
  final Color notificationAccent;

  static AppColors light = AppColors(
    success: BrandPalette.success,
    onSuccess: Colors.white,
    successContainer: const Color(0xFFC8E6C9),
    onSuccessContainer: const Color(0xFF1B5E20),
    warning: BrandPalette.warning,
    onWarning: Colors.white,
    warningContainer: const Color(0xFFFFE0B2),
    onWarningContainer: const Color(0xFFBF360C),
    info: BrandPalette.info,
    onInfo: Colors.white,
    infoContainer: const Color(0xFFBBDEFB),
    onInfoContainer: const Color(0xFF0D47A1),
    taskUpcoming: BrandPalette.taskUpcoming,
    onTaskUpcoming: Colors.white,
    taskDueToday: BrandPalette.taskDueToday,
    onTaskDueToday: const Color(0xFF212121),
    taskOverdue: BrandPalette.taskOverdue,
    onTaskOverdue: Colors.white,
    taskDone: BrandPalette.taskDone,
    onTaskDone: Colors.white,
    syncIdle: BrandPalette.success,
    syncSyncing: BrandPalette.info,
    syncOffline: BrandPalette.warning,
    syncError: const Color(0xFFB00020),
    brandInk: BrandPalette.brandInk,
    brandCream: BrandPalette.brandCream,
    splashBackground: BrandPalette.splashLight,
    authBackground: BrandPalette.authBackgroundLight,
    logoTint: BrandPalette.brandInk,
    gradientStart: BrandPalette.gradientStart,
    gradientEnd: BrandPalette.gradientEnd,
    glassSurfaceFill: BrandPalette.glassFillLight,
    glassSurfaceBorder: BrandPalette.glassBorderLight,
    scrim: const Color(0x99000000),
    notificationAccent: BrandPalette.brandInk,
  );

  static AppColors dark = AppColors(
    success: const Color(0xFF81C784),
    onSuccess: const Color(0xFF1B5E20),
    successContainer: const Color(0xFF2E7D32),
    onSuccessContainer: const Color(0xFFE8F5E9),
    warning: const Color(0xFFFFB74D),
    onWarning: const Color(0xFF4E2600),
    warningContainer: const Color(0xFFEF6C00),
    onWarningContainer: const Color(0xFFFFF3E0),
    info: const Color(0xFF64B5F6),
    onInfo: const Color(0xFF0D47A1),
    infoContainer: const Color(0xFF1565C0),
    onInfoContainer: const Color(0xFFE3F2FD),
    taskUpcoming: const Color(0xFF9CCC65),
    onTaskUpcoming: const Color(0xFF1B5E20),
    taskDueToday: const Color(0xFFFFD54F),
    onTaskDueToday: const Color(0xFF212121),
    taskOverdue: const Color(0xFFEF5350),
    onTaskOverdue: const Color(0xFF4A0000),
    taskDone: const Color(0xFF90A4AE),
    onTaskDone: const Color(0xFF263238),
    syncIdle: const Color(0xFF81C784),
    syncSyncing: const Color(0xFF64B5F6),
    syncOffline: const Color(0xFFFFB74D),
    syncError: const Color(0xFFCF6679),
    brandInk: BrandPalette.brandInk,
    brandCream: BrandPalette.brandCream,
    splashBackground: BrandPalette.splashDark,
    authBackground: BrandPalette.authBackgroundDark,
    logoTint: BrandPalette.brandCream,
    gradientStart: BrandPalette.gradientStart,
    gradientEnd: BrandPalette.seedDark,
    glassSurfaceFill: BrandPalette.glassFillDark,
    glassSurfaceBorder: BrandPalette.glassBorderDark,
    scrim: const Color(0xCC000000),
    notificationAccent: BrandPalette.brandCream,
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? taskUpcoming,
    Color? onTaskUpcoming,
    Color? taskDueToday,
    Color? onTaskDueToday,
    Color? taskOverdue,
    Color? onTaskOverdue,
    Color? taskDone,
    Color? onTaskDone,
    Color? syncIdle,
    Color? syncSyncing,
    Color? syncOffline,
    Color? syncError,
    Color? brandInk,
    Color? brandCream,
    Color? splashBackground,
    Color? authBackground,
    Color? logoTint,
    Color? gradientStart,
    Color? gradientEnd,
    Color? glassSurfaceFill,
    Color? glassSurfaceBorder,
    Color? scrim,
    Color? notificationAccent,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      taskUpcoming: taskUpcoming ?? this.taskUpcoming,
      onTaskUpcoming: onTaskUpcoming ?? this.onTaskUpcoming,
      taskDueToday: taskDueToday ?? this.taskDueToday,
      onTaskDueToday: onTaskDueToday ?? this.onTaskDueToday,
      taskOverdue: taskOverdue ?? this.taskOverdue,
      onTaskOverdue: onTaskOverdue ?? this.onTaskOverdue,
      taskDone: taskDone ?? this.taskDone,
      onTaskDone: onTaskDone ?? this.onTaskDone,
      syncIdle: syncIdle ?? this.syncIdle,
      syncSyncing: syncSyncing ?? this.syncSyncing,
      syncOffline: syncOffline ?? this.syncOffline,
      syncError: syncError ?? this.syncError,
      brandInk: brandInk ?? this.brandInk,
      brandCream: brandCream ?? this.brandCream,
      splashBackground: splashBackground ?? this.splashBackground,
      authBackground: authBackground ?? this.authBackground,
      logoTint: logoTint ?? this.logoTint,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      glassSurfaceFill: glassSurfaceFill ?? this.glassSurfaceFill,
      glassSurfaceBorder: glassSurfaceBorder ?? this.glassSurfaceBorder,
      scrim: scrim ?? this.scrim,
      notificationAccent: notificationAccent ?? this.notificationAccent,
    );
  }

  static Color? _lerpColor(Color? a, Color? b, double t) =>
      Color.lerp(a, b, t);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      success: _lerpColor(success, other.success, t)!,
      onSuccess: _lerpColor(onSuccess, other.onSuccess, t)!,
      successContainer:
          _lerpColor(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          _lerpColor(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: _lerpColor(warning, other.warning, t)!,
      onWarning: _lerpColor(onWarning, other.onWarning, t)!,
      warningContainer:
          _lerpColor(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          _lerpColor(onWarningContainer, other.onWarningContainer, t)!,
      info: _lerpColor(info, other.info, t)!,
      onInfo: _lerpColor(onInfo, other.onInfo, t)!,
      infoContainer: _lerpColor(infoContainer, other.infoContainer, t)!,
      onInfoContainer:
          _lerpColor(onInfoContainer, other.onInfoContainer, t)!,
      taskUpcoming: _lerpColor(taskUpcoming, other.taskUpcoming, t)!,
      onTaskUpcoming: _lerpColor(onTaskUpcoming, other.onTaskUpcoming, t)!,
      taskDueToday: _lerpColor(taskDueToday, other.taskDueToday, t)!,
      onTaskDueToday: _lerpColor(onTaskDueToday, other.onTaskDueToday, t)!,
      taskOverdue: _lerpColor(taskOverdue, other.taskOverdue, t)!,
      onTaskOverdue: _lerpColor(onTaskOverdue, other.onTaskOverdue, t)!,
      taskDone: _lerpColor(taskDone, other.taskDone, t)!,
      onTaskDone: _lerpColor(onTaskDone, other.onTaskDone, t)!,
      syncIdle: _lerpColor(syncIdle, other.syncIdle, t)!,
      syncSyncing: _lerpColor(syncSyncing, other.syncSyncing, t)!,
      syncOffline: _lerpColor(syncOffline, other.syncOffline, t)!,
      syncError: _lerpColor(syncError, other.syncError, t)!,
      brandInk: _lerpColor(brandInk, other.brandInk, t)!,
      brandCream: _lerpColor(brandCream, other.brandCream, t)!,
      splashBackground:
          _lerpColor(splashBackground, other.splashBackground, t)!,
      authBackground: _lerpColor(authBackground, other.authBackground, t)!,
      logoTint: _lerpColor(logoTint, other.logoTint, t)!,
      gradientStart: _lerpColor(gradientStart, other.gradientStart, t)!,
      gradientEnd: _lerpColor(gradientEnd, other.gradientEnd, t)!,
      glassSurfaceFill:
          _lerpColor(glassSurfaceFill, other.glassSurfaceFill, t)!,
      glassSurfaceBorder:
          _lerpColor(glassSurfaceBorder, other.glassSurfaceBorder, t)!,
      scrim: _lerpColor(scrim, other.scrim, t)!,
      notificationAccent:
          _lerpColor(notificationAccent, other.notificationAccent, t)!,
    );
  }
}
