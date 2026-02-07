/// Management Message Model
class ManagementMessageModel {
  final String id;
  final String title;
  final String message;
  final String priority; // low, medium, high, urgent
  final bool isVisible;
  final String? publishedBy;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  ManagementMessageModel({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.isVisible = true,
    this.publishedBy,
    required this.publishedAt,
    this.expiresAt,
    required this.createdAt,
  });

  factory ManagementMessageModel.fromJson(Map<String, dynamic> json) {
    return ManagementMessageModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
      isVisible: json['is_visible'] as bool? ?? true,
      publishedBy: json['published_by'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority,
      'is_visible': isVisible,
      'published_by': publishedBy,
      'published_at': publishedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Check if message is still valid
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }
}
