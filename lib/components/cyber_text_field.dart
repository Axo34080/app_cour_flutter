import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TextFormField cyberpunk réutilisable.
///
/// Usage minimal :
/// ```dart
/// CyberTextField(label: 'Email', controller: _ctrl)
/// ```
class CyberTextField extends StatefulWidget {
  const CyberTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.maxLines = 1,
    this.accentColor = AppColors.neonCyan,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final int maxLines;

  /// Couleur d'accentuation (border + icône au focus). Défaut : neonCyan.
  final Color accentColor;

  @override
  State<CyberTextField> createState() => _CyberTextFieldState();
}

class _CyberTextFieldState extends State<CyberTextField> {
  bool _obscured = false;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() => _hasFocus = _focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final borderColor = _hasFocus ? accent : accent.withValues(alpha: 0.3);
    final borderWidth = _hasFocus ? 1.5 : 1.0;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(
          color: _hasFocus ? accent : AppColors.textPrimary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: AppColors.textPrimary.withValues(alpha: 0.3),
          fontSize: 14,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: _hasFocus ? accent : AppColors.textPrimary.withValues(alpha: 0.4),
                size: 20,
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textPrimary.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonPink, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonPink, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        errorStyle: const TextStyle(color: AppColors.neonPink, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
