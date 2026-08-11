import '../../../../core/result/guard.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_data_source.dart';
import '../models/app_notification_dto.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required NotificationsLocalDataSource dataSource,
    required Clock clock,
  })  : _dataSource = dataSource,
        _clock = clock;

  final NotificationsLocalDataSource _dataSource;
  final Clock _clock;

  @override
  Future<Result<List<AppNotification>>> getNotifications() {
    return guardAsync(
      operation: 'getNotifications',
      () async {
        final DateTime now = _clock.now();
        final List<AppNotification> notifications = (await _dataSource
                .fetchNotifications())
            .map((AppNotificationDto dto) => dto.toEntity(now))
            .toList()
          ..sort(
            (AppNotification a, AppNotification b) =>
                b.occurredAt.compareTo(a.occurredAt),
          );
        return List<AppNotification>.unmodifiable(notifications);
      },
    );
  }

  @override
  Future<Result<void>> markAllAsRead() => guardAsync(
        operation: 'markAllNotificationsAsRead',
        _dataSource.markAllAsRead,
      );
}
