import 'package:flutter/widgets.dart';

/// Motion tokens. Premium, never distracting.
abstract final class JmMotion {
  /// Micro-interactions: press, hover, toggle.
  static const micro = Duration(milliseconds: 150);

  /// Standard component transitions.
  static const standard = Duration(milliseconds: 250);

  /// Page and hero transitions.
  static const page = Duration(milliseconds: 400);

  /// Delay between items in a staggered list entrance.
  static const stagger = Duration(milliseconds: 60);

  static const Curve ease = Curves.easeOutCubic;

  /// Material 3 "emphasized" curve, for things that travel a long way.
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// Gentle spring for bottom sheets and drawers.
  static final SpringDescription sheetSpring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 0.86);

  /// Scale applied to buttons and cards while pressed.
  static const double pressScale = 0.97;

  /// Vertical lift for hovered cards on web/desktop.
  static const double hoverLift = -4;

  /// True when the user asked the OS to reduce motion. Components must skip
  /// decorative animation (stagger, shimmer sweep, lifts) when this is set.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [d], or zero when motion is reduced.
  static Duration of(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;
}
