import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Roles deshabilitados - backend no tiene tabla de roles
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_state.dart';
import 'package:open_books_mobile/features/admin/usuarios/data/models/admin_usuario.dart';
import 'package:open_books_mobile/features/admin/usuarios/ui/widgets/usuario_form_dialog.dart';
import 'package:open_books_mobile/features/admin/usuarios/ui/widgets/usuario_delete_dialog.dart';
import 'package:open_books_mobile/features/admin/ui/widgets/admin_search_bar.dart';
import 'package:open_books_mobile/features/admin/ui/widgets/admin_error_view.dart';
import 'package:open_books_mobile/features/admin/ui/widgets/admin_empty_view.dart';
import 'package:open_books_mobile/features/admin/ui/widgets/admin_loading_more.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  bool _scrollListenersAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _initCubits();
    _attachScrollListeners();
  }

  void _initCubits() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminUsuariosCubit>().setToken(sessionState.token);
    }
    context.read<AdminUsuariosCubit>().loadUsuarios();
  }

  void _attachScrollListeners() {
    if (_scrollListenersAttached) return;
    _scrollListenersAttached = true;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminUsuariosCubit>().loadMoreUsuarios();
    }
  }

  void _onSearch(String query) {
    context.read<AdminUsuariosCubit>().searchUsuarios(query);
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => UsuarioFormDialog(
        roles: const [],
        onSave: (request) async {
          final cubit = context.read<AdminUsuariosCubit>();
          return await cubit.createUsuario(request as CreateUsuarioRequest);
        },
      ),
    );
  }

  void _showEditDialog(AdminUsuario usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => UsuarioFormDialog(
        usuario: usuario,
        roles: const [],
        onSave: (request) async {
          final cubit = context.read<AdminUsuariosCubit>();
          return await cubit.updateUsuario(usuario.id, request as UpdateUsuarioRequest);
        },
      ),
    );
  }

  void _showDeleteDialog(AdminUsuario usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => UsuarioDeleteDialog(
        usuario: usuario,
        onConfirm: () async {
          final cubit = context.read<AdminUsuariosCubit>();
          return await cubit.deleteUsuario(usuario.id);
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
            Tab(text: 'Usuarios'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsuariosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsuariosTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AdminSearchBar(
                hintText: 'Buscar por nombre, usuario o email...',
                onSearch: _onSearch,
              ),
              IconButton.filled(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Nuevo Usuario',
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<AdminUsuariosCubit, AdminUsuariosState>(
            builder: (context, state) {
              if (state is AdminUsuariosLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminUsuariosError) {
                return AdminErrorView(
                  message: state.message,
                  onRetry: () => context.read<AdminUsuariosCubit>().loadUsuarios(),
                );
              }
              if (state is AdminUsuariosLoaded) {
                return _buildUsuariosList(state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsuariosList(AdminUsuariosLoaded state) {
    if (state.usuarios.items.isEmpty) {
      return const AdminEmptyView(
        icon: Icons.people_outline,
        message: 'No se encontraron usuarios',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AdminUsuariosCubit>().refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.usuarios.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.usuarios.items.length) {
            return const AdminLoadingMore();
          }
          final usuario = state.usuarios.items[index];
          return _UsuarioCard(
            usuario: usuario,
            onEdit: () => _showEditDialog(usuario),
            onDelete: () => _showDeleteDialog(usuario),
          );
        },
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final AdminUsuario usuario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UsuarioCard({
    required this.usuario,
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
            _buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario.nombreCompleto,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _buildStatusBadge(context),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${usuario.userName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRoleBadge(context),
                      if (usuario.sancionado) ...[
                        const SizedBox(width: 8),
                        _buildSanctionBadge(context),
                      ],
                    ],
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

  Widget _buildAvatar() {
    if (usuario.fotoPerfilBase64 != null &&
        usuario.fotoPerfilBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(usuario.fotoPerfilBase64!);
        return CircleAvatar(
          radius: 28,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.deepPurple.withValues(alpha: 0.2),
      child: Text(
        usuario.nombreCompleto.isNotEmpty
            ? usuario.nombreCompleto[0].toUpperCase()
            : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isActive = usuario.estado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    final isAdmin = usuario.isAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.purple.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        usuario.nombreRol,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isAdmin ? Colors.purple : Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSanctionBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, size: 14, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            'Sancionado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}


