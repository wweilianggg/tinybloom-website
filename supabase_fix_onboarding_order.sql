-- ============================================================================
-- Fix onboarding_options sort_order without deleting any rows.
-- Use this instead of re-running supabase_onboarding_options.sql when the
-- live sort_order values have drifted (e.g. after adding entries via
-- Admin > Onboarding) but you don't want to lose custom entries.
--
-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query).
-- ============================================================================

update public.onboarding_options set sort_order = 1 where category = 'medical_condition' and label = 'Gestational Diabetes';
update public.onboarding_options set sort_order = 2 where category = 'medical_condition' and label = 'Hypertension';
update public.onboarding_options set sort_order = 3 where category = 'medical_condition' and label = 'Anemia';
update public.onboarding_options set sort_order = 4 where category = 'medical_condition' and label = 'Thyroid Disorder';
update public.onboarding_options set sort_order = 5 where category = 'medical_condition' and label = 'Asthma';
update public.onboarding_options set sort_order = 6 where category = 'medical_condition' and label = 'Depression / Anxiety';
update public.onboarding_options set sort_order = 7 where category = 'medical_condition' and label = 'Back Pain';
update public.onboarding_options set sort_order = 8 where category = 'medical_condition' and label = 'Other';

update public.onboarding_options set sort_order = 1 where category = 'allergy' and label = 'Nuts';
update public.onboarding_options set sort_order = 2 where category = 'allergy' and label = 'Dairy';
update public.onboarding_options set sort_order = 3 where category = 'allergy' and label = 'Eggs';
update public.onboarding_options set sort_order = 4 where category = 'allergy' and label = 'Seafood';
update public.onboarding_options set sort_order = 5 where category = 'allergy' and label = 'Wheat & Gluten';
update public.onboarding_options set sort_order = 6 where category = 'allergy' and label = 'Soy';
update public.onboarding_options set sort_order = 7 where category = 'allergy' and label = 'Sesame';
update public.onboarding_options set sort_order = 8 where category = 'allergy' and label = 'Fruits & Vegetables';
update public.onboarding_options set sort_order = 9 where category = 'allergy' and label = 'Environmental';
update public.onboarding_options set sort_order = 10 where category = 'allergy' and label = 'Animals';
update public.onboarding_options set sort_order = 11 where category = 'allergy' and label = 'Insect Stings & Bites';
update public.onboarding_options set sort_order = 12 where category = 'allergy' and label = 'Medications & Materials';
update public.onboarding_options set sort_order = 13 where category = 'allergy' and label = 'Other';

-- Any custom rows you've added since (e.g. "Other 2") keep their existing
-- sort_order and will simply sort after the ones fixed above. If you want a
-- specific custom row to sort last, give it a number higher than 13 here:
-- update public.onboarding_options set sort_order = 14 where category = 'allergy' and label = 'Other 2';
