import 'dart:math';

import '../../data/models/index.dart';
import '../../logic/cubit/libros_cubit.dart';

class HomeSectionsData {
  final List<Libro> recomendados;
  final List<Libro> librosCategoria;
  final Categoria? categoriaRandom;
  final List<Libro> librosAutor;
  final String? autorRandom;
  final List<Libro> top5;

  const HomeSectionsData({
    required this.recomendados,
    required this.librosCategoria,
    required this.categoriaRandom,
    required this.librosAutor,
    required this.autorRandom,
    required this.top5,
  });
}

class HomeSectionsLoader {
  Future<HomeSectionsData> load(LibrosCubit cubit) async {
    final random = Random();
    
    final results = await Future.wait([
      cubit.getCategorias(),
      cubit.getLibrosAleatorios(),
      cubit.getTop5Libros(),
    ]);
    
    final categoriasResult = results[0] as PagedResult<Categoria>;
    final categorias = categoriasResult.data;
    final recomendados = results[1] as List<Libro>;
    final top5 = results[2] as List<Libro>;

    String? autorRandom;
    List<Libro> librosAutor = [];
    if (recomendados.isNotEmpty) {
      autorRandom = recomendados[random.nextInt(recomendados.length)].autor;
      librosAutor = await cubit.getLibrosPorAutor(autorRandom);
    }

    Categoria? categoriaRandom;
    List<Libro> librosCategoria = [];
    if (categorias.isNotEmpty) {
      categoriaRandom = categorias[random.nextInt(categorias.length)];
      librosCategoria = await cubit.getLibrosPorCategoria(categoriaRandom.id);
    }

    return HomeSectionsData(
      recomendados: recomendados,
      librosCategoria: librosCategoria,
      categoriaRandom: categoriaRandom,
      librosAutor: librosAutor,
      autorRandom: autorRandom,
      top5: top5,
    );
  }
}