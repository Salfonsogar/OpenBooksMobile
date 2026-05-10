import 'package:flutter/material.dart';

import '../../data/models/index.dart';
import '../pages/book_detail_dialogs.dart';

class BookDescriptionWidget extends StatelessWidget {
  final LibroDetalle libro;
  final double maxWidth;

  const BookDescriptionWidget({
    super.key,
    required this.libro,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final descripcion = libro.descripcion;
    final maxLines = 4;
    final textSpan = TextSpan(text: descripcion);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    final exceeded = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Descripción',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (exceeded)
              TextButton(
                onPressed: () => showDescripcionCompleta(context, descripcion),
                child: const Text('Ver más'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          descripcion,
          maxLines: exceeded ? maxLines : null,
          overflow: exceeded ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}