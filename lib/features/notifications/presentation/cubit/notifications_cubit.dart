import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => <Object?>[];
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsError extends NotificationsState {
  const NotificationsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

final class NotificationsReady extends NotificationsState {
  const NotificationsReady(this.notifications);

  final List<AppNotification> notifications;

  int get unreadCount =>
      notifications.where((AppNotification n) => !n.isRead).length;

  bool get isEmpty => notifications.isEmpty;

  @override
  List<Object?> get props => <Object?>[notifications];
}

/// Owns the notification list and the unread badge.
///
/// Lives above the app shell rather than inside the panel, because the app bar
/// badge needs the unread count whether or not the panel has ever been opened.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsLoading());

  final NotificationsRepository _repository;

  Future<void> load() async {
    final Result<List<AppNotification>> result =
        await _repository.getNotifications();
    if (isClosed) return;

    emit(
      switch (result) {
        Success<List<AppNotification>>(:final List<AppNotification> value) =>
          NotificationsReady(value),
        Failed<List<AppNotification>>(:final failure) =>
          NotificationsError(failure),
      },
    );
  }

  Future<void> markAllAsRead() async {
    final NotificationsState current = state;
    if (current is! NotificationsReady || current.unreadCount == 0) return;

    final Result<void> result = await _repository.markAllAsRead();
    if (isClosed || !result.isSuccess) return;

    emit(
      NotificationsReady(
        current.notifications
            .map((AppNotification n) => n.markRead())
            .toList(growable: false),
      ),
    );
  }
}
