import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';
import 'libro_card.dart';

class HomeSeccionWidget extends StatelessWidget {
  final String titulo;
  final List<Libro> libros;
  final void Function(Libro) onLibroTap;

  const HomeSeccionWidget({
    super.key,
    required this.titulo,
    required this.libros,
    required this.onLibroTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            titulo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: Scrollbar(
            thumbVisibility: false,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: libros.length,
              itemBuilder: (context, index) {
                final libro = libros[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: LibroCard(
                    libro: libro,
                    onTap: () => onLibroTap(libro),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}