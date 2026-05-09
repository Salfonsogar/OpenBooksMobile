import 'package:flutter/material.dart';

class BookDetailStats extends StatelessWidget {
  final int vecesValorado;
  final int cantidadResenas;
  final int cantidadEnBiblioteca;

  const BookDetailStats({
    super.key,
    required this.vecesValorado,
    required this.cantidadResenas,
    required this.cantidadEnBiblioteca,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, '$vecesValorado', 'valoraciones'),
            _buildStatItem(context, '$cantidadResenas', 'reseñas'),
            _buildStatItem(context, '$cantidadEnBiblioteca', 'en biblioteca'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}