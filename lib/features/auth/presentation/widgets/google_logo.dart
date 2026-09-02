import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Google "G" mark, drawn as vector paint so the button needs no bundled
/// asset and stays crisp at any size.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  // Brand colours, per Google's identity guidelines.
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // Author against a 24x24 grid, then scale to the requested size.
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale);

    const stroke = 4.6;
    const outerRadius = 11.5;
    final ringRect = Rect.fromCircle(
      center: const Offset(12, 12),
      radius: outerRadius - stroke / 2,
    );

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    void segment(Color color, double startDeg, double sweepDeg) {
      canvas.drawArc(
        ringRect,
        _rad(startDeg),
        _rad(sweepDeg),
        false,
        arc..color = color,
      );
    }

    // Clockwise from the upper left: red over the top, blue down the right to
    // the crossbar, green across the bottom, yellow up the left.
    segment(_red, 190, 120);
    segment(_blue, -50, 70);
    segment(_green, 20, 110);
    segment(_yellow, 130, 60);

    // The crossbar that turns the ring into a G.
    canvas.drawRect(
      const Rect.fromLTRB(11.6, 9.75, 22.6, 14.25),
      Paint()..color = _blue,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
