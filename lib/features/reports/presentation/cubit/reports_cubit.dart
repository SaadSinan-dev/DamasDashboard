import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_query.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/filter_reports.dart';
import 'reports_state.dart';

/// Owns the reports list, its query, and the delete flow.
///
/// The widget layer never filters or sorts: it dispatches `search`, `filterBy`
/// and `sortBy`, and renders `visibleReports`.
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required ReportsRepository repository,
    required FilterReports filterReports,
  })  : _repository = repository,
        _filterReports = filterReports,
        super(const ReportsInitial());

  final ReportsRepository _repository;
  final FilterReports _filterReports;

  /// Localized report names, supplied by the presentation layer and refreshed
  /// when the locale changes. Search and name-sort run against these so a user
  /// can find a report by typing its name in the language they see it in.
  Map<ReportKind, String> _labels = const <ReportKind, String>{};

  /// Debounces keystrokes so a five-character search does not recompute the
  /// list five times.
  Timer? _searchDebounce;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 250);

  bool _isFetching = false;

  String _labelOf(ReportKind kind) => _labels[kind] ?? kind.name;

  /// Supplies translated report names. Re-applies the query if they changed.
  void setLabels(Map<ReportKind, String> labels) {
    if (_labels.length == labels.length &&
        labels.entries.every(
          (MapEntry<ReportKind, String> e) => _labels[e.key] == e.value,
        )) {
      return;
    }
    _labels = Map<ReportKind, String>.unmodifiable(labels);

    final ReportsState current = state;
    if (current is ReportsReady) {
      emit(_readyWith(current, current.query));
    }
  }

  Future<void> load() async {
    if (_isFetching) return;
    emit(const ReportsLoading());
    await _fetch(const ReportQuery());
  }

  Future<void> refresh() async {
    if (_isFetching) return;
    final ReportsState current = state;
    final ReportQuery query =
        current is ReportsReady ? current.query : const ReportQuery();
    if (current is ReportsReady) {
      emit(
        ReportsReady(
          allReports: current.allReports,
          visibleReports: current.visibleReports,
          scheduled: current.scheduled,
          query: current.query,
          isRefreshing: true,
        ),
      );
    } else {
      emit(const ReportsLoading());
    }
    await _fetch(query);
  }

  void search(String term) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDelay, () {
      final ReportsState current = state;
      if (current is! ReportsReady) return;
      emit(_readyWith(current, current.query.copyWith(searchTerm: term)));
    });
  }

  void filterBy(ReportStatusFilter filter) {
    final ReportsState current = state;
    if (current is! ReportsReady) return;
    emit(_readyWith(current, current.query.copyWith(status: filter)));
  }

  void sortBy(ReportSort sort) {
    final ReportsState current = state;
    if (current is! ReportsReady) return;
    emit(_readyWith(current, current.query.copyWith(sort: sort)));
  }

  /// Deletes a report, returning the outcome so the caller can confirm or report
  /// the failure to the user.
  Future<Result<void>> deleteReport(String id) async {
    final Result<void> result = await _repository.deleteReport(id);
    if (isClosed) return result;

    final ReportsState current = state;
    if (result.isSuccess && current is ReportsReady) {
      final List<Report> remaining = current.allReports
          .where((Report report) => report.id != id)
          .toList(growable: false);
      // Re-applies the active query, so the row disappears without the filter
      // or sort the user had set being reset.
      emit(
        _ready(
          allReports: remaining,
          scheduled: current.scheduled,
          query: current.query,
        ),
      );
    }
    return result;
  }

  Future<void> _fetch(ReportQuery query) async {
    _isFetching = true;
    try {
      final (
        Result<List<Report>> reports,
        Result<List<ScheduledReport>> scheduled
      ) = await (
        _repository.getReports(),
        _repository.getScheduledReports(),
      ).wait;

      if (isClosed) return;

      final Failure? failure = reports.failureOrNull ?? scheduled.failureOrNull;
      if (failure != null) {
        emit(ReportsError(failure));
        return;
      }

      emit(
        _ready(
          allReports: reports.valueOrNull!,
          scheduled: scheduled.valueOrNull!,
          query: query,
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  /// Builds a ready state with [ReportsReady.visibleReports] derived from
  /// [query].
  ///
  /// Every emission goes through here, which is what guarantees the visible list
  /// can never drift out of step with the query that produced it.
  ReportsReady _ready({
    required List<Report> allReports,
    required List<ScheduledReport> scheduled,
    required ReportQuery query,
  }) {
    return ReportsReady(
      allReports: allReports,
      visibleReports: _filterReports(allReports, query, labelOf: _labelOf),
      scheduled: scheduled,
      query: query,
    );
  }

  /// Re-derives [current] under a new [query], keeping its loaded data.
  ReportsReady _readyWith(ReportsReady current, ReportQuery query) {
    return _ready(
      allReports: current.allReports,
      scheduled: current.scheduled,
      query: query,
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
