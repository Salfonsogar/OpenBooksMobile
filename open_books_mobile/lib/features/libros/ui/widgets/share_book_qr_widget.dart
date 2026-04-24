import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareBookQrWidget extends StatelessWidget {
  final int libroId;
  final String titulo;
  final String autor;
  final double? size;
  final VoidCallback? onShare;

  const ShareBookQrWidget({
    super.key,
    required this.libroId,
    required this.titulo,
    required this.autor,
    this.size,
    this.onShare,
  });

  String get _qrData {
    final data = {
      'libroId': libroId,
      'titulo': titulo,
      'autor': autor,
      'v': 1,
    };
    return jsonEncode(data);
  }

  Future<void> _shareQr() async {
    try {
      await Clipboard.setData(ClipboardData(text: _qrData));
      onShare?.call();
    } catch (e) {
      debugPrint('Error copying QR to clipboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSize = size ?? 200.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: effectiveSize - 32,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (autor.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            autor,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _shareQr,
          icon: const Icon(Icons.share),
          label: const Text('Compartir QR'),
        ),
      ],
    );
  }
}

class ShareBookQrDialog extends StatelessWidget {
  final int libroId;
  final String titulo;
  final String autor;

  const ShareBookQrDialog({
    super.key,
    required this.libroId,
    required this.titulo,
    required this.autor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ShareBookQrWidget(
          libroId: libroId,
          titulo: titulo,
          autor: autor,
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR copiado al portapapeles'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}