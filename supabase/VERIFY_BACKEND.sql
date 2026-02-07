-- ================================================
-- VERIFICATION SCRIPT
-- Run this to check if everything is setup correctly
-- ================================================

-- Check 1: Database Tables (should be 12)
SELECT 
    '✅ Database Tables' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) = 12 THEN '✅ PASS'
        ELSE '❌ FAIL - Expected 12 tables'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check 2: Roles (should be 5)
SELECT 
    '✅ Roles' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) = 5 THEN '✅ PASS'
        ELSE '❌ FAIL - Expected 5 roles'
    END as status
FROM public.roles;

-- Check 3: Storage Buckets (should be 3)
SELECT 
    '✅ Storage Buckets' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) >= 3 THEN '✅ PASS'
        ELSE '❌ FAIL - Expected 3 buckets (documents, images, videos)'
    END as status
FROM storage.buckets;

-- Check 4: Storage Policies (should be multiple)
SELECT 
    '✅ Storage Policies' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ PASS'
        ELSE '❌ FAIL - No storage policies found'
    END as status
FROM pg_policies 
WHERE schemaname = 'storage';

-- Check 5: Test Users (optional)
SELECT 
    '✅ Test Users' as check_name,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ PASS'
        ELSE '⚠️ WARNING - No users linked to database yet'
    END as status
FROM public.users;

-- ================================================
-- Detailed Results
-- ================================================

-- Show all tables
SELECT '=== TABLES ===' as info;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

-- Show all roles
SELECT '=== ROLES ===' as info;
SELECT role_name FROM public.roles ORDER BY role_name;

-- Show all buckets
SELECT '=== STORAGE BUCKETS ===' as info;
SELECT id, name, public FROM storage.buckets ORDER BY name;

-- Show storage policies count per bucket
SELECT '=== STORAGE POLICIES ===' as info;
SELECT 
    split_part(tablename, '.', 1) as bucket,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'storage'
GROUP BY split_part(tablename, '.', 1);

-- Show users (if any)
SELECT '=== USERS ===' as info;
SELECT email, r.role_name, is_active 
FROM public.users u 
LEFT JOIN public.roles r ON u.role_id = r.id
ORDER BY email;

-- ================================================
-- FINAL SUMMARY
-- ================================================
DO $$
DECLARE
    table_count INT;
    role_count INT;
    bucket_count INT;
    policy_count INT;
    user_count INT;
BEGIN
    SELECT COUNT(*) INTO table_count FROM information_schema.tables WHERE table_schema = 'public';
    SELECT COUNT(*) INTO role_count FROM public.roles;
    SELECT COUNT(*) INTO bucket_count FROM storage.buckets;
    SELECT COUNT(*) INTO policy_count FROM pg_policies WHERE schemaname = 'storage';
    SELECT COUNT(*) INTO user_count FROM public.users;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '       BACKEND VERIFICATION SUMMARY     ';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Database Tables:    % (Expected: 12)', table_count;
    RAISE NOTICE 'Roles:              % (Expected: 5)', role_count;
    RAISE NOTICE 'Storage Buckets:    % (Expected: 3)', bucket_count;
    RAISE NOTICE 'Storage Policies:   % (Expected: 15+)', policy_count;
    RAISE NOTICE 'Users Linked:       %', user_count;
    RAISE NOTICE '';
    
    IF table_count = 12 AND role_count = 5 AND bucket_count >= 3 AND policy_count > 0 THEN
        RAISE NOTICE '✅ BACKEND SETUP COMPLETE!';
        RAISE NOTICE '✅ Ready to use with Flutter app';
    ELSE
        RAISE NOTICE '⚠️ SETUP INCOMPLETE:';
        IF table_count != 12 THEN
            RAISE NOTICE '  ❌ Run SIMPLE_SETUP.sql to create tables';
        END IF;
        IF bucket_count < 3 THEN
            RAISE NOTICE '  ❌ Create buckets: documents, images, videos';
        END IF;
        IF policy_count = 0 THEN
            RAISE NOTICE '  ❌ Run STORAGE_SAFE.sql to add policies';
        END IF;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;
