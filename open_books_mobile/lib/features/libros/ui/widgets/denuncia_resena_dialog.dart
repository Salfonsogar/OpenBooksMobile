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
    return AlertDialog(
      title: const Text('Denunciar reseña'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Por qué deseas denunciar esta reseña?',
                style: Theme.of(context).textTheme.bodyMedium,
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
                title: Text(motivo, style: const TextStyle(fontSize: 14)),
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
                  decoration: const InputDecoration(
                    hintText: 'Describe el motivo de tu denuncia...',
                    border: OutlineInputBorder(),
                    labelText: 'Descripción',
                  ),
                ),
              ],
              if (_motivoSeleccionado != null && _motivoSeleccionado != 'Otro') ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _comentarioController,
                  maxLines: 2,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Descripción adicional (opcional)',
                    border: OutlineInputBorder(),
                    labelText: 'Comentarios adicionales',
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
          child: const Text('Cancelar'),
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
            backgroundColor: Colors.red,
          ),
          child: const Text('Denunciar'),
        ),
      ],
    );
  }
}
