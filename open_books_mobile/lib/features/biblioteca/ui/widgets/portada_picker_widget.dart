import 'dart:convert';

import 'package:flutter/material.dart';

class PortadaPickerWidget extends StatelessWidget {
  final String? portadaBase64;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const PortadaPickerWidget({
    super.key,
    required this.portadaBase64,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPick,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: portadaBase64 != null
            ? Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(portadaBase64!),
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: onClear,
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'Toca para seleccionar imagen',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
