import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/cubit/categorias_cubit.dart';

class SearchFiltersPanel extends StatelessWidget {
  final int? selectedCategoriaId;
  final String? selectedAutor;
  final void Function(int) onCategoriaToggled;
  final void Function(String?) onAutorSubmitted;
  final VoidCallback onClearCategoria;

  const SearchFiltersPanel({
    super.key,
    required this.selectedCategoriaId,
    required this.selectedAutor,
    required this.onCategoriaToggled,
    required this.onAutorSubmitted,
    required this.onClearCategoria,
  });

  @override
  Widget build(BuildContext context) {
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
                onSubmitted: onAutorSubmitted,
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
                          value: selectedCategoriaId,
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
                              onCategoriaToggled(categoriaId);
                            }
                          },
                        ),
                      ),
                      if (selectedCategoriaId != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: onClearCategoria,
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
}