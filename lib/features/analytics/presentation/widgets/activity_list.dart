import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/relative_time.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/value_formatter.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/activity_event.dart';
import 'metric_presentation.dart';

/// The recent-activity feed.
///
/// The list is short and bounded by `activityLimit`, and it already sits inside
/// a scroll view, so a plain [Column] is both correct and cheaper than a nested
/// shrink-wrapped [ListView] — which would lay out every child twice.
class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.events, required this.now});

  final List<ActivityEvent> events;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return AppEmptyView(
        icon: Icons.inbox_outlined,
        title: context.l10n.emptyActivityTitle,
        message: context.l10n.emptyActivityBody,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < events.length; i++) ...<Widget>[
          if (i > 0) const Divider(height: AppSpacing.xl),
          _ActivityTile(event: events[i], now: now),
        ],
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event, required this.now});

  final ActivityEvent event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ValueFormatter formatter = ValueFormatter.of(context);
    final String title = event.type.title(context.l10n);
    final String description = event.description(context.l10n, formatter);
    final String timestamp =
        formatRelativeTime(context.l10n, event.occurredAt, now: now);

    return Semantics(
      container: true,
      label: '$title. $description. $timestamp',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.type.icon,
                size: 18,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(title, style: context.textStyles.titleSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              timestamp,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
