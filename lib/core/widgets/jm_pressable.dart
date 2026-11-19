import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Interaction state passed to [JmPressable.builder].
@immutable
class JmPressState {
  const new({
    required this.hovered,
    required this.pressed,
    required this.focused,
    required this.enabled,
  });

  final bool hovered;
  final bool pressed;
  final bool focused;
  final bool enabled;
}

/// The single interaction primitive behind buttons, cards and chips.
///
/// Gives every tappable surface the same behaviour: pointer + keyboard
/// activation (Enter/Space), a visible focus ring for keyboard users, hover
/// state on web/desktop, a 0.97 press scale, optional haptics and correct
/// screen-reader semantics. Decorative motion is skipped under reduce-motion.
class JmPressable extends StatefulWidget {
  const new({
    required this.builder,
    required this.onTap,
    this.semanticLabel,
    this.tooltip,
    this.isButton = true,
    this.selected,
    this.scaleOnPress = true,
    this.haptic = false,
    this.focusRadius = JmRadius.buttonAll,
    this.cursor,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final Widget Function(BuildContext context, JmPressState state) builder;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? tooltip;
  final bool isButton;
  final bool? selected;
  final bool scaleOnPress;
  final bool haptic;
  final BorderRadius focusRadius;
  final MouseCursor? cursor;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<JmPressable> createState() => _JmPressableState();
}

class _JmPressableState extends State<JmPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  void _activate() {
    if (!_enabled) return;
    if (widget.haptic) unawaited(HapticFeedback.lightImpact());
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final reduce = context.reduceMotion;
    final state = JmPressState(
      hovered: _hovered && _enabled,
      pressed: _pressed && _enabled,
      focused: _focused,
      enabled: _enabled,
    );

    var child = widget.builder(context, state);

    if (widget.scaleOnPress && !reduce) {
      child = AnimatedScale(
        scale: state.pressed ? JmMotion.pressScale : 1,
        duration: JmMotion.micro,
        curve: JmMotion.ease,
        child: child,
      );
    }

    // passthrough: the pressable takes exactly the space its parent gives
    // (cards fill grid cells instead of shrinking to their content).
    child = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        child,
        if (_focused)
          Positioned(
            left: -3,
            top: -3,
            right: -3,
            bottom: -3,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: widget.focusRadius.add(
                    BorderRadius.circular(3),
                  ),
                  border: Border.all(color: jm.focus, width: 2),
                ),
              ),
            ),
          ),
      ],
    );

    child = FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: _enabled
          ? (widget.cursor ?? SystemMouseCursors.click)
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled ? _activate : null,
        child: child,
      ),
    );

    child = Semantics(
      button: widget.isButton,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      onTap: _enabled ? _activate : null,
      child: child,
    );

    if (widget.tooltip != null) {
      child = Tooltip(message: widget.tooltip, child: child);
    }
    return child;
  }
}
