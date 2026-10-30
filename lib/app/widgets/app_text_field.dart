import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_context.dart';
import 'typed_hint.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.leadingIcon,
    this.exampleHint,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
    this.onEditingComplete,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData leadingIcon;
  final String? exampleHint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  TypedHintController? _typedHint;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    if (widget.exampleHint != null) {
      _typedHint = TypedHintController(
        fullText: widget.exampleHint!,
        onUpdate: () {
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void deactivate() {
    _typedHint?.onFocus(false, reduceMotion: true);
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    _typedHint?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _typedHint?.onFocus(_focusNode.hasFocus, reduceMotion: reduceMotion);
    if (!_focusNode.hasFocus) {
      setState(() => _touched = true);
    }
    setState(() {});
  }

  void _onTextChange() {
    if (widget.controller.text.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final focused = _focusNode.hasFocus;
    final iconColor = focused ? scheme.primary : scheme.onSurfaceVariant;

    final showTypedHint = widget.exampleHint != null &&
        focused &&
        widget.controller.text.isEmpty &&
        (_typedHint?.visible.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          autocorrect: widget.autocorrect,
          textCapitalization: widget.textCapitalization,
          autovalidateMode: _touched
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          onEditingComplete: widget.onEditingComplete,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.leadingIcon, color: iconColor),
            hintText: showTypedHint ? null : widget.exampleHint,
          ),
        ),
        if (showTypedHint)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md + 28,
              top: AppSpacing.xxs,
            ),
            child: ExcludeSemantics(
              child: Text(
                _typedHint!.visible,
                style: context.text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    required this.obscured,
    required this.onToggleVisibility,
    this.exampleHint,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool obscured;
  final VoidCallback onToggleVisibility;
  final String? exampleHint;
  final bool enabled;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final _focusNode = FocusNode();
  TypedHintController? _typedHint;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    if (widget.exampleHint != null) {
      _typedHint = TypedHintController(
        fullText: widget.exampleHint!,
        onUpdate: () {
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void deactivate() {
    _typedHint?.onFocus(false, reduceMotion: true);
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _typedHint?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _typedHint?.onFocus(_focusNode.hasFocus, reduceMotion: reduceMotion);
    if (!_focusNode.hasFocus) {
      setState(() => _touched = true);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final focused = _focusNode.hasFocus;
    final iconColor = focused ? scheme.primary : scheme.onSurfaceVariant;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      obscureText: widget.obscured,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: _touched
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(Icons.lock_outline_rounded, color: iconColor),
        suffixIcon: IconButton(
          onPressed: widget.enabled ? widget.onToggleVisibility : null,
          tooltip: widget.obscured ? 'Show password' : 'Hide password',
          icon: Icon(
            widget.obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
