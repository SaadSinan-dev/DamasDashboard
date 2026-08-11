import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failure_presenter.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/result/result.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_card.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/filter_reports.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../widgets/report_presentation.dart';
import '../widgets/report_tile.dart';
import '../widgets/reports_toolbar.dart';
import '../widgets/scheduled_report_list.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsCubit>(
      create: (_) => ReportsCubit(
        repository: sl<ReportsRepository>(),
        filterReports: sl<FilterReports>(),
      )..load(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fires on first build and again whenever Localizations change, which is
    // exactly when the cubit's search index needs the new translations.
    final AppL10n l10n = AppL10n.of(context);
    context.read<ReportsCubit>().setLabels(<ReportKind, String>{
      for (final ReportKind kind in ReportKind.values) kind: kind.label(l10n),
    });
  }

  Future<void> _confirmAndDelete(Report report) async {
    final AppL10n l10n = context.l10n;
    final String name = report.kind.label(l10n);

    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.reportDeleteTitle),
            content: Text(l10n.reportDeleteBody(name)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    // Captured before the await: `context` must not be touched afterwards.
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Result<void> result =
        await context.read<ReportsCubit>().deleteReport(report.id);
    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.fold(
            onSuccess: (_) => l10n.reportDeleted(name),
            onFailure: (failure) => failure.localize(l10n).title,
          ),
        ),
      ),
    );
  }

  void _notifyUnavailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsNotAvailable(feature))),
    );
  }

  void _download(Report report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.reportDownloadStarted(report.kind.label(context.l10n)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (BuildContext context, ReportsState state) {
        return switch (state) {
          ReportsInitial() || ReportsLoading() => const Center(
              child: AppLoadingView(),
            ),
          ReportsError(:final failure) => AppErrorView(
              failure: failure,
              onRetry: () => context.read<ReportsCubit>().load(),
            ),
          ReportsReady() => _content(context, state),
        };
      },
    );
  }

  Widget _content(BuildContext context, ReportsReady state) {
    final ReportsCubit cubit = context.read<ReportsCubit>();

    return PageBody(
      onRefresh: cubit.refresh,
      children: <Widget>[
        PageHeader(
          title: context.l10n.reportsTitle,
          subtitle: context.l10n.reportsSubtitle,
          actions: <Widget>[
            FilledButton.icon(
              onPressed: () => _notifyUnavailable(context.l10n.reportsGenerate),
              icon: const Icon(Icons.add_chart_rounded),
              label: Text(context.l10n.reportsGenerate),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  _notifyUnavailable(context.l10n.reportsExportCsv),
              icon: const Icon(Icons.download_rounded),
              label: Text(context.l10n.reportsExportCsv),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionCard(
          title: context.l10n.reportsRecentTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ReportsToolbar(
                query: state.query,
                onSearchChanged: cubit.search,
                onFilterChanged: cubit.filterBy,
                onSortChanged: cubit.sortBy,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReportsList(
                  state: state,
                  onDelete: _confirmAndDelete,
                  onDownload: _download),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionCard(
          title: context.l10n.reportsScheduledTitle,
          child: ScheduledReportList(schedules: state.scheduled),
        ),
      ],
    );
  }
}

class _ReportsList extends StatelessWidget {
  const _ReportsList({
    required this.state,
    required this.onDelete,
    required this.onDownload,
  });

  final ReportsReady state;
  final ValueChanged<Report> onDelete;
  final ValueChanged<Report> onDownload;

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) {
      return AppEmptyView(
        icon: Icons.folder_open_outlined,
        title: context.l10n.emptyReportsTitle,
        message: context.l10n.emptyReportsBody,
      );
    }

    if (state.hasNoMatches) {
      return AppEmptyView(
        icon: Icons.search_off_rounded,
        title: context.l10n.emptySearchTitle,
        message: context.l10n.emptySearchBody(state.query.searchTerm),
      );
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < state.visibleReports.length; i++) ...<Widget>[
          if (i > 0) const Divider(height: AppSpacing.lg),
          ReportTile(
            // Keyed by id so reordering after a sort moves the element rather
            // than rebuilding every tile in place.
            key: ValueKey<String>(state.visibleReports[i].id),
            report: state.visibleReports[i],
            onDownload: () => onDownload(state.visibleReports[i]),
            onDelete: () => onDelete(state.visibleReports[i]),
          ),
        ],
      ],
    );
  }
}
