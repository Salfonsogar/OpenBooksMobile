import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/index.dart';
import '../../logic/cubit/libros_cubit.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _sectionsLoader = HomeSectionsLoader();
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
      final data = await _sectionsLoader.load(context.read<LibrosCubit>());
      
      if (mounted) {
        setState(() {
          _recomendados = data.recomendados;
          _librosCategoria = data.librosCategoria;
          _categoriaRandom = data.categoriaRandom;
          _librosAutor = data.librosAutor;
          _autorRandom = data.autorRandom;
          _top5 = data.top5;
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
          return const HomeLoadingView();
        }

        if (state is LibrosError) {
          return HomeErrorView(
            message: state.message,
            onRetry: () => context.read<LibrosCubit>().refresh(),
          );
        }

        if (state is LibrosLoaded && (state.query != null || state.categoriasSeleccionadas != null || state.autor != null)) {
          return HomeGridView(
            state: state,
            scrollController: _scrollController,
            onRefresh: () => context.read<LibrosCubit>().refresh(),
            onLibroTap: (id) => context.pushReplacement('/book/$id'),
          );
        }

        return HomeSeccionesView(
          recomendados: _recomendados,
          librosCategoria: _librosCategoria,
          categoriaRandom: _categoriaRandom,
          librosAutor: _librosAutor,
          autorRandom: _autorRandom,
          top5: _top5,
          onRefresh: _cargarSecciones,
          onLibroTap: (libro) => context.pushReplacement('/book/${libro.id}'),
        );
      },
    );
  }
}