import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/router/app_routes.dart';

/// A top-level destination in the app shell.
@immutable
class AppDestination {
  const AppDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final AppRoute route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The four shell destinations, in branch order.
///
/// Order is the contract with `StatefulShellRoute`: index *n* here must be
/// branch *n* there, so both the drawer and the rail are built from this one
/// list rather than each hard-coding its own copy.
List<AppDestination> appDestinations(AppL10n l10n) => <AppDestination>[
      AppDestination(
        route: AppRoute.dashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.navDashboard,
      ),
      AppDestination(
        route: AppRoute.analytics,
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights_rounded,
        label: l10n.navAnalytics,
      ),
      AppDestination(
        route: AppRoute.reports,
        icon: Icons.description_outlined,
        selectedIcon: Icons.description_rounded,
        label: l10n.navReports,
      ),
      AppDestination(
        route: AppRoute.settings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: l10n.navSettings,
      ),
    ];
