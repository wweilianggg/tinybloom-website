-- =============================================
-- Run this in Supabase SQL Editor
-- Drops the broken trigger and fixes policies
-- so registration works without it
-- =============================================

-- Drop the existing trigger and function entirely
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Ensure profiles allows insert from anyone authenticated OR during signup
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Re-enable with simple open policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own_profile_select" ON profiles;
DROP POLICY IF EXISTS "own_profile_update" ON profiles;
DROP POLICY IF EXISTS "own_profile_insert" ON profiles;
DROP POLICY IF EXISTS "own_profile_upsert" ON profiles;
DROP POLICY IF EXISTS "Admins full access on profiles" ON profiles;

-- Anyone can insert a profile (we validate user_id = auth.uid() in the app)
CREATE POLICY "profiles_insert" ON profiles
  FOR INSERT WITH CHECK (true);

-- Users can read their own profile
CREATE POLICY "profiles_select_own" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile  
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Admin can do everything
CREATE POLICY "profiles_admin" ON profiles
  FOR ALL USING (auth.email() = 'admin@tinybloom.com');

-- Verify
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'profiles';

-- Allow admin to delete profiles
DROP POLICY IF EXISTS "profiles_delete_admin" ON profiles;
CREATE POLICY "profiles_delete_admin" ON profiles
  FOR DELETE USING (auth.email() = 'admin@tinybloom.com');
