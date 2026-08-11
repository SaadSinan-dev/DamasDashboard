import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_query.dart';

sealed class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

final class ReportsError extends ReportsState {
  const ReportsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

final class ReportsReady extends ReportsState {
  const ReportsReady({
    required this.allReports,
    required this.visibleReports,
    required this.scheduled,
    required this.query,
    this.isRefreshing = false,
  });

  /// Everything the repository returned, before the query is applied.
  final List<Report> allReports;

  /// The result of applying [query] — what the list actually renders.
  final List<Report> visibleReports;

  final List<ScheduledReport> scheduled;
  final ReportQuery query;
  final bool isRefreshing;

  /// No reports exist at all — distinct from "the filter excluded them",
  /// because the two need different empty-state copy and different actions.
  bool get isEmpty => allReports.isEmpty;

  /// Reports exist but none match the current query.
  bool get hasNoMatches => allReports.isNotEmpty && visibleReports.isEmpty;

  @override
  List<Object?> get props =>
      <Object?>[allReports, visibleReports, scheduled, query, isRefreshing];
}
