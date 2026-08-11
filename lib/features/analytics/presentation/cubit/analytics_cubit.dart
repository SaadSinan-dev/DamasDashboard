import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/usecases/get_analytics_snapshot.dart';
import 'analytics_state.dart';

/// Drives both the dashboard and the analytics screen.
///
/// The two screens differ only in which [MetricScope] they request and how much
/// history they show, so they share one cubit configured differently rather than
/// two near-identical copies.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({
    required GetAnalyticsSnapshot getAnalyticsSnapshot,
    required this.scope,
    this.revenueMonths = 12,
    this.activityLimit = 5,
  })  : _getAnalyticsSnapshot = getAnalyticsSnapshot,
        super(const AnalyticsInitial());

  final GetAnalyticsSnapshot _getAnalyticsSnapshot;
  final MetricScope scope;
  final int revenueMonths;
  final int activityLimit;

  /// Guards against overlapping loads — a user pulling to refresh while the
  /// first load is still running would otherwise race two responses, and the
  /// slower one would win.
  bool _isFetching = false;

  /// Initial load. Shows a full-screen spinner.
  Future<void> load() async {
    if (_isFetching) return;
    emit(const AnalyticsLoading());
    await _fetch();
  }

  /// Re-fetch that keeps the current data visible while it runs.
  Future<void> refresh() async {
    if (_isFetching) return;
    final AnalyticsState current = state;
    emit(
      current is AnalyticsReady
          ? current.copyWith(isRefreshing: true)
          : const AnalyticsLoading(),
    );
    await _fetch();
  }

  Future<void> _fetch() async {
    _isFetching = true;
    try {
      final Result<AnalyticsSnapshot> result = await _getAnalyticsSnapshot(
        scope: scope,
        revenueMonths: revenueMonths,
        activityLimit: activityLimit,
      );

      // The screen may have been popped while the request was in flight.
      if (isClosed) return;

      emit(
        switch (result) {
          Success<AnalyticsSnapshot>(:final AnalyticsSnapshot value) =>
            AnalyticsReady(value),
          Failed<AnalyticsSnapshot>(:final failure) => AnalyticsError(failure),
        },
      );
    } finally {
      _isFetching = false;
    }
  }
}
