import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/core/constants/app_constants.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;
  String? _emailError;
  String? _passwordError;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );

  void _validateEmail() {
    final value = _emailController.text;
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Ingresa tu correo electrónico';
      } else if (!_emailRegex.hasMatch(value)) {
        _emailError = 'Ingresa un correo electrónico válido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    final value = _passwordController.text;
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Ingresa tu contraseña';
      } else if (!_passwordRegex.hasMatch(value)) {
        _passwordError = 'Mínimo 8 caracteres, mayúscula, minúscula y carácter especial';
      } else {
        _passwordError = null;
      }
    });
  }

  void _clearErrors() {
    setState(() {
      _loginError = null;
      _emailError = null;
      _passwordError = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    _validateEmail();
    _validatePassword();
    
    if (_emailError != null || _passwordError != null) {
      return;
    }
    
    _clearErrors();
    
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            context.go('/home');
          } else if (state is AuthError) {
            setState(() {
              _loginError = state.message;
            });
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu biblioteca personal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
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
                    if (_emailError != null) _buildErrorWidget(_emailError!),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _validatePassword(),
                      onEditingComplete: () => _validatePassword(),
                      onFieldSubmitted: (_) => _onLogin(),
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
                    if (_passwordError != null) _buildErrorWidget(_passwordError!),
                    if (_loginError != null) ...[
                      const SizedBox(height: 8),
                      _buildErrorWidget(_loginError!),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/recovery'),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onLogin,
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
                                  'Iniciar Sesión',
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
                          '¿No tienes cuenta?',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Regístrate',
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
      ),
    );
  }
}