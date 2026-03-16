import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/categorias_cubit.dart';
import '../../logic/cubit/libros_cubit.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final Set<int> _selectedCategorias = {};
  final _autorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentState = context.read<LibrosCubit>().state;
    if (currentState is LibrosLoaded) {
      if (currentState.categoriasSeleccionadas != null) {
        _selectedCategorias.addAll(currentState.categoriasSeleccionadas!);
      }
      if (currentState.autor != null) {
        _autorController.text = currentState.autor!;
      }
    }
    context.read<CategoriasCubit>().cargarCategorias();
  }

  @override
  void dispose() {
    _autorController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final autor = _autorController.text.trim();
    context.read<LibrosCubit>().cargarLibros(
          categorias: _selectedCategorias.isNotEmpty ? _selectedCategorias.toList() : null,
          autor: autor.isNotEmpty ? autor : null,
          refresh: true,
        );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategorias.clear();
      _autorController.clear();
    });
    context.read<LibrosCubit>().cargarLibros(refresh: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar libros',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Autor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _autorController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por autor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Categorías',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<CategoriasCubit, CategoriasState>(
                    builder: (context, state) {
                      if (state is CategoriasLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CategoriasLoaded) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.categorias.map((categoria) {
                            final isSelected = _selectedCategorias.contains(categoria.id);
                            return FilterChip(
                              label: Text(categoria.nombre),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategorias.add(categoria.id);
                                  } else {
                                    _selectedCategorias.remove(categoria.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
