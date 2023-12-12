import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const StarApp());
}

enum StarAnimation {
  spin,
  fall,
  rainbow,
  shrink,
  invert,
}

class StarPainter extends CustomPainter {
  final StarAnimation animation;
  final double progress;

  const StarPainter({this.animation = StarAnimation.spin, this.progress = 0.0});

  @override
  paint(Canvas canvas, Size size) {
    var cx = size.width / 2;
    var cy = size.height / 2;
    var radius = min(size.width, size.height) / 2 - 20;
    double rotation = 0.0;
    Color bgColor = Colors.black;
    Color color = Colors.yellow;

    if (animation == StarAnimation.shrink) {
      if (progress < 0.5) {
        var p = progress * 2;
        radius *= (1.0 - p);
      } else {
        var p = (progress - 0.5) * 2;
        radius *= Curves.elasticOut.transform(p);
      }
    }

    if (animation == StarAnimation.invert) {
      var color0 = bgColor;
      var color1 = color;
      if (progress < 0.5) {
        var p = progress * 2;
        bgColor = HSVColor.lerp(
                HSVColor.fromColor(color0), HSVColor.fromColor(color1), p)!
            .toColor();
        color = HSVColor.lerp(
                HSVColor.fromColor(color1), HSVColor.fromColor(color0), p)!
            .toColor();
      } else {
        var p = (progress - 0.5) * 2;
        bgColor = HSVColor.lerp(
                HSVColor.fromColor(color1), HSVColor.fromColor(color0), p)!
            .toColor();
        color = HSVColor.lerp(
                HSVColor.fromColor(color0), HSVColor.fromColor(color1), p)!
            .toColor();
      }
    }

    if (animation == StarAnimation.spin) {
      rotation = 2 * pi * Curves.easeInOut.transform(progress);
    }

    if (animation == StarAnimation.fall) {
      var d = (size.height / 2) + radius;
      if (progress < 0.5) {
        var p = Curves.easeInQuad.transform(progress * 2);
        cy = (size.height / 2) + d * p;
      } else {
        var p = Curves.bounceOut.transform((progress - 0.5) * 2);
        cy = -radius + d * p;
      }
    }

    if (animation == StarAnimation.rainbow) {
      var colors = [
        Colors.yellow,
        Colors.green,
        Colors.lightBlue,
        Colors.purple,
        Colors.red,
        Colors.orange
      ];
      var c = progress * colors.length;
      var colorIndex = c.floor();
      var colorBlend = c - colorIndex;
      var color0 = colors[colorIndex % colors.length];
      var color1 = colors[(colorIndex + 1) % colors.length];
      color = HSVColor.lerp(HSVColor.fromColor(color0),
              HSVColor.fromColor(color1), colorBlend)!
          .toColor();
    }

    var bgPaint = Paint()..color = bgColor;
    var bgPath = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(bgPath, bgPaint);

    var starPaint = Paint()..color = color;
    var starPath = _drawStar(cx, cy, radius, rotation: rotation);

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

class AnimatedStar extends AnimatedWidget {
  final StarAnimation animation;

  const AnimatedStar(
      {super.key,
      required AnimationController controller,
      this.animation = StarAnimation.spin})
      : super(listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: StarPainter(animation: animation, progress: _progress.value));
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
  StarAnimation animation = StarAnimation.spin;
  final random = Random();

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
          setState(() {
            var animations = StarAnimation.values;
            animation = animations[random.nextInt(animations.length)];
          });
          _controller.reset();
          _controller.forward();
        },
        child: AnimatedStar(controller: _controller, animation: animation),
      ),
    );
  }
}
