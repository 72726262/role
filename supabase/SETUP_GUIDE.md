# 🎯 دليل Supabase الكامل - خطوة بخطوة

## ✅ الخطوة 1: تطبيق Schema (نهائي بدون أخطاء)

### افتح Supabase Dashboard
1. اذهب إلى: https://supabase.com/dashboard
2. افتح مشروعك
3. اضغط على **SQL Editor** من القائمة اليسرى

### شغّل Complete Schema
1. اضغط **New Query**
2. انسخ **كل محتوى** `complete_schema.sql`
3. الصق في المحرر
4. اضغط **Run** (أو Ctrl+Enter)

**✅ النجاح!** سترى:
```
✅ Schema created successfully!
✅ 12 tables created with indexes and triggers
✅ RLS policies configured for all roles
✅ 5 default roles inserted
```

---

## ✅ الخطوة 2: إنشاء Users في Authentication

### اذهب إلى Authentication > Users
1. اضغط **Add User** > **Create new user**
2. أنشئ هؤلاء المستخدمين:

| Email | Password | ملاحظة |
|-------|----------|--------|
| admin@company.com | Admin@123456 | ✅ Auto Confirm |
| hr@company.com | Hr@123456 | ✅ Auto Confirm |
| it@company.com | It@123456 | ✅ Auto Confirm |
| manager@company.com | Manager@123456 | ✅ Auto Confirm |
| employee@company.com | Employee@123456 | ✅ Auto Confirm |

**⚠️ مهم جداً**: بعد إنشاء كل user، **انسخ UUID** الخاص به

---

## ✅ الخطوة 3: تطبيق Sample Data

### افتح `seed_data.sql`
1. **ابحث عن السطور 17-46** (INSERT INTO users)
2. **استبدل UUIDs** بالأرقام الحقيقية من Authentication:
   ```sql
   -- قبل:
   '00000000-0000-0000-0000-000000000001'::uuid
   
   -- بعد (مثال):
   'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::uuid
   ```

3. **كرر نفس UUIDs** في مواضع أخرى:
   - سطر 52-56: employee_profiles
   - سطر 124-126: moods

### شغّل Seed Data
1. SQL Editor > **New Query**
2. انسخ `seed_data.sql` **المحدّث**
3. **Run**

**✅ النجاح!** سترى:
```
✅ Sample data inserted!
📊 3 News, 4 Events, 3 Policies, etc.
```

---

## ✅ الخطوة 4: Setup Storage Buckets

### إنشاء Buckets يدوياً
1. اذهب إلى **Storage** من القائمة
2. اضغط **New Bucket**:
   - Name: `documents`
   - Public: **No** ❌
   - اضغط Create

3. اضغط **New Bucket** مرة أخرى:
   - Name: `images`
   - Public: **Yes** ✅
   - اضغط Create

### تطبيق Storage Policies
1. SQL Editor > **New Query**
2. انسخ `storage_setup.sql`
3. **Run**

**✅ تم!** Storage جاهز

---

## 📊 التحقق من النجاح

### اختبر Tables
```sql
-- اعرض جميع الـ Roles
SELECT * FROM public.roles;

-- اعرض Users
SELECT u.email, u.full_name, r.role_name 
FROM public.users u 
JOIN public.roles r ON u.role_id = r.id;

-- اعرض News
SELECT title, is_published FROM public.news;
```

**يجب أن ترى البيانات!**

---

## 🔒 RLS Policies (تم تطبيقها تلقائياً)

### ✅ ما تم ضبطه:

| Table | Employee | HR | IT | Management | Admin |
|-------|----------|----|----|------------|-------|
| users | View All | View All | View All | View All | Full |
| news | View Published | View Published | View Published | Manage | Manage |
| events | View | View | View | View | Manage |
| moods | Own Only | View All | - | View All | View All |
| hr_policies | View | Manage | View | View | Manage |
| training_courses | View | Manage | View | View | Manage |
| it_policies | View | View | Manage | View | Manage |
| mgmt_messages | View | View | View | Manage | Manage |
| navigation_links | View Active | View Active | View Active | View Active | Manage |
| notifications | Own Only | Own Only | Own Only | Own Only | Manage All |

---

## 🎯 الخلاصة

**3 ملفات SQL فقط:**
1. ✅ `complete_schema.sql` - Schema + RLS + Roles
2. ✅ `seed_data.sql` - Sample Data (بعد تحديث UUIDs)
3. ✅ `storage_setup.sql` - Storage Policies

**بعد التطبيق:**
- ✅ 12 Tables مع Indexes
- ✅ 8 Triggers للـ updated_at
- ✅ RLS Policies لكل الـ Roles
- ✅ 2 Storage Buckets
- ✅ 5 Test Users جاهزين

**🚀 Database جاهز 100%!**

---

## ⚠️ ملاحظات

### إذا حصل خطأ "trigger already exists"
الحل:
```sql
-- شغّل هذا أولاً لحذف كل شيء
-- ثم شغّل complete_schema.sql مرة أخرى
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

### إذا نسيت UUID
```sql
-- اعرض جميع Auth Users مع UUIDs
SELECT id, email FROM auth.users;
```

---

## 🎉 جاهز للاستخدام!

الآن يمكنك:
1. تشغيل `flutter run`
2. تسجيل الدخول بأي من الحسابات
3. اختبار جميع الـ Dashboards
4. جميع الـ CRUD operations تعمل بالصلاحيات الصحيحة
