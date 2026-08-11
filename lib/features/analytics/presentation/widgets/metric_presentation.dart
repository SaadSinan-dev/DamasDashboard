import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/value_formatter.dart';
import '../../domain/entities/activity_event.dart';
import '../../domain/entities/metric.dart';

/// Presentation mapping for domain enums.
///
/// Icons and translated labels live here rather than on the entities, so the
/// domain layer stays free of `package:flutter` and of any one language.
extension MetricIdPresentation on MetricId {
  String label(AppL10n l10n) => switch (this) {
        MetricId.netRevenue => l10n.metricNetRevenue,
        MetricId.subscriptions => l10n.metricSubscriptions,
        MetricId.churnRate => l10n.metricChurnRate,
        MetricId.activeUsers => l10n.metricActiveUsers,
        MetricId.totalUsers => l10n.metricTotalUsers,
        MetricId.growth => l10n.metricGrowth,
      };

  IconData get icon => switch (this) {
        MetricId.netRevenue => Icons.account_balance_wallet_outlined,
        MetricId.subscriptions => Icons.card_membership_outlined,
        MetricId.churnRate => Icons.trending_down_rounded,
        MetricId.activeUsers => Icons.people_alt_outlined,
        MetricId.totalUsers => Icons.groups_outlined,
        MetricId.growth => Icons.insights_rounded,
      };
}

extension MetricPresentation on Metric {
  /// The headline figure, formatted for its unit.
  ///
  /// Large figures switch to compact notation so a card cannot be widened past
  /// its neighbours by an unusually long number.
  String formattedValue(ValueFormatter formatter) => switch (unit) {
        MetricUnit.currency => value.abs() >= 100000
            ? formatter.compactCurrency(value)
            : formatter.currency(value),
        MetricUnit.count => value.abs() >= 10000
            ? formatter.compactNumber(value)
            : formatter.number(value),
        MetricUnit.percent => formatter.percentFromPoints(value),
      };

  /// Signed period-over-period change, or `null` when there is no baseline.
  String? formattedChange(ValueFormatter formatter) {
    final double? ratio = changeRatio;
    if (ratio == null) return null;
    return formatter.signedPercentFromRatio(ratio);
  }
}

extension ActivityTypePresentation on ActivityType {
  IconData get icon => switch (this) {
        ActivityType.payment => Icons.payments_outlined,
        ActivityType.signup => Icons.person_add_alt_1_outlined,
        ActivityType.reportReady => Icons.description_outlined,
        ActivityType.systemAlert => Icons.warning_amber_rounded,
      };

  String title(AppL10n l10n) => switch (this) {
        ActivityType.payment => l10n.activityPaymentTitle,
        ActivityType.signup => l10n.activitySignupTitle,
        ActivityType.reportReady => l10n.activityReportTitle,
        ActivityType.systemAlert => l10n.activityAlertTitle,
      };
}

extension ActivityEventPresentation on ActivityEvent {
  String description(AppL10n l10n, ValueFormatter formatter) => switch (type) {
        ActivityType.payment => l10n.activityPaymentBody(
            formatter.currency(amount ?? 0),
            actor,
          ),
        ActivityType.signup => l10n.activitySignupBody(actor),
        ActivityType.reportReady => l10n.activityReportBody(actor),
        ActivityType.systemAlert => l10n.activityAlertBody(actor),
      };
}
