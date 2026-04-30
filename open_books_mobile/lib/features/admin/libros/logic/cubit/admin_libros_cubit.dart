import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_libro.dart';
import '../../data/repositories/admin_libros_repository.dart';
import 'admin_libros_state.dart';
export 'admin_libros_state.dart';

class AdminLibrosCubit extends Cubit<AdminLibrosState> {
  final AdminLibrosRepository _repository;

  AdminLibrosCubit(this._repository) : super(AdminLibrosInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadLibros({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    emit(AdminLibrosLoading());
    try {
      final libros = await _repository.getLibros(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );
      emit(
        AdminLibrosLoaded(
          libros: libros,
          currentPage: pageNumber,
          searchQuery: searchQuery ?? '',
        ),
      );
    } catch (e) {
      emit(AdminLibrosError(e.toString()));
    }
  }

  Future<void> searchLibros(String query) async {
    emit(AdminLibrosLoading());
    try {
      final libros = await _repository.getLibros(
        pageNumber: 1,
        pageSize: 10,
        searchQuery: query,
      );
      emit(
        AdminLibrosLoaded(libros: libros, currentPage: 1, searchQuery: query),
      );
    } catch (e) {
      emit(AdminLibrosError(e.toString()));
    }
  }

  Future<void> loadMoreLibros() async {
    final currentState = state;
    if (currentState is! AdminLibrosLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.libros.totalPages) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final libros = await _repository.getLibros(
        pageNumber: nextPage,
        pageSize: 10,
        searchQuery: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
      );

      final allItems = [...currentState.libros.items, ...libros.items];
      final pagedLibros = PagedLibros(
        items: allItems,
        pageNumber: libros.pageNumber,
        pageSize: libros.pageSize,
        totalCount: libros.totalCount,
        totalPages: libros.totalPages,
      );

      emit(
        AdminLibrosLoaded(
          libros: pagedLibros,
          currentPage: nextPage,
          searchQuery: currentState.searchQuery,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is AdminLibrosLoaded) {
      await loadLibros(
        pageNumber: 1,
        searchQuery: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
      );
    } else {
      await loadLibros();
    }
  }

  Future<bool> createLibro(CreateLibroRequest request) async {
    emit(AdminLibrosCreating());
    try {
      final libro = await _repository.createLibro(request);
      if (libro != null) {
        emit(AdminLibrosCreated(libro));
        await refresh();
        return true;
      }
      emit(const AdminLibrosCreateError('Error al crear libro'));
      return false;
    } catch (e) {
      emit(AdminLibrosCreateError(e.toString()));
      return false;
    }
  }

  Future<bool> updateLibro(int id, UpdateLibroRequest request) async {
    emit(AdminLibrosUpdating());
    try {
      final libro = await _repository.updateLibro(id, request);
      if (libro != null) {
        emit(AdminLibrosUpdated(libro));
        await refresh();
        return true;
      }
      emit(const AdminLibrosUpdateError('Error al actualizar libro'));
      return false;
    } catch (e) {
      emit(AdminLibrosUpdateError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteLibro(int id) async {
    emit(AdminLibrosDeleting());
    try {
      final success = await _repository.deleteLibro(id);
      if (success) {
        emit(AdminLibrosDeleted());
        await refresh();
        return true;
      }
      emit(const AdminLibrosDeleteError('Error al eliminar libro'));
      return false;
    } catch (e) {
      emit(AdminLibrosDeleteError(e.toString()));
      return false;
    }
  }
}
