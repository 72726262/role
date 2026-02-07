-- ============================================
-- COMPLETE CLEANUP SCRIPT
-- Run this FIRST before applying schema.sql
-- ============================================

-- Step 1: Drop all triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON public.employee_profiles;
DROP TRIGGER IF EXISTS update_news_updated_at ON public.news;
DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
DROP TRIGGER IF EXISTS update_hr_policies_updated_at ON public.hr_policies;
DROP TRIGGER IF EXISTS update_training_courses_updated_at ON public.training_courses;
DROP TRIGGER IF EXISTS update_it_policies_updated_at ON public.it_policies;
DROP TRIGGER IF EXISTS update_navigation_links_updated_at ON public.navigation_links;

-- Step 2: Drop all tables (CASCADE to remove dependencies)
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.navigation_links CASCADE;
DROP TABLE IF EXISTS public.management_messages CASCADE;
DROP TABLE IF EXISTS public.it_policies CASCADE;
DROP TABLE IF EXISTS public.training_courses CASCADE;
DROP TABLE IF EXISTS public.hr_policies CASCADE;
DROP TABLE IF EXISTS public.moods CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.news CASCADE;
DROP TABLE IF EXISTS public.employee_profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.roles CASCADE;

-- Step 3: Drop all functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Step 4: Drop all indexes (if not dropped with tables)
DROP INDEX IF EXISTS public.one_mood_per_day;
DROP INDEX IF EXISTS public.idx_users_role;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_employee_profiles_user;
DROP INDEX IF EXISTS public.idx_news_published;
DROP INDEX IF EXISTS public.idx_events_date;
DROP INDEX IF EXISTS public.idx_navigation_links_order;
DROP INDEX IF EXISTS public.idx_notifications_user;
DROP INDEX IF EXISTS public.idx_users_role_id;
DROP INDEX IF EXISTS public.idx_employee_profiles_user_id;
DROP INDEX IF EXISTS public.idx_moods_user_date;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Cleanup complete! Now run schema.sql';
END $$;
