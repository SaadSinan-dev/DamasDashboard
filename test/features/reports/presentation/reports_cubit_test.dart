import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/result/result.dart';
import 'package:damas_dashboard/features/reports/domain/entities/report.dart';
import 'package:damas_dashboard/features/reports/domain/entities/report_query.dart';
import 'package:damas_dashboard/features/reports/domain/usecases/filter_reports.dart';
import 'package:damas_dashboard/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:damas_dashboard/features/reports/presentation/cubit/reports_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  Report report(String id, ReportKind kind,
          {ReportStatus status = ReportStatus.ready}) =>
      Report(
        id: id,
        kind: kind,
        format: ReportFormat.pdf,
        status: status,
        sizeBytes: 1000,
        generatedAt: DateTime.utc(2026, 3, 15),
      );

  late FakeReportsRepository repository;
  late ReportsCubit cubit;

  const Map<ReportKind, String> labels = <ReportKind, String>{
    ReportKind.financialSummary: 'Quarterly financial summary',
    ReportKind.userEngagement: 'User engagement metrics',
    ReportKind.serverAudit: 'Annual server audit',
    ReportKind.revenueSync: 'Weekly revenue sync',
    ReportKind.churnBreakdown: 'Churn breakdown',
  };

  setUp(() {
    repository = FakeReportsRepository(
      reports: <Report>[
        report('a', ReportKind.financialSummary),
        report('b', ReportKind.userEngagement),
        report('c', ReportKind.serverAudit, status: ReportStatus.generating),
      ],
    );
    cubit = ReportsCubit(
      repository: repository,
      filterReports: const FilterReports(),
    )..setLabels(labels);
  });

  tearDown(() => cubit.close());

  test('starts in the initial state', () {
    expect(cubit.state, isA<ReportsInitial>());
  });

  test('emits loading then ready on a successful load', () async {
    final Future<void> states = expectLater(
      cubit.stream,
      emitsInOrder(<Matcher>[isA<ReportsLoading>(), isA<ReportsReady>()]),
    );

    await cubit.load();
    await states;

    final ReportsReady state = cubit.state as ReportsReady;
    expect(state.allReports, hasLength(3));
    expect(state.visibleReports, hasLength(3));
  });

  test('emits an error state carrying the failure', () async {
    repository.reportsFailure = const NetworkFailure();

    await cubit.load();

    expect(cubit.state, isA<ReportsError>());
    expect((cubit.state as ReportsError).failure, isA<NetworkFailure>());
  });

  group('query', () {
    setUp(() => cubit.load());

    test('filtering by status narrows the visible list only', () {
      cubit.filterBy(ReportStatusFilter.generating);

      final ReportsReady state = cubit.state as ReportsReady;
      expect(state.visibleReports.map((Report r) => r.id), <String>['c']);
      // The unfiltered list is retained so clearing the filter needs no refetch.
      expect(state.allReports, hasLength(3));
    });

    test('search is debounced rather than applied per keystroke', () async {
      cubit
        ..search('fin')
        ..search('finan')
        ..search('financial');

      // Nothing has changed yet — the timer has not fired.
      expect((cubit.state as ReportsReady).visibleReports, hasLength(3));

      await Future<void>.delayed(const Duration(milliseconds: 300));

      final ReportsReady state = cubit.state as ReportsReady;
      expect(state.visibleReports.map((Report r) => r.id), <String>['a']);
      expect(state.query.searchTerm, 'financial');
    });

    test('reports no matches separately from having no reports', () async {
      cubit.search('nonexistent');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final ReportsReady state = cubit.state as ReportsReady;
      expect(state.hasNoMatches, isTrue);
      expect(state.isEmpty, isFalse);
    });

    test('sorting changes order without refetching', () {
      cubit.sortBy(ReportSort.name);
      expect((cubit.state as ReportsReady).query.sort, ReportSort.name);
    });

    test('changing labels re-applies the active search', () async {
      cubit.search('التدقيق');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect((cubit.state as ReportsReady).visibleReports, isEmpty);

      // Switching to Arabic must make the Arabic search term match.
      cubit.setLabels(const <ReportKind, String>{
        ReportKind.financialSummary: 'الملخّص المالي الربعي',
        ReportKind.userEngagement: 'مؤشرات تفاعل المستخدمين',
        ReportKind.serverAudit: 'التدقيق السنوي للخوادم',
        ReportKind.revenueSync: 'مزامنة الإيرادات الأسبوعية',
        ReportKind.churnBreakdown: 'تفصيل معدّل الإلغاء',
      });

      expect(
        (cubit.state as ReportsReady).visibleReports.map((Report r) => r.id),
        <String>['c'],
      );
    });
  });

  group('delete', () {
    setUp(() => cubit.load());

    test('removes the report and reports success', () async {
      final Result<void> result = await cubit.deleteReport('a');

      expect(result.isSuccess, isTrue);
      expect(repository.deletedIds, <String>['a']);

      final ReportsReady state = cubit.state as ReportsReady;
      expect(state.allReports.map((Report r) => r.id), <String>['b', 'c']);
      expect(
          state.visibleReports.map((Report r) => r.id), isNot(contains('a')));
    });

    test('leaves state untouched and returns the failure when it fails',
        () async {
      repository.deleteFailure = const NotFoundFailure(resourceId: 'a');

      final Result<void> result = await cubit.deleteReport('a');

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect((cubit.state as ReportsReady).allReports, hasLength(3));
    });

    test('preserves the active filter after deleting', () async {
      cubit.filterBy(ReportStatusFilter.ready);
      await cubit.deleteReport('a');

      final ReportsReady state = cubit.state as ReportsReady;
      expect(state.query.status, ReportStatusFilter.ready);
      expect(state.visibleReports.map((Report r) => r.id), <String>['b']);
    });
  });

  test('refresh keeps the previous data visible while it runs', () async {
    await cubit.load();
    final List<ReportsState> observed = <ReportsState>[];
    final subscription = cubit.stream.listen(observed.add);

    await cubit.refresh();
    await subscription.cancel();

    // The first emission is still a Ready state, not a Loading one, so the list
    // does not blank out under the user.
    expect(observed.first, isA<ReportsReady>());
    expect((observed.first as ReportsReady).isRefreshing, isTrue);
  });

  test('does not emit after close', () async {
    await cubit.load();
    await cubit.close();
    // Would throw a StateError if the cubit emitted after being closed.
    await cubit.deleteReport('a');
  });
}
