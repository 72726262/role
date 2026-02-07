/// Employee Profile Model
class EmployeeProfileModel {
  final String id;
  final String userId;
  final String? jobTitle;
  final String? department;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final DateTime? hireDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeProfileModel({
    required this.id,
    required this.userId,
    this.jobTitle,
    this.department,
    this.phoneNumber,
    this.photoUrl,
    this.dateOfBirth,
    this.hireDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jobTitle: json['job_title'] as String?,
      department: json['department'] as String?,
      phoneNumber: json['phone_number'] as String?,
      photoUrl: json['photo_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'job_title': jobTitle,
      'department': department,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'hire_date': hireDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmployeeProfileModel copyWith({
    String? id,
    String? userId,
    String? jobTitle,
    String? department,
    String? phoneNumber,
    String? photoUrl,
    DateTime? dateOfBirth,
    DateTime? hireDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
