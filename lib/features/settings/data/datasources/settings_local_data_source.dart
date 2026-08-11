import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract interface class SettingsLocalDataSource {
  Future<String?> readThemeMode();

  Future<String?> readLanguage();

  Future<void> writeSettings(
      {required String themeMode, required String language});
}

/// Key/value storage for preferences.
///
/// Only non-sensitive display preferences are stored here. `SharedPreferences`
/// is plain-text on disk, so anything secret would need the platform keystore
/// instead.
class SettingsPreferencesDataSource implements SettingsLocalDataSource {
  const SettingsPreferencesDataSource(this._preferences);

  static const String themeModeKey = 'settings.themeMode';
  static const String languageKey = 'settings.language';

  final SharedPreferences _preferences;

  @override
  Future<String?> readThemeMode() async => _preferences.getString(themeModeKey);

  @override
  Future<String?> readLanguage() async => _preferences.getString(languageKey);

  @override
  Future<void> writeSettings({
    required String themeMode,
    required String language,
  }) async {
    final bool wroteTheme =
        await _preferences.setString(themeModeKey, themeMode);
    final bool wroteLanguage =
        await _preferences.setString(languageKey, language);

    if (!wroteTheme || !wroteLanguage) {
      throw const CacheException('Preferences could not be written to disk');
    }
  }
}
