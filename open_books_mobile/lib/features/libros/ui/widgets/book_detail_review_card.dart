import 'dart:convert';
import 'package:flutter/material.dart';

import '../../data/models/resena.dart';

class BookDetailReviewCard extends StatelessWidget {
  final Resena resena;
  final VoidCallback? onReport;

  const BookDetailReviewCard({
    super.key,
    required this.resena,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: resena.fotoPerfilBase64 != null
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(resena.fotoPerfilBase64!),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Text(
                              resena.nombreUsuario.isNotEmpty ? resena.nombreUsuario[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                      : Text(
                          resena.nombreUsuario.isNotEmpty ? resena.nombreUsuario[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 14),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resena.nombreUsuario,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _formatDate(resena.fecha),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onReport != null)
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 20),
                    onPressed: onReport,
                    tooltip: 'Denunciar',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.texto),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}