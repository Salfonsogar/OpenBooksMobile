import 'package:equatable/equatable.dart';

import '../../data/models/admin_sancion.dart';

abstract class AdminSancionesState extends Equatable {
  const AdminSancionesState();

  @override
  List<Object?> get props => [];
}

class AdminSancionesInitial extends AdminSancionesState {}

class AdminSancionesLoading extends AdminSancionesState {}

class AdminSancionesLoaded extends AdminSancionesState {
  final PagedSanciones sanciones;
  final int currentPage;
  final bool isLoadingMore;

  const AdminSancionesLoaded({
    required this.sanciones,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [sanciones, currentPage, isLoadingMore];
}

class AdminSancionesError extends AdminSancionesState {
  final String message;

  const AdminSancionesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSancionesCreating extends AdminSancionesState {}

class AdminSancionesCreated extends AdminSancionesState {
  final AdminSancion sancion;

  const AdminSancionesCreated(this.sancion);

  @override
  List<Object?> get props => [sancion];
}

class AdminSancionesCreateError extends AdminSancionesState {
  final String message;

  const AdminSancionesCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSancionesUpdating extends AdminSancionesState {}

class AdminSancionesUpdated extends AdminSancionesState {
  final AdminSancion sancion;

  const AdminSancionesUpdated(this.sancion);

  @override
  List<Object?> get props => [sancion];
}

class AdminSancionesUpdateError extends AdminSancionesState {
  final String message;

  const AdminSancionesUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSancionesDeleting extends AdminSancionesState {}

class AdminSancionesDeleted extends AdminSancionesState {}

class AdminSancionesDeleteError extends AdminSancionesState {
  final String message;

  const AdminSancionesDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
