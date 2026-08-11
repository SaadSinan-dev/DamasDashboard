import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// Page title and supporting line, with optional end-aligned actions.
///
/// Marked as a heading for screen readers so users can jump between sections
/// with rotor/heading navigation instead of swiping through every control.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            style: context.isCompact
                ? context.textStyles.displaySmall
                : context.textStyles.displayMedium,
          ),
        ),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (actions.isEmpty) return text;

    // On narrow screens actions wrap below the title rather than squeezing it.
    if (context.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          text,
          const SizedBox(height: AppSpacing.lg),
          Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: actions),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(child: text),
        const SizedBox(width: AppSpacing.lg),
        Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: actions),
      ],
    );
  }
}
