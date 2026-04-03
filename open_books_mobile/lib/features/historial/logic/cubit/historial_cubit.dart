import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';
import '../../../libros/data/models/libro.dart';
import '../../domain/usecases/get_historial_usecase.dart';
import '../../domain/usecases/add_to_historial_usecase.dart';

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
  final GetHistorialUseCase getHistorialUseCase;
  final AddToHistorialUseCase addToHistorialUseCase;
  final SessionCubit sessionCubit;

  HistorialCubit({
    required this.getHistorialUseCase,
    required this.addToHistorialUseCase,
    required this.sessionCubit,
  }) : super(HistorialInitial());

  Future<void> cargarHistorial({int cantidad = 10}) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! SessionAuthenticated) {
      emit(HistorialLoaded(libros: []));
      return;
    }

    emit(HistorialLoading());
    try {
      final entities = await getHistorialUseCase(sessionState.userId);
      final libros = entities
          .map((e) => Libro(
                id: e.libroId,
                titulo: e.titulo,
                autor: e.autor ?? '',
                descripcion: '',
                portadaBase64: e.portadaBase64,
                categorias: const [],
              ))
          .toList();
      emit(HistorialLoaded(libros: libros));
    } catch (e) {
      emit(HistorialError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addToHistorial(Libro libro) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! SessionAuthenticated) return;

    try {
      await addToHistorialUseCase(sessionState.userId, libro);
    } catch (_) {
      // Fire-and-forget: el sync puede fallar silenciosamente
    }
  }

  Future<void> refresh() async {
    await cargarHistorial();
  }
}
