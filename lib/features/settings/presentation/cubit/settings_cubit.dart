import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Holds the active preferences and persists every change.
///
/// Provided above `MaterialApp`, so emitting a new value rebuilds the app with a
/// different theme and locale. There is no loading state because bootstrap reads
/// the stored settings before the first frame — starting in the wrong theme and
/// correcting a frame later is a visible flash.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit({
    required SettingsRepository repository,
    required AppSettings initial,
  })  : _repository = repository,
        super(initial);

  final SettingsRepository _repository;

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setLanguage(AppLanguage language) =>
      _update(state.copyWith(language: language));

  Future<void> _update(AppSettings next) async {
    if (next == state) return;

    // Applied to the UI first so the control responds immediately; a failed
    // write is logged by the repository and leaves the preference in memory for
    // this session rather than snapping the toggle back under the user's finger.
    emit(next);
    await _repository.save(next);
  }
}
