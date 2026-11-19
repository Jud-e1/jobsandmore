import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Placeholder logo mark: a rounded emerald tile holding an upward "path"
/// (a stepped J that ends in a rising arrow-dot), standing for a career that
/// moves forward. Swap for the final mark in `assets/brand/`.
class JmLogoMark extends StatelessWidget {
  const new({this.size = 36, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'JobsAndMore',
    image: true,
    child: CustomPaint(size: Size.square(size), painter: JmLogoPainter()),
  );
}

class JmLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;
    final tile = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.28));
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [JmBrand.emerald, JmBrand.teal],
        ).createShader(rect),
    );

    // Soft inner highlight.
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.7, -0.8),
          radius: 1.1,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The "J" path, rising to the right.
    final path = Path()
      ..moveTo(s * 0.56, s * 0.30)
      ..lineTo(s * 0.56, s * 0.58)
      ..quadraticBezierTo(s * 0.56, s * 0.74, s * 0.40, s * 0.74)
      ..quadraticBezierTo(s * 0.28, s * 0.74, s * 0.26, s * 0.62);
    canvas.drawPath(path, stroke);

    // Amber "more" dot.
    canvas.drawCircle(
      Offset(s * 0.74, s * 0.30),
      s * 0.085,
      Paint()..color = JmBrand.amber,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo mark + wordmark.
class JmLogo extends StatelessWidget {
  const new({this.size = 32, this.showWordmark = true, super.key});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    if (!showWordmark) return JmLogoMark(size: size);
    return Semantics(
      label: 'JobsAndMore',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          JmLogoMark(size: size),
          SizedBox(width: size * 0.3),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'JobsAnd'),
                TextSpan(
                  text: 'More',
                  style: TextStyle(color: jm.primary),
                ),
              ],
            ),
            style: context.type.h4.copyWith(
              fontSize: size * 0.62,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: jm.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mesh-gradient backdrop: three large blurred orbs drifting very slowly.
/// Static under reduce-motion.
class JmMeshBackground extends StatefulWidget {
  const new({this.child, this.intensity = 1, super.key});

  final Widget? child;
  final double intensity;

  @override
  State<JmMeshBackground> createState() => _JmMeshBackgroundState();
}

class _JmMeshBackgroundState extends State<JmMeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _MeshPainter(
                  t: _c.value,
                  colors: [jm.orbA, jm.orbB, jm.orbC],
                  base: jm.background,
                  intensity: widget.intensity * (jm.isDark ? 0.55 : 0.7),
                ),
              ),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  new({
    required this.t,
    required this.colors,
    required this.base,
    required this.intensity,
  });

  final double t;
  final List<Color> colors;
  final Color base;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final a = t * 2 * math.pi;
    final r = math.max(size.width, size.height);
    final orbs = [
      (
        Offset(size.width * (0.18 + 0.04 * math.sin(a)), size.height * 0.15),
        r * 0.42,
        colors[0],
      ),
      (
        Offset(
          size.width * (0.82 + 0.05 * math.cos(a)),
          size.height * (0.28 + 0.06 * math.sin(a)),
        ),
        r * 0.38,
        colors[1],
      ),
      (
        Offset(
          size.width * (0.55 + 0.05 * math.sin(a + 2)),
          size.height * (0.95 + 0.04 * math.cos(a)),
        ),
        r * 0.3,
        colors[2],
      ),
    ];
    for (final (c, radius, color) in orbs) {
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(c, radius, [
            color.withValues(alpha: intensity),
            color.withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(_MeshPainter old) =>
      old.t != t || old.base != base || old.intensity != intensity;
}

/// Frosted glass panel (blur + ~70% surface) for hero search bars.
class JmGlass extends StatelessWidget {
  const new({
    required this.child,
    this.padding = const EdgeInsets.all(JmSpace.x3),
    this.radius = JmRadius.sheetAll,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: jm.shadowLg),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: jm.glass,
              borderRadius: radius,
              border: Border.all(color: jm.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
