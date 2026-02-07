import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import '../../models/event_model.dart';
import 'events_list_state.dart';

/// Events List Cubit

class EventsListCubit extends Cubit<EventsListState> {
  final DatabaseService _databaseService;

  EventsListCubit({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService(),
        super(EventsListInitial());

  /// Load all events
  Future<void> loadEvents() async {
    emit(EventsListLoading());
    
    try {
      final events = await _databaseService.getEvents();
      emit(EventsListLoaded(events));
    } catch (e) {
      emit(EventsListError(e.toString()));
    }
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _databaseService.delete('events', eventId);
      await loadEvents();
    } catch (e) {
      emit(EventsListError(e.toString()));
    }
  }
}
