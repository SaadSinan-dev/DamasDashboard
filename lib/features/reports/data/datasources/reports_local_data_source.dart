import '../../../../core/data/json_asset_reader.dart';
import '../../../../core/data/json_parsing.dart';
import '../../../../core/error/exceptions.dart';
import '../models/report_dto.dart';

abstract interface class ReportsLocalDataSource {
  Future<List<ReportDto>> fetchReports();

  Future<List<ScheduledReportDto>> fetchScheduledReports();

  /// Throws [NotFoundException] when no report has the given id.
  Future<void> deleteReport(String id);
}

/// Reads the seed payload once, then serves an in-memory copy that mutations
/// apply to.
///
/// Deletion is genuinely applied to that copy rather than faked in the UI, so
/// the delete flow exercises the same repository → data source path a networked
/// implementation would. The trade-off is that changes do not survive a restart;
/// persisting them belongs to whichever backend replaces this class.
class ReportsAssetDataSource implements ReportsLocalDataSource {
  ReportsAssetDataSource(this._reader);

  static const String assetPath = 'assets/data/reports.json';

  final JsonAssetReader _reader;

  List<ReportDto>? _reports;
  List<ScheduledReportDto>? _scheduled;

  /// Held so concurrent callers await the same load instead of each starting
  /// their own read of the same asset.
  Future<void>? _loading;

  Future<void> _ensureLoaded() {
    if (_reports != null && _scheduled != null) return Future<void>.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final Map<String, dynamic> json = await _reader.readObject(assetPath);
      _reports =
          json.requireObjectList('reports').map(ReportDto.fromJson).toList();
      _scheduled = json
          .requireObjectList('scheduled')
          .map(ScheduledReportDto.fromJson)
          .toList();
    } finally {
      // Cleared either way so a failed load can be retried rather than
      // permanently returning the same rejected future.
      _loading = null;
    }
  }

  @override
  Future<List<ReportDto>> fetchReports() async {
    await _ensureLoaded();
    return List<ReportDto>.unmodifiable(_reports!);
  }

  @override
  Future<List<ScheduledReportDto>> fetchScheduledReports() async {
    await _ensureLoaded();
    return List<ScheduledReportDto>.unmodifiable(_scheduled!);
  }

  @override
  Future<void> deleteReport(String id) async {
    await _ensureLoaded();
    final int before = _reports!.length;
    _reports!.removeWhere((ReportDto dto) => dto.id == id);
    if (_reports!.length == before) {
      throw NotFoundException('No report with id $id', resourceId: id);
    }
  }
}
