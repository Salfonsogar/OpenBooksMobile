import 'package:equatable/equatable.dart';

import '../../data/models/admin_denuncia.dart';

abstract class AdminDenunciasState extends Equatable {
  const AdminDenunciasState();

  @override
  List<Object?> get props => [];
}

class AdminDenunciasInitial extends AdminDenunciasState {}

class AdminDenunciasLoading extends AdminDenunciasState {}

class AdminDenunciasLoaded extends AdminDenunciasState {
  final PagedDenuncias denuncias;
  final int currentPage;
  final bool isLoadingMore;

  const AdminDenunciasLoaded({
    required this.denuncias,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [denuncias, currentPage, isLoadingMore];
}

class AdminDenunciasError extends AdminDenunciasState {
  final String message;

  const AdminDenunciasError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminDenunciasDeleting extends AdminDenunciasState {}

class AdminDenunciasDeleted extends AdminDenunciasState {}

class AdminDenunciasDeleteError extends AdminDenunciasState {
  final String message;

  const AdminDenunciasDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
