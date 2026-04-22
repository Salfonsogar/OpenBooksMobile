import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/libro_biblioteca.dart';
import '../../logic/cubit/biblioteca_cubit.dart';
import '../../../../shared/ui/widgets/reading_progress_bar.dart';
import '../../../../shared/ui/widgets/sync_status_indicator.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibliotecaCubit>().cargarBiblioteca();
    });
  }

  Future<void> _descargarLibro(int libroId, String titulo) async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    messenger.showSnackBar(
      SnackBar(
        content: Text('Descargando "$titulo"...'),
        backgroundColor: colorScheme.primary,
      ),
    );

    try {
      await context.read<BibliotecaCubit>().descargarLibro(libroId);
      
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
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

  void _editarLibro(int libroId) {
    context.push('/book/$libroId');
  }

  Future<void> _eliminarLibro(int libroId, String titulo) async {
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

    if (confirm == true && mounted) {
      await context.read<BibliotecaCubit>().quitarLibro(libroId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/library/upload'),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BibliotecaCubit, BibliotecaState>(
          builder: (context, state) {
            if (state is BibliotecaLoading || state is BibliotecaInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BibliotecaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () =>
                          context.read<BibliotecaCubit>().cargarBiblioteca(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is BibliotecaLoaded) {
              if (state.libros.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tu biblioteca está vacía',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agrega libros desde el catálogo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () => context.go('/home'),
                        child: const Text('Explorar libros'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<BibliotecaCubit>().refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.libros.length,
                  itemBuilder: (context, index) {
                    final libro = state.libros[index];
                    return _buildLibroItem(libro);
                  },
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
    );
  }

  Widget _buildLibroItem(LibroBiblioteca libro) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.pushReplacement('/reader/${libro.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: libro.portadaBase64 != null && libro.portadaBase64!.isNotEmpty
                    ? Image.memory(
                        base64Decode(libro.portadaBase64!),
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 120,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.menu_book,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.menu_book,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
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
                      _descargarLibro(libro.id, libro.titulo);
                      break;
                    case 'edit':
                      _editarLibro(libro.id);
                      break;
                    case 'delete':
                      _eliminarLibro(libro.id, libro.titulo);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface),
                        SizedBox(width: 8),
                        Text('Descargar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
                        SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        SizedBox(width: 8),
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
