import '../../../../core/result/result.dart';
import '../entities/report.dart';

abstract interface class ReportsRepository {
  Future<Result<List<Report>>> getReports();

  Future<Result<List<ScheduledReport>>> getScheduledReports();

  /// Removes a report. Fails with `NotFoundFailure` when [id] is unknown.
  Future<Result<void>> deleteReport(String id);
}
