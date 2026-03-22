import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:open_books_mobile/features/auth/data/models/rol.dart';
import 'package:open_books_mobile/features/auth/data/repositories/roles_repository.dart';
import 'package:open_books_mobile/features/admin/usuarios/data/models/admin_usuario.dart';

class UsuarioFormDialog extends StatefulWidget {
  final AdminUsuario? usuario;
  final List<Rol> roles;
  final Future<bool> Function(dynamic request) onSave;

  const UsuarioFormDialog({
    super.key,
    this.usuario,
    required this.roles,
    required this.onSave,
  });

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _nombreCompletoController;
  late final TextEditingController _contrasenaController;
  late int _selectedRolId;
  late bool _estado;
  bool _isLoading = false;
  List<Rol> _roles = [];
  bool _isLoadingRoles = true;

  bool get isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.usuario?.userName ?? '');
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _nombreCompletoController = TextEditingController(text: widget.usuario?.nombreCompleto ?? '');
    _contrasenaController = TextEditingController();
    
    _roles = widget.roles;
    _isLoadingRoles = widget.roles.isEmpty;
    
    final initialRolId = widget.usuario?.rolId ?? (_roles.isNotEmpty ? _roles.first.id : 2);
    _selectedRolId = _roles.any((r) => r.id == initialRolId) ? initialRolId : (_roles.isNotEmpty ? _roles.first.id : 2);
    _estado = widget.usuario?.estado ?? true;
    
    if (_roles.isEmpty) {
      _loadRoles();
    }
  }

  Future<void> _loadRoles() async {
    try {
      final rolesRepository = GetIt.instance<RolesRepository>();
      final roles = await rolesRepository.getRoles();
      if (mounted) {
        setState(() {
          _roles = roles;
          _isLoadingRoles = false;
          if (_roles.isNotEmpty && !_roles.any((r) => r.id == _selectedRolId)) {
            _selectedRolId = _roles.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoles = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _nombreCompletoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;
    if (isEditing) {
      final request = UpdateUsuarioRequest(
        userName: _userNameController.text,
        email: _emailController.text,
        nombreCompleto: _nombreCompletoController.text,
        rolId: _selectedRolId,
        estado: _estado,
      );
      success = await widget.onSave(request);
    } else {
      final request = CreateUsuarioRequest(
        userName: _userNameController.text,
        email: _emailController.text,
        contrasena: _contrasenaController.text,
        rolId: _selectedRolId,
        nombreCompleto: _nombreCompletoController.text,
      );
      success = await widget.onSave(request);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de usuario es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreCompletoController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre completo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'El email no es válido';
                    }
                    return null;
                  },
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contrasenaController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (!isEditing && (value == null || value.isEmpty)) {
                        return 'La contraseña es requerida';
                      }
                      if (!isEditing && value != null && value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                if (_isLoadingRoles)
                  const Center(child: CircularProgressIndicator())
                else if (_roles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text('No hay roles disponibles', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _roles.any((r) => r.id == _selectedRolId) 
                        ? _selectedRolId 
                        : (_roles.isNotEmpty ? _roles.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: _roles.map((rol) {
                      return DropdownMenuItem(
                        value: rol.id,
                        child: Text(rol.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRolId = value);
                      }
                    },
                  ),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Activo'),
                    value: _estado,
                    onChanged: (value) {
                      setState(() => _estado = value);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
