import 'package:equatable/equatable.dart';

import '../../data/models/admin_sugerencia.dart';

abstract class AdminSugerenciasState extends Equatable {
  const AdminSugerenciasState();

  @override
  List<Object?> get props => [];
}

class AdminSugerenciasInitial extends AdminSugerenciasState {}

class AdminSugerenciasLoading extends AdminSugerenciasState {}

class AdminSugerenciasLoaded extends AdminSugerenciasState {
  final PagedSugerencias sugerencias;
  final int currentPage;
  final bool isLoadingMore;

  const AdminSugerenciasLoaded({
    required this.sugerencias,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [sugerencias, currentPage, isLoadingMore];
}

class AdminSugerenciasError extends AdminSugerenciasState {
  final String message;

  const AdminSugerenciasError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSugerenciasDeleting extends AdminSugerenciasState {}

class AdminSugerenciasDeleted extends AdminSugerenciasState {}

class AdminSugerenciasDeleteError extends AdminSugerenciasState {
  final String message;

  const AdminSugerenciasDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
