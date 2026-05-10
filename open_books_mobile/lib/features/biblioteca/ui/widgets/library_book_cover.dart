import 'dart:convert';

import 'package:flutter/material.dart';

class LibraryBookCover extends StatelessWidget {
  final String? portadaBase64;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LibraryBookCover({
    super.key,
    this.portadaBase64,
    this.width = 80,
    this.height = 120,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);
    
    return ClipRRect(
      borderRadius: radius,
      child: portadaBase64 != null && portadaBase64!.isNotEmpty
          ? Image.memory(
              base64Decode(portadaBase64!),
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(context),
            )
          : _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}