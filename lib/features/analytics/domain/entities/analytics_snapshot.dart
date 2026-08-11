import 'package:equatable/equatable.dart';

import 'activity_event.dart';
import 'metric.dart';
import 'revenue_point.dart';

/// Which set of metrics a screen asks for.
///
/// The dashboard shows commercial headline figures; the analytics screen shows
/// audience and growth figures. Modelling this as a parameter keeps one
/// repository method instead of two near-identical ones.
enum MetricScope { dashboard, analytics }

/// Everything a dashboard-style screen renders, fetched as one unit.
///
/// Grouping these means the screen has a single loading state and a single
/// failure state, rather than three independently-resolving spinners that make
/// the page flicker as each lands.
class AnalyticsSnapshot extends Equatable {
  const AnalyticsSnapshot({
    required this.metrics,
    required this.revenueSeries,
    required this.recentActivity,
  });

  final List<Metric> metrics;
  final List<RevenuePoint> revenueSeries;
  final List<ActivityEvent> recentActivity;

  @override
  List<Object?> get props => <Object?>[metrics, revenueSeries, recentActivity];
}
