import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/libros_cubit.dart';
import '../../logic/cubit/categorias_cubit.dart';
import '../widgets/index.dart';

class SearchPage extends StatefulWidget {
  final String? autorInicial;

  const SearchPage({super.key, this.autorInicial});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _showFilters = false;
  bool _hasSearched = false;
  String? _selectedAutor;
  List<int> _selectedCategorias = [];
  int? _selectedCategoriaId;

  @override
  void initState() {
    super.initState();
    context.read<CategoriasCubit>().cargarCategorias();
    
    if (widget.autorInicial != null && widget.autorInicial!.isNotEmpty) {
      _searchController.text = widget.autorInicial!;
      _selectedAutor = widget.autorInicial;
      setState(() {
        _hasSearched = true;
      });
      context.read<LibrosCubit>().buscarLibrosConFiltros(
        '',
        autor: widget.autorInicial,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query, {List<int>? categorias, String? autor}) {
    final hasFilters = (categorias != null && categorias.isNotEmpty) || 
                       (autor != null && autor.isNotEmpty) ||
                       query.isNotEmpty;
    
    setState(() {
      _hasSearched = hasFilters;
    });

    if (hasFilters) {
      context.read<LibrosCubit>().buscarLibrosConFiltros(
        query,
        categorias: categorias ?? _selectedCategorias,
        autor: autor ?? _selectedAutor,
      );
    } else {
      context.read<LibrosCubit>().cargarLibros();
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _onCategoriaToggled(int categoriaId) {
    setState(() {
      _selectedCategoriaId = categoriaId;
      _selectedCategorias = [categoriaId];
      _hasSearched = true;
    });
    context.read<LibrosCubit>().buscarLibrosConFiltros(
      _searchController.text,
      categorias: _selectedCategorias,
      autor: _selectedAutor,
    );
  }

  void _onAutorSubmitted(String? autor) {
    setState(() {
      _selectedAutor = autor;
      _hasSearched = true;
    });
    context.read<LibrosCubit>().buscarLibrosConFiltros(
      _searchController.text,
      categorias: _selectedCategorias,
      autor: _selectedAutor,
    );
  }

  void _onClearCategoria() {
    setState(() {
      _selectedCategoriaId = null;
      _selectedCategorias = [];
    });
    context.read<LibrosCubit>().buscarLibrosConFiltros(
      _searchController.text,
      categorias: [],
      autor: _selectedAutor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              showFilters: _showFilters,
              onChanged: (value) {
                _onSearchChanged(value);
                setState(() {});
              },
              onToggleFilters: _toggleFilters,
              onBack: () => context.go('/home'),
            ),
            if (_showFilters)
              SearchFiltersPanel(
                selectedCategoriaId: _selectedCategoriaId,
                selectedAutor: _selectedAutor,
                onCategoriaToggled: _onCategoriaToggled,
                onAutorSubmitted: (value) => _onAutorSubmitted(value?.isNotEmpty == true ? value : null),
                onClearCategoria: _onClearCategoria,
              ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return const SearchEmptyState();
    }

    return BlocBuilder<LibrosCubit, LibrosState>(
      builder: (context, state) {
        if (state is LibrosLoading) {
          return const SearchLoadingView();
        }

        if (state is LibrosError) {
          return SearchErrorView(
            message: state.message,
            onRetry: () => context.read<LibrosCubit>().cargarLibros(),
          );
        }

        if (state is LibrosLoaded) {
          if (state.libros.isEmpty) {
            return const SearchNoResultsState();
          }

          return SearchResultsGrid(libros: state.libros);
        }

        return const SearchLoadingView();
      },
    );
  }
}