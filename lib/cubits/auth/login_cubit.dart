import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'login_state.dart';

/// Login Cubit - handles login logic
class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = AuthService();

  LoginCubit() : super(LoginInitial());

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(LoginLoading());

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        emit(const LoginError('البريد الإلكتروني وكلمة المرور مطلوبان'));
        return;
      }

      // Sign in
      await _authService.signIn(email: email, password: password);

      // Get user role
      final role = await _authService.getUserRole();

      if (role == null) {
        emit(const LoginError('لم يتم العثور على دور المستخدم'));
        return;
      }

      emit(LoginSuccess(role));
    } catch (e) {
      print(e.toString());
      emit(LoginError('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(LoginInitial());
  }
}
