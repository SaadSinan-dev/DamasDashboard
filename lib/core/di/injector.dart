import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/analytics/data/datasources/analytics_local_data_source.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_analytics_snapshot.dart';
import '../../features/notifications/data/datasources/notifications_local_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/reports/data/datasources/reports_local_data_source.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/filter_reports.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../data/json_asset_reader.dart';
import '../utils/clock.dart';

/// Application service locator.
///
/// Read from exactly two kinds of place: [configureDependencies]'s callers, and
/// the `create:` callback of a `BlocProvider`. Everything else takes its
/// dependencies through its constructor, which is what keeps repositories, use
/// cases and cubits unit-testable without registering anything.
final GetIt sl = GetIt.instance;

/// Registers every dependency. Call once, before `runApp`.
///
/// [simulatedLatency] is zero in tests so they do not spend real time waiting,
/// and non-zero in the app so the loading and refreshing states are reachable
/// without a backend.
Future<void> configureDependencies({
  Duration simulatedLatency = _demoLatency,
  SharedPreferences? preferences,
}) async {
  final SharedPreferences prefs =
      preferences ?? await SharedPreferences.getInstance();

  _registerCore(prefs, simulatedLatency);
  _registerAnalytics();
  _registerReports();
  _registerNotifications();
  _registerSettings();
}

void _registerCore(SharedPreferences prefs, Duration latency) {
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<Clock>(SystemClock.new)
    ..registerLazySingleton<JsonAssetReader>(
      () => JsonAssetReader(latency: latency),
    );
}

void _registerAnalytics() {
  sl
    ..registerLazySingleton<AnalyticsLocalDataSource>(
      () => AnalyticsAssetDataSource(sl<JsonAssetReader>()),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(
        dataSource: sl<AnalyticsLocalDataSource>(),
        clock: sl<Clock>(),
      ),
    )
    // Use cases are stateless and cheap, so a factory avoids keeping one alive
    // for the life of the process.
    ..registerFactory<GetAnalyticsSnapshot>(
      () => GetAnalyticsSnapshot(sl<AnalyticsRepository>()),
    );
}

void _registerReports() {
  sl
    ..registerLazySingleton<ReportsLocalDataSource>(
      () => ReportsAssetDataSource(sl<JsonAssetReader>()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(
        dataSource: sl<ReportsLocalDataSource>(),
        clock: sl<Clock>(),
      ),
    )
    ..registerFactory<FilterReports>(FilterReports.new);
}

void _registerNotifications() {
  sl
    ..registerLazySingleton<NotificationsLocalDataSource>(
      () => NotificationsAssetDataSource(sl<JsonAssetReader>()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(
        dataSource: sl<NotificationsLocalDataSource>(),
        clock: sl<Clock>(),
      ),
    );
}

void _registerSettings() {
  sl
    ..registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsPreferencesDataSource(sl<SharedPreferences>()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<SettingsLocalDataSource>()),
    );
}

/// Tears the container down. Used between tests.
Future<void> resetDependencies() => sl.reset();

const Duration _demoLatency = Duration(milliseconds: 450);
