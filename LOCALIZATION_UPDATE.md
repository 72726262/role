# Add missing localization strings to app_localizations.dart

## Required Additions

Add these getters before the ERROR MESSAGES section (around line 261):

```dart
  // Additional Admin Features
  String get systemManagement => isArabic ? 'إدارة النظام' : 'System Management';
  String get changeRole => isArabic ? 'تغيير الدور' : 'Change Role';
  String get newRole => isArabic ? 'الدور الجديد' : 'New Role';
  String get roleChanged => isArabic ? 'تم تغيير الدور بنجاح' : 'Role changed successfully';
  String get activate => isArabic ? 'تفعيل' : 'Activate';
  String get deactivate => isArabic ? 'إلغاء التفعيل' : 'Deactivate';
  String get userActivated => isArabic ? 'تم تفعيل المستخدم' : 'User activated';
  String get userDeactivated => isArabic ? 'تم إلغاء تفعيل المستخدم' : 'User deactivated';
  String get userCreated => isArabic ? 'تم إنشاء المستخدم بنجاح' : 'User created successfully';
  String get userUpdated => isArabic ? 'تم تحديث المستخدم بنجاح' : 'User updated successfully';
  String get userDeleted => isArabic ? 'تم حذف المستخدم' : 'User deleted';
  String get deleteUserConfirm => isArabic ? 'حذف المستخدم' : 'Delete user ';
  String get create => isArabic ? 'إنشاء' : 'Create';
  String get update => isArabic ? 'تحديث' : 'Update';
  String get change => isArabic ? 'تغيير' : 'Change';
  String get description => isArabic ? 'الوصف' : 'Description';
  String get message => isArabic ? 'الرسالة' : 'Message';
  String get messages => isArabic ? 'الرسائل' : 'Messages';
  String get eventsManagement => isArabic ? 'إدارة الفعاليات' : 'Events Management';
  String get editEvent => isArabic ? 'تعديل فعالية' : 'Edit Event';
  String get editLink => isArabic ? 'تعديل رابط' : 'Edit Link';
  String get createNews => isArabic ? 'إنشاء خبر' : 'Create News';
  String get manageNews => isArabic ? 'إدارة الأخبار' : 'Manage News';
  String get publishMessageHint => isArabic ? 'نشر رسالة جديدة للموظفين' : 'Publish new message to employees';
  String get messageHistory => isArabic ? 'سجل الرسائل' : 'Message History';
  String get messageHistoryHint => isArabic ? 'عرض الرسائل المنشورة' : 'View published messages';
  String get createNewsHint => isArabic ? 'إنشاء خبر جديد' : 'Create new article';
  String get manageNewsHint => isArabic ? 'عرض وتعديل الأخبار' : 'View and edit news';
  String get featureComingSoon => isArabic ? 'هذه الميزة قادمة قريباً' : 'This feature is coming soon';
  String get push => isArabic ? 'إشعار فوري' : 'Push';
  String get target => isArabic ? 'الهدف' : 'Target';
  String get byRole => isArabic ? 'حسب الدور' : 'By Role';
  String get specificUsers => isArabic ? 'مستخدمين محددين' : 'Specific Users';
  String get send => isArabic ? 'إرسال' : 'Send';
  String get notificationSent => isArabic ? 'تم إرسال الإشعار بنجاح' : 'Notification sent successfully';
  String get noNotifications => isArabic ? 'لا توجد إشعارات' : 'No notifications';
  String get comingSoon => isArabic ? 'قريباً' : 'Coming Soon';
```

## How to Add

1. Open `lib/core/localization/app_localizations.dart`
2. Find line 261 (the `// ERROR MESSAGES` comment)
3. Add above code **before** that comment
4. Save the file

This adds all missing strings used in the admin screens.
