import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInput extends StatelessWidget {
  final String label;
  final String? error;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextEditingController? controller;

  const PinInput({
    super.key,
    required this.label,
    this.error,
    required this.onChanged,
    this.obscureText = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: textScaler.scale(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: size.height * 0.01),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.02,
            ),
          ),
        ),
      ],
    );
  }
} 