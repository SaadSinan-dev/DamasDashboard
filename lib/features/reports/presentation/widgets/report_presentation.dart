import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_query.dart';

extension ReportKindPresentation on ReportKind {
  String label(AppL10n l10n) => switch (this) {
        ReportKind.financialSummary => l10n.reportKindFinancialSummary,
        ReportKind.userEngagement => l10n.reportKindUserEngagement,
        ReportKind.serverAudit => l10n.reportKindServerAudit,
        ReportKind.revenueSync => l10n.reportKindRevenueSync,
        ReportKind.churnBreakdown => l10n.reportKindChurnBreakdown,
      };
}

extension ReportFormatPresentation on ReportFormat {
  /// File extensions are proper nouns, so they stay Latin in every locale.
  String get label => name.toUpperCase();

  IconData get icon => switch (this) {
        ReportFormat.pdf => Icons.picture_as_pdf_outlined,
        ReportFormat.csv => Icons.table_chart_outlined,
        ReportFormat.xlsx => Icons.grid_on_outlined,
      };
}

extension ReportStatusPresentation on ReportStatus {
  String label(AppL10n l10n) => switch (this) {
        ReportStatus.ready => l10n.reportStatusReady,
        ReportStatus.generating => l10n.reportStatusGenerating,
        ReportStatus.failed => l10n.reportStatusFailed,
      };

  StatusTone get tone => switch (this) {
        ReportStatus.ready => StatusTone.positive,
        ReportStatus.generating => StatusTone.warning,
        ReportStatus.failed => StatusTone.negative,
      };

  IconData get icon => switch (this) {
        ReportStatus.ready => Icons.check_circle_outline_rounded,
        ReportStatus.generating => Icons.hourglass_empty_rounded,
        ReportStatus.failed => Icons.error_outline_rounded,
      };
}

extension ReportStatusFilterPresentation on ReportStatusFilter {
  String label(AppL10n l10n) => switch (this) {
        ReportStatusFilter.all => l10n.reportFilterAll,
        ReportStatusFilter.ready => l10n.reportFilterReady,
        ReportStatusFilter.generating => l10n.reportFilterGenerating,
        ReportStatusFilter.failed => l10n.reportFilterFailed,
      };
}

extension ReportSortPresentation on ReportSort {
  String label(AppL10n l10n) => switch (this) {
        ReportSort.newest => l10n.reportSortNewest,
        ReportSort.oldest => l10n.reportSortOldest,
        ReportSort.name => l10n.reportSortName,
        ReportSort.largest => l10n.reportSortLargest,
      };
}

extension ScheduledReportPresentation on ScheduledReport {
  /// "Every Monday at 08:00", with the weekday and time rendered by `intl` so
  /// both follow the locale's own names and clock convention.
  String scheduleLabel(AppL10n l10n, String locale) {
    // 1 Jan 2024 was a Monday, so adding (weekday - 1) days lands on the target
    // weekday without needing a lookup table.
    final DateTime referenceDay = DateTime(2024, 1, weekday);
    return l10n.scheduleWeekly(
      DateFormat.EEEE(locale).format(referenceDay),
      DateFormat.jm(locale).format(DateTime(2024, 1, 1, hour, minute)),
    );
  }
}
