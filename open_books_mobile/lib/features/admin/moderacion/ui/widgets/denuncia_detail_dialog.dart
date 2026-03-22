import 'package:flutter/material.dart';

import '../../data/models/admin_denuncia.dart';

class DenunciaDetailDialog extends StatelessWidget {
  final AdminDenuncia denuncia;

  const DenunciaDetailDialog({
    super.key,
    required this.denuncia,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalle de Denuncia'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Motivo', denuncia.motivo),
              const SizedBox(height: 16),
              _buildInfoRow('Denunciante', denuncia.nombreUsuarioDenunciante),
              const SizedBox(height: 16),
              _buildInfoRow('Denunciado', denuncia.nombreUsuarioDenunciado),
              const SizedBox(height: 16),
              _buildInfoRow('Fecha', _formatDate(denuncia.fechaCreacion)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  denuncia.descripcion ?? 'Sin descripción',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
