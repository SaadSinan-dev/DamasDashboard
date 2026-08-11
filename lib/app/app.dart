import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injector.dart';
import '../core/l10n/generated/app_localizations.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/clock.dart';
import '../features/notifications/domain/repositories/notifications_repository.dart';
import '../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';

/// Application root.
///
/// Stateful for two reasons: the [GoRouter] must be built once rather than on
/// every rebuild (recreating it resets navigation state), and the app observes
/// platform locale changes so that "System" language keeps following the device
/// while the app is running.
class DamasDashboardApp extends StatefulWidget {
  const DamasDashboardApp({super.key, required this.initialSettings});

  /// Read from disk during bootstrap, so the first frame is already painted in
  /// the user's chosen theme and language.
  final AppSettings initialSettings;

  @override
  State<DamasDashboardApp> createState() => _DamasDashboardAppState();
}

class _DamasDashboardAppState extends State<DamasDashboardApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = createAppRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // The locale is resolved explicitly (see [_resolveLocale]) because the theme
    // needs it to pick a font, so a system language change has to be rebuilt for
    // by hand rather than being handled inside MaterialApp.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Clock>.value(
      value: sl<Clock>(),
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(
              repository: sl<SettingsRepository>(),
              initial: widget.initialSettings,
            ),
          ),
          BlocProvider<NotificationsCubit>(
            // Above the shell so the app bar badge has a count before the panel
            // is ever opened.
            create: (_) =>
                NotificationsCubit(sl<NotificationsRepository>())..load(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (BuildContext context, AppSettings settings) {
            final Locale locale = _resolveLocale(settings.language);

            return MaterialApp.router(
              onGenerateTitle: (BuildContext context) =>
                  AppL10n.of(context).appTitle,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
              theme: AppTheme.light(locale),
              darkTheme: AppTheme.dark(locale),
              themeMode: switch (settings.themeMode) {
                AppThemeMode.system => ThemeMode.system,
                AppThemeMode.light => ThemeMode.light,
                AppThemeMode.dark => ThemeMode.dark,
              },
              locale: locale,
              supportedLocales: AppL10n.supportedLocales,
              localizationsDelegates: AppL10n.localizationsDelegates,
            );
          },
        ),
      ),
    );
  }

  /// Turns the stored preference into a concrete [Locale].
  ///
  /// "System" walks the device's preferred languages in order and takes the
  /// first the app actually ships translations for, falling back to English.
  Locale _resolveLocale(AppLanguage language) {
    final String? explicitCode = language.languageCode;
    if (explicitCode != null) return Locale(explicitCode);

    for (final Locale candidate
        in WidgetsBinding.instance.platformDispatcher.locales) {
      final bool supported = AppL10n.supportedLocales.any(
        (Locale supported) => supported.languageCode == candidate.languageCode,
      );
      if (supported) return Locale(candidate.languageCode);
    }
    return const Locale('en');
  }
}
