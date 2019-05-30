import 'package:flutter/material.dart';

import 'dart:math' as Math;

class EmotiveFace extends StatelessWidget {
  num happiness;

  EmotiveFace(this.happiness);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: EmotiveFacePainter(happiness),
    );
  }
}

class EmotiveFacePainter extends CustomPainter {
  num happiness;

  EmotiveFacePainter(this.happiness);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Drawing the head
    //final paint = Paint()..color = Colors.yellow;
    //canvas.drawCircle(center, radius, paint);
    // Drawing the mouth
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final smileLeftOffset = Offset(radius / 2, 1.33 * radius);
    final smileRightOffset = Offset(1.5 * radius, 1.33 * radius);
    final smileCentreOffset = Offset(radius, radius + happiness);

    Path path = new Path()
      ..moveTo(smileLeftOffset.dx, smileLeftOffset.dy)
      ..quadraticBezierTo(smileCentreOffset.dx, smileCentreOffset.dy,
          smileRightOffset.dx, smileRightOffset.dy);
    canvas.drawPath(path, smilePaint);

    canvas.drawCircle(
        Offset(center.dx - radius / 2.5, center.dy - radius * 0.33),
        2,
        Paint());
    canvas.drawCircle(
        Offset(center.dx + radius / 2.5, center.dy - radius * 0.33),
        2,
        Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
