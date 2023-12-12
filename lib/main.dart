import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const StarApp());
}

class StarPainter extends CustomPainter {
  final Color color;

  const StarPainter({required this.color});

  @override
  paint(Canvas canvas, Size size) {
    var bgPath = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(bgPath, Paint());

    var cx = size.width / 2;
    var cy = size.height / 2;
    var radius = min(size.width, size.height) / 2 - 20;
    var innerRadius = radius * 0.5;
    var nPoints = 5;
    var a = 2 * pi / nPoints;

    var starPaint = Paint()..color = color;

    var starPath = Path();
    starPath.moveTo(cx, cy - radius);
    for (var i = 0; i < nPoints; i++) {
      var a0 = a * i;
      if (i != 0) {
        var ox = radius * sin(a0);
        var oy = radius * -cos(a0);
        starPath.lineTo(cx + ox, cy + oy);
      }
      var ix = innerRadius * sin(a0 + a / 2);
      var iy = innerRadius * -cos(a0 + a / 2);
      starPath.lineTo(cx + ix, cy + iy);
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  @override
  shouldRepaint(CustomPainter oldDelegate) => true;
}

class Star extends StatelessWidget {
  final Color color;

  const Star({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: StarPainter(color: color));
  }
}

class StarApp extends StatelessWidget {
  const StarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Star(color: Colors.yellow),
    );
  }
}
