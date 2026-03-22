import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/categorias/data/models/admin_categoria.dart';
import 'package:open_books_mobile/features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import 'package:open_books_mobile/features/admin/categorias/ui/widgets/categoria_form_dialog.dart';
import 'package:open_books_mobile/features/admin/categorias/ui/widgets/categoria_delete_dialog.dart';

class AdminCategoriasPage extends StatefulWidget {
  const AdminCategoriasPage({super.key});

  @override
  State<AdminCategoriasPage> createState() => _AdminCategoriasPageState();
}

class _AdminCategoriasPageState extends State<AdminCategoriasPage> {
  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  void _initCubit() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminCategoriasCubit>().setToken(sessionState.token);
    }
    context.read<AdminCategoriasCubit>().loadCategorias();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoriaFormDialog(
        onSave: (request) async {
          return await context.read<AdminCategoriasCubit>().createCategoria(request);
        },
      ),
    );
  }

  void _showEditDialog(AdminCategoria categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoriaFormDialog(
        categoria: categoria,
        onSave: (request) async {
          return await context.read<AdminCategoriasCubit>().updateCategoria(categoria.id, request);
        },
      ),
    );
  }

  void _showDeleteDialog(AdminCategoria categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoriaDeleteDialog(
        categoria: categoria,
        onConfirm: () async {
          return await context.read<AdminCategoriasCubit>().deleteCategoria(categoria.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<AdminCategoriasCubit, AdminCategoriasState>(
              builder: (context, state) {
                if (state is AdminCategoriasLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminCategoriasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AdminCategoriasCubit>().loadCategorias();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is AdminCategoriasLoaded) {
                  return _buildCategoriasList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gestión de Categorías',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          FilledButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Categoría'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasList(AdminCategoriasLoaded state) {
    if (state.categorias.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron categorías',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminCategoriasCubit>().refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.categorias.items.length,
        itemBuilder: (context, index) {
          final categoria = state.categorias.items[index];
          return _CategoriaCard(
            categoria: categoria,
            onEdit: () => _showEditDialog(categoria),
            onDelete: () => _showDeleteDialog(categoria),
          );
        },
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final AdminCategoria categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoriaCard({
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (categoria.descripcion != null && categoria.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      categoria.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${categoria.cantidadLibros} libros',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
