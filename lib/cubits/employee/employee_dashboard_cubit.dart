import 'package:employee_portal/models/employee_profile_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'employee_dashboard_state.dart';

class EmployeeDashboardCubit extends Cubit<EmployeeDashboardState> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  EmployeeDashboardCubit() : super(EmployeeDashboardInitial());

  /// Load all dashboard data
  Future<void> loadDashboard() async {
    emit(EmployeeDashboardLoading());

    try {
      // Get current user
      final user = await _authService.getCurrentUserData();
      if (user == null) {
        emit(const EmployeeDashboardError('User not found'));
        return;
      }

      // Fetch all data in parallel
      final results = await Future.wait([
        _databaseService.getEmployeeProfile(user.id),
        _databaseService.getNews(),
        _databaseService.getEvents(),
        _databaseService.getManagementMessages(),
        _databaseService.getNavigationLinks(),
        _databaseService.checkMoodSubmittedToday(user.id),
      ]);

      final profile = results[0];
      final news = results[1] as List;
      final events = results[2] as List;
      final messages = results[3] as List;
      final links = results[4] as List;
      final moodSubmitted = results[5] as bool;

      if (profile == null) {
        emit(const EmployeeDashboardError('Profile not found'));
        return;
      }

      emit(EmployeeDashboardLoaded(
        profile: profile as EmployeeProfileModel,
        news: news.cast(),
        events: events.cast(),
        messages: messages.cast(),
        links: links.cast(),
        moodSubmittedToday: moodSubmitted,
      ));
    } catch (e) {
      emit(EmployeeDashboardError(e.toString()));
    }
  }

  /// Refresh dashboard
  Future<void> refresh() async {
    await loadDashboard();
  }
}

class MoodSubmissionCubit extends Cubit<MoodSubmissionState> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  MoodSubmissionCubit() : super(MoodSubmissionInitial());

  /// Submit today's mood
  Future<void> submitMood(String moodType, {String? notes}) async {
    emit(MoodSubmissionLoading());

    try {
      // Get current user
      final user = await _authService.getCurrentUserData();
      if (user == null) {
        emit(const MoodSubmissionError('User not found'));
        return;
      }

      // Check if already submitted today
      final alreadySubmitted =
          await _databaseService.checkMoodSubmittedToday(user.id);
      if (alreadySubmitted) {
        emit(const MoodSubmissionError(
            'You have already submitted your mood today'));
        return;
      }

      // Create mood
      await _databaseService.createMood(
          userId: user.id, moodType: moodType, notes: notes);

      emit(MoodSubmissionSuccess());
    } catch (e) {
      emit(MoodSubmissionError(e.toString()));
    }
  }

  void reset() {
    emit(MoodSubmissionInitial());
  }
}
