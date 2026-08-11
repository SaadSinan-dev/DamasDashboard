import 'package:damas_dashboard/core/di/injector.dart';
import 'package:damas_dashboard/core/error/failure.dart';
import 'package:damas_dashboard/core/widgets/app_state_views.dart';
import 'package:damas_dashboard/features/reports/domain/entities/report.dart';
import 'package:damas_dashboard/features/reports/domain/repositories/reports_repository.dart';
import 'package:damas_dashboard/features/reports/domain/usecases/filter_reports.dart';
import 'package:damas_dashboard/features/reports/presentation/pages/reports_page.dart';
import 'package:damas_dashboard/features/reports/presentation/widgets/report_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

/// Exercises the reports screen against fake dependencies registered in the real
/// service locator, so the page, its cubit and the use case are wired together
/// exactly as they are in the app.
/// Comfortably longer than the cubit's search debounce.
const Duration _beyondSearchDebounce = Duration(milliseconds: 400);

void main() {
  late FakeReportsRepository repository;

  Report report(String id, ReportKind kind,
          {ReportStatus status = ReportStatus.ready}) =>
      Report(
        id: id,
        kind: kind,
        format: ReportFormat.pdf,
        status: status,
        sizeBytes: status == ReportStatus.ready ? 2516582 : null,
        generatedAt: DateTime.utc(2026, 3, 14),
      );

  setUp(() {
    repository = FakeReportsRepository(
      reports: <Report>[
        report('a', ReportKind.financialSummary),
        report('b', ReportKind.userEngagement),
        report('c', ReportKind.serverAudit, status: ReportStatus.generating),
      ],
      scheduled: <ScheduledReport>[
        const ScheduledReport(
          id: 's1',
          kind: ReportKind.revenueSync,
          weekday: DateTime.monday,
          hour: 8,
          minute: 0,
          recipient: 'ops@damas.example',
        ),
      ],
    );

    sl
      ..registerFactory<ReportsRepository>(() => repository)
      ..registerFactory<FilterReports>(FilterReports.new);
  });

  tearDown(resetDependencies);

  testWidgets('shows a spinner before data arrives',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());

    expect(find.byType(AppLoadingView), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('renders the reports once loaded', (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    expect(find.byType(ReportTile), findsNWidgets(3));
    expect(find.text('Quarterly financial summary'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('shows a retryable error when loading fails',
      (WidgetTester tester) async {
    repository.reportsFailure = const NetworkFailure();

    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Connection problem'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('retry re-requests and recovers', (WidgetTester tester) async {
    repository.reportsFailure = const NetworkFailure();
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    repository.reportsFailure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportTile), findsNWidgets(3));
  });

  testWidgets('shows the empty state when there are no reports at all',
      (WidgetTester tester) async {
    repository.reports = <Report>[];

    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    expect(find.text('No reports yet'), findsOneWidget);
  });

  testWidgets('filtering by status narrows the list',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'Generating'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportTile), findsOneWidget);
    expect(find.text('Annual server audit'), findsOneWidget);
  });

  testWidgets('searching narrows the list and reports no matches',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'engagement');
    // Search is debounced, so the timer has to be allowed to fire; pumpAndSettle
    // alone returns as soon as no frame is scheduled.
    await tester.pump(_beyondSearchDebounce);
    await tester.pumpAndSettle();
    expect(find.byType(ReportTile), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(_beyondSearchDebounce);
    await tester.pumpAndSettle();
    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('deleting asks for confirmation and can be cancelled',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('Delete this report?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.deletedIds, isEmpty);
    expect(find.byType(ReportTile), findsNWidgets(3));
  });

  testWidgets('confirming the dialog deletes the report and confirms it',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repository.deletedIds, hasLength(1));
    expect(find.byType(ReportTile), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('renders in Arabic with right-to-left direction',
      (WidgetTester tester) async {
    await tester.pumpApp(const ReportsPage(), locale: const Locale('ar'));
    await tester.pumpAndSettle();

    expect(find.text('التقارير'), findsOneWidget);
    expect(find.text('الملخّص المالي الربعي'), findsOneWidget);

    final BuildContext context = tester.element(find.byType(ReportTile).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
