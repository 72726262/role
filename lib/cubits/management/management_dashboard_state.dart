import 'package:equatable/equatable.dart';
import '../../models/management_message_model.dart';

abstract class ManagementDashboardState extends Equatable {
  const ManagementDashboardState();

  @override
  List<Object?> get props => [];
}

class ManagementDashboardInitial extends ManagementDashboardState {}

class ManagementDashboardLoading extends ManagementDashboardState {}

class ManagementDashboardLoaded extends ManagementDashboardState {
  final Map<String, int> moodStats;
  final List<ManagementMessageModel> messages;
  final int totalEmployees;

  const ManagementDashboardLoaded({
    required this.moodStats,
    required this.messages,
    required this.totalEmployees,
  });

  @override
  List<Object?> get props => [moodStats, messages, totalEmployees];
}

class ManagementDashboardError extends ManagementDashboardState {
  final String message;

  const ManagementDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
