import 'package:flutter/material.dart';

import '../../data/models/index.dart';
import 'resena_card_widget.dart';

class BookReviewsSection extends StatelessWidget {
  final List<Resena> resenas;
  final int totalResenas;
  final VoidCallback onLoadMore;

  const BookReviewsSection({
    super.key,
    required this.resenas,
    required this.totalResenas,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reseñas ($totalResenas)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (resenas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No hay reseñas todavía',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...resenas.map((resena) => ResenaCardWidget(resena: resena)),
        if (resenas.length < totalResenas)
          Center(
            child: TextButton(
              onPressed: onLoadMore,
              child: const Text('Cargar más reseñas'),
            ),
          ),
      ],
    );
  }
}