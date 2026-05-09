import 'package:flutter/material.dart';

class BookDetailStars extends StatelessWidget {
  final int currentRating;
  final int promedioValoraciones;
  final ValueChanged<int>? onRatingTap;

  const BookDetailStars({
    super.key,
    required this.currentRating,
    required this.promedioValoraciones,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Valoración',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isFilled = index < currentRating || index < promedioValoraciones.round();
            return GestureDetector(
              onTap: onRatingTap != null ? () => onRatingTap!(index + 1) : null,
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: Colors.amber[700],
                size: 32,
              ),
            );
          }),
        ),
      ],
    );
  }
}