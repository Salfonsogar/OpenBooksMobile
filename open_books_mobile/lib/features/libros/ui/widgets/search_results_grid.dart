import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';
import 'libro_card.dart';

class SearchResultsGrid extends StatelessWidget {
  final List<Libro> libros;

  const SearchResultsGrid({
    super.key,
    required this.libros,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: libros.length,
      itemBuilder: (context, index) {
        final libro = libros[index];
        return LibroCard(
          libro: libro,
          onTap: () => context.pushReplacement('/book/${libro.id}'),
        );
      },
    );
  }
}