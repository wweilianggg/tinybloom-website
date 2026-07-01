-- =============================================
-- Run this in Supabase SQL Editor
-- Creates the missing next_of_kin_profiles row
-- whenever a next_of_kin account is registered.
--
-- Fires AFTER a row is inserted into `profiles` (by whatever
-- already creates that row, e.g. the existing handle_new_user
-- trigger). Reads linked_pregnant_user_id / relationship back
-- out of auth.users.raw_user_meta_data, which register.html now
-- sends via supabaseClient.auth.signUp({ options: { data: ... } }).
--
-- SECURITY DEFINER means this runs with elevated privileges and
-- bypasses RLS, so it works even if the browser has no active
-- session yet (e.g. email confirmation still pending).
-- =============================================

CREATE OR REPLACE FUNCTION handle_new_kin_profile()
RETURNS TRIGGER AS $$
DECLARE
  meta JSONB;
BEGIN
  IF NEW.role = 'next_of_kin' THEN
    SELECT raw_user_meta_data INTO meta FROM auth.users WHERE id = NEW.id;

    INSERT INTO next_of_kin_profiles (user_id, linked_pregnant_user_id, relationship)
    VALUES (
      NEW.id,
      NULLIF(meta->>'linked_pregnant_user_id', '')::uuid,
      meta->>'relationship'
    )
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_profile_created_kin ON profiles;
CREATE TRIGGER on_profile_created_kin
  AFTER INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION handle_new_kin_profile();

-- Verify the trigger is in place
SELECT tgname FROM pg_trigger WHERE tgname = 'on_profile_created_kin';

-- After registering a test next_of_kin account, verify the link was created:
-- SELECT k.*, p.full_name AS kin_name, m.full_name AS mum_name
-- FROM next_of_kin_profiles k
-- JOIN profiles p ON p.id = k.user_id
-- LEFT JOIN profiles m ON m.id = k.linked_pregnant_user_id
-- ORDER BY k.created_at DESC;
