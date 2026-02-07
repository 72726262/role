/// Role Model
class RoleModel {
  final String id;
  final String roleName;
  final String? description;
  final DateTime createdAt;

  RoleModel({
    required this.id,
    required this.roleName,
    this.description,
    required this.createdAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      roleName: json['role_name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': roleName,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to check role type
  bool isEmployee() => roleName == 'Employee';
  bool isHR() => roleName == 'HR';
  bool isIT() => roleName == 'IT';
  bool isManagement() => roleName == 'Management';
  bool isAdmin() => roleName == 'Admin';
}
