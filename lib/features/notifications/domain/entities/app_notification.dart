import 'package:equatable/equatable.dart';

/// Categories of notification the system raises.
///
/// Notifications and the activity feed deliberately keep separate enums even
/// though they overlap today: they are different bounded contexts, and coupling
/// them would mean a new activity type silently becomes a notification type.
enum NotificationKind { payment, signup, reportReady, systemAlert }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.actor,
    required this.occurredAt,
    required this.isRead,
  });

  final String id;
  final NotificationKind kind;
  final String actor;
  final DateTime occurredAt;
  final bool isRead;

  AppNotification markRead() => AppNotification(
        id: id,
        kind: kind,
        actor: actor,
        occurredAt: occurredAt,
        isRead: true,
      );

  @override
  List<Object?> get props => <Object?>[id, kind, actor, occurredAt, isRead];
}
