import 'package:equatable/equatable.dart';

/// The report templates the product can produce.
///
/// An enum rather than a free-text title because these are system-defined
/// templates, which means they can be translated, filtered and icon-mapped.
enum ReportKind {
  financialSummary,
  userEngagement,
  serverAudit,
  revenueSync,
  churnBreakdown,
}

enum ReportFormat { pdf, csv, xlsx }

enum ReportStatus { ready, generating, failed }

/// A generated report file.
class Report extends Equatable {
  const Report({
    required this.id,
    required this.kind,
    required this.format,
    required this.status,
    required this.generatedAt,
    this.sizeBytes,
  });

  final String id;
  final ReportKind kind;
  final ReportFormat format;
  final ReportStatus status;
  final DateTime generatedAt;

  /// Unknown until generation finishes, so nullable rather than a misleading 0.
  final int? sizeBytes;

  /// Only a finished report has a file behind it to download.
  bool get isDownloadable => status == ReportStatus.ready && sizeBytes != null;

  @override
  List<Object?> get props =>
      <Object?>[id, kind, format, status, generatedAt, sizeBytes];
}

/// A recurring report configuration.
class ScheduledReport extends Equatable {
  const ScheduledReport({
    required this.id,
    required this.kind,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.recipient,
  });

  final String id;
  final ReportKind kind;

  /// `DateTime.monday`–`DateTime.sunday` (1–7).
  final int weekday;
  final int hour;
  final int minute;
  final String recipient;

  @override
  List<Object?> get props =>
      <Object?>[id, kind, weekday, hour, minute, recipient];
}
