# 🔧 حل نهائي لخطأ SQL

## المشكلة
```
ERROR: 42710: trigger "update_users_updated_at" for relation "users" already exists
```

**السبب**: Triggers موجودة بالفعل من محاولات سابقة

---

## ✅ الحل (خطوتين فقط)

### الخطوة 1: Cleanup (امسح كل شيء)

**افتح Supabase Dashboard → SQL Editor → New Query**

انسخ والصق **كل محتوى** ملف `cleanup.sql` ثم **Run**

```sql
-- سيحذف:
-- ✅ 8 Triggers
-- ✅ 12 Tables
-- ✅ 1 Function
-- ✅ All Indexes
```

**انتظر**: "Cleanup complete!" message

---

### الخطوة 2: Apply Schema (طبّق من جديد)

**نفس SQL Editor → New Query**

انسخ والصق **كل محتوى** ملف `schema.sql` ثم **Run**

**✅ النجاح!** - لن يكون هناك أي أخطاء

---

## 🎯 بعد النجاح

### أنشئ Admin User
```sql
-- 1. أنشئ user في Auth أولاً (Dashboard → Authentication → Add User)
-- Email: admin@company.com
-- Password: Admin@123456
-- ✅ Auto Confirm User
-- انسخ UUID

-- 2. أضفه لجدول users
INSERT INTO public.users (id, email, full_name, role_id)
VALUES (
    'YOUR-ACTUAL-UUID-HERE'::uuid,
    'admin@company.com',
    'System Administrator',
    (SELECT id FROM public.roles WHERE role_name = 'Admin')
);

-- 3. أنشئ profile
INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'YOUR-ACTUAL-UUID-HERE'::uuid,
    'System Administrator',
    'IT'
);
```

---

## ✅ تم!

Database جاهز 100%
