import 'package:damas_dashboard/core/error/exceptions.dart';
import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/result/result.dart';
import 'package:damas_dashboard/features/analytics/data/datasources/analytics_local_data_source.dart';
import 'package:damas_dashboard/features/analytics/data/models/activity_event_dto.dart';
import 'package:damas_dashboard/features/analytics/data/models/metric_dto.dart';
import 'package:damas_dashboard/features/analytics/data/models/revenue_point_dto.dart';
import 'package:damas_dashboard/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/activity_event.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/analytics_snapshot.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/metric.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/revenue_point.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

class _StubDataSource implements AnalyticsLocalDataSource {
  _StubDataSource({
    this.metrics = const <MetricDto>[],
    this.series = const <RevenuePointDto>[],
    this.activity = const <ActivityEventDto>[],
    this.error,
  });

  List<MetricDto> metrics;
  List<RevenuePointDto> series;
  List<ActivityEventDto> activity;
  Object? error;

  @override
  Future<List<MetricDto>> fetchMetrics(String scope) async {
    if (error != null) throw error!;
    return metrics;
  }

  @override
  Future<List<RevenuePointDto>> fetchRevenueSeries() async {
    if (error != null) throw error!;
    return series;
  }

  @override
  Future<List<ActivityEventDto>> fetchActivity() async {
    if (error != null) throw error!;
    return activity;
  }
}

void main() {
  final DateTime now = DateTime.utc(2026, 3, 15, 12);
  final FixedClock clock = FixedClock(now);

  AnalyticsRepositoryImpl repositoryWith(_StubDataSource source) =>
      AnalyticsRepositoryImpl(dataSource: source, clock: clock);

  group('getMetrics', () {
    test('maps DTOs onto domain entities', () async {
      final Result<List<Metric>> result = await repositoryWith(
        _StubDataSource(
          metrics: const <MetricDto>[
            MetricDto(id: 'netRevenue', value: 100, previousValue: 80),
          ],
        ),
      ).getMetrics(MetricScope.dashboard);

      expect(
        result.valueOrNull,
        <Metric>[
          const Metric(id: MetricId.netRevenue, value: 100, previousValue: 80),
        ],
      );
    });

    test('turns an unknown metric id into a CacheFailure rather than crashing',
        () async {
      final Result<List<Metric>> result = await repositoryWith(
        _StubDataSource(
          metrics: const <MetricDto>[
            MetricDto(id: 'notAMetric', value: 1, previousValue: 1),
          ],
        ),
      ).getMetrics(MetricScope.dashboard);

      expect(result.failureOrNull, isA<CacheFailure>());
    });
  });

  group('getRevenueSeries', () {
    test('resolves month offsets against the injected clock', () async {
      final Result<List<RevenuePoint>> result = await repositoryWith(
        _StubDataSource(
          series: const <RevenuePointDto>[
            RevenuePointDto(monthsAgo: 1, amount: 10),
          ],
        ),
      ).getRevenueSeries();

      // "One month before 15 March 2026" normalises to the first of February.
      expect(result.valueOrNull!.single.month, DateTime(2026, 2));
    });

    test('sorts oldest to newest so the chart reads left to right', () async {
      final Result<List<RevenuePoint>> result = await repositoryWith(
        _StubDataSource(
          series: const <RevenuePointDto>[
            RevenuePointDto(monthsAgo: 0, amount: 30),
            RevenuePointDto(monthsAgo: 2, amount: 10),
            RevenuePointDto(monthsAgo: 1, amount: 20),
          ],
        ),
      ).getRevenueSeries();

      expect(
        result.valueOrNull!.map((RevenuePoint p) => p.amount),
        <double>[10, 20, 30],
      );
    });

    test('trims to the requested window, keeping the most recent months',
        () async {
      final Result<List<RevenuePoint>> result = await repositoryWith(
        _StubDataSource(
          series: List<RevenuePointDto>.generate(
            12,
            (int i) => RevenuePointDto(monthsAgo: i, amount: i.toDouble()),
          ),
        ),
      ).getRevenueSeries(months: 3);

      expect(result.valueOrNull, hasLength(3));
      expect(
        result.valueOrNull!.map((RevenuePoint p) => p.amount),
        <double>[2, 1, 0],
      );
    });

    test('returns everything when fewer months exist than requested', () async {
      final Result<List<RevenuePoint>> result = await repositoryWith(
        _StubDataSource(
          series: const <RevenuePointDto>[
            RevenuePointDto(monthsAgo: 0, amount: 1),
          ],
        ),
      ).getRevenueSeries(months: 24);

      expect(result.valueOrNull, hasLength(1));
    });
  });

  group('getRecentActivity', () {
    test('sorts newest first and applies the limit', () async {
      final Result<List<ActivityEvent>> result = await repositoryWith(
        _StubDataSource(
          activity: const <ActivityEventDto>[
            ActivityEventDto(
              id: 'old',
              type: 'signup',
              actor: 'A',
              minutesAgo: 500,
            ),
            ActivityEventDto(
              id: 'new',
              type: 'signup',
              actor: 'B',
              minutesAgo: 5,
            ),
            ActivityEventDto(
              id: 'mid',
              type: 'signup',
              actor: 'C',
              minutesAgo: 50,
            ),
          ],
        ),
      ).getRecentActivity(limit: 2);

      expect(
        result.valueOrNull!.map((ActivityEvent e) => e.id),
        <String>['new', 'mid'],
      );
    });
  });

  group('exception mapping', () {
    test('NotFoundException becomes NotFoundFailure', () async {
      final Result<List<Metric>> result = await repositoryWith(
        _StubDataSource(
            error: const NotFoundException('missing', resourceId: 'x')),
      ).getMetrics(MetricScope.dashboard);

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(
        (result.failureOrNull! as NotFoundFailure).resourceId,
        'x',
      );
    });

    test('CacheException becomes CacheFailure', () async {
      final Result<List<Metric>> result = await repositoryWith(
        _StubDataSource(error: const CacheException('bad json')),
      ).getMetrics(MetricScope.dashboard);

      expect(result.failureOrNull, isA<CacheFailure>());
    });

    test('an unrecognised error becomes UnexpectedFailure, not a crash',
        () async {
      final Result<List<Metric>> result = await repositoryWith(
        _StubDataSource(error: ArgumentError('boom')),
      ).getMetrics(MetricScope.dashboard);

      expect(result.failureOrNull, isA<UnexpectedFailure>());
    });
  });
}
