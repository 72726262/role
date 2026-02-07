/// IT Policy Model
class ITPolicyModel {
  final String id;
  final String title;
  final String? description;
  final String? policyType; // security, usage, compliance, other
  final String? pdfUrl;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ITPolicyModel({
    required this.id,
    required this.title,
    this.description,
    this.policyType,
    this.pdfUrl,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ITPolicyModel.fromJson(Map<String, dynamic> json) {
    return ITPolicyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      policyType: json['policy_type'] as String?,
      pdfUrl: json['pdf_url'] as String?,
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
      'policy_type': policyType,
      'pdf_url': pdfUrl,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
