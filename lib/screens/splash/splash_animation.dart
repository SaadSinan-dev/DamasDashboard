part of 'splash_screen.dart';

// ── Background Layer ──────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final AnimationController particleController;
  final Size size;

  const _AnimatedBackground({
    required this.controller,
    required this.particleController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, particleController]),
      builder: (_, __) {
        return Stack(
          children: [
            // Base dark gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020D08),
                    Color(0xFF051F17),
                    Color(0xFF071A10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Radial glow — center bloom
            Positioned(
              top: size.height * 0.25,
              left: size.width * 0.5 - 180,
              child: Opacity(
                opacity: controller.value * 0.6,
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x3010B981),
                        Color(0x0810B981),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Rotating arc decoration
            Positioned.fill(
              child: Transform.rotate(
                angle: particleController.value * 2 * math.pi * 0.08,
                child: CustomPaint(
                  painter: _ArcPainter(
                    opacity: controller.value * 0.18,
                    size: size,
                  ),
                ),
              ),
            ),

            // Subtle grid lines
            Positioned.fill(
              child: Opacity(
                opacity: controller.value * 0.04,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final double scale, fade, glow, ringScale, ringOpacity;

  const _LogoSection({
    required this.scale,
    required this.fade,
    required this.glow,
    required this.ringScale,
    required this.ringOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fade,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.scale(
                scale: ringScale,
                child: Opacity(
                  opacity: ringOpacity * 0.25,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // Middle ring
              Transform.scale(
                scale: ringScale,
                child: Opacity(
                  opacity: ringOpacity * 0.15,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLight,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Glow halo
              Opacity(
                opacity: glow * 0.5,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Core logo tile
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [AppColors.surface, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Inner shimmer
                    Positioned(
                      top: 6,
                      left: 8,
                      right: 30,
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.add_chart_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Text Content ──────────────────────────────────────────────────

class _ContentSection extends StatelessWidget {
  final double titleFade, subtitleFade, taglineFade;
  final Offset titleSlide, subtitleSlide;

  const _ContentSection({
    required this.titleFade,
    required this.titleSlide,
    required this.subtitleFade,
    required this.subtitleSlide,
    required this.taglineFade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main title
        FractionalTranslation(
          translation: titleSlide,
          child: Opacity(
            opacity: titleFade,
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'DAMAS',
                    style: TextStyle(
                      fontFamily: AppFonts.english,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                  TextSpan(
                    text: ' DASH',
                    style: TextStyle(
                      fontFamily: AppFonts.english,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF10B981),
                      letterSpacing: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Divider line
        FractionalTranslation(
          translation: titleSlide,
          child: Opacity(
            opacity: titleFade * 0.6,
            child: Container(
              width: 40,
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF10B981),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Arabic subtitle
        FractionalTranslation(
          translation: subtitleSlide,
          child: Opacity(
            opacity: subtitleFade,
            child: const Text(
              "لوحة التحكم  لإدارة بياناتك",
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppFonts.arabic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64A882),
                letterSpacing: 0.3,
                height: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Version tagline
        Opacity(
          opacity: taglineFade * 0.45,
          child: const Text(
            'v2.0 · Enterprise Edition',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: Color(0xFF2D6B4F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final double progress;
  final double fade;

  const _ProgressSection({required this.progress, required this.fade});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();

    return Opacity(
      opacity: fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            // Track
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 2,
                color: const Color(0xFF0F2B1E),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF059669),
                              Color(0xFF34D399),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Percentage
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2D6B4F),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double opacity;
  final Size size;

  _ArcPainter({required this.opacity, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = Offset(size.width / 2, size.height * 0.35);
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 160.0 + i * 55),
        -math.pi * 0.4,
        math.pi * 0.8,
        false,
        paint..color = AppColors.primary.withOpacity(opacity - i * 0.04),
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.opacity != opacity;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}