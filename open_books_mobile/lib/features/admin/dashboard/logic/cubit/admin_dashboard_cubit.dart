import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminDashboardRepository _repository;

  AdminDashboardCubit(this._repository) : super(AdminDashboardInitial());

  Future<void> loadStats() async {
    emit(AdminDashboardLoading());
    try {
      final stats = await _repository.getStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> refresh() async {
    try {
      final stats = await _repository.getStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }
}
