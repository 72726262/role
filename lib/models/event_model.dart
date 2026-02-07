/// Event Model
class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String eventType; // birthday, meeting, celebration, training, other
  final String? location;
  final int? maxAttendees;
  final String? imageUrl;
  final String? createdBy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    required this.eventType,
    this.location,
    this.maxAttendees,
    this.imageUrl,
    this.createdBy,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventType: json['event_type'] as String,
      location: json['location'] as String?,
      maxAttendees: json['max_attendees'] as int?,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0], // Date only
      'event_type': eventType,
      'location': location,
      'max_attendees': maxAttendees,
      'image_url': imageUrl,
      'created_by': createdBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Check if event is upcoming
  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  // Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }
}
