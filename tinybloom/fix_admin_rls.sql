-- =============================================
-- RUN THIS IN SUPABASE SQL EDITOR
-- Fixes admin access to all tables
-- =============================================

-- ---- PROFILES ----
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins full access to profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON profiles;
DROP POLICY IF EXISTS "Admins full access" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins full access on profiles" ON profiles FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- ---- TESTIMONIALS ----
DROP POLICY IF EXISTS "Public can read published testimonials" ON testimonials;
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON testimonials;
DROP POLICY IF EXISTS "Admins manage all testimonials" ON testimonials;

CREATE POLICY "Public read published testimonials" ON testimonials FOR SELECT USING (is_published = true);
CREATE POLICY "Anyone can submit testimonials" ON testimonials FOR INSERT WITH CHECK (true);
CREATE POLICY "Admins full access on testimonials" ON testimonials FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- ---- SITE SETTINGS ----
DROP POLICY IF EXISTS "Public can read site settings" ON site_settings;
DROP POLICY IF EXISTS "Admins manage site settings" ON site_settings;

CREATE POLICY "Public read site settings" ON site_settings FOR SELECT USING (true);
CREATE POLICY "Admins full access on site_settings" ON site_settings FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- ---- ARTICLES ----
DROP POLICY IF EXISTS "Public can read published articles" ON articles;
DROP POLICY IF EXISTS "Admins manage articles" ON articles;

CREATE POLICY "Public read published articles" ON articles FOR SELECT USING (status = 'published');
CREATE POLICY "Admins full access on articles" ON articles FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- ---- FAQS ----
DROP POLICY IF EXISTS "Public can read published faqs" ON faqs;
DROP POLICY IF EXISTS "Admins manage faqs" ON faqs;

CREATE POLICY "Public read published faqs" ON faqs FOR SELECT USING (is_published = true);
CREATE POLICY "Admins full access on faqs" ON faqs FOR ALL
  USING ((SELECT role FROM profiles WHERE id = auth.uid()) = 'admin');

-- Verify admin profile
SELECT id, email, role FROM profiles WHERE email = 'admin@tinybloom.com';

-- =============================================
-- ADD NEW SITE SETTINGS KEYS FOR HOME PAGE
-- Run this to add the new editable fields
-- =============================================
INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('hero_btn_primary', 'Get Started Free', 'Hero primary button text'),
  ('hero_btn_secondary', 'Learn More', 'Hero secondary button text'),
  ('features_heading', 'More Support. Less Stress. Happier Pregnancy.', 'Features section heading'),
  ('features_subheading', 'Everything you need in one beautiful platform.', 'Features section subheading'),
  ('cta_title', 'Start your TinyBloom journey today.', 'CTA banner headline'),
  ('cta_subtitle', 'Join thousands of mothers who trust TinyBloom for a happier pregnancy.', 'CTA banner subtitle'),
  ('cta_btn', 'Register for Free', 'CTA button text')
ON CONFLICT (setting_key) DO NOTHING;
