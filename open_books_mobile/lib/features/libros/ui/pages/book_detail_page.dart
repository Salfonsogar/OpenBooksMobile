import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';
import '../../logic/cubit/libro_detalle_cubit.dart' show OperationType, LibroDetalleCubit, LibroDetalleState, LibroDetalleLoaded, LibroDetalleError, LibroDetalleLoading;
import '../widgets/book_header_widget.dart';
import '../widgets/book_stats_widget.dart';
import '../widgets/book_description_widget.dart';
import '../widgets/book_reviews_section.dart';
import '../widgets/star_rating_widget.dart';
import '../../../../shared/ui/widgets/close_header.dart';
import 'book_detail_dialogs.dart';
import 'book_detail_states_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibroDetalleCubit, LibroDetalleState>(
      builder: (context, state) {
        final actions = state is LibroDetalleLoaded
            ? [
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => showQrDialog(
                    context,
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
                return const BookDetailLoadingView();
              }

              if (state is LibroDetalleError) {
                return BookDetailErrorView(
                  message: state.message,
                  onRetry: () => context.read<LibroDetalleCubit>().recargar(),
                );
              }

              if (state is LibroDetalleLoaded) {
                return _buildLoadedContent(context, state);
              }

              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadedContent(BuildContext context, LibroDetalleLoaded state) {
    final libro = state.libro;
    final estaEnBiblioteca = state.estaEnBiblioteca;
    final maxWidth = MediaQuery.of(context).size.width - 32;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookHeaderWidget(libro: libro),
          const SizedBox(height: 32),
          _buildBotonComprar(libro, estaEnBiblioteca),
          const SizedBox(height: 32),
          BookStatsWidget(libro: libro),
          const SizedBox(height: 32),
          StarRatingWidget(
            promedioValoraciones: libro.promedioValoraciones,
            onRatingSelected: (rating) {
              context.read<LibroDetalleCubit>().valorar(rating);
            },
          ),
          const SizedBox(height: 32),
          _buildBotonResena(libro.id),
          const SizedBox(height: 48),
          BookDescriptionWidget(libro: libro, maxWidth: maxWidth),
          const SizedBox(height: 48),
          BookReviewsSection(
            resenas: libro.resenas,
            totalResenas: libro.totalResenas,
            onLoadMore: () {
              final page = (libro.resenas.length / 5).ceil() + 1;
              context.read<LibroDetalleCubit>().cargarMasResenas(page);
            },
          ),
        ],
      ),
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

  Widget _buildBotonResena(int libroId) {
    return Center(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
        ),
        onPressed: () => showReviewDialog(context, libroId),
        child: const Text('Escribir reseña'),
      ),
    );
  }
}