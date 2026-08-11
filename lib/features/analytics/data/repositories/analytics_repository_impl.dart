import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/entities/metric.dart';
import '../../domain/entities/revenue_point.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_data_source.dart';
import '../models/activity_event_dto.dart';
import '../models/metric_dto.dart';
import '../models/revenue_point_dto.dart';

/// Maps DTOs to entities and exceptions to failures.
///
/// All error handling is delegated to [guardAsync], which is why there is not a
/// single `try`/`catch` in this class.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl({
    required AnalyticsLocalDataSource dataSource,
    required Clock clock,
  })  : _dataSource = dataSource,
        _clock = clock;

  final AnalyticsLocalDataSource _dataSource;
  final Clock _clock;

  @override
  Future<Result<List<Metric>>> getMetrics(MetricScope scope) {
    return guardAsync(
      operation: 'getMetrics(${scope.name})',
      () async {
        final List<MetricDto> dtos = await _dataSource.fetchMetrics(scope.name);
        return dtos
            .map((MetricDto dto) => dto.toEntity())
            .toList(growable: false);
      },
    );
  }

  @override
  Future<Result<List<RevenuePoint>>> getRevenueSeries({int months = 12}) {
    return guardAsync(
      operation: 'getRevenueSeries',
      () async {
        final DateTime now = _clock.now();
        final List<RevenuePointDto> dtos =
            await _dataSource.fetchRevenueSeries();

        final List<RevenuePoint> points = dtos
            .map((RevenuePointDto dto) => dto.toEntity(now))
            .toList(growable: false)
          ..sort(
              (RevenuePoint a, RevenuePoint b) => a.month.compareTo(b.month));

        // Trimming happens here rather than in the data source so the same cached
        // payload can serve callers asking for different windows.
        if (points.length <= months) return points;
        return points.sublist(points.length - months);
      },
    );
  }

  @override
  Future<Result<List<ActivityEvent>>> getRecentActivity({int limit = 5}) {
    return guardAsync(
      operation: 'getRecentActivity',
      () async {
        final DateTime now = _clock.now();
        final List<ActivityEvent> events = (await _dataSource.fetchActivity())
            .map((ActivityEventDto dto) => dto.toEntity(now))
            .toList(growable: false)
          ..sort(
            (ActivityEvent a, ActivityEvent b) =>
                b.occurredAt.compareTo(a.occurredAt),
          );

        return events.take(limit).toList(growable: false);
      },
    );
  }
}
