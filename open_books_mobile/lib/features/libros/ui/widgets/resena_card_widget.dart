import 'package:flutter/material.dart';

import '../../data/models/index.dart';
import '../pages/book_detail_dialogs.dart';
import '../pages/book_detail_utils.dart';

class ResenaCardWidget extends StatelessWidget {
  final Resena resena;

  const ResenaCardWidget({
    super.key,
    required this.resena,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context),
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
                        formatDate(resena.fecha),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDenunciaButton(context),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.texto),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        resena.nombreUsuario.isNotEmpty ? resena.nombreUsuario[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildDenunciaButton(BuildContext context) {
    return Builder(
      builder: (innerContext) {
        return IconButton(
          icon: const Icon(Icons.flag_outlined, size: 20),
          onPressed: () => showDenunciaResenaDialog(innerContext, resena),
          tooltip: 'Denunciar reseña',
          color: Theme.of(context).colorScheme.error,
        );
      },
    );
  }
}