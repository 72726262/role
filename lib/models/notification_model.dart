/// Notification Model
class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String message;
  final String notificationType; // email, push, in_app, whatsapp
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.isRead = false,
    required this.sentAt,
    this.readAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationType: json['notification_type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
      'sent_at': sentAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      notificationType: notificationType,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata,
    );
  }
}
