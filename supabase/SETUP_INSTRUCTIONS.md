# تطبيق Schema على Supabase

## الخطوة 1: تسجيل الدخول إلى Supabase Dashboard

1. افتح المتصفح واذهب إلى: https://supabase.com/dashboard
2. اختر المشروع الخاص بك

## الخطوة 2: تطبيق SQL Schema

### الطريقة الأولى: عبر SQL Editor في Dashboard

1. في Dashboard، اذهب إلى **SQL Editor** من القائمة الجانبية
2. اضغط على **New Query**
3. انسخ محتوى ملف `supabase/schema.sql` كاملاً
4. الصق المحتوى في المحرر
5. اضغط **Run** أو `Ctrl+Enter`
6. انتظر حتى يكتمل التنفيذ (قد يستغرق 10-30 ثانية)

### الطريقة الثانية: عبر Supabase CLI (إذا كان مثبت)

```bash
# تثبيت Supabase CLI (إذا لم يكن مثبتاً)
npm install -g supabase

# تسجيل الدخول
supabase login

# ربط المشروع
supabase link --project-ref mwruqqjbaqqdygbrggmd

# تطبيق Schema
supabase db push
```

## الخطوة 3: إنشاء Storage Buckets

1. اذهب إلى **Storage** من القائمة الجانبية
2. اضغط **Create a new bucket**

### Bucket 1: documents
- **Name**: `documents`
- **Public**: ✅ (اختياري - للسماح بقراءة PDFs)
- **File size limit**: 50 MB
- **Allowed MIME types**: `application/pdf`

### Bucket 2: images
- **Name**: `images`
- **Public**: ✅
- **File size limit**: 5 MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`

## الخطوة 4: تطبيق Storage Policies

### لـ documents bucket:

```sql
-- Allow authenticated users to read documents
CREATE POLICY "Authenticated users can read documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'documents');

-- Allow HR, IT, and Admin to upload documents
CREATE POLICY "HR, IT, Admin can upload documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'documents' AND
    EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid()
        AND r.role_name IN ('HR', 'IT', 'Admin')
    )
);

-- Allow Admin to delete documents
CREATE POLICY "Admin can delete documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'documents' AND
    EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid()
        AND r.role_name = 'Admin'
    )
);
```

### لـ images bucket:

```sql
-- Allow everyone to read images
CREATE POLICY "Everyone can read images"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'images');

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- Allow users to update their own images or Admin
CREATE POLICY "Users can update own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid()
        AND r.role_name = 'Admin'
    ))
);

-- Allow users to delete their own images or Admin
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'images' AND
    (auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (
        SELECT 1 FROM public.users u
        JOIN public.roles r ON u.role_id = r.id
        WHERE u.id = auth.uid()
        AND r.role_name = 'Admin'
    ))
);
```

## الخطوة 5: إنشاء أول مستخدم Admin

بعد تطبيق الـ Schema، يجب إنشاء مستخدم Admin أولاً:

1. اذهب إلى **Authentication** > **Users**
2. اضغط **Add user** > **Create new user**
3. أدخل:
   - Email: admin@company.com
   - Password: (اختر كلمة مرور قوية)
   - ✅ Auto Confirm User

4. بعد إنشاء المستخدم، احصل على الـ UUID الخاص به
5. اذهب إلى **SQL Editor** ونفذ:

```sql
-- إدراج المستخدم في جدول users كـ Admin
INSERT INTO public.users (id, email, full_name, role_id)
VALUES (
    'user-uuid-here',  -- ضع UUID المستخدم هنا
    'admin@company.com',
    'System Admin',
    (SELECT id FROM public.roles WHERE role_name = 'Admin')
);

-- إنشاء ملف تعريف للمستخدم
INSERT INTO public.employee_profiles (user_id, job_title, department)
VALUES (
    'user-uuid-here',  -- نفس UUID
    'System Administrator',
    'IT'
);
```

## الخطوة 6: التحقق من التثبيت

تحقق من أن كل شيء تم بنجاح:

```sql
-- التحقق من الجداول
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- التحقق من الأدوار
SELECT * FROM public.roles;

-- التحقق من RLS
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- التحقق من Storage Buckets
SELECT * FROM storage.buckets;
```

## ملاحظات مهمة

✅ **تم إنشاء**:
- 12 جدول بيانات
- 5 أدوار (Roles)
- Row Level Security Policies قوية جداً
- Indexes للأداء
- Triggers للـ updated_at
- Functions مساعدة

⚠️ **يجب عليك**:
- إنشاء Storage Buckets يدوياً
- تطبيق Storage Policies
- إنشاء مستخدم Admin أولاً
- اختبار الصلاحيات

🔐 **الأمان**:
- كل جدول محمي بـ RLS
- الصلاحيات موزعة حسب الأدوار
- لا يمكن لأي مستخدم الوصول لبيانات غيره
- Admin فقط له صلاحيات كاملة
