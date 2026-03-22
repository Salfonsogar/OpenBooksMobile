import 'package:flutter/material.dart';

import '../../data/models/admin_sugerencia.dart';

class SugerenciaDeleteDialog extends StatefulWidget {
  final AdminSugerencia sugerencia;
  final Future<bool> Function() onConfirm;

  const SugerenciaDeleteDialog({
    super.key,
    required this.sugerencia,
    required this.onConfirm,
  });

  @override
  State<SugerenciaDeleteDialog> createState() => _SugerenciaDeleteDialogState();
}

class _SugerenciaDeleteDialogState extends State<SugerenciaDeleteDialog> {
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
      title: const Text('Eliminar Sugerencia'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de eliminar esta sugerencia?'),
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
