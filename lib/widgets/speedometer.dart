import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Speedometer extends StatelessWidget {
  final double speed;
  final double maxSpeed;
  final double size;

  const Speedometer({
    super.key,
    required this.speed,
    this.maxSpeed = AppConstants.maxSpeedKmh,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpeedometerPainter(
          speed: speed,
          maxSpeed: maxSpeed,
          accentColor: _getSpeedColor(),
          glowColor: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Color _getSpeedColor() {
    final fraction = speed / maxSpeed;
    if (fraction < 0.5) return const Color(0xFF4CAF50);
    if (fraction < 0.75) return const Color(0xFFFFC107);
    if (fraction < 0.9) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;
  final Color accentColor;
  final Color glowColor;

  _SpeedometerPainter({
    required this.speed,
    required this.maxSpeed,
    required this.accentColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final startAngle = -210 * pi / 180;
    final sweepAngle = 240 * pi / 180;

    _drawBackground(canvas, center, radius);
    _drawArcScale(canvas, center, radius, startAngle, sweepAngle);
    _drawTickMarks(canvas, center, radius, startAngle, sweepAngle);
    _drawSpeedLabels(canvas, center, radius, startAngle, sweepAngle);
    _drawGlow(canvas, center, radius, startAngle, sweepAngle);
    _drawNeedle(canvas, center, radius, startAngle, sweepAngle);
    _drawCenterCircle(canvas, center, radius);
    _drawSpeedValue(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.grey.shade900,
      const Color(0xFF303030),
      Colors.black87,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 1, borderPaint);
  }

  void _drawArcScale(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final arcRect = Rect.fromCircle(center: center, radius: radius * 0.72);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = startAngle + (sweepAngle * i / 60);
      final isMajor = i % 5 == 0;

      if (isMajor) {
        final fraction = i / 60;
        Color segmentColor;
        if (fraction < 0.5) {
          segmentColor = const Color(0xFF4CAF50);
        } else if (fraction < 0.75) {
          segmentColor = const Color(0xFFFFC107);
        } else if (fraction < 0.9) {
          segmentColor = const Color(0xFFFF9800);
        } else {
          segmentColor = const Color(0xFFF44336);
        }

        arcPaint.color = segmentColor;
      } else {
        arcPaint.color = Colors.grey.shade600;
      }

      canvas.drawArc(
        arcRect,
        angle - 0.01,
        0.035,
        false,
        arcPaint..strokeWidth = isMajor ? 12 : 4,
      );
    }
  }

  void _drawTickMarks(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    for (int i = 0; i <= 13; i++) {
      final angle = startAngle + (sweepAngle * i / 13);
      final isMajor = i % 2 == 0;
      final innerRadius = isMajor ? radius * 0.62 : radius * 0.66;
      final outerRadius = radius * 0.72;

      final innerPoint = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final outerPoint = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(
        innerPoint,
        outerPoint,
        Paint()
          ..color = isMajor ? Colors.white70 : Colors.grey.shade500
          ..strokeWidth = isMajor ? 2.5 : 1.5,
      );
    }
  }

  void _drawSpeedLabels(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final textPainter = TextPainter(textAlign: TextAlign.center);
    const speedInterval = 20;
    final totalLabels = (maxSpeed / speedInterval).round();
    final labelCount = totalLabels + 1;

    for (int i = 0; i < labelCount; i++) {
      final fraction = i / totalLabels;
      final angle = startAngle + (sweepAngle * fraction);
      final labelRadius = radius * 0.50;

      final labelPoint = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: '${i * speedInterval}',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelPoint - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawGlow(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final fraction = (speed / maxSpeed).clamp(0.0, 1.0);
    final angle = startAngle + (sweepAngle * fraction);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(0.3),
          accentColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(
          center.dx + radius * 0.5 * cos(angle),
          center.dy + radius * 0.5 * sin(angle),
        ),
        radius: radius * 0.5,
      ));

    canvas.drawCircle(
      Offset(
        center.dx + radius * 0.5 * cos(angle),
        center.dy + radius * 0.5 * sin(angle),
      ),
      radius * 0.4,
      glowPaint,
    );
  }

  void _drawNeedle(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final fraction = (speed / maxSpeed).clamp(0.0, 1.0);
    final angle = startAngle + (sweepAngle * fraction);

    final needleLength = radius * 0.62;
    final needleTip = Offset(
      center.dx + needleLength * cos(angle),
      center.dy + needleLength * sin(angle),
    );

    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [accentColor, accentColor.withOpacity(0.6)],
      ).createShader(Rect.fromPoints(center, needleTip));

    canvas.drawLine(center, needleTip, needlePaint..strokeWidth = 3);
    canvas.drawLine(center, needleTip, Paint()
      ..color = accentColor.withOpacity(0.3)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawLine(center, needleTip, needlePaint..strokeWidth = 3);
  }

  void _drawCenterCircle(Canvas canvas, Offset center, double radius) {
    final centerGradient = RadialGradient(
      colors: [accentColor, accentColor.withOpacity(0.3)],
    );

    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..shader = centerGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.15),
      ),
    );

    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawSpeedValue(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textAlign: TextAlign.center);

    textPainter.text = TextSpan(
      text: '${speed.round()}',
      style: TextStyle(
        color: accentColor,
        fontSize: radius * 0.22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.2 - textPainter.height / 2,
      ),
    );

    textPainter.text = TextSpan(
      text: 'km/h',
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: radius * 0.065,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius * 0.28 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_SpeedometerPainter oldDelegate) =>
      oldDelegate.speed != speed || oldDelegate.accentColor != accentColor;
}
