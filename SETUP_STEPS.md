# 🚀 خطوات التشغيل - بالترتيب

## الخطوة 1: تطبيق SQL Schema في Supabase

### الطريقة 1: عبر Dashboard (الأسهل)
1. افتح https://supabase.com/dashboard
2. اختر المشروع: `mwruqqjbaqqdygbrggmd`
3. من القائمة الجانبية -> **SQL Editor**
4. اضغط **New Query**
5. افتح ملف `c:\Users\HP\Desktop\Projects\role\supabase\schema.sql`
6. انسخ **كل المحتوى** (Ctrl+A ثم Ctrl+C)
7. الصقه في SQL Editor (Ctrl+V)
8. اضغط **Run** (أو F5)
9. انتظر 10-30 ثانية حتى يكتمل
10. إذا رأيت "Success" -> ✅ تم بنجاح!

---

## الخطوة 2: إنشاء Storage Buckets

### Bucket 1: documents
1. من Dashboard -> **Storage** (في القائمة الجانبية)
2. اضغط **New bucket**
3. **Name**: `documents`
4. **Public bucket**: ✅ نعم (اختر ON)
5. اضغط **Create bucket**

### Bucket 2: images
1. اضغط **New bucket** مرة أخرى
2. **Name**: `images`
3. **Public bucket**: ✅ نعم (اختر ON)
4. اضغط **Create bucket**

---

## الخطوة 3: إنشاء مستخدم Admin للاختبار

### أ. إنشاء User في Authentication
1. من Dashboard -> **Authentication** -> **Users**
2. اضغط **Add user**  
3. اختر **Create new user**
4. **Email**: `admin@company.com`
5. **Password**: `Admin@123456` (أو أي كلمة مرور قوية)
6. ✅ فعّل **Auto Confirm User**
7. اضغط **Create user**
8. **انسخ الـ UUID** (سيظهر في القائمة) - مثلاً: `123e4567-e89b-12d3-a456-426614174000`

### ب. إضافة User إلى جدول users
1. ارجع إلى **SQL Editor**
2. **New Query**
3. انسخ والصق الكود التالي (استبدل UUID بما نسخته):

```sql
-- استبدل 'UUID-من-الخطوة-السابقة' بالـ UUID الحقيقي
DO $$
DECLARE
  admin_uuid UUID := 'UUID-من-الخطوة-السابقة'; -- ضع الـ UUID هنا
  admin_role_id UUID;
BEGIN
  -- Get Admin role ID
  SELECT id INTO admin_role_id FROM public.roles WHERE role_name = 'Admin';
  
  -- Insert user
  INSERT INTO public.users (id, email, full_name, role_id, is_active)
  VALUES (
    admin_uuid,
    'admin@company.com',
    'System Administrator',
    admin_role_id,
    true
  );
  
  -- Insert employee profile
  INSERT INTO public.employee_profiles (user_id, job_title, department)
  VALUES (
    admin_uuid,
    'System Administrator',
    'IT Department'
  );
END $$;
```

4. اضغط **Run**
5. إذا نجح -> ✅ Admin user جاهز!

---

## الخطوة 4: تشغيل Flutter Project

### أ. تحميل Dependencies

افتح Terminal/PowerShell في مجلد المشروع:
```bash
cd c:\Users\HP\Desktop\Projects\role
flutter pub get
```

انتظر حتى تنتهي (1-2 دقيقة)

### ب. تشغيل التطبيق

```bash
flutter run
```

اختر الجهاز (emulator أو physical device)

---

## الخطوة 5: اختبار Login

1. عند فتح التطبيق، ستظهر شاشة Login
2. أدخل:
   - **Email**: `admin@company.com`
   - **Password**: `Admin@123456` (أو ما اخترته)
3. اضغط **تسجيل الدخول**
4. يجب أن تنتقل إلى **Admin Dashboard**

---

## الخطوة 6  (اختياري): تحميل Cairo Fonts

### لتحسين المظهر:
1. اذهب إلى: https://fonts.google.com/specimen/Cairo
2. اضغط **Download family**
3. فك الضغط عن الملف
4. انسخ الملفات التالية إلى `c:\Users\HP\Desktop\Projects\role\assets\fonts\`:
   - `Cairo-Regular.ttf`
   - `Cairo-Bold.ttf`
   - `Cairo-SemiBold.ttf`

5. افتح `pubspec.yaml`
6. **أزل التعليق (#)** من سطور fonts:
```yaml
fonts:
  - family: Cairo
    fonts:
      - asset: assets/fonts/Cairo-Regular.ttf
      - asset: assets/fonts/Cairo-Bold.ttf
        weight: 700
      - asset: assets/fonts/Cairo-SemiBold.ttf
        weight: 600
```

7. شغّل في Terminal:
```bash
flutter pub get
flutter run
```

---

## ✅ Checklist النهائي

قبل ما تبدأ تطوير:

- [ ] ✅ SQL Schema مطبّق بنجاح
- [ ] ✅ Storage buckets (documents + images) موجودة
- [ ] ✅ Admin user منشأ ومضاف للجدول
- [ ] ✅ flutter pub get نجح بدون أخطاء
- [ ] ✅ التطبيق يشتغل
- [ ] ✅ Login يعمل و ينقل لـ Dashboard
- [ ] ⏳ Cairo fonts محملة (اختياري)

---

## 🐛 حل المشاكل الشائعة

### مشكلة: SQL Error في السطر 204
**الحل**: تأكد من استخدام schema.sql المحدّث (تم إصلاحه)

### مشكلة: flutter pub get فشل
```bash
flutter clean
flutter pub get
```

### مشكلة: Login فشل
1. تأكد من إنشاء User في Auth
2. تأكد من تشغيل SQL لإضافته لجدول users
3. تأكد من كلمة المرور صحيحة

### مشكلة: Dashboard فارغ
هذا طبيعي! الـ 4 dashboards (HR, IT, Management, Admin) placeholders فقط.
Employee Dashboard فيه UI أساسي.

---

## 🎯 بعد ما تخلص من كل الخطوات

**يمكنك البدء في التطوير!**

راجع:
- `QUICK_START.md` - دليل التطوير
- `PROJECT_STATUS.md` - حالة المشروع
- `walkthrough.md` - شرح تفصيلي

**كل شيء جاهز! 🚀**
