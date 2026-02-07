import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import 'management_dashboard_state.dart';

class ManagementDashboardCubit extends Cubit<ManagementDashboardState> {
  final DatabaseService _databaseService = DatabaseService();

  ManagementDashboardCubit() : super(ManagementDashboardInitial());

  Future<void> loadDashboard() async {
    emit(ManagementDashboardLoading());

    try {
      final results = await Future.wait([
        _databaseService.getMoodStatistics(),
        _databaseService.getManagementMessages(),
        _databaseService.getTotalEmployeesCount(),
      ]);

      final moodStats = results[0] as Map<String, int>;
      final messages = results[1] as List;
      final totalEmployees = results[2] as int;

      emit(ManagementDashboardLoaded(
        moodStats: moodStats,
        messages: messages.cast(),
        totalEmployees: totalEmployees,
      ));
    } catch (e) {
      emit(ManagementDashboardError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
