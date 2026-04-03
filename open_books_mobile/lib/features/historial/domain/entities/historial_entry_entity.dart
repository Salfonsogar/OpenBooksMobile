import 'package:equatable/equatable.dart';

class HistorialEntryEntity extends Equatable {
  final int id;
  final int libroId;
  final int usuarioId;
  final String titulo;
  final String? autor;
  final String? portadaBase64;
  final DateTime ultimaLectura;
  final String status;
  final DateTime createdAt;

  const HistorialEntryEntity({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.titulo,
    this.autor,
    this.portadaBase64,
    required this.ultimaLectura,
    this.status = 'synced',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        libroId,
        usuarioId,
        titulo,
        autor,
        portadaBase64,
        ultimaLectura,
        status,
        createdAt,
      ];

  HistorialEntryEntity copyWith({
    int? id,
    int? libroId,
    int? usuarioId,
    String? titulo,
    String? autor,
    String? portadaBase64,
    DateTime? ultimaLectura,
    String? status,
    DateTime? createdAt,
  }) {
    return HistorialEntryEntity(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      portadaBase64: portadaBase64 ?? this.portadaBase64,
      ultimaLectura: ultimaLectura ?? this.ultimaLectura,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
