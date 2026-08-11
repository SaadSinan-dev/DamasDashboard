import '../../../../core/result/result.dart';
import '../entities/activity_event.dart';
import '../entities/analytics_snapshot.dart';
import '../entities/metric.dart';
import '../entities/revenue_point.dart';

/// Contract the analytics feature depends on.
///
/// Declared in the domain layer and implemented in the data layer, so the
/// direction of dependency points inward: presentation and domain know nothing
/// about JSON assets, HTTP or caching.
abstract interface class AnalyticsRepository {
  Future<Result<List<Metric>>> getMetrics(MetricScope scope);

  Future<Result<List<RevenuePoint>>> getRevenueSeries({int months});

  Future<Result<List<ActivityEvent>>> getRecentActivity({int limit});
}
