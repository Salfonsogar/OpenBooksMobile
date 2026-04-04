import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/create_user_libro.dart';
import '../../data/repositories/user_libros_repository.dart';

abstract class UploadLibroState extends Equatable {
  const UploadLibroState();

  @override
  List<Object?> get props => [];
}

class UploadLibroInitial extends UploadLibroState {}

class UploadLibroLoading extends UploadLibroState {}

class UploadLibroSuccess extends UploadLibroState {}

class UploadLibroError extends UploadLibroState {
  final String message;

  const UploadLibroError(this.message);

  @override
  List<Object> get props => [message];
}

class UploadLibroCubit extends Cubit<UploadLibroState> {
  final UserLibrosRepository _repository;

  UploadLibroCubit({UserLibrosRepository? repository})
      : _repository = repository ?? UserLibrosRepository(),
        super(UploadLibroInitial());

  Future<bool> subirLibro({
    required String titulo,
    required String autor,
    String? descripcion,
    required List<int> categoriasIds,
    String? portadaBase64,
    String? archivoBase64,
    String? nombreArchivo,
  }) async {
    emit(UploadLibroLoading());

    try {
      final request = CreateUserLibroRequest(
        titulo: titulo,
        autor: autor,
        descripcion: descripcion,
        categoriasIds: categoriasIds,
        portadaBase64: portadaBase64,
        archivoBase64: archivoBase64,
        nombreArchivo: nombreArchivo,
      );

      final success = await _repository.crearLibro(request);

      if (success) {
        emit(UploadLibroSuccess());
        return true;
      } else {
        emit(const UploadLibroError('Error al subir el libro'));
        return false;
      }
    } catch (e) {
      emit(UploadLibroError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  void reset() {
    emit(UploadLibroInitial());
  }
}
