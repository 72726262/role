-- ================================================
-- STORAGE SETUP - SAFE VERSION (No Errors)
-- Works even if policies already exist
-- ================================================

-- ================================================
-- RLS Policies for DOCUMENTS bucket (Private)
-- ================================================

DROP POLICY IF EXISTS "Users can upload documents" ON storage.objects;
CREATE POLICY "Users can upload documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'documents' AND
    auth.uid() IS NOT NULL
);

DROP POLICY IF EXISTS "Users can view own documents" ON storage.objects;
CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "HR and Admin can view all documents" ON storage.objects;
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

DROP POLICY IF EXISTS "Users can update own documents" ON storage.objects;
CREATE POLICY "Users can update own documents"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can delete own documents" ON storage.objects;
CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

-- ================================================
-- RLS Policies for IMAGES bucket (Public)
-- ================================================

DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'images' AND
    auth.uid() IS NOT NULL
);

DROP POLICY IF EXISTS "Anyone can view images" ON storage.objects;
CREATE POLICY "Anyone can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'images');

DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;
CREATE POLICY "Users can update own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'images' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Admin can delete any image" ON storage.objects;
CREATE POLICY "Admin can delete any image"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'images' AND
    get_user_role(auth.uid()) = 'Admin'
);

-- ================================================
-- RLS Policies for VIDEOS bucket (Public)
-- ================================================

DROP POLICY IF EXISTS "Authenticated users can upload videos" ON storage.objects;
CREATE POLICY "Authenticated users can upload videos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'videos' AND
    auth.uid() IS NOT NULL
);

DROP POLICY IF EXISTS "Anyone can view videos" ON storage.objects;
CREATE POLICY "Anyone can view videos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'videos');

DROP POLICY IF EXISTS "Users can update own videos" ON storage.objects;
CREATE POLICY "Users can update own videos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'videos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Users can delete own videos" ON storage.objects;
CREATE POLICY "Users can delete own videos"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'videos' AND
    auth.uid()::text = (storage.foldername(name))[1]
);

DROP POLICY IF EXISTS "Admin can delete any video" ON storage.objects;
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
    RAISE NOTICE '✅ Storage policies updated successfully!';
    RAISE NOTICE '✅ Documents: Private (HR/Admin access)';
    RAISE NOTICE '✅ Images: Public';
    RAISE NOTICE '✅ Videos: Public';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Ready to upload files!';
END $$;
