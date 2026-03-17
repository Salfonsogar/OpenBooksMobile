import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/historial_cubit.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistorialCubit>().cargarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialCubit, HistorialState>(
      builder: (context, state) {
        if (state is HistorialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistorialError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<HistorialCubit>().cargarHistorial(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final libros = state is HistorialLoaded ? state.libros : [];

        if (libros.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin historial de lectura',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Los libros que leas aparecerán aquí',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Explorar libros'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<HistorialCubit>().refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: libros.length,
            itemBuilder: (context, index) {
              final libro = libros[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: libro.portadaBase64 != null &&
                            libro.portadaBase64!.isNotEmpty
                        ? Image.memory(
                            base64Decode(libro.portadaBase64!),
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 60,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.menu_book),
                              );
                            },
                          )
                        : Container(
                            width: 40,
                            height: 60,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.menu_book),
                          ),
                  ),
                  title: Text(
                    libro.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    libro.autor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushReplacement('/book/${libro.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
