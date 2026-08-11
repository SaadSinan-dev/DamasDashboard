import '../../../../core/data/json_asset_reader.dart';
import '../../../../core/data/json_parsing.dart';
import '../models/app_notification_dto.dart';

abstract interface class NotificationsLocalDataSource {
  Future<List<AppNotificationDto>> fetchNotifications();

  Future<void> markAllAsRead();
}

class NotificationsAssetDataSource implements NotificationsLocalDataSource {
  NotificationsAssetDataSource(this._reader);

  static const String assetPath = 'assets/data/notifications.json';

  final JsonAssetReader _reader;

  List<AppNotificationDto>? _notifications;
  Future<void>? _loading;

  Future<void> _ensureLoaded() {
    if (_notifications != null) return Future<void>.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    try {
      final Map<String, dynamic> json = await _reader.readObject(assetPath);
      _notifications = json
          .requireObjectList('notifications')
          .map(AppNotificationDto.fromJson)
          .toList();
    } finally {
      _loading = null;
    }
  }

  @override
  Future<List<AppNotificationDto>> fetchNotifications() async {
    await _ensureLoaded();
    return List<AppNotificationDto>.unmodifiable(_notifications!);
  }

  @override
  Future<void> markAllAsRead() async {
    await _ensureLoaded();
    _notifications = _notifications!
        .map((AppNotificationDto dto) => dto.copyWith(isRead: true))
        .toList();
  }
}
