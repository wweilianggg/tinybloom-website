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
  created_at timestamptz not null default now()
);

alter table public.onboarding_options add column if not exists description text;

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

insert into public.onboarding_options (category, label, sort_order) values
  ('medical_condition', 'Gestational Diabetes', 1),
  ('medical_condition', 'Hypertension', 2),
  ('medical_condition', 'Anemia', 3),
  ('medical_condition', 'Thyroid Disorder', 4),
  ('medical_condition', 'Asthma', 5),
  ('medical_condition', 'Depression / Anxiety', 6),
  ('medical_condition', 'Back Pain', 7),
  ('medical_condition', 'Other', 8);

insert into public.onboarding_options (category, label, description, sort_order) values
  ('allergy', 'Nuts', 'Includes peanuts, almonds, cashews, walnuts, and other tree nuts.', 1),
  ('allergy', 'Dairy', 'Includes milk, cheese, yogurt, and other dairy products.', 2),
  ('allergy', 'Eggs', 'Includes eggs and foods containing egg products.', 3),
  ('allergy', 'Seafood', 'Includes fish, shellfish, prawns, crab, and other seafood.', 4),
  ('allergy', 'Wheat & Gluten', 'Includes wheat, barley, rye, and other gluten-containing grains.', 5),
  ('allergy', 'Soy', 'Includes soybeans and soy-derived products.', 6),
  ('allergy', 'Sesame', 'Includes sesame seeds and sesame oil.', 7),
  ('allergy', 'Fruits & Vegetables', 'Specific fruits or vegetables known to trigger a reaction.', 8),
  ('allergy', 'Environmental', 'Includes pollen, dust mites, mold, and other environmental allergens.', 9),
  ('allergy', 'Animals', 'Includes pet dander from cats, dogs, and other animals.', 10),
  ('allergy', 'Insect Stings & Bites', 'Includes bee stings, wasp stings, and other insect bites.', 11),
  ('allergy', 'Medications & Materials', 'Includes specific medications, latex, or other materials.', 12),
  ('allergy', 'Other', 'Any other allergy not covered by the categories above.', 13);
