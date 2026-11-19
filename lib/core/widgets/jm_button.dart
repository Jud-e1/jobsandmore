import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';

enum JmButtonVariant { primary, secondary, ghost, destructive, accent }

enum JmButtonSize { sm, md, lg }

/// The one button. Primary CTAs get the signature gradient on hover plus a
/// coloured glow; loading keeps the button's width so layouts never jump.
class JmButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.variant = JmButtonVariant.primary,
    this.size = JmButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
    this.haptic = false,
    super.key,
  });

  const new secondary({
    required this.label,
    required this.onPressed,
    this.size = JmButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
    this.haptic = false,
    super.key,
  }) : variant = JmButtonVariant.secondary;

  const new ghost({
    required this.label,
    required this.onPressed,
    this.size = JmButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
    this.haptic = false,
    super.key,
  }) : variant = JmButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final JmButtonVariant variant;
  final JmButtonSize size;
  final IconData? leading;
  final IconData? trailing;
  final bool loading;
  final bool expand;
  final String? semanticLabel;
  final bool haptic;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final enabled = onPressed != null && !loading;

    final (height, hPad, fontSize, iconSize) = switch (size) {
      JmButtonSize.sm => (36.0, 14.0, 14.0, 16.0),
      JmButtonSize.md => (JmSpace.minTouch, 18.0, 15.0, 18.0),
      JmButtonSize.lg => (54.0, 24.0, 16.0, 20.0),
    };

    return JmPressable(
      onTap: enabled ? onPressed : null,
      semanticLabel: semanticLabel ?? label,
      haptic: haptic,
      builder: (context, s) {
        final (bg, fg, border) = _colors(jm, s);
        final gradient =
            variant == JmButtonVariant.primary && s.hovered && enabled
            ? jm.signature
            : null;

        final content = Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Icon(leading, size: iconSize, color: fg),
              const SizedBox(width: JmSpace.x2),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: type.label.copyWith(
                  fontSize: fontSize,
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: JmSpace.x2),
              AnimatedSlide(
                offset: Offset(s.hovered && !context.reduceMotion ? 0.2 : 0, 0),
                duration: JmMotion.micro,
                child: Icon(trailing, size: iconSize, color: fg),
              ),
            ],
          ],
        );

        return AnimatedContainer(
          duration: JmMotion.micro,
          curve: JmMotion.ease,
          height: height,
          constraints: BoxConstraints(minWidth: height),
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient,
            borderRadius: JmRadius.buttonAll,
            border: border == null ? null : Border.all(color: border),
            boxShadow: variant == JmButtonVariant.primary && enabled
                ? (s.hovered ? jm.shadowPrimary : null)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: loading ? 0 : 1, child: content),
              if (loading)
                SizedBox.square(
                  dimension: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: fg,
                    semanticsLabel: 'Loading',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  (Color bg, Color fg, Color? border) _colors(JmPalette jm, JmPressState s) {
    final enabled = onPressed != null || loading;
    if (!enabled) {
      return switch (variant) {
        JmButtonVariant.ghost => (Colors.transparent, jm.textSubtle, null),
        _ => (jm.surfaceSunken, jm.textSubtle, null),
      };
    }
    final active = s.hovered || s.pressed;
    return switch (variant) {
      JmButtonVariant.primary => (
        s.pressed ? jm.primaryHover : jm.primary,
        jm.onPrimary,
        null,
      ),
      JmButtonVariant.accent => (
        active ? Color.lerp(jm.accent, Colors.white, 0.15)! : jm.accent,
        jm.onAccent,
        null,
      ),
      JmButtonVariant.secondary => (
        active ? jm.surfaceAlt : jm.surface,
        jm.text,
        active ? jm.borderStrong : jm.border,
      ),
      JmButtonVariant.ghost => (
        active ? jm.primarySoft : Colors.transparent,
        jm.isDark ? jm.primary : jm.onPrimarySoft,
        null,
      ),
      JmButtonVariant.destructive => (
        active ? Color.lerp(jm.error, Colors.black, 0.12)! : jm.error,
        jm.isDark ? JmBrand.ink : Colors.white,
        null,
      ),
    };
  }
}

/// Square icon-only button with a required accessible label.
class JmIconButton extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = JmSpace.minTouch,
    this.color,
    this.filled = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return JmPressable(
      onTap: onPressed,
      semanticLabel: label,
      tooltip: label,
      builder: (context, s) => AnimatedContainer(
        duration: JmMotion.micro,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: s.hovered || s.pressed
              ? jm.surfaceSunken
              : (filled ? jm.surfaceAlt : Colors.transparent),
          borderRadius: JmRadius.buttonAll,
        ),
        child: Icon(icon, size: 20, color: color ?? jm.textMuted),
      ),
    );
  }
}
