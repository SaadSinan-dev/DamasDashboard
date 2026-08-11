import 'generated/app_localizations.dart';

/// Renders a timestamp as "2 minutes ago" in the active language.
///
/// Goes through the ARB plural forms rather than string concatenation, which is
/// what makes Arabic correct: it has six plural categories, so "3 minutes" and
/// "11 minutes" take different noun forms that no `'$n minutes ago'` template
/// could produce.
String formatRelativeTime(
  AppL10n l10n,
  DateTime timestamp, {
  required DateTime now,
}) {
  final Duration elapsed = now.difference(timestamp);

  if (elapsed.inMinutes < 1) return l10n.timeJustNow;
  if (elapsed.inMinutes < 60) return l10n.timeMinutesAgo(elapsed.inMinutes);
  if (elapsed.inHours < 24) return l10n.timeHoursAgo(elapsed.inHours);
  return l10n.timeDaysAgo(elapsed.inDays);
}
