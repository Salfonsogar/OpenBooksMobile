import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

bool descriptionExceedsLines({
  required String descripcion,
  required int maxLines,
  required double maxWidth,
}) {
  final textSpan = TextSpan(text: descripcion);
  final textPainter = TextPainter(
    text: textSpan,
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: maxWidth);
  return textPainter.didExceedMaxLines;
}