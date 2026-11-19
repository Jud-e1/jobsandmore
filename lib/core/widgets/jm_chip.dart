import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:jobsandmore/core/widgets/jm_pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Static chip for tags such as job type or skills. Optionally removable.
class JmChip extends StatelessWidget {
  const new({
    required this.label,
    this.icon,
    this.onRemove,
    this.tone = JmTone.neutral,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onRemove;
  final JmTone tone;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final fg = tone == JmTone.neutral ? jm.textMuted : jm.toneFg(tone);
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: EdgeInsets.only(left: 10, right: onRemove == null ? 10 : 4),
      decoration: BoxDecoration(
        color: jm.toneBg(tone),
        borderRadius: JmRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: context.type.small.copyWith(color: fg)),
          if (onRemove != null)
            JmPressable(
              onTap: onRemove,
              semanticLabel: 'Remove $label',
              builder: (context, s) => Container(
                margin: const EdgeInsets.only(left: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.hovered ? jm.border : Colors.transparent,
                ),
                child: Icon(PhosphorIconsBold.x, size: 12, color: fg),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selectable filter chip with an animated check and an optional count.
class JmFilterChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onChanged,
    this.count,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final int? count;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;
    return JmPressable(
      onTap: onChanged == null ? null : () => onChanged!(!selected),
      selected: selected,
      semanticLabel: count == null ? label : '$label, $count results',
      builder: (context, s) {
        final fg = selected ? jm.onPrimarySoft : jm.text;
        return AnimatedContainer(
          duration: JmMotion.micro,
          curve: JmMotion.ease,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? jm.primarySoft
                : (s.hovered ? jm.surfaceAlt : jm.surface),
            borderRadius: JmRadius.pill,
            border: Border.all(
              color: selected
                  ? jm.primary.withValues(alpha: 0.6)
                  : (s.hovered ? jm.borderStrong : jm.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: JmMotion.micro,
                curve: JmMotion.ease,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          PhosphorIconsBold.check,
                          size: 14,
                          color: fg,
                        ),
                      )
                    : (icon == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(icon, size: 14, color: jm.textMuted),
                            )),
              ),
              Text(
                label,
                style: type.label.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: type.caption.copyWith(
                    color: selected ? fg : jm.textSubtle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
