import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import 'users_list_state.dart';

/// Users List Cubit
/// Manages the list of users for admin dashboard

class UsersListCubit extends Cubit<UsersListState> {
  final DatabaseService _databaseService;

  UsersListCubit({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService(),
        super(UsersListInitial());

  /// Load all users
  Future<void> loadUsers() async {
    emit(UsersListLoading());
    
    try {
      final users = await _databaseService.getAllUsers();
      emit(UsersListLoaded(users));
    } catch (e) {
      emit(UsersListError(e.toString()));
    }
  }

  /// Refresh users
  Future<void> refreshUsers() async {
    await loadUsers();
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    emit(UsersListLoading());
    
    try {
      final users = await _databaseService.searchUsers(query);
      emit(UsersListLoaded(users));
    } catch (e) {
      emit(UsersListError(e.toString()));
    }
  }

  /// Filter users by role
  Future<void> filterByRole(String role) async {
    if (role == 'all') {
      await loadUsers();
      return;
    }

    emit(UsersListLoading());
    
    try {
      final users = await _databaseService.getUsersByRole(role);
      emit(UsersListLoaded(users));
    } catch (e) {
      emit(UsersListError(e.toString()));
    }
  }
}
