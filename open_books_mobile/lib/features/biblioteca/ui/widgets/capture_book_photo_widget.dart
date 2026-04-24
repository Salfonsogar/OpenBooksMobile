import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CaptureBookPhotoWidget extends StatefulWidget {
  final String? initialImageBase64;
  final Function(String base64Image) onImageCaptured;
  final VoidCallback? onImageRemoved;

  const CaptureBookPhotoWidget({
    super.key,
    this.initialImageBase64,
    required this.onImageCaptured,
    this.onImageRemoved,
  });

  @override
  State<CaptureBookPhotoWidget> createState() => _CaptureBookPhotoWidgetState();
}

class _CaptureBookPhotoWidgetState extends State<CaptureBookPhotoWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _currentImageBase64;

  @override
  void initState() {
    super.initState();
    _currentImageBase64 = widget.initialImageBase64;
  }

  @override
  void didUpdateWidget(CaptureBookPhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageBase64 != oldWidget.initialImageBase64) {
      _currentImageBase64 = widget.initialImageBase64;
    }
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final base64 = base64Encode(bytes);
        setState(() {
          _currentImageBase64 = base64;
        });
        widget.onImageCaptured(base64);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar foto: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _currentImageBase64 = null;
    });
    widget.onImageRemoved?.call();
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _currentImageBase64 != null && _currentImageBase64!.isNotEmpty;

    if (hasImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(_currentImageBase64!),
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.white,
                    onPressed: _showSourcePicker,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.white,
                    onPressed: _removeImage,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _showSourcePicker,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar foto',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}