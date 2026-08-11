import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_data_source.dart';
import '../models/report_dto.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl({
    required ReportsLocalDataSource dataSource,
    required Clock clock,
  })  : _dataSource = dataSource,
        _clock = clock;

  final ReportsLocalDataSource _dataSource;
  final Clock _clock;

  @override
  Future<Result<List<Report>>> getReports() {
    return guardAsync(
      operation: 'getReports',
      () async {
        final DateTime now = _clock.now();
        return (await _dataSource.fetchReports())
            .map((ReportDto dto) => dto.toEntity(now))
            .toList(growable: false);
      },
    );
  }

  @override
  Future<Result<List<ScheduledReport>>> getScheduledReports() {
    return guardAsync(
      operation: 'getScheduledReports',
      () async => (await _dataSource.fetchScheduledReports())
          .map((ScheduledReportDto dto) => dto.toEntity())
          .toList(growable: false),
    );
  }

  @override
  Future<Result<void>> deleteReport(String id) {
    return guardAsync(
      operation: 'deleteReport($id)',
      () => _dataSource.deleteReport(id),
    );
  }
}
