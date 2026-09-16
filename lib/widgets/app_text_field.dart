import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded pill text field matching the Figma inputs (dark fill, muted hint,
/// optional trailing password visibility toggle).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.autofillHints,
  });

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final List<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      style: Theme.of(context)
          .textTheme
          .bodyLarge
          ?.copyWith(color: AppColors.textPrimary),
      cursorColor: AppColors.copper,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: AppColors.hint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.copper.withOpacity(0.6)),
        errorBorder: _border(color: AppColors.accentRed),
        focusedErrorBorder: _border(color: AppColors.accentRed),
        errorStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.accentRed),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.hint,
                  size: 22,
                ),
              )
            : null,
      ),
    );
  }

  OutlineInputBorder _border({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}
