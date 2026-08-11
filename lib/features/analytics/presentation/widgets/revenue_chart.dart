import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// `intl` exports a bidi TextDirection that shadows the framework's.
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/utils/value_formatter.dart';
import '../../domain/entities/revenue_point.dart';

/// Revenue time series.
///
/// The previous version drew six unlabelled points with axes switched off, which
/// made it decorative rather than informative. This one labels both axes, shows
/// a tooltip on touch, and carries a semantic description for screen readers,
/// which cannot read a canvas.
class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key, required this.points});

  final List<RevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final ValueFormatter formatter = ValueFormatter.of(context);
    final AppSemanticColors semantic = context.semanticColors;
    final double height = context.isCompact ? 220 : 280;

    return Semantics(
      label: context.l10n.a11yRevenueChart(points.length),
      // The canvas has no meaningful sub-nodes to explore, so it is announced as
      // one described image rather than as an empty container.
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          // Charts read left-to-right regardless of UI direction: mirroring the
          // time axis under an RTL locale would put the most recent month on the
          // left and invert the meaning of a rising line.
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: LineChart(
              _chartData(context, formatter, semantic),
              duration: AppDurations.medium,
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _chartData(
    BuildContext context,
    ValueFormatter formatter,
    AppSemanticColors semantic,
  ) {
    final double maxAmount = points
        .map((RevenuePoint p) => p.amount)
        .reduce((double a, double b) => a > b ? a : b);
    final double minAmount = points
        .map((RevenuePoint p) => p.amount)
        .reduce((double a, double b) => a < b ? a : b);

    // Headroom above and below keeps the line off the frame edges.
    final double span = (maxAmount - minAmount).abs();
    final double padding = span == 0 ? maxAmount * 0.1 : span * 0.25;
    final double minY = (minAmount - padding).clamp(0, double.infinity);
    final double maxY = maxAmount + padding;
    final double interval = ((maxY - minY) / 4).ceilToDouble();

    // A label under every month collides on a phone, so show every other one.
    final int labelStride = context.isCompact ? 3 : 2;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      minX: 0,
      maxX: (points.length - 1).toDouble(),
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: interval <= 0 ? null : interval,
        getDrawingHorizontalLine: (double value) => FlLine(
          color: semantic.chartGrid,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval: interval <= 0 ? null : interval,
            getTitlesWidget: (double value, TitleMeta meta) {
              if (value == meta.max) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  formatter.compactCurrency(value),
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final int index = value.round();
              if (index < 0 || index >= points.length) {
                return const SizedBox.shrink();
              }
              if (index % labelStride != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  DateFormat.MMM(
                          Localizations.localeOf(context).toLanguageTag())
                      .format(points[index].month),
                  style: context.textStyles.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: context.colors.inverseSurface,
          tooltipRoundedRadius: AppRadii.sm,
          getTooltipItems: (List<LineBarSpot> spots) =>
              spots.map((LineBarSpot spot) {
            final RevenuePoint point = points[spot.x.round()];
            return LineTooltipItem(
              '${DateFormat.yMMM(Localizations.localeOf(context).toLanguageTag()).format(point.month)}\n'
              '${formatter.currency(point.amount)}',
              context.textStyles.labelMedium!.copyWith(
                color: context.colors.onInverseSurface,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: <LineChartBarData>[
        LineChartBarData(
          spots: <FlSpot>[
            for (int i = 0; i < points.length; i++)
              FlSpot(i.toDouble(), points[i].amount),
          ],
          isCurved: true,
          // Above ~0.3 the spline overshoots between close points and invents
          // dips the data does not contain.
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          color: semantic.chartLine,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[semantic.chartAreaTop, semantic.chartAreaBottom],
            ),
          ),
        ),
      ],
    );
  }
}
