import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/database_service.dart';
import '../../services/realtime_service.dart';
import '../../models/notification_model.dart';
import 'notifications_state.dart';

/// Notifications Cubit
/// Manages notifications with real-time updates

class NotificationsCubit extends Cubit<NotificationsState> {
  final DatabaseService _databaseService;
  final RealtimeService _realtimeService;
  StreamSubscription? _notificationsSubscription;

  NotificationsCubit({
    DatabaseService? databaseService,
    RealtimeService? realtimeService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _realtimeService = realtimeService ?? RealtimeService(),
        super(NotificationsInitial());

  /// Load notifications for current user
  Future<void> loadNotifications() async {
    emit(NotificationsLoading());

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(const NotificationsError('المستخدم غير مسجل'));
        return;
      }

      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Subscribe to real-time notifications
  void subscribeToNotifications() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final stream = _realtimeService.subscribeToNotifications(user.id);
    _notificationsSubscription = stream.listen((data) {
      final notifications =
          data.map((json) => NotificationModel.fromJson(json)).toList();
      emit(NotificationsLoaded(notifications));
    });
  }

  /// Unsubscribe from real-time notifications
  void unsubscribeFromNotifications() {
    _notificationsSubscription?.cancel();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseService.update('notifications', notificationId, {
        'is_read': true,
      });
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      await loadNotifications();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databaseService.delete('notifications', notificationId);
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Future<void> close() {
    unsubscribeFromNotifications();
    return super.close();
  }
}
