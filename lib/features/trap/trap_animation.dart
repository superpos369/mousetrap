import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Draws the mousetrap — a classic spring-bar trap.
/// [snapProgress] goes 0.0 (open/set) → 1.0 (snapped shut).
class TrapAnimation extends StatelessWidget {
  final double snapProgress; // 0 = open, 1 = snapped

  const TrapAnimation({super.key, required this.snapProgress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 200),
      painter: _TrapPainter(progress: snapProgress),
    );
  }
}

class _TrapPainter extends CustomPainter {
  final double progress;

  _TrapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;

    // ── BASE PLATE ────────────────────────────────────────────────
    final basePaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.fill;

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 260, height: 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(baseRect, basePaint);

    // Screws
    final screwPaint = Paint()..color = const Color(0xFF555555);
    for (final x in [cx - 110.0, cx + 110.0]) {
      canvas.drawCircle(Offset(x, cy), 5, screwPaint);
    }

    // ── SPRING COIL (left side) ───────────────────────────────────
    _drawSpring(canvas, Offset(cx - 90, cy - 11), progress);

    // ── KILL BAR — swings from open (~-100°) to shut (0°) ────────
    final barAngle = _lerp(-math.pi * 0.72, 0, progress);
    final pivot = Offset(cx - 90, cy - 11);

    final barPaint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barEnd = Offset(
      pivot.dx + math.cos(barAngle) * 200,
      pivot.dy + math.sin(barAngle) * 200,
    );

    canvas.drawLine(pivot, barEnd, barPaint);

    // Bar tip circle
    canvas.drawCircle(
      barEnd,
      5,
      Paint()..color = const Color(0xFF333333),
    );

    // ── BAIT PLATFORM ─────────────────────────────────────────────
    if (progress < 0.5) {
      final baitPaint = Paint()..color = AppColors.chedddarYellow.withValues(alpha: 1 - progress * 2);
      canvas.drawCircle(Offset(cx + 40, cy - 15), 10, baitPaint);
    }

    // ── IMPACT FLASH ──────────────────────────────────────────────
    if (progress > 0.85) {
      final flashOpacity = (1.0 - progress) * 6.0; // fades 0.85 → 1.0
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: flashOpacity.clamp(0, 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(pivot, 60, flashPaint);
    }
  }

  void _drawSpring(Canvas canvas, Offset center, double progress) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    const coils = 6;
    const width = 16.0;
    const height = 14.0;

    for (int i = 0; i < coils; i++) {
      final y = center.dy - height / 2 + (i * height / coils);
      final x1 = center.dx - width / 2;
      final x2 = center.dx + width / 2;
      if (i == 0) path.moveTo(x1, y);
      path.lineTo(x2, y);
      path.lineTo(x1, y + height / coils);
    }

    canvas.drawPath(path, paint);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_TrapPainter old) => old.progress != progress;
}
