-- Run this once in the Supabase SQL editor.
-- Creates the two lookup tables that back the admin "Lists" section
-- (Specialization for specialists, Area of Expertise for volunteers),
-- seeds them with the options that used to be hardcoded in register.html,
-- and locks them down with RLS so only admins can write to them.

create table if not exists specializations (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists areas_of_expertise (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table specializations enable row level security;
alter table areas_of_expertise enable row level security;

-- Anyone (including the public registration page) can read active entries.
create policy "Public can read active specializations"
  on specializations for select
  using (is_active = true);

create policy "Public can read active areas of expertise"
  on areas_of_expertise for select
  using (is_active = true);

-- Admins (profiles.role = 'admin') can fully manage both tables.
create policy "Admins can manage specializations"
  on specializations for all
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

create policy "Admins can manage areas of expertise"
  on areas_of_expertise for all
  using (exists (select 1 from profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'admin'));

-- Seed with the options that were previously hardcoded in register.html.
insert into specializations (label, display_order) values
  ('OB/GYN', 1),
  ('Maternal-Fetal Medicine (Perinatologist)', 2),
  ('Midwife (CNM)', 3),
  ('Anesthesiologist', 4),
  ('Reproductive Endocrinologist (REI)', 5),
  ('Genetic Counselor', 6),
  ('Urologist/Andrologist', 7),
  ('Endocrinologist', 8),
  ('Cardiologist', 9),
  ('Nephrologist', 10),
  ('Hematologist', 11),
  ('Neonatologist', 12),
  ('Pediatrician', 13),
  ('Psychiatrist/Psychologist (perinatal)', 14),
  ('Pelvic Floor PT', 15),
  ('Lactation Consultant (IBCLC)', 16),
  ('Dietitian/Nutritionist', 17)
on conflict do nothing;

insert into areas_of_expertise (label, display_order) values
  ('Preconception & fertility support', 1),
  ('Pregnancy (general / trimester-specific)', 2),
  ('High-risk pregnancy experience', 3),
  ('Postpartum recovery', 4),
  ('Breastfeeding & feeding support', 5),
  ('Mental health & emotional support', 6),
  ('Loss & grief support (miscarriage, stillbirth)', 7),
  ('Nutrition & lifestyle', 8)
on conflict do nothing;
