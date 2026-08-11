import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/di/injector.dart';
import '../core/result/result.dart';
import '../core/utils/app_logger.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import 'app.dart';

/// Composition root.
///
/// Everything that must happen before the first frame happens here — binding
/// initialisation, dependency registration, error plumbing and reading stored
/// preferences — which keeps `main` to a single call and gives tests a seam to
/// start the app with different dependencies.
Future<void> bootstrap() async {
  // Guarded so that errors thrown during startup are reported through the same
  // handler as errors thrown later, instead of being lost to the console.
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.error(
          details.exceptionAsString(),
          name: 'flutter',
          error: details.exception,
          stackTrace: details.stack,
        );
        if (kDebugMode) FlutterError.presentError(details);
      };

      // Errors from the engine that never reach the Flutter framework.
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        AppLogger.error(
          'Uncaught platform error',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      await configureDependencies();

      // Read before the first frame so the app never paints in the wrong theme
      // and then corrects itself a frame later.
      final Result<AppSettings> stored = await sl<SettingsRepository>().load();
      final AppSettings settings = stored.fold(
        onSuccess: (AppSettings value) => value,
        onFailure: (_) => AppSettings.defaults,
      );

      runApp(DamasDashboardApp(initialSettings: settings));
    },
    (Object error, StackTrace stack) => AppLogger.error(
      'Uncaught zone error',
      error: error,
      stackTrace: stack,
    ),
  );
}
