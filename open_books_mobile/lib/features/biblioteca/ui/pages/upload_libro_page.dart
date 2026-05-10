import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import '../../logic/cubit/upload_libro_cubit.dart';
import '../../logic/upload_libro_controller.dart';
import '../widgets/archivo_picker_widget.dart';
import '../widgets/categoria_selector_sheet.dart';
import '../widgets/portada_picker_widget.dart';
import '../widgets/upload_form_field.dart';

class UploadLibroPage extends StatefulWidget {
  const UploadLibroPage({super.key});

  @override
  State<UploadLibroPage> createState() => _UploadLibroPageState();
}

class _UploadLibroPageState extends State<UploadLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _controller = UploadLibroController();

  List<int> _selectedCategoriaIds = [];
  String? _portadaBase64;
  String? _archivoBase64;
  String? _nombreArchivo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<AdminCategoriasCubit>().loadCategorias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickPortada() async {
    final result = await _controller.pickPortada();
    if (result.portadaBase64 != null) {
      setState(() => _portadaBase64 = result.portadaBase64);
    }
  }

  Future<void> _pickArchivo() async {
    final result = await _controller.pickArchivo();
    if (result.archivoBase64 != null) {
      setState(() {
        _archivoBase64 = result.archivoBase64;
        _nombreArchivo = result.nombreArchivo;
      });
    }
  }

  void _showCategoriaSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminCategoriasCubit>(),
        child: CategoriaSelectorSheet(
          selectedIds: _selectedCategoriaIds,
          onSelected: (ids) {
            setState(() => _selectedCategoriaIds = ids);
          },
        ),
      ),
    );
  }

  Future<void> _subir() async {
    if (!_formKey.currentState!.validate()) return;
    if (_archivoBase64 == null || _archivoBase64!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo del libro es requerido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _controller.subirLibro(
      cubit: context.read<UploadLibroCubit>(),
      titulo: _tituloController.text,
      autor: _autorController.text,
      descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
      categoriasIds: _selectedCategoriaIds,
      portadaBase64: _portadaBase64,
      archivoBase64: _archivoBase64,
      nombreArchivo: _nombreArchivo,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro subido exitosamente')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text('Subir Libro'),
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<UploadLibroCubit, UploadLibroState>(
        listener: (context, state) {
          if (state is UploadLibroError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              UploadFormField(
                labelText: 'Título',
                controller: _tituloController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              UploadFormField(
                labelText: 'Autor',
                controller: _autorController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El autor es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              UploadFormField(
                labelText: 'Descripción (opcional)',
                controller: _descripcionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showCategoriaSelector,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Categorías',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    fillColor: colorScheme.surfaceContainerHighest,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategoriaIds.isEmpty
                            ? 'Seleccionar categorías'
                            : '${_selectedCategoriaIds.length} seleccionada(s)',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Portada (opcional)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              PortadaPickerWidget(
                portadaBase64: _portadaBase64,
                onPick: _pickPortada,
                onClear: () => setState(() => _portadaBase64 = null),
              ),
              const SizedBox(height: 24),
              Text(
                'Archivo del libro (PDF o EPUB)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ArchivoPickerWidget(
                nombreArchivo: _nombreArchivo,
                archivoSeleccionado: _archivoBase64 != null,
                onPick: _pickArchivo,
                onClear: () => setState(() {
                  _archivoBase64 = null;
                  _nombreArchivo = null;
                }),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _subir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Subir Libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

