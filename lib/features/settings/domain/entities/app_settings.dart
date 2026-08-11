import 'package:equatable/equatable.dart';

/// Theme preference.
///
/// Deliberately not Flutter's `ThemeMode`: the domain layer must not import
/// `package:flutter`. The presentation layer maps between the two.
enum AppThemeMode { system, light, dark }

/// Language preference. `system` follows the device setting.
enum AppLanguage {
  system(null),
  english('en'),
  arabic('ar');

  const AppLanguage(this.languageCode);

  /// BCP-47 language code, or `null` to defer to the platform.
  final String? languageCode;
}

/// User preferences that survive a restart.
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.system,
  });

  static const AppSettings defaults = AppSettings();

  final AppThemeMode themeMode;
  final AppLanguage language;

  AppSettings copyWith({AppThemeMode? themeMode, AppLanguage? language}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => <Object?>[themeMode, language];
}
