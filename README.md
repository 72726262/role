# 🎨 Premium Employee Portal

<div align="center">

**نظام إدارة موظفين احترافي مع UI فاخر وميزات Real-Time**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## ✨ الميزات الرئيسية

### 🎨 UI/UX Premium
- **Glassmorphic Design** - تأثيرات Blur احترافية
- **Dark/Light Mode** - تبديل سلس بين الوضعين
- **Premium Animations** - حركات ناعمة ومبهرة
- **Skeleton Loaders** - حالات تحميل احترافية
- **Gradient Backgrounds** - خلفيات تدرجية جميلة

### 🔄 Real-Time Features
- إشعارات فورية
- رسائل Real-time
- تحديثات الأخبار المباشرة
- الفعاليات القادمة

### 📱 الشاشات (11 شاشة)
1. **Settings** - إعدادات شاملة
2. **Create News** - إنشاء أخبار مع محرر غني
3. **User Detail** - تفاصيل المستخدم الكاملة
4. **Messages Inbox** - صندوق الرسائل
5. **Compose Message** - إنشاء رسالة
6. **Message Detail** - تفاصيل الرسالة
7. **Notifications Center** - مركز الإشعارات
8. **Event Detail** - تفاصيل الفعالية
9. **Enhanced Employee Dashboard** - لوحة تحكم الموظف
10. **Login** - تسجيل الدخول
11. **Register** - التسجيل

---

## 🛠️ التقنيات المستخدمة

### Core
```yaml
flutter: SDK 3.0+
dart: 3.0+
```

### State Management
```yaml
flutter_bloc: ^8.1.6
equatable: ^2.0.5
```

### Backend
```yaml
supabase_flutter: ^2.7.0
```

### UI/UX
```yaml
skeletonizer: ^1.4.2        # Skeleton loaders
shimmer: ^3.0.0              # Shimmer effects
cached_network_image: ^3.4.1 # Image caching
```

### Storage
```yaml
shared_preferences: ^2.3.3   # Local storage
hive: ^2.2.3                 # NoSQL database
```

---

## 🚀 البدء السريع

### المتطلبات
- Flutter SDK 3.0+
- Dart 3.0+
- حساب Supabase

### التثبيت

1. **Clone المشروع**
```bash
git clone <repository-url>
cd role
```

2. **تثبيت Dependencies**
```bash
flutter pub get
```

3. **إعداد Supabase**
```bash
# أنشئ ملف .env
cp .env.example .env

# أضف بيانات Supabase
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

4. **تشغيل SQL Scripts**
```sql
-- في Supabase SQL Editor
-- نفذ:
1. supabase/database_setup.sql
2. supabase/ADDITIONAL_TABLES.sql
3. supabase/storage_setup.sql
```

5. **تشغيل التطبيق**
```bash
flutter run
```

---

## 📁 البنية المعمارية

```
lib/
├── core/
│   ├── theme/
│   │   ├── advanced_theme_system.dart   # نظام الألوان والتدرجات
│   │   ├── theme_cubit.dart             # إدارة الثيم
│   │   └── app_theme.dart               # إعدادات الثيم
│   │
│   └── widgets/
│       ├── glassmorphic_card.dart       # 💎 Glassmorphic card
│       ├── animated_button.dart         # 🎯 Animated button
│       ├── skeleton_loader.dart         # 💀 Skeleton loader
│       ├── premium_text_field.dart      # ✨ Premium input
│       └── page_transitions.dart        # 🎬 Page transitions
│
├── features/
│   ├── admin/
│   │   ├── create_news_screen.dart
│   │   └── user_detail_screen.dart
│   │
│   ├── messages/
│   │   ├── messages_screen.dart
│   │   ├── compose_message_screen.dart
│   │   └── message_detail_screen.dart
│   │
│   ├── notifications/
│   │   └── notifications_screen.dart
│   │
│   ├── events/
│   │   └── event_detail_screen.dart
│   │
│   ├── employee/
│   │   └── enhanced_employee_dashboard.dart
│   │
│   └── settings/
│       └── settings_screen.dart
│
└── services/
    ├── realtime_service.dart            # 🔄 Real-time subscriptions
    ├── database_service.dart
    └── storage_service.dart
```

---

## 🎨 Premium Widgets

### 💎 GlassmorphicCard
```dart
GlassmorphicCard(
  onTap: () {},
  child: YourContent(),
)
```

### 🎯 AnimatedButton
```dart
AnimatedButton(
  text: 'نشر',
  icon: Icons.publish,
  isLoading: isLoading,
  onPressed: () {},
  gradient: AppGradients.primaryGradient,
)
```

### 💀 SkeletonLoader
```dart
SkeletonLoader(
  isLoading: true,
  child: YourList(),
)
```

### ✨ PremiumTextField
```dart
PremiumTextField(
  label: 'البريد الإلكتروني',
  prefixIcon: Icons.email,
  controller: emailController,
)
```

### 🎬 PageTransitions
```dart
context.pushWithTransition(
  NewScreen(),
  type: TransitionType.slideFade,
)
```

---

## 🔄 Real-Time Features

```dart
// Subscribe to notifications
final stream = RealtimeService().subscribeToNotifications(userId);

// Subscribe to messages
final messages = RealtimeService().subscribeToMessages(userRole);

// Subscribe to news
final news = RealtimeService().subscribeToNews();

// Subscribe to events
final events = RealtimeService().subscribeToEvents();
```

---

## 🎨 Theme System

### تبديل الثيم
```dart
// في أي مكان في التطبيق
context.read<ThemeCubit>().toggleTheme();
```

### الألوان
```dart
// Light Mode
AppColors.primaryLight
AppColors.backgroundLight
AppColors.textPrimaryLight

// Dark Mode
AppColors.primaryDarkMode
AppColors.backgroundDark
AppColors.textPrimaryDark
```

### Gradients
```dart
AppGradients.primaryGradient
AppGradients.successGradient
AppGradients.errorGradient
```

---

## 📊 Database Schema

### Users Table
```sql
- id (UUID)
- full_name (TEXT)
- email (TEXT)
- role_id (UUID)
- department (TEXT)
- is_active (BOOLEAN)
- avatar_url (TEXT)
```

### Messages Table
```sql
- id (UUID)
- sender_id (UUID)
- receiver_role (TEXT)
- title (TEXT)
- content (TEXT)
- attachments (JSONB)
- is_important (BOOLEAN)
```

### Notifications Table
```sql
- id (UUID)
- user_id (UUID)
- type (TEXT)
- title (TEXT)
- body (TEXT)
- is_read (BOOLEAN)
```

---

## 🎯 Best Practices

### 1. State Management
- ✅ استخدام BLoC/Cubit
- ✅ Immutable states
- ✅ Event-driven architecture

### 2. Performance
- ✅ Lazy loading
- ✅ Image caching
- ✅ Optimized builds
- ✅ Skeleton loaders

### 3. Code Quality
- ✅ Clean Architecture
- ✅ SOLID principles
- ✅ Type-safe code
- ✅ Error handling

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file

---

## 🤝 المساهمة

المساهمات مرحب بها! الرجاء:
1. Fork المشروع
2. إنشاء Feature Branch
3. Commit التغييرات
4. Push إلى Branch
5. فتح Pull Request

---

## 📞 الدعم

للمساعدة أو الأسئلة:
- افتح Issue في GitHub
- راجع [documentation](docs/)

---

<div align="center">

**بُني بـ ❤️ باستخدام Flutter & Supabase**

🎨 **Premium Quality** | 🚀 **Production Ready** | 💎 **Modern UI**

</div>