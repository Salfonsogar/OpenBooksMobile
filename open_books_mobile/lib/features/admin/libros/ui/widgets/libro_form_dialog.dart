import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_libro.dart';
import '../../../categorias/logic/cubit/admin_categorias_cubit.dart';

class LibroFormDialog extends StatefulWidget {
  final AdminLibro? libro;
  final Future<bool> Function(dynamic request) onSave;

  const LibroFormDialog({
    super.key,
    this.libro,
    required this.onSave,
  });

  @override
  State<LibroFormDialog> createState() => _LibroFormDialogState();
}

class _LibroFormDialogState extends State<LibroFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _autorController;
  late final TextEditingController _descripcionController;
  late bool _activo;
  bool _isLoading = false;
  
  List<int> _selectedCategoriaIds = [];
  String? _portadaBase64;
  String? _archivoBase64;
  String? _nombreArchivo;
  String? _portadaFileName;

  bool get isEditing => widget.libro != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.libro?.titulo ?? '');
    _autorController = TextEditingController(text: widget.libro?.autor ?? '');
    _descripcionController = TextEditingController(text: widget.libro?.descripcion ?? '');
    _activo = widget.libro?.activo ?? true;
    
    if (widget.libro != null) {
      _selectedCategoriaIds = widget.libro!.categorias
          .whereType<int>()
          .toList();
    }
    
    context.read<AdminCategoriasCubit>().loadCategorias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isImage) async {
    // TODO: Implementar con file_picker o image_picker
    // Por ahora muestra un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isImage 
            ? 'Usa image_picker para seleccionar portada' 
            : 'Usa file_picker para seleccionar EPUB'),
      ),
    );
  }

  void _showCategoriaSelector() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminCategoriasCubit>(),
        child: _CategoriaSelectorDialog(
          selectedIds: _selectedCategoriaIds,
          onSelected: (ids) {
            setState(() => _selectedCategoriaIds = ids);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEditing && (_archivoBase64 == null || _archivoBase64!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo EPUB es requerido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    dynamic request;
    if (isEditing) {
      request = UpdateLibroRequest(
        titulo: _tituloController.text,
        autor: _autorController.text,
        descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        categoriasIds: _selectedCategoriaIds.isNotEmpty ? _selectedCategoriaIds : null,
        portadaBase64: _portadaBase64,
        activo: _activo,
      );
    } else {
      request = CreateLibroRequest(
        titulo: _tituloController.text,
        autor: _autorController.text,
        descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
        categoriasIds: _selectedCategoriaIds,
        portadaBase64: _portadaBase64,
        archivoBase64: _archivoBase64,
        nombreArchivo: _nombreArchivo,
      );
    }

    final success = await widget.onSave(request);

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
      title: Text(isEditing ? 'Editar Libro' : 'Subir Libro'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEditing) ...[
                  _buildFileDropZone(),
                  const SizedBox(height: 16),
                ],
                if (isEditing) ...[
                  _buildPortadaSelector(),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildCategoriaSelector(),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Activo'),
                    value: _activo,
                    onChanged: (value) {
                      setState(() => _activo = value);
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
              : Text(isEditing ? 'Guardar' : 'Subir'),
        ),
      ],
    );
  }

  Widget _buildFileDropZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            _archivoBase64 != null ? Icons.check_circle : Icons.upload_file,
            size: 48,
            color: _archivoBase64 != null 
                ? Colors.green 
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            _archivoBase64 != null 
                ? 'Archivo seleccionado'
                : 'Arrastra el archivo EPUB aquí',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_nombreArchivo != null) ...[
            const SizedBox(height: 4),
            Text(
              _nombreArchivo!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _pickFile(false),
            child: Text(_archivoBase64 != null ? 'Cambiar' : 'Seleccionar archivo'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortadaSelector() {
    return InkWell(
      onTap: () => _pickFile(true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _portadaBase64 != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        base64Decode(_portadaBase64!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portada',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _portadaFileName ?? 'Clic para cambiar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategoriaSelector,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCategoriaIds.isEmpty
                        ? 'Seleccionar categorías'
                        : '${_selectedCategoriaIds.length} categorías seleccionadas',
                    style: TextStyle(
                      color: _selectedCategoriaIds.isEmpty
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriaSelectorDialog extends StatefulWidget {
  final List<int> selectedIds;
  final Function(List<int>) onSelected;

  const _CategoriaSelectorDialog({
    required this.selectedIds,
    required this.onSelected,
  });

  @override
  State<_CategoriaSelectorDialog> createState() => _CategoriaSelectorDialogState();
}

class _CategoriaSelectorDialogState extends State<_CategoriaSelectorDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Categorías'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: BlocBuilder<AdminCategoriasCubit, AdminCategoriasState>(
          builder: (context, state) {
            if (state is AdminCategoriasLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminCategoriasLoaded) {
              return ListView.builder(
                itemCount: state.categorias.items.length,
                itemBuilder: (context, index) {
                  final categoria = state.categorias.items[index];
                  final isSelected = _tempSelected.contains(categoria.id);
                  return CheckboxListTile(
                    title: Text(categoria.nombre),
                    subtitle: Text('${categoria.cantidadLibros} libros'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _tempSelected.add(categoria.id);
                        } else {
                          _tempSelected.remove(categoria.id);
                        }
                      });
                    },
                  );
                },
              );
            }
            return const Center(child: Text('No hay categorías'));
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSelected(_tempSelected);
            Navigator.pop(context);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
