import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Paints a stylized 3D-looking wedge of cheese via CustomPainter.
/// No external model loader needed — pure Canvas drawing.
class CheeseWidget extends StatelessWidget {
  final double rotationY; // radians, drives the pseudo-3D perspective shift
  final double scale;     // 0.0 → 1.0, used for appear/disappear

  const CheeseWidget({
    super.key,
    this.rotationY = 0,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: CustomPaint(
        size: const Size(320, 280),
        painter: _CheesePainter(rotationY: rotationY),
      ),
    );
  }
}

class _CheesePainter extends CustomPainter {
  final double rotationY;

  _CheesePainter({required this.rotationY});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Perspective factor — makes the cheese appear to slightly rotate
    final perspective = math.sin(rotationY) * 0.12;

    // ── TOP FACE ──────────────────────────────────────────────────
    final topPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: [
          AppColors.chedddarLight,
          AppColors.chedddarYellow,
          AppColors.chedddarDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final topPath = Path()
      ..moveTo(cx + perspective * 60, cy - 110)
      ..lineTo(cx + 140 + perspective * 40, cy - 10)
      ..lineTo(cx - 140 + perspective * 20, cy - 10)
      ..close();

    canvas.drawPath(topPath, topPaint);

    // ── FRONT FACE ────────────────────────────────────────────────
    final frontPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.chedddarYellow,
          AppColors.chedddarDark,
        ],
      ).createShader(Rect.fromLTWH(0, cy - 10, size.width, 110));

    final frontPath = Path()
      ..moveTo(cx + 140 + perspective * 40, cy - 10)
      ..lineTo(cx + 140 + perspective * 40, cy + 100)
      ..lineTo(cx - 140 + perspective * 20, cy + 100)
      ..lineTo(cx - 140 + perspective * 20, cy - 10)
      ..close();

    canvas.drawPath(frontPath, frontPaint);

    // ── RIGHT FACE (depth) ────────────────────────────────────────
    final rightPaint = Paint()
      ..color = AppColors.chedddarDark.withValues(alpha: 0.85);

    final rightPath = Path()
      ..moveTo(cx + perspective * 60, cy - 110)
      ..lineTo(cx + 140 + perspective * 40, cy - 10)
      ..lineTo(cx + 140 + perspective * 40, cy + 100)
      ..lineTo(cx + perspective * 60, cy - 10)  // back-right bottom
      ..close();

    canvas.drawPath(rightPath, rightPaint);

    // ── HOLES ─────────────────────────────────────────────────────
    final holePaint = Paint()..color = AppColors.holeColor;

    final holes = [
      Offset(cx - 40 + perspective * 30, cy + 30),
      Offset(cx + 50 + perspective * 35, cy + 55),
      Offset(cx - 80 + perspective * 25, cy + 65),
      Offset(cx + 10 + perspective * 28, cy + 15),
    ];
    final holeRadii = [18.0, 14.0, 10.0, 12.0];

    for (int i = 0; i < holes.length; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: holes[i],
          width: holeRadii[i] * 2,
          height: holeRadii[i] * 1.3,
        ),
        holePaint,
      );
    }

    // ── HIGHLIGHT GLOSS ───────────────────────────────────────────
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 20 + perspective * 20, cy - 60),
        width: 80,
        height: 30,
      ),
      glossPaint,
    );
  }

  @override
  bool shouldRepaint(_CheesePainter old) => old.rotationY != rotationY;
}
