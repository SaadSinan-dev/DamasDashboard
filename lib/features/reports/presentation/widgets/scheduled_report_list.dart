import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/report.dart';
import 'report_presentation.dart';

/// Recurring report configurations.
class ScheduledReportList extends StatelessWidget {
  const ScheduledReportList({super.key, required this.schedules});

  final List<ScheduledReport> schedules;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return AppEmptyView(
        icon: Icons.event_repeat_outlined,
        title: context.l10n.emptyScheduledTitle,
        message: context.l10n.emptyScheduledBody,
      );
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < schedules.length; i++) ...<Widget>[
          if (i > 0) const Divider(height: AppSpacing.lg),
          _ScheduledTile(schedule: schedules[i]),
        ],
      ],
    );
  }
}

class _ScheduledTile extends StatelessWidget {
  const _ScheduledTile({required this.schedule});

  final ScheduledReport schedule;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String title = schedule.kind.label(context.l10n);
    final String cadence = schedule.scheduleLabel(context.l10n, locale);
    final String recipient = context.l10n.scheduleRecipient(schedule.recipient);

    return Semantics(
      container: true,
      label: '$title. $cadence. $recipient',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  Icons.event_repeat_outlined,
                  size: 22,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      cadence,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      recipient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
