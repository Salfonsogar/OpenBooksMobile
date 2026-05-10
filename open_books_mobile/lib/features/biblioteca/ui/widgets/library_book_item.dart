import 'package:flutter/material.dart';

import '../../data/models/libro_biblioteca.dart';
import '../../../../shared/ui/widgets/reading_progress_bar.dart';
import '../../../../shared/ui/widgets/sync_status_indicator.dart';
import 'library_book_cover.dart';

class LibraryBookItem extends StatelessWidget {
  final LibroBiblioteca libro;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LibraryBookItem({
    super.key,
    required this.libro,
    required this.onTap,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              LibraryBookCover(
                portadaBase64: libro.portadaBase64,
                width: 80,
                height: 120,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (libro.progreso > 0) ...[
                      ReadingProgressBar(
                        progreso: libro.progreso,
                        height: 6,
                        showPercentage: true,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (libro.page != null) ...[
                            Text(
                              'Pagina ${libro.page}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (libro.syncStatus != null) ...[
                            SyncStatusIndicator(
                              pendingCount: libro.syncStatus == 'pending' ? 1 : 0,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'download':
                      onDownload();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text('Descargar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}