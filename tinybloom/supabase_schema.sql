-- TinyBloom Database Schema for Supabase
-- Run this entire file in Supabase SQL Editor

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- ENUMS
-- =============================================
CREATE TYPE user_role AS ENUM ('admin', 'free_user', 'premium_user', 'next_of_kin', 'specialist', 'volunteer');
CREATE TYPE subscription_status AS ENUM ('active', 'inactive', 'cancelled', 'expired');
CREATE TYPE content_status AS ENUM ('published', 'draft', 'archived');
CREATE TYPE consultation_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');

-- =============================================
-- PROFILES TABLE
-- =============================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role user_role NOT NULL DEFAULT 'free_user',
  phone TEXT,
  date_of_birth DATE,
  profile_picture_url TEXT,
  bio TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- PREGNANCY PROFILES
-- =============================================
CREATE TABLE pregnancy_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  due_date DATE,
  last_menstrual_period DATE,
  current_week INT,
  is_first_pregnancy BOOLEAN DEFAULT FALSE,
  doctor_name TEXT,
  hospital TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- NEXT OF KIN PROFILES
-- =============================================
CREATE TABLE next_of_kin_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  linked_pregnant_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  relationship TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SPECIALIST PROFILES
-- =============================================
CREATE TABLE specialist_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  specialization TEXT NOT NULL,
  license_number TEXT,
  years_experience INT,
  hospital_affiliation TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- VOLUNTEER PROFILES
-- =============================================
CREATE TABLE volunteer_profiles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  expertise TEXT,
  availability TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SUBSCRIPTIONS
-- =============================================
CREATE TABLE subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL,
  status subscription_status DEFAULT 'active',
  price DECIMAL(10,2),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  stripe_subscription_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- ARTICLES
-- =============================================
CREATE TABLE articles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  excerpt TEXT,
  content TEXT NOT NULL,
  category TEXT,
  tags TEXT[],
  cover_image_url TEXT,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  status content_status DEFAULT 'draft',
  is_premium_only BOOLEAN DEFAULT FALSE,
  view_count INT DEFAULT 0,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- FAQ
-- =============================================
CREATE TABLE faqs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category TEXT,
  display_order INT DEFAULT 0,
  is_published BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- HEALTH TRACKER LOGS
-- =============================================
CREATE TABLE health_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  log_date DATE DEFAULT CURRENT_DATE,
  weight_kg DECIMAL(5,2),
  blood_pressure_systolic INT,
  blood_pressure_diastolic INT,
  symptoms TEXT[],
  notes TEXT,
  mood TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- BABY MOVEMENT LOGS
-- =============================================
CREATE TABLE baby_movement_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  movement_type TEXT,
  count INT DEFAULT 1,
  duration_seconds INT,
  notes TEXT
);

-- =============================================
-- APPOINTMENTS
-- =============================================
CREATE TABLE appointments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  appointment_date TIMESTAMPTZ NOT NULL,
  location TEXT,
  doctor_name TEXT,
  notes TEXT,
  reminder_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- CONSULTATIONS
-- =============================================
CREATE TABLE consultations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  specialist_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  status consultation_status DEFAULT 'pending',
  consultation_type TEXT,
  scheduled_at TIMESTAMPTZ,
  notes TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- TESTIMONIALS
-- =============================================
CREATE TABLE testimonials (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  reviewer_name TEXT NOT NULL,
  reviewer_image_url TEXT,
  content TEXT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  review_date DATE DEFAULT CURRENT_DATE,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- SITE SETTINGS
-- =============================================
CREATE TABLE site_settings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  setting_key TEXT UNIQUE NOT NULL,
  setting_value TEXT,
  description TEXT,
  updated_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- AUDIT LOGS
-- =============================================
CREATE TABLE audit_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  admin_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  target_table TEXT,
  target_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- UPDATED_AT TRIGGER
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER articles_updated_at BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER faqs_updated_at BEFORE UPDATE ON faqs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER pregnancy_profiles_updated_at BEFORE UPDATE ON pregnancy_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================
-- AUTO-CREATE PROFILE ON SIGNUP TRIGGER
-- Reads role from user metadata if provided
-- =============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_role_val user_role;
BEGIN
  -- Safely cast role from metadata, default to free_user
  BEGIN
    user_role_val := (NEW.raw_user_meta_data->>'role')::user_role;
  EXCEPTION WHEN invalid_text_representation THEN
    user_role_val := 'free_user';
  END;

  IF user_role_val IS NULL THEN
    user_role_val := 'free_user';
  END IF;

  INSERT INTO profiles (id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    user_role_val
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =============================================
-- ROW LEVEL SECURITY
-- =============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pregnancy_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE baby_movement_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- Profiles: users see own, admins see all
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins full access to profiles"
  ON profiles FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Allow public read on testimonials (published only)
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read published testimonials"
  ON testimonials FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Anyone can insert testimonials"
  ON testimonials FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Admins manage all testimonials"
  ON testimonials FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Public read on faqs and articles
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read published faqs"
  ON faqs FOR SELECT USING (is_published = TRUE);
CREATE POLICY "Admins manage faqs"
  ON faqs FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read published articles"
  ON articles FOR SELECT USING (status = 'published');
CREATE POLICY "Admins manage articles"
  ON articles FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Site settings: public read, admin write
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read site settings"
  ON site_settings FOR SELECT USING (TRUE);
CREATE POLICY "Admins manage site settings"
  ON site_settings FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.role = 'admin')
  );

-- Personal data: owner only
CREATE POLICY "Users manage own health logs"
  ON health_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own movement logs"
  ON baby_movement_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own appointments"
  ON appointments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own consultations"
  ON consultations FOR SELECT USING (auth.uid() = patient_id OR auth.uid() = specialist_id);
CREATE POLICY "Users create consultations"
  ON consultations FOR INSERT WITH CHECK (auth.uid() = patient_id);

-- =============================================
-- SEED: SITE SETTINGS
-- =============================================
INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('site_name', 'TinyBloom', 'Name of the website'),
  ('hero_title', 'Better pregnancy outcomes start with better support.', 'Hero section main title'),
  ('hero_subtitle', 'Our platform delivers personalised insights, and continuous guidance across every pregnancy milestone to create a safer and healthier journey for all mothers.', 'Hero section subtitle'),
  ('contact_email', 'support@tinybloom.com', 'Support contact email'),
  ('premium_monthly_price', '9.90', 'Monthly premium subscription price'),
  ('premium_yearly_price', '90.00', 'Yearly premium subscription price');

-- =============================================
-- SEED: DEFAULT FAQs
-- =============================================
INSERT INTO faqs (question, answer, category, display_order, is_published) VALUES
  ('What is TinyBloom?', 'TinyBloom is a personalised pregnancy support platform that provides insights, health tracking, expert consultations, and community support for expecting mothers.', 'General', 1, TRUE),
  ('Is the Basic plan really free?', 'Yes! The Basic plan is completely free and includes access to pregnancy articles, FAQs, and simple symptom logging.', 'Subscriptions', 2, TRUE),
  ('What does the Premium plan include?', 'Premium includes personalised pregnancy tracking, advanced symptom tracking & alerts, detailed baby development insights, full access to all resources, and priority expert consultations.', 'Subscriptions', 3, TRUE),
  ('How do I book a consultation?', 'You can chat with volunteer doctors for free on the Basic plan. Premium users get access to one-on-one video consultations with specialists.', 'Features', 4, TRUE),
  ('Is my health data secure?', 'Yes. All your data is encrypted and stored securely. We comply with healthcare data privacy standards and never share your personal information.', 'Privacy', 5, TRUE);

-- =============================================
-- SEED: TESTIMONIALS (pre-approved, shown on site)
-- =============================================
INSERT INTO testimonials (reviewer_name, content, rating, review_date, is_published) VALUES
  ('Sarah K.', 'This app really helped me stay on track with my pregnancy. The weekly updates and symptom tracking made me feel more prepared and less anxious throughout my journey.', 5, '2026-03-12', TRUE),
  ('Michael L.', 'I love how easy it is to find reliable information. The articles and tips are simple to understand, and I always feel more confident after reading them.', 5, '2026-04-16', TRUE),
  ('Lauren M.', 'The personalised tracking feature is so helpful. It feels like the app understands what stage I''m in and gives me the right guidance at the right time.', 5, '2026-05-10', TRUE);

-- =============================================
-- SEED: ADMIN ACCOUNT
-- =============================================
-- Step 1: Create the auth user with a known UUID
-- We use Supabase's admin API via the setup page (admin-setup.html)
-- OR run the block below if you prefer pure SQL setup.
--
-- OPTION A (Recommended): Use admin-setup.html on your live site.
--   Visit: https://YOUR_SITE/admin-setup.html
--   This creates the auth user AND profile in one step.
--
-- OPTION B (SQL only — run AFTER creating the user in Auth dashboard):
--   UPDATE profiles SET role = 'admin' WHERE email = 'admin@tinybloom.com';
--
-- The admin-setup.html page locks itself after the first admin is created.

-- =============================================

-- =============================================
-- CREATE ADMIN ACCOUNT
-- After running all the schema above, run these
-- two steps to create your admin login:
--
-- STEP 1: Go to Supabase Dashboard →
--         Authentication → Users → Add User
--         Email:    admin@tinybloom.com
--         Password: TinyBloom@Admin2024!
--         ✅ Check "Auto Confirm User"
--         Click "Create User"
--
-- STEP 2: Run this SQL to assign admin role:
-- =============================================

UPDATE profiles
SET role = 'admin', full_name = 'TinyBloom Admin'
WHERE email = 'admin@tinybloom.com';
