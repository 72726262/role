import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

/// 🎨 Theme Controller Cubit
/// Manages theme switching and persistence

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme';
  
  ThemeCubit() : super(ThemeState.light()) {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = prefs.getString(_themeKey) ?? 'light';
      
      if (themeMode == 'dark') {
        emit(ThemeState.dark());
      } else {
        emit(ThemeState.light());
      }
    } catch (e) {
      // Default to light theme on error
      emit(ThemeState.light());
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newState = state.isDark ? ThemeState.light() : ThemeState.dark();
    emit(newState);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newState.isDark ? 'dark' : 'light');
    } catch (e) {
      // Handle error silently
    }
  }

  /// Set specific theme
  Future<void> setTheme(bool isDark) async {
    final newState = isDark ? ThemeState.dark() : ThemeState.light();
    emit(newState);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
      // Handle error silently
    }
  }
}
