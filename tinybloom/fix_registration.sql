-- =============================================
-- Run this in Supabase SQL Editor
-- Fixes registration for all user types
-- =============================================

-- Allow profile upsert on registration (the trigger + direct upsert both need this)
DROP POLICY IF EXISTS "own_profile_insert" ON profiles;
CREATE POLICY "own_profile_insert" ON profiles
  FOR INSERT WITH CHECK (true);

-- Also allow upsert (update on conflict)
DROP POLICY IF EXISTS "own_profile_upsert" ON profiles;
CREATE POLICY "own_profile_upsert" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Enable RLS and allow insert on specialist_profiles
ALTER TABLE specialist_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "specialist_insert" ON specialist_profiles;
CREATE POLICY "specialist_insert" ON specialist_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "specialist_select" ON specialist_profiles;
CREATE POLICY "specialist_select" ON specialist_profiles
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "specialist_admin" ON specialist_profiles
  FOR ALL USING (auth.email() = 'admin@tinybloom.com');

-- Enable RLS and allow insert on volunteer_profiles
ALTER TABLE volunteer_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "volunteer_insert" ON volunteer_profiles;
CREATE POLICY "volunteer_insert" ON volunteer_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "volunteer_select" ON volunteer_profiles;
CREATE POLICY "volunteer_select" ON volunteer_profiles
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "volunteer_admin" ON volunteer_profiles
  FOR ALL USING (auth.email() = 'admin@tinybloom.com');

-- Enable RLS and allow insert on next_of_kin_profiles
ALTER TABLE next_of_kin_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "kin_insert" ON next_of_kin_profiles;
CREATE POLICY "kin_insert" ON next_of_kin_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "kin_select" ON next_of_kin_profiles
  FOR SELECT USING (auth.uid() = user_id);

-- Make sure handle_new_user trigger runs as superuser
ALTER FUNCTION handle_new_user() SECURITY DEFINER SET search_path = public;

-- Test: verify policies are in place
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('profiles', 'specialist_profiles', 'volunteer_profiles')
ORDER BY tablename;
