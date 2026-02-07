-- ================================================
-- STORAGE BUCKETS SETUP
-- Run this in Supabase Dashboard > Storage
-- ================================================

-- Note: Storage buckets are created via Dashboard UI or SQL
-- This script creates the necessary policies

-- ================================================
-- STEP 1: CREATE BUCKETS (Via Dashboard)
-- ================================================
-- Go to Storage > Create Bucket
-- 1. Name: "documents" | Public: No
-- 2. Name: "images" | Public: Yes (for news/profile images)

-- ================================================
-- STEP 2: STORAGE POLICIES
-- ================================================

-- Documents Bucket Policies (Private)
-- SELECT
CREATE POLICY "Authenticated users can view documents"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'documents' AND
    auth.role() = 'authenticated'
);

-- INSERT
CREATE POLICY "HR/IT/Admin can upload documents"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'documents' AND
    (
        get_user_role(auth.uid()) IN ('HR', 'IT', 'Admin')
    )
);

-- UPDATE
CREATE POLICY "HR/IT/Admin can update documents"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'documents' AND
    get_user_role(auth.uid()) IN ('HR', 'IT', 'Admin')
);

-- DELETE
CREATE POLICY "Admin can delete documents"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'documents' AND
    get_user_role(auth.uid()) = 'Admin'
);

-- Images Bucket Policies (Public)
-- SELECT (Public Read)
CREATE POLICY "Anyone can view public images"
ON storage.objects FOR SELECT
USING (bucket_id = 'images');

-- INSERT
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'images' AND
    auth.role() = 'authenticated'
);

-- UPDATE
CREATE POLICY "Users can update own images or admins can update all"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'images' AND
    (
        auth.uid()::text = (storage.foldername(name))[1] OR
        get_user_role(auth.uid()) = 'Admin'
    )
);

-- DELETE
CREATE POLICY "Users can delete own images or admins can delete all"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'images' AND
    (
        auth.uid()::text = (storage.foldername(name))[1] OR
        get_user_role(auth.uid()) = 'Admin'
    )
);

-- ================================================
-- SUCCESS MESSAGE
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '✅ Storage policies created!';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Manual Steps Required:';
    RAISE NOTICE '1. Go to Storage in Supabase Dashboard';
    RAISE NOTICE '2. Create bucket: "documents" (Private)';
    RAISE NOTICE '3. Create bucket: "images" (Public)';
    RAISE NOTICE '4. Policies are already configured';
END $$;
