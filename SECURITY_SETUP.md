# 🔐 Security & Configuration Guide

## ⚠️ CRITICAL: Before Running the App

### 1. Create .env File

```bash
cp .env.example .env
```

### 2. Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Project Settings** → **API**
4. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`

### 3. Update .env File

```env
SUPABASE_URL=https://your-actual-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...your-actual-key
```

### 4. Update supabase_config.dart

Open `lib/core/config/supabase_config.dart` and replace placeholders:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
```

**Replace with your actual values!**

---

## 🔒 Security Best Practices

### ✅ DO:
- Keep `.env` file in `.gitignore` (already done)
- Use environment variables for production
- Rotate keys if exposed
- Use RLS policies (already configured)
- Review Supabase logs regularly

### ❌ DON'T:
- Commit API keys to Git
- Share keys in screenshots
- Use production keys in development
- Hardcode sensitive data

---

## 📦 Storage Buckets Setup

### Create Buckets (Supabase Dashboard)

1. Go to **Storage** → **Create Bucket**
2. Create 3 buckets:

| Bucket Name | Public? | Purpose |
|-------------|---------|---------|
| `documents` | ❌ No | Private PDFs, HR files |
| `images` | ✅ Yes | News images, avatars |
| `videos` | ✅ Yes | Training videos |

### Apply RLS Policies

Run `supabase/STORAGE_COMPLETE.sql` in SQL Editor

```sql
-- This creates RLS policies for:
-- - Upload/download permissions
-- - Role-based access
-- - Admin overrides
```

---

## 🎯 File Upload Limits

**Default Limits:**
- Images: 50MB
- Videos: 100MB
- Documents: 50MB

**To Change:** Supabase Dashboard → Storage → Bucket → Settings

---

## 🔄 Environment-Specific Configs

### Development (.env)
```env
ENVIRONMENT=development
SUPABASE_URL=https://dev-project.supabase.co
```

### Production (.env.production)
```env
ENVIRONMENT=production
SUPABASE_URL=https://prod-project.supabase.co
```

---

## 🛡️ RLS Security Summary

### Documents Bucket (Private)
- ✅ Users upload to own folder
- ✅ Users view own files
- ✅ HR/Admin view all
- ❌ No public access

### Images/Videos Buckets (Public)
- ✅ Anyone can view
- ✅ Authenticated upload
- ✅ Users manage own files
- ✅ Admin can delete any

---

## 🚨 If Keys Are Exposed

1. **Immediately:** Go to Supabase Dashboard
2. **Project Settings** → **API** → **Reset Keys**
3. Update `.env` with new keys
4. Redeploy app

---

## ✅ Checklist Before Deployment

- [ ] `.env` file created with real credentials
- [ ] `supabase_config.dart` updated
- [ ] `.gitignore` includes `.env`
- [ ] Storage buckets created
- [ ] `STORAGE_COMPLETE.sql` executed
- [ ] Test file upload/download
- [ ] Keys not in Git history
- [ ] Production keys separate from dev

---

## 📞 Need Help?

- **Supabase Docs**: https://supabase.com/docs/guides/storage
- **RLS Guide**: https://supabase.com/docs/guides/auth/row-level-security
- **Security**: https://supabase.com/docs/guides/auth/security

---

## 🎯 Quick Test

After setup, try:

```bash
flutter run
```

Login and test:
- Upload avatar image (**images** bucket)
- Upload HR policy PDF (**documents** bucket)
- View files in Storage → Supabase Dashboard

✅ **Everything secured!** 🔐
