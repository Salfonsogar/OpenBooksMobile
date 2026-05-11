import 'package:flutter/material.dart';

import '../../data/models/index.dart';

class BookStatsWidget extends StatelessWidget {
  final LibroDetalle libro;

  const BookStatsWidget({
    super.key,
    required this.libro,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.star,
              label: 'Valoración',
              value: libro.promedioValoraciones.toStringAsFixed(1),
            ),
            _buildStatItem(
              context,
              icon: Icons.rate_review,
              label: 'Reseñas',
              value: libro.totalResenas.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}