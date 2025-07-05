import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/themes/app_colors.dart';

class PinInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isVisible;
  final Function(String)? onChanged;
  final Function()? onToggleVisibility;
  final Function(String)? onSubmitted;
  final String? error;

  const PinInput({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.isVisible = false,
    this.onChanged,
    this.onToggleVisibility,
    this.onSubmitted,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isVisible,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Allow only alphanumeric characters (letters and numbers)
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (value) {
            debugPrint('📝 PIN input changed: ${value.length} characters');
            onChanged?.call(value);
          },
          onSubmitted: (value) {
            debugPrint('📝 PIN input submitted: ${value.length} characters');
            onSubmitted?.call(value);
          },
          style: TextStyle(
            fontSize: mediaQueryWidth * 0.045,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: mediaQueryWidth * 0.035,
              color: AppColors.textSecondary,
            ),
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: onToggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
} 