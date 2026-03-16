import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../logic/cubit/libro_detalle_cubit.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/review_dialog.dart';

class BookDetailPage extends StatefulWidget {
  final int libroId;

  const BookDetailPage({super.key, required this.libroId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LibroDetalleCubit>().cargarDetalle(widget.libroId);
  }

  void _showRatingDialog(LibroDetalle libro) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        libroId: libro.id,
        onRate: (puntuacion) {
          context.read<LibroDetalleCubit>().valorar(puntuacion);
        },
      ),
    );
  }

  void _showReviewDialog(int libroId) {
    showDialog(
      context: context,
      builder: (context) => ReviewDialog(
        libroId: libroId,
        onSubmit: (texto) {
          context.read<LibroDetalleCubit>().escribirResena(texto);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LibroDetalleCubit, LibroDetalleState>(
        listener: (context, state) {
          if (state is ValoracionSuccess || state is ResenaSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operación realizada con éxito')),
            );
          } else if (state is LibroDetalleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LibroDetalleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LibroDetalleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LibroDetalleCubit>().recargar(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is LibroDetalleLoaded ||
              state is ValoracionSuccess ||
              state is ResenaSuccess) {
            final libro = state is LibroDetalleLoaded
                ? state.libro
                : state is ValoracionSuccess
                ? state.libro
                : (state as ResenaSuccess).libro;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child:
                          libro.portadaBase64 != null &&
                              libro.portadaBase64!.isNotEmpty
                          ? Image.memory(
                              base64Decode(libro.portadaBase64!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.menu_book, size: 80),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(Icons.menu_book, size: 80),
                            ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add_to_home_screen),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Agregar a biblioteca (pendiente)'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          libro.titulo,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          libro.autor,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[700],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${libro.promedioValoraciones.toStringAsFixed(1)} (${libro.cantidadValoraciones} valoraciones)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: libro.categorias
                              .map(
                                (c) => Chip(
                                  label: Text(
                                    c,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(libro.descripcion),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showRatingDialog(libro),
                                icon: const Icon(Icons.star_outline),
                                label: const Text('Valorar'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showReviewDialog(libro.id),
                                icon: const Icon(Icons.rate_review_outlined),
                                label: const Text('Reseñar'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.push('/reader/${libro.id}'),
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Comenzar a leer'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reseñas (${libro.totalResenas})',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (libro.resenas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text('No hay reseñas todavía'),
                            ),
                          )
                        else
                          ...libro.resenas.map(
                            (resena) => _buildResenaCard(resena),
                          ),
                        if (libro.resenas.length < libro.totalResenas)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                final page =
                                    (libro.resenas.length / 5).ceil() + 1;
                                context
                                    .read<LibroDetalleCubit>()
                                    .cargarMasResenas(page);
                              },
                              child: const Text('Cargar más reseñas'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildResenaCard(Resena resena) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: resena.fotoPerfilBase64 != null
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(resena.fotoPerfilBase64!),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              resena.nombreUsuario[0].toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                      : Text(
                          resena.nombreUsuario[0].toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resena.nombreUsuario,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(resena.fecha),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.texto),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
