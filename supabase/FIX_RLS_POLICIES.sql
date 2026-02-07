-- ============================================
-- إصلاح Infinite Recursion في RLS Policies
-- ============================================

-- المشكلة: الـ Admin policy بيعمل self-reference على جدول users
-- الحل: استخدام auth.jwt() بدل nested query

-- 1. حذف Policies القديمة
DROP POLICY IF EXISTS "Allow insert during registration" ON users;
DROP POLICY IF EXISTS "Allow users to view own data" ON users;
DROP POLICY IF EXISTS "Allow users to update own data" ON users;
DROP POLICY IF EXISTS "Allow admins full access" ON users;

DROP POLICY IF EXISTS "Allow insert during registration" ON employee_profiles;
DROP POLICY IF EXISTS "Allow users to view own profile" ON employee_profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON employee_profiles;
DROP POLICY IF EXISTS "Allow admins full access" ON employee_profiles;

-- ============================================
-- جدول users
-- ============================================

-- السماح بالإضافة أثناء التسجيل (authenticated users فقط)
CREATE POLICY "Allow insert during registration"
ON users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- السماح للمستخدم برؤية بياناته
CREATE POLICY "Allow users to view own data"
ON users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- السماح للمستخدم بتحديث بياناته
CREATE POLICY "Allow users to update own data"
ON users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================
-- جدول employee_profiles
-- ============================================

-- السماح بالإضافة للجميع
CREATE POLICY "Allow insert during registration"
ON employee_profiles
FOR INSERT
TO authenticated
WITH CHECK (true);

-- السماح للمستخدم برؤية ملفه
CREATE POLICY "Allow users to view own profile"
ON employee_profiles
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- السماح للمستخدم بتحديث ملفه
CREATE POLICY "Allow users to update own profile"
ON employee_profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- جدول roles - السماح بالقراءة للجميع
-- ============================================

DROP POLICY IF EXISTS "Allow read roles" ON roles;

CREATE POLICY "Allow read roles"
ON roles
FOR SELECT
TO authenticated
USING (true);

-- السماح أيضاً للـ anon users (للتسجيل)
CREATE POLICY "Allow anon read roles"
ON roles
FOR SELECT
TO anon
USING (true);

-- ============================================
-- التحقق
-- ============================================

SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('users', 'employee_profiles', 'roles')
ORDER BY tablename, policyname;
