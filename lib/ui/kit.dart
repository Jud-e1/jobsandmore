import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/responsive/breakpoints.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';

export 'package:jobsandmore/ui/media.dart';

/// Building blocks that reproduce the approved UI design
/// ("JobsAndMoreng.com – Web & Mobile UI/UX"). Colours come from the theme
/// so dark mode keeps working; the extra tints below are design-only.
abstract final class DTint {
  static Color green(BuildContext c) => c.jm.primarySoft;
  static Color amber(BuildContext c) => c.jm.accentSoft;
  static Color blue(BuildContext c) =>
      c.jm.isDark ? const Color(0xFF16233A) : const Color(0xFFE4ECF8);
  static Color purple(BuildContext c) =>
      c.jm.isDark ? const Color(0xFF2A1C33) : const Color(0xFFF3E8F7);
  static Color blueText(BuildContext c) =>
      c.jm.isDark ? const Color(0xFF9BB9EE) : const Color(0xFF1F4E99);
  static Color purpleText(BuildContext c) =>
      c.jm.isDark ? const Color(0xFFD9B8E8) : const Color(0xFF6B2E83);

  /// Hero / dark panel green and the ink used by dark sections.
  static const Color forest = JmBrand.forest;
  static const Color ink = JmBrand.ink;
  static const onDarkMuted = Color(0xFFD6E8DE);
  static const footerMuted = Color(0xFFC8D2CC);
}

/// Max-width content column with the design's 24px gutters.
class DContainer extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth + 48),
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// White bordered card (radius 16, 1px border).
class DCard extends StatelessWidget {
  const new({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
    this.borderColor,
    this.radius = 22,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    Widget box(bool hover) => AnimatedContainer(
      duration: JmMotion.micro,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? jm.surface,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == Colors.transparent
            ? null
            : Border.all(
                color: hover ? jm.borderStrong : (borderColor ?? jm.border),
              ),
        boxShadow: hover ? jm.shadowLg : jm.shadowSm,
      ),
      // Own (transparent) Material so list tiles and ink ripples inside the
      // card paint above its background.
      child: Material(type: MaterialType.transparency, child: child),
    );
    if (onTap == null) return box(false);
    return JmPressable(
      onTap: onTap,
      scaleOnPress: false,
      semanticLabel: semanticLabel,
      focusRadius: BorderRadius.circular(radius),
      builder: (context, s) => box(s.hovered),
    );
  }
}

/// Small rounded label.
class DPill extends StatelessWidget {
  const new(
    this.text, {
    this.bg,
    this.fg,
    this.icon,
    this.radius = 999,
    this.fontSize = 12,
    this.bold = true,
    super.key,
  });

  final String text;
  final Color? bg;
  final Color? fg;
  final IconData? icon;
  final double radius;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final color = fg ?? jm.onPrimarySoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? jm.primarySoft,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: context.type.caption.copyWith(
                color: color,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "✓ Verified employer" style pill. The label is always the precise level.
class DVerifiedPill extends StatelessWidget {
  const new(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) =>
      DPill(label, icon: Icons.check_rounded, fontSize: 12);
}

/// Grey info tag ("Lagos · Hybrid").
class DTag extends StatelessWidget {
  const new(this.text, {this.bg, super.key});

  final String text;
  final Color? bg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg ?? context.jm.surfaceAlt,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: context.type.caption.copyWith(color: context.jm.text),
    ),
  );
}

/// Initials logo tile ("KL").
class DInitials extends StatelessWidget {
  const new(
    this.initials, {
    this.size = 44,
    this.bg,
    this.fg,
    this.circle = false,
    super.key,
  });

  final String initials;
  final double size;
  final Color? bg;
  final Color? fg;
  final bool circle;

  @override
  Widget build(BuildContext context) => Semantics(
    excludeSemantics: true,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg ?? context.jm.surfaceAlt,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.23),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Text(
        initials,
        style: context.type.label.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
          color: fg ?? context.jm.onPrimarySoft,
        ),
      ),
    ),
  );
}

/// Soft square icon tile used on cards ("48px, radius 12").
class DIconTile extends StatelessWidget {
  const new(this.icon, {this.bg, this.fg, this.size = 48, super.key});

  final IconData icon;
  final Color? bg;
  final Color? fg;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg ?? context.jm.primarySoft,
      borderRadius: BorderRadius.circular(size / 4),
    ),
    child: Icon(icon, size: size / 2, color: fg ?? context.jm.primary),
  );
}

enum DBtnStyle {
  primary,
  amber,
  white,
  outlineLight,
  dark,
  secondary,
  ghost,
  danger,
}

/// The design's buttons (radius 10, bold label, 44–52px tall).
class DBtn extends StatelessWidget {
  const new(
    this.label, {
    required this.onTap,
    this.style = DBtnStyle.primary,
    this.icon,
    this.trailing,
    this.expand = false,
    this.height = 48,
    this.fontSize = 15,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final DBtnStyle style;
  final IconData? icon;
  final IconData? trailing;
  final bool expand;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final (bg, fg, border) = switch (style) {
      DBtnStyle.primary => (jm.primary, jm.onPrimary, null),
      DBtnStyle.amber => (JmBrand.amber, JmBrand.ink, null),
      DBtnStyle.white => (Colors.white, JmBrand.forest, null),
      DBtnStyle.outlineLight => (
        Colors.transparent,
        Colors.white,
        Colors.white.withValues(alpha: 0.6),
      ),
      DBtnStyle.dark => (
        jm.isDark ? jm.surfaceAlt : JmBrand.ink,
        Colors.white,
        null,
      ),
      DBtnStyle.secondary => (jm.surface, jm.text, jm.borderStrong),
      DBtnStyle.ghost => (Colors.transparent, jm.text, null),
      DBtnStyle.danger => (jm.surface, jm.error, jm.error),
    };
    final disabled = onTap == null;
    return JmPressable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, s) => AnimatedContainer(
        duration: JmMotion.micro,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: height * 0.45),
        decoration: BoxDecoration(
          color: disabled
              ? jm.surfaceSunken
              : (s.hovered && style == DBtnStyle.primary
                    ? jm.primaryHover
                    : (s.hovered && style == DBtnStyle.ghost
                          ? jm.surfaceAlt
                          : bg)),
          borderRadius: BorderRadius.circular(999),
          border: border == null ? null : Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: disabled ? jm.textSubtle : fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.label.copyWith(
                  color: disabled ? jm.textSubtle : fg,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 18, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bold green text link, optionally with an arrow ("View all jobs →").
class DLink extends StatelessWidget {
  const new(
    this.label, {
    required this.onTap,
    this.arrow = false,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool arrow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c =
        color ?? (context.jm.isDark ? context.jm.primary : context.jm.primary);
    return JmPressable(
      onTap: onTap,
      isButton: false,
      semanticLabel: label,
      scaleOnPress: false,
      focusRadius: BorderRadius.circular(6),
      builder: (context, s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          arrow ? '$label →' : label,
          style: context.type.label.copyWith(
            color: c,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            decoration: s.hovered ? TextDecoration.underline : null,
            decorationColor: c,
          ),
        ),
      ),
    );
  }
}

/// Section heading: H2 + supporting line, optional trailing link.
class DSectionHead extends StatelessWidget {
  const new(
    this.title, {
    this.subtitle,
    this.action,
    this.onAction,
    this.eyebrow,
    this.size = 36,
    this.center = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;
  final String? eyebrow;
  final double size;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final compact = context.screenSize.isMobile;
    final left = Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[
          DEyebrow(eyebrow!),
          const SizedBox(height: 10),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: type.h2.copyWith(fontSize: compact ? size * 0.78 : size),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: type.body.copyWith(
              color: context.jm.textMuted,
              fontSize: 17,
            ),
          ),
        ],
      ],
    );
    if (action == null || onAction == null) return left;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 12,
      spacing: 16,
      children: [
        left,
        DLink(action!, onTap: onAction!, arrow: true),
      ],
    );
  }
}

/// Uppercase green label above headings ("AI CAREER TOOLS").
class DEyebrow extends StatelessWidget {
  const new(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.type.caption.copyWith(
      color: color ?? context.jm.primary,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      letterSpacing: 0.8,
    ),
  );
}

/// Coloured notice strip (status, tips, "get these jobs by email").
class DNotice extends StatelessWidget {
  const new({
    required this.child,
    this.bg,
    this.border,
    this.icon,
    this.iconColor,
    this.trailing,
    super.key,
  });

  final Widget child;
  final Color? bg;
  final Color? border;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: bg ?? context.jm.primarySoft,
      borderRadius: BorderRadius.circular(12),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: iconColor ?? context.jm.onPrimarySoft,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: DefaultTextStyle.merge(
                style: context.type.body.copyWith(fontSize: 15),
                child: child,
              ),
            ),
          ],
        ),
        ?trailing,
      ],
    ),
  );
}

/// Labelled input in the design's style (label 14/600, field 48px, radius 10).
class DField extends StatelessWidget {
  const new({
    required this.label,
    this.hint,
    this.initial,
    this.controller,
    this.optional,
    this.helper,
    this.error,
    this.success,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
    this.onChanged,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final String label;
  final String? hint;
  final String? initial;
  final TextEditingController? controller;

  /// e.g. "(optional)" shown after the label in muted text.
  final String? optional;
  final String? helper;
  final String? error;
  final String? success;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final borderColor = error != null
        ? jm.error
        : (success != null ? jm.primary : jm.borderStrong);
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    final field = TextFormField(
      controller: controller,
      initialValue: controller == null ? initial : null,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      validator: validator,
      autofillHints: autofillHints,
      style: type.body.copyWith(color: jm.text),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 13,
        ),
        enabledBorder: b(
          borderColor,
          error != null || success != null ? 1.5 : 1,
        ),
        border: b(borderColor),
        focusedBorder: b(jm.primary, 2),
        errorBorder: b(jm.error, 1.5),
        focusedErrorBorder: b(jm.error, 2),
        fillColor: jm.isDark ? jm.surfaceSunken : jm.surface,
        filled: true,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (optional != null)
                TextSpan(
                  text: ' $optional',
                  style: type.small.copyWith(
                    color: jm.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          style: type.label.copyWith(color: jm.text),
        ),
        const SizedBox(height: 6),
        if (prefix != null)
          Row(
            children: [
              prefix!,
              const SizedBox(width: 8),
              Expanded(child: field),
            ],
          )
        else
          field,
        if (error != null || success != null || helper != null) ...[
          const SizedBox(height: 6),
          Text(
            error ?? (success != null ? '✓ $success' : helper!),
            style: type.small.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: error != null
                  ? jm.error
                  : (success != null ? jm.onPrimarySoft : jm.textMuted),
            ),
          ),
        ],
      ],
    );
  }
}

/// Labelled dropdown in the design's style.
class DSelect<T> extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.optional,
    this.itemLabel,
    this.height = 48,
    this.showLabel = true,
    super.key,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String? optional;
  final String Function(T)? itemLabel;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    final box = Semantics(
      label: label,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: jm.isDark ? jm.surfaceSunken : jm.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: jm.borderStrong),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: jm.surface,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: jm.textMuted),
            style: type.body.copyWith(color: jm.text, fontSize: 15),
            items: [
              for (final i in items)
                DropdownMenuItem<T>(
                  value: i,
                  child: Text(
                    itemLabel?.call(i) ?? '$i',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
    if (!showLabel) return box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (optional != null)
                TextSpan(
                  text: ' $optional',
                  style: type.small.copyWith(
                    color: jm.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          style: type.label.copyWith(color: jm.text),
        ),
        const SizedBox(height: 6),
        box,
      ],
    );
  }
}

/// Selectable pill (radio or checkbox look from the design).
class DChoicePill extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return JmPressable(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      selected: selected,
      semanticLabel: label,
      focusRadius: BorderRadius.circular(999),
      builder: (context, s) => AnimatedContainer(
        duration: JmMotion.micro,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? jm.primarySoft
              : (s.hovered ? jm.surfaceAlt : jm.surface),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? jm.primary : jm.borderStrong,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              multi
                  ? (selected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded)
                  : (selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded),
              size: 18,
              color: selected ? jm.primary : jm.textMuted,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: context.type.label.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: jm.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox row with rich label (consents, filters).
class DCheck extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.label,
    this.trailing,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final String? trailing;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: DefaultTextStyle.merge(
                  style: context.type.small.copyWith(
                    color: context.jm.text,
                    fontSize: 14,
                  ),
                  child: label,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  trailing!,
                  style: context.type.small.copyWith(
                    color: context.jm.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// The onboarding progress bar: five segments with labels.
class DStepBar extends StatelessWidget {
  const new({required this.steps, required this.current, super.key});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return Semantics(
      label: 'Step ${current + 1} of ${steps.length}: ${steps[current]}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: JmMotion.standard,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= current ? jm.primary : jm.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!context.screenSize.isMobile)
                    Text(
                      '${i + 1} · ${steps[i]}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.caption.copyWith(
                        fontSize: 13,
                        fontWeight: i == current
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: i == current ? jm.onPrimarySoft : jm.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Underlined tab row (listing types, profile sections).
class DTabs extends StatelessWidget {
  const new({
    required this.tabs,
    required this.current,
    required this.onTap,
    super.key,
  });

  final List<String> tabs;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            JmPressable(
              onTap: () => onTap(i),
              selected: i == current,
              semanticLabel: tabs[i],
              scaleOnPress: false,
              builder: (context, s) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == current ? jm.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: context.type.label.copyWith(
                    fontSize: 15,
                    fontWeight: i == current
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: i == current ? jm.onPrimarySoft : jm.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Thin progress bar (profile completion, course progress).
class DBar extends StatelessWidget {
  const new(this.value, {this.color, this.height = 8, super.key});

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1),
      minHeight: height,
      backgroundColor: context.jm.border,
      color: color ?? context.jm.primary,
    ),
  );
}

/// Ring with a number in the middle ("74").
class DRing extends StatelessWidget {
  const new(
    this.value, {
    this.size = 52,
    this.stroke = 5,
    this.label,
    super.key,
  });

  final int value;
  final double size;
  final double stroke;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${label ?? 'Score'} $value out of 100',
    excludeSemantics: true,
    child: SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: JmMotion.of(context, const Duration(milliseconds: 900)),
              curve: JmMotion.emphasized,
              builder: (context, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: stroke,
                backgroundColor: context.jm.border,
                color: context.jm.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Text(
            '$value',
            style: context.type.label.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.3,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Dashed placeholder box (testimonials / partner logos awaiting consent).
class DDashedBox extends StatelessWidget {
  const new({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedRRect(context.jm.borderStrong),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedRRect extends CustomPainter {
  new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) => old.color != color;
}

/// Responsive two-pane layout: main + aside side by side on wide screens,
/// stacked on narrow ones (mirrors the design's flex-wrap rows).
class DSplit extends StatelessWidget {
  const new({
    required this.main,
    required this.aside,
    this.asideWidth = 340,
    this.gap = 28,
    this.breakpoint = 900,
    this.asideFirst = false,
    this.asideOnRight = true,
    super.key,
  });

  final Widget main;
  final Widget aside;
  final double asideWidth;
  final double gap;
  final double breakpoint;

  /// When stacked, show the aside above main.
  final bool asideFirst;
  final bool asideOnRight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth < breakpoint) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: asideFirst
              ? [aside, SizedBox(height: gap), main]
              : [main, SizedBox(height: gap), aside],
        );
      }
      final a = SizedBox(width: asideWidth, child: aside);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: asideOnRight
            ? [Expanded(child: main), SizedBox(width: gap), a]
            : [a, SizedBox(width: gap), Expanded(child: main)],
      );
    },
  );
}

/// Wrap-based responsive grid where every cell has the same width.
class DGrid extends StatelessWidget {
  const new({
    required this.children,
    this.minItemWidth = 260,
    this.gap = 16,
    this.maxColumns = 4,
    super.key,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double gap;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = ((c.maxWidth + gap) / (minItemWidth + gap)).floor().clamp(
        1,
        maxColumns,
      );
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    },
  );
}

/// Navigate helper used by design screens.
extension DNav on BuildContext {
  void to(String location) => GoRouter.of(this).go(location);
  void open(String location) => GoRouter.of(this).push(location);
}

/// Simple data table matching the design's HTML tables: header row, rows
/// with bottom borders, flex column widths. Fills the available width and
/// scrolls sideways only when narrower than [minWidth].
class DTable extends StatelessWidget {
  const new({
    required this.columns,
    required this.rows,
    this.minWidth = 640,
    this.selectedRow,
    this.onRowTap,
    super.key,
  });

  /// (label, flex) per column.
  final List<(String, int)> columns;
  final List<List<Widget>> rows;
  final double minWidth;
  final int? selectedRow;
  final ValueChanged<int>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    Widget line(List<Widget> cells, {bool header = false, int? index}) {
      final row = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: index != null && index == selectedRow ? jm.primarySoft : null,
          border: Border(bottom: BorderSide(color: jm.border)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              Expanded(
                flex: columns[i].$2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: i < cells.length ? cells[i] : const SizedBox(),
                  ),
                ),
              ),
          ],
        ),
      );
      if (index == null || onRowTap == null) return row;
      return Semantics(
        button: true,
        selected: index == selectedRow,
        child: InkWell(onTap: () => onRowTap!(index), child: row),
      );
    }

    Widget table(double w) => SizedBox(
      width: w,
      child: DefaultTextStyle.merge(
        style: type.small.copyWith(color: jm.text),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            line([
              for (final (label, _) in columns)
                Text(
                  label,
                  style: type.caption.copyWith(
                    color: jm.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ], header: true),
            for (final (i, r) in rows.indexed) line(r, index: i),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= minWidth) return table(c.maxWidth);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table(minWidth),
        );
      },
    );
  }
}
