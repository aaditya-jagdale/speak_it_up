import 'package:flutter/material.dart';
import 'package:speak_it_up/shared/widgets/colors.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String? hint;
  final bool isPassword;
  final bool enabled;
  final String? errorText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final Function()? onTap;
  final Function(String)? onChanged;
  final bool autoFocus;

  const CustomTextField({
    super.key,
    this.title = '',
    this.hint,
    this.controller,
    this.isPassword = false,
    this.enabled = true,
    this.errorText,
    this.keyboardType,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onTap: onTap,
      onChanged: onChanged,
      enabled: enabled,
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        counterText: '',
        errorText: errorText,
        hintText: hint,
        label: title.isNotEmpty ? Text(title) : null,
        fillColor: Colors.white,
        filled: true,
        hintStyle: const TextStyle(
          color: AppColors.black50,
          fontWeight: FontWeight.normal,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0XFFD4D4D4)),
        ),
      ),
    );
  }
}
