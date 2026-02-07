import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

/// 🔄 Real-Time Service
/// Handles Supabase real-time subscriptions

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  /// Subscribe to table changes
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(Map<String, dynamic>) onInsert,
    void Function(Map<String, dynamic>)? onUpdate,
    void Function(Map<String, dynamic>)? onDelete,
  }) {
    final channelName = 'realtime:$table';
    
    // Remove existing channel if any
    if (_channels.containsKey(channelName)) {
      _channels[channelName]!.unsubscribe();
      _channels.remove(channelName);
    }

    final channel = _client.channel(channelName);

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) {
            if (onUpdate != null) onUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) {
            if (onDelete != null) onDelete(payload.oldRecord);
          },
        )
        .subscribe();

    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to notifications for a specific user
  Stream<List<Map<String, dynamic>>> subscribeToNotifications(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    subscribeToTable(
      table: 'notifications',
      onInsert: (data) async {
        if (data['user_id'] == userId) {
          // Fetch all notifications when new one arrives
          final notifications = await _client
              .from('notifications')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          
          controller.add(List<Map<String, dynamic>>.from(notifications));
        }
      },
      onUpdate: (data) async {
        if (data['user_id'] == userId) {
          final notifications = await _client
              .from('notifications')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          
          controller.add(List<Map<String, dynamic>>.from(notifications));
        }
      },
      onDelete: (data) async {
        if (data['user_id'] == userId) {
          final notifications = await _client
              .from('notifications')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
          
          controller.add(List<Map<String, dynamic>>.from(notifications));
        }
      },
    );

    return controller.stream;
  }

  /// Subscribe to messages for a user
  Stream<List<Map<String, dynamic>>> subscribeToMessages(String userId) {
    final controller = StreamController<List<Map<String, dynamic>>>();

    subscribeToTable(
      table: 'messages',
      onInsert: (data) async {
        if (data['receiver_id'] == userId) {
          final messages = await _client
              .from('messages')
              .select()
              .or('receiver_id.eq.$userId,sender_id.eq.$userId')
              .order('created_at', ascending: false);
          
          controller.add(List<Map<String, dynamic>>.from(messages));
        }
      },
    );

    return controller.stream;
  }

  /// Subscribe to news updates
  Stream<List<Map<String, dynamic>>> subscribeToNews() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    subscribeToTable(
      table: 'news',
      onInsert: (data) async {
        final news = await _client
            .from('news')
            .select()
            .eq('is_published', true)
            .order('created_at', ascending: false);
        
        controller.add(List<Map<String, dynamic>>.from(news));
      },
      onUpdate: (data) async {
        final news = await _client
            .from('news')
            .select()
            .eq('is_published', true)
            .order('created_at', ascending: false);
        
        controller.add(List<Map<String, dynamic>>.from(news));
      },
    );

    return controller.stream;
  }

  /// Subscribe to events
  Stream<List<Map<String, dynamic>>> subscribeToEvents() {
    final controller = StreamController<List<Map<String, dynamic>>>();

    subscribeToTable(
      table: 'events',
      onInsert: (data) async {
        final events = await _client
            .from('events')
            .select()
            .order('event_date', ascending: true);
        
        controller.add(List<Map<String, dynamic>>.from(events));
      },
      onUpdate: (data) async {
        final events = await _client
            .from('events')
            .select()
            .order('event_date', ascending: true);
        
        controller.add(List<Map<String, dynamic>>.from(events));
      },
    );

    return controller.stream;
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    if (_channels.containsKey(channelName)) {
      _channels[channelName]!.unsubscribe();
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from all channels
  void unsubscribeAll() {
    for (var channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }

  /// Dispose
  void dispose() {
    unsubscribeAll();
  }
}
