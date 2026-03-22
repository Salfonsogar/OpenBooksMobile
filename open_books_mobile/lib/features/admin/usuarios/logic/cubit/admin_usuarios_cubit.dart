import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_usuario.dart';
import '../../data/repositories/admin_usuarios_repository.dart';
import 'admin_usuarios_state.dart';

class AdminUsuariosCubit extends Cubit<AdminUsuariosState> {
  final AdminUsuariosRepository _repository;

  AdminUsuariosCubit(this._repository) : super(AdminUsuariosInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadUsuarios({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    emit(AdminUsuariosLoading());
    try {
      final usuarios = await _repository.getUsuarios(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );
      emit(AdminUsuariosLoaded(
        usuarios: usuarios,
        currentPage: pageNumber,
        searchQuery: searchQuery ?? '',
      ));
    } catch (e) {
      emit(AdminUsuariosError(e.toString()));
    }
  }

  Future<void> searchUsuarios(String query) async {
    emit(AdminUsuariosLoading());
    try {
      final usuarios = await _repository.getUsuarios(
        pageNumber: 1,
        pageSize: 10,
        searchQuery: query,
      );
      emit(AdminUsuariosLoaded(
        usuarios: usuarios,
        currentPage: 1,
        searchQuery: query,
      ));
    } catch (e) {
      emit(AdminUsuariosError(e.toString()));
    }
  }

  Future<void> loadMoreUsuarios() async {
    final currentState = state;
    if (currentState is! AdminUsuariosLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.usuarios.totalPages) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final usuarios = await _repository.getUsuarios(
        pageNumber: nextPage,
        pageSize: 10,
        searchQuery: currentState.searchQuery.isNotEmpty ? currentState.searchQuery : null,
      );

      final allItems = [...currentState.usuarios.items, ...usuarios.items];
      final pagedUsuarios = PagedUsuarios(
        items: allItems,
        pageNumber: usuarios.pageNumber,
        pageSize: usuarios.pageSize,
        totalCount: usuarios.totalCount,
        totalPages: usuarios.totalPages,
      );

      emit(AdminUsuariosLoaded(
        usuarios: pagedUsuarios,
        currentPage: nextPage,
        searchQuery: currentState.searchQuery,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is AdminUsuariosLoaded) {
      await loadUsuarios(
        pageNumber: 1,
        searchQuery: currentState.searchQuery.isNotEmpty ? currentState.searchQuery : null,
      );
    } else {
      await loadUsuarios();
    }
  }

  Future<bool> createUsuario(CreateUsuarioRequest request) async {
    emit(AdminUsuarioCreating());
    try {
      final usuario = await _repository.createUsuario(request);
      if (usuario != null) {
        emit(AdminUsuarioCreated(usuario));
        await refresh();
        return true;
      }
      emit(const AdminUsuarioCreateError('Error al crear usuario'));
      return false;
    } catch (e) {
      emit(AdminUsuarioCreateError(e.toString()));
      return false;
    }
  }

  Future<bool> updateUsuario(int id, UpdateUsuarioRequest request) async {
    emit(AdminUsuarioUpdating());
    try {
      final usuario = await _repository.updateUsuario(id, request);
      if (usuario != null) {
        emit(AdminUsuarioUpdated(usuario));
        await refresh();
        return true;
      }
      emit(const AdminUsuarioUpdateError('Error al actualizar usuario'));
      return false;
    } catch (e) {
      emit(AdminUsuarioUpdateError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteUsuario(int id) async {
    emit(AdminUsuarioDeleting());
    try {
      final success = await _repository.deleteUsuario(id);
      if (success) {
        emit(AdminUsuarioDeleted());
        await refresh();
        return true;
      }
      emit(const AdminUsuarioDeleteError('Error al eliminar usuario'));
      return false;
    } catch (e) {
      emit(AdminUsuarioDeleteError(e.toString()));
      return false;
    }
  }
}
