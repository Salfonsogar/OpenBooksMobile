import 'package:flutter/material.dart';

class ArchivoPickerWidget extends StatelessWidget {
  final String? nombreArchivo;
  final bool archivoSeleccionado;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const ArchivoPickerWidget({
    super.key,
    required this.nombreArchivo,
    required this.archivoSeleccionado,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPick,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: archivoSeleccionado
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book, size: 40, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nombreArchivo ?? 'Archivo seleccionado',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: onClear,
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 40, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'Toca para seleccionar archivo',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
