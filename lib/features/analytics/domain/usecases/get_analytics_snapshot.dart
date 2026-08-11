import '../../../../core/result/result.dart';
import '../entities/activity_event.dart';
import '../entities/analytics_snapshot.dart';
import '../entities/metric.dart';
import '../entities/revenue_point.dart';
import '../repositories/analytics_repository.dart';

/// Loads everything a dashboard-style screen needs, as one atomic result.
///
/// This use case earns its place by doing something no repository method does:
/// it issues the three reads **concurrently** and collapses them into a single
/// success or failure. Without it, both the dashboard and the analytics screen
/// would each reimplement that orchestration in their cubit.
class GetAnalyticsSnapshot {
  const GetAnalyticsSnapshot(this._repository);

  final AnalyticsRepository _repository;

  Future<Result<AnalyticsSnapshot>> call({
    MetricScope scope = MetricScope.dashboard,
    int revenueMonths = 12,
    int activityLimit = 5,
  }) async {
    final (
      Result<List<Metric>> metrics,
      Result<List<RevenuePoint>> series,
      Result<List<ActivityEvent>> activity,
    ) = await (
      _repository.getMetrics(scope),
      _repository.getRevenueSeries(months: revenueMonths),
      _repository.getRecentActivity(limit: activityLimit),
    ).wait;

    // A dashboard that renders its metrics but silently drops its chart is worse
    // than an honest error with a retry, so any single failure fails the whole
    // snapshot.
    return switch ((metrics, series, activity)) {
      (
        Success<List<Metric>>(value: final List<Metric> m),
        Success<List<RevenuePoint>>(value: final List<RevenuePoint> r),
        Success<List<ActivityEvent>>(value: final List<ActivityEvent> a),
      ) =>
        Success<AnalyticsSnapshot>(
          AnalyticsSnapshot(
            metrics: m,
            revenueSeries: r,
            recentActivity: a,
          ),
        ),
      (Failed<List<Metric>>(:final failure), _, _) =>
        Failed<AnalyticsSnapshot>(failure),
      (_, Failed<List<RevenuePoint>>(:final failure), _) =>
        Failed<AnalyticsSnapshot>(failure),
      (_, _, Failed<List<ActivityEvent>>(:final failure)) =>
        Failed<AnalyticsSnapshot>(failure),
    };
  }
}
