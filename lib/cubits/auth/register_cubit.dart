import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/employee_profile_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  RegisterCubit() : super(RegisterInitial());

  /// Register new employee
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String department,
    required String employeeId,
    String? phoneNumber,
  }) async {
    emit(RegisterLoading());

    try {
      // 1. Get role_id from roles table based on role name
      final roleData = await _supabase
          .from('roles')
          .select('id')
          .eq('role_name', role)
          .single();

      final roleId = roleData['id'] as String;

      // 2. Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role_id': roleId,
        },
      );

      if (authResponse.user == null) {
        emit(const RegisterError('Failed to create account'));
        return;
      }
      print('User created with ID: ${authResponse.user!.id}');
      final userId = authResponse.user!.id;

      // 3. Create user record in users table
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role_id': roleId,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 4. Create employee profile
      await _supabase.from('employee_profiles').insert({
        'user_id': userId,
        'department': department,
        'employee_id': employeeId,
        'phone_number': phoneNumber,
        'hire_date': DateTime.now().toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      emit(const RegisterSuccess(
        'Account created successfully! Please login.',
      ));
    } on AuthException catch (e) {
      print(e.message.toString());
      emit(RegisterError(e.message));
    } catch (e) {
      emit(RegisterError('Registration failed: ${e.toString()}'));
      print(e.toString());
    }
  }

  void reset() {
    emit(RegisterInitial());
  }
}
