import '../../../../core/utils/search_text.dart';
import '../entities/report.dart';
import '../entities/report_query.dart';

/// Applies a [ReportQuery] to a list of reports.
///
/// This is the feature's real business logic — searching, filtering and sorting
/// — extracted so it can be unit-tested without a widget tree and reused by any
/// screen that lists reports.
///
/// The caller supplies a label resolver for [ReportKind]. Passing it in keeps
/// translation out of the domain while still letting an Arabic user search for
/// «الملخّص المالي» and an English user search for "financial".
class FilterReports {
  const FilterReports();

  List<Report> call(
    List<Report> reports,
    ReportQuery query, {
    required String Function(ReportKind kind) labelOf,
  }) {
    final List<Report> filtered = reports
        .where(query.status.admits)
        .where(
          (Report report) =>
              matchesSearch(labelOf(report.kind), query.searchTerm),
        )
        .toList()
      ..sort(
        (Report a, Report b) => switch (query.sort) {
          ReportSort.newest => b.generatedAt.compareTo(a.generatedAt),
          ReportSort.oldest => a.generatedAt.compareTo(b.generatedAt),
          // Locale-aware collation is out of scope; a plain comparison is
          // stable and predictable, which is what matters for a short list.
          ReportSort.name => labelOf(a.kind).compareTo(labelOf(b.kind)),
          // Reports still generating have no size yet, so they sort last
          // rather than being treated as zero-byte files.
          ReportSort.largest =>
            (b.sizeBytes ?? -1).compareTo(a.sizeBytes ?? -1),
        },
      );

    return List<Report>.unmodifiable(filtered);
  }
}
