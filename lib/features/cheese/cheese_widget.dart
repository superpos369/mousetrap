import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class CheeseWidget extends StatelessWidget {
  final double rotationY;
  final double scale;

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
        size: const Size(340, 300),
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
    final cy = size.height * 0.54;
    final p = math.sin(rotationY) * 0.15; // perspective shift

    // ── SHADOW UNDER CHEESE ───────────────────────────────────────
    final shadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32)
      ..color = const Color(0xCC000000);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + p * 30, cy + 108), width: 280, height: 28),
      shadowPaint,
    );

    // ── GEOMETRY ──────────────────────────────────────────────────
    // Block cheese: front face, top face, right side face

    final tl = Offset(cx - 148 + p * 10, cy - 88); // top-left
    final tr = Offset(cx + 148 + p * 60, cy - 88); // top-right
    final bl = Offset(cx - 148 + p * 10, cy + 108); // bottom-left
    final br = Offset(cx + 148 + p * 60, cy + 108); // bottom-right

    // Depth offset for top/right faces
    const dz = 44.0;
    final tlb = Offset(tl.dx - dz * 0.6, tl.dy - dz); // back-top-left
    final trb = Offset(tr.dx - dz * 0.6, tr.dy - dz); // back-top-right

    // ── RIGHT SIDE FACE ───────────────────────────────────────────
    final rightPath = Path()
      ..moveTo(tr.dx, tr.dy)
      ..lineTo(trb.dx, trb.dy)
      ..lineTo(trb.dx, trb.dy + (br.dy - tr.dy))
      ..lineTo(br.dx, br.dy)
      ..close();

    canvas.drawPath(
      rightPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFB87000),
            const Color(0xFF8A5200),
          ],
        ).createShader(rightPath.getBounds()),
    );

    // ── TOP FACE ──────────────────────────────────────────────────
    final topPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(trb.dx, trb.dy)
      ..lineTo(tlb.dx, tlb.dy)
      ..close();

    canvas.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFE89A00),
            const Color(0xFFFFC93C),
            const Color(0xFFFFE08A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(topPath.getBounds()),
    );

    // Top face rim highlight
    canvas.drawPath(
      topPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0x33FFFFFF),
    );

    // ── FRONT FACE ────────────────────────────────────────────────
    final frontPath = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();

    canvas.drawPath(
      frontPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF4A800),
            const Color(0xFFD98A00),
            const Color(0xFFC07800),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(frontPath.getBounds()),
    );

    // ── HOLES ─────────────────────────────────────────────────────
    _drawHole(canvas, Offset(cx - 58 + p * 20, cy - 18), 24, 17);
    _drawHole(canvas, Offset(cx + 38 + p * 40, cy + 32), 20, 14);
    _drawHole(canvas, Offset(cx - 90 + p * 14, cy + 52), 15, 11);
    _drawHole(canvas, Offset(cx + 80 + p * 48, cy - 30), 13, 9);
    _drawHole(canvas, Offset(cx - 10 + p * 28, cy + 68), 18, 13);

    // ── LIGHT REFLECTION (top) ────────────────────────────────────
    final glossPath = Path()
      ..moveTo(tl.dx + 20, tl.dy + 4)
      ..lineTo(tr.dx - 20, tr.dy + 4)
      ..lineTo(tr.dx - 20, tr.dy + 14)
      ..lineTo(tl.dx + 20, tl.dy + 14)
      ..close();

    canvas.drawPath(
      glossPath,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..color = const Color(0x44FFFFFF),
    );

    // ── FRONT FACE GLOSS (left edge bright) ───────────────────────
    final edgeGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0x30FFFFFF),
          const Color(0x00FFFFFF),
        ],
      ).createShader(Rect.fromLTWH(tl.dx, tl.dy, 80, bl.dy - tl.dy))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(frontPath, edgeGlow);

    // ── OUTER GLOW ────────────────────────────────────────────────
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
      ..color = AppColors.chedddarYellow.withValues(alpha: 0.22);
    canvas.drawRect(
      Rect.fromLTRB(tl.dx - 12, tlb.dy - 12, br.dx + 12, br.dy + 12),
      glowPaint,
    );
  }

  void _drawHole(Canvas canvas, Offset center, double rx, double ry) {
    // Outer dark ring (depth)
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..color = const Color(0xCC3D1F00),
    );

    // Inner hole
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2 - 4, height: ry * 2 - 3),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 1.0,
          colors: const [
            Color(0xFF5C2D00),
            Color(0xFF2A1000),
          ],
        ).createShader(Rect.fromCenter(
          center: center,
          width: rx * 2,
          height: ry * 2,
        )),
    );

    // Highlight glint top-left
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - rx * 0.28, center.dy - ry * 0.3),
        width: rx * 0.5,
        height: ry * 0.35,
      ),
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(_CheesePainter old) => old.rotationY != rotationY;
}
