-- =============================================
-- FINAL RLS FIX — Run this in Supabase SQL Editor
-- Fixes infinite recursion in profiles policy
-- =============================================

-- Drop ALL existing policies on profiles
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins full access to profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins full access" ON profiles;
DROP POLICY IF EXISTS "Admins full access on profiles" ON profiles;

-- Simple non-recursive policies
-- Users read/update their own row only
CREATE POLICY "own_profile_select" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "own_profile_update" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "own_profile_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Drop ALL existing policies on testimonials
DROP POLICY IF EXISTS "Public can read published testimonials" ON testimonials;
DROP POLICY IF EXISTS "Public read published testimonials" ON testimonials;
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON testimonials;
DROP POLICY IF EXISTS "Anyone can submit testimonials" ON testimonials;
DROP POLICY IF EXISTS "Admins manage all testimonials" ON testimonials;
DROP POLICY IF EXISTS "Admins full access on testimonials" ON testimonials;

-- Testimonials: public read published, anyone insert, admin all
-- Use auth.email() to check admin — avoids querying profiles (no recursion)
CREATE POLICY "testimonials_public_read" ON testimonials FOR SELECT USING (is_published = true);
CREATE POLICY "testimonials_insert" ON testimonials FOR INSERT WITH CHECK (true);
CREATE POLICY "testimonials_admin_all" ON testimonials FOR ALL
  USING (auth.email() = 'admin@tinybloom.com');

-- Drop ALL existing policies on site_settings
DROP POLICY IF EXISTS "Public can read site settings" ON site_settings;
DROP POLICY IF EXISTS "Public read site settings" ON site_settings;
DROP POLICY IF EXISTS "Admins manage site settings" ON site_settings;
DROP POLICY IF EXISTS "Admins full access on site_settings" ON site_settings;

CREATE POLICY "settings_public_read" ON site_settings FOR SELECT USING (true);
CREATE POLICY "settings_admin_all" ON site_settings FOR ALL
  USING (auth.email() = 'admin@tinybloom.com');

-- Drop ALL existing policies on articles
DROP POLICY IF EXISTS "Public can read published articles" ON articles;
DROP POLICY IF EXISTS "Public read published articles" ON articles;
DROP POLICY IF EXISTS "Admins manage articles" ON articles;
DROP POLICY IF EXISTS "Admins full access on articles" ON articles;

CREATE POLICY "articles_public_read" ON articles FOR SELECT USING (status = 'published');
CREATE POLICY "articles_admin_all" ON articles FOR ALL
  USING (auth.email() = 'admin@tinybloom.com');

-- Drop ALL existing policies on faqs
DROP POLICY IF EXISTS "Public can read published faqs" ON faqs;
DROP POLICY IF EXISTS "Public read published faqs" ON faqs;
DROP POLICY IF EXISTS "Admins manage faqs" ON faqs;
DROP POLICY IF EXISTS "Admins full access on faqs" ON faqs;

CREATE POLICY "faqs_public_read" ON faqs FOR SELECT USING (is_published = true);
CREATE POLICY "faqs_admin_all" ON faqs FOR ALL
  USING (auth.email() = 'admin@tinybloom.com');

-- Verify
SELECT tablename, policyname FROM pg_policies
WHERE tablename IN ('profiles','testimonials','site_settings','articles','faqs')
ORDER BY tablename;
