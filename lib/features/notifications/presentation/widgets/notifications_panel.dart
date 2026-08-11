import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/l10n/relative_time.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';

/// Opens the notification panel in whichever presentation suits the screen.
///
/// The old implementation was a fixed 350px overlay that clipped on a 320dp
/// phone and had no dismiss affordance beyond a close icon. A bottom sheet is
/// the platform-correct pattern on a phone — draggable, swipe-dismissable, and
/// focus-trapped — while a dialog reads better beside a navigation rail.
Future<void> showNotificationsPanel(BuildContext context) {
  final NotificationsCubit cubit = context.read<NotificationsCubit>();
  final Clock clock = context.read<Clock>();

  Widget panel(BuildContext _) => _PanelScope(cubit: cubit, clock: clock);

  if (context.isCompact) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      builder: panel,
    );
  }

  return showDialog<void>(
    context: context,
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.2),
    builder: (BuildContext dialogContext) => Align(
      alignment: AlignmentDirectional.topEnd,
      child: Padding(
        // Directional, so under an RTL locale the panel hugs the same edge as
        // the bell icon that opened it rather than the opposite one.
        padding: const EdgeInsetsDirectional.only(
          top: kToolbarHeight + AppSpacing.sm,
          end: AppSpacing.lg,
          start: AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                math.min(400, MediaQuery.sizeOf(dialogContext).width - 32),
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.6,
          ),
          child: Material(
            color: Theme.of(dialogContext).colorScheme.surface,
            elevation: 8,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            clipBehavior: Clip.antiAlias,
            child: panel(dialogContext),
          ),
        ),
      ),
    ),
  );
}

/// Re-provides the panel's dependencies by value.
///
/// The providers do sit above the router today, so a dialog route would inherit
/// them anyway. Passing them explicitly means the panel keeps working if it is
/// later shown from a nested navigator or a separate overlay, where that would
/// no longer hold.
class _PanelScope extends StatelessWidget {
  const _PanelScope({required this.cubit, required this.clock});

  final NotificationsCubit cubit;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Clock>.value(
      value: clock,
      child: BlocProvider<NotificationsCubit>.value(
        value: cubit,
        child: const NotificationsPanel(),
      ),
    );
  }
}

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (BuildContext context, NotificationsState state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _PanelHeader(state: state),
            const Divider(height: 1),
            Flexible(child: _PanelBody(state: state)),
          ],
        );
      },
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    final int unread = state is NotificationsReady
        ? (state as NotificationsReady).unreadCount
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    context.l10n.notificationsTitle,
                    style: context.textStyles.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.notificationsUnread(unread),
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (unread > 0)
            TextButton(
              onPressed: context.read<NotificationsCubit>().markAllAsRead,
              child: Text(context.l10n.notificationsMarkAllRead),
            ),
        ],
      ),
    );
  }
}

class _PanelBody extends StatelessWidget {
  const _PanelBody({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      NotificationsLoading() => const AppLoadingView(minHeight: 160),
      NotificationsError(:final failure) => AppErrorView(
          failure: failure,
          onRetry: context.read<NotificationsCubit>().load,
        ),
      NotificationsReady(:final List<AppNotification> notifications)
          when notifications.isEmpty =>
        AppEmptyView(
          icon: Icons.notifications_none_rounded,
          title: context.l10n.emptyNotificationsTitle,
          message: context.l10n.emptyNotificationsBody,
        ),
      NotificationsReady(:final List<AppNotification> notifications) =>
        ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
          itemBuilder: (BuildContext context, int index) =>
              _NotificationTile(notification: notifications[index]),
        ),
    };
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = context.l10n;
    final String title = switch (notification.kind) {
      NotificationKind.payment => l10n.activityPaymentTitle,
      NotificationKind.signup => l10n.activitySignupTitle,
      NotificationKind.reportReady => l10n.activityReportTitle,
      NotificationKind.systemAlert => l10n.activityAlertTitle,
    };
    final String timestamp = formatRelativeTime(
      l10n,
      notification.occurredAt,
      now: context.read<Clock>().now(),
    );

    return ListTile(
      // Unread state is carried by the dot *and* by the bold weight, so it does
      // not depend on noticing a small coloured circle.
      leading: Icon(
        switch (notification.kind) {
          NotificationKind.payment => Icons.payments_outlined,
          NotificationKind.signup => Icons.person_add_alt_1_outlined,
          NotificationKind.reportReady => Icons.description_outlined,
          NotificationKind.systemAlert => Icons.warning_amber_rounded,
        },
        color: notification.isRead
            ? context.colors.onSurfaceVariant
            : context.colors.primary,
      ),
      title: Text(
        title,
        style: context.textStyles.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Text('${notification.actor} · $timestamp'),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}
