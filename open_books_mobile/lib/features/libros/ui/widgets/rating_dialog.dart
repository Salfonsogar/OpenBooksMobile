import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final int libroId;
  final Function(int) onRate;

  const RatingDialog({
    super.key,
    required this.libroId,
    required this.onRate,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Valorar libro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('¿Cómo calificarías este libro?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: Icon(
                  starValue <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber[700],
                  size: 40,
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _rating > 0
              ? () {
                  widget.onRate(_rating);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
