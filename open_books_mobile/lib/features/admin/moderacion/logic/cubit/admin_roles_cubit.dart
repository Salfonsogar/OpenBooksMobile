import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_rol.dart';
import '../../data/repositories/admin_roles_repository.dart';

abstract class AdminRolesState extends Equatable {
  const AdminRolesState();

  @override
  List<Object?> get props => [];
}

class AdminRolesInitial extends AdminRolesState {}

class AdminRolesLoading extends AdminRolesState {}

class AdminRolesLoaded extends AdminRolesState {
  final List<AdminRol> roles;

  const AdminRolesLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

class AdminRolesError extends AdminRolesState {
  final String message;

  const AdminRolesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminRolesCubit extends Cubit<AdminRolesState> {
  final AdminRolesRepository _repository;

  AdminRolesCubit(this._repository) : super(AdminRolesInitial());

  void setToken(String token) {
    _repository.setToken(token);
  }

  Future<void> loadRoles() async {
    emit(AdminRolesLoading());
    try {
      final roles = await _repository.getRoles();
      emit(AdminRolesLoaded(roles));
    } catch (e) {
      emit(AdminRolesError(e.toString()));
    }
  }

  Future<bool> createRol(CreateRolRequest request) async {
    try {
      final rol = await _repository.createRol(request);
      if (rol != null) {
        await loadRoles();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRol(int id, UpdateRolRequest request) async {
    try {
      final rol = await _repository.updateRol(id, request);
      if (rol != null) {
        await loadRoles();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRol(int id) async {
    try {
      final success = await _repository.deleteRol(id);
      if (success) {
        await loadRoles();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
