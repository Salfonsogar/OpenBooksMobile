import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:open_books_mobile/features/auth/data/models/rol.dart';
import 'package:open_books_mobile/features/auth/data/repositories/roles_repository.dart';
import 'package:open_books_mobile/shared/core/session/session_cubit.dart';
import 'package:open_books_mobile/shared/core/session/session_state.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_cubit.dart';
import 'package:open_books_mobile/features/admin/usuarios/logic/cubit/admin_usuarios_state.dart';
import 'package:open_books_mobile/features/admin/usuarios/data/models/admin_usuario.dart';
import 'package:open_books_mobile/features/admin/usuarios/ui/widgets/usuario_form_dialog.dart';
import 'package:open_books_mobile/features/admin/usuarios/ui/widgets/usuario_delete_dialog.dart';
import 'package:open_books_mobile/features/admin/moderacion/data/models/admin_rol.dart';
import 'package:open_books_mobile/features/admin/moderacion/logic/cubit/admin_roles_cubit.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/rol_form_dialog.dart';
import 'package:open_books_mobile/features/admin/moderacion/ui/widgets/rol_delete_dialog.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<Rol> _roles = [];
  bool _isLoadingRoles = true;
  bool _scrollListenersAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCubits();
    _loadRoles();
    _attachScrollListeners();
  }

  void _initCubits() {
    final sessionState = context.read<SessionCubit>().state;
    if (sessionState is SessionAuthenticated) {
      context.read<AdminUsuariosCubit>().setToken(sessionState.token);
      context.read<AdminRolesCubit>().setToken(sessionState.token);
    }
    context.read<AdminUsuariosCubit>().loadUsuarios();
    context.read<AdminRolesCubit>().loadRoles();
  }

  void _attachScrollListeners() {
    if (_scrollListenersAttached) return;
    _scrollListenersAttached = true;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminUsuariosCubit>().loadMoreUsuarios();
    }
  }

  Future<void> _loadRoles() async {
    final rolesRepository = GetIt.instance<RolesRepository>();
    final roles = await rolesRepository.getRoles();
    if (mounted) {
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    }
  }

  void _onSearch(String query) {
    context.read<AdminUsuariosCubit>().searchUsuarios(query);
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => UsuarioFormDialog(
        roles: _roles,
        onSave: (request) async {
          final cubit = this.context.read<AdminUsuariosCubit>();
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
        roles: _roles,
        onSave: (request) async {
          final cubit = this.context.read<AdminUsuariosCubit>();
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
          final cubit = this.context.read<AdminUsuariosCubit>();
          return await cubit.deleteUsuario(usuario.id);
        },
      ),
    );
  }

  void _showRolCreateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => RolFormDialog(
        onSave: (request) async {
          return await context.read<AdminRolesCubit>().createRol(request);
        },
      ),
    );
  }

  void _showRolEditDialog(AdminRol rol) {
    showDialog(
      context: context,
      builder: (dialogContext) => RolFormDialog(
        rol: rol,
        onSave: (request) async {
          return await context.read<AdminRolesCubit>().updateRol(rol.id, request);
        },
      ),
    );
  }

  void _showRolDeleteDialog(AdminRol rol) {
    showDialog(
      context: context,
      builder: (dialogContext) => RolDeleteDialog(
        rol: rol,
        onConfirm: () async {
          return await context.read<AdminRolesCubit>().deleteRol(rol.id);
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
            Tab(text: 'Roles'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsuariosTab(),
              _buildRolesTab(),
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
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, usuario o email...',
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
                onPressed: _isLoadingRoles ? null : _showCreateDialog,
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AdminUsuariosCubit>().loadUsuarios();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron usuarios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
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

  Widget _buildRolesTab() {
    return BlocBuilder<AdminRolesCubit, AdminRolesState>(
      builder: (context, state) {
        if (state is AdminRolesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminRolesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminRolesCubit>().loadRoles();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is AdminRolesLoaded) {
          return _buildRolesList(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRolesList(AdminRolesLoaded state) {
    if (state.roles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay roles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.filled(
                onPressed: _showRolCreateDialog,
                icon: const Icon(Icons.add),
                tooltip: 'Nuevo Rol',
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<AdminRolesCubit>().loadRoles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.roles.length,
              itemBuilder: (context, index) {
                final rol = state.roles[index];
                return _RolCard(
                  rol: rol,
                  onEdit: () => _showRolEditDialog(rol),
                  onDelete: () => _showRolDeleteDialog(rol),
                );
              },
            ),
          ),
        ),
      ],
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

class _RolCard extends StatelessWidget {
  final AdminRol rol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RolCard({
    required this.rol,
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
                color: rol.isAdministrador
                    ? Colors.purple.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                rol.isAdministrador ? Icons.admin_panel_settings : Icons.badge,
                color: rol.isAdministrador ? Colors.purple : Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rol.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${rol.id}',
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
}
