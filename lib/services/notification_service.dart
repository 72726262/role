import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

/// Notification Service - handles all notification types
class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> init() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
    // This will be implemented based on notification payload
  }

  // ============================================
  // IN-APP NOTIFICATIONS
  // ============================================

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'employee_portal_channel',
      'Employee Portal',
      channelDescription: 'Employee Portal Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ============================================
  // PUSH NOTIFICATIONS (Supabase Realtime)
  // ============================================

  /// Subscribe to user-specific notifications
  RealtimeChannel subscribeToNotifications(String userId, Function(NotificationModel) onNotification) {
    final channel = _supabase.channel('notifications:$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = NotificationModel.fromJson(payload.newRecord);
            onNotification(notification);

            // Show local notification
            showLocalNotification(
              title: notification.title,
              body: notification.message,
            );
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from notifications
  Future<void> unsubscribeFromNotifications(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }

  // ============================================
  // NOTIFICATION CRUD
  // ============================================

  /// Send notification to user(s)
  Future<void> sendNotification({
    required String title,
    required String message,
    required List<String>? userIds, // null = all users
    String notificationType = 'in_app',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (userIds == null) {
        // Send to all users
        final usersResponse = await _supabase.from('users').select('id');
        final allUserIds = (usersResponse as List)
            .map((u) => u['id'] as String)
            .toList();

        for (var userId in allUserIds) {
          await _createNotification(
            userId: userId,
            title: title,
            message: message,
            notificationType: notificationType,
            metadata: metadata,
          );
        }
      } else {
        // Send to specific users
        for (var userId in userIds) {
          await _createNotification(
            userId: userId,
            title: title,
            message: message,
            notificationType: notificationType,
            metadata: metadata,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create notification record
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String message,
    required String notificationType,
    Map<String, dynamic>? metadata,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'metadata': metadata,
    });
  }

  /// Get user notifications
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('sent_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // EMAIL NOTIFICATIONS (Supabase Edge Functions)
  // ============================================

  /// Send email notification via Edge Function
  /// Note: Requires Supabase Edge Function to be deployed
  Future<void> sendEmailNotification({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    try {
      await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': toEmail,
          'subject': subject,
          'body': body,
        },
      );
    } catch (e) {
      // Email sending failed - log or handle error
      rethrow;
    }
  }

  // ============================================
  // WHATSAPP NOTIFICATIONS (Structure Ready)
  // ============================================

  /// Send WhatsApp notification (placeholder for future integration)
  Future<void> sendWhatsAppNotification({
    required String phoneNumber,
    required String message,
  }) async {
    // This is a placeholder for WhatsApp integration
    // You can integrate with WhatsApp Business API or similar service
    // For now, just create a notification record
    try {
      // TODO: Implement WhatsApp integration
      throw UnimplementedError('WhatsApp integration pending');
    } catch (e) {
      rethrow;
    }
  }
}
