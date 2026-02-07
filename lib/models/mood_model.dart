/// Mood Model - for daily employee mood tracking
class MoodModel {
  final String id;
  final String userId;
  final String moodType; // happy, normal, tired, need_support
  final DateTime recordedAt;
  final String? notes;

  MoodModel({
    required this.id,
    required this.userId,
    required this.moodType,
    required this.recordedAt,
    this.notes,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      moodType: json['mood_type'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood_type': moodType,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  // Check if mood was recorded today
  bool get isToday {
    final now = DateTime.now();
    return recordedAt.year == now.year &&
        recordedAt.month == now.month &&
        recordedAt.day == now.day;
  }

  // Get mood emoji
  String get emoji {
    switch (moodType) {
      case 'happy':
        return '😊';
      case 'normal':
        return '😐';
      case 'tired':
        return '😴';
      case 'need_support':
        return '😟';
      default:
        return '🙂';
    }
  }
}
