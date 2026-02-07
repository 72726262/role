import 'package:equatable/equatable.dart';
import '../../models/event_model.dart';

/// Events List State

abstract class EventsListState extends Equatable {
  const EventsListState();

  @override
  List<Object?> get props => [];
}

class EventsListInitial extends EventsListState {}

class EventsListLoading extends EventsListState {}

class EventsListLoaded extends EventsListState {
  final List<EventModel> events;

  const EventsListLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventsListError extends EventsListState {
  final String message;

  const EventsListError(this.message);

  @override
  List<Object?> get props => [message];
}
