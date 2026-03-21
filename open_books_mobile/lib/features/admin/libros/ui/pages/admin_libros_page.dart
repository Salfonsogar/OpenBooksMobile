import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/libros/data/models/admin_libro.dart';
import 'package:open_books_mobile/features/admin/libros/logic/cubit/admin_libros_cubit.dart';
import 'package:open_books_mobile/features/admin/libros/ui/widgets/libro_form_dialog.dart';
import 'package:open_books_mobile/features/admin/libros/ui/widgets/libro_delete_dialog.dart';
import 'package:open_books_mobile/features/admin/categorias/data/models/admin_categoria.dart';
import 'package:open_books_mobile/features/admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import 'package:open_books_mobile/features/admin/categorias/ui/widgets/categoria_form_dialog.dart';
import 'package:open_books_mobile/features/admin/categorias/ui/widgets/categoria_delete_dialog.dart';

class AdminLibrosPage extends StatefulWidget {
  const AdminLibrosPage({super.key});

  @override
  State<AdminLibrosPage> createState() => _AdminLibrosPageState();
}

class _AdminLibrosPageState extends State<AdminLibrosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollControllerLibros = ScrollController();
  final _scrollControllerCategorias = ScrollController();
  bool _scrollListenersAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCubits();
    _attachScrollListeners();
  }

  void _initCubits() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminLibrosCubit>().setToken(sessionState.token);
      context.read<AdminCategoriasCubit>().setToken(sessionState.token);
    }
    context.read<AdminLibrosCubit>().loadLibros();
    context.read<AdminCategoriasCubit>().loadCategorias();
  }

  void _attachScrollListeners() {
    if (_scrollListenersAttached) return;
    _scrollListenersAttached = true;
    _scrollControllerLibros.addListener(_onLibrosScroll);
  }

  void _onLibrosScroll() {
    if (_scrollControllerLibros.position.pixels >=
        _scrollControllerLibros.position.maxScrollExtent - 200) {
      context.read<AdminLibrosCubit>().loadMoreLibros();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollControllerLibros.dispose();
    _scrollControllerCategorias.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminLibrosCubit>().searchLibros(query);
  }

  void _showLibroCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => LibroFormDialog(
        onSave: (request) async {
          return await context.read<AdminLibrosCubit>().createLibro(request);
        },
      ),
    );
  }

  void _showLibroEditDialog(AdminLibro libro) {
    showDialog(
      context: context,
      builder: (dialogContext) => LibroFormDialog(
        libro: libro,
        onSave: (request) async {
          return await context.read<AdminLibrosCubit>().updateLibro(libro.id, request);
        },
      ),
    );
  }

  void _showLibroDeleteDialog(AdminLibro libro) {
    showDialog(
      context: context,
      builder: (dialogContext) => LibroDeleteDialog(
        libro: libro,
        onConfirm: () async {
          return await context.read<AdminLibrosCubit>().deleteLibro(libro.id);
        },
      ),
    );
  }

  void _showCategoriaCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoriaFormDialog(
        onSave: (request) async {
          return await context.read<AdminCategoriasCubit>().createCategoria(request);
        },
      ),
    );
  }

  void _showCategoriaEditDialog(AdminCategoria categoria) {
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

  void _showCategoriaDeleteDialog(AdminCategoria categoria) {
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
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Libros'),
            Tab(text: 'Categorías'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLibrosTab(),
              _buildCategoriasTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibrosTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por título o autor...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _onSearch,
                ),
              ),
              IconButton.filled(
                onPressed: _showLibroCreateDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Nuevo Libro',
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<AdminLibrosCubit, AdminLibrosState>(
            builder: (context, state) {
              if (state is AdminLibrosLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminLibrosError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AdminLibrosCubit>().loadLibros();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }
              if (state is AdminLibrosLoaded) {
                return _buildLibrosList(state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLibrosList(AdminLibrosLoaded state) {
    if (state.libros.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron libros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminLibrosCubit>().refresh();
      },
      child: ListView.builder(
        controller: _scrollControllerLibros,
        padding: const EdgeInsets.all(16),
        itemCount: state.libros.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.libros.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final libro = state.libros.items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LibroCard(
              libro: libro,
              onEdit: () => _showLibroEditDialog(libro),
              onDelete: () => _showLibroDeleteDialog(libro),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriasTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.filled(
                onPressed: _showCategoriaCreateDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Nueva Categoría',
              ),
            ],
          ),
        ),
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
              'No hay categorías',
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
        controller: _scrollControllerCategorias,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categorias.items.length,
        itemBuilder: (context, index) {
          final categoria = state.categorias.items[index];
          return _CategoriaCard(
            categoria: categoria,
            onEdit: () => _showCategoriaEditDialog(categoria),
            onDelete: () => _showCategoriaDeleteDialog(categoria),
          );
        },
      ),
    );
  }
}

class _LibroCard extends StatelessWidget {
  final AdminLibro libro;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LibroCard({
    required this.libro,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCover(context),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: libro.activo
                            ? Colors.green.withValues(alpha: 0.9)
                            : Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        libro.activo ? 'Activo' : 'Inactivo',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (libro.descripcion != null && libro.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        libro.descripcion!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (libro.portadaBase64 != null && libro.portadaBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(libro.portadaBase64!),
          width: 80,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        );
      } catch (_) {
        return _buildPlaceholder(context);
      }
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 80,
      height: 120,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.category, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          categoria.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _buildBadge(context),
                    ],
                  ),
                  if (categoria.descripcion != null && categoria.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      categoria.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${categoria.cantidadLibros} libros',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Categoría',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.blue,
        ),
      ),
    );
  }
}
