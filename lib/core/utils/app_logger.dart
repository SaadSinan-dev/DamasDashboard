import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity levels, ordered so they can be compared numerically.
enum LogLevel { debug, info, warning, error }

/// Thin logging facade over `dart:developer`.
///
/// Using this rather than `print` gives three things `print` does not: levels,
/// structured stack traces in DevTools, and a single place to forward records to
/// a crash reporter when one is added. Debug records are compiled out of release
/// builds via [kDebugMode].
abstract final class AppLogger {
  static LogLevel minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void debug(String message, {String? name}) =>
      _log(LogLevel.debug, message, name: name);

  static void info(String message, {String? name}) =>
      _log(LogLevel.info, message, name: name);

  static void warning(String message, {String? name, Object? error}) =>
      _log(LogLevel.warning, message, name: name, error: error);

  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(
        LogLevel.error,
        message,
        name: name,
        error: error,
        stackTrace: stackTrace,
      );

  static void _log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minimumLevel.index) return;
    developer.log(
      message,
      name: name ?? 'damas',
      level: _developerLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Maps onto the standard `package:logging` numeric levels that DevTools reads.
  static int _developerLevel(LogLevel level) => switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      };
}
