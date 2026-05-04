import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_categoria.dart';
import '../../data/repositories/admin_categorias_repository.dart';
import 'admin_categorias_state.dart';
export 'admin_categorias_state.dart';

class AdminCategoriasCubit extends Cubit<AdminCategoriasState> {
  final AdminCategoriasRepository _repository;

  AdminCategoriasCubit(this._repository) : super(AdminCategoriasInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadCategorias() async {
    emit(AdminCategoriasLoading());
    try {
      final categorias = await _repository.getCategorias();
      emit(AdminCategoriasLoaded(categorias: categorias));
    } catch (e) {
      emit(AdminCategoriasError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadCategorias();
  }

  Future<bool> createCategoria(CreateCategoriaRequest request) async {
    emit(AdminCategoriasCreating());
    try {
      final categoria = await _repository.createCategoria(request);
      if (categoria != null) {
        emit(AdminCategoriasCreated(categoria));
        await refresh();
        return true;
      }
      emit(const AdminCategoriasCreateError('Error al crear categoría'));
      return false;
    } catch (e) {
      emit(AdminCategoriasCreateError(e.toString()));
      return false;
    }
  }

  Future<bool> updateCategoria(int id, UpdateCategoriaRequest request) async {
    emit(AdminCategoriasUpdating());
    try {
      final categoria = await _repository.updateCategoria(id, request);
      if (categoria != null) {
        emit(AdminCategoriasUpdated(categoria));
        await refresh();
        return true;
      }
      emit(const AdminCategoriasUpdateError('Error al actualizar categoría'));
      return false;
    } catch (e) {
      emit(AdminCategoriasUpdateError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    emit(AdminCategoriasDeleting());
    try {
      final success = await _repository.deleteCategoria(id);
      if (success) {
        emit(AdminCategoriasDeleted());
        await refresh();
        return true;
      }
      emit(const AdminCategoriasDeleteError('Error al eliminar categoría'));
      return false;
    } catch (e) {
      emit(AdminCategoriasDeleteError(e.toString()));
      return false;
    }
  }
}
