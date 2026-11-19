import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';

/// Surface container. Tappable cards lift 4px on hover with a deeper shadow.
class JmCard extends StatelessWidget {
  const new({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(JmSpace.x6),
    this.semanticLabel,
    this.elevated = true,
    this.highlighted = false,
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  /// Resting shadow. Flat cards rely on the border alone.
  final bool elevated;

  /// Draws a primary border, e.g. for the selected item in a list.
  final bool highlighted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;

    Widget surface(JmPressState? s) {
      final hovered = s?.hovered ?? false;
      final lift = hovered && !context.reduceMotion;
      return AnimatedContainer(
        duration: JmMotion.standard,
        curve: JmMotion.ease,
        transform: Matrix4.translationValues(
          0,
          lift ? JmMotion.hoverLift : 0,
          0,
        ),
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? jm.surface,
          borderRadius: JmRadius.cardAll,
          border: Border.all(
            color: highlighted
                ? jm.primary
                : (hovered ? jm.borderStrong : jm.border),
            width: highlighted ? 1.5 : 1,
          ),
          boxShadow: hovered
              ? jm.shadowLg
              : (elevated ? jm.shadowSm : const <BoxShadow>[]),
        ),
        child: child,
      );
    }

    if (onTap == null) {
      return Semantics(
        container: true,
        label: semanticLabel,
        child: surface(null),
      );
    }
    return JmPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      focusRadius: JmRadius.cardAll,
      scaleOnPress: false,
      builder: (context, s) => surface(s),
    );
  }
}
