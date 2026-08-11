/// Build-wide constants.
///
/// Nothing secret belongs here — this file ships inside the app bundle and can
/// be read from a decompiled build. API keys and endpoints for a real backend
/// should come from `--dart-define` at build time and be read via
/// [String.fromEnvironment], never committed.
abstract final class AppConfig {
  /// Kept in step with `version:` in pubspec.yaml. Reading it at runtime would
  /// mean adding `package_info_plus` for a single string.
  static const String version = '1.0.0';

  /// Example of the dart-define pattern, unused while the app runs on bundled
  /// data. `flutter run --dart-define=API_BASE_URL=https://…`
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get hasRemoteBackend => apiBaseUrl.isNotEmpty;
}
