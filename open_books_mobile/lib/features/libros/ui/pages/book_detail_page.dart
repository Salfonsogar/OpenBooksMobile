import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';
import '../../logic/cubit/libro_detalle_cubit.dart' show OperationType, LibroDetalleCubit, LibroDetalleState, LibroDetalleLoaded, LibroDetalleError, LibroDetalleLoading;
import '../widgets/review_dialog.dart';
import '../widgets/denuncia_resena_dialog.dart';
import '../widgets/share_book_qr_widget.dart';
import '../../../../shared/ui/widgets/close_header.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';

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
    final cubit = context.read<LibroDetalleCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => ReviewDialog(
        libroId: libroId,
        onSubmit: (texto) {
          cubit.escribirResena(texto);
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
            child: const Text('cerrar'),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(int libroId, String titulo, String autor) {
    showDialog(
      context: context,
      builder: (dialogContext) => ShareBookQrDialog(
        libroId: libroId,
        titulo: titulo,
        autor: autor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibroDetalleCubit, LibroDetalleState>(
      builder: (context, state) {
        final actions = state is LibroDetalleLoaded
            ? [
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => _showQrDialog(
                    state.libro.id,
                    state.libro.titulo,
                    state.libro.autor,
                  ),
                  tooltip: 'Compartir QR',
                ),
              ]
            : <Widget>[];
        return Scaffold(
          appBar: CloseHeader(
            onClose: () => context.go('/home'),
            actions: actions,
          ),
          body: BlocConsumer<LibroDetalleCubit, LibroDetalleState>(
            listener: (context, state) {
              if (state is LibroDetalleLoaded && state.operationType != null) {
                if (state.operationType == OperationType.denuncia) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Denuncia enviada correctamente')),
                  );
                } else if (state.operationType == OperationType.valoracion || 
                           state.operationType == OperationType.resena) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Operación realizada con éxito')),
                  );
                }
              } else if (state is LibroDetalleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            listenWhen: (previous, current) {
              if (previous is LibroDetalleLoaded && current is LibroDetalleLoaded) {
                return current.operationType != previous.operationType;
              }
              return true;
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

          if (state is LibroDetalleLoaded) {
            final libro = state.libro;
            final portadaBase64 = state.portadaBase64;
            final estaEnBiblioteca = state.estaEnBiblioteca;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(libro, portadaBase64),
                  const SizedBox(height: 32),
                  _buildBotonComprar(libro, estaEnBiblioteca),
                  const SizedBox(height: 32),
                  _buildEstadisticas(libro),
                  const SizedBox(height: 32),
                  _buildEstrellas(libro),
                  const SizedBox(height: 32),
                  _buildBotonResena(libro.id),
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
      },
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
              if (libro.categorias.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  libro.categorias.first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
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
              if (libro.categorias.length > 1)
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        onPressed: () {
          if (estaEnBiblioteca) {
            context.push('/reader/${libro.id}');
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
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
        ),
        onPressed: () => _showReviewDialog(libroId),
        child: const Text('Escribir reseña'),
      ),
    );
  }

  Widget _buildEstadisticas(LibroDetalle libro) {
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.onSurface),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No hay reseñas todavía',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
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
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                _buildDenunciaButton(resena),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.texto),
          ],
        ),
      ),
    );
  }

  Widget _buildDenunciaButton(Resena resena) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.flag_outlined, size: 20),
          onPressed: () => _showDenunciaDialog(resena),
          tooltip: 'Denunciar reseña',
          color: Theme.of(context).colorScheme.error,
        );
      },
    );
  }

  void _showDenunciaDialog(Resena resena) {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is! SessionAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para denunciar una reseña')),
      );
      return;
    }

    if (sessionState.userId == resena.usuarioId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes denunciar tu propia reseña')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => DenunciaResenaDialog(
        resena: resena,
        onSubmit: (motivo, comentario) {
          context.read<LibroDetalleCubit>().denunciarResena(
            idDenunciante: sessionState.userId,
            idDenunciado: resena.usuarioId,
            idResena: resena.id,
            motivo: motivo,
            comentario: comentario,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
