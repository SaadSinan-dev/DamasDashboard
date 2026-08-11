import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// Meaning conveyed by a [StatusPill], mapped to semantic colors by the theme.
enum StatusTone { positive, negative, warning, neutral }

/// Small labelled pill for statuses and deltas.
///
/// Every pill pairs its color with a text label rather than relying on color
/// alone, so the state is still readable for users with colour vision
/// deficiency — and by a screen reader.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;

  /// Spoken instead of [label] when the visible text is an abbreviation.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (tone) {
      StatusTone.positive => (
          context.semanticColors.onPositiveContainer,
          context.semanticColors.positiveContainer,
        ),
      StatusTone.negative => (
          context.semanticColors.onNegativeContainer,
          context.semanticColors.negativeContainer,
        ),
      StatusTone.warning => (
          context.semanticColors.onWarningContainer,
          context.semanticColors.warningContainer,
        ),
      StatusTone.neutral => (
          context.colors.onSurfaceVariant,
          context.colors.surfaceContainerHigh,
        ),
    };

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            // Flexible so an unusually long label ellipsizes inside the pill
            // instead of overflowing the card that contains it.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.labelMedium?.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
