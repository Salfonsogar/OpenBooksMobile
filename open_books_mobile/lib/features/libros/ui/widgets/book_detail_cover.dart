import 'dart:convert';
import 'package:flutter/material.dart';

class BookDetailCover extends StatelessWidget {
  final String? portadaBase64;
  final double width;
  final double height;

  const BookDetailCover({
    super.key,
    this.portadaBase64,
    this.width = 120,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (portadaBase64 == null || portadaBase64!.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Icon(Icons.menu_book, size: 60)),
      );
    }

    try {
      final bytes = base64Decode(portadaBase64!);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: Icon(Icons.menu_book, size: 60)),
          );
        },
      );
    } catch (e) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(child: Icon(Icons.menu_book, size: 60)),
      );
    }
  }
}