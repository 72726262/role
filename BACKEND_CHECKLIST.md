# 📋 BACKEND CHECKLIST - Complete Setup

## ✅ Step-by-Step Backend Setup

### 1️⃣ Database Schema ✅ DONE
- [x] Run `supabase/SIMPLE_SETUP.sql`
- [x] 12 tables created
- [x] 8 triggers for auto-update
- [x] RLS policies enabled
- [x] 5 default roles inserted

**Verify:**
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
-- Should show 12 tables
```

---

### 2️⃣ Storage Buckets ⚠️ ACTION NEEDED

#### Create Buckets (Manual in Dashboard)

1. **Supabase Dashboard** → **Storage** → **Create Bucket**

2. Create 3 buckets:

| Bucket Name | Public Access | File Types |
|-------------|---------------|------------|
| `documents` | ❌ Private | PDF, DOC, XLS |
| `images` | ✅ Public | JPG, PNG, WebP |
| `videos` | ✅ Public | MP4, WebM |

#### Apply Storage RLS Policies

3. **SQL Editor** → Run `supabase/STORAGE_COMPLETE.sql`

**Verify:**
```sql
SELECT * FROM storage.buckets;
-- Should show: documents, images, videos
```

---

### 3️⃣ Test Users ⚠️ ACTION NEEDED

#### Create in Authentication

**Authentication** → **Users** → **Add User**

Create 5 test users:

| Email | Password | Role | Auto Confirm |
|-------|----------|------|--------------|
| `admin@test.com` | `Admin@123` | Admin | ✅ |
| `hr@test.com` | `Hr@123456` | HR | ✅ |
| `it@test.com` | `It@123456` | IT | ✅ |
| `manager@test.com` | `Manager@123` | Management | ✅ |
| `employee@test.com` | `Emp@123456` | Employee | ✅ |

#### Link Users to Database

For each user, copy UUID and run:

```sql
-- Replace UUID with actual user ID
INSERT INTO public.users (id, email, full_name, role_id, is_active)
VALUES (
    'USER-UUID-HERE'::uuid,
    'admin@test.com',
    'System Admin',
    (SELECT id FROM public.roles WHERE role_name = 'Admin'),
    true
);

-- Create profile
INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'USER-UUID-HERE'::uuid,
    'System Administrator',
    'IT'
);
```

**Repeat for all 5 users!**

---

### 4️⃣ Sample Data (Optional) ✅ READY

Run these to populate data for testing:

```sql
-- Add news
INSERT INTO public.news (title, content, is_published, published_at)
VALUES 
    ('مرحباً في النظام', 'نرحب بكم في بوابة الموظفين الجديدة', true, NOW()),
    ('إعلان هام', 'اجتماع عام يوم الأحد القادم', true, NOW());

-- Add events
INSERT INTO public.events (title, description, event_type, event_date, icon_name)
VALUES 
    ('اجتماع الفريق', 'اجتماع شهري', 'meeting', CURRENT_DATE + 7, 'groups'),
    ('عيد ميلاد أحمد', 'احتفال بعيد الميلاد', 'birthday', CURRENT_DATE + 3, 'cake');

-- Add navigation links
INSERT INTO public.navigation_links (title, icon_name, url, display_order, is_active)
VALUES 
    ('دليل الموظف', 'menu_book', 'https://handbook.company.com', 1, true),
    ('نظام الرواتب', 'payments', 'https://payroll.company.com', 2, true),
    ('الدعم الفني', 'support_agent', 'https://support.company.com', 3, true);

-- Add HR policy
INSERT INTO public.hr_policies (title, description, category)
VALUES ('سياسة الإجازات', 'قوانين الإجازات السنوية والمرضية', 'Leaves');

-- Add IT policy
INSERT INTO public.it_policies (title, description, policy_type)
VALUES ('سياسة الأمن السيبراني', 'قواعد حماية البيانات', 'security');

-- Add training course
INSERT INTO public.training_courses (title, description, instructor, duration_hours, max_participants, start_date, end_date)
VALUES ('دورة Excel المتقدم', 'تعلم Excel بشكل احترافي', 'أحمد محمد', 16, 20, CURRENT_DATE + 14, CURRENT_DATE + 21);
```

---

### 5️⃣ Security Configuration ⚠️ CRITICAL

#### Hide API Keys

1. **NEVER commit** API keys to Git!

2. Update `lib/core/config/supabase_config.dart`:
   - Replace `YOUR_SUPABASE_URL_HERE`
   - Replace `YOUR_SUPABASE_ANON_KEY_HERE`

3. Create `.env` file (see `SECURITY_SETUP.md`)

4. Add `.env` to `.gitignore` ✅ (Already done)

---

### 6️⃣ Verification Tests

Run these checks:

#### Database Check
```sql
-- All tables exist?
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
-- Expected: 12

-- Roles inserted?
SELECT * FROM public.roles;
-- Expected: 5 rows

-- Users linked?
SELECT u.email, r.role_name FROM public.users u JOIN public.roles r ON u.role_id = r.id;
-- Should show your test users
```

#### Storage Check
```sql
-- Buckets exist?
SELECT * FROM storage.buckets;
-- Expected: documents, images, videos

-- Policies exist?
SELECT * FROM storage.policies;
-- Should show multiple policies
```

#### Auth Check
1. Go to **Authentication** → **Users**
2. You should see 5 users
3. All should have **Confirmed** status ✅

---

## 🎯 Final Checklist

Before running Flutter app:

- [ ] `SIMPLE_SETUP.sql` executed successfully
- [ ] All 12 tables created
- [ ] 5 roles inserted
- [ ] 3 storage buckets created (documents, images, videos)
- [ ] `STORAGE_COMPLETE.sql` executed
- [ ] 5 test users created in Authentication
- [ ] All users linked to `public.users` table
- [ ] Sample data inserted (optional)
- [ ] API keys updated in `supabase_config.dart`
- [ ] `.env` file created (optional)
- [ ] `.gitignore` includes `.env` ✅

---

## 🚀 Ready to Test!

```bash
flutter pub get
flutter run
```

**Login with:** `admin@test.com` / `Admin@123`

**Expected:**
- ✅ Login successful
- ✅ Admin Dashboard shows 6 cards
- ✅ Can navigate to all screens
- ✅ No errors in console

---

## ❌ Troubleshooting

### "relation does not exist"
**Fix:** Run `SIMPLE_SETUP.sql` again

### "bucket not found"
**Fix:** Create buckets manually in Dashboard

### "Invalid login credentials"
**Fix:** 
- Check user email/password
- Ensure user is **Confirmed** in Auth
- Check user exists in `public.users` table

### "Row Level Security policy violation"
**Fix:** 
- Verify user has correct role
- Check RLS policies exist

---

## 📁 SQL Files Summary

| File | Purpose | When to Run |
|------|---------|-------------|
| `SIMPLE_SETUP.sql` | Database schema + RLS | **First** |
| `STORAGE_COMPLETE.sql` | Storage buckets RLS | After creating buckets |
| Sample data snippets | Test data | Optional, after users |

---

## ✅ Backend is 100% Complete!

Once checklist done, you have:
- ✅ 12 database tables
- ✅ Row Level Security
- ✅ 3 storage buckets with policies
- ✅ 5 test users
- ✅ Sample data

**Ready for production deployment!** 🎉
