import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';
import '../../logic/validators.dart';
import '../widgets/auth_error_banner.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreUsuarioController = TextEditingController();
  final _nombreCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final int _rolId = 2;

  String? _nombreUsuarioError;
  String? _nombreCompletoError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _registerError;

  void _validateNombreUsuario() {
    setState(() {
      _nombreUsuarioError = AuthValidators.validateRequired(
        _nombreUsuarioController.text, 'nombre de usuario',
      ) ?? AuthValidators.validateMinLength(
        _nombreUsuarioController.text, 3, 'nombre de usuario',
      );
    });
  }

  void _validateNombreCompleto() {
    setState(() {
      _nombreCompletoError = AuthValidators.validateRequired(
        _nombreCompletoController.text, 'nombre completo',
      );
    });
  }

  void _validateEmail() {
    setState(() => _emailError = AuthValidators.validateEmail(_emailController.text));
  }

  void _validatePassword() {
    setState(() => _passwordError = AuthValidators.validatePassword(_passwordController.text));
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = AuthValidators.validateConfirmPassword(
        _confirmPasswordController.text, _passwordController.text,
      );
    });
  }

  void _clearErrors() {
    setState(() {
      _registerError = null;
    });
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _nombreCompletoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    _validateNombreUsuario();
    _validateNombreCompleto();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (_nombreUsuarioError != null ||
        _nombreCompletoError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    _clearErrors();

    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            nombreUsuario: _nombreUsuarioController.text.trim(),
            correo: _emailController.text.trim(),
            contrasena: _passwordController.text,
            rolId: _rolId,
            nombreCompleto: _nombreCompletoController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Crear Cuenta',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            context.go('/home');
          } else if (state is AuthError) {
            setState(() {
              _registerError = state.message;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreUsuarioController,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _validateNombreUsuario(),
                    onEditingComplete: () => _validateNombreUsuario(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) => null,
                  ),
                  if (_nombreUsuarioError != null) AuthErrorBanner(message: _nombreUsuarioError!),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nombreCompletoController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) => _validateNombreCompleto(),
                    onEditingComplete: () => _validateNombreCompleto(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) => null,
                  ),
                  if (_nombreCompletoError != null) AuthErrorBanner(message: _nombreCompletoError!),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _validateEmail(),
                    onEditingComplete: () => _validateEmail(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) => null,
                  ),
                  if (_emailError != null) AuthErrorBanner(message: _emailError!),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _validatePassword(),
                    onEditingComplete: () => _validatePassword(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) => null,
                  ),
                  if (_passwordError != null) AuthErrorBanner(message: _passwordError!),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _validateConfirmPassword(),
                    onEditingComplete: () => _validateConfirmPassword(),
                    onFieldSubmitted: (_) => _onRegister(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (value) => null,
                  ),
                  if (_confirmPasswordError != null) AuthErrorBanner(message: _confirmPasswordError!),
                  if (_registerError != null) ...[
                    const SizedBox(height: 16),
                    AuthErrorBanner(message: _registerError!),
                  ],
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                'Crear Cuenta',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta?',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Inicia Sesión',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}