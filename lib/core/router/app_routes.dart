/// Every destination in the app, in one place.
///
/// Navigation goes through `context.goNamed(AppRoute.reports.name)` rather than
/// a raw path string, so a route rename is a compile-time change instead of a
/// runtime 404 discovered in testing.
enum AppRoute {
  splash('/splash'),
  dashboard('/dashboard'),
  analytics('/analytics'),
  reports('/reports'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;

  /// The route name registered with go_router; matches the enum member.
  String get routeName => name;
}
