import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const StarApp());
}

class StarPainter extends CustomPainter {
  final Color color;
  final double progress;

  const StarPainter({required this.color, this.progress = 0.0});

  @override
  paint(Canvas canvas, Size size) {
    var bgPath = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(bgPath, Paint());

    var cx = size.width / 2;
    var cy = size.height / 2;
    var radius = min(size.width, size.height) / 2 - 20;

    var starPaint = Paint()..color = color;
    var starPath = _drawStar(cx, cy, radius,
        rotation: 2 * pi * Curves.easeInOut.transform(progress));

    canvas.drawPath(starPath, starPaint);
  }

  @override
  shouldRepaint(CustomPainter oldDelegate) => true;

  Path _drawStar(double x, double y, double radius, {double rotation = 0.0}) {
    var nPoints = 5;
    var a = 2 * pi / nPoints;
    var innerRadius = radius * 0.5;

    var path = Path();
    for (var i = 0; i < nPoints; i++) {
      var a0 = a * i + rotation;
      var ox = radius * sin(a0);
      var oy = radius * -cos(a0);
      if (i == 0) {
        path.moveTo(x + ox, y + oy);
      } else {
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

class AnimatedStar extends AnimatedWidget {
  const AnimatedStar({super.key, required AnimationController controller})
      : super(listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: StarPainter(color: Colors.yellow, progress: _progress.value));
  }
}

class StarApp extends StatefulWidget {
  const StarApp({super.key});

  @override
  State<StarApp> createState() => StarAppState();
}

class StarAppState extends State<StarApp> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 2), vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GestureDetector(
        onTap: () {
          if (_controller.isAnimating) {
            return;
          }
          _controller.reset();
          _controller.forward();
        },
        child: AnimatedStar(controller: _controller),
      ),
    );
  }
}
