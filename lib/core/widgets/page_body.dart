import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// Scrollable page body with responsive padding, a max content width, and
/// pull-to-refresh.
///
/// Centring wide content matters on tablet and desktop: a dashboard stretched
/// across 1600px forces the eye to travel the full width to pair a label with
/// its value.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.children,
    this.onRefresh,
    this.scrollController,
  });

  final List<Widget> children;

  /// When provided, the body supports pull-to-refresh.
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final double horizontal =
        context.isCompact ? AppSpacing.lg : AppSpacing.xxl;

    final Widget scrollView = CustomScrollView(
      controller: scrollController,
      // Always scrollable so pull-to-refresh works even when content is short.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            AppSpacing.xl,
            horizontal,
            AppSpacing.xxxl,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (onRefresh == null) return scrollView;

    return RefreshIndicator.adaptive(
      onRefresh: onRefresh!,
      child: scrollView,
    );
  }
}

/// Lays children out in a grid whose column count follows the available width.
///
/// Used for metric cards. A [LayoutBuilder] is used rather than `MediaQuery` so
/// the grid also adapts correctly when it sits beside a navigation rail, where
/// the window width no longer equals the width available to content.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.minTileWidth = 240,
    this.spacing = AppSpacing.lg,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, children.length.clamp(1, 4));
        final double tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            for (final Widget child in children)
              SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}
