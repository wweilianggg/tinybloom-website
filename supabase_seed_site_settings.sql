-- ============================================================================
-- Seeds `site_settings` with the current content of the Home, Features,
-- Subscriptions, and Download pages, so each admin-editable field has a
-- real row in the database.
--
-- Safe to re-run: `on conflict (setting_key) do nothing` skips any row that
-- already exists, so it never overwrites saved changes.
--
-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query).
--
-- Not included: register.html and payment.html (no admin editor for these),
-- and testimonials/FAQs (stored in their own tables, not site_settings).
-- ============================================================================

insert into public.site_settings (setting_key, setting_value) values

-- ---------- Home page ----------
('hero_title', $$Better pregnancy outcomes start with better support.$$),
('hero_subtitle', $$Our platform delivers personalised insights, and continuous guidance across every pregnancy milestone to create a safer and healthier journey for all mothers.$$),
('hero_btn_primary', $$Get Started Free$$),
('hero_btn_secondary', $$Learn More$$),
('features_heading', $$More Support. Less Stress. Happier Pregnancy.$$),
('features_subheading', $$Everything you need in one beautiful platform.$$),
('feat1_title', $$Baby Monitor$$),
('feat1_desc', $$Track your baby's kicks, movements, and heartbeat patterns in real-time. Get alerts for unusual activity and share reports with your doctor.$$),
('feat2_title', $$Health Tracker$$),
('feat2_desc', $$Monitor your weight, blood pressure, symptoms, and appointment reminders all in one place. Keep a complete pregnancy health journal.$$),
('feat3_title', $$Expert Consultation$$),
('feat3_desc', $$Chat with volunteer doctors and specialists for free advice. Upgrade to premium for one-on-one video consultations and personalized care.$$),
('feat4_title', $$AI Recommendations$$),
('feat4_desc', $$Get personalised weekly tips, nutrition advice, and health guidelines based on your trimester, health profile, and specific needs.$$),
('feat5_title', $$Education Support$$),
('feat5_desc', $$Expert-guided tips on breastfeeding, pumping schedules, and latching techniques. Access video tutorials anytime.$$),
('feat6_title', $$Appointment Reminders$$),
('feat6_desc', $$Never miss a prenatal check-up. Set reminders for scans, blood tests, and doctor visits.$$),
('home_basic_name', $$Basic$$),
('home_basic_desc', $$Basic information & simple tracking.$$),
('home_basic_features', $$["Pregnancy articles & FAQ","Simple symptom logging","Basic week-by-week tracking"]$$),
('home_premium_name', $$Premium$$),
('home_premium_desc', $$Personalised insights, advanced tracking & full support.$$),
('home_premium_features', $$["Personalised pregnancy tracking","Advanced symptom tracking & alerts","Detailed baby development insights","Full access to all resources"]$$),
('home_annual_name', $$Premium Annual$$),
('home_annual_desc', $$Best value — save vs monthly.$$),
('home_annual_features', $$["Personalised pregnancy tracking","Advanced symptom tracking & alerts","Detailed baby development insights","Full access to all resources"]$$),
('cta_title', $$Start your TinyBloom journey today.$$),
('cta_subtitle', $$Join thousands of mothers who trust TinyBloom for a happier pregnancy.$$),
('cta_btn', $$Register for Free$$),
('site_name', $$TinyBloom$$),
('contact_email', $$support@tinybloom.com$$),
('footer_tagline', $$Personalised pregnancy support for every mother. Better outcomes start with better support.$$),

-- ---------- Features page ----------
('feat_page_title', $$Everything You Need$$),
('feat_page_subtitle', $$Discover all the tools and features TinyBloom offers to support you through every step of your pregnancy.$$),
('feat_cta_title', $$Ready to get started?$$),
('feat_cta_subtitle', $$Join TinyBloom free today. Upgrade when you're ready.$$),
('feat_cta_btn1', $$Create Free Account$$),
('feat_cta_btn2', $$View Pricing$$),
('feat_card_count', $$9$$),
('feat_card1_icon', $$👶$$),
('feat_card1_title', $$Baby Monitor$$),
('feat_card1_desc', $$Track your baby’s kicks, movements, and heartbeat patterns in real-time. Get alerts for unusual activity and share reports with your doctor instantly.$$),
('feat_card1_badge', $$✓ Free & Premium$$),
('feat_card2_icon', $$📊$$),
('feat_card2_title', $$Health Tracker$$),
('feat_card2_desc', $$Monitor your weight, blood pressure, symptoms, and appointment reminders all in one place. Keep a complete pregnancy health journal with visual trends.$$),
('feat_card2_badge', $$✓ Free for All$$),
('feat_card3_icon', $$👩‍⚕️$$),
('feat_card3_title', $$Expert Consultation$$),
('feat_card3_desc', $$Chat with volunteer doctors and specialists for free advice. Upgrade to premium for one-on-one video consultations and personalised care from verified specialists.$$),
('feat_card3_badge', $$⭐ Premium Feature (Specialist)$$),
('feat_card4_icon', $$🤖$$),
('feat_card4_title', $$AI Pregnancy Chatbot$$),
('feat_card4_desc', $$Ask pregnancy-related questions anytime and receive instant guidance on symptoms, baby development, nutrition and general pregnancy concerns through an AI-powered assistant.$$),
('feat_card4_badge', $$✓ Free for All$$),
('feat_card5_icon', $$🎯$$),
('feat_card5_title', $$AI Recommendations$$),
('feat_card5_desc', $$Get personalised weekly tips, nutrition advice and health guidelines based on your trimester, health profile and specific needs. Powered by advanced AI.$$),
('feat_card5_badge', $$⭐ Premium Feature$$),
('feat_card6_icon', $$📚$$),
('feat_card6_title', $$Educational Library$$),
('feat_card6_desc', $$Access pregnancy articles, FAQs and expert-guided educational resources. Premium users enjoy the full education library, videos and advanced learning content.$$),
('feat_card6_badge', $$✓ Free for All$$),
('feat_card7_icon', $$📅$$),
('feat_card7_title', $$Appointment Reminders$$),
('feat_card7_desc', $$Never miss a prenatal check-up. Set reminders for scans, blood tests and doctor visits. Sync with your calendar and share with your next of kin.$$),
('feat_card7_badge', $$✓ Free for All$$),
('feat_card8_icon', $$💑$$),
('feat_card8_title', $$Family Portal$$),
('feat_card8_desc', $$Invite your partner or next of kin to stay updated on pregnancy milestones, appointments and health summaries, keeping your support network connected.$$),
('feat_card8_badge', $$✓ Free for All$$),
('feat_card9_icon', $$📰$$),
('feat_card9_title', $$Pregnancy Articles & FAQ$$),
('feat_card9_desc', $$Browse our curated library of articles and frequently asked questions written by medical experts. From first trimester to postpartum care.$$),
('feat_card9_badge', $$✓ Free for All$$),

-- ---------- Subscriptions page ----------
('sub_page_title', $$Simple Pricing$$),
('sub_page_subtitle', $$Start free and upgrade to unlock advanced features for a happier, better-supported pregnancy.$$),
('premium_monthly_price', $$9.90$$),
('premium_yearly_price', $$90.00$$),
('sub_basic_name', $$Basic$$),
('sub_premium_name', $$Premium$$),
('sub_annual_name', $$Premium Annual$$),
('sub_popular_badge', $$Most Popular$$),
('sub_value_badge', $$Best Value$$),
('sub_basic_desc', $$Basic information & simple tracking.$$),
('sub_premium_monthly_desc', $$Personalised insights, advanced tracking & full support features.$$),
('sub_compare_title', $$Full Feature Comparison$$),
('sub_basic_features', $$["Pregnancy articles & FAQ","AI Pregnancy Chatbot","Health Log (Weight, BP & Symptoms)","Basic week-by-week tracking","Appointment reminders","Emergency Notifications","Volunteer Doctor Consultations"]$$),
('sub_premium_features', $$["Everything in Basic","Advanced symptom tracking & alerts","Detailed baby development insights","AI Personalised Weekly Tips","AI Personalised Recommendations","Video consultations with specialists"]$$),
('sub_compare_sections', $$Tracking,Support,AI & Education$$),
('sub_compare_rows', $$[{"feature":"Basic week-by-week tracking","category":"Tracking","basic":true,"premium":true},{"feature":"Baby movement & kick counter","category":"Tracking","basic":true,"premium":true},{"feature":"Health log (weight, BP, symptoms)","category":"Tracking","basic":true,"premium":true},{"feature":"Personalised pregnancy timeline","category":"Tracking","basic":false,"premium":true},{"feature":"Advanced symptom tracking & alerts","category":"Tracking","basic":false,"premium":true},{"feature":"Detailed baby development insights","category":"Tracking","basic":false,"premium":true},{"feature":"Pregnancy articles & FAQ","category":"Support","basic":true,"premium":true},{"feature":"Chat with volunteer doctors","category":"Support","basic":true,"premium":true},{"feature":"1-on-1 video with specialists","category":"Support","basic":false,"premium":true},{"feature":"Basic article library","category":"AI & Education","basic":true,"premium":true},{"feature":"AI weekly personalised tips","category":"AI & Education","basic":false,"premium":true},{"feature":"Full education library + videos","category":"AI & Education","basic":false,"premium":true}]$$),

-- ---------- Download page ----------
('download_app_url', $$https://tinybloom.app/download$$)

on conflict (setting_key) do nothing;
