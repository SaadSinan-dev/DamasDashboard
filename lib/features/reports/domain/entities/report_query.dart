import 'package:equatable/equatable.dart';

import 'report.dart';

/// Status filter offered in the reports toolbar.
enum ReportStatusFilter {
  all(null),
  ready(ReportStatus.ready),
  generating(ReportStatus.generating),
  failed(ReportStatus.failed);

  const ReportStatusFilter(this.status);

  /// The status this filter admits, or `null` for "no filter".
  final ReportStatus? status;

  bool admits(Report report) => status == null || report.status == status;
}

/// Sort orders offered in the reports toolbar.
enum ReportSort { newest, oldest, name, largest }

/// The complete description of what the reports list should show.
///
/// Bundling the three controls into one value means the cubit has a single
/// field to update and a single thing to recompute from, instead of three
/// fields that can drift out of step.
class ReportQuery extends Equatable {
  const ReportQuery({
    this.searchTerm = '',
    this.status = ReportStatusFilter.all,
    this.sort = ReportSort.newest,
  });

  final String searchTerm;
  final ReportStatusFilter status;
  final ReportSort sort;

  bool get isFiltered =>
      searchTerm.trim().isNotEmpty || status != ReportStatusFilter.all;

  ReportQuery copyWith({
    String? searchTerm,
    ReportStatusFilter? status,
    ReportSort? sort,
  }) =>
      ReportQuery(
        searchTerm: searchTerm ?? this.searchTerm,
        status: status ?? this.status,
        sort: sort ?? this.sort,
      );

  @override
  List<Object?> get props => <Object?>[searchTerm, status, sort];
}
