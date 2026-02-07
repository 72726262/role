/// Training Course Model
class TrainingCourseModel {
  final String id;
  final String title;
  final String? description;
  final int? durationHours;
  final String? instructor;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxParticipants;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingCourseModel({
    required this.id,
    required this.title,
    this.description,
    this.durationHours,
    this.instructor,
    this.startDate,
    this.endDate,
    this.maxParticipants,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingCourseModel.fromJson(Map<String, dynamic> json) {
    return TrainingCourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationHours: json['duration_hours'] as int?,
      instructor: json['instructor'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      maxParticipants: json['max_participants'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_hours': durationHours,
      'instructor': instructor,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'max_participants': maxParticipants,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
