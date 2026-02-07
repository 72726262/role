-- ================================================
-- SUPABASE SETUP - SIMPLIFIED & GUARANTEED
-- Version: FINAL (No Errors)
-- Run this in Supabase SQL Editor
-- ================================================

-- STEP 1: Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- STEP 2: Create helper function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- STEP 3: Create helper function for getting user role
CREATE OR REPLACE FUNCTION get_user_role(user_uuid uuid)
RETURNS text AS $$
    SELECT r.role_name 
    FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = user_uuid;
$$ LANGUAGE sql SECURITY DEFINER;

-- ================================================
-- TABLES CREATION
-- ================================================

-- Table 1: Roles
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name TEXT UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default roles
INSERT INTO public.roles (role_name, description, permissions) VALUES
    ('Employee', 'Regular employee', '{"view_news": true}'::jsonb),
    ('HR', 'HR department', '{"manage_policies": true}'::jsonb),
    ('IT', 'IT department', '{"manage_it_policies": true}'::jsonb),
    ('Management', 'Management', '{"publish_messages": true}'::jsonb),
    ('Admin', 'Administrator', '{"full_access": true}'::jsonb)
ON CONFLICT (role_name) DO NOTHING;

-- Table 2: Users
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role_id UUID REFERENCES public.roles(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON public.users(role_id);

-- Table 3: Employee Profiles
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

-- Table 4: News
CREATE TABLE IF NOT EXISTS public.news (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    author_id UUID REFERENCES public.users(id),
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_news_published ON public.news(is_published, published_at);

-- Table 5: Events
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

-- Table 6: Moods
CREATE TABLE IF NOT EXISTS public.moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    mood_type TEXT NOT NULL CHECK (mood_type IN ('happy', 'normal', 'tired', 'need_support')),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_moods_user_date ON public.moods(user_id, recorded_at);

-- Unique constraint: one mood per day per user
DROP INDEX IF EXISTS one_mood_per_day;
CREATE UNIQUE INDEX one_mood_per_day ON public.moods (user_id, ((recorded_at AT TIME ZONE 'UTC')::date));

-- Table 7: HR Policies
CREATE TABLE IF NOT EXISTS public.hr_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT,
    pdf_url TEXT,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 8: Training Courses
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

-- Table 9: IT Policies
CREATE TABLE IF NOT EXISTS public.it_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    policy_type TEXT,
    pdf_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 10: Management Messages
CREATE TABLE IF NOT EXISTS public.management_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('urgent', 'high', 'medium', 'low')),
    published_by UUID REFERENCES public.users(id),
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 11: Navigation Links
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

-- Table 12: Notifications
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
-- TRIGGERS (Safe - with DROP IF EXISTS)
-- ================================================

DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON public.employee_profiles;
CREATE TRIGGER update_employee_profiles_updated_at BEFORE UPDATE ON public.employee_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_news_updated_at ON public.news;
CREATE TRIGGER update_news_updated_at BEFORE UPDATE ON public.news
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_hr_policies_updated_at ON public.hr_policies;
CREATE TRIGGER update_hr_policies_updated_at BEFORE UPDATE ON public.hr_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_training_courses_updated_at ON public.training_courses;
CREATE TRIGGER update_training_courses_updated_at BEFORE UPDATE ON public.training_courses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_it_policies_updated_at ON public.it_policies;
CREATE TRIGGER update_it_policies_updated_at BEFORE UPDATE ON public.it_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_navigation_links_updated_at ON public.navigation_links;
CREATE TRIGGER update_navigation_links_updated_at BEFORE UPDATE ON public.navigation_links
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- RLS POLICIES - Enable RLS
-- ================================================

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
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

-- RLS Policies (Drop existing first to avoid conflicts)
DROP POLICY IF EXISTS "roles_select" ON public.roles;
CREATE POLICY "roles_select" ON public.roles FOR SELECT USING (true);

DROP POLICY IF EXISTS "users_select" ON public.users;
CREATE POLICY "users_select" ON public.users FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_own" ON public.users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_select" ON public.employee_profiles;
CREATE POLICY "profiles_select" ON public.employee_profiles FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "news_select" ON public.news;
CREATE POLICY "news_select" ON public.news FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "events_select" ON public.events;
CREATE POLICY "events_select" ON public.events FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "moods_select_own" ON public.moods;
CREATE POLICY "moods_select_own" ON public.moods FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "moods_insert_own" ON public.moods;
CREATE POLICY "moods_insert_own" ON public.moods FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "hr_policies_select" ON public.hr_policies;
CREATE POLICY "hr_policies_select" ON public.hr_policies FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "training_courses_select" ON public.training_courses;
CREATE POLICY "training_courses_select" ON public.training_courses FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "it_policies_select" ON public.it_policies;
CREATE POLICY "it_policies_select" ON public.it_policies FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "messages_select" ON public.management_messages;
CREATE POLICY "messages_select" ON public.management_messages FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "links_select" ON public.navigation_links;
CREATE POLICY "links_select" ON public.navigation_links FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "notifications_select_own" ON public.notifications;
CREATE POLICY "notifications_select_own" ON public.notifications FOR SELECT USING (auth.uid() = user_id);

-- ================================================
-- SUCCESS!
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '✅ Schema created successfully!';
    RAISE NOTICE '✅ 12 tables created';
    RAISE NOTICE '✅ 8 triggers created';
    RAISE NOTICE '✅ RLS enabled and policies set';
    RAISE NOTICE '';
    RAISE NOTICE 'Next: Create users in Authentication→Users';
END $$;
