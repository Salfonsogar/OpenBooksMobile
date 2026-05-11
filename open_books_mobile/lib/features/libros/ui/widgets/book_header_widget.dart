import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';

class BookHeaderWidget extends StatelessWidget {
  final LibroDetalle libro;

  const BookHeaderWidget({
    super.key,
    required this.libro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 180,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _buildPortadaImage(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libro.titulo,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                libro.autor,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (libro.categorias.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  libro.categorias.first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              _buildRating(context),
              const SizedBox(height: 8),
              _buildCategoryChips(context),
              const SizedBox(height: 12),
              _buildAutorLink(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortadaImage(BuildContext context) {
    if (libro.portadaUrl == null || libro.portadaUrl!.isEmpty) {
      return const Center(child: Icon(Icons.menu_book, size: 60));
    }

    return Image.network(
      libro.portadaUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.menu_book, size: 60));
      },
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber[700], size: 20),
        const SizedBox(width: 4),
        Text(
          '${libro.promedioValoraciones.toStringAsFixed(1)} (${libro.cantidadValoraciones})',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    if (libro.categorias.length <= 1) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: libro.categorias
          .take(3)
          .map(
            (c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }

  Widget _buildAutorLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/search?autor=${Uri.encodeComponent(libro.autor)}',
        );
      },
      child: Text(
        'Más de este autor',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}