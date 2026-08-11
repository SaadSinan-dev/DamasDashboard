import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/result/result.dart';
import 'package:damas_dashboard/core/utils/clock.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/activity_event.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/analytics_snapshot.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/metric.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/revenue_point.dart';
import 'package:damas_dashboard/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:damas_dashboard/features/notifications/domain/entities/app_notification.dart';
import 'package:damas_dashboard/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:damas_dashboard/features/reports/domain/entities/report.dart';
import 'package:damas_dashboard/features/reports/domain/repositories/reports_repository.dart';
import 'package:damas_dashboard/features/settings/domain/entities/app_settings.dart';
import 'package:damas_dashboard/features/settings/domain/repositories/settings_repository.dart';

/// Hand-written fakes rather than a mocking package.
///
/// The contracts here are small and the assertions are about behaviour, not
/// about which methods were called, so a fake reads better than a mock and keeps
/// one fewer dependency in the project.

/// A clock frozen at a known instant, so anything derived from "now" — relative
/// timestamps, sort order — is deterministic.
class FixedClock implements Clock {
  const FixedClock(this._now);

  /// An arbitrary but fixed reference point used across the suite.
  factory FixedClock.reference() => FixedClock(DateTime.utc(2026, 3, 15, 12));

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository({
    this.metrics = const <Metric>[],
    this.series = const <RevenuePoint>[],
    this.activity = const <ActivityEvent>[],
    this.metricsFailure,
    this.seriesFailure,
    this.activityFailure,
    this.delay = Duration.zero,
  });

  List<Metric> metrics;
  List<RevenuePoint> series;
  List<ActivityEvent> activity;
  Failure? metricsFailure;
  Failure? seriesFailure;
  Failure? activityFailure;
  Duration delay;

  /// Records the order calls started and finished, so a test can prove the three
  /// reads overlap instead of running one after another.
  final List<String> callLog = <String>[];

  @override
  Future<Result<List<Metric>>> getMetrics(MetricScope scope) async {
    callLog.add('metrics:start');
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    callLog.add('metrics:end');
    final Failure? failure = metricsFailure;
    return failure != null
        ? Failed<List<Metric>>(failure)
        : Success<List<Metric>>(metrics);
  }

  @override
  Future<Result<List<RevenuePoint>>> getRevenueSeries({int months = 12}) async {
    callLog.add('series:start');
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    callLog.add('series:end');
    final Failure? failure = seriesFailure;
    return failure != null
        ? Failed<List<RevenuePoint>>(failure)
        : Success<List<RevenuePoint>>(series);
  }

  @override
  Future<Result<List<ActivityEvent>>> getRecentActivity({int limit = 5}) async {
    callLog.add('activity:start');
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    callLog.add('activity:end');
    final Failure? failure = activityFailure;
    return failure != null
        ? Failed<List<ActivityEvent>>(failure)
        : Success<List<ActivityEvent>>(activity);
  }
}

class FakeReportsRepository implements ReportsRepository {
  FakeReportsRepository({
    List<Report>? reports,
    this.scheduled = const <ScheduledReport>[],
    this.reportsFailure,
    this.deleteFailure,
  }) : reports = reports ?? <Report>[];

  List<Report> reports;
  List<ScheduledReport> scheduled;
  Failure? reportsFailure;
  Failure? deleteFailure;

  final List<String> deletedIds = <String>[];

  @override
  Future<Result<List<Report>>> getReports() async {
    final Failure? failure = reportsFailure;
    if (failure != null) return Failed<List<Report>>(failure);
    return Success<List<Report>>(List<Report>.unmodifiable(reports));
  }

  @override
  Future<Result<List<ScheduledReport>>> getScheduledReports() async {
    final Failure? failure = reportsFailure;
    if (failure != null) return Failed<List<ScheduledReport>>(failure);
    return Success<List<ScheduledReport>>(scheduled);
  }

  @override
  Future<Result<void>> deleteReport(String id) async {
    final Failure? failure = deleteFailure;
    if (failure != null) return Failed<void>(failure);
    deletedIds.add(id);
    reports = reports.where((Report r) => r.id != id).toList();
    return const Success<void>(null);
  }
}

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository({
    List<AppNotification>? notifications,
    this.failure,
  }) : notifications = notifications ?? <AppNotification>[];

  List<AppNotification> notifications;
  Failure? failure;

  @override
  Future<Result<List<AppNotification>>> getNotifications() async {
    final Failure? error = failure;
    if (error != null) return Failed<List<AppNotification>>(error);
    return Success<List<AppNotification>>(
      List<AppNotification>.unmodifiable(notifications),
    );
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    final Failure? error = failure;
    if (error != null) return Failed<void>(error);
    notifications = notifications
        .map((AppNotification n) => n.markRead())
        .toList(growable: false);
    return const Success<void>(null);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(
      {this.stored = AppSettings.defaults, this.saveFailure});

  AppSettings stored;
  Failure? saveFailure;

  final List<AppSettings> savedValues = <AppSettings>[];

  @override
  Future<Result<AppSettings>> load() async => Success<AppSettings>(stored);

  @override
  Future<Result<void>> save(AppSettings settings) async {
    final Failure? failure = saveFailure;
    if (failure != null) return Failed<void>(failure);
    savedValues.add(settings);
    stored = settings;
    return const Success<void>(null);
  }
}
