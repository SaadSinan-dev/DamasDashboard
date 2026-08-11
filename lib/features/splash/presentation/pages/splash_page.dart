import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/splash_backdrop.dart';

/// Branded launch screen.
///
/// This feature has no domain or data layer, and deliberately so: it fetches
/// nothing and decides nothing. Giving it a repository and a cubit to match the
/// other features would be architecture for its own sake.
///
/// Rewritten from a version that ran five concurrent controllers — one of them
/// `repeat()`ing forever, so the splash kept animating and repainting a
/// full-screen `CustomPaint` for the life of the process — and chained
/// `Future.delayed` calls that touched controllers without checking whether the
/// widget was still mounted.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// How long the full entrance sequence runs.
  static const Duration sequenceDuration = Duration(milliseconds: 2600);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // One controller drives everything; the individual elements are staggered with
  // Intervals. Five controllers were five things to keep in sync and dispose.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashPage.sequenceDuration,
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.05, 0.45, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.05, 0.35, curve: Curves.easeOut),
  );
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
  );
  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 1, curve: Curves.easeInOut),
  );

  bool _sequenceStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is unavailable in initState, and the reduced-motion preference
    // has to be read before deciding whether to animate at all.
    if (_sequenceStarted) return;
    _sequenceStarted = true;
    _run(reduceMotion: MediaQuery.disableAnimationsOf(context));
  }

  Future<void> _run({required bool reduceMotion}) async {
    if (reduceMotion) {
      // Users who asked the platform to reduce motion still get the brand
      // moment, just without the movement.
      _controller.value = 1;
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } else {
      try {
        await _controller.forward().orCancel;
      } on TickerCanceled {
        // Disposed mid-animation — the route is gone, so there is nothing to
        // navigate to.
        return;
      }
    }

    if (!mounted) return;
    context.goNamed(AppRoute.dashboard.routeName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scoped to this route and reverted automatically on pop, unlike a
    // SystemChrome call in initState which would leak into the next screen.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppPalette.emerald950,
      ),
      child: Scaffold(
        backgroundColor: AppPalette.emerald950,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Isolated so the static backdrop is not repainted by the animated
            // foreground on every frame.
            const RepaintBoundary(child: SplashBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 3),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const _SplashLogo(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeTransition(
                      opacity: _titleFade,
                      child: const _SplashTitle(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        context.l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: AppPalette.emerald300,
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    _SplashProgress(progress: _progress),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: <Color>[AppPalette.emerald600, AppPalette.emerald400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.emerald500.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.insights_rounded,
        size: 44,
        color: AppPalette.emerald950,
      ),
    );
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    // Always Latin and always LTR: it is the product's wordmark, not translated
    // copy, so it should not flip with the locale.
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: 'DAMAS',
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            TextSpan(
              text: ' DASH',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: AppPalette.emerald400,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppTypography.latinDisplay,
          fontSize: 36,
          letterSpacing: 6,
          height: 1.1,
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedBuilder(
          animation: progress,
          builder: (BuildContext context, _) => LinearProgressIndicator(
            value: progress.value,
            minHeight: 3,
            backgroundColor: AppPalette.emerald900,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppPalette.emerald400,
            ),
          ),
        ),
      ),
    );
  }
}
