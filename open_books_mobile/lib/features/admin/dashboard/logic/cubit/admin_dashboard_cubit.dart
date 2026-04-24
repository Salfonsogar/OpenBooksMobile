import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../shared/services/local_database.dart';
import '../../../../../shared/core/session/session_cubit.dart';
import '../../data/repositories/admin_dashboard_repository.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final AdminDashboardRepository _repository;
  final LocalDatabase _localDatabase;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AdminDashboardCubit(
    this._repository, {
    required LocalDatabase localDatabase,
    required SessionCubit sessionCubit,
  })  : _localDatabase = localDatabase,
        super(AdminDashboardInitial());

  Future<void> loadStats() async {
    emit(AdminDashboardLoading());
    try {
      await _initDependencies();
      final stats = await _repository.getStats();
      emit(AdminDashboardLoaded(stats: stats));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  Future<void> _initDependencies() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      _repository.setDependencies(
        localDatabase: _localDatabase,
        token: token,
      );
    }
  }

  Future<void> refresh() async {
    try {
      final currentState = state;
      DateFilter filter = DateFilter.mes;
      if (currentState is AdminDashboardLoaded) {
        filter = currentState.dateFilter;
      }

      final stats = await _repository.getStats();
      emit(AdminDashboardLoaded(
        stats: stats,
        dateFilter: filter,
      ));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }

  void changeFilter(DateFilter filter, {DateTime? startDate, DateTime? endDate}) {
    final currentState = state;
    if (currentState is AdminDashboardLoaded) {
      emit(currentState.copyWith(
        dateFilter: filter,
        customStartDate: startDate,
        customEndDate: endDate,
      ));
      refresh();
    }
  }
}