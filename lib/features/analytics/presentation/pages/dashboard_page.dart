import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/usecases/get_analytics_snapshot.dart';
import '../cubit/analytics_cubit.dart';
import '../widgets/analytics_view.dart';

/// Commercial overview — the app's landing screen.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsCubit>(
      create: (_) => AnalyticsCubit(
        getAnalyticsSnapshot: sl<GetAnalyticsSnapshot>(),
        scope: MetricScope.dashboard,
      )..load(),
      child: AnalyticsView(
        title: context.l10n.dashboardTitle,
        subtitle: context.l10n.dashboardSubtitle,
      ),
    );
  }
}
