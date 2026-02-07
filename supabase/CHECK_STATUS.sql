-- ================================================
-- SIMPLE CHECK - Shows actual results
-- Copy and run in Supabase SQL Editor
-- ================================================

-- 1. Check Tables (should show 12 rows)
SELECT '=== TABLES ===' as section, COUNT(*) as total FROM information_schema.tables WHERE table_schema = 'public'
UNION ALL
SELECT 'Expected', 12;

-- 2. Check Roles (should show 5 rows)
SELECT '=== ROLES ===' as section, COUNT(*) as total FROM public.roles
UNION ALL
SELECT 'Expected', 5;

-- 3. Check Storage Buckets (should show 3 rows)
SELECT '=== BUCKETS ===' as section, COUNT(*) as total FROM storage.buckets
UNION ALL  
SELECT 'Expected', 3;

-- 4. List actual buckets (see what you have)
SELECT '=== YOUR BUCKETS ===' as info;
SELECT name, public, created_at FROM storage.buckets;

-- 5. Check Storage Policies
SELECT '=== STORAGE POLICIES ===' as section, COUNT(*) as total FROM pg_policies WHERE schemaname = 'storage'
UNION ALL
SELECT 'Expected', 15;

-- 6. Check Users
SELECT '=== USERS ===' as section, COUNT(*) as total FROM public.users
UNION ALL
SELECT 'Expected (optional)', 1;

-- ================================================
-- FINAL STATUS
-- ================================================
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM storage.buckets) >= 3 THEN '✅ BUCKETS OK'
        ELSE '❌ CREATE BUCKETS FIRST!'
    END as status;
