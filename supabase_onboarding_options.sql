-- ============================================================================
-- Onboarding options for moms — Medical Conditions and Allergies selectable
-- during sign-up/onboarding in the app. Mirrors the shape and RLS pattern of
-- `pregnancy_log_options` (see admin/app-logs.html).
--
-- Run this in the Supabase SQL Editor (Project > SQL Editor > New query).
-- Safe to re-run: it adds the `description` column if missing and refreshes
-- the seed data to the latest agreed list.
-- ============================================================================

create table if not exists public.onboarding_options (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('medical_condition', 'allergy')),
  label text not null,
  description text,
  sort_order int not null default 0,
  is_text_input boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.onboarding_options add column if not exists description text;

-- Marks an option as a free-text box (like "Other") instead of a plain
-- checkbox, so this behavior can be toggled per-option from Admin > Onboarding
-- instead of being hardcoded to the label "Other". Deleting/renaming an entry
-- no longer breaks the text-box behavior — it's a flag, not a string match.
alter table public.onboarding_options add column if not exists is_text_input boolean not null default false;

-- Allergies must always have a description; medical conditions don't need one.
alter table public.onboarding_options drop constraint if exists onboarding_options_allergy_description_required;
alter table public.onboarding_options add constraint onboarding_options_allergy_description_required
  check (category <> 'allergy' or (description is not null and length(trim(description)) > 0));

alter table public.onboarding_options enable row level security;

drop policy if exists "Anyone can read onboarding options" on public.onboarding_options;
create policy "Anyone can read onboarding options"
  on public.onboarding_options for select
  using (true);

drop policy if exists "Admins can manage onboarding options" on public.onboarding_options;
create policy "Admins can manage onboarding options"
  on public.onboarding_options for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- ============================================================================
-- Seed data — replaces the earlier hardcoded list with the latest agreed set.
-- Edit freely via Admin > Onboarding after this is loaded.
-- ============================================================================

delete from public.onboarding_options where category in ('medical_condition', 'allergy');

insert into public.onboarding_options (category, label, sort_order, is_text_input) values
  ('medical_condition', 'Gestational Diabetes', 1, false),
  ('medical_condition', 'Hypertension', 2, false),
  ('medical_condition', 'Anemia', 3, false),
  ('medical_condition', 'Thyroid Disorder', 4, false),
  ('medical_condition', 'Asthma', 5, false),
  ('medical_condition', 'Depression / Anxiety', 6, false),
  ('medical_condition', 'Back Pain', 7, false),
  ('medical_condition', 'Other', 8, true);

insert into public.onboarding_options (category, label, description, sort_order, is_text_input) values
  ('allergy', 'Nuts', 'Includes peanuts, almonds, cashews, walnuts, and other tree nuts.', 1, false),
  ('allergy', 'Dairy', 'Includes milk, cheese, yogurt, and other dairy products.', 2, false),
  ('allergy', 'Eggs', 'Includes eggs and foods containing egg products.', 3, false),
  ('allergy', 'Seafood', 'Includes fish, shellfish, prawns, crab, and other seafood.', 4, false),
  ('allergy', 'Wheat & Gluten', 'Includes wheat, barley, rye, and other gluten-containing grains.', 5, false),
  ('allergy', 'Soy', 'Includes soybeans and soy-derived products.', 6, false),
  ('allergy', 'Sesame', 'Includes sesame seeds and sesame oil.', 7, false),
  ('allergy', 'Fruits & Vegetables', 'Specific fruits or vegetables known to trigger a reaction.', 8, false),
  ('allergy', 'Environmental', 'Includes pollen, dust mites, mold, and other environmental allergens.', 9, false),
  ('allergy', 'Animals', 'Includes pet dander from cats, dogs, and other animals.', 10, false),
  ('allergy', 'Insect Stings & Bites', 'Includes bee stings, wasp stings, and other insect bites.', 11, false),
  ('allergy', 'Medications & Materials', 'Includes specific medications, latex, or other materials.', 12, false),
  ('allergy', 'Other', 'Any other allergy not covered by the categories above.', 13, true);
