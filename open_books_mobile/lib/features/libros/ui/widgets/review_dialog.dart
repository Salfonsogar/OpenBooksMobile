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
    return AlertDialog(
      title: const Text('Escribir reseña'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Comparte tu opinión sobre este libro...',
            border: OutlineInputBorder(),
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
          child: const Text('Cancelar'),
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
