/// 🎨 App Constants
/// Centralized constants for the application

class AppConstants {
  // App Info
  static const String appName = 'Employee Portal';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'نظام إدارة الموظفين الاحترافي';

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;

  // Image Sizes
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int thumbnailSize = 200;
  static const int avatarSize = 400;

  // Animation Durations (in milliseconds)
  static const int shortAnimationDuration = 150;
  static const int normalAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Cache Durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String fullDateFormat = 'EEEE, dd MMMM yyyy';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String newsBucket = 'news';
  static const String messagesBucket = 'messages';
  static const String eventsBucket = 'events';
  static const String documentsBucket = 'documents';

  // Notification Types
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeNews = 'news';
  static const String notificationTypeEvent = 'event';
  static const String notificationTypeSystem = 'system';
  static const String notificationTypeAnnouncement = 'announcement';

  // Message Priorities
  static const String priorityLow = 'low';
  static const String priorityNormal = 'normal';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';

  // News Categories
  static const String categoryAnnouncement = 'announcement';
  static const String categoryEvent = 'event';
  static const String categoryUpdate = 'update';
  static const String categoryAchievement = 'achievement';

  // Roles
  static const String roleAdmin = 'Admin';
  static const String roleEmployee = 'Employee';
  static const String roleHR = 'HR';
  static const String roleIT = 'IT';
  static const String roleManagement = 'Management';

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserRole = 'user_role';

  // Error Messages
  static const String errorGeneric = 'حدث خطأ ما. يرجى المحاولة مرة أخرى';
  static const String errorNetwork = 'خطأ في الاتصال بالإنترنت';
  static const String errorAuth = 'خطأ في المصادقة';
  static const String errorPermission = 'ليس لديك صلاحية للقيام بهذا الإجراء';
  static const String errorNotFound = 'العنصر غير موجود';

  // Success Messages
  static const String successSaved = 'تم الحفظ بنجاح';
  static const String successUpdated = 'تم التحديث بنجاح';
  static const String successDeleted = 'تم الحذف بنجاح';
  static const String successSent = 'تم الإرسال بنجاح';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(
    r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$',
  );
  static final RegExp urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
}
