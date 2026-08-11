import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/usecases/get_analytics_snapshot.dart';
import '../cubit/analytics_cubit.dart';
import '../widgets/analytics_view.dart';

/// Audience and growth view — the same snapshot shape, a different metric scope
/// and a longer activity window.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsCubit>(
      create: (_) => AnalyticsCubit(
        getAnalyticsSnapshot: sl<GetAnalyticsSnapshot>(),
        scope: MetricScope.analytics,
        // A longer feed than the dashboard's: this screen is where a user goes
        // to actually read through recent events.
        activityLimit: 8,
      )..load(),
      child: AnalyticsView(
        title: context.l10n.analyticsTitle,
        subtitle: context.l10n.analyticsSubtitle,
      ),
    );
  }
}
