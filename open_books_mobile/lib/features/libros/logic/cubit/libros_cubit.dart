import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/models.dart';
import '../../data/repositories/libros_repository.dart';

abstract class LibrosState extends Equatable {
  const LibrosState();

  @override
  List<Object?> get props => [];
}

class LibrosInitial extends LibrosState {}

class LibrosLoading extends LibrosState {}

class LibrosLoaded extends LibrosState {
  final List<Libro> libros;
  final int page;
  final int totalPages;
  final bool hasMore;
  final String? query;
  final List<int>? categoriasSeleccionadas;
  final String? autor;

  const LibrosLoaded({
    required this.libros,
    this.page = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.query,
    this.categoriasSeleccionadas,
    this.autor,
  });

  @override
  List<Object?> get props => [libros, page, totalPages, hasMore, query, categoriasSeleccionadas, autor];

  LibrosLoaded copyWith({
    List<Libro>? libros,
    int? page,
    int? totalPages,
    bool? hasMore,
    String? query,
    List<int>? categoriasSeleccionadas,
    String? autor,
  }) {
    return LibrosLoaded(
      libros: libros ?? this.libros,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      categoriasSeleccionadas: categoriasSeleccionadas ?? this.categoriasSeleccionadas,
      autor: autor ?? this.autor,
    );
  }
}

class LibrosError extends LibrosState {
  final String message;

  const LibrosError(this.message);

  @override
  List<Object> get props => [message];
}

class LibrosCubit extends Cubit<LibrosState> {
  final LibrosRepository _repository;

  LibrosCubit(this._repository) : super(LibrosInitial());

  Future<void> cargarLibros({
    String? query,
    List<int>? categorias,
    String? autor,
    int page = 1,
    int pageSize = 10,
    bool refresh = false,
  }) async {
    final currentState = state;
    List<Libro> currentLibros = [];

    if (!refresh && currentState is LibrosLoaded && page > 1) {
      currentLibros = currentState.libros;
    }

    emit(LibrosLoading());
    try {
      final result = await _repository.getLibros(
        query: query,
        page: page,
        pageSize: pageSize,
        categorias: categorias,
        autor: autor,
      );

      final allLibros = (page == 1 || refresh) ? result.data : [...currentLibros, ...result.data];

      emit(LibrosLoaded(
        libros: allLibros,
        page: result.page,
        totalPages: result.totalPages,
        hasMore: result.page < result.totalPages,
        query: query,
        categoriasSeleccionadas: categorias,
        autor: autor,
      ));
    } catch (e) {
      emit(LibrosError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> cargarMasLibros() async {
    final currentState = state;
    if (currentState is! LibrosLoaded || !currentState.hasMore) return;

    await cargarLibros(
      query: currentState.query,
      categorias: currentState.categoriasSeleccionadas,
      autor: currentState.autor,
      page: currentState.page + 1,
      refresh: false,
    );
  }

  Future<void> buscarLibros(String query) async {
    await cargarLibros(query: query, refresh: true);
  }

  Future<void> filtrarPorCategoria(List<int> categorias) async {
    await cargarLibros(categorias: categorias, refresh: true);
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is LibrosLoaded) {
      await cargarLibros(
        query: currentState.query,
        categorias: currentState.categoriasSeleccionadas,
        autor: currentState.autor,
        refresh: true,
      );
    } else {
      await cargarLibros(refresh: true);
    }
  }
}
