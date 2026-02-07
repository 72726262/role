-- ================================================
-- COMPLETE SUPABASE BACKEND SETUP
-- Version: 2.0 (Final - No Errors)
-- ================================================

-- ================================================
-- STEP 0: ENABLE EXTENSIONS
-- ================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- STEP 1: DROP EVERYTHING (Clean Start)
-- ================================================

-- Drop all triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users CASCADE;
DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON public.employee_profiles CASCADE;
DROP TRIGGER IF EXISTS update_news_updated_at ON public.news CASCADE;
DROP TRIGGER IF EXISTS update_events_updated_at ON public.events CASCADE;
DROP TRIGGER IF EXISTS update_hr_policies_updated_at ON public.hr_policies CASCADE;
DROP TRIGGER IF EXISTS update_training_courses_updated_at ON public.training_courses CASCADE;
DROP TRIGGER IF EXISTS update_it_policies_updated_at ON public.it_policies CASCADE;
DROP TRIGGER IF EXISTS update_navigation_links_updated_at ON public.navigation_links CASCADE;

-- Drop all tables (in reverse dependency order)
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

-- Drop all functions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS get_user_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS check_user_permission(uuid, text) CASCADE;

-- ================================================
-- STEP 2: CREATE HELPER FUNCTION
-- ================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- STEP 3: CREATE TABLES (In Dependency Order)
-- ================================================

-- 1. Roles Table
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name TEXT UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Users Table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role_id UUID REFERENCES public.roles(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON public.users(role_id);
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3. Employee Profiles
CREATE TABLE IF NOT EXISTS public.employee_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    job_title TEXT,
    department TEXT,
    phone_number TEXT,
    photo_url TEXT,
    date_of_birth DATE,
    hire_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_employee_profiles_user_id ON public.employee_profiles(user_id);
DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON public.employee_profiles;
CREATE TRIGGER update_employee_profiles_updated_at BEFORE UPDATE ON public.employee_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. News
CREATE TABLE IF NOT EXISTS public.news (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    author_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_news_published ON public.news(is_published, published_at);
DROP TRIGGER IF EXISTS update_news_updated_at ON public.news;
CREATE TRIGGER update_news_updated_at BEFORE UPDATE ON public.news
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. Events
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    event_type TEXT,
    event_date DATE NOT NULL,
    icon_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(event_date);
DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. Moods
CREATE TABLE IF NOT EXISTS public.moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    mood_type TEXT NOT NULL CHECK (mood_type IN ('happy', 'normal', 'tired', 'need_support')),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_moods_user_date ON public.moods(user_id, recorded_at);
CREATE UNIQUE INDEX IF NOT EXISTS one_mood_per_day ON public.moods (user_id, ((recorded_at AT TIME ZONE 'UTC')::date));

-- 7. HR Policies
CREATE TABLE IF NOT EXISTS public.hr_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT,
    pdf_url TEXT,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_hr_policies_updated_at ON public.hr_policies;
CREATE TRIGGER update_hr_policies_updated_at BEFORE UPDATE ON public.hr_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. Training Courses
CREATE TABLE IF NOT EXISTS public.training_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    instructor TEXT,
    duration_hours INTEGER,
    max_participants INTEGER,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_training_courses_updated_at ON public.training_courses;
CREATE TRIGGER update_training_courses_updated_at BEFORE UPDATE ON public.training_courses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 9. IT Policies
CREATE TABLE IF NOT EXISTS public.it_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    policy_type TEXT,
    pdf_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_it_policies_updated_at ON public.it_policies;
CREATE TRIGGER update_it_policies_updated_at BEFORE UPDATE ON public.it_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10. Management Messages
CREATE TABLE IF NOT EXISTS public.management_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('urgent', 'high', 'medium', 'low')),
    published_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Navigation Links
CREATE TABLE IF NOT EXISTS public.navigation_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    icon_name TEXT,
    url TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_navigation_links_order ON public.navigation_links(display_order);
DROP TRIGGER IF EXISTS update_navigation_links_updated_at ON public.navigation_links;
CREATE TRIGGER update_navigation_links_updated_at BEFORE UPDATE ON public.navigation_links
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 12. Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    notification_type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- ================================================
-- STEP 4: ROW LEVEL SECURITY (RLS) POLICIES
-- ================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hr_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.it_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.management_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.navigation_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Helper function to get user role
CREATE OR REPLACE FUNCTION get_user_role(user_uuid uuid)
RETURNS text AS $$
    SELECT r.role_name 
    FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = user_uuid;
$$ LANGUAGE sql SECURITY DEFINER;

-- ============ ROLES TABLE POLICIES ============
DROP POLICY IF EXISTS "Roles are viewable by everyone" ON public.roles;
CREATE POLICY "Roles are viewable by everyone" ON public.roles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Only admins can modify roles" ON public.roles;
CREATE POLICY "Only admins can modify roles" ON public.roles 
FOR ALL USING (get_user_role(auth.uid()) = 'Admin');

-- ============ USERS TABLE POLICIES ============
DROP POLICY IF EXISTS "Users can view all users" ON public.users;
CREATE POLICY "Users can view all users" ON public.users FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users 
FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Only admins can insert/delete users" ON public.users;
CREATE POLICY "Only admins can insert/delete users" ON public.users 
FOR ALL USING (get_user_role(auth.uid()) = 'Admin');

-- ============ EMPLOYEE PROFILES POLICIES ============
DROP POLICY IF EXISTS "Profiles viewable by all authenticated" ON public.employee_profiles;
CREATE POLICY "Profiles viewable by all authenticated" ON public.employee_profiles 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Users can update own profile" ON public.employee_profiles;
CREATE POLICY "Users can update own profile" ON public.employee_profiles 
FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "HR and Admin can manage all profiles" ON public.employee_profiles;
CREATE POLICY "HR and Admin can manage all profiles" ON public.employee_profiles 
FOR ALL USING (get_user_role(auth.uid()) IN ('HR', 'Admin'));

-- ============ NEWS POLICIES ============
DROP POLICY IF EXISTS "News viewable by all authenticated" ON public.news;
CREATE POLICY "News viewable by all authenticated" ON public.news 
FOR SELECT USING (auth.uid() IS NOT NULL AND is_published = true);

DROP POLICY IF EXISTS "Admin and Management can manage news" ON public.news;
CREATE POLICY "Admin and Management can manage news" ON public.news 
FOR ALL USING (get_user_role(auth.uid()) IN ('Admin', 'Management'));

-- ============ EVENTS POLICIES ============
DROP POLICY IF EXISTS "Events viewable by all authenticated" ON public.events;
CREATE POLICY "Events viewable by all authenticated" ON public.events 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Admin can manage events" ON public.events;
CREATE POLICY "Admin can manage events" ON public.events 
FOR ALL USING (get_user_role(auth.uid()) = 'Admin');

-- ============ MOODS POLICIES ============
DROP POLICY IF EXISTS "Users can view own moods" ON public.moods;
CREATE POLICY "Users can view own moods" ON public.moods 
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own moods" ON public.moods;
CREATE POLICY "Users can insert own moods" ON public.moods 
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "HR and Management can view all moods" ON public.moods;
CREATE POLICY "HR and Management can view all moods" ON public.moods 
FOR SELECT USING (get_user_role(auth.uid()) IN ('HR', 'Management', 'Admin'));

-- ============ HR POLICIES TABLE POLICIES ============
DROP POLICY IF EXISTS "Policies viewable by all authenticated" ON public.hr_policies;
CREATE POLICY "Policies viewable by all authenticated" ON public.hr_policies 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "HR can manage policies" ON public.hr_policies;
CREATE POLICY "HR can manage policies" ON public.hr_policies 
FOR ALL USING (get_user_role(auth.uid()) IN ('HR', 'Admin'));

-- ============ TRAINING COURSES POLICIES ============
DROP POLICY IF EXISTS "Courses viewable by all authenticated" ON public.training_courses;
CREATE POLICY "Courses viewable by all authenticated" ON public.training_courses 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "HR can manage courses" ON public.training_courses;
CREATE POLICY "HR can manage courses" ON public.training_courses 
FOR ALL USING (get_user_role(auth.uid()) IN ('HR', 'Admin'));

-- ============ IT POLICIES TABLE POLICIES ============
DROP POLICY IF EXISTS "IT Policies viewable by all authenticated" ON public.it_policies;
CREATE POLICY "IT Policies viewable by all authenticated" ON public.it_policies 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "IT can manage policies" ON public.it_policies;
CREATE POLICY "IT can manage policies" ON public.it_policies 
FOR ALL USING (get_user_role(auth.uid()) IN ('IT', 'Admin'));

-- ============ MANAGEMENT MESSAGES POLICIES ============
DROP POLICY IF EXISTS "Messages viewable by all authenticated" ON public.management_messages;
CREATE POLICY "Messages viewable by all authenticated" ON public.management_messages 
FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Management can manage messages" ON public.management_messages;
CREATE POLICY "Management can manage messages" ON public.management_messages 
FOR ALL USING (get_user_role(auth.uid()) IN ('Management', 'Admin'));

-- ============ NAVIGATION LINKS POLICIES ============
DROP POLICY IF EXISTS "Links viewable by all authenticated" ON public.navigation_links;
CREATE POLICY "Links viewable by all authenticated" ON public.navigation_links 
FOR SELECT USING (auth.uid() IS NOT NULL AND is_active = true);

DROP POLICY IF EXISTS "Admin can manage links" ON public.navigation_links;
CREATE POLICY "Admin can manage links" ON public.navigation_links 
FOR ALL USING (get_user_role(auth.uid()) = 'Admin');

-- ============ NOTIFICATIONS POLICIES ============
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications" ON public.notifications 
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications" ON public.notifications 
FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admin can manage all notifications" ON public.notifications;
CREATE POLICY "Admin can manage all notifications" ON public.notifications 
FOR ALL USING (get_user_role(auth.uid()) = 'Admin');

-- ================================================
-- STEP 5: INSERT DEFAULT ROLES
-- ================================================
INSERT INTO public.roles (role_name, description, permissions) VALUES
    ('Employee', 'Regular employee with basic access', '{"view_news": true, "submit_mood": true}'::jsonb),
    ('HR', 'HR department with policy and training management', '{"manage_policies": true, "manage_training": true, "view_moods": true}'::jsonb),
    ('IT', 'IT department with system and policy management', '{"manage_it_policies": true, "view_all_users": true}'::jsonb),
    ('Management', 'Management with analytics and messaging', '{"publish_messages": true, "view_analytics": true, "manage_content": true}'::jsonb),
    ('Admin', 'Full system access', '{"full_access": true}'::jsonb)
ON CONFLICT (role_name) DO NOTHING;

-- ================================================
-- STEP 6: COMMENTS (Documentation)
-- ================================================
COMMENT ON TABLE public.roles IS 'User roles and permissions';
COMMENT ON TABLE public.users IS 'User accounts linked to auth.users';
COMMENT ON TABLE public.employee_profiles IS 'Extended employee information';
COMMENT ON TABLE public.news IS 'Company news and announcements';
COMMENT ON TABLE public.events IS 'Company events and occasions';
COMMENT ON TABLE public.moods IS 'Daily employee mood tracking (one per day)';
COMMENT ON TABLE public.hr_policies IS 'HR policies and documents';
COMMENT ON TABLE public.training_courses IS 'Training courses catalog';
COMMENT ON TABLE public.it_policies IS 'IT policies and guidelines';
COMMENT ON TABLE public.management_messages IS 'Official messages from management';
COMMENT ON TABLE public.navigation_links IS 'Quick access links for employee dashboard';
COMMENT ON TABLE public.notifications IS 'User notifications history';

-- ================================================
-- SUCCESS MESSAGE
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '✅ Schema created successfully!';
    RAISE NOTICE '✅ 12 tables created with indexes and triggers';
    RAISE NOTICE '✅ RLS policies configured for all roles';
    RAISE NOTICE '✅ 5 default roles inserted';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Next Steps:';
    RAISE NOTICE '1. Create admin user in Authentication > Users';
    RAISE NOTICE '2. Run seed_data.sql to populate sample data';
    RAISE NOTICE '3. Setup storage buckets (see storage_setup.sql)';
END $$;
