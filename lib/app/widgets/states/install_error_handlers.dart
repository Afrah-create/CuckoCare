import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/logging/app_logger.dart';
import 'screen_error_fallback.dart';

void installErrorHandlers() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    appLogger.e(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    previous?.call(details);
  };

  final platform = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    appLogger.e('Uncaught error', error: error, stackTrace: stack);
    if (platform != null) {
      return platform(error, stack);
    }
    return true;
  };

  ErrorWidget.builder = (details) {
    if (kReleaseMode) {
      return const ScreenErrorFallback();
    }
    return ErrorWidget.withDetails(
      message: details.exceptionAsString(),
      error: details.exception is FlutterError ? details.exception as FlutterError : null,
    );
  };
}

Widget releaseErrorWidget(FlutterErrorDetails details) {
  appLogger.e(
    details.exceptionAsString(),
    error: details.exception,
    stackTrace: details.stack,
  );
  return const ScreenErrorFallback();
}
