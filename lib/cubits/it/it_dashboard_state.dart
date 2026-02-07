import 'package:equatable/equatable.dart';
import '../../models/it_policy_model.dart';

/// IT Dashboard States
abstract class ITDashboardState extends Equatable {
  const ITDashboardState();

  @override
  List<Object?> get props => [];
}

class ITDashboardInitial extends ITDashboardState {}

class ITDashboardLoading extends ITDashboardState {}

class ITDashboardLoaded extends ITDashboardState {
  final List<ITPolicyModel> policies;
  final int totalUsers;
  final int activeDevices;

  const ITDashboardLoaded({
    required this.policies,
    required this.totalUsers,
    required this.activeDevices,
  });

  @override
  List<Object?> get props => [policies, totalUsers, activeDevices];
}

class ITDashboardError extends ITDashboardState {
  final String message;

  const ITDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

/// IT Policy States
abstract class ITPolicyState extends Equatable {
  const ITPolicyState();

  @override
  List<Object?> get props => [];
}

class ITPolicyInitial extends ITPolicyState {}

class ITPolicyLoading extends ITPolicyState {}

class ITPolicyLoaded extends ITPolicyState {
  final List<ITPolicyModel> policies;

  const ITPolicyLoaded(this.policies);

  @override
  List<Object?> get props => [policies];
}

class ITPolicyError extends ITPolicyState {
  final String message;

  const ITPolicyError(this.message);

  @override
  List<Object?> get props => [message];
}

class ITPolicySuccess extends ITPolicyState {
  final String message;

  const ITPolicySuccess(this.message);

  @override
  List<Object?> get props => [message];
}
