import 'package:flutter/material.dart';

import '../../../usuarios/data/models/admin_usuario.dart';

class UsuarioDeleteDialog extends StatefulWidget {
  final AdminUsuario usuario;
  final Future<bool> Function() onConfirm;

  const UsuarioDeleteDialog({
    super.key,
    required this.usuario,
    required this.onConfirm,
  });

  @override
  State<UsuarioDeleteDialog> createState() => _UsuarioDeleteDialogState();
}

class _UsuarioDeleteDialogState extends State<UsuarioDeleteDialog> {
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
      title: const Text('Eliminar Usuario'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar al usuario "${widget.usuario.nombreCompleto}"?'),
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
