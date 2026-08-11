import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import 'app_navigation_drawer.dart';
import 'app_top_bar.dart';
import 'navigation_destinations.dart';

/// The persistent frame around every screen.
///
/// One [Scaffold] for the whole app. Previously the shell had a Scaffold and
/// each of the four pages nested another inside it, which produced five
/// overlapping Scaffolds, doubled-up `SafeArea` insets and a `ScaffoldMessenger`
/// lookup that resolved to the wrong ancestor.
///
/// Navigation adapts to width: a drawer on phones, a permanent rail from tablet
/// width up, where a hidden drawer wastes a screen that has room to show it.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab returns it to its root, matching the platform
      // convention for bottom/rail navigation.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<AppDestination> destinations = appDestinations(context.l10n);
    final bool useRail = !context.isCompact;

    return Scaffold(
      appBar: AppTopBar(showMenuButton: !useRail),
      drawer: useRail
          ? null
          : AppNavigationDrawer(
              destinations: destinations,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
            ),
      body: useRail
          ? _RailLayout(
              destinations: destinations,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              child: navigationShell,
            )
          : navigationShell,
    );
  }
}

class _RailLayout extends StatelessWidget {
  const _RailLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Labels are always visible from desktop width, where there is room for
    // them; on tablet they appear only under the selected item.
    final bool extended = context.screenSize == ScreenSize.expanded;

    return Row(
      children: <Widget>[
        NavigationRail(
          extended: extended,
          minExtendedWidth: 200,
          labelType: extended ? null : NavigationRailLabelType.all,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: <NavigationRailDestination>[
            for (final AppDestination destination in destinations)
              NavigationRailDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: Text(destination.label),
              ),
          ],
        ),
        VerticalDivider(width: 1, color: context.colors.outlineVariant),
        Expanded(child: child),
      ],
    );
  }
}
