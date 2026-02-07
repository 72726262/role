# 🔧 دليل إصلاح الأخطاء الـ 244

## ملخص الأخطاء

### 1. Localization Strings ✅ **تم**
- أضفنا 37 string ناقص
- الأخطاء المتعلقة بـ localization انخفضت من ~100 إلى ~0

### 2. Database Service Methods ❌ **محتاج إصلاح**

الأخطاء دي محتاجة إضافة methods في `DatabaseService`:

#### Methods الناقصة:
```dart
// في lib/services/database_service.dart

// 1. Check mood submitted today
Future<bool> checkMoodSubmittedToday(String userId) async {
  // Implementation
}

// 2. Create mood
Future<void> createMood({
  required String userId,
  required String moodType,
  String? notes,
}) async {
  // Implementation
}

// 3. Get total employees count
Future<int> getTotalEmployeesCount() async {
  // Implementation
}

// 4. HR Policy CRUD - fix parameters
Future<void> createHRPolicy(Map<String, dynamic> policy) async {
  // Change from named parameters to Map
}

Future<void> updateHRPolicy(String id, Map<String, dynamic> policy) async {
  // Change from named parameters to Map with ID
}

// 5. Training Course CRUD - fix parameters
Future<void> createTrainingCourse(Map<String, dynamic> course) async {
  // Change from named parameters to Map
}

Future<void> updateTrainingCourse(String id, Map<String, dynamic> course) async {
  // Change from named parameters to Map with ID
}

// 6. IT Policy CRUD - fix parameters
Future<void> createITPolicy(Map<String, dynamic> policy) async {
  // Change from named parameters to Map
}

Future<void> updateITPolicy(String id, Map<String, dynamic> policy) async {
  // Change from named parameters to Map with ID
}
```

### 3. Cubits - Wrong Method Calls ❌ **محتاج إصلاح**

في الـ `hr_dashboard_cubit.dart` و `it_dashboard_cubit.dart`:

**قبل:**
```dart
await _db.createHRPolicy(
  title: title,
  description: description,
  pdfUrl: pdfUrl,
  category: category,
);
```

**بعد:**
```dart
await _db.createHRPolicy({
  'title': title,
  'description': description,
  'pdf_url': pdfUrl,
  'category': category,
});
```

### 4. Theme Issue ❌ **محتاج إصلاح**

في `lib/core/theme/app_theme.dart` line 80:

**Error:**
```
The argument type 'CardTheme' can't be assigned to 'CardThemeData?'
```

**Fix:**
```dart
// Change from:
cardTheme: CardTheme(...)

// To:
cardTheme: CardThemeData(...)
```

### 5. IT Dashboard Error ❌ **خطأ في الكود**

في `lib/features/it/it_dashboard_screen.dart` line 112:

**Error:**
```
Undefined name 'localization'
Expected to find ','
```

**Fix:**
```dart
// Line 112 - probably has typo
// Check and fix syntax error
```

---

## الإصلاحات المطلوبة بالترتيب

### Priority 1: Database Service
1. افتح `lib/services/database_service.dart`
2. أضف الـ methods الناقصة (شوف القائمة فوق)

### Priority 2: Fix Cubits
1. `lib/cubits/hr/hr_dashboard_cubit.dart`
2. `lib/cubits/it/it_dashboard_cubit.dart`
3. غيّر من named parameters إلى Map

### Priority 3: Fix Theme
1. `lib/core/theme/app_theme.dart` line 80
2. غيّر `CardTheme` إلى `CardThemeData`

### Priority 4: Fix IT Dashboard
1. `lib/features/it/it_dashboard_screen.dart` line 112
2. صحح الـ syntax error

---

## عدد الأخطاء المتبقية

| النوع | العدد | الحالة |
|-------|------|--------|
| Localization | ~100 | ✅ تم |
| Database Service | ~45 | ❌ ناقص |
| Theme | 1 | ❌ ناقص |
| Syntax | 2 | ❌ ناقص |
| Warnings | ~96 (info) | ⚠️ اختياري |

**Total Errors متبقية: ~48**  
**Warnings (info): ~96** (مش مهمة، بس best practices)

---

## خطوات التنفيذ

### 1. أضف Database Methods

افتح `lib/services/database_service.dart` و أضف:

```dart
// Mood methods
Future<bool> checkMoodSubmittedToday(String userId) async {
  try {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final response = await supabase
        .from('moods')
        .select()
        .eq('user_id', userId)
        .gte('recorded_at', startOfDay.toIso8601String())
        .single();
    
    return response != null;
  } catch (e) {
    return false;
  }
}

Future<void> createMood({
  required String userId,
  required String moodType,
  String? notes,
}) async {
  await supabase.from('moods').insert({
    'user_id': userId,
    'mood_type': moodType,
    'notes': notes,
  });
}

Future<int> getTotalEmployeesCount() async {
  final response = await supabase
      .from('users')
      .select('id', const FetchOptions(count: CountOption.exact));
  return response.count ?? 0;
}

// HR Policy methods - change to Map
Future<void> createHRPolicy(Map<String, dynamic> policy) async {
  await supabase.from('hr_policies').insert(policy);
}

Future<void> updateHRPolicy(String id, Map<String, dynamic> policy) async {
  await supabase.from('hr_policies').update(policy).eq('id', id);
}

// Training Course methods - change to Map
Future<void> createTrainingCourse(Map<String, dynamic> course) async {
  await supabase.from('training_courses').insert(course);
}

Future<void> updateTraining Course(String id, Map<String, dynamic> course) async {
  await supabase.from('training_courses').update(course).eq('id', id);
}

// IT Policy methods - change to Map
Future<void> createITPolicy(Map<String, dynamic> policy) async {
  await supabase.from('it_policies').insert(policy);
}

Future<void> updateITPolicy(String id, Map<String, dynamic> policy) async {
  await supabase.from('it_policies').update(policy).eq('id', id);
}
```

### 2. Fix Cubits

في `lib/cubits/hr/hr_dashboard_cubit.dart` line 67:

**قبل:**
```dart
await _db.createHRPolicy(
  title: title,
  description: description,
  pdfUrl: pdfUrl,
  category: category,
);
```

**بعد:**
```dart
await _db.createHRPolicy({
  'title': title,
  'description': description,
  'pdf_url': pdfUrl,
  'category': category,
  'created_by': supabase.auth.currentUser?.id,
});
```

عدّل نفس الشيء لـ:
- `updateHRPolicy` (line 88)
- `createTrainingCourse` (line 139)
- `updateTrainingCourse` (line 166)

في `lib/cubits/it/it_dashboard_cubit.dart`:
- `createITPolicy` (line 64)
- `updateITPolicy` (line 85)

### 3. Fix Theme

في `lib/core/theme/app_theme.dart` line 80:

```dart
// Change:
cardTheme: CardTheme(...)

// To:
cardTheme: CardThemeData(...)
```

### 4. Fix IT Dashboard Syntax

افتح `lib/features/it/it_dashboard_screen.dart` line 112 وصحح الخطأ.

---

## بعد التعديلات

شغّل:
```bash
flutter analyze
```

المفروض الأخطاء تنزل من 244 إلى ~5-10 فقط!

---

## الـ Warnings (اختياري)

باق ~ 96 warning من نوع `info`:
- `withOpacity` deprecated (use `.withValues()`)
- `value` deprecated (use `initialValue`)
- `prefer_const_constructors`
- `unused_import`

دول مش هيمنعوا المشروع من الشغل! ✅
