import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../extensions/context_extensions.dart';
import '../widgets/app_state_views.dart';
import 'app_routes.dart';

/// Shown for any URL that matches no route.
///
/// Reachable in the wild on web, where a user can edit the address bar, and via
/// a stale deep link. Without this go_router renders its own debug-red error
/// screen in release builds.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppMessageView(
          icon: Icons.explore_off_outlined,
          title: context.l10n.errorRouteTitle,
          message: context.l10n.errorRouteBody(location),
          action: FilledButton.icon(
            onPressed: () => context.goNamed(AppRoute.dashboard.routeName),
            icon: const Icon(Icons.home_outlined),
            label: Text(context.l10n.errorGoHome),
          ),
        ),
      ),
    );
  }
}
