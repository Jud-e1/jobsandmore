import 'dart:math' as math;

import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Animated radial score (ATS-readiness, profile completion, match).
///
/// Colour follows the score band. The number counts up with the ring; under
/// reduce-motion both jump straight to the value.
class JmScoreRing extends StatelessWidget {
  const new({
    required this.score,
    this.size = 120,
    this.label,
    this.strokeWidth,
    this.showValue = true,
    this.semanticLabel,
    this.useBandColours = true,
    super.key,
  });

  /// 0–100.
  final double score;
  final double size;
  final String? label;
  final double? strokeWidth;
  final bool showValue;
  final String? semanticLabel;

  /// When false the ring always uses the signature gradient (e.g. profile
  /// completion, where a low score is not "bad").
  final bool useBandColours;

  Color _band(JmPalette jm, double v) {
    if (!useBandColours) return jm.primary;
    if (v >= 75) return jm.success;
    if (v >= 50) return jm.info;
    if (v >= 30) return jm.warning;
    return jm.error;
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final target = score.clamp(0, 100).toDouble();
    final stroke = strokeWidth ?? size * 0.09;

    return Semantics(
      label:
          semanticLabel ?? '${label ?? 'Score'}: ${target.round()} out of 100',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: target),
        duration: JmMotion.of(context, const Duration(milliseconds: 1100)),
        curve: JmMotion.emphasized,
        builder: (context, v, _) {
          final color = _band(jm, v);
          return SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _RingPainter(
                value: v / 100,
                track: jm.surfaceSunken,
                color: color,
                gradient: useBandColours ? null : jm.signature,
                stroke: stroke,
              ),
              child: showValue
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${v.round()}',
                            style: type.h2.copyWith(
                              fontSize: size * 0.28,
                              height: 1,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (label != null && size >= 96) ...[
                            const SizedBox(height: 4),
                            Text(
                              label!,
                              textAlign: TextAlign.center,
                              style: type.caption.copyWith(
                                color: jm.textMuted,
                                fontSize: math.max(11, size * 0.09),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  new({
    required this.value,
    required this.track,
    required this.color,
    required this.stroke,
    this.gradient,
  });

  final double value;
  final Color track;
  final Color color;
  final double stroke;
  final Gradient? gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      p.shader = SweepGradient(
        startAngle: 0,
        colors: (gradient! as LinearGradient).colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    } else {
      p.color = color;
    }
    canvas.drawArc(rect, -math.pi / 2, sweep, false, p);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Labelled linear progress bar.
class JmProgressMeter extends StatelessWidget {
  const new({
    required this.value,
    this.label,
    this.trailing,
    this.compact = false,
    this.tone = JmTone.primary,
    super.key,
  });

  /// 0–1.
  final double value;
  final String? label;

  /// Overrides the default "NN%" text on the right.
  final String? trailing;
  final bool compact;
  final JmTone tone;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final v = value.clamp(0.0, 1.0);
    final fill = tone == JmTone.primary ? jm.primary : jm.toneFg(tone);
    final bar = ClipRRect(
      borderRadius: JmRadius.pill,
      child: SizedBox(
        height: compact ? 6 : 8,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: jm.surfaceSunken)),
            // Positioned.fill gives the fill the track's full height; the
            // fraction then sets only its width.
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: v),
                duration: JmMotion.of(
                  context,
                  const Duration(milliseconds: 800),
                ),
                curve: JmMotion.emphasized,
                builder: (context, t, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tone == JmTone.primary ? null : fill,
                      gradient: tone == JmTone.primary ? jm.signature : null,
                      borderRadius: JmRadius.pill,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      label: label,
      value: '${(v * 100).round()}%',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    label!,
                    style: (compact ? type.caption : type.small).copyWith(
                      color: jm.textMuted,
                    ),
                  ),
                ),
                Text(
                  trailing ?? '${(v * 100).round()}%',
                  style: (compact ? type.caption : type.label).copyWith(
                    color: jm.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 6 : JmSpace.x2),
          ],
          bar,
        ],
      ),
    );
  }
}

/// Onboarding stepper. Full labels on wide layouts; a segmented bar plus
/// "Step 2 of 5" on narrow ones.
class JmStepper extends StatelessWidget {
  const new({
    required this.steps,
    required this.current,
    this.onStepTap,
    super.key,
  });

  final List<String> steps;

  /// Zero-based index of the active step.
  final int current;

  /// Lets users jump back to completed steps.
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return Semantics(
      label: 'Step ${current + 1} of ${steps.length}: ${steps[current]}',
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= steps.length * 120;
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'STEP ${current + 1} OF ${steps.length}',
                      style: type.overline.copyWith(color: jm.textSubtle),
                    ),
                    const Spacer(),
                    Text(steps[current], style: type.label),
                  ],
                ),
                const SizedBox(height: JmSpace.x2),
                Row(
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedContainer(
                          duration: JmMotion.standard,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i <= current ? jm.primary : jm.surfaceSunken,
                            borderRadius: JmRadius.pill,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: AnimatedContainer(
                        duration: JmMotion.standard,
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: i <= current ? jm.primary : jm.border,
                          borderRadius: JmRadius.pill,
                        ),
                      ),
                    ),
                  ),
                _StepDot(
                  index: i,
                  label: steps[i],
                  done: i < current,
                  active: i == current,
                  onTap: onStepTap != null && i < current
                      ? () => onStepTap!(i)
                      : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const new({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
    this.onTap,
  });

  final int index;
  final String label;
  final bool done;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final dot = AnimatedContainer(
      duration: JmMotion.standard,
      curve: JmMotion.ease,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? jm.primary : (active ? jm.surface : jm.surfaceSunken),
        border: Border.all(
          color: done || active ? jm.primary : jm.border,
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: jm.primary.withValues(alpha: 0.2),
                  blurRadius: 0,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: done
          ? Icon(PhosphorIconsBold.check, size: 16, color: jm.onPrimary)
          : Text(
              '${index + 1}',
              style: type.label.copyWith(
                color: active ? jm.primary : jm.textSubtle,
              ),
            ),
    );
    return Semantics(
      button: onTap != null,
      label:
          '${done ? 'Completed' : (active ? 'Current' : 'Upcoming')}: $label',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
          child: SizedBox(
            width: 96,
            child: Column(
              children: [
                dot,
                const SizedBox(height: JmSpace.x2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: type.caption.copyWith(
                    color: active ? jm.text : jm.textMuted,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
