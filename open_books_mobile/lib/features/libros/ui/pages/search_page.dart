import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/libros_cubit.dart';
import '../../logic/cubit/categorias_cubit.dart';
import '../widgets/libro_card.dart';

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
            _buildSearchBar(),
            if (_showFilters) _buildFilters(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.go('/home'),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar libros...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _onSearchChanged(value);
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _showFilters 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: _showFilters 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: _toggleFilters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<CategoriasCubit, CategoriasState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Autor',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar por autor...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (value) {
                  _onAutorSubmitted(value.isNotEmpty ? value : null);
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Categorías',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (state is CategoriasLoading)
                const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is CategoriasLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedCategoriaId,
                          hint: Text(
                            'Seleccionar categoría',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          underline: const SizedBox(),
                          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          items: state.categorias.map((categoria) {
                            return DropdownMenuItem<int>(
                              value: categoria.id,
                              child: Text(
                                categoria.nombre,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              ),
                            );
                          }).toList(),
                          onChanged: (categoriaId) {
                            if (categoriaId != null) {
                              _onCategoriaToggled(categoriaId);
                            }
                          },
                        ),
                      ),
                      if (_selectedCategoriaId != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: _onClearCategoria,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                )
              else if (state is CategoriasError)
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else
                const SizedBox(height: 40),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Ingresa un término de búsqueda',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<LibrosCubit, LibrosState>(
      builder: (context, state) {
        if (state is LibrosLoading) {
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
                  onPressed: () => context.read<LibrosCubit>().cargarLibros(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is LibrosLoaded) {
          if (state.libros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  const Text('No se encontraron libros'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.libros.length,
            itemBuilder: (context, index) {
              final libro = state.libros[index];
              return LibroCard(
                libro: libro,
                onTap: () => context.pushReplacement('/book/${libro.id}'),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
