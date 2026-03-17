import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../logic/cubit/libro_detalle_cubit.dart';
import '../widgets/review_dialog.dart';
import '../../../../shared/ui/widgets/close_header.dart';

class BookDetailPage extends StatefulWidget {
  final int libroId;

  const BookDetailPage({super.key, required this.libroId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _puntuacionSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    context.read<LibroDetalleCubit>().cargarDetalle(widget.libroId);
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

  void _showDescripcionCompleta(String descripcion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descripción'),
        content: SingleChildScrollView(child: Text(descripcion)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseHeader(onClose: () => context.go('/home')),
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

            final portadaBase64 = state is LibroDetalleLoaded
                ? state.portadaBase64
                : state is ValoracionSuccess
                ? state.portadaBase64
                : (state as ResenaSuccess).portadaBase64;

            final estaEnBiblioteca = state is LibroDetalleLoaded
                ? state.estaEnBiblioteca
                : state is ValoracionSuccess
                ? state.estaEnBiblioteca
                : (state as ResenaSuccess).estaEnBiblioteca;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(libro, portadaBase64),
                  const SizedBox(height: 32),
                  _buildBotonComprar(libro, estaEnBiblioteca),
                  const SizedBox(height: 48),
                  _buildEstrellas(libro),
                  const SizedBox(height: 32),
                  _buildBotonResena(libro.id),
                  const SizedBox(height: 48),
                  _buildEstadisticas(libro),
                  const SizedBox(height: 48),
                  _buildDescripcion(libro),
                  const SizedBox(height: 48),
                  _buildResenas(libro),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPortadaImage(String? portadaBase64) {
    if (portadaBase64 == null || portadaBase64.isEmpty) {
      return const Center(child: Icon(Icons.menu_book, size: 60));
    }

    try {
      final bytes = base64Decode(portadaBase64);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.menu_book, size: 60));
        },
      );
    } catch (e) {
      return const Center(child: Icon(Icons.menu_book, size: 60));
    }
  }

  Widget _buildHeader(LibroDetalle libro, String? portadaBase64) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 120,
              height: 180,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _buildPortadaImage(portadaBase64),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                libro.autor,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${libro.promedioValoraciones.toStringAsFixed(1)} (${libro.cantidadValoraciones})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: libro.categorias
                    .take(3)
                    .map(
                      (c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  context.push(
                    '/search?autor=${Uri.encodeComponent(libro.autor)}',
                  );
                },
                child: Text(
                  'Más de este autor',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotonComprar(LibroDetalle libro, bool estaEnBiblioteca) {
    if (estaEnBiblioteca) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.pushReplacement('/reader/${libro.id}');
          },
          child: const Text('Leer'),
        ),
      );
    }
    return Center(
      child: OutlinedButton(
        onPressed: () {
          if (estaEnBiblioteca) {
            context.pushReplacement('/reader/${libro.id}');
          } else {
            context.read<LibroDetalleCubit>().agregarABiblioteca();
          }
        },
        child: Text(estaEnBiblioteca ? 'Leer' : 'Comprar'),
      ),
    );
  }

  Widget _buildEstrellas(LibroDetalle libro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Valoración',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _puntuacionSeleccionada = index + 1;
                });
                context.read<LibroDetalleCubit>().valorar(index + 1);
              },
              child: Icon(
                index < _puntuacionSeleccionada ||
                        index < libro.promedioValoraciones.round()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber[700],
                size: 32,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBotonResena(int libroId) {
    return Center(
      child: OutlinedButton(
        onPressed: () => _showReviewDialog(libroId),
        child: const Text('Escribir reseña'),
      ),
    );
  }

  Widget _buildEstadisticas(LibroDetalle libro) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.star,
              label: 'Valoración',
              value: libro.promedioValoraciones.toStringAsFixed(1),
            ),
            _buildStatItem(
              icon: Icons.rate_review,
              label: 'Reseñas',
              value: libro.totalResenas.toString(),
            ),
            _buildStatItem(
              icon: Icons.description,
              label: 'Páginas',
              value: libro.numeroPaginas != null
                  ? libro.numeroPaginas.toString()
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDescripcion(LibroDetalle libro) {
    final descripcion = libro.descripcion;
    final maxLines = 4;
    final textSpan = TextSpan(text: descripcion);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final exceeded = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Descripción',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (exceeded)
              TextButton(
                onPressed: () => _showDescripcionCompleta(descripcion),
                child: const Text('Ver más'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          descripcion,
          maxLines: exceeded ? maxLines : null,
          overflow: exceeded ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }

  Widget _buildResenas(LibroDetalle libro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reseñas (${libro.totalResenas})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (libro.resenas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No hay reseñas todavía')),
          )
        else
          ...libro.resenas.map((resena) => _buildResenaCard(resena)),
        if (libro.resenas.length < libro.totalResenas)
          Center(
            child: TextButton(
              onPressed: () {
                final page = (libro.resenas.length / 5).ceil() + 1;
                context.read<LibroDetalleCubit>().cargarMasResenas(page);
              },
              child: const Text('Cargar más reseñas'),
            ),
          ),
      ],
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
