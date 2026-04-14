import 'package:flutter/material.dart';

import '../../data/models/models.dart';

class DenunciaResenaDialog extends StatefulWidget {
  final Resena resena;
  final Function(String motivo, String? comentario) onSubmit;

  const DenunciaResenaDialog({
    super.key,
    required this.resena,
    required this.onSubmit,
  });

  @override
  State<DenunciaResenaDialog> createState() => _DenunciaResenaDialogState();
}

class _DenunciaResenaDialogState extends State<DenunciaResenaDialog> {
  String? _motivoSeleccionado;
  final _comentarioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);
    return AlertDialog(
      backgroundColor: colors.colorScheme.surface,
      title: Text('Denunciar reseña', style: TextStyle(color: colors.colorScheme.onSurface)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Por qué deseas denunciar esta reseña?',
                style: TextStyle(color: colors.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              ...motivosDenuncia.map((motivo) => ListTile(
                leading: Radio<String>(
                  value: motivo,
                  groupValue: _motivoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      _motivoSeleccionado = value;
                    });
                  },
                ),
                title: Text(motivo, style: TextStyle(fontSize: 14, color: colors.colorScheme.onSurface)),
                onTap: () {
                  setState(() {
                    _motivoSeleccionado = motivo;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 8),
              if (_motivoSeleccionado == 'Otro') ...[
                TextFormField(
                  controller: _comentarioController,
                  maxLines: 3,
                  maxLength: 200,
                  style: TextStyle(color: colors.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Describe el motivo de tu denuncia...',
                    hintStyle: TextStyle(color: colors.colorScheme.onSurfaceVariant),
                    border: const OutlineInputBorder(),
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: colors.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
              if (_motivoSeleccionado != null && _motivoSeleccionado != 'Otro') ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _comentarioController,
                  maxLines: 2,
                  maxLength: 200,
                  style: TextStyle(color: colors.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Descripción adicional (opcional)',
                    hintStyle: TextStyle(color: colors.colorScheme.onSurfaceVariant),
                    border: const OutlineInputBorder(),
                    labelText: 'Comentarios adicionales',
                    labelStyle: TextStyle(color: colors.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: colors.colorScheme.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_motivoSeleccionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona un motivo')),
              );
              return;
            }
            widget.onSubmit(
              _motivoSeleccionado!,
              _comentarioController.text.trim().isEmpty 
                  ? null 
                  : _comentarioController.text.trim(),
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.colorScheme.error,
          ),
          child: const Text('Denunciar'),
        ),
      ],
    );
  }
}
