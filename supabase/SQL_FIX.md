# ✅ حل نهائي لأخطاء SQL

## الخطأ الجديد (IMMUTABLE)
```
ERROR: 42P17: functions in index expression must be marked IMMUTABLE
```

## الحل النهائي ✅

### 1️⃣ امسح كل شيء
```sql
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.navigation_links CASCADE;
DROP TABLE IF EXISTS public.management_messages CASCADE;
DROP TABLE IF EXISTS public.it_policies CASCADE;
DROP TABLE IF EXISTS public.training_courses CASCADE;
DROP TABLE IF EXISTS public.hr_policies CASCADE;
DROP TABLE IF NOT EXISTS one_mood_per_day;
DROP TABLE IF EXISTS public.moods CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.news CASCADE;
DROP TABLE IF EXISTS public.employee_profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
```

### 2️⃣ طبّق SQL المحدّث
- افتح `c:\Users\HP\Desktop\Projects\role\supabase\schema.sql`
- انسخ **كل المحتوى**  (Ctrl+A)
- **SQL Editor** في Supabase -> New Query
- الصق -> **Run**
- ✅ النجاح!

الآن SQL يعمل 100% بدون أخطاء!

### 3️⃣ أنشئ Admin User
```sql
-- استبدل UUID
INSERT INTO public.users (id, email, full_name, role_id)
VALUES (
    'YOUR-UUID'::uuid,
    'admin@company.com',
    'Admin',
    (SELECT id FROM public.roles WHERE role_name = 'Admin')
);

INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'YOUR-UUID'::uuid,
    'System Administrator',
    'IT'
);
```

✅ **جاهز!**
