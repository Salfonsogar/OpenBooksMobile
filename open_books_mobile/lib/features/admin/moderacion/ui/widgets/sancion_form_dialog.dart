import 'package:flutter/material.dart';

import '../../data/models/admin_sancion.dart';

class SancionFormDialog extends StatefulWidget {
  final AdminSancion? sancion;
  final Future<bool> Function(dynamic request) onSave;

  const SancionFormDialog({
    super.key,
    this.sancion,
    required this.onSave,
  });

  @override
  State<SancionFormDialog> createState() => _SancionFormDialogState();
}

class _SancionFormDialogState extends State<SancionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioIdController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipoSancion = 'Suspensión';
  DateTime? _fechaFin;
  bool _isLoading = false;

  bool get isEditing => widget.sancion != null;

  final List<String> _tiposSancion = [
    'Suspensión',
    'Advertencia',
    'Bloqueo temporal',
    'Bloqueo permanente',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _usuarioIdController.text = widget.sancion!.usuarioId.toString();
      _descripcionController.text = widget.sancion!.descripcion ?? '';
      _tipoSancion = widget.sancion!.tipoSancion;
      _fechaFin = widget.sancion!.fechaFin;
    }
  }

  @override
  void dispose() {
    _usuarioIdController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fechaFin = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final usuarioId = int.tryParse(_usuarioIdController.text);
    if (usuarioId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de usuario inválido')),
        );
      }
      return;
    }

    dynamic request;
    if (isEditing) {
      request = UpdateSancionRequest(
        tipoSancion: _tipoSancion,
        descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        fechaFin: _fechaFin,
        activa: widget.sancion!.activa,
      );
    } else {
      request = CreateSancionRequest(
        usuarioId: usuarioId,
        tipoSancion: _tipoSancion,
        descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        fechaFin: _fechaFin,
      );
    }

    final success = await widget.onSave(request);

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
      title: Text(isEditing ? 'Editar Sanción' : 'Nueva Sanción'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing)
                TextFormField(
                  controller: _usuarioIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID de Usuario',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El ID de usuario es requerido';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
              if (!isEditing) const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSancion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Sanción',
                  border: OutlineInputBorder(),
                ),
                items: _tiposSancion.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoSancion = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Fin (opcional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _fechaFin != null
                        ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                        : 'Sin fecha de fin',
                  ),
                ),
              ),
            ],
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
