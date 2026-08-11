import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsLocalDataSource _dataSource;

  @override
  Future<Result<AppSettings>> load() {
    return guardAsync(
      operation: 'loadSettings',
      () async {
        final (String? theme, String? language) = await (
          _dataSource.readThemeMode(),
          _dataSource.readLanguage(),
        ).wait;

        return AppSettings(
          themeMode: _parse(AppThemeMode.values, theme, AppThemeMode.system),
          language: _parse(AppLanguage.values, language, AppLanguage.system),
        );
      },
    );
  }

  @override
  Future<Result<void>> save(AppSettings settings) {
    return guardAsync(
      operation: 'saveSettings',
      () => _dataSource.writeSettings(
        themeMode: settings.themeMode.name,
        language: settings.language.name,
      ),
    );
  }

  /// Unlike the strict parsing used for report data, an unreadable preference
  /// falls back to its default: a value written by an older build should leave
  /// the user with a working app, not a failed launch.
  T _parse<T extends Enum>(List<T> values, String? stored, T fallback) {
    if (stored == null) return fallback;
    for (final T value in values) {
      if (value.name == stored) return value;
    }
    AppLogger.warning(
        'Unrecognised stored preference "$stored"; using default');
    return fallback;
  }
}
