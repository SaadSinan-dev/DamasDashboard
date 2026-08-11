import '../../../../core/data/json_asset_reader.dart';
import '../../../../core/data/json_parsing.dart';
import '../../../../core/error/exceptions.dart';
import '../models/activity_event_dto.dart';
import '../models/metric_dto.dart';
import '../models/revenue_point_dto.dart';

/// Reads analytics payloads from the bundled JSON asset.
///
/// The interface is what the repository depends on; swapping to a REST backend
/// means adding an `AnalyticsRemoteDataSource` with the same shape and changing
/// one line of dependency registration.
abstract interface class AnalyticsLocalDataSource {
  Future<List<MetricDto>> fetchMetrics(String scope);

  Future<List<RevenuePointDto>> fetchRevenueSeries();

  Future<List<ActivityEventDto>> fetchActivity();
}

class AnalyticsAssetDataSource implements AnalyticsLocalDataSource {
  AnalyticsAssetDataSource(this._reader);

  static const String assetPath = 'assets/data/analytics.json';

  final JsonAssetReader _reader;

  // The decoded payload is memoised: the three fetches are issued concurrently
  // by GetAnalyticsSnapshot, and without this the same asset would be read and
  // parsed three times per refresh.
  Future<Map<String, dynamic>>? _payload;

  // Memoised rather than re-read: the bundled payload cannot change at runtime,
  // so a refresh re-runs the mapping pipeline without paying for the asset load
  // again. A remote data source would put its cache policy here instead.
  Future<Map<String, dynamic>> _read() =>
      _payload ??= _reader.readObject(assetPath);

  @override
  Future<List<MetricDto>> fetchMetrics(String scope) async {
    final Map<String, dynamic> json = await _read();
    final Map<String, dynamic> byScope = json.requireObject('metrics');
    if (!byScope.containsKey(scope)) {
      throw NotFoundException('No metrics for scope "$scope"',
          resourceId: scope);
    }
    return byScope
        .requireObjectList(scope)
        .map(MetricDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<RevenuePointDto>> fetchRevenueSeries() async {
    final Map<String, dynamic> json = await _read();
    return json
        .requireObjectList('revenueSeries')
        .map(RevenuePointDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<ActivityEventDto>> fetchActivity() async {
    final Map<String, dynamic> json = await _read();
    return json
        .requireObjectList('activity')
        .map(ActivityEventDto.fromJson)
        .toList(growable: false);
  }
}
