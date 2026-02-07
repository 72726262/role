import 'package:flutter/material.dart';

/// App Localization for Arabic and English
/// Supports RTL for Arabic and LTR for English
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Check if current language is Arabic
  bool get isArabic => locale.languageCode == 'ar';

  // Text Direction based on language
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  // ============================================
  // GENERAL
  // ============================================
  String get appName => isArabic ? 'بوابة الموظفين' : 'Employee Portal';
  String get yes => isArabic ? 'نعم' : 'Yes';
  String get no => isArabic ? 'لا' : 'No';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get add => isArabic ? 'إضافة' : 'Add';
  String get search => isArabic ? 'بحث' : 'Search';
  String get filter => isArabic ? 'تصفية' : 'Filter';
  String get submit => isArabic ? 'إرسال' : 'Submit';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'نجح' : 'Success';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get noData => isArabic ? 'لا توجد بيانات' : 'No Data';
  String get offline => isArabic ? 'غير متصل بالإنترنت' : 'Offline';
  String get online => isArabic ? 'متصل' : 'Online';

  // ============================================
  // AUTHENTICATION
  // ============================================
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get forgotPassword => isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?';
  String get loginButton => isArabic ? 'دخول' : 'Login';
  String get loggingIn => isArabic ? 'جاري تسجيل الدخول...' : 'Logging in...';
  String get logoutConfirm => isArabic ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?';
  String get invalidEmail => isArabic ? 'البريد الإلكتروني غير صالح' : 'Invalid email';
  String get invalidPassword => isArabic ? 'كلمة المرور غير صالحة' : 'Invalid password';
  String get loginFailed => isArabic ? 'فشل تسجيل الدخول' : 'Login failed';
  String get loginSuccess => isArabic ? 'تم تسجيل الدخول بنجاح' : 'Login successful';

  // ============================================
  // ROLES
  // ============================================
  String get employee => isArabic ? 'موظف' : 'Employee';
  String get hr => isArabic ? 'الموارد البشرية' : 'HR';
  String get it => isArabic ? 'تكنولوجيا المعلومات' : 'IT';
  String get management => isArabic ? 'الإدارة' : 'Management';
  String get admin => isArabic ? 'مسؤول النظام' : 'Admin';

  // ============================================
  // EMPLOYEE DASHBOARD
  // ============================================
  String get dashboard => isArabic ? 'لوحة التحكم' : 'Dashboard';
  String get welcome => isArabic ? 'مرحباً' : 'Welcome';
  String get jobTitle => isArabic ? 'المسمى الوظيفي' : 'Job Title';
  String get department => isArabic ? 'القسم' : 'Department';
  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';
  
  // Date & Time
  String get date => isArabic ? 'التاريخ' : 'Date';
  String get time => isArabic ? 'الوقت' : 'Time';
  String get temperature => isArabic ? 'درجة الحرارة' : 'Temperature';

  // Daily Mood
  String get dailyMood => isArabic ? 'المزاج اليومي' : 'Daily Mood';
  String get howAreYouToday => isArabic ? 'كيف حالك اليوم؟' : 'How are you today?';
  String get moodHappy => isArabic ? 'سعيد' : 'Happy';
  String get moodNormal => isArabic ? 'عادي' : 'Normal';
  String get moodTired => isArabic ? 'متعب' : 'Tired';
  String get tired => isArabic ? 'متعب' : 'Tired';
  String get happy => isArabic ? 'سعيد' : 'Happy';
  String get moodNeedSupport => isArabic ? 'بحاجة للدعم' : 'Need Support';
  String get moodSubmitted => isArabic ? 'تم تسجيل المزاج بنجاح' : 'Mood submitted successfully';
  String get moodAlreadySubmitted => isArabic ? 'لقد سجلت مزاجك اليوم' : 'You have already submitted your mood today';

  // Strategic Documents
  String get strategicPyramid => isArabic ? 'الهرم الاستراتيجي' : 'Strategic Pyramid';
  String get cultureBook => isArabic ? 'كتاب الثقافة' : 'Culture Book';
  String get viewDocument => isArabic ? 'عرض المستند' : 'View Document';

  // News
  String get news => isArabic ? 'الأخبار' : 'News';
  String get companyNews => isArabic ? 'أخبار الشركة' : 'Company News';
  String get readMore => isArabic ? 'اقرأ المزيد' : 'Read More';
  String get newsDetails => isArabic ? 'تفاصيل الخبر' : 'News Details';
  String get publishedOn => isArabic ? 'نُشر في' : 'Published on';
  String get author => isArabic ? 'الكاتب' : 'Author';

  // Management Messages
  String get managementMessages => isArabic ? 'رسائل الإدارة' : 'Management Messages';
  String get officialMessage => isArabic ? 'رسالة رسمية' : 'Official Message';
  String get priority => isArabic ? 'الأولوية' : 'Priority';
  String get priorityLow => isArabic ? 'منخفضة' : 'Low';
  String get priorityMedium => isArabic ? 'متوسطة' : 'Medium';
  String get priorityHigh => isArabic ? 'عالية' : 'High';
  String get priorityUrgent => isArabic ? 'عاجلة' : 'Urgent';

  // Events
  String get events => isArabic ? 'الفعاليات' : 'Events';
  String get eventsAndOccasions => isArabic ? 'الفعاليات والمناسبات' : 'Events & Occasions';
  String get upcomingEvents => isArabic ? 'الفعاليات القادمة' : 'Upcoming Events';
  String get birthday => isArabic ? 'عيد ميلاد' : 'Birthday';
  String get meeting => isArabic ? 'اجتماع' : 'Meeting';
  String get celebration => isArabic ? 'احتفال' : 'Celebration';
  String get training => isArabic ? 'تدريب' : 'Training';
  String get other => isArabic ? 'أخرى' : 'Other';

  // Quick Links
  String get quickLinks => isArabic ? 'روابط سريعة' : 'Quick Links';

  // AI Chatbot
  String get aiChatbot => isArabic ? 'مساعد ذكي' : 'AI Assistant';
  String get chatWithAI => isArabic ? 'تحدث مع المساعد الذكي' : 'Chat with AI';

  // ============================================
  // HR DASHBOARD
  // ============================================
  String get hrDashboard => isArabic ? 'لوحة الموارد البشرية' : 'HR Dashboard';
  String get overview => isArabic ? 'نظرة عامة' : 'Overview';
  String get employeeCount => isArabic ? 'عدد الموظفين' : 'Employee Count';
  String get totalEmployees => isArabic ? 'إجمالي الموظفين' : 'Total Employees';
  String get moodStatistics => isArabic ? 'إحصائيات المزاج' : 'Mood Statistics';
  String get moodAverage => isArabic ? 'متوسط المزاج' : 'Mood Average';

  // HR Policies
  String get hrPolicies => isArabic ? 'سياسات الموارد البشرية' : 'HR Policies';
  String get policies => isArabic ? 'السياسات' : 'Policies';
  String get addPolicy => isArabic ? 'إضافة سياسة' : 'Add Policy';
  String get editPolicy => isArabic ? 'تعديل سياسة' : 'Edit Policy';
  String get deletePolicy => isArabic ? 'حذف سياسة' : 'Delete Policy';
  String get policyTitle => isArabic ? 'عنوان السياسة' : 'Policy Title';
  String get policyDescription => isArabic ? 'وصف السياسة' : 'Policy Description';
  String get uploadPDF => isArabic ? 'رفع ملف PDF' : 'Upload PDF';
  String get pdfUrl => isArabic ? 'رابط PDF' : 'PDF URL';
  String get policyFormHint => isArabic ? 'أدخل تفاصيل السياسة' : 'Enter policy details';
  String get category => isArabic ? 'الفئة' : 'Category';

  // Training & Courses
  String get trainingCourses => isArabic ? 'الدورات التدريبية' : 'Training Courses';
  String get courses => isArabic ? 'الدورات' : 'Courses';
  String get addCourse => isArabic ? 'إضافة دورة' : 'Add Course';
  String get editCourse => isArabic ? 'تعديل دورة' : 'Edit Course';
  String get courseTitle => isArabic ? 'عنوان الدورة' : 'Course Title';
  String get courseDescription => isArabic ? 'وصف الدورة' : 'Course Description';
  String get instructor => isArabic ? 'المدرب' : 'Instructor';
  String get duration => isArabic ? 'المدة' : 'Duration';
  String get hours => isArabic ? 'ساعة' : 'Hours';
  String get startDate => isArabic ? 'تاريخ البدء' : 'Start Date';
  String get endDate => isArabic ? 'تاريخ الانتهاء' : 'End Date';
  String get maxParticipants => isArabic ? 'الحد الأقصى للمشاركين' : 'Max Participants';

  // Recruitment
  String get recruitmentPortal => isArabic ? 'بوابة التوظيف' : 'Recruitment Portal';
  String get jobPostings => isArabic ? 'الوظائف المتاحة' : 'Job Postings';
  String get manageJobPostings => isArabic ? 'إدارة الوظائف' : 'Manage Job Postings';

  // Mood Reports
  String get moodReports => isArabic ? 'تقارير المزاج' : 'Mood Reports';
  String get viewReports => isArabic ? 'عرض التقارير' : 'View Reports';

  // ============================================
  // IT DASHBOARD
  // ============================================
  String get itDashboard => isArabic ? 'لوحة تكنولوجيا المعلومات' : 'IT Dashboard';
  String get itPolicies => isArabic ? 'سياسات تكنولوجيا المعلومات' : 'IT Policies';
  String get cyberSecurity => isArabic ? 'الأمن السيبراني' : 'Cyber Security';
  String get securityAwareness => isArabic ? 'التوعية الأمنية' : 'Security Awareness';
  String get itAnnouncements => isArabic ? 'إعلانات تكنولوجيا المعلومات' : 'IT Announcements';
  String get supportContacts => isArabic ? 'جهات الاتصال للدعم' : 'Support Contacts';
  String get itSupport => isArabic ? 'الدعم الفني' : 'IT Support';

  // ============================================
  // MANAGEMENT DASHBOARD
  // ============================================
  String get managementDashboard => isArabic ? 'لوحة الإدارة' : 'Management Dashboard';
  String get companyEngagement => isArabic ? 'مشاركة الشركة' : 'Company Engagement';
  String get engagementOverview => isArabic ? 'نظرة عامة على المشاركة' : 'Engagement Overview';
  String get moodTrends => isArabic ? 'اتجاهات المزاج' : 'Mood Trends';
  String get publishMessage => isArabic ? 'نشر رسالة' : 'Publish Message';
  String get messageTitle => isArabic ? 'عنوان الرسالة' : 'Message Title';
  String get messageContent => isArabic ? 'محتوى الرسالة' : 'Message Content';
  String get visibility => isArabic ? 'الظهور' : 'Visibility';
  String get visibilityControl => isArabic ? 'التحكم في الظهور' : 'Visibility Control';
  String get expiryDate => isArabic ? 'تاريخ الانتهاء' : 'Expiry Date';

  // ============================================
  // ADMIN DASHBOARD
  // ============================================
  String get adminDashboard => isArabic ? 'لوحة المسؤول' : 'Admin Dashboard';
  String get systemAdmin => isArabic ? 'مسؤول النظام' : 'System Admin';

  // User Management
  String get userManagement => isArabic ? 'إدارة المستخدمين' : 'User Management';
  String get users => isArabic ? 'المستخدمون' : 'Users';
  String get addUser => isArabic ? 'إضافة مستخدم' : 'Add User';
  String get editUser => isArabic ? 'تعديل مستخدم' : 'Edit User';
  String get deleteUser => isArabic ? 'حذف مستخدم' : 'Delete User';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get role => isArabic ? 'الدور' : 'Role';
  String get status => isArabic ? 'الحالة' : 'Status';
  String get active => isArabic ? 'نشط' : 'Active';
  String get inactive => isArabic ? 'غير نشط' : 'Inactive';

  // Content Management
  String get contentManagement => isArabic ? 'إدارة المحتوى' : 'Content Management';
  String get manageContent => isArabic ? 'إدارة المحتوى' : 'Manage Content';
  String get addNews => isArabic ? 'إضافة خبر' : 'Add News';
  String get editNews => isArabic ? 'تعديل خبر' : 'Edit News';
  String get title => isArabic ? 'العنوان' : 'Title';
  String get content => isArabic ? 'المحتوى' : 'Content';
  String get image => isArabic ? 'الصورة' : 'Image';
  String get uploadImage => isArabic ? 'رفع صورة' : 'Upload Image';
  String get published => isArabic ? 'منشور' : 'Published';
  String get draft => isArabic ? 'مسودة' : 'Draft';

  // Navigation Links
  String get navigationLinks => isArabic ? 'روابط التنقل' : 'Navigation Links';
  String get manageLinks => isArabic ? 'إدارة الروابط' : 'Manage Links';
  String get addLink => isArabic ? 'إضافة رابط' : 'Add Link';
  String get linkTitle => isArabic ? 'عنوان الرابط' : 'Link Title';
  String get linkTitleAr => isArabic ? 'العنوان بالعربية' : 'Title in Arabic';
  String get url => isArabic ? 'الرابط' : 'URL';
  String get icon => isArabic ? 'الأيقونة' : 'Icon';
  String get displayOrder => isArabic ? 'ترتيب العرض' : 'Display Order';

  // Events & Polls
  String get eventsPolls => isArabic ? 'الفعاليات والاستطلاعات' : 'Events & Polls';
  String get manageEvents => isArabic ? 'إدارة الفعاليات' : 'Manage Events';
  String get addEvent => isArabic ? 'إضافة فعالية' : 'Add Event';
  String get eventTitle => isArabic ? 'عنوان الفعالية' : 'Event Title';
  String get eventDescription => isArabic ? 'وصف الفعالية' : 'Event Description';
  String get eventDate => isArabic ? 'تاريخ الفعالية' : 'Event Date';
  String get eventType => isArabic ? 'نوع الفعالية' : 'Event Type';

  // Notifications
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get notificationsCenter => isArabic ? 'مركز الإشعارات' : 'Notifications Center';
  String get sendNotification => isArabic ? 'إرسال إشعار' : 'Send Notification';
  String get notificationTitle => isArabic ? 'عنوان الإشعار' : 'Notification Title';
  String get notificationMessage => isArabic ? 'رسالة الإشعار' : 'Notification Message';
  String get recipients => isArabic ? 'المستلمون' : 'Recipients';
  String get allUsers => isArabic ? 'جميع المستخدمين' : 'All Users';
  String get selectUsers => isArabic ? 'تحديد مستخدمين' : 'Select Users';
  String get notificationType => isArabic ? 'نوع الإشعار' : 'Notification Type';
  String get emailNotification => isArabic ? 'إشعار بريد إلكتروني' : 'Email Notification';
  String get pushNotification => isArabic ? 'إشعار فوري' : 'Push Notification';
  String get inAppNotification => isArabic ? 'إشعار داخل التطبيق' : 'In-App Notification';
  String get whatsappNotification => isArabic ? 'إشعار واتساب' : 'WhatsApp Notification';

  // ============================================
  // ADDITIONAL ADMIN & COMMON STRINGS
  // ============================================
  String get systemManagement => isArabic ? 'إدارة النظام' : 'System Management';
  String get systemSettings => isArabic ? 'إعدادات النظام' : 'System Settings';
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
  String get deleteUserConfirm => isArabic ? 'حذف المستخدم' : 'Delete user';
  String get create => isArabic ? 'إنشاء' : 'Create';
  String get update => isArabic ? 'تحديث' : 'Update';
  String get change => isArabic ? 'تغيير' : 'Change';
  String get description => isArabic ? 'الوصف' : 'Description';
  String get message => isArabic ? 'الرسالة' : 'Message';
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

  // Missing strings from errors
  String get employeeDashboard => isArabic ? 'لوحة الموظف' : 'Employee Dashboard';
  String get user => isArabic ? 'المستخدم' : 'User';
  String get moodSubmittedSuccessfully => isArabic ? 'تم تسجيل المزاج بنجاح' : 'Mood submitted successfully';
  String get normal => isArabic ? 'عادي' : 'Normal';
  String get needSupport => isArabic ? 'بحاجة للدعم' : 'Need Support';
  String get strategicContent => isArabic ? 'المحتوى الاستراتيجي' : 'Strategic Content';
  String get cultureHandbook => isArabic ? 'دليل الثقافة' : 'Culture Handbook';
  String get seeAll => isArabic ? 'عرض الكل' : 'See All';
  String get noNewsAvailable => isArabic ? 'لا توجد أخبار' : 'No news available';
  String get noEventsAvailable => isArabic ? 'لا توجد فعاليات' : 'No events available';
  String get moodAnalytics => isArabic ? 'تحليلات المزاج' : 'Mood Analytics';
  String get noPoliciesAvailable => isArabic ? 'لا توجد سياسات' : 'No policies available';
  String get viewPDF => isArabic ? 'عرض PDF' : 'View PDF';
  String get deleteConfirmMessage => isArabic ? 'هل تريد حذف هذا العنصر؟' : 'Do you want to delete this item?';
  String get categoryHint => isArabic ? 'اختر الفئة' : 'Select category';
  String get durationHours => isArabic ? 'المدة (ساعات)' : 'Duration (hours)';
  String get notSelected => isArabic ? 'غير محدد' : 'Not selected';
  String get noCoursesAvailable => isArabic ? 'لا توجد دورات' : 'No courses available';
  String get max => isArabic ? 'الحد الأقصى' : 'Max';
  String get totalUsers => isArabic ? 'إجمالي المستخدمين' : 'Total Users';
  String get activeDevices => isArabic ? 'الأجهزة النشطة' : 'Active Devices';
  String get emailSupport => isArabic ? 'الدعم عبر البريد' : 'Email Support';
  String get phoneSupport => isArabic ? 'الدعم الهاتفي' : 'Phone Support';
  String get systemAnnouncements => isArabic ? 'إعلانات النظام' : 'System Announcements';
  String get systemMaintenance => isArabic ? 'صيانة النظام' : 'System Maintenance';
  String get scheduledMaintenanceMessage => isArabic ? 'صيانة مجدولة للنظام' : 'Scheduled system maintenance';
  String get securityUpdate => isArabic ? 'تحديث أمني' : 'Security Update';
  String get securityUpdateMessage => isArabic ? 'تحديث أمني مهم' : 'Important security update';
  String get policyType => isArabic ? 'نوع السياسة' : 'Policy Type';
  String get engagementRate => isArabic ? 'معدل التفاعل' : 'Engagement Rate';
  String get moodDistribution => isArabic ? 'توزيع المزاج' : 'Mood Distribution';
  String get publishedMessages => isArabic ? 'الرسائل المنشورة' : 'Published Messages';
  String get noMessagesPublished => isArabic ? 'لا توجد رسائل منشورة' : 'No messages published';
  String get publishNewMessage => isArabic ? 'نشر رسالة جديدة' : 'Publish New Message';
  String get messages => isArabic ? 'الرسائل' : 'Messages';

  // ============================================
  // VALIDATION MESSAGES
  // ============================================
  String get fieldRequired => isArabic ? 'هذا الحقل مطلوب' : 'This field is required';
  String get required => isArabic ? 'مطلوب' : 'Required';
  String get invalidInput => isArabic ? 'إدخال غير صالح' : 'Invalid input';
  String get confirmDelete => isArabic ? 'هل أنت متأكد من الحذف؟' : 'Are you sure you want to delete?';
  String get deleteSuccess => isArabic ? 'تم الحذف بنجاح' : 'Deleted successfully';
  String get saveSuccess => isArabic ? 'تم الحفظ بنجاح' : 'Saved successfully';
  String get updateSuccess => isArabic ? 'تم التحديث بنجاح' : 'Updated successfully';
  String get createSuccess => isArabic ? 'تم الإنشاء بنجاح' : 'Created successfully';
  String get operationFailed => isArabic ? 'فشلت العملية' : 'Operation failed';

  // ============================================
  // ERROR MESSAGES
  // ============================================
  String get serverError => isArabic ? 'خطأ في الخادم' : 'Server error';
  String get networkError => isArabic ? 'خطأ في الشبكة' : 'Network error';
  String get noInternetConnection => isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
  String get sessionExpired => isArabic ? 'انتهت الجلسة' : 'Session expired';
  String get unauthorized => isArabic ? 'غير مصرح' : 'Unauthorized';
  String get accessDenied => isArabic ? 'تم رفض الوصول' : 'Access denied';
  String get somethingWentWrong => isArabic ? 'حدث خطأ ما' : 'Something went wrong';
  String get tryAgainLater => isArabic ? 'حاول مرة أخرى لاحقاً' : 'Try again later';
}

// Delegate for loading localizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
