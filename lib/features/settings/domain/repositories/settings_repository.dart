import '../../../../core/result/result.dart';
import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Reads stored preferences, falling back to [AppSettings.defaults].
  Future<Result<AppSettings>> load();

  Future<Result<void>> save(AppSettings settings);
}
