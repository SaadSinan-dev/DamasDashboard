import 'package:equatable/equatable.dart';

/// The kinds of event that appear in the activity feed.
///
/// Modelled as a type rather than a pre-rendered string so the feed can be
/// translated, filtered and icon-mapped without parsing English prose.
enum ActivityType { payment, signup, reportReady, systemAlert }

/// A single entry in the recent-activity feed.
class ActivityEvent extends Equatable {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.actor,
    required this.occurredAt,
    this.amount,
  });

  final String id;
  final ActivityType type;

  /// Person or system component the event is attributed to.
  final String actor;
  final DateTime occurredAt;

  /// Only meaningful for [ActivityType.payment].
  final double? amount;

  @override
  List<Object?> get props => <Object?>[id, type, actor, occurredAt, amount];
}
