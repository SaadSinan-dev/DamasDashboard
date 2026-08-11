import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/shell/app_shell.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/analytics/presentation/pages/dashboard_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';
import 'route_error_page.dart';

/// Builds the application router.
///
/// The four main destinations sit inside a [StatefulShellRoute.indexedStack]:
/// each branch keeps its own navigator and its own state, so switching tabs
/// preserves scroll position and in-flight cubits — the behaviour the old
/// `IndexedStack` provided — while still giving every screen a real URL that
/// works as a deep link and in browser history.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    errorBuilder: (BuildContext context, GoRouterState state) =>
        RouteErrorPage(location: state.uri.toString()),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.routeName,
        builder: (_, __) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          _branch(AppRoute.dashboard, const DashboardPage()),
          _branch(AppRoute.analytics, const AnalyticsPage()),
          _branch(AppRoute.reports, const ReportsPage()),
          _branch(AppRoute.settings, const SettingsPage()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(AppRoute route, Widget page) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: route.path,
        name: route.routeName,
        // No transition between tabs: an indexed stack swap that also animates
        // reads as a glitch rather than as navigation.
        pageBuilder: (_, GoRouterState state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: page,
        ),
      ),
    ],
  );
}
