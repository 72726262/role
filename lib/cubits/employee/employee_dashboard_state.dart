import 'package:equatable/equatable.dart';
import '../../models/employee_profile_model.dart';
import '../../models/news_model.dart';
import '../../models/event_model.dart';
import '../../models/management_message_model.dart';
import '../../models/navigation_link_model.dart';

/// Employee Dashboard States
abstract class EmployeeDashboardState extends Equatable {
  const EmployeeDashboardState();

  @override
  List<Object?> get props => [];
}

class EmployeeDashboardInitial extends EmployeeDashboardState {}

class EmployeeDashboardLoading extends EmployeeDashboardState {}

class EmployeeDashboardLoaded extends EmployeeDashboardState {
  final EmployeeProfileModel profile;
  final List<NewsModel> news;
  final List<EventModel> events;
  final List<ManagementMessageModel> messages;
  final List<NavigationLinkModel> links;
  final bool moodSubmittedToday;

  const EmployeeDashboardLoaded({
    required this.profile,
    required this.news,
    required this.events,
    required this.messages,
    required this.links,
    required this.moodSubmittedToday,
  });

  @override
  List<Object?> get props => [profile, news, events, messages, links, moodSubmittedToday];
}

class EmployeeDashboardError extends EmployeeDashboardState {
  final String message;

  const EmployeeDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Mood Submission States
abstract class MoodSubmissionState extends Equatable {
  const MoodSubmissionState();

  @override
  List<Object?> get props => [];
}

class MoodSubmissionInitial extends MoodSubmissionState {}

class MoodSubmissionLoading extends MoodSubmissionState {}

class MoodSubmissionSuccess extends MoodSubmissionState {}

class MoodSubmissionError extends MoodSubmissionState {
  final String message;

  const MoodSubmissionError(this.message);

  @override
  List<Object?> get props => [message];
}
