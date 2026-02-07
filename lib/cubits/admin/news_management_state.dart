import 'package:equatable/equatable.dart';
import '../../models/news_model.dart';

/// News Management State

abstract class NewsManagementState extends Equatable {
  const NewsManagementState();

  @override
  List<Object?> get props => [];
}

class NewsManagementInitial extends NewsManagementState {}

class NewsManagementLoading extends NewsManagementState {}

class NewsManagementLoaded extends NewsManagementState {
  final List<NewsModel> news;

  const NewsManagementLoaded(this.news);

  @override
  List<Object?> get props => [news];
}

class NewsManagementError extends NewsManagementState {
  final String message;

  const NewsManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
