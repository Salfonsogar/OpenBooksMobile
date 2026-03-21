import 'package:flutter/material.dart';

import '../../data/models/admin_rol.dart';

class RolFormDialog extends StatefulWidget {
  final AdminRol? rol;
  final Future<bool> Function(dynamic request) onSave;

  const RolFormDialog({
    super.key,
    this.rol,
    required this.onSave,
  });

  @override
  State<RolFormDialog> createState() => _RolFormDialogState();
}

class _RolFormDialogState extends State<RolFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  bool _isLoading = false;

  bool get isEditing => widget.rol != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.rol?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;
    if (isEditing) {
      final request = UpdateRolRequest(nombre: _nombreController.text);
      success = await widget.onSave(request);
    } else {
      final request = CreateRolRequest(nombre: _nombreController.text);
      success = await widget.onSave(request);
    }

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
      title: Text(isEditing ? 'Editar Rol' : 'Nuevo Rol'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre del rol',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
