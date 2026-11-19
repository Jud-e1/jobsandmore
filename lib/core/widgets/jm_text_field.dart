import 'package:flutter/services.dart';
import 'package:jobsandmore/app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Labelled text input with helper and error text. The label sits above the
/// field (never a disappearing placeholder) for clarity and accessibility.
class JmTextField extends StatefulWidget {
  const new({
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.optional = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;

  /// Shows "(optional)" after the label.
  final bool optional;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  @override
  State<JmTextField> createState() => _JmTextFieldState();
}

class _JmTextFieldState extends State<JmTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final jm = context.jm;
    final type = context.type;

    var suffix = widget.suffix;
    if (widget.obscure) {
      suffix = IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
          size: 20,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            children: [
              if (widget.optional)
                TextSpan(
                  text: '  (optional)',
                  style: type.small.copyWith(color: jm.textSubtle),
                ),
            ],
          ),
          style: type.label.copyWith(color: jm.text),
        ),
        const SizedBox(height: JmSpace.x2),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: type.body.copyWith(color: jm.text),
          cursorColor: jm.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            helperMaxLines: 3,
            errorText: widget.errorText,
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
