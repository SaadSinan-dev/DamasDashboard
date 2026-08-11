import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/features/settings/domain/entities/app_settings.dart';
import 'package:damas_dashboard/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeSettingsRepository repository;
  late SettingsCubit cubit;

  setUp(() {
    repository = FakeSettingsRepository();
    cubit = SettingsCubit(
      repository: repository,
      initial: AppSettings.defaults,
    );
  });

  tearDown(() => cubit.close());

  test('starts from the settings bootstrap supplied', () {
    final SettingsCubit seeded = SettingsCubit(
      repository: repository,
      initial: const AppSettings(
        themeMode: AppThemeMode.dark,
        language: AppLanguage.arabic,
      ),
    );
    addTearDown(seeded.close);

    expect(seeded.state.themeMode, AppThemeMode.dark);
    expect(seeded.state.language, AppLanguage.arabic);
  });

  test('changing the theme emits and persists', () async {
    await cubit.setThemeMode(AppThemeMode.dark);

    expect(cubit.state.themeMode, AppThemeMode.dark);
    expect(repository.savedValues.single.themeMode, AppThemeMode.dark);
  });

  test('changing the language emits and persists', () async {
    await cubit.setLanguage(AppLanguage.arabic);

    expect(cubit.state.language, AppLanguage.arabic);
    expect(repository.savedValues.single.language, AppLanguage.arabic);
  });

  test('changing one preference leaves the other alone', () async {
    await cubit.setLanguage(AppLanguage.arabic);
    await cubit.setThemeMode(AppThemeMode.light);

    expect(cubit.state.language, AppLanguage.arabic);
    expect(cubit.state.themeMode, AppThemeMode.light);
  });

  test('selecting the current value does not write again', () async {
    await cubit.setThemeMode(AppThemeMode.system);

    expect(repository.savedValues, isEmpty);
  });

  test('a failed write keeps the choice applied for this session', () async {
    repository.saveFailure = const CacheFailure();

    await cubit.setThemeMode(AppThemeMode.dark);

    // The user's selection stays visible rather than snapping back under their
    // finger; only persistence was lost.
    expect(cubit.state.themeMode, AppThemeMode.dark);
    expect(repository.savedValues, isEmpty);
  });

  group('AppLanguage', () {
    test('system defers to the platform, the others pin a language', () {
      expect(AppLanguage.system.languageCode, isNull);
      expect(AppLanguage.english.languageCode, 'en');
      expect(AppLanguage.arabic.languageCode, 'ar');
    });
  });
}
