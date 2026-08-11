import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/analytics_snapshot.dart';

/// States an analytics-style screen can be in.
///
/// Sealed so that `switch` in the widget layer is exhaustive: adding a state
/// later breaks the build at every screen that renders it, rather than silently
/// falling through to a blank frame.
sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Nothing requested yet.
final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// First load, with nothing to show behind it.
final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// Data available. [isRefreshing] is true while a pull-to-refresh runs, which
/// lets the screen keep showing the previous data instead of flashing a spinner.
final class AnalyticsReady extends AnalyticsState {
  const AnalyticsReady(this.snapshot, {this.isRefreshing = false});

  final AnalyticsSnapshot snapshot;
  final bool isRefreshing;

  /// True when the source returned successfully but had nothing in it.
  bool get isEmpty =>
      snapshot.metrics.isEmpty &&
      snapshot.revenueSeries.isEmpty &&
      snapshot.recentActivity.isEmpty;

  AnalyticsReady copyWith({bool? isRefreshing}) => AnalyticsReady(
        snapshot,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => <Object?>[snapshot, isRefreshing];
}

/// The load failed and there is nothing cached to fall back on.
final class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}
