import '../../../../core/data/json_parsing.dart';
import '../../domain/entities/activity_event.dart';

/// Wire representation of an activity feed entry.
class ActivityEventDto {
  const ActivityEventDto({
    required this.id,
    required this.type,
    required this.actor,
    required this.minutesAgo,
    this.amount,
  });

  factory ActivityEventDto.fromJson(Map<String, dynamic> json) =>
      ActivityEventDto(
        id: json.requireString('id'),
        type: json.requireString('type'),
        actor: json.requireString('actor'),
        minutesAgo: json.requireInt('minutesAgo'),
        amount: json.optionalDouble('amount'),
      );

  final String id;
  final String type;
  final String actor;
  final int minutesAgo;
  final double? amount;

  ActivityEvent toEntity(DateTime now) => ActivityEvent(
        id: id,
        type: enumByName(ActivityType.values, type, field: 'activity.type'),
        actor: actor,
        occurredAt: now.subtract(Duration(minutes: minutesAgo)),
        amount: amount,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'actor': actor,
        'minutesAgo': minutesAgo,
        'amount': amount,
      };
}
