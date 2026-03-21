import 'package:equatable/equatable.dart';

import '../../data/models/admin_usuario.dart';

abstract class AdminUsuariosState extends Equatable {
  const AdminUsuariosState();

  @override
  List<Object?> get props => [];
}

class AdminUsuariosInitial extends AdminUsuariosState {}

class AdminUsuariosLoading extends AdminUsuariosState {}

class AdminUsuariosLoaded extends AdminUsuariosState {
  final PagedUsuarios usuarios;
  final int currentPage;
  final bool isLoadingMore;
  final String searchQuery;

  const AdminUsuariosLoaded({
    required this.usuarios,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [usuarios, currentPage, isLoadingMore, searchQuery];

  AdminUsuariosLoaded copyWith({
    PagedUsuarios? usuarios,
    int? currentPage,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return AdminUsuariosLoaded(
      usuarios: usuarios ?? this.usuarios,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminUsuariosError extends AdminUsuariosState {
  final String message;

  const AdminUsuariosError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsuarioCreating extends AdminUsuariosState {}

class AdminUsuarioCreated extends AdminUsuariosState {
  final AdminUsuario usuario;

  const AdminUsuarioCreated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class AdminUsuarioCreateError extends AdminUsuariosState {
  final String message;

  const AdminUsuarioCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsuarioUpdating extends AdminUsuariosState {}

class AdminUsuarioUpdated extends AdminUsuariosState {
  final AdminUsuario usuario;

  const AdminUsuarioUpdated(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class AdminUsuarioUpdateError extends AdminUsuariosState {
  final String message;

  const AdminUsuarioUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUsuarioDeleting extends AdminUsuariosState {}

class AdminUsuarioDeleted extends AdminUsuariosState {}

class AdminUsuarioDeleteError extends AdminUsuariosState {
  final String message;

  const AdminUsuarioDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
