import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_sugerencia.dart';
import '../../data/repositories/admin_sugerencias_repository.dart';
import 'admin_sugerencias_state.dart';
export 'admin_sugerencias_state.dart';

class AdminSugerenciasCubit extends Cubit<AdminSugerenciasState> {
  final AdminSugerenciasRepository _repository;

  AdminSugerenciasCubit(this._repository) : super(AdminSugerenciasInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadSugerencias({int pageNumber = 1, int pageSize = 10}) async {
    emit(AdminSugerenciasLoading());
    try {
      final sugerencias = await _repository.getSugerencias(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(AdminSugerenciasLoaded(
        sugerencias: sugerencias,
        currentPage: pageNumber,
      ));
    } catch (e) {
      emit(AdminSugerenciasError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadSugerencias();
  }

  Future<void> loadMoreSugerencias() async {
    final currentState = state;
    if (currentState is! AdminSugerenciasLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.sugerencias.totalPages) return;

    emit(AdminSugerenciasLoaded(
      sugerencias: currentState.sugerencias,
      currentPage: currentState.currentPage,
      isLoadingMore: true,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final sugerencias = await _repository.getSugerencias(
        pageNumber: nextPage,
        pageSize: 10,
      );

      final allItems = [...currentState.sugerencias.items, ...sugerencias.items];
      final pagedSugerencias = PagedSugerencias(
        items: allItems,
        pageNumber: sugerencias.pageNumber,
        pageSize: sugerencias.pageSize,
        totalCount: sugerencias.totalCount,
        totalPages: sugerencias.totalPages,
      );

      emit(AdminSugerenciasLoaded(
        sugerencias: pagedSugerencias,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(AdminSugerenciasLoaded(
        sugerencias: currentState.sugerencias,
        currentPage: currentState.currentPage,
        isLoadingMore: false,
      ));
    }
  }

  Future<bool> deleteSugerencia(int id) async {
    emit(AdminSugerenciasDeleting());
    try {
      final success = await _repository.deleteSugerencia(id);
      if (success) {
        emit(AdminSugerenciasDeleted());
        await refresh();
        return true;
      }
      emit(AdminSugerenciasDeleteError('Error al eliminar sugerencia'));
      return false;
    } catch (e) {
      emit(AdminSugerenciasDeleteError(e.toString()));
      return false;
    }
  }
}
