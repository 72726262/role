-- ============================================
-- إضافة الجداول الناقصة للنظام المتكامل
-- ============================================

-- 1. جدول الإشعارات (Real-time)
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('message', 'news', 'event', 'system', 'announcement')),
  title TEXT NOT NULL,
  body TEXT,
  data JSONB DEFAULT '{}',
  link TEXT, -- للتنقل للصفحة المطلوبة
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- 2. جدول الرسائل (Messages/Chat)
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver_role TEXT, -- 'all', 'employee', 'hr', 'it', 'management', 'admin'
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  attachments JSONB DEFAULT '[]', -- [{type: 'image'|'video'|'link', url: '...', title: '...'}]
  is_important BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_role ON messages(receiver_role);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- 3. إعدادات التطبيق
CREATE TABLE IF NOT EXISTS app_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,
  value JSONB NOT NULL,
  category TEXT CHECK (category IN ('general', 'notifications', 'privacy', 'system')),
  description TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_app_settings_category ON app_settings(category);

-- 4. تفضيلات المستخدمين
CREATE TABLE IF NOT EXISTS user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  theme TEXT DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'system')),
  language TEXT DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. صلاحيات الأدوار
CREATE TABLE IF NOT EXISTS role_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
  resource TEXT NOT NULL, -- 'users', 'news', 'messages', 'events', 'settings'
  can_create BOOLEAN DEFAULT FALSE,
  can_read BOOLEAN DEFAULT FALSE,
  can_update BOOLEAN DEFAULT FALSE,
  can_delete BOOLEAN DEFAULT FALSE,
  UNIQUE(role_id, resource)
);

CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);

-- 6. سجل النشاطات (Audit Trail)
CREATE TABLE IF NOT EXISTS activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL, -- 'create', 'update', 'delete', 'login', 'logout'
  resource TEXT NOT NULL, -- 'user', 'news', 'message', etc.
  resource_id UUID,
  details JSONB DEFAULT '{}',
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);

-- ============================================
-- RLS Policies للجداول الجديدة
-- ============================================

-- Notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can insert notifications" ON notifications;
CREATE POLICY "System can insert notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (true);

-- Messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view relevant messages" ON messages;
CREATE POLICY "Users can view relevant messages"
ON messages FOR SELECT
TO authenticated
USING (
  receiver_role = 'all' OR
  EXISTS (
    SELECT 1 FROM users
    INNER JOIN roles ON users.role_id = roles.id
    WHERE users.id = auth.uid()
    AND roles.role_name = messages.receiver_role
  ) OR
  sender_id = auth.uid()
);

DROP POLICY IF EXISTS "Authorized users can create messages" ON messages;
CREATE POLICY "Authorized users can create messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (sender_id = auth.uid());

DROP POLICY IF EXISTS "Senders can update own messages" ON messages;
CREATE POLICY "Senders can update own messages"
ON messages FOR UPDATE
TO authenticated
USING (sender_id = auth.uid());

DROP POLICY IF EXISTS "Senders can delete own messages" ON messages;
CREATE POLICY "Senders can delete own messages"
ON messages FOR DELETE
TO authenticated
USING (sender_id = auth.uid());

-- User Preferences
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own preferences" ON user_preferences;
CREATE POLICY "Users can manage own preferences"
ON user_preferences FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- App Settings (Admin only)
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read settings" ON app_settings;
CREATE POLICY "Everyone can read settings"
ON app_settings FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Admins can manage settings" ON app_settings;
CREATE POLICY "Admins can manage settings"
ON app_settings FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    INNER JOIN roles ON users.role_id = roles.id
    WHERE users.id = auth.uid()
    AND roles.role_name = 'Admin'
  )
);

-- Role Permissions (Admin only)
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read permissions" ON role_permissions;
CREATE POLICY "Everyone can read permissions"
ON role_permissions FOR SELECT
TO authenticated
USING (true);

-- Activity Logs (Admin only read)
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "System can insert logs" ON activity_logs;
CREATE POLICY "System can insert logs"
ON activity_logs FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Admins can view logs" ON activity_logs;
CREATE POLICY "Admins can view logs"
ON activity_logs FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    INNER JOIN roles ON users.role_id = roles.id
    WHERE users.id = auth.uid()
    AND roles.role_name = 'Admin'
  )
);

-- ============================================
-- إدراج صلاحيات افتراضية
-- ============================================

-- Admin: Full access
INSERT INTO role_permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  roles.id,
  resource,
  true, true, true, true
FROM roles, 
  UNNEST(ARRAY['users', 'news', 'messages', 'events', 'settings', 'training_courses', 'hr_policies', 'it_policies']) AS resource
WHERE roles.role_name = 'Admin'
ON CONFLICT (role_id, resource) DO NOTHING;

-- Management: Messages, News, Events
INSERT INTO role_permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  roles.id,
  resource,
  true, true, true, true
FROM roles,
  UNNEST(ARRAY['messages', 'news', 'events']) AS resource
WHERE roles.role_name = 'Management'
ON CONFLICT (role_id, resource) DO NOTHING;

-- HR: HR specific resources
INSERT INTO role_permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  roles.id,
  resource,
  true, true, true, true
FROM roles,
  UNNEST(ARRAY['training_courses', 'hr_policies', 'users']) AS resource
WHERE roles.role_name = 'HR'
ON CONFLICT (role_id, resource) DO UPDATE SET
  can_read = true,
  can_create = EXCLUDED.can_create,
  can_update = EXCLUDED.can_update,
  can_delete = EXCLUDED.can_delete;

-- IT: IT specific resources  
INSERT INTO role_permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  roles.id,
  resource,
  true, true, true, true
FROM roles,
  UNNEST(ARRAY['it_policies', 'users']) AS resource
WHERE roles.role_name = 'IT'
ON CONFLICT (role_id, resource) DO UPDATE SET
  can_read = true,
  can_create = EXCLUDED.can_create,
  can_update = EXCLUDED.can_update,
  can_delete = EXCLUDED.can_delete;

-- Employee: Read only
INSERT INTO role_permissions (role_id, resource, can_create, can_read, can_update, can_delete)
SELECT 
  roles.id,
  resource,
  false, true, false, false
FROM roles,
  UNNEST(ARRAY['news', 'messages', 'events', 'training_courses']) AS resource
WHERE roles.role_name = 'Employee'
ON CONFLICT (role_id, resource) DO UPDATE SET can_read = true;

-- ============================================
-- إعدادات افتراضية للتطبيق
-- ============================================

INSERT INTO app_settings (key, value, category, description) VALUES
('app_name', '{"ar": "بوابة الموظفين", "en": "Employee Portal"}', 'general', 'Application name'),
('maintenance_mode', 'false', 'system', 'Enable maintenance mode'),
('allow_registration', 'false', 'system', 'Allow new user registration'),
('notifications_enabled', 'true', 'notifications', 'Enable notifications'),
('max_upload_size_mb', '10', 'system', 'Maximum file upload size')
ON CONFLICT (key) DO NOTHING;

-- ============================================
-- Triggers للـ Real-time
-- ============================================

-- تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_messages_updated_at
BEFORE UPDATE ON messages
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at
BEFORE UPDATE ON user_preferences
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_app_settings_updated_at
BEFORE UPDATE ON app_settings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- التحقق من الجداول
-- ============================================

SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_name IN ('notifications', 'messages', 'app_settings', 'user_preferences', 'role_permissions', 'activity_logs')
ORDER BY table_name;
