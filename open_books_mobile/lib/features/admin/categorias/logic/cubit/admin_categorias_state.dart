import 'package:equatable/equatable.dart';

import '../../data/models/admin_categoria.dart';

abstract class AdminCategoriasState extends Equatable {
  const AdminCategoriasState();

  @override
  List<Object?> get props => [];
}

class AdminCategoriasInitial extends AdminCategoriasState {}

class AdminCategoriasLoading extends AdminCategoriasState {}

class AdminCategoriasLoaded extends AdminCategoriasState {
  final PagedCategorias categorias;

  const AdminCategoriasLoaded({required this.categorias});

  @override
  List<Object?> get props => [categorias];
}

class AdminCategoriasError extends AdminCategoriasState {
  final String message;

  const AdminCategoriasError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCategoriasCreating extends AdminCategoriasState {}

class AdminCategoriasCreated extends AdminCategoriasState {
  final AdminCategoria categoria;

  const AdminCategoriasCreated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class AdminCategoriasCreateError extends AdminCategoriasState {
  final String message;

  const AdminCategoriasCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCategoriasUpdating extends AdminCategoriasState {}

class AdminCategoriasUpdated extends AdminCategoriasState {
  final AdminCategoria categoria;

  const AdminCategoriasUpdated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class AdminCategoriasUpdateError extends AdminCategoriasState {
  final String message;

  const AdminCategoriasUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminCategoriasDeleting extends AdminCategoriasState {}

class AdminCategoriasDeleted extends AdminCategoriasState {}

class AdminCategoriasDeleteError extends AdminCategoriasState {
  final String message;

  const AdminCategoriasDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
