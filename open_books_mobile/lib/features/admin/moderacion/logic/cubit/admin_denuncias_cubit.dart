import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_denuncia.dart';
import '../../data/repositories/admin_denuncias_repository.dart';
import 'admin_denuncias_state.dart';
export 'admin_denuncias_state.dart';

class AdminDenunciasCubit extends Cubit<AdminDenunciasState> {
  final AdminDenunciasRepository _repository;

  AdminDenunciasCubit(this._repository) : super(AdminDenunciasInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadDenuncias({int pageNumber = 1, int pageSize = 10}) async {
    emit(AdminDenunciasLoading());
    try {
      final denuncias = await _repository.getDenuncias(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      emit(AdminDenunciasLoaded(
        denuncias: denuncias,
        currentPage: pageNumber,
      ));
    } catch (e) {
      emit(AdminDenunciasError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDenuncias();
  }

  Future<void> loadMoreDenuncias() async {
    final currentState = state;
    if (currentState is! AdminDenunciasLoaded) return;
    if (currentState.isLoadingMore) return;
    if (currentState.currentPage >= currentState.denuncias.totalPages) return;

    emit(AdminDenunciasLoaded(
      denuncias: currentState.denuncias,
      currentPage: currentState.currentPage,
      isLoadingMore: true,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final denuncias = await _repository.getDenuncias(
        pageNumber: nextPage,
        pageSize: 10,
      );

      final allItems = [...currentState.denuncias.items, ...denuncias.items];
      final pagedDenuncias = PagedDenuncias(
        items: allItems,
        pageNumber: denuncias.pageNumber,
        pageSize: denuncias.pageSize,
        totalCount: denuncias.totalCount,
        totalPages: denuncias.totalPages,
      );

      emit(AdminDenunciasLoaded(
        denuncias: pagedDenuncias,
        currentPage: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(AdminDenunciasLoaded(
        denuncias: currentState.denuncias,
        currentPage: currentState.currentPage,
        isLoadingMore: false,
      ));
    }
  }

  Future<bool> deleteDenuncia(int id) async {
    emit(AdminDenunciasDeleting());
    try {
      final success = await _repository.deleteDenuncia(id);
      if (success) {
        emit(AdminDenunciasDeleted());
        await refresh();
        return true;
      }
      emit(const AdminDenunciasDeleteError('Error al eliminar denuncia'));
      return false;
    } catch (e) {
      emit(AdminDenunciasDeleteError(e.toString()));
      return false;
    }
  }
}
