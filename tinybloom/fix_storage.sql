-- =============================================
-- Run this in Supabase SQL Editor
-- Creates storage bucket for site images
-- =============================================

-- Create public images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('site-images', 'site-images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow admin to upload images
CREATE POLICY "admin_upload_images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'site-images' AND
    auth.email() = 'admin@tinybloom.com'
  );

-- Allow admin to update/delete images
CREATE POLICY "admin_manage_images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'site-images' AND
    auth.email() = 'admin@tinybloom.com'
  );

-- Allow public to read images
CREATE POLICY "public_read_images" ON storage.objects
  FOR SELECT USING (bucket_id = 'site-images');
