import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_sancion.dart';
import '../../data/repositories/admin_sanciones_repository.dart';
import 'admin_sanciones_state.dart';
export 'admin_sanciones_state.dart';

class AdminSancionesCubit extends Cubit<AdminSancionesState> {
  final AdminSancionesRepository _repository;

  AdminSancionesCubit(this._repository) : super(AdminSancionesInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadSanciones({int pageNumber = 1, int pageSize = 10}) async {
    emit(AdminSancionesLoading());
    try {
      final sanciones = await _repository.getSanciones(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(AdminSancionesLoaded(
        sanciones: sanciones,
        currentPage: pageNumber,
      ));
    } catch (e) {
      emit(AdminSancionesError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadSanciones();
  }

  Future<void> loadMoreSanciones() async {
    final currentState = state;
    if (currentState is! AdminSancionesLoaded) return;
    if (currentState.sanciones.items.isEmpty) return;
    if (currentState.currentPage >= currentState.sanciones.totalPages) return;

    emit(AdminSancionesLoaded(
      sanciones: currentState.sanciones,
      currentPage: currentState.currentPage,
      isLoadingMore: true,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final sanciones = await _repository.getSanciones(
        pageNumber: nextPage,
        pageSize: 10,
      );

      final allItems = [...currentState.sanciones.items, ...sanciones.items];
      final pagedSanciones = PagedSanciones(
        items: allItems,
        pageNumber: sanciones.pageNumber,
        pageSize: sanciones.pageSize,
        totalCount: sanciones.totalCount,
        totalPages: sanciones.totalPages,
      );

      emit(AdminSancionesLoaded(
        sanciones: pagedSanciones,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(AdminSancionesLoaded(
        sanciones: currentState.sanciones,
        currentPage: currentState.currentPage,
        isLoadingMore: false,
      ));
    }
  }

  Future<bool> createSancion(CreateSancionRequest request) async {
    emit(AdminSancionesCreating());
    try {
      final sancion = await _repository.createSancion(request);
      if (sancion != null) {
        emit(AdminSancionesCreated(sancion));
        await refresh();
        return true;
      }
      emit(const AdminSancionesCreateError('Error al crear sanción'));
      return false;
    } catch (e) {
      emit(AdminSancionesCreateError(e.toString()));
      return false;
    }
  }

  Future<bool> updateSancion(int id, UpdateSancionRequest request) async {
    emit(AdminSancionesUpdating());
    try {
      final sancion = await _repository.updateSancion(id, request);
      if (sancion != null) {
        emit(AdminSancionesUpdated(sancion));
        await refresh();
        return true;
      }
      emit(const AdminSancionesUpdateError('Error al actualizar sanción'));
      return false;
    } catch (e) {
      emit(AdminSancionesUpdateError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteSancion(int id) async {
    emit(AdminSancionesDeleting());
    try {
      final success = await _repository.deleteSancion(id);
      if (success) {
        emit(AdminSancionesDeleted());
        await refresh();
        return true;
      }
      emit(const AdminSancionesDeleteError('Error al eliminar sanción'));
      return false;
    } catch (e) {
      emit(AdminSancionesDeleteError(e.toString()));
      return false;
    }
  }
}
