import 'package:flutter/material.dart';

import '../../logic/cubit/libros_cubit.dart';
import 'libro_card.dart';

class HomeGridView extends StatelessWidget {
  final LibrosLoaded state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(int) onLibroTap;

  const HomeGridView({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onLibroTap,
  });

  @override
  Widget build(BuildContext context) {
    if (state.libros.isEmpty) {
      return const Center(
        child: Text('No se encontraron libros'),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.libros.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.libros.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final libro = state.libros[index];
          return LibroCard(
            libro: libro,
            onTap: () => onLibroTap(libro.id),
          );
        },
      ),
    );
  }
}