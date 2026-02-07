-- ============================================
-- FIXED COMPLETE SYSTEM TABLES
-- Compatible with existing structure
-- ============================================

-- PREREQUISITE: Ensure uuid extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PERMISSIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
  resource VARCHAR(100) NOT NULL,
  can_create BOOLEAN DEFAULT false,
  can_read BOOLEAN DEFAULT true,
  can_update BOOLEAN DEFAULT false,
  can_delete BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(role_id, resource)
);

CREATE INDEX IF NOT EXISTS idx_permissions_role_id ON public.permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_permissions_resource ON public.permissions(resource);

-- ============================================
-- 2. EVENT ATTENDEES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.event_attendees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'pending')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_event_attendees_event_id ON public.event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user_id ON public.event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_status ON public.event_attendees(status);

-- ============================================
-- 3. USER ACTIVITY LOG TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_activity (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  details JSONB DEFAULT '{}',
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON public.user_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_action ON public.user_activity(action);
CREATE INDEX IF NOT EXISTS idx_user_activity_created_at ON public.user_activity(created_at DESC);

-- ============================================
-- 4. UPDATE EXISTING TABLES
-- ============================================

-- Add missing columns to NEWS table
ALTER TABLE public.news 
ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'announcement';

ALTER TABLE public.news 
ADD COLUMN IF NOT EXISTS priority VARCHAR(20) DEFAULT 'normal';

ALTER TABLE public.news 
ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]';

-- Add missing columns to MESSAGES table
ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]';

ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;

ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- Add missing columns to NOTIFICATIONS table
ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS action_url TEXT;

ALTER TABLE public.notifications 
ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'general';

-- Add missing columns to EVENTS table
ALTER TABLE public.events 
ADD COLUMN IF NOT EXISTS location TEXT;

ALTER TABLE public.events 
ADD COLUMN IF NOT EXISTS max_attendees INTEGER;

ALTER TABLE public.events 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- ============================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_messages_receiver_role ON public.messages(receiver_role);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON public.messages(is_read);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_category ON public.notifications(category);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_news_category ON public.news(category);
CREATE INDEX IF NOT EXISTS idx_news_priority ON public.news(priority);

CREATE INDEX IF NOT EXISTS idx_events_event_date ON public.events(event_date);

-- ============================================
-- 6. RLS POLICIES FOR PERMISSIONS TABLE
-- ============================================

ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
DROP POLICY IF EXISTS "Admin can manage permissions" ON public.permissions;
CREATE POLICY "Admin can manage permissions"
ON public.permissions FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.role_name = 'Admin'
  )
);

-- Users can view their role permissions
DROP POLICY IF EXISTS "Users can view their role permissions" ON public.permissions;
CREATE POLICY "Users can view their role permissions"
ON public.permissions FOR SELECT
TO authenticated
USING (
  role_id IN (
    SELECT role_id FROM public.users WHERE id = auth.uid()
  )
);

-- ============================================
-- 7. RLS POLICIES FOR EVENT_ATTENDEES TABLE
-- ============================================

ALTER TABLE public.event_attendees ENABLE ROW LEVEL SECURITY;

-- Users can view attendees of events
DROP POLICY IF EXISTS "Users can view event attendees" ON public.event_attendees;
CREATE POLICY "Users can view event attendees"
ON public.event_attendees FOR SELECT
TO authenticated
USING (true);

-- Users can register themselves for events
DROP POLICY IF EXISTS "Users can register for events" ON public.event_attendees;
CREATE POLICY "Users can register for events"
ON public.event_attendees FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Users can cancel their own registration
DROP POLICY IF EXISTS "Users can cancel their registration" ON public.event_attendees;
CREATE POLICY "Users can cancel their registration"
ON public.event_attendees FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Users can delete their own registration
DROP POLICY IF EXISTS "Users can delete their registration" ON public.event_attendees;
CREATE POLICY "Users can delete their registration"
ON public.event_attendees FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Admin/HR can manage all attendees
DROP POLICY IF EXISTS "Admin can manage all attendees" ON public.event_attendees;
CREATE POLICY "Admin can manage all attendees"
ON public.event_attendees FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.role_name IN ('Admin', 'HR')
  )
);

-- ============================================
-- 8. RLS POLICIES FOR USER_ACTIVITY TABLE
-- ============================================

ALTER TABLE public.user_activity ENABLE ROW LEVEL SECURITY;

-- Users can view their own activity
DROP POLICY IF EXISTS "Users can view own activity" ON public.user_activity;
CREATE POLICY "Users can view own activity"
ON public.user_activity FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- System can insert activity
DROP POLICY IF EXISTS "Service can insert activity" ON public.user_activity;
CREATE POLICY "Service can insert activity"
ON public.user_activity FOR INSERT
TO authenticated
WITH CHECK (true);

-- Admin can view all activity
DROP POLICY IF EXISTS "Admin can view all activity" ON public.user_activity;
CREATE POLICY "Admin can view all activity"
ON public.user_activity FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.role_name = 'Admin'
  )
);

-- ============================================
-- 9. UPDATE TRIGGER FOR TIMESTAMPS
-- ============================================

-- Trigger for permissions
DROP TRIGGER IF EXISTS update_permissions_updated_at ON public.permissions;
CREATE TRIGGER update_permissions_updated_at 
BEFORE UPDATE ON public.permissions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for event_attendees
DROP TRIGGER IF EXISTS update_event_attendees_updated_at ON public.event_attendees;
CREATE TRIGGER update_event_attendees_updated_at 
BEFORE UPDATE ON public.event_attendees
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 10. INSERT DEFAULT PERMISSIONS
-- ============================================

-- Clear existing permissions
TRUNCATE TABLE public.permissions;

-- Insert permissions for each role
INSERT INTO public.permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'users',
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM public.roles r;

INSERT INTO public.permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'news',
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM public.roles r;

INSERT INTO public.permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'events',
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM public.roles r;

INSERT INTO public.permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'messages',
  true,
  true,
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM public.roles r;

-- ============================================
-- 11. CREATE HELPER VIEW
-- ============================================

DROP VIEW IF EXISTS public.user_permissions;
CREATE OR REPLACE VIEW public.user_permissions AS
SELECT 
  u.id as user_id,
  u.email,
  r.role_name,
  p.resource,
  p.can_create,
  p.can_read,
  p.can_update,
  p.can_delete
FROM public.users u
LEFT JOIN public.roles r ON u.role_id = r.id
LEFT JOIN public.permissions p ON r.id = p.role_id;

-- Grant access
GRANT SELECT ON public.user_permissions TO authenticated;

-- ============================================
-- 12. ENABLE REALTIME (Optional)
-- ============================================

-- Enable realtime for new tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.permissions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_attendees;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_activity;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Uncomment to verify:
-- SELECT * FROM public.permissions;
-- SELECT * FROM public.event_attendees;
-- SELECT * FROM public.user_activity;
-- SELECT * FROM public.user_permissions;

-- ============================================
-- ✅ SETUP COMPLETE!
-- ============================================

-- Summary:
-- ✅ 3 new tables created
-- ✅ Existing tables updated
-- ✅ RLS policies applied
-- ✅ Indexes created
-- ✅ Default permissions inserted
-- ✅ Realtime enabled
