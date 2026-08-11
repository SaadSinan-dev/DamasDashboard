import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_dimens.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/widgets/notifications_panel.dart';

/// Application bar.
///
/// The previous version wrapped an [AppBar] in a `BackdropFilter` for a "glass"
/// effect, but the bar was opaque and the body did not extend behind it, so the
/// blur cost a full-screen filter pass every frame and rendered nothing. Styling
/// now comes from `appBarTheme`.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.showMenuButton = true});

  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showMenuButton
          ? Builder(
              builder: (BuildContext context) => IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu_rounded),
                // Both a tooltip and a semantic label: the tooltip serves
                // pointer and keyboard users, the label serves screen readers.
                tooltip: context.l10n.a11yOpenNavigation,
              ),
            )
          : null,
      titleSpacing: showMenuButton ? 0 : AppSpacing.xl,
      title: Text(context.l10n.appTitle),
      actions: const <Widget>[
        _NotificationsButton(),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      // Only the unread count affects this button, so it does not rebuild when
      // the list contents change in any other way.
      buildWhen: (NotificationsState previous, NotificationsState current) =>
          _unreadOf(previous) != _unreadOf(current),
      builder: (BuildContext context, NotificationsState state) {
        final int unread = _unreadOf(state);

        return IconButton(
          onPressed: () => showNotificationsPanel(context),
          tooltip: context.l10n.a11yOpenNotifications,
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }

  static int _unreadOf(NotificationsState state) =>
      state is NotificationsReady ? state.unreadCount : 0;
}
