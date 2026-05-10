import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/widgets/multi_select_bottom_sheet.dart';
import '../../../admin/categorias/data/models/admin_categoria.dart';
import '../../../admin/categorias/logic/cubit/admin_categorias_cubit.dart';

class CategoriaSelectorSheet extends StatelessWidget {
  final List<int> selectedIds;
  final Function(List<int>) onSelected;

  const CategoriaSelectorSheet({
    super.key,
    required this.selectedIds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCategoriasCubit, AdminCategoriasState>(
      builder: (context, state) {
        if (state is AdminCategoriasLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminCategoriasLoaded) {
          final categorias = state.categorias.items;
          if (categorias.isEmpty) {
            return Center(
              child: Text(
                'No hay categorías disponibles',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          }

          return MultiSelectBottomSheet<AdminCategoria>(
            items: categorias,
            title: 'Seleccionar Categorías',
            labelBuilder: (c) => c.nombre,
            subtitleBuilder: (c) => '${c.cantidadLibros} libros',
            selectedItems: categorias.where((c) => selectedIds.contains(c.id)).toList(),
            onConfirm: (selected) {
              onSelected(selected.map((c) => c.id).toList());
            },
          );
        }

        return Center(
          child: Text(
            'Error al cargar categorías',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
      },
    );
  }
}
