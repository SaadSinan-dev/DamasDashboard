import 'package:damas_dashboard/core/l10n/generated/app_localizations.dart';
import 'package:damas_dashboard/core/theme/app_theme.dart';
import 'package:damas_dashboard/core/utils/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Mounts a widget inside the same scaffolding the real app provides:
/// localizations, the app theme, and a [Clock].
///
/// Without this every widget test would need its own MaterialApp boilerplate,
/// and any test that forgot the localization delegates would fail inside
/// `context.l10n` rather than at the assertion.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    Clock? clock,
    Size surfaceSize = const Size(1000, 1400),
    List<BlocProvider<dynamic>> providers = const <BlocProvider<dynamic>>[],
  }) async {
    await _setSurfaceSize(surfaceSize);

    Widget body = Scaffold(body: child);
    if (providers.isNotEmpty) {
      body = MultiBlocProvider(providers: providers, child: body);
    }

    await pumpWidget(
      RepositoryProvider<Clock>.value(
        value: clock ?? FixedClock.reference(),
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
          theme: AppTheme.light(locale),
          darkTheme: AppTheme.dark(locale),
          themeMode: themeMode,
          home: body,
        ),
      ),
    );
  }

  Future<void> _setSurfaceSize(Size size) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  }
}
