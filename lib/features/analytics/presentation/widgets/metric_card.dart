import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/value_formatter.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/metric.dart';
import 'metric_presentation.dart';

/// The single KPI card used by every screen.
///
/// Replaces two divergent `StatCard` implementations that had drifted into
/// different APIs and different visual treatments.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.metric});

  final Metric metric;

  @override
  Widget build(BuildContext context) {
    final ValueFormatter formatter = ValueFormatter.of(context);
    final String label = metric.id.label(context.l10n);
    final String value = metric.formattedValue(formatter);
    final String? change = metric.formattedChange(formatter);

    // The whole card reads as one node: a screen reader announces the label, the
    // value and the direction of travel together instead of three loose strings.
    return Semantics(
      container: true,
      label: '$label: $value',
      value: change == null
          ? null
          : metric.trend == MetricTrend.up
              ? context.l10n.a11yTrendUp(change)
              : context.l10n.a11yTrendDown(change),
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        metric.id.icon,
                        size: 18,
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Takes the remaining width and aligns the pill to the end,
                    // which lets the pill shrink on a narrow card rather than
                    // being pushed past the edge by a fixed Spacer.
                    if (change != null)
                      Flexible(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _TrendPill(metric: metric, change: change),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // FittedBox keeps an unexpectedly long figure inside the tile
                // instead of overflowing it on a 320dp screen.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: context.textStyles.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  const _TrendPill({required this.metric, required this.change});

  final Metric metric;
  final String change;

  @override
  Widget build(BuildContext context) {
    // Colour follows whether the movement is *good*, not whether it is up.
    // Churn falling is a green result even though the arrow points down.
    return StatusPill(
      label: change,
      tone: switch (metric.trend) {
        MetricTrend.flat => StatusTone.neutral,
        _ => metric.isFavourable ? StatusTone.positive : StatusTone.negative,
      },
      icon: switch (metric.trend) {
        MetricTrend.up => Icons.arrow_upward_rounded,
        MetricTrend.down => Icons.arrow_downward_rounded,
        MetricTrend.flat => Icons.remove_rounded,
      },
    );
  }
}
