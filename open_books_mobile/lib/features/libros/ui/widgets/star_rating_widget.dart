import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final double promedioValoraciones;
  final Function(int) onRatingSelected;

  const StarRatingWidget({
    super.key,
    required this.promedioValoraciones,
    required this.onRatingSelected,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _puntuacionSeleccionada = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Valoración',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _puntuacionSeleccionada = index + 1;
                });
                widget.onRatingSelected(index + 1);
              },
              child: Icon(
                index < _puntuacionSeleccionada ||
                        index < widget.promedioValoraciones.round()
                    ? Icons.star
                    : Icons.star_border,
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