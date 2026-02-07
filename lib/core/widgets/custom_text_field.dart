import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final TextDirection? textDirection;
  final String? hint;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.textDirection,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      textDirection: textDirection,
      style: const TextStyle(
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppTheme.primaryColor,
              )
            : null,
        suffixIcon: suffixIcon,
        
        // Border when enabled
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        
        // Border when focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        
        // Border when error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 1.5,
          ),
        ),
        
        // Border when error and focused
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.errorColor,
            width: 2,
          ),
        ),
        
        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        
        // Fill
        filled: true,
        fillColor: enabled ? Colors.white : AppTheme.surfaceColor,
        
        // Content padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        
        // Label style
        labelStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        
        // Hint style
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        
        // Error style
        errorStyle: const TextStyle(
          color: AppTheme.errorColor,
          fontSize: 12,
        ),
      ),
      validator: validator,
    );
  }
}
