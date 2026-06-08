-- Run this in Supabase SQL Editor
-- Adds feature text settings keys

INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('feat1_title', 'Baby Monitor', 'Feature 1 title'),
  ('feat1_desc', 'Track your baby''s kicks, movements, and heartbeat patterns in real-time. Get alerts for unusual activity and share reports with your doctor.', 'Feature 1 description'),
  ('feat2_title', 'Health Tracker', 'Feature 2 title'),
  ('feat2_desc', 'Monitor your weight, blood pressure, symptoms, and appointment reminders all in one place. Keep a complete pregnancy health journal.', 'Feature 2 description'),
  ('feat3_title', 'Expert Consultation', 'Feature 3 title'),
  ('feat3_desc', 'Chat with volunteer doctors and specialists for free advice. Upgrade to premium for one-on-one video consultations and personalized care.', 'Feature 3 description'),
  ('feat4_title', 'AI Recommendations', 'Feature 4 title'),
  ('feat4_desc', 'Get personalised weekly tips, nutrition advice, and health guidelines based on your trimester, health profile, and specific needs.', 'Feature 4 description'),
  ('feat5_title', 'Education Support', 'Feature 5 title'),
  ('feat5_desc', 'Expert-guided tips on breastfeeding, pumping schedules, and latching techniques. Access video tutorials anytime.', 'Feature 5 description'),
  ('feat6_title', 'Appointment Reminders', 'Feature 6 title'),
  ('feat6_desc', 'Never miss a prenatal check-up. Set reminders for scans, blood tests, and doctor visits.', 'Feature 6 description')
ON CONFLICT (setting_key) DO NOTHING;

-- Payment page text settings
INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('payment_title', 'Get TinyBloom Premium', 'Payment page main title'),
  ('payment_subtitle', 'Unlock all features for a happier, better-supported pregnancy.', 'Payment page subtitle'),
  ('payment_plan_name', 'Premium', 'Plan name on payment page'),
  ('payment_plan_tagline', 'Full access to all TinyBloom features', 'Plan tagline on payment page'),
  ('payment_billing_note_monthly', 'Billed monthly. Cancel anytime.', 'Monthly billing note'),
  ('payment_billing_note_yearly', 'Billed annually. Cancel anytime.', 'Yearly billing note'),
  ('payment_btn', 'Continue to Payment →', 'Continue button text'),
  ('payment_back_btn', '← Back to Registration', 'Back button text')
ON CONFLICT (setting_key) DO NOTHING;

-- Plan bullet points for payment page
INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('plan_bullet1', 'Personalised pregnancy tracking', 'Plan feature bullet 1'),
  ('plan_bullet2', 'Advanced symptom tracking', 'Plan feature bullet 2'),
  ('plan_bullet3', 'AI-powered weekly tips', 'Plan feature bullet 3'),
  ('plan_bullet4', 'Video consultations', 'Plan feature bullet 4'),
  ('plan_bullet5', 'Baby development insights', 'Plan feature bullet 5'),
  ('plan_bullet6', 'Full education library', 'Plan feature bullet 6')
ON CONFLICT (setting_key) DO NOTHING;

-- Features page settings
INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('feat_page_title', 'Everything You Need', 'Features page title'),
  ('feat_page_subtitle', 'Discover all the tools and features TinyBloom offers to support you through every step of your pregnancy.', 'Features page subtitle'),
  ('feat_cta_title', 'Ready to get started?', 'Features page CTA title'),
  ('feat_cta_subtitle', 'Join TinyBloom free today. Upgrade when you''re ready.', 'Features page CTA subtitle'),
  ('feat_cta_btn1', 'Create Free Account', 'Features page CTA button 1'),
  ('feat_cta_btn2', 'View Pricing', 'Features page CTA button 2'),
  -- Subscriptions page settings
  ('sub_page_title', 'Simple Pricing', 'Subscriptions page title'),
  ('sub_page_subtitle', 'Start free and upgrade to unlock advanced features for a happier, better-supported pregnancy.', 'Subscriptions page subtitle'),
  ('sub_premium_name', 'Premium', 'Premium plan name'),
  ('sub_annual_name', 'Premium Annual', 'Annual plan name'),
  ('sub_popular_badge', 'Most Popular', 'Most popular badge text'),
  ('sub_value_badge', 'Best Value', 'Best value badge text'),
  ('sub_compare_title', 'Full Feature Comparison', 'Comparison table title')
ON CONFLICT (setting_key) DO NOTHING;
