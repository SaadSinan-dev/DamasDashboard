import 'package:damas_dashboard/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

// Internal project imports

import 'package:damas_dashboard/core/app_fonts.dart';
import 'package:damas_dashboard/core/app_colors.dart';


part 'splash_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _contentController;
  late final AnimationController _progressController;
  late final AnimationController _particleController;

  // ── Logo ───────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoGlow;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  // ── Content ────────────────────────────────────────────────────
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _taglineFade;

  // ── Progress ───────────────────────────────────────────────────
  late final Animation<double> _progressValue;
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Background sweep
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _ringScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Content stagger
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    ));

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    // Particle rotation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  Future<void> _startSequence() async {
    _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const Homescreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: Stack(
        children: [
          // ── 1. Animated Background ───────────────────────────
          _AnimatedBackground(
            controller: _bgController,
            particleController: _particleController,
            size: size,
          ),

          // ── 2. Main Content ──────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) => _LogoSection(
                    scale: _logoScale.value,
                    fade: _logoFade.value,
                    glow: _logoGlow.value,
                    ringScale: _ringScale.value,
                    ringOpacity: _ringOpacity.value,
                  ),
                ),

                const SizedBox(height: 48),

                // Content
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (_, __) => _ContentSection(
                    titleFade: _titleFade.value,
                    titleSlide: _titleSlide.value,
                    subtitleFade: _subtitleFade.value,
                    subtitleSlide: _subtitleSlide.value,
                    taglineFade: _taglineFade.value,
                  ),
                ),

                const Spacer(flex: 3),

                // Progress
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) => _ProgressSection(
                    progress: _progressValue.value,
                    fade: _progressFade.value,
                  ),
                ),

                const SizedBox(height: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }
}