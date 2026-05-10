import 'package:flutter/material.dart';

import '../../logic/cubit/biblioteca_cubit.dart';

class LibraryActions {
  LibraryActions._();

  static Future<void> descargarLibro(
    BuildContext context,
    BibliotecaCubit cubit,
    int libroId,
    String titulo,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    messenger.showSnackBar(
      SnackBar(
        content: Text('Descargando "$titulo"...'),
        backgroundColor: colorScheme.primary,
      ),
    );

    try {
      await cubit.descargarLibro(libroId);
      
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Libro descargado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al descargar: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  static void editarLibro(BuildContext context, int libroId) {
    Navigator.of(context).pushReplacementNamed('/book/$libroId');
  }

  static Future<void> eliminarLibro(
    BuildContext context,
    BibliotecaCubit cubit,
    int libroId,
    String titulo,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Estás seguro de eliminar "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await cubit.quitarLibro(libroId);
    }
  }
}