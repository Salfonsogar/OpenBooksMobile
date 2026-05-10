import 'package:flutter/material.dart';

class UploadFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextStyle? style;
  final int? maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const UploadFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.style,
    this.maxLines,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      style: style ?? TextStyle(color: colorScheme.onSurface),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        errorStyle: TextStyle(color: colorScheme.error),
        fillColor: colorScheme.surfaceContainerHighest,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
