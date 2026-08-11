import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';
import 'activity_list.dart';
import 'metric_card.dart';
import 'revenue_chart.dart';

/// Shared body for the dashboard and analytics screens.
///
/// Both render the same three sections from the same [AnalyticsSnapshot] and
/// differ only in their heading and in which [MetricScope] their cubit requests,
/// so they compose this rather than duplicating the layout.
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (BuildContext context, AnalyticsState state) {
        return switch (state) {
          AnalyticsInitial() || AnalyticsLoading() => const Center(
              child: AppLoadingView(),
            ),
          AnalyticsError(:final failure) => AppErrorView(
              failure: failure,
              onRetry: () => context.read<AnalyticsCubit>().load(),
            ),
          // A successful response that contains nothing is neither an error nor
          // a loading state, so it gets its own copy rather than rendering a
          // page of empty cards.
          AnalyticsReady(isEmpty: true) => AppEmptyView(
              icon: Icons.query_stats_outlined,
              title: context.l10n.emptyActivityTitle,
              message: context.l10n.emptyActivityBody,
            ),
          AnalyticsReady(:final AnalyticsSnapshot snapshot) => _Content(
              title: title,
              subtitle: subtitle,
              snapshot: snapshot,
            ),
        };
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    required this.subtitle,
    required this.snapshot,
  });

  final String title;
  final String subtitle;
  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final DateTime now = context.read<Clock>().now();

    return PageBody(
      onRefresh: context.read<AnalyticsCubit>().refresh,
      children: <Widget>[
        PageHeader(title: title, subtitle: subtitle),
        const SizedBox(height: AppSpacing.xl),
        ResponsiveCardGrid(
          children: <Widget>[
            for (final metric in snapshot.metrics) MetricCard(metric: metric),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionCard(
          title: context.l10n.revenueChartTitle,
          subtitle: context.l10n.revenueChartSubtitle(
            snapshot.revenueSeries.length,
          ),
          child: RevenueChart(points: snapshot.revenueSeries),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionCard(
          title: context.l10n.recentActivityTitle,
          child: ActivityList(events: snapshot.recentActivity, now: now),
        ),
      ],
    );
  }
}
