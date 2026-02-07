/// Navigation Link Model
class NavigationLinkModel {
  final String id;
  final String title;
  final String? titleAr;
  final String url;
  final String? iconName;
  final int? displayOrder;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  NavigationLinkModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.url,
    this.iconName,
    this.displayOrder,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NavigationLinkModel.fromJson(Map<String, dynamic> json) {
    return NavigationLinkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      url: json['url'] as String,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int?,
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
      'title_ar': titleAr,
      'url': url,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Get localized title
  String getLocalizedTitle(bool isArabic) {
    return isArabic ? (titleAr ?? title) : title;
  }
}
