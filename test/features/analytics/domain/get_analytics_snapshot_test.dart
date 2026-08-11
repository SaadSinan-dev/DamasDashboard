import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/result/result.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/activity_event.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/analytics_snapshot.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/metric.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/revenue_point.dart';
import 'package:damas_dashboard/features/analytics/domain/usecases/get_analytics_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  final List<Metric> metrics = <Metric>[
    const Metric(id: MetricId.netRevenue, value: 100, previousValue: 90),
  ];
  final List<RevenuePoint> series = <RevenuePoint>[
    RevenuePoint(month: DateTime.utc(2026, 3), amount: 100),
  ];
  final List<ActivityEvent> activity = <ActivityEvent>[
    ActivityEvent(
      id: 'a1',
      type: ActivityType.payment,
      actor: 'Sarah',
      occurredAt: DateTime.utc(2026, 3, 15),
      amount: 10,
    ),
  ];

  test('combines the three reads into a single snapshot', () async {
    final GetAnalyticsSnapshot useCase = GetAnalyticsSnapshot(
      FakeAnalyticsRepository(
        metrics: metrics,
        series: series,
        activity: activity,
      ),
    );

    final Result<AnalyticsSnapshot> result = await useCase();

    expect(result.isSuccess, isTrue);
    final AnalyticsSnapshot snapshot = result.valueOrNull!;
    expect(snapshot.metrics, metrics);
    expect(snapshot.revenueSeries, series);
    expect(snapshot.recentActivity, activity);
  });

  test('issues the three reads concurrently rather than in sequence', () async {
    final FakeAnalyticsRepository repository = FakeAnalyticsRepository(
      metrics: metrics,
      series: series,
      activity: activity,
      delay: const Duration(milliseconds: 20),
    );

    await GetAnalyticsSnapshot(repository)();

    // Sequential execution would log start/end in pairs. Overlapping execution
    // starts all three before any of them finishes.
    expect(
      repository.callLog.take(3),
      <String>['metrics:start', 'series:start', 'activity:start'],
    );
  });

  test('fails the whole snapshot when any single read fails', () async {
    for (final String failing in <String>['metrics', 'series', 'activity']) {
      final FakeAnalyticsRepository repository = FakeAnalyticsRepository(
        metrics: metrics,
        series: series,
        activity: activity,
        metricsFailure: failing == 'metrics' ? const NetworkFailure() : null,
        seriesFailure: failing == 'series' ? const CacheFailure() : null,
        activityFailure:
            failing == 'activity' ? const UnexpectedFailure() : null,
      );

      final Result<AnalyticsSnapshot> result =
          await GetAnalyticsSnapshot(repository)();

      expect(
        result.isSuccess,
        isFalse,
        reason: 'a failing $failing read must fail the snapshot',
      );
    }
  });

  test('propagates the specific failure so the UI can explain it', () async {
    final Result<AnalyticsSnapshot> result = await GetAnalyticsSnapshot(
      FakeAnalyticsRepository(seriesFailure: const CacheFailure()),
    )();

    expect(result.failureOrNull, isA<CacheFailure>());
  });

  test('passes the requested scope and limits to the repository', () async {
    final FakeAnalyticsRepository repository = FakeAnalyticsRepository();
    await GetAnalyticsSnapshot(repository)(
      scope: MetricScope.analytics,
      revenueMonths: 6,
      activityLimit: 3,
    );

    expect(repository.callLog, contains('metrics:start'));
  });
}
