import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../admin/categorias/logic/cubit/admin_categorias_cubit.dart';
import '../../logic/cubit/upload_libro_cubit.dart';

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
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _portadaBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _pickArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf'],
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _archivoBase64 = base64Encode(file.bytes!);
          _nombreArchivo = file.name;
        });
      }
    }
  }

  void _showCategoriaSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminCategoriasCubit>(),
        child: _CategoriaSelectorSheet(
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

    final success = await context.read<UploadLibroCubit>().subirLibro(
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
              TextFormField(
                controller: _tituloController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Título',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  errorStyle: TextStyle(color: colorScheme.error),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autorController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Autor',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  errorStyle: TextStyle(color: colorScheme.error),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El autor es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  fillColor: colorScheme.surfaceContainerHighest,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
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
              InkWell(
                onTap: _pickPortada,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _portadaBase64 != null
                      ? Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(_portadaBase64!),
                                  height: 140,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(Icons.close, color: colorScheme.onSurface),
                                onPressed: () => setState(() => _portadaBase64 = null),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text(
                                'Toca para seleccionar imagen',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Archivo del libro (PDF o EPUB)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickArchivo,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _archivoBase64 != null
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book, size: 40, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _nombreArchivo ?? 'Archivo seleccionado',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colorScheme.onSurface),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: colorScheme.onSurface),
                                onPressed: () => setState(() {
                                  _archivoBase64 = null;
                                  _nombreArchivo = null;
                                }),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 40, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text(
                                'Toca para seleccionar archivo',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                ),
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

class _CategoriaSelectorSheet extends StatefulWidget {
  final List<int> selectedIds;
  final Function(List<int>) onSelected;

  const _CategoriaSelectorSheet({
    required this.selectedIds,
    required this.onSelected,
  });

  @override
  State<_CategoriaSelectorSheet> createState() => _CategoriaSelectorSheetState();
}

class _CategoriaSelectorSheetState extends State<_CategoriaSelectorSheet> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seleccionar Categorías',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onSelected(_tempSelected);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Aceptar',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outline),
              Expanded(
                child: BlocBuilder<AdminCategoriasCubit, AdminCategoriasState>(
                  builder: (context, state) {
                    if (state is AdminCategoriasLoading) {
                      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                    }
                    
                    if (state is AdminCategoriasLoaded) {
                      if (state.categorias.items.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay categorías disponibles',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.categorias.items.length,
                        itemBuilder: (context, index) {
                          final categoria = state.categorias.items[index];
                          final isSelected = _tempSelected.contains(categoria.id);
                          
                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: colorScheme.primary,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _tempSelected.add(categoria.id);
                                } else {
                                  _tempSelected.remove(categoria.id);
                                }
                              });
                            },
                            title: Text(
                              categoria.nombre,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                            subtitle: Text(
                              '${categoria.cantidadLibros} libros',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                      );
                    }
                    
                    return Center(
                      child: Text(
                        'Error al cargar categorías',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
