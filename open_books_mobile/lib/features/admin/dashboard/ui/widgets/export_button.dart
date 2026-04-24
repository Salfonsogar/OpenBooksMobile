import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportButton extends StatefulWidget {
  final GlobalKey repaintKey;
  final String title;

  const ExportButton({
    super.key,
    required this.repaintKey,
    this.title = 'Exportar Dashboard',
  });

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _isExporting = false;

  Future<void> _exportAndShare() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final boundary = widget.repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        _showSnackBar('Error: No se pudo capturar el dashboard');
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        _showSnackBar('Error: No se pudo generar la imagen');
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/dashboard_$timestamp.png');

      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Dashboard Analytics - OpenBooks',
          subject: 'Reporte de Estadísticas',
        ),
      );

      if (mounted) {
        _showSnackBar('Dashboard exportado correctamente');
      }
    } catch (e) {
      _showSnackBar('Error al exportar: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isExporting ? null : _exportAndShare,
      icon: _isExporting
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.share, size: 18),
      label: Text(_isExporting ? 'Exportando...' : widget.title),
    );
  }
}