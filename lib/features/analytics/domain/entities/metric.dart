import 'package:equatable/equatable.dart';

/// How a metric's value should be formatted.
enum MetricUnit { currency, count, percent }

/// The metrics the product tracks.
///
/// Each member carries its own unit and its own notion of which direction is
/// good — churn rising is bad while revenue rising is good — so the rule lives
/// with the data instead of being re-derived by each widget that draws it.
enum MetricId {
  netRevenue(unit: MetricUnit.currency),
  subscriptions(unit: MetricUnit.count),
  churnRate(unit: MetricUnit.percent, lowerIsBetter: true),
  activeUsers(unit: MetricUnit.count),
  totalUsers(unit: MetricUnit.count),
  growth(unit: MetricUnit.percent);

  const MetricId({required this.unit, this.lowerIsBetter = false});

  final MetricUnit unit;

  /// True when a decrease is the desirable outcome.
  final bool lowerIsBetter;
}

/// Direction of change against the previous period.
enum MetricTrend { up, down, flat }

/// A key performance indicator and its previous-period comparison.
class Metric extends Equatable {
  const Metric({
    required this.id,
    required this.value,
    required this.previousValue,
  });

  final MetricId id;
  final double value;
  final double previousValue;

  /// Values closer together than this are treated as unchanged, which keeps
  /// floating-point noise from rendering as a 0.0% "change".
  static const double _flatThreshold = 1e-9;

  MetricUnit get unit => id.unit;

  double get absoluteChange => value - previousValue;

  /// Change as a fraction of the previous value, or `null` when there is no
  /// baseline to compare against (division by zero is not a 0% change).
  double? get changeRatio {
    if (previousValue.abs() < _flatThreshold) return null;
    return absoluteChange / previousValue.abs();
  }

  MetricTrend get trend {
    if (absoluteChange.abs() < _flatThreshold) return MetricTrend.flat;
    return absoluteChange > 0 ? MetricTrend.up : MetricTrend.down;
  }

  /// Whether the movement is good news, accounting for metrics where lower is
  /// better. Drives the colour of the trend badge.
  bool get isFavourable => switch (trend) {
        MetricTrend.flat => true,
        MetricTrend.up => !id.lowerIsBetter,
        MetricTrend.down => id.lowerIsBetter,
      };

  @override
  List<Object?> get props => <Object?>[id, value, previousValue];
}
