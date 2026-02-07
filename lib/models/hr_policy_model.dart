/// HR Policy Model
class HRPolicyModel {
  final String id;
  final String title;
  final String? description;
  final String? pdfUrl;
  final String? category;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  HRPolicyModel({
    required this.id,
    required this.title,
    this.description,
    this.pdfUrl,
    this.category,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HRPolicyModel.fromJson(Map<String, dynamic> json) {
    return HRPolicyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      category: json['category'] as String?,
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
      'pdf_url': pdfUrl,
      'category': category,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
