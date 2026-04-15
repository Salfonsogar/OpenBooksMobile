import 'package:equatable/equatable.dart';

class LibroBibliotecaEntity extends Equatable {
  final int id;
  final int libroId;
  final int usuarioId;
  final String titulo;
  final String autor;
  final String descripcion;
  final String? portadaBase64;
  final List<String> categorias;
  final double progreso;
  final bool isDownloaded;
  final int? page;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? syncStatus;
  final DateTime? lastReadAt;
  final int? readingStreak;

  const LibroBibliotecaEntity({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.titulo,
    required this.autor,
    required this.descripcion,
    this.portadaBase64,
    required this.categorias,
    this.progreso = 0.0,
    this.isDownloaded = false,
    this.page,
    this.updatedAt,
    this.createdAt,
    this.syncStatus,
    this.lastReadAt,
    this.readingStreak,
  });

  @override
  List<Object?> get props => [
        id,
        libroId,
        usuarioId,
        titulo,
        autor,
        descripcion,
        portadaBase64,
        categorias,
        progreso,
        isDownloaded,
        page,
        updatedAt,
        createdAt,
        syncStatus,
        lastReadAt,
        readingStreak,
      ];

  LibroBibliotecaEntity copyWith({
    int? id,
    int? libroId,
    int? usuarioId,
    String? titulo,
    String? autor,
    String? descripcion,
    String? portadaBase64,
    List<String>? categorias,
    double? progreso,
    bool? isDownloaded,
    int? page,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? syncStatus,
    DateTime? lastReadAt,
    int? readingStreak,
  }) {
    return LibroBibliotecaEntity(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      descripcion: descripcion ?? this.descripcion,
      portadaBase64: portadaBase64 ?? this.portadaBase64,
      categorias: categorias ?? this.categorias,
      progreso: progreso ?? this.progreso,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      page: page ?? this.page,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingStreak: readingStreak ?? this.readingStreak,
    );
  }
}
