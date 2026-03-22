import 'package:flutter/material.dart';

import '../../data/models/admin_categoria.dart';

class CategoriaDeleteDialog extends StatefulWidget {
  final AdminCategoria categoria;
  final Future<bool> Function() onConfirm;

  const CategoriaDeleteDialog({
    super.key,
    required this.categoria,
    required this.onConfirm,
  });

  @override
  State<CategoriaDeleteDialog> createState() => _CategoriaDeleteDialogState();
}

class _CategoriaDeleteDialogState extends State<CategoriaDeleteDialog> {
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
      title: const Text('Eliminar Categoría'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar la categoría "${widget.categoria.nombre}"?'),
            if (widget.categoria.cantidadLibros > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta categoría tiene ${widget.categoria.cantidadLibros} libro(s) asociado(s).',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
