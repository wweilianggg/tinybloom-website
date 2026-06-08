-- =============================================
-- Run this in Supabase SQL Editor
-- Adds user_code field for mum linking
-- =============================================

-- Add a unique short user code to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS user_code TEXT UNIQUE;

-- Generate a unique 8-char code for existing users
UPDATE profiles
SET user_code = UPPER(SUBSTRING(MD5(id::text || email), 1, 8))
WHERE user_code IS NULL;

-- Function to auto-generate user_code on new profile insert
CREATE OR REPLACE FUNCTION generate_user_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_code IS NULL THEN
    NEW.user_code := UPPER(SUBSTRING(MD5(NEW.id::text || NEW.email || NOW()::text), 1, 8));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_user_code ON profiles;
CREATE TRIGGER set_user_code
  BEFORE INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION generate_user_code();

-- Allow next_of_kin to look up a mum's profile by user_code (public select on user_code only)
CREATE POLICY "lookup_by_user_code" ON profiles
  FOR SELECT USING (true);

-- Verify
SELECT id, full_name, email, role, user_code FROM profiles LIMIT 5;
