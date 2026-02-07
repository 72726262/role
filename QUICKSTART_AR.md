# 🚀 دليل البدء السريع

## المتطلبات الأساسية
- Flutter 3.0+
- Dart 3.0+
- حساب Supabase

---

## خطوات التثبيت

### 1. إعداد المشروع

```bash
# Clone المشروع
git clone <repository-url>
cd role

# تثبيت Dependencies
flutter pub get
```

### 2. إعداد Supabase

#### أ. إنشاء مشروع جديد
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. أنشئ مشروع جديد
3. احفظ Project URL و anon key

#### ب. تنفيذ SQL Scripts

في Supabase SQL Editor، نفذ الملفات بالترتيب:

```sql
-- 1. الجداول الأساسية
supabase/database_setup.sql

-- 2. الجداول الإضافية
supabase/ADDITIONAL_TABLES.sql

-- 3. إعداد Storage
supabase/storage_setup.sql
```

### 3. إعداد Environment Variables

```bash
# أنشئ ملف .env
cp .env.example .env
```

عدّل ملف `.env`:
```env
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

### 4. تشغيل التطبيق

```bash
flutter run
```

---

## 🎨 استخدام Premium Widgets

### GlassmorphicCard
```dart
import 'package:your_app/core/widgets/glassmorphic_card.dart';

GlassmorphicCard(
  onTap: () => print('تم الضغط'),
  child: Text('محتوى الكارت'),
)
```

### AnimatedButton
```dart
import 'package:your_app/core/widgets/animated_button.dart';

AnimatedButton(
  text: 'حفظ',
  icon: Icons.save,
  isLoading: _isLoading,
  onPressed: () async {
    // عملك هنا
  },
  gradient: AppGradients.primaryGradient,
)
```

### SkeletonLoader
```dart
import 'package:your_app/core/widgets/skeleton_loader.dart';

SkeletonLoader(
  isLoading: _isLoading,
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemWidget(items[index]),
  ),
)
```

### PremiumTextField
```dart
import 'package:your_app/core/widgets/premium_text_field.dart';

PremiumTextField(
  label: 'البريد الإلكتروني',
  prefixIcon: Icons.email,
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'مطلوب';
    }
    return null;
  },
)
```

### PageTransitions
```dart
import 'package:your_app/core/widgets/page_transitions.dart';

// استخدام Extension
context.pushWithTransition(
  NewScreen(),
  type: TransitionType.slideFade,
);

// أو مباشرة
Navigator.of(context).push(
  PageTransitions.slideFromRight(NewScreen()),
);
```

---

## 🌓 Dark/Light Mode

### تبديل الثيم
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/core/theme/theme_cubit.dart';

// في أي widget
ElevatedButton(
  onPressed: () {
    context.read<ThemeCubit>().toggleTheme();
  },
  child: Text('تبديل الثيم'),
)

// أو
Switch(
  value: context.watch<ThemeCubit>().state.isDark,
  onChanged: (_) {
    context.read<ThemeCubit>().toggleTheme();
  },
)
```

### الحصول على الثيم الحالي
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// استخدام الألوان المناسبة
final bgColor = isDark 
  ? AppColors.backgroundDark 
  : AppColors.backgroundLight;
```

---

## 🔄 Real-Time Features

### الإشعارات
```dart
import 'package:your_app/services/realtime_service.dart';

final realtimeService = RealtimeService();

StreamBuilder<List<Map<String, dynamic>>>(
  stream: realtimeService.subscribeToNotifications(userId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return SkeletonLoader(isLoading: true, child: widget);
    }
    
    final notifications = snapshot.data!;
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return NotificationItem(notifications[index]);
      },
    );
  },
)
```

### الرسائل
```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: realtimeService.subscribeToMessages(userRole),
  builder: (context, snapshot) {
    // بناء UI
  },
)
```

---

## 📱 التنقل بين الشاشات

### باستخدام Routes
```dart
// في main.dart أو app.dart
routes: {
  '/': (context) => LoginScreen(),
  '/register': (context) => RegisterScreen(),
  '/dashboard': (context) => DashboardScreen(),
  '/settings': (context) => SettingsScreen(),
}

// الانتقال
Navigator.pushNamed(context, '/settings');
```

### باستخدام Transitions
```dart
context.pushWithTransition(
  SettingsScreen(),
  type: TransitionType.slideFade,
);
```

---

## 🎨 الألوان والتدرجات

### الألوان
```dart
import 'package:your_app/core/theme/advanced_theme_system.dart';

Container(
  color: AppColors.primaryLight,
  // أو
  color: AppColors.primaryDarkMode, // للـ Dark Mode
)
```

### التدرجات
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppGradients.primaryGradient,
    // أو
    gradient: AppGradients.successGradient,
  ),
)
```

### Shadows
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.mediumShadowLight,
    // أو
    boxShadow: AppShadows.largeShadowDark,
  ),
)
```

---

## 🔐 Authentication

### تسجيل الدخول
```dart
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);

if (response.user != null) {
  // نجح تسجيل الدخول
  Navigator.pushReplacementNamed(context, '/dashboard');
}
```

### التسجيل
```dart
final response = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
  data: {
    'full_name': fullName,
    'role': role,
  },
);
```

### تسجيل الخروج
```dart
await Supabase.instance.client.auth.signOut();
Navigator.pushReplacementNamed(context, '/');
```

---

## 📊 قراءة البيانات

### باستخدام DatabaseService
```dart
import 'package:your_app/services/database_service.dart';

final dbService = DatabaseService();

// قراءة كل البيانات
final users = await dbService.getAll('users');

// قراءة بـ ID
final user = await dbService.getById('users', userId);

// إنشاء
await dbService.create('users', {
  'full_name': 'أحمد',
  'email': 'ahmad@example.com',
});

// تحديث
await dbService.update('users', userId, {
  'full_name': 'أحمد محمد',
});

// حذف
await dbService.delete('users', userId);
```

---

## 🎯 Tips للتطوير

### 1. استخدم Hot Reload
```bash
# في Terminal
r  # Hot reload
R  # Hot restart
```

### 2. تفعيل Null Safety
التطبيق يستخدم Null Safety بالكامل

### 3. فحص الأخطاء
```bash
flutter analyze
```

### 4. تشغيل Tests
```bash
flutter test
```

---

## 🐛 حل المشاكل الشائعة

### خطأ في Supabase Connection
```dart
// تحقق من:
1. SUPABASE_URL صحيح
2. SUPABASE_ANON_KEY صحيح
3. اتصال الإنترنت
```

### خطأ في Theme
```dart
// تأكد من وجود BlocProvider للـ ThemeCubit
BlocProvider(
  create: (context) => ThemeCubit(),
  child: MyApp(),
)
```

### خطأ في الصور
```dart
// تأكد من إعداد Storage في Supabase
// راجع: supabase/storage_setup.sql
```

---

## 📚 موارد إضافية

- [Flutter Docs](https://flutter.dev/docs)
- [Supabase Docs](https://supabase.com/docs)
- [BLoC Pattern](https://bloclibrary.dev/)

---

## 🎉 جاهز للبدء!

المشروع الآن جاهز للاستخدام. ابدأ بـ:
```bash
flutter run
```

لأي مساعدة، راجع [README.md](README.md) أو [walkthrough.md](walkthrough.md)
