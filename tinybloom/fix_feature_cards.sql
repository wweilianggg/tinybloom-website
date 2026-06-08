-- Run this in Supabase SQL Editor
-- Seeds all default feature card content

INSERT INTO site_settings (setting_key, setting_value, description) VALUES
  ('feat_card1_title', 'Baby Monitor', 'Feature card 1 title'),
  ('feat_card1_desc', 'Track your baby''s kicks, movements, and heartbeat patterns in real-time. Get alerts for unusual activity and share reports with your doctor instantly.', 'Feature card 1 description'),
  ('feat_card1_badge', '✓ Free & Premium', 'Feature card 1 badge'),
  ('feat_card2_title', 'Health Tracker', 'Feature card 2 title'),
  ('feat_card2_desc', 'Monitor your weight, blood pressure, symptoms, and appointment reminders all in one place. Keep a complete pregnancy health journal with visual trends.', 'Feature card 2 description'),
  ('feat_card2_badge', '✓ Free & Premium', 'Feature card 2 badge'),
  ('feat_card3_title', 'Expert Consultation', 'Feature card 3 title'),
  ('feat_card3_desc', 'Chat with volunteer doctors and specialists for free advice. Upgrade to premium for one-on-one video consultations and personalized care from verified specialists.', 'Feature card 3 description'),
  ('feat_card3_badge', '⭐ Premium Feature (Video)', 'Feature card 3 badge'),
  ('feat_card4_title', 'AI Recommendations', 'Feature card 4 title'),
  ('feat_card4_desc', 'Get personalised weekly tips, nutrition advice, and health guidelines based on your trimester, health profile, and specific needs. Powered by advanced AI.', 'Feature card 4 description'),
  ('feat_card4_badge', '⭐ Premium Feature', 'Feature card 4 badge'),
  ('feat_card5_title', 'Education Support', 'Feature card 5 title'),
  ('feat_card5_desc', 'Expert-guided tips on breastfeeding, pumping schedules, and latching techniques. Access video tutorials and in-depth guides curated by certified professionals.', 'Feature card 5 description'),
  ('feat_card5_badge', '⭐ Full Library (Premium)', 'Feature card 5 badge'),
  ('feat_card6_title', 'Appointment Reminders', 'Feature card 6 title'),
  ('feat_card6_desc', 'Never miss a prenatal check-up. Set reminders for scans, blood tests, and doctor visits. Sync with your calendar and share with your next of kin.', 'Feature card 6 description'),
  ('feat_card6_badge', '✓ Free & Premium', 'Feature card 6 badge'),
  ('feat_card7_title', 'Family Portal', 'Feature card 7 title'),
  ('feat_card7_desc', 'Invite your partner or next of kin to stay updated on pregnancy milestones, appointments, and health summaries — keeping your support network connected.', 'Feature card 7 description'),
  ('feat_card7_badge', '✓ All Account Types', 'Feature card 7 badge'),
  ('feat_card8_title', 'Pregnancy Articles & FAQ', 'Feature card 8 title'),
  ('feat_card8_desc', 'Browse our curated library of articles and frequently asked questions written by medical experts. From first trimester to postpartum care.', 'Feature card 8 description'),
  ('feat_card8_badge', '✓ Free for All', 'Feature card 8 badge'),
  ('feat_card_count', '8', 'Total number of feature cards')
ON CONFLICT (setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value;
