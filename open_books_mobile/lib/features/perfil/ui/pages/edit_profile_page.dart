import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/data/models/usuario.dart';
import '../../logic/cubit/perfil_cubit.dart';
import '../../../../shared/ui/widgets/close_header.dart';
import '../../../../shared/ui/widgets/options_list.dart';

class EditProfilePage extends StatefulWidget {
  final Usuario usuario;

  const EditProfilePage({super.key, required this.usuario});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _userNameController;
  late final TextEditingController _nombreCompletoController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _newPasswordController;

  String? _fotoPerfilBase64;
  Uint8List? _fotoPerfilBytes;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.usuario.userName);
    _nombreCompletoController = TextEditingController(
      text: widget.usuario.nombreCompleto,
    );
    _emailController = TextEditingController(text: widget.usuario.email);
    _passwordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _fotoPerfilBase64 = widget.usuario.fotoPerfilBase64;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _nombreCompletoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _fotoPerfilBytes = bytes;
        _fotoPerfilBase64 = base64Encode(bytes);
      });
    }
  }

  void _saveGeneral() {
    final userName = _userNameController.text.trim();
    final nombreCompleto = _nombreCompletoController.text.trim();

    if (userName.isEmpty &&
        nombreCompleto.isEmpty &&
        _fotoPerfilBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
      );
      return;
    }

    context.read<PerfilCubit>().actualizarPerfil(
      userName: userName.isNotEmpty ? userName : null,
      nombreCompleto: nombreCompleto.isNotEmpty ? nombreCompleto : null,
      fotoPerfilBase64: _fotoPerfilBase64,
    );
  }

  void _showEmailSection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cambiar correo', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Nuevo correo',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                      ),
                    );
                    return;
                  }
                  context.read<PerfilCubit>().actualizarCorreo(
                    email: email,
                    contrasena: password,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Actualizar correo'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPasswordSection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cambiar contraseña',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final password = _passwordController.text.trim();
                  final newPassword = _newPasswordController.text.trim();
                  if (password.isEmpty || newPassword.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                      ),
                    );
                    return;
                  }
                  if (newPassword.length < 6) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La contraseña debe tener al menos 6 caracteres',
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<PerfilCubit>().actualizarContrasena(
                    contrasenaActual: password,
                    nuevaContrasena: newPassword,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Actualizar contraseña'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseHeader(onClose: () => context.go('/profile')),
      body: BlocConsumer<PerfilCubit, PerfilState>(
        listener: (context, state) {
          if (state is PerfilLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cambios guardados correctamente')),
            );
          } else if (state is PerfilError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is PerfilLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información personal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileImage(),
                const SizedBox(height: 24),
                TextField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreCompletoController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveGeneral,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Seguridad',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                OptionsList(
                  options: [
                    OptionItem(
                      icon: Icons.email,
                      title: 'Cambiar correo',
                      onTap: _showEmailSection,
                    ),
                    OptionItem(
                      icon: Icons.lock,
                      title: 'Cambiar contraseña',
                      onTap: _showPasswordSection,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: _fotoPerfilBytes != null
                ? MemoryImage(_fotoPerfilBytes!)
                : _fotoPerfilBase64 != null && _fotoPerfilBase64!.isNotEmpty
                ? MemoryImage(base64Decode(_fotoPerfilBase64!))
                : null,
            child:
                _fotoPerfilBytes == null &&
                    (_fotoPerfilBase64 == null || _fotoPerfilBase64!.isEmpty)
                ? Text(
                    widget.usuario.userName.isNotEmpty
                        ? widget.usuario.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 36),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 18),
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
