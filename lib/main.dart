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

    var starPaint = Paint()..color = color;
    var starPath = _drawStar(cx, cy, radius);

    canvas.drawPath(starPath, starPaint);
  }

  @override
  shouldRepaint(CustomPainter oldDelegate) => true;

  Path _drawStar(double x, double y, double radius) {
    var nPoints = 5;
    var a = 2 * pi / nPoints;
    var innerRadius = radius * 0.5;

    var path = Path();
    path.moveTo(x, y - radius);
    for (var i = 0; i < nPoints; i++) {
      var a0 = a * i;
      if (i != 0) {
        var ox = radius * sin(a0);
        var oy = radius * -cos(a0);
        path.lineTo(x + ox, y + oy);
      }
      var ix = innerRadius * sin(a0 + a / 2);
      var iy = innerRadius * -cos(a0 + a / 2);
      path.lineTo(x + ix, y + iy);
    }
    path.close();

    return path;
  }
}

class Star extends StatelessWidget {
  final Color color;

  const Star({super.key, required this.color});

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
      home: const Star(color: Colors.yellow),
    );
  }
}
