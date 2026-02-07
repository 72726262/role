-- ============================================
-- ADDITIONAL TABLES FOR COMPLETE SYSTEM
-- ============================================

-- 1. PERMISSIONS TABLE
-- Stores role-based permissions for resources
CREATE TABLE IF NOT EXISTS permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
  resource VARCHAR(100) NOT NULL,
  can_create BOOLEAN DEFAULT false,
  can_read BOOLEAN DEFAULT true,
  can_update BOOLEAN DEFAULT false,
  can_delete BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(role_id, resource)
);

-- 2. EVENT ATTENDEES TABLE
-- Tracks who is attending which event
CREATE TABLE IF NOT EXISTS event_attendees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled', 'pending')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 3. USER ACTIVITY LOG TABLE
-- Logs user actions for audit trail
CREATE TABLE IF NOT EXISTS user_activity (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  details JSONB DEFAULT '{}',
  ip_address VARCHAR(50),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. UPDATE MESSAGES TABLE
-- Add attachments column if not exists
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]';

-- Add read status
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;

-- Add read at timestamp
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP;

-- 5. UPDATE NOTIFICATIONS TABLE
-- Add metadata column for additional info
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- Add action URL for click navigation
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS action_url TEXT;

-- Add notification category
ALTER TABLE notifications 
ADD COLUMN IF NOT EXISTS category VARCHAR(50) DEFAULT 'general';

-- 6. CREATE INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_permissions_role_id ON permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_permissions_resource ON permissions(resource);

CREATE INDEX IF NOT EXISTS idx_event_attendees_event_id ON event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_user_id ON event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_event_attendees_status ON event_attendees(status);

CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON user_activity(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_action ON user_activity(action);
CREATE INDEX IF NOT EXISTS idx_user_activity_created_at ON user_activity(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_receiver_role ON messages(receiver_role);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_category ON notifications(category);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- 7. RLS POLICIES FOR PERMISSIONS TABLE
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
CREATE POLICY "Admin can manage permissions"
ON permissions FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'Admin'
  )
);

-- Others can only view their role permissions
CREATE POLICY "Users can view their role permissions"
ON permissions FOR SELECT
TO authenticated
USING (
  role_id IN (
    SELECT role_id FROM users WHERE id = auth.uid()
  )
);

-- 8. RLS POLICIES FOR EVENT_ATTENDEES TABLE
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- Users can view attendees of events
CREATE POLICY "Users can view event attendees"
ON event_attendees FOR SELECT
TO authenticated
USING (true);

-- Users can register themselves for events
CREATE POLICY "Users can register for events"
ON event_attendees FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Users can cancel their own registration
CREATE POLICY "Users can cancel their registration"
ON event_attendees FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

-- Users can delete their own registration
CREATE POLICY "Users can delete their registration"
ON event_attendees FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Admin can manage all attendees
CREATE POLICY "Admin can manage all attendees"
ON event_attendees FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'Admin'
  )
);

-- 9. RLS POLICIES FOR USER_ACTIVITY TABLE
ALTER TABLE user_activity ENABLE ROW LEVEL SECURITY;

-- Users can view their own activity
CREATE POLICY "Users can view own activity"
ON user_activity FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- System can insert activity (service role)
CREATE POLICY "Service can insert activity"
ON user_activity FOR INSERT
TO authenticated
WITH CHECK (true);

-- Admin can view all activity
CREATE POLICY "Admin can view all activity"
ON user_activity FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'Admin'
  )
);

-- 10. CREATE FUNCTIONS FOR AUTOMATIC TIMESTAMPS
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables with updated_at
CREATE TRIGGER update_permissions_updated_at BEFORE UPDATE ON permissions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_attendees_updated_at BEFORE UPDATE ON event_attendees
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 11. INSERT DEFAULT PERMISSIONS FOR ROLES
-- Get role IDs first (run this after roles are created)
INSERT INTO permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'users',
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM roles r
ON CONFLICT (role_id, resource) DO NOTHING;

INSERT INTO permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'news',
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM roles r
ON CONFLICT (role_id, resource) DO NOTHING;

INSERT INTO permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'events',
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  true,
  CASE WHEN r.role_name IN ('Admin', 'HR') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM roles r
ON CONFLICT (role_id, resource) DO NOTHING;

INSERT INTO permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  r.id,
  'messages',
  true,
  true,
  CASE WHEN r.role_name IN ('Admin', 'Management') THEN true ELSE false END,
  CASE WHEN r.role_name = 'Admin' THEN true ELSE false END
FROM roles r
ON CONFLICT (role_id, resource) DO NOTHING;

-- 12. CREATE VIEW FOR USER PERMISSIONS
CREATE OR REPLACE VIEW user_permissions AS
SELECT 
  u.id as user_id,
  u.email,
  u.role,
  p.resource,
  p.can_create,
  p.can_read,
  p.can_update,
  p.can_delete
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN permissions p ON r.id = p.role_id;

-- Grant access to view
GRANT SELECT ON user_permissions TO authenticated;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if all tables exist
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' 
-- AND tablename IN ('permissions', 'event_attendees', 'user_activity');

-- Check permissions count
-- SELECT COUNT(*) FROM permissions;

-- Check event attendees
-- SELECT COUNT(*) FROM event_attendees;

-- Check user activity
-- SELECT COUNT(*) FROM user_activity;

-- ============================================
-- COMPLETED SUCCESSFULLY
-- ============================================
