import 'package:equatable/equatable.dart';
import '../../models/hr_policy_model.dart';
import '../../models/training_course_model.dart';

/// HR Dashboard States
abstract class HRDashboardState extends Equatable {
  const HRDashboardState();

  @override
  List<Object?> get props => [];
}

class HRDashboardInitial extends HRDashboardState {}

class HRDashboardLoading extends HRDashboardState {}

class HRDashboardLoaded extends HRDashboardState {
  final int totalEmployees;
  final Map<String, int> moodStats; // {happy: 10, normal: 5, ...}
  final List<HRPolicyModel> policies;
  final List<TrainingCourseModel> courses;

  const HRDashboardLoaded({
    required this.totalEmployees,
    required this.moodStats,
    required this.policies,
    required this.courses,
  });

  @override
  List<Object?> get props => [totalEmployees, moodStats, policies, courses];
}

class HRDashboardError extends HRDashboardState {
  final String message;

  const HRDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// HR Policy States
abstract class HRPolicyState extends Equatable {
  const HRPolicyState();

  @override
  List<Object?> get props => [];
}

class HRPolicyInitial extends HRPolicyState {}

class HRPolicyLoading extends HRPolicyState {}

class HRPolicyLoaded extends HRPolicyState {
  final List<HRPolicyModel> policies;

  const HRPolicyLoaded(this.policies);

  @override
  List<Object?> get props => [policies];
}

class HRPolicyError extends HRPolicyState {
  final String message;

  const HRPolicyError(this.message);

  @override
  List<Object?> get props => [message];
}

class HRPolicySuccess extends HRPolicyState {
  final String message;

  const HRPolicySuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Training Course States
abstract class TrainingCourseState extends Equatable {
  const TrainingCourseState();

  @override
  List<Object?> get props => [];
}

class TrainingCourseInitial extends TrainingCourseState {}

class TrainingCourseLoading extends TrainingCourseState {}

class TrainingCourseLoaded extends TrainingCourseState {
  final List<TrainingCourseModel> courses;

  const TrainingCourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class TrainingCourseError extends TrainingCourseState {
  final String message;

  const TrainingCourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class TrainingCourseSuccess extends TrainingCourseState {
  final String message;

  const TrainingCourseSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
