import 'package:flutter/material.dart';

class ReviewDialog extends StatefulWidget {
  final int libroId;
  final Function(String) onSubmit;

  const ReviewDialog({
    super.key,
    required this.libroId,
    required this.onSubmit,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);
    return AlertDialog(
      backgroundColor: colors.colorScheme.surface,
      title: Text('Escribir reseña', style: TextStyle(color: colors.colorScheme.onSurface)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 5,
          maxLength: 500,
          style: TextStyle(color: colors.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.colorScheme.surface,
            hintText: 'Comparte tu opinión sobre este libro...',
            hintStyle: TextStyle(color: colors.colorScheme.onSurfaceVariant),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colors.colorScheme.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Escribe una reseña';
            }
            if (value.trim().length < 10) {
              return 'La reseña debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: colors.colorScheme.onSurfaceVariant)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Publicar'),
        ),
      ],
    );
  }
}
