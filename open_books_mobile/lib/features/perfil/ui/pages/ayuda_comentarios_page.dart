import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/cubit/perfil_cubit.dart';
import '../../../../shared/ui/widgets/close_header.dart';

class AyudaComentariosPage extends StatelessWidget {
  const AyudaComentariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AyudaComentariosView();
  }
}

class _AyudaComentariosView extends StatefulWidget {
  const _AyudaComentariosView();

  @override
  State<_AyudaComentariosView> createState() => _AyudaComentariosViewState();
}

class _AyudaComentariosViewState extends State<_AyudaComentariosView> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  static const int _maxCaracteres = 500;
  static const int _minCaracteres = 10;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PerfilCubit, PerfilState>(
      listener: (context, state) {
        if (state is SugerenciaSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sugerencia enviada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _comentarioController.clear();
        } else if (state is PerfilError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      listenWhen: (previous, current) {
        if (previous is SugerenciaSending && current is SugerenciaSuccess) return true;
        if (current is PerfilError) return true;
        return false;
      },
      builder: (context, state) {
        final isLoading = state is SugerenciaSending;
        final texto = _comentarioController.text;
        final esValido = texto.trim().length >= _minCaracteres;

        return Scaffold(
          appBar: CloseHeader(
            title: 'Ayuda y comentarios',
            onClose: () => context.pop(),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Tienes alguna sugerencia o necesitas ayuda?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu opinión es importante para mejorar la app.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _comentarioController,
                    maxLines: 8,
                    maxLength: _maxCaracteres,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu sugerencia o comentario aquí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Escribe un comentario';
                      }
                      if (value.trim().length < _minCaracteres) {
                        return 'El comentario debe tener al menos $_minCaracteres caracteres';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading || !esValido
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<PerfilCubit>().enviarSugerencia(
                                  _comentarioController.text.trim(),
                                );
                              }
                            },
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : const Text('Enviar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recibirás una notificación cuando tu sugerencia sea procesada.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
