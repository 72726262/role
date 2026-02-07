# 🚀 دليل سريع - Supabase Setup (مضمون 100%)

## ✅ الخطوة 1: تطبيق Schema (خطوة واحدة فقط!)

### افتح Supabase Dashboard
1. اذهب إلى https://supabase.com/dashboard
2. اختر مشروعك
3. اضغط على **SQL Editor** من القائمة

### شغّل الـ Script
1. اضغط **+ New Query**
2. افتح ملف `supabase/SIMPLE_SETUP.sql`
3. **Select All** (Ctrl+A) و **Copy**
4. الصق في Supabase SQL Editor
5. اضغط **Run** (أو Ctrl+Enter)

**✅ سترى رسالة النجاح:**
```
✅ Schema created successfully!
✅ 12 tables created
✅ 8 triggers created
✅ RLS enabled and policies set
```

**❌ إذا ظهر خطأ:**
شغّل هذا الأمر أولاً (لحذف كل شيء):
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```
ثم ارجع وشغّل `SIMPLE_SETUP.sql` مرة أخرى.

---

## ✅ الخطوة 2: إنشاء Test User واحد (للتجربة)

### اذهب إلى Authentication
1. من القائمة الجانبية: **Authentication**
2. اضغط **Users**
3. اضغط **Add User** → **Create new user**

### املأ البيانات
- **Email**: `admin@test.com`
- **Password**: `Admin@123456`
- ✅ **Auto Confirm User** (مهم!)
- اضغط **Create User**

### انسخ الـ UUID
- بعد إنشاء User، **انسخ الـ UUID** (الرقم الطويل)

---

## ✅ الخطوة 3: إضافة User للجدول

ارجع لـ **SQL Editor** وشغّل هذا (استبدل UUID):

```sql
-- استبدل YOUR-UUID-HERE بالـ UUID اللي نسخته
INSERT INTO public.users (id, email, full_name, role_id)
VALUES (
    'YOUR-UUID-HERE'::uuid,
    'admin@test.com',
    'Admin User',
    (SELECT id FROM public.roles WHERE role_name = 'Admin')
);

-- أنشئ Profile
INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'YOUR-UUID-HERE'::uuid,
    'System Admin',
    'IT'
);
```

**مثال بـ UUID حقيقي:**
```sql
INSERT INTO public.users (id, email, full_name, role_id)
VALUES (
    'a1b2c3d4-1234-5678-90ab-cdef12345678'::uuid,
    'admin@test.com',
    'Admin User',
    (SELECT id FROM public.roles WHERE role_name = 'Admin')
);

INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'a1b2c3d4-1234-5678-90ab-cdef12345678'::uuid,
    'System Admin',
    'IT'
);
```

---

## ✅ الخطوة 4: تطبيق بيانات تجريبية (اختياري)

### إضافة خبر تجريبي
```sql
INSERT INTO public.news (title, content, is_published, published_at)
VALUES (
    'مرحباً بك في النظام',
    'هذا خبر تجريبي لاختبار النظام',
    true,
    NOW()
);
```

### إضافة فعالية
```sql
INSERT INTO public.events (title, description, event_type, event_date, icon_name)
VALUES (
    'اجتماع الفريق',
    'اجتماع شهري',
    'meeting',
    CURRENT_DATE + INTERVAL '7 days',
    'groups'
);
```

### إضافة روابط سريعة
```sql
INSERT INTO public.navigation_links (title, icon_name, url, display_order)
VALUES 
    ('دليل الموظف', 'menu_book', 'https://company.com/handbook', 1),
    ('نظام الرواتب', 'payments', 'https://payroll.company.com', 2),
    ('الدعم الفني', 'support', 'https://support.company.com', 3);
```

---

## ✅ الخطوة 5: إعداد Flutter App

### 1. افتح `lib/core/config/supabase_config.dart`

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

### 2. احصل على البيانات من Supabase
- اذهب إلى **Project Settings** > **API**
- انسخ:
  - **Project URL** → ضعه في `supabaseUrl`
  - **anon/public key** → ضعه في `supabaseAnonKey`

---

## ✅ الخطوة 6: شغّل Flutter

```bash
cd c:\Users\HP\Desktop\Projects\role
flutter pub get
flutter run
```

---

## 🎯 اختبار

### تسجيل الدخول
- **Email**: `admin@test.com`
- **Password**: `Admin@123456`

### يجب أن ترى:
✅ Admin Dashboard مع 6 cards  
✅ جميع الـ screens تفتح بدون أخطاء  

---

## ❌ حل المشاكل الشائعة

### مشكلة: "relation does not exist"
**الحل**: شغّل `SIMPLE_SETUP.sql` مرة أخرى

### مشكلة: "trigger already exists"
**الحل**: 
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
```
ثم شغّل `SIMPLE_SETUP.sql`

### مشكلة: Login fails (400 error)
**الحل**: تأكد من:
- Supabase URL صحيح
- Anon Key صحيح
- User موجود في Authentication

### مشكلة: "Invalid login credentials"
**الحل**: 
- تأكد User معمول له Auto Confirm
- تأكد Password صحيح
- حاول reset password من Supabase Dashboard

---

## 🎉 تم!

Database جاهز وFlutter App شغال!

**الخطوات التالية:**
- أضف المزيد من الـ users
- جرب كل الـ dashboards
- شوف المميزات في `walkthrough.md`
