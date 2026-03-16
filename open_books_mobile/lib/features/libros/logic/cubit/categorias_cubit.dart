import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/models.dart';
import '../../data/repositories/libros_repository.dart';

abstract class CategoriasState extends Equatable {
  const CategoriasState();

  @override
  List<Object?> get props => [];
}

class CategoriasInitial extends CategoriasState {}

class CategoriasLoading extends CategoriasState {}

class CategoriasLoaded extends CategoriasState {
  final List<Categoria> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object> get props => [categorias];
}

class CategoriasError extends CategoriasState {
  final String message;

  const CategoriasError(this.message);

  @override
  List<Object> get props => [message];
}

class CategoriasCubit extends Cubit<CategoriasState> {
  final LibrosRepository _repository;

  CategoriasCubit(this._repository) : super(CategoriasInitial());

  Future<void> cargarCategorias() async {
    emit(CategoriasLoading());
    try {
      final result = await _repository.getCategorias();
      emit(CategoriasLoaded(result.data));
    } catch (e) {
      emit(CategoriasError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
