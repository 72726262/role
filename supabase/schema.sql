-- ================================================
-- EMPLOYEE PORTAL DATABASE SCHEMA - FIXED VERSION
-- ================================================
-- Version: 1.1 (Fixed dependency issues)
-- ================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- STEP 1: CREATE ROLES TABLE (No dependencies)
-- ================================================
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name TEXT UNIQUE NOT NULL CHECK (role_name IN ('Employee', 'HR', 'IT', 'Management', 'Admin')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default roles
INSERT INTO public.roles (role_name, description) VALUES
    ('Employee', 'Regular employee with basic access'),
    ('HR', 'Human Resources team member'),
    ('IT', 'IT department member'),
    ('Management', 'Management team member'),
    ('Admin', 'System administrator with full access')
ON CONFLICT (role_name) DO NOTHING;

-- ================================================
-- STEP 2: CREATE USERS TABLE (Depends on roles only)
-- ================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role_id UUID REFERENCES public.roles(id) ON DELETE SET NULL NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ================================================
-- STEP 3: CREATE HELPER FUNCTIONS
-- ================================================
-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- STEP 4: CREATE REMAINING TABLES
-- ================================================

-- Employee Profiles
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

CREATE INDEX IF NOT EXISTS idx_employee_profiles_user ON public.employee_profiles(user_id);
DROP TRIGGER IF EXISTS update_employee_profiles_updated_at ON public.employee_profiles;
CREATE TRIGGER update_employee_profiles_updated_at BEFORE UPDATE ON public.employee_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- News
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

-- Events
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('birthday', 'meeting', 'celebration', 'training', 'other')),
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(event_date);
DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Moods
CREATE TABLE IF NOT EXISTS public.moods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    mood_type TEXT NOT NULL CHECK (mood_type IN ('happy', 'normal', 'tired', 'need_support')),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT
);

-- Create unique index for one mood per day (using cast instead of DATE() function)
CREATE UNIQUE INDEX IF NOT EXISTS one_mood_per_day ON public.moods (user_id, ((recorded_at AT TIME ZONE 'UTC')::date));

-- HR Policies
CREATE TABLE IF NOT EXISTS public.hr_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    pdf_url TEXT,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_hr_policies_updated_at ON public.hr_policies;
CREATE TRIGGER update_hr_policies_updated_at BEFORE UPDATE ON public.hr_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Training Courses
CREATE TABLE IF NOT EXISTS public.training_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    duration_hours INTEGER,
    instructor TEXT,
    start_date DATE,
    end_date DATE,
    max_participants INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_training_courses_updated_at ON public.training_courses;
CREATE TRIGGER update_training_courses_updated_at BEFORE UPDATE ON public.training_courses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- IT Policies
CREATE TABLE IF NOT EXISTS public.it_policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    policy_type TEXT CHECK (policy_type IN ('security', 'usage', 'compliance', 'other')),
    pdf_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_it_policies_updated_at ON public.it_policies;
CREATE TRIGGER update_it_policies_updated_at BEFORE UPDATE ON public.it_policies
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Management Messages
CREATE TABLE IF NOT EXISTS public.management_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    is_visible BOOLEAN DEFAULT true,
    published_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Navigation Links
CREATE TABLE IF NOT EXISTS public.navigation_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    title_ar TEXT,
    url TEXT NOT NULL,
    icon_name TEXT,
    display_order INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_navigation_links_order ON public.navigation_links(display_order);
DROP TRIGGER IF EXISTS update_navigation_links_updated_at ON public.navigation_links;
CREATE TRIGGER update_navigation_links_updated_at BEFORE UPDATE ON public.navigation_links
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    notification_type TEXT NOT NULL CHECK (notification_type IN ('email', 'push', 'in_app', 'whatsapp')),
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- ================================================
-- STEP 5: ENABLE RLS ON ALL TABLES
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

-- ================================================
-- STEP 6: CREATE RLS POLICIES
-- ================================================

-- ROLES POLICIES
CREATE POLICY "Anyone can view roles" ON public.roles FOR SELECT USING (true);
-- Admin policy for roles table (original policy was for ALL, but only SELECT is needed for non-admins)
CREATE POLICY "Only admins can modify roles" ON public.roles FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);

-- USERS POLICIES
CREATE POLICY "Users can view their own data" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "HR and Admin can view all users" ON public.users FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);
CREATE POLICY "Only admins can insert users" ON public.users FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);
CREATE POLICY "Only admins can update users" ON public.users FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);
CREATE POLICY "Only admins can delete users" ON public.users FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);

-- EMPLOYEE PROFILES POLICIES
CREATE POLICY "Users can view their own profile" ON public.employee_profiles FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update their own profile" ON public.employee_profiles FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "HR and Admin can view all profiles" ON public.employee_profiles FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);
CREATE POLICY "HR and Admin can manage all profiles" ON public.employee_profiles FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);

-- NEWS POLICIES
CREATE POLICY "Anyone can view published news" ON public.news FOR SELECT USING (is_published = true);
CREATE POLICY "Admin and Management can manage news" ON public.news FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('Management', 'Admin')
    )
);

-- EVENTS POLICIES
CREATE POLICY "Anyone can view active events" ON public.events FOR SELECT USING (is_active = true);
CREATE POLICY "HR and Admin can manage events" ON public.events FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);

-- MOODS POLICIES
CREATE POLICY "Users can view their own moods" ON public.moods FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert their own mood" ON public.moods FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "HR and Admin can view all moods" ON public.moods FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Management', 'Admin')
    )
);

-- HR POLICIES
CREATE POLICY "Anyone can view active HR policies" ON public.hr_policies FOR SELECT USING (is_active = true);
CREATE POLICY "HR can manage policies" ON public.hr_policies FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);

-- TRAINING COURSES POLICIES
CREATE POLICY "Anyone can view active courses" ON public.training_courses FOR SELECT USING (is_active = true);
CREATE POLICY "HR can manage courses" ON public.training_courses FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('HR', 'Admin')
    )
);

-- IT POLICIES
CREATE POLICY "Anyone can view active IT policies" ON public.it_policies FOR SELECT USING (is_active = true);
CREATE POLICY "IT can manage policies" ON public.it_policies FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('IT', 'Admin')
    )
);

-- MANAGEMENT MESSAGES POLICIES
CREATE POLICY "Anyone can view visible messages" ON public.management_messages FOR SELECT USING (
    is_visible = true AND (expires_at IS NULL OR expires_at > NOW())
);
CREATE POLICY "Management can manage messages" ON public.management_messages FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name IN ('Management', 'Admin')
    )
);

-- NAVIGATION LINKS POLICIES
CREATE POLICY "Anyone can view active links" ON public.navigation_links FOR SELECT USING (is_active = true);
CREATE POLICY "Admin can manage links" ON public.navigation_links FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);

-- NOTIFICATIONS POLICIES
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (
    auth.uid() = user_id
);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (
    auth.uid() = user_id
);
CREATE POLICY "Admin can send notifications" ON public.notifications FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users u
        INNER JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid() AND r.role_name = 'Admin'
    )
);

-- ================================================
-- SCHEMA COMPLETE - READY TO USE!
-- ================================================

-- Create storage buckets (run these in Supabase Dashboard -> Storage)
-- 1. documents bucket (for PDFs, strategic files)
-- 2. images bucket (for news, profile photos)

-- Storage policies will be created in Supabase Dashboard:
-- documents bucket:
--   - SELECT: Authenticated users can read
--   - INSERT: HR, IT, Admin can upload
--   - UPDATE: HR, IT, Admin can update
--   - DELETE: Admin only

-- images bucket:
--   - SELECT: Authenticated users can read
--   - INSERT: All authenticated users can upload
--   - UPDATE: Owner and Admin can update
--   - DELETE: Owner and Admin can delete

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_role_id ON public.users(role_id);
CREATE INDEX IF NOT EXISTS idx_employee_profiles_user_id ON public.employee_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_news_published ON public.news(is_published, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(event_date DESC);
CREATE INDEX IF NOT EXISTS idx_moods_user_date ON public.moods(user_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, sent_at DESC);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employee_profiles_updated_at BEFORE UPDATE ON public.employee_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_updated_at BEFORE UPDATE ON public.news
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_hr_policies_updated_at BEFORE UPDATE ON public.hr_policies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_training_courses_updated_at BEFORE UPDATE ON public.training_courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_it_policies_updated_at BEFORE UPDATE ON public.it_policies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_navigation_links_updated_at BEFORE UPDATE ON public.navigation_links
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- You can add sample data here after creating your first user
-- Example:
-- INSERT INTO public.employee_profiles (user_id, job_title, department) 
-- VALUES ('your-user-uuid', 'Software Developer', 'IT');

COMMENT ON TABLE public.roles IS 'User roles for role-based access control';
COMMENT ON TABLE public.users IS 'User accounts linked to Supabase Auth';
COMMENT ON TABLE public.employee_profiles IS 'Extended employee information';
COMMENT ON TABLE public.news IS 'Company news and announcements';
COMMENT ON TABLE public.events IS 'Events, meetings, and celebrations';
COMMENT ON TABLE public.moods IS 'Daily employee mood tracking (one per day)';
COMMENT ON TABLE public.hr_policies IS 'HR policies and documents';
COMMENT ON TABLE public.training_courses IS 'Training and development courses';
COMMENT ON TABLE public.it_policies IS 'IT policies and security guidelines';
COMMENT ON TABLE public.management_messages IS 'Official messages from management';
COMMENT ON TABLE public.navigation_links IS 'Quick access links for employee dashboard';
COMMENT ON TABLE public.notifications IS 'User notifications history';
