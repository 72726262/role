# 🔧 Database Fix Instructions

## ❌ Previous Error
```
ERROR: 42703: column users.role does not exist
```

**Cause:** The SQL was using `users.role` but your schema has `users.role_id`

---

## ✅ Fixed SQL File

Use: **`FIXED_COMPLETE_TABLES.sql`**

This file:
- ✅ Uses `role_id` instead of `role`
- ✅ Compatible with existing schema
- ✅ Adds all missing tables
- ✅ Updates existing tables safely
- ✅ Applies RLS policies correctly

---

## 📝 How to Apply

### Option 1: Supabase Dashboard (Recommended)

1. Go to Supabase Dashboard
2. Click **SQL Editor**
3. Click **New Query**
4. Copy all content from `FIXED_COMPLETE_TABLES.sql`
5. Click **Run**

### Option 2: Command Line

```bash
psql "your-connection-string" -f supabase/FIXED_COMPLETE_TABLES.sql
```

---

## ✅ What This SQL Does

### Creates 3 New Tables:
1. **permissions** - Role-based permissions
2. **event_attendees** - Event registration
3. **user_activity** - Audit logs

### Updates Existing Tables:
- **news**: adds `category`, `priority`, `images`
- **messages**: adds `attachments`, `is_read`, `read_at`
- **notifications**: adds `metadata`, `action_url`, `category`
- **events**: adds `location`, `max_attendees`, `image_url`

### Creates Indexes:
- Performance indexes on all tables
- Foreign key indexes

### Applies RLS Policies:
- Proper security for all tables
- Role-based access control

### Inserts Default Data:
- Permissions for all 5 roles
- Read/write permissions by role

---

## 🔍 Verification

After running the SQL, verify with:

```sql
-- Check new tables exist
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('permissions', 'event_attendees', 'user_activity');

-- Check permissions were created
SELECT COUNT(*) FROM public.permissions;

-- Check updated columns exist
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'news' AND column_name IN ('category', 'priority');
```

Expected results:
- 3 tables found
- 20 permissions created (5 roles × 4 resources)
- New columns exist

---

## ⚠️ Important Notes

1. **Safe to Run Multiple Times** - Uses `IF NOT EXISTS` and `ADD COLUMN IF NOT EXISTS`
2. **Non-Destructive** - Only adds, never deletes
3. **Preserves Data** - Existing data remains intact
4. **RLS Enabled** - Security policies applied

---

## 🎯 Next Steps After SQL

1. Run the SQL in Supabase
2. Verify tables created
3. Test the app
4. Check real-time subscriptions work

---

## 🆘 If Still Getting Errors

**Error: "relation already exists"**
- This is OK! It means the table/column already exists
- SQL will skip and continue

**Error: "permission denied"**
- Make sure you're using Service Role key in SQL Editor
- Or run as database owner

**Error: "function does not exist"**
- Run `SIMPLE_SETUP.sql` first to create helper functions
- Then run `FIXED_COMPLETE_TABLES.sql`

---

## 📊 Current Schema

```
users
  ├── id (UUID, FK to auth.users)
  ├── email (TEXT)
  ├── full_name (TEXT)
  ├── role_id (UUID, FK to roles) ✅ NOT 'role'!
  ├── is_active (BOOLEAN)
  ├── created_at (TIMESTAMP)
  └── updated_at (TIMESTAMP)

roles
  ├── id (UUID, PK)
  ├── role_name (TEXT)
  ├── description (TEXT)
  ├── permissions (JSONB)
  └── created_at (TIMESTAMP)

permissions (NEW!)
  ├── id (UUID)
  ├── role_id (UUID, FK to roles) ✅
  ├── resource (TEXT)
  ├── can_create (BOOLEAN)
  ├── can_read (BOOLEAN)
  ├── can_update (BOOLEAN)
  └── can_delete (BOOLEAN)
```

---

**✅ Fixed and Ready!**
