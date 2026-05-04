import 'package:equatable/equatable.dart';

import '../../data/models/admin_stats.dart';

enum DateFilter { hoy, semana, mes, personalizado }

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminStats stats;
  final DateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const AdminDashboardLoaded({
    required this.stats,
    this.dateFilter = DateFilter.mes,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [stats, dateFilter, customStartDate, customEndDate];

  AdminDashboardLoaded copyWith({
    AdminStats? stats,
    DateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return AdminDashboardLoaded(
      stats: stats ?? this.stats,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}