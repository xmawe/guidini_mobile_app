import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// A helper function to create consistent InputDecoration
InputDecoration customInputDecoration({
  required String label,
  Icon? prefixIcon,
  String? hint,
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppColors.gray300, // Hint text color
    ),
    labelStyle: const TextStyle(
      color: AppColors.gray600, // Label color (unfocused)
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.gray600, // Label color (focused)
      fontWeight: FontWeight.w600,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.gray100, // Border color (unfocused)
        width: 1,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary700,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.primary800, // Border color (focused)
        width: 2.0,
      ),
    ),
  );
}

/// A reusable TextField widget
class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final Icon? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController controller; // <-- now required
  final TextInputType? keyboardType;
  final String? errorText;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller, // <-- required
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: customInputDecoration(
        label: label,
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}
