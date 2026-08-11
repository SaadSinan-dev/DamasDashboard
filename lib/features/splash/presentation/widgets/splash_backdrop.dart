import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Static background for the splash screen: a dark gradient, a soft bloom behind
/// the logo, and a faint grid.
///
/// Static on purpose. The previous backdrop rotated arcs from a controller set
/// to `repeat()`, which never stopped — the grid and arcs were repainted every
/// frame for as long as the app ran, even after the splash had been replaced.
class SplashBackdrop extends StatelessWidget {
  const SplashBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFF020D08),
            AppPalette.emerald950,
            Color(0xFF071A10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(painter: _GridPainter()),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.35),
                radius: 0.7,
                colors: <Color>[Color(0x3310B981), Color(0x0010B981)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  static const double _spacing = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppPalette.emerald500.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    for (double x = 0; x <= size.width; x += _spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += _spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // Nothing here depends on state, so the grid is painted once and cached.
  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
