import 'package:equatable/equatable.dart';

import '../../data/models/admin_libro.dart';

abstract class AdminLibrosState extends Equatable {
  const AdminLibrosState();

  @override
  List<Object?> get props => [];
}

class AdminLibrosInitial extends AdminLibrosState {}

class AdminLibrosLoading extends AdminLibrosState {}

class AdminLibrosLoaded extends AdminLibrosState {
  final PagedLibros libros;
  final int currentPage;
  final bool isLoadingMore;
  final String searchQuery;

  const AdminLibrosLoaded({
    required this.libros,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [libros, currentPage, isLoadingMore, searchQuery];

  AdminLibrosLoaded copyWith({
    PagedLibros? libros,
    int? currentPage,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return AdminLibrosLoaded(
      libros: libros ?? this.libros,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AdminLibrosError extends AdminLibrosState {
  final String message;

  const AdminLibrosError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminLibrosCreating extends AdminLibrosState {}

class AdminLibrosCreated extends AdminLibrosState {
  final AdminLibro libro;

  const AdminLibrosCreated(this.libro);

  @override
  List<Object?> get props => [libro];
}

class AdminLibrosCreateError extends AdminLibrosState {
  final String message;

  const AdminLibrosCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminLibrosUpdating extends AdminLibrosState {}

class AdminLibrosUpdated extends AdminLibrosState {
  final AdminLibro libro;

  const AdminLibrosUpdated(this.libro);

  @override
  List<Object?> get props => [libro];
}

class AdminLibrosUpdateError extends AdminLibrosState {
  final String message;

  const AdminLibrosUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminLibrosDeleting extends AdminLibrosState {}

class AdminLibrosDeleted extends AdminLibrosState {}

class AdminLibrosDeleteError extends AdminLibrosState {
  final String message;

  const AdminLibrosDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
