import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/historial_repository.dart';
import '../../../libros/data/models/libro.dart';

abstract class HistorialState extends Equatable {
  const HistorialState();

  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialState {}

class HistorialLoading extends HistorialState {}

class HistorialLoaded extends HistorialState {
  final List<Libro> libros;

  const HistorialLoaded({required this.libros});

  @override
  List<Object> get props => [libros];
}

class HistorialError extends HistorialState {
  final String message;

  const HistorialError(this.message);

  @override
  List<Object> get props => [message];
}

class HistorialCubit extends Cubit<HistorialState> {
  final HistorialRepository _repository;

  HistorialCubit({required HistorialRepository repository})
      : _repository = repository,
        super(HistorialInitial());

  Future<void> cargarHistorial({int cantidad = 10}) async {
    emit(HistorialLoading());
    try {
      final libros = await _repository.getHistorial(cantidad: cantidad);
      emit(HistorialLoaded(libros: libros));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refresh() async {
    await cargarHistorial();
  }
}
