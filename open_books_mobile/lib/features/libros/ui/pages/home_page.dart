import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../logic/cubit/libros_cubit.dart';
import '../widgets/libro_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  List<Libro> _recomendados = [];
  List<Libro> _librosCategoria = [];
  Categoria? _categoriaRandom;
  List<Libro> _librosAutor = [];
  String? _autorRandom;
  List<Libro> _top5 = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _cargarSecciones();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarSecciones() async {
    setState(() => _isLoading = true);

    try {
      final random = Random();
      final cubit = context.read<LibrosCubit>();
      
      final categoriasResult = await cubit.getCategorias();
      final categorias = categoriasResult.data;

      final recomendados = await cubit.getLibrosAleatorios();
      final top5 = await cubit.getTop5Libros();

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

      if (mounted) {
        setState(() {
          _recomendados = recomendados;
          _librosCategoria = librosCategoria;
          _categoriaRandom = categoriaRandom;
          _librosAutor = librosAutor;
          _autorRandom = autorRandom;
          _top5 = top5;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<LibrosCubit>().state;
      if (state is LibrosLoaded) {
        context.read<LibrosCubit>().cargarMasLibros();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibrosCubit, LibrosState>(
      builder: (context, state) {
        if (state is LibrosLoading && _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LibrosError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<LibrosCubit>().refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is LibrosLoaded && (state.query != null || state.categoriasSeleccionadas != null || state.autor != null)) {
          return _buildGridView(state);
        }

        return _buildSecciones();
      },
    );
  }

  Widget _buildGridView(LibrosLoaded state) {
    if (state.libros.isEmpty) {
      return const Center(
        child: Text('No se encontraron libros'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<LibrosCubit>().refresh(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.libros.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.libros.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final libro = state.libros[index];
          return LibroCard(
            libro: libro,
            onTap: () => context.pushReplacement('/book/${libro.id}'),
          );
        },
      ),
    );
  }

  Widget _buildSecciones() {
    return RefreshIndicator(
      onRefresh: _cargarSecciones,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recomendados.isNotEmpty) ...[
              _buildSeccion('eBooks recomendados', _recomendados),
            ],
            if (_categoriaRandom != null && _librosCategoria.isNotEmpty) ...[
              _buildSeccion(_categoriaRandom!.nombre, _librosCategoria),
            ],
            if (_autorRandom != null && _librosAutor.isNotEmpty) ...[
              _buildSeccion('Escritos por $_autorRandom', _librosAutor),
            ],
            if (_top5.isNotEmpty) ...[
              _buildSeccion('Más valorados', _top5),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, List<Libro> libros) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            titulo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: Scrollbar(
            thumbVisibility: false,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: libros.length,
              itemBuilder: (context, index) {
                final libro = libros[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: LibroCard(
                    libro: libro,
                    onTap: () => context.pushReplacement('/book/${libro.id}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
