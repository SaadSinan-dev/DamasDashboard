import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/value_formatter.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/report.dart';
import 'report_presentation.dart';

/// One row in the reports list.
class ReportTile extends StatelessWidget {
  const ReportTile({
    super.key,
    required this.report,
    required this.onDownload,
    required this.onDelete,
  });

  final Report report;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ValueFormatter formatter = ValueFormatter.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String title = report.kind.label(context.l10n);

    final String meta = <String>[
      DateFormat.yMMMd(locale).format(report.generatedAt),
      if (report.sizeBytes != null)
        formatter.fileSize(report.sizeBytes!)
      else
        context.l10n.reportSizePending,
      report.format.label,
    ].join(context.l10n.reportMetaSeparator);

    return Semantics(
      container: true,
      label: '$title. ${report.status.label(context.l10n)}. $meta',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  report.format.icon,
                  size: 22,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (report.status != ReportStatus.ready)
              ExcludeSemantics(
                child: StatusPill(
                  label: report.status.label(context.l10n),
                  tone: report.status.tone,
                  icon: report.status.icon,
                ),
              ),
            _ReportActions(
              report: report,
              onDownload: onDownload,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Actions collapse into one overflow menu rather than sitting as two icons,
/// which keeps both targets at a full 48dp even on a 320dp-wide screen.
class _ReportActions extends StatelessWidget {
  const _ReportActions({
    required this.report,
    required this.onDownload,
    required this.onDelete,
  });

  final Report report;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ReportAction>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      onSelected: (_ReportAction action) => switch (action) {
        _ReportAction.download => onDownload(),
        _ReportAction.delete => onDelete(),
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_ReportAction>>[
        PopupMenuItem<_ReportAction>(
          value: _ReportAction.download,
          enabled: report.isDownloadable,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.download_rounded),
            title: Text(context.l10n.actionDownload),
          ),
        ),
        PopupMenuItem<_ReportAction>(
          value: _ReportAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            iconColor: context.colors.error,
            textColor: context.colors.error,
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(context.l10n.actionDelete),
          ),
        ),
      ],
    );
  }
}

enum _ReportAction { download, delete }
