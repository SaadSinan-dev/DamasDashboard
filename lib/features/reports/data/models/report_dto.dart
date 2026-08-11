import '../../../../core/data/json_parsing.dart';
import '../../domain/entities/report.dart';

/// Wire representation of a generated report.
class ReportDto {
  const ReportDto({
    required this.id,
    required this.kind,
    required this.format,
    required this.status,
    required this.generatedMinutesAgo,
    this.sizeBytes,
  });

  factory ReportDto.fromJson(Map<String, dynamic> json) => ReportDto(
        id: json.requireString('id'),
        kind: json.requireString('kind'),
        format: json.requireString('format'),
        status: json.requireString('status'),
        generatedMinutesAgo: json.requireInt('generatedMinutesAgo'),
        sizeBytes: json.optionalInt('sizeBytes'),
      );

  final String id;
  final String kind;
  final String format;
  final String status;
  final int generatedMinutesAgo;
  final int? sizeBytes;

  Report toEntity(DateTime now) => Report(
        id: id,
        kind: enumByName(ReportKind.values, kind, field: 'report.kind'),
        format: enumByName(ReportFormat.values, format, field: 'report.format'),
        status: enumByName(ReportStatus.values, status, field: 'report.status'),
        generatedAt: now.subtract(Duration(minutes: generatedMinutesAgo)),
        sizeBytes: sizeBytes,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'format': format,
        'status': status,
        'generatedMinutesAgo': generatedMinutesAgo,
        'sizeBytes': sizeBytes,
      };
}

/// Wire representation of a recurring report configuration.
class ScheduledReportDto {
  const ScheduledReportDto({
    required this.id,
    required this.kind,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.recipient,
  });

  factory ScheduledReportDto.fromJson(Map<String, dynamic> json) =>
      ScheduledReportDto(
        id: json.requireString('id'),
        kind: json.requireString('kind'),
        weekday: json.requireInt('weekday'),
        hour: json.requireInt('hour'),
        minute: json.requireInt('minute'),
        recipient: json.requireString('recipient'),
      );

  final String id;
  final String kind;
  final int weekday;
  final int hour;
  final int minute;
  final String recipient;

  ScheduledReport toEntity() => ScheduledReport(
        id: id,
        kind: enumByName(ReportKind.values, kind, field: 'scheduled.kind'),
        weekday: weekday,
        hour: hour,
        minute: minute,
        recipient: recipient,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'weekday': weekday,
        'hour': hour,
        'minute': minute,
        'recipient': recipient,
      };
}
