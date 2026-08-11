import 'package:damas_dashboard/core/theme/app_semantic_colors.dart';
import 'package:damas_dashboard/core/widgets/status_pill.dart';
import 'package:damas_dashboard/features/analytics/domain/entities/metric.dart';
import 'package:damas_dashboard/features/analytics/presentation/widgets/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('MetricCard', () {
    testWidgets('renders the localized label and the exact figure',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.netRevenue,
            value: 84200,
            previousValue: 73730,
          ),
        ),
      );

      expect(find.text('Net revenue'), findsOneWidget);
      expect(find.text(r'$84,200'), findsOneWidget);
    });

    testWidgets('switches to compact notation above the readability threshold',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.netRevenue,
            value: 142400,
            previousValue: 131365,
          ),
        ),
      );

      // Six figures and up would widen the tile past its neighbours.
      expect(find.textContaining('142'), findsOneWidget);
      expect(find.text(r'$142,400'), findsNothing);
    });

    testWidgets('translates the label when the locale is Arabic',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.activeUsers,
            value: 12400,
            previousValue: 11450,
          ),
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('المستخدمون النشطون'), findsOneWidget);
    });

    testWidgets('shows an upward arrow with a positive tone for rising revenue',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.netRevenue,
            value: 110,
            previousValue: 100,
          ),
        ),
      );

      final StatusPill pill =
          tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.tone, StatusTone.positive);
      expect(pill.icon, Icons.arrow_upward_rounded);
    });

    testWidgets('falling churn reads as good news despite pointing down',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.churnRate,
            value: 2.4,
            previousValue: 3.2,
          ),
        ),
      );

      final StatusPill pill =
          tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.icon, Icons.arrow_downward_rounded);
      expect(pill.tone, StatusTone.positive);
    });

    testWidgets('rising churn reads as bad news', (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.churnRate,
            value: 4,
            previousValue: 3.2,
          ),
        ),
      );

      final StatusPill pill =
          tester.widget<StatusPill>(find.byType(StatusPill));
      expect(pill.tone, StatusTone.negative);
    });

    testWidgets('omits the trend pill when there is no baseline to compare',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.subscriptions,
            value: 50,
            previousValue: 0,
          ),
        ),
      );

      expect(find.byType(StatusPill), findsNothing);
    });

    testWidgets('announces label, value and direction as one semantic node',
        (WidgetTester tester) async {
      // Must be released inside the test body: the framework asserts no handle
      // is still active before tearDowns run.
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.netRevenue,
            value: 110,
            previousValue: 100,
          ),
        ),
      );

      // One node carrying label and value together, rather than three loose
      // strings a screen reader would read without any relationship between
      // the metric, its figure and its direction of travel.
      expect(
        tester.getSemantics(find.byType(MetricCard)),
        containsSemantics(
          label: r'Net revenue: $110',
          value: 'Up +10.0% versus the previous period',
        ),
      );

      handle.dispose();
    });

    testWidgets('fits a large value on a narrow card without overflowing',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 150,
          child: MetricCard(
            metric: Metric(
              id: MetricId.netRevenue,
              value: 987654321,
              previousValue: 900000000,
            ),
          ),
        ),
        surfaceSize: const Size(320, 640),
      );

      // A RenderFlex overflow is surfaced through takeException, so a null here
      // means the card absorbed the long figure instead of painting past its
      // own bounds.
      expect(tester.takeException(), isNull);
    });

    testWidgets('reads from the theme in dark mode',
        (WidgetTester tester) async {
      await tester.pumpApp(
        const MetricCard(
          metric: Metric(
            id: MetricId.netRevenue,
            value: 110,
            previousValue: 100,
          ),
        ),
        themeMode: ThemeMode.dark,
      );

      final BuildContext context = tester.element(find.byType(MetricCard));
      expect(
        Theme.of(context).extension<AppSemanticColors>(),
        AppSemanticColors.dark,
      );
    });
  });
}
