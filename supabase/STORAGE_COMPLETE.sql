-- ================================================
-- STORAGE SETUP - Complete
-- Run AFTER running SIMPLE_SETUP.sql
-- ================================================

-- ================================================
-- STEP 1: Create Storage Buckets
-- ================================================
-- Note: Create buckets in Supabase Dashboard first:
-- Storage → New Bucket:
--   1. Name: "documents" | Public: NO
--   2. Name: "images" | Public: YES
--   3. Name: "videos" | Public: YES

-- Then run this SQL to set RLS policies:

-- ================================================
-- STEP 2: RLS Policies for DOCUMENTS bucket (Private)
-- ================================================

-- Allow authenticated users to upload documents
CREATE POLICY "Users can upload documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid() IS NOT NULL
);

-- Allow users to view their own documents
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow HR and Admin to view all documents
CREATE POLICY "HR and Admin can view all documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'documents' AND
    (
        get_user_role(auth.uid()) = 'HR' OR
        get_user_role(auth.uid()) = 'Admin'
    )
);

-- Allow users to update their own documents
CREATE POLICY "Users can update own documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own documents
CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- ================================================
-- STEP 3: RLS Policies for IMAGES bucket (Public)
-- ================================================

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'images' AND
    auth.uid() IS NOT NULL
);

-- Allow everyone to view images (public bucket)
CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'images');

-- Allow users to update their own images
CREATE POLICY "Users can update own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own images
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow Admin to delete any image
CREATE POLICY "Admin can delete any image"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'images' AND
    get_user_role(auth.uid()) = 'Admin'
);

-- ================================================
-- STEP 4: RLS Policies for VIDEOS bucket (Public)
-- ================================================

-- Allow authenticated users to upload videos
CREATE POLICY "Authenticated users can upload videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'videos' AND
    auth.uid() IS NOT NULL
);

-- Allow everyone to view videos (public bucket)
CREATE POLICY "Anyone can view videos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'videos');

-- Allow users to update their own videos
CREATE POLICY "Users can update own videos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'videos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own videos
CREATE POLICY "Users can delete own videos"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'videos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow Admin to delete any video
CREATE POLICY "Admin can delete any video"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'videos' AND
    get_user_role(auth.uid()) = 'Admin'
);

-- ================================================
-- SUCCESS!
-- ================================================
DO $$
BEGIN
    RAISE NOTICE '✅ Storage RLS policies created successfully!';
    RAISE NOTICE '✅ Documents bucket: Private (role-based access)';
    RAISE NOTICE '✅ Images bucket: Public (anyone can view)';
    RAISE NOTICE '✅ Videos bucket: Public (anyone can view)';
    RAISE NOTICE '';
    RAISE NOTICE 'Now you can upload files via Flutter app!';
END $$;
