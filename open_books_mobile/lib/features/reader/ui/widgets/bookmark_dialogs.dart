import 'package:flutter/material.dart';

import 'reader_colors.dart';

class BookmarkCallbacks {
  final void Function(String title) onCreate;
  final void Function(int id, String title) onUpdate;
  final void Function(int id) onDelete;

  const BookmarkCallbacks({
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });
}

void showCreateBookmarkDialog({
  required BuildContext context,
  required ReaderColors colors,
  required String defaultTitle,
  required void Function(String title) onConfirm,
}) {
  final controller = TextEditingController(text: defaultTitle);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.background,
      title: Text(
        'Agregar marcador',
        style: TextStyle(color: colors.text),
      ),
      content: TextField(
        controller: controller,
        style: TextStyle(color: colors.text),
        cursorColor: colors.text,
        decoration: InputDecoration(
          labelText: 'Nombre del marcador',
          labelStyle: TextStyle(color: colors.text.withValues(alpha: 0.7)),
          filled: true,
          fillColor: colors.text.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.text.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.accent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.text.withValues(alpha: 0.3)),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancelar', style: TextStyle(color: colors.text)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.background,
          ),
          onPressed: () {
            final title = controller.text.trim();
            if (title.isNotEmpty) {
              Navigator.pop(dialogContext);
              onConfirm(title);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
}

void showEditBookmarkDialog({
  required BuildContext context,
  required ReaderColors colors,
  required String currentTitle,
  required void Function(String title) onConfirm,
}) {
  final controller = TextEditingController(text: currentTitle);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.background,
      title: Text(
        'Editar marcador',
        style: TextStyle(color: colors.text),
      ),
      content: TextField(
        controller: controller,
        style: TextStyle(color: colors.text),
        cursorColor: colors.text,
        decoration: InputDecoration(
          labelText: 'Nombre del marcador',
          labelStyle: TextStyle(color: colors.text.withValues(alpha: 0.7)),
          filled: true,
          fillColor: colors.text.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.text.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.accent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colors.text.withValues(alpha: 0.3)),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancelar', style: TextStyle(color: colors.text)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.background,
          ),
          onPressed: () {
            final title = controller.text.trim();
            if (title.isNotEmpty) {
              Navigator.pop(dialogContext);
              onConfirm(title);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

void showDeleteBookmarkDialog({
  required BuildContext context,
  required ReaderColors colors,
  required String title,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.background,
      title: Text(
        'Eliminar marcador',
        style: TextStyle(color: colors.text),
      ),
      content: Text(
        '¿Eliminar el marcador "$title"?',
        style: TextStyle(color: colors.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancelar', style: TextStyle(color: colors.text)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
