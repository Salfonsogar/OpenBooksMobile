import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppNotification extends Equatable {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final DateTime createdAt;
  final bool leida;

  const AppNotification({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.createdAt,
    this.leida = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: json['titulo'] ?? 'Notificación',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? 'sistema',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      leida: json['leida'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'createdAt': createdAt.toIso8601String(),
      'leida': leida,
    };
  }

  IconData get icon {
    switch (tipo) {
      case 'sancion':
        return Icons.warning_rounded;
      case 'sugerencia':
        return Icons.lightbulb_rounded;
      case 'libro':
        return Icons.menu_book_rounded;
      case 'sistema':
        return Icons.settings_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color? getColorPorTipo(BuildContext context) {
    switch (tipo) {
      case 'sancion':
        return Colors.red;
      case 'sugerencia':
        return Colors.green;
      case 'libro':
        return Theme.of(context).colorScheme.primary;
      case 'sistema':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  AppNotification copyWith({
    String? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    DateTime? createdAt,
    bool? leida,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      leida: leida ?? this.leida,
    );
  }

  @override
  List<Object?> get props => [id, titulo, mensaje, tipo, createdAt, leida];
}
