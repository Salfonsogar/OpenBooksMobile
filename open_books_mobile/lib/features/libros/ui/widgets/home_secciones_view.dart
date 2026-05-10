import 'package:flutter/material.dart';

import '../../data/models/index.dart';
import 'home_seccion_widget.dart';

class HomeSeccionesView extends StatelessWidget {
  final List<Libro> recomendados;
  final List<Libro> librosCategoria;
  final Categoria? categoriaRandom;
  final List<Libro> librosAutor;
  final String? autorRandom;
  final List<Libro> top5;
  final Future<void> Function() onRefresh;
  final void Function(Libro) onLibroTap;

  const HomeSeccionesView({
    super.key,
    required this.recomendados,
    required this.librosCategoria,
    required this.categoriaRandom,
    required this.librosAutor,
    required this.autorRandom,
    required this.top5,
    required this.onRefresh,
    required this.onLibroTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recomendados.isNotEmpty) ...[
              HomeSeccionWidget(
                titulo: 'eBooks recomendados',
                libros: recomendados,
                onLibroTap: onLibroTap,
              ),
            ],
            if (categoriaRandom != null && librosCategoria.isNotEmpty) ...[
              HomeSeccionWidget(
                titulo: categoriaRandom!.nombre,
                libros: librosCategoria,
                onLibroTap: onLibroTap,
              ),
            ],
            if (autorRandom != null && librosAutor.isNotEmpty) ...[
              HomeSeccionWidget(
                titulo: 'Escritos por $autorRandom',
                libros: librosAutor,
                onLibroTap: onLibroTap,
              ),
            ],
            if (top5.isNotEmpty) ...[
              HomeSeccionWidget(
                titulo: 'Más valorados',
                libros: top5,
                onLibroTap: onLibroTap,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}