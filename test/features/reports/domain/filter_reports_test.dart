import 'package:damas_dashboard/features/reports/domain/entities/report.dart';
import 'package:damas_dashboard/features/reports/domain/entities/report_query.dart';
import 'package:damas_dashboard/features/reports/domain/usecases/filter_reports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const FilterReports filterReports = FilterReports();

  // Stand-in for the localized names the presentation layer supplies.
  const Map<ReportKind, String> englishLabels = <ReportKind, String>{
    ReportKind.financialSummary: 'Quarterly financial summary',
    ReportKind.userEngagement: 'User engagement metrics',
    ReportKind.serverAudit: 'Annual server audit',
    ReportKind.revenueSync: 'Weekly revenue sync',
    ReportKind.churnBreakdown: 'Churn breakdown',
  };

  String labelOf(ReportKind kind) => englishLabels[kind]!;

  Report report(
    String id,
    ReportKind kind, {
    ReportStatus status = ReportStatus.ready,
    int? sizeBytes = 1000,
    int daysAgo = 0,
  }) =>
      Report(
        id: id,
        kind: kind,
        format: ReportFormat.pdf,
        status: status,
        sizeBytes: sizeBytes,
        generatedAt:
            DateTime.utc(2026, 3, 15).subtract(Duration(days: daysAgo)),
      );

  final List<Report> reports = <Report>[
    report('a', ReportKind.financialSummary, daysAgo: 1, sizeBytes: 500),
    report('b', ReportKind.userEngagement, daysAgo: 5, sizeBytes: 9000),
    report(
      'c',
      ReportKind.serverAudit,
      status: ReportStatus.generating,
      sizeBytes: null,
    ),
    report(
      'd',
      ReportKind.revenueSync,
      status: ReportStatus.failed,
      sizeBytes: null,
      daysAgo: 10,
    ),
  ];

  List<String> idsOf(List<Report> result) =>
      result.map((Report r) => r.id).toList();

  group('status filter', () {
    test('"all" keeps every report', () {
      final List<Report> result = filterReports(
        reports,
        const ReportQuery(),
        labelOf: labelOf,
      );
      expect(result, hasLength(reports.length));
    });

    test('narrows to a single status', () {
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(status: ReportStatusFilter.generating),
            labelOf: labelOf,
          ),
        ),
        <String>['c'],
      );
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(status: ReportStatusFilter.failed),
            labelOf: labelOf,
          ),
        ),
        <String>['d'],
      );
    });
  });

  group('search', () {
    test('matches the localized label, not the enum name', () {
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(searchTerm: 'financial'),
            labelOf: labelOf,
          ),
        ),
        <String>['a'],
      );
    });

    test('ignores case and surrounding whitespace', () {
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(searchTerm: '  ENGAGEMENT '),
            labelOf: labelOf,
          ),
        ),
        <String>['b'],
      );
    });

    test('an empty term does not filter anything out', () {
      expect(
        filterReports(
          reports,
          const ReportQuery(searchTerm: '   '),
          labelOf: labelOf,
        ).length,
        reports.length,
      );
    });

    test('searches the Arabic labels when those are supplied', () {
      const Map<ReportKind, String> arabicLabels = <ReportKind, String>{
        ReportKind.financialSummary: 'الملخّص المالي الربعي',
        ReportKind.userEngagement: 'مؤشرات تفاعل المستخدمين',
        ReportKind.serverAudit: 'التدقيق السنوي للخوادم',
        ReportKind.revenueSync: 'مزامنة الإيرادات الأسبوعية',
        ReportKind.churnBreakdown: 'تفصيل معدّل الإلغاء',
      };

      // Typed without the hamza on the alef, as a phone keyboard produces.
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(searchTerm: 'الايرادات'),
            labelOf: (ReportKind kind) => arabicLabels[kind]!,
          ),
        ),
        <String>['d'],
      );
    });

    test('combines with the status filter', () {
      expect(
        filterReports(
          reports,
          const ReportQuery(
            searchTerm: 'financial',
            status: ReportStatusFilter.failed,
          ),
          labelOf: labelOf,
        ),
        isEmpty,
      );
    });
  });

  group('sort', () {
    test('newest first is the default', () {
      expect(
        idsOf(filterReports(reports, const ReportQuery(), labelOf: labelOf)),
        <String>['c', 'a', 'b', 'd'],
      );
    });

    test('oldest first reverses it', () {
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(sort: ReportSort.oldest),
            labelOf: labelOf,
          ),
        ),
        <String>['d', 'b', 'a', 'c'],
      );
    });

    test('by name uses the localized label', () {
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(sort: ReportSort.name),
            labelOf: labelOf,
          ),
        ),
        <String>['c', 'a', 'b', 'd'],
      );
    });

    test('largest first ranks unknown sizes last, not as zero bytes', () {
      // 'c' and 'd' have no size yet; they must not outrank a real 500-byte file
      // by being treated as 0.
      expect(
        idsOf(
          filterReports(
            reports,
            const ReportQuery(sort: ReportSort.largest),
            labelOf: labelOf,
          ),
        ).take(2),
        <String>['b', 'a'],
      );
    });
  });

  test('does not mutate the input list', () {
    final List<Report> original = List<Report>.from(reports);
    filterReports(
      reports,
      const ReportQuery(sort: ReportSort.oldest),
      labelOf: labelOf,
    );
    expect(reports, original);
  });

  test('returns an unmodifiable list so state cannot be edited in place', () {
    final List<Report> result =
        filterReports(reports, const ReportQuery(), labelOf: labelOf);
    expect(() => result.add(reports.first), throwsUnsupportedError);
  });
}
