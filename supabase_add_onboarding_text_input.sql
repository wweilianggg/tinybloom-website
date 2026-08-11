-- ============================================================================
-- Add the `is_text_input` flag to onboarding_options without deleting any
-- rows. Use this instead of re-running supabase_onboarding_options.sql on a
-- live database, since that script deletes and reseeds all rows.
--
-- This lets an option (like "Other") render as a free-text box in the app
-- instead of a plain checkbox, based on a per-row flag rather than matching
-- the label text "Other". That means the text-box behavior survives renaming
-- or deleting the current "Other" row, and can be enabled on any option.
--
-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query).
-- Safe to re-run.
-- ============================================================================

alter table public.onboarding_options add column if not exists is_text_input boolean not null default false;

-- Carry the flag over for existing rows currently named "Other".
update public.onboarding_options set is_text_input = true where label = 'Other';
