import 'package:flutter/material.dart';

import '../../data/models/admin_libro.dart';

class LibroDeleteDialog extends StatefulWidget {
  final AdminLibro libro;
  final Future<bool> Function() onConfirm;

  const LibroDeleteDialog({
    super.key,
    required this.libro,
    required this.onConfirm,
  });

  @override
  State<LibroDeleteDialog> createState() => _LibroDeleteDialogState();
}

class _LibroDeleteDialogState extends State<LibroDeleteDialog> {
  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() => _isLoading = true);

    final success = await widget.onConfirm();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar Libro'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar "${widget.libro.titulo}"?'),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _delete,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Eliminar'),
        ),
      ],
    );
  }
}
