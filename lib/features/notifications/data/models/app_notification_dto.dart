import '../../../../core/data/json_parsing.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationDto {
  const AppNotificationDto({
    required this.id,
    required this.kind,
    required this.actor,
    required this.minutesAgo,
    required this.isRead,
  });

  factory AppNotificationDto.fromJson(Map<String, dynamic> json) =>
      AppNotificationDto(
        id: json.requireString('id'),
        kind: json.requireString('kind'),
        actor: json.requireString('actor'),
        minutesAgo: json.requireInt('minutesAgo'),
        isRead: json.requireBool('isRead'),
      );

  final String id;
  final String kind;
  final String actor;
  final int minutesAgo;
  final bool isRead;

  AppNotificationDto copyWith({bool? isRead}) => AppNotificationDto(
        id: id,
        kind: kind,
        actor: actor,
        minutesAgo: minutesAgo,
        isRead: isRead ?? this.isRead,
      );

  AppNotification toEntity(DateTime now) => AppNotification(
        id: id,
        kind: enumByName(
          NotificationKind.values,
          kind,
          field: 'notification.kind',
        ),
        actor: actor,
        occurredAt: now.subtract(Duration(minutes: minutesAgo)),
        isRead: isRead,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'actor': actor,
        'minutesAgo': minutesAgo,
        'isRead': isRead,
      };
}
